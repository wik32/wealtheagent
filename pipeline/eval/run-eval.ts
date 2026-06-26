import { readdir, readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { basename, dirname, extname, join } from "node:path";
import { parseArgs } from "node:util";
import { loadEnv } from "../src/env.js";
import { loadDocument } from "../src/ingest/load.js";

loadEnv();
import { extractContract } from "../src/extract.js";
import { createProvider, type ProviderName } from "../src/providers/index.js";

const here = dirname(fileURLToPath(import.meta.url));
const samplesDir = join(here, "samples");
const expectedDir = join(here, "expected");

const { values } = parseArgs({
  options: { provider: { type: "string", default: "mock" } },
});
const providerName = values.provider as ProviderName;
const provider = createProvider(providerName, { fixtureDir: expectedDir });

interface Expected {
  contractType: string | null;
  data: Record<string, unknown> | null;
}

interface Row {
  sample: string;
  type: string;
  fieldsCorrect: number;
  fieldsTotal: number;
  note: string;
}

const deepEqual = (a: unknown, b: unknown): boolean =>
  JSON.stringify(normalize(a)) === JSON.stringify(normalize(b));

function normalize(v: unknown): unknown {
  if (Array.isArray(v)) return v.map(normalize);
  if (v && typeof v === "object") {
    return Object.fromEntries(
      Object.entries(v as Record<string, unknown>)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([k, val]) => [k, normalize(val)])
    );
  }
  return v;
}

const files = (await readdir(samplesDir)).filter((f) => !f.startsWith(".")).sort();
if (files.length === 0) {
  console.error("No samples found. Run `npm run make-samples` first.");
  process.exit(2);
}

const rows: Row[] = [];

for (const file of files) {
  const sampleName = basename(file, extname(file));
  const baseName = sampleName.replace(/_foto$/, "");
  const expected = JSON.parse(
    await readFile(join(expectedDir, `${baseName}.json`), "utf8")
  ) as Expected;

  const doc = await loadDocument(join(samplesDir, file));
  const result = await extractContract(doc, provider);

  if (expected.contractType === null) {
    const ok = result.status === "rejected";
    rows.push({
      sample: sampleName,
      type: "(kein Vertrag)",
      fieldsCorrect: ok ? 1 : 0,
      fieldsTotal: 1,
      note: ok ? "korrekt abgelehnt" : `FEHLER: nicht abgelehnt (${result.status})`,
    });
    continue;
  }

  if (result.status === "rejected") {
    const total = Object.keys(expected.data ?? {}).length + 1;
    rows.push({
      sample: sampleName,
      type: expected.contractType,
      fieldsCorrect: 0,
      fieldsTotal: total,
      note: `abgelehnt: ${result.reason}`,
    });
    continue;
  }

  let correct = 0;
  const wrong: string[] = [];
  const entries = Object.entries(expected.data ?? {});
  if (result.contractType === expected.contractType) correct += 1;
  else wrong.push("contractType");
  for (const [field, expectedValue] of entries) {
    const actual = (result.contract as Record<string, unknown>)[field];
    if (deepEqual(actual, expectedValue)) correct += 1;
    else wrong.push(field);
  }
  rows.push({
    sample: sampleName,
    type: expected.contractType,
    fieldsCorrect: correct,
    fieldsTotal: entries.length + 1,
    note: wrong.length ? `abweichend: ${wrong.join(", ")}` : "",
  });
}

console.log(`\nEval — provider: ${provider.name}\n`);
const pad = (s: string, n: number) => s.padEnd(n);
console.log(pad("Sample", 32) + pad("Typ", 22) + pad("Felder", 10) + "Hinweis");
console.log("-".repeat(90));
let totalCorrect = 0;
let totalFields = 0;
for (const r of rows) {
  totalCorrect += r.fieldsCorrect;
  totalFields += r.fieldsTotal;
  console.log(
    pad(r.sample, 32) + pad(r.type, 22) + pad(`${r.fieldsCorrect}/${r.fieldsTotal}`, 10) + r.note
  );
}
const accuracy = totalFields ? (100 * totalCorrect) / totalFields : 0;
console.log("-".repeat(90));
console.log(`Feld-Genauigkeit gesamt: ${totalCorrect}/${totalFields} (${accuracy.toFixed(1)}%)\n`);
process.exit(accuracy === 100 ? 0 : accuracy >= 85 ? 0 : 1);
