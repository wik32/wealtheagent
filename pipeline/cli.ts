import { parseArgs } from "node:util";
import { loadEnv } from "./src/env.js";
import { loadDocument, UnsupportedDocumentError } from "./src/ingest/load.js";

loadEnv();
import { extractContract } from "./src/extract.js";
import { createProvider, type ProviderName } from "./src/providers/index.js";

const { values, positionals } = parseArgs({
  allowPositionals: true,
  options: {
    provider: { type: "string", default: "mock" },
    fixtures: { type: "string" },
  },
});

const file = positionals[0];
if (!file) {
  console.error("Usage: npm run extract -- <file> [--provider mock|claude|mistral]");
  process.exit(2);
}

const providerName = values.provider as ProviderName;
if (!["mock", "claude", "mistral"].includes(providerName)) {
  console.error(`Unknown provider "${providerName}". Use: mock, claude, mistral`);
  process.exit(2);
}

try {
  const doc = await loadDocument(file);
  const provider = createProvider(providerName, { fixtureDir: values.fixtures });
  const result = await extractContract(doc, provider);
  console.log(JSON.stringify(result, null, 2));
  process.exit(result.status === "rejected" ? 1 : 0);
} catch (err) {
  if (err instanceof UnsupportedDocumentError) {
    console.error(err.message);
    process.exit(2);
  }
  throw err;
}
