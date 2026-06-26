import { mkdir, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { zodToJsonSchema } from "zod-to-json-schema";
import {
  ContractType,
  ExtractedContract,
  SCHEMA_VERSION,
  schemaFor,
} from "../src/schemas/index.js";

const outDir = join(
  dirname(fileURLToPath(import.meta.url)),
  "..",
  "..",
  "schemas"
);
await mkdir(outDir, { recursive: true });

const targets: Record<string, Parameters<typeof zodToJsonSchema>[0]> = {
  "extracted-contract": ExtractedContract,
};
for (const type of ContractType.options) {
  targets[type] = schemaFor(type);
}

for (const [name, schema] of Object.entries(targets)) {
  const json = zodToJsonSchema(schema, {
    name,
    target: "jsonSchema7",
  });
  const withMeta = { $comment: `schemaVersion ${SCHEMA_VERSION}`, ...json };
  await writeFile(
    join(outDir, `${name}.schema.json`),
    JSON.stringify(withMeta, null, 2) + "\n"
  );
  console.log(`exported ${name}.schema.json`);
}
console.log(`\nSchemas (v${SCHEMA_VERSION}) → ${outDir}`);
