import type { DocumentInput } from "../ingest/load.js";
import type { ContractType } from "../schemas/index.js";
import {
  ProviderUnavailableError,
  type ClassifyResult,
  type ExtractionProvider,
  type ProviderExtractResult,
} from "./types.js";

export class MistralProvider implements ExtractionProvider {
  readonly name = "mistral-eu";

  constructor() {
    if (!process.env["MISTRAL_API_KEY"]) {
      throw new ProviderUnavailableError(
        "MISTRAL_API_KEY is not set. The Mistral adapter is a stub in sprint 1."
      );
    }
  }

  async classify(_doc: DocumentInput): Promise<ClassifyResult> {
    throw new ProviderUnavailableError("Mistral adapter not implemented yet (sprint 1 stub).");
  }

  async extract(_doc: DocumentInput, _type: ContractType): Promise<ProviderExtractResult> {
    throw new ProviderUnavailableError("Mistral adapter not implemented yet (sprint 1 stub).");
  }
}
