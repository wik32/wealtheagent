import type { DocumentInput } from "../ingest/load.js";
import type { ContractType } from "../schemas/index.js";

export interface ClassifyResult {
  contractType: ContractType | null;
  confidence: number;
}

export interface ProviderExtractResult {
  data: unknown;
  fieldConfidence: Record<string, number>;
}

export interface ExtractionProvider {
  readonly name: string;
  classify(doc: DocumentInput): Promise<ClassifyResult>;
  extract(doc: DocumentInput, type: ContractType): Promise<ProviderExtractResult>;
}

export class ProviderUnavailableError extends Error {}
