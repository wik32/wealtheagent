import AnthropicBedrock from "@anthropic-ai/bedrock-sdk";
import { z } from "zod";
import { zodOutputFormat } from "@anthropic-ai/sdk/helpers/zod";
import type { DocumentInput } from "../ingest/load.js";
import { ContractType, schemaFor } from "../schemas/index.js";
import type {
  ClassifyResult,
  ExtractionProvider,
  ProviderExtractResult,
} from "./types.js";

// EU-regional (CRIS) model IDs — data stays in EU regions, per DSGVO posture.
const CLASSIFY_MODEL =
  process.env["FINANZAPP_CLASSIFY_MODEL"] ??
  "eu.anthropic.claude-haiku-4-5-20251001-v1:0";
const EXTRACT_MODEL =
  process.env["FINANZAPP_EXTRACT_MODEL"] ?? "eu.anthropic.claude-opus-4-6-v1";

const ClassificationOutput = z.object({
  contractType: ContractType.nullable(),
  confidence: z.number().min(0).max(1),
});

const FieldConfidenceEntry = z.object({
  field: z.string(),
  confidence: z.number().min(0).max(1),
});

const CLASSIFY_SYSTEM = `Du klassifizierst deutsche Finanz- und Versicherungsdokumente.
Mögliche Typen: privathaftpflicht, berufsunfaehigkeit, krankenversicherung (inkl. Zusatzversicherungen wie Zahnzusatz), lebensversicherung, depot (Depot-/Fondsauszüge), altersvorsorge (Renteninformation, Riester, Rürup, bAV, private Rente).
Wenn das Dokument kein solches Vertrags- oder Finanzdokument ist, gib contractType null und confidence 0 zurück. Erfinde niemals einen Typ.`;

const EXTRACT_SYSTEM = `Du extrahierst strukturierte Daten aus deutschen Finanz- und Versicherungsdokumenten.
Regeln:
- Gib für jedes Top-Level-Feld der Vertragsdaten einen Eintrag in fieldConfidence (0 bis 1) an: wie sicher die Information direkt aus dem Dokument abzulesen war.
- Felder, die im Dokument nicht vorkommen, sind null (Konfidenz 1.0, wenn sicher abwesend; niedriger, wenn unklar).
- Erfinde niemals Werte. Datumsangaben als ISO YYYY-MM-DD. Beträge in EUR als Dezimalzahl (58,90 € => 58.9).
- Beitrag (premium): amount + Zahlungsintervall (monatlich/vierteljaehrlich/halbjaehrlich/jaehrlich/einmalig).`;

export class BedrockClaudeProvider implements ExtractionProvider {
  readonly name = "claude-bedrock-eu";
  private readonly client: AnthropicBedrock;

  constructor() {
    this.client = new AnthropicBedrock({
      awsRegion: process.env["AWS_REGION"] ?? "eu-central-1",
    });
  }

  private static contentBlocks(doc: DocumentInput) {
    if (doc.kind === "pdf") {
      return [
        {
          type: "document" as const,
          source: {
            type: "base64" as const,
            media_type: "application/pdf" as const,
            data: Buffer.from(doc.bytes).toString("base64"),
          },
        },
      ];
    }
    return doc.pages.map((page) => ({
      type: "image" as const,
      source: {
        type: "base64" as const,
        media_type: "image/jpeg" as const,
        data: Buffer.from(page).toString("base64"),
      },
    }));
  }

  async classify(doc: DocumentInput): Promise<ClassifyResult> {
    const response = await this.client.messages.create({
      model: CLASSIFY_MODEL,
      max_tokens: 512,
      system: CLASSIFY_SYSTEM,
      output_config: { format: zodOutputFormat(ClassificationOutput) },
      messages: [
        {
          role: "user",
          content: [
            ...BedrockClaudeProvider.contentBlocks(doc),
            { type: "text", text: "Klassifiziere dieses Dokument." },
          ],
        },
      ],
    });
    const parsed = ClassificationOutput.safeParse(JSON.parse(firstText(response)));
    if (!parsed.success) return { contractType: null, confidence: 0 };
    return parsed.data;
  }

  async extract(doc: DocumentInput, type: ContractType): Promise<ProviderExtractResult> {
    const contractSchema = schemaFor(type);
    const outputSchema = z.object({
      data: contractSchema,
      fieldConfidence: z.array(FieldConfidenceEntry),
    });

    const response = await this.client.messages.create({
      model: EXTRACT_MODEL,
      max_tokens: 16000,
      system: EXTRACT_SYSTEM,
      output_config: { format: zodOutputFormat(outputSchema) },
      messages: [
        {
          role: "user",
          content: [
            ...BedrockClaudeProvider.contentBlocks(doc),
            {
              type: "text",
              text: `Extrahiere die Vertragsdaten (Vertragstyp: ${type}) aus diesem Dokument.`,
            },
          ],
        },
      ],
    });

    const raw = JSON.parse(firstText(response)) as {
      data: unknown;
      fieldConfidence: Array<{ field: string; confidence: number }>;
    };
    return {
      data: raw.data,
      fieldConfidence: Object.fromEntries(
        (raw.fieldConfidence ?? []).map((e) => [e.field, e.confidence])
      ),
    };
  }
}

function firstText(response: { content: Array<{ type: string }> }): string {
  for (const block of response.content) {
    if (block.type === "text") return (block as { type: "text"; text: string }).text;
  }
  throw new Error("Model response contained no text block");
}
