// FinanzApp — Edge Function: extract-document
// Ablauf: Dokument (RLS-geschützt) aus dem Storage laden → Claude auf AWS
// Bedrock (EU-regionale Modelle) klassifizieren + extrahieren → Ergebnis in
// "contracts" schreiben, Dokumentstatus aktualisieren.
//
// Läuft bewusst mit dem JWT des aufrufenden Nutzers (kein Service-Role-Key):
// Row-Level-Security gilt damit auch hier — niemand kann fremde Dokumente
// extrahieren lassen.
//
// Secrets (supabase secrets set …): AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY,
// optional AWS_REGION (Default eu-central-1).

import { createClient } from "npm:@supabase/supabase-js@2";
import AnthropicBedrock from "npm:@anthropic-ai/bedrock-sdk@0.27.0";

const CLASSIFY_TYPES = [
  "privathaftpflicht",
  "berufsunfaehigkeit",
  "krankenversicherung",
  "lebensversicherung",
  "depot",
  "altersvorsorge",
] as const;

// Kompakte Feldspezifikation je Vertragstyp — gespiegelt aus
// pipeline/src/schemas (schemaVersion 0.1.0, siehe schemas/*.schema.json).
const FIELD_SPECS: Record<string, string> = {
  gemeinsam:
    "provider (Anbietername), contractNumber, startDate (YYYY-MM-DD|null), endDate (YYYY-MM-DD|null), premium ({amount:{amount:Zahl,currency:'EUR'},interval:'monatlich'|'vierteljaehrlich'|'halbjaehrlich'|'jaehrlich'|'einmalig'}|null)",
  privathaftpflicht:
    "coverageSum ({amount,currency}|null), deductible ({amount,currency}|null), insuredPersons ('single'|'paar'|'familie'|null)",
  berufsunfaehigkeit:
    "monthlyBenefit ({amount,currency}|null), benefitEndAge (Zahl|null), dynamics (bool|null)",
  krankenversicherung:
    "kind ('vollversicherung'|'zusatz_zahn'|'zusatz_stationaer'|'zusatz_sonstige'|null), tariff (string|null), reimbursementPercent (0-100|null), annualLimit ({amount,currency}|null)",
  lebensversicherung:
    "kind ('risikoleben'|'kapitalleben'|'fondsgebunden'|null), sumInsured ({amount,currency}|null), beneficiary (string|null), surrenderValue ({amount,currency}|null)",
  depot:
    "custodian (string|null), totalValue ({amount,currency}|null), asOfDate (YYYY-MM-DD|null), positions ([{name,isin|null,units|null,marketValue|null,ter|null}])",
  altersvorsorge:
    "kind ('gesetzlich'|'riester'|'ruerup'|'bav'|'privat'|null), expectedMonthlyPension ({amount,currency}|null), guaranteedMonthlyPension ({amount,currency}|null), retirementAge (Zahl|null), currentBalance ({amount,currency}|null)",
};

const SCHEMA_VERSION = "0.1.0";
const REVIEW_THRESHOLD = 0.8;
const EXTRACT_MODEL =
  Deno.env.get("FINANZAPP_EXTRACT_MODEL") ?? "eu.anthropic.claude-opus-4-6-v1";

