import type { DocumentInput } from "./ingest/load.js";
import type { ExtractionProvider } from "./providers/types.js";
import {
  SCHEMA_VERSION,
  schemaFor,
  type ContractType,
  type ExtractedContract,
} from "./schemas/index.js";
import { assessFields, type FieldAssessment } from "./confidence.js";

const MIN_CLASSIFY_CONFIDENCE = 0.5;

export type ExtractionResult =
  | {
      status: "ok" | "needs_review";
      schemaVersion: string;
      provider: string;
      contractType: ContractType;
      contract: ExtractedContract;
      fields: Record<string, FieldAssessment>;
    }
  | {
      status: "rejected";
      provider: string;
      reason: string;
    };

export async function extractContract(
  doc: DocumentInput,
  provider: ExtractionProvider
): Promise<ExtractionResult> {
  const classification = await provider.classify(doc);

  if (
    classification.contractType === null ||
    classification.confidence < MIN_CLASSIFY_CONFIDENCE
  ) {
    return {
      status: "rejected",
      provider: provider.name,
      reason:
        "Kein Vertragsdokument erkannt. Unterstützt: Versicherungspolicen, Depotauszüge, Renteninformationen.",
    };
  }

  const contractType = classification.contractType;
  const schema = schemaFor(contractType);
  const raw = await provider.extract(doc, contractType);

  let candidate = ensureObject(raw.data, contractType);
  let parsed = schema.safeParse(candidate);
  const invalidFields: string[] = [];

  if (!parsed.success) {
    for (const issue of parsed.error.issues) {
      const field = issue.path[0];
      if (typeof field === "string" && field !== "contractType") {
        invalidFields.push(field);
        (candidate as Record<string, unknown>)[field] = nullValueFor(field, contractType);
      }
    }
    parsed = schema.safeParse(candidate);
  }

  if (!parsed.success) {
    return {
      status: "rejected",
      provider: provider.name,
      reason: `Extraktion entsprach nicht dem Schema (${contractType}): ${parsed.error.issues
        .map((i) => i.path.join("."))
        .join(", ")}`,
    };
  }

  const fields = assessFields(raw.fieldConfidence, invalidFields);
  const anyReview = Object.values(fields).some((f) => f.needsReview);

  return {
    status: anyReview ? "needs_review" : "ok",
    schemaVersion: SCHEMA_VERSION,
    provider: provider.name,
    contractType,
    contract: parsed.data,
    fields,
  };
}

function ensureObject(data: unknown, contractType: ContractType): Record<string, unknown> {
  const base = typeof data === "object" && data !== null ? { ...(data as Record<string, unknown>) } : {};
  base["contractType"] = contractType;
  return base;
}

function nullValueFor(field: string, contractType: ContractType): unknown {
  if (contractType === "depot" && field === "positions") return [];
  return null;
}
