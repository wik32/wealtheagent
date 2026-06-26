import { readFile } from "node:fs/promises";
import { join } from "node:path";
import type { DocumentInput } from "../ingest/load.js";
import { ContractType } from "../schemas/index.js";
import type {
  ClassifyResult,
  ExtractionProvider,
  ProviderExtractResult,
} from "./types.js";

interface MockFixture {
  contractType: string;
  data: Record<string, unknown>;
  fieldConfidence?: Record<string, number>;
}

export class MockProvider implements ExtractionProvider {
  readonly name = "mock";

  constructor(private readonly fixtureDir: string) {}

  private async fixtureFor(doc: DocumentInput): Promise<MockFixture | null> {
    const baseName = doc.name.replace(/_foto$/, "");
    try {
      const raw = await readFile(join(this.fixtureDir, `${baseName}.json`), "utf8");
      return JSON.parse(raw) as MockFixture;
    } catch {
      return null;
    }
  }

  async classify(doc: DocumentInput): Promise<ClassifyResult> {
    const fixture = await this.fixtureFor(doc);
    const parsed = ContractType.safeParse(fixture?.contractType);
    if (!fixture || !parsed.success) return { contractType: null, confidence: 0 };
    return { contractType: parsed.data, confidence: 0.99 };
  }

  async extract(doc: DocumentInput): Promise<ProviderExtractResult> {
    const fixture = await this.fixtureFor(doc);
    if (!fixture) return { data: {}, fieldConfidence: {} };
    const fieldConfidence =
      fixture.fieldConfidence ??
      Object.fromEntries(Object.keys(fixture.data).map((k) => [k, 0.99]));
    return { data: fixture.data, fieldConfidence };
  }
}