Deno.serve(async (req) => {
  try {
    const { document_id } = await req.json();
    if (!document_id) return json({ error: "document_id fehlt" }, 400);

    const authHeader = req.headers.get("Authorization") ?? "";
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData.user) return json({ error: "Nicht angemeldet" }, 401);
    const userId = userData.user.id;

    const { data: doc, error: docError } = await supabase
      .from("documents")
      .select("id, storage_path, status")
      .eq("id", document_id)
      .single();
    if (docError || !doc) return json({ error: "Dokument nicht gefunden" }, 404);

    await supabase.from("documents").update({ status: "processing" }).eq("id", doc.id);

    const { data: blob, error: dlError } = await supabase.storage
      .from("documents")
      .download(doc.storage_path);
    if (dlError || !blob) {
      await supabase.from("documents").update({ status: "failed" }).eq("id", doc.id);
      return json({ error: "Download fehlgeschlagen" }, 500);
    }

    const bytes = new Uint8Array(await blob.arrayBuffer());
    const isPdf = doc.storage_path.toLowerCase().endsWith(".pdf");
    const contentBlock = isPdf
      ? {
          type: "document" as const,
          source: {
            type: "base64" as const,
            media_type: "application/pdf" as const,
            data: encodeBase64(bytes),
          },
        }
      : {
          type: "image" as const,
          source: {
            type: "base64" as const,
            media_type: "image/jpeg" as const,
            data: encodeBase64(bytes),
          },
        };

    const client = new AnthropicBedrock({
      awsRegion: Deno.env.get("AWS_REGION") ?? "eu-central-1",
    });

    const system = `Du extrahierst strukturierte Daten aus deutschen Finanz- und Versicherungsdokumenten.
Antworte AUSSCHLIESSLICH mit einem JSON-Objekt, ohne Markdown:
{"contractType": <einer von ${JSON.stringify([...CLASSIFY_TYPES])} oder null>,
 "data": <Objekt mit den Vertragsfeldern oder null>,
 "fieldConfidence": [{"field": "...", "confidence": 0..1}, ...]}
Wenn das Dokument kein Vertrags-/Finanzdokument ist: contractType null, data null.
Gemeinsame Felder: ${FIELD_SPECS["gemeinsam"]}
Typspezifische Felder: ${CLASSIFY_TYPES.map((t) => `${t}: ${FIELD_SPECS[t]}`).join(" | ")}
Erfinde niemals Werte; fehlende Felder sind null. Beträge als Dezimalzahl (58,90 € => 58.9).`;

    const response = await client.messages.create({
      model: EXTRACT_MODEL,
      max_tokens: 8000,
      system,
      messages: [
        {
          role: "user",
          content: [contentBlock, { type: "text", text: "Extrahiere dieses Dokument." }],
        },
      ],
    });

    const text = response.content.find((b: { type: string }) => b.type === "text") as
      | { text: string }
      | undefined;
    const parsed = JSON.parse(
      (text?.text ?? "{}").replace(/^```json\s*/i, "").replace(/```\s*$/, "")
    );

    if (!parsed.contractType || !CLASSIFY_TYPES.includes(parsed.contractType)) {
      await supabase
        .from("documents")
        .update({
          status: "rejected",
          rejection_reason: "Kein Vertragsdokument erkannt.",
        })
        .eq("id", doc.id);
      return json({
        status: "rejected",
        provider: "claude-bedrock-eu",
        reason: "Kein Vertragsdokument erkannt.",
      });
    }

    const confidences: Record<string, number> = Object.fromEntries(
      (parsed.fieldConfidence ?? []).map(
        (e: { field: string; confidence: number }) => [e.field, e.confidence]
      )
    );
    const fields = Object.fromEntries(
      Object.keys(parsed.data ?? {}).map((k) => {
        const c = Math.min(1, Math.max(0, confidences[k] ?? 0));
        return [k, { confidence: c, needsReview: c < REVIEW_THRESHOLD }];
      })
    );
    const anyReview = Object.values(fields).some(
      (f) => (f as { needsReview: boolean }).needsReview
    );
    const status = anyReview ? "needs_review" : "ok";

    await supabase.from("contracts").insert({
      user_id: userId,
      document_id: doc.id,
      schema_version: SCHEMA_VERSION,
      contract_type: parsed.contractType,
      status,
      data: { ...parsed.data, contractType: parsed.contractType },
      fields,
    });
    await supabase.from("documents").update({ status: "extracted" }).eq("id", doc.id);

    return json({
      status,
      provider: "claude-bedrock-eu",
      schemaVersion: SCHEMA_VERSION,
      contractType: parsed.contractType,
      contract: { ...parsed.data, contractType: parsed.contractType },
      fields,
    });
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function encodeBase64(bytes: Uint8Array): string {
  let binary = "";
  const chunk = 0x8000;
  for (let i = 0; i < bytes.length; i += chunk) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunk));
  }
  return btoa(binary);
}
