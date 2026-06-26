import { loadEnv } from "../src/env.js";

loadEnv();

const region = process.env["AWS_REGION"] ?? "eu-central-1";
const classifyModel =
  process.env["FINANZAPP_CLASSIFY_MODEL"] ?? "eu.anthropic.claude-haiku-4-5-20251001-v1:0";
const extractModel =
  process.env["FINANZAPP_EXTRACT_MODEL"] ?? "eu.anthropic.claude-opus-4-6-v1";

console.log("FinanzApp Preflight — Claude auf AWS Bedrock (EU)\n");
console.log(`  Region:               ${region}`);
console.log(`  Klassifikationsmodell: ${classifyModel}`);
console.log(`  Extraktionsmodell:     ${extractModel}\n`);

const hasEnvCreds =
  !!process.env["AWS_ACCESS_KEY_ID"] && !!process.env["AWS_SECRET_ACCESS_KEY"];
const hasBearerToken = !!process.env["AWS_BEARER_TOKEN_BEDROCK"];
if (!hasEnvCreds && !hasBearerToken) {
  console.error(
    "✗ Keine AWS-Zugangsdaten gefunden.\n" +
      "  Lege pipeline/.env an (Vorlage: .env.example) mit AWS_ACCESS_KEY_ID und\n" +
      "  AWS_SECRET_ACCESS_KEY — oder nutze ~/.aws/credentials bzw. AWS_BEARER_TOKEN_BEDROCK.\n" +
      "  Hinweis: Dieser Check prüft nur Umgebungsvariablen; ~/.aws/credentials\n" +
      "  funktioniert trotzdem — dann diesen Hinweis ignorieren und weiterlaufen lassen."
  );
}

if (!region.startsWith("eu-")) {
  console.warn(`⚠ AWS_REGION ist "${region}" — keine EU-Region. EU-Hosting ist Projektvorgabe.\n`);
}

const { default: AnthropicBedrock } = await import("@anthropic-ai/bedrock-sdk");
const client = new AnthropicBedrock({ awsRegion: region });

async function ping(label: string, model: string): Promise<boolean> {
  const start = Date.now();
  try {
    const res = await client.messages.create({
      model,
      max_tokens: 16,
      messages: [{ role: "user", content: "Antworte nur mit: ok" }],
    });
    const text = res.content.find((b) => b.type === "text");
    console.log(
      `✓ ${label}: erreichbar (${Date.now() - start} ms)` +
        (text && "text" in text ? ` — Antwort: ${text.text.trim().slice(0, 40)}` : "")
    );
    return true;
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(`✗ ${label}: ${msg.split("\n")[0]}`);
    if (/429|too many tokens|throttl|rate exceeded/i.test(msg)) {
      console.error(
        "  → Quota-Limit, NICHT die Zugangsdaten: Die Anmeldung hat funktioniert,\n" +
          "    aber das Token-Tageskontingent des Accounts ist erschöpft (neue AWS-\n" +
          "    Accounts starten mit sehr niedrigen Bedrock-Quotas).\n" +
          "    AWS Console → Service Quotas → Amazon Bedrock (eu-central-1) →\n" +
          "    'tokens per day/minute' für die Claude-Modelle → Erhöhung beantragen.\n" +
          "    Bei ganz neuen Accounts hilft oft auch: 24h warten."
      );
    } else if (/AccessDenied|don't have access|not authorized/i.test(msg)) {
      console.error(
        "  → Modellzugriff fehlt: AWS Console → Bedrock → Model access →\n" +
          "    Anthropic-Modelle in der EU-Region freischalten (meist sofort genehmigt)."
      );
    } else if (/credential|token|signature|expired/i.test(msg)) {
      console.error("  → Zugangsdaten prüfen (pipeline/.env oder ~/.aws/credentials).");
    } else if (/ResolutionError|ENOTFOUND|ECONNREFUSED/i.test(msg)) {
      console.error("  → Netzwerk/Region prüfen — ist die Region korrekt geschrieben?");
    }
    return false;
  }
}

const okClassify = await ping("Klassifikation (Haiku)", classifyModel);
const okExtract = await ping("Extraktion (Opus)", extractModel);

if (okClassify && okExtract) {
  console.log(
    "\nAlles bereit. Nächste Schritte:\n" +
      "  npm run extract -- eval/samples/haftpflicht_huk.pdf --provider claude\n" +
      "  npm run eval -- --provider claude"
  );
  process.exit(0);
}
process.exit(1);
