import { describe, expect, it } from "vitest";
import { extractContract } from "../src/extract.js";
import type { DocumentInput } from "../src/ingest/load.js";
import type {
  ClassifyResult,
  ExtractionProvider,
  ProviderExtractResult,
} from "../src/providers/types.js";
import type { ContractType } from "../src/schemas/index.js";

const doc: DocumentInput = { kind: "images", name: "test", pages: [new Uint8Array()] };

function provider(
  classify: ClassifyResult,
  extract?: ProviderExtractResult
): ExtractionProvider {
  return {
    name: "test",
    classify: async () => classify,
    extract: async (_d: DocumentInput, _t: ContractType) =>
      extract ?? { data: {}, fieldConfidence: {} },
  };
}

const liabilityData = {
  provider: "HUK-COBURG",
  contractNumber: "PH-1",
  startDate: "2019-03-01",
  endDate: null,
  premium: { amount: { amount: 58.9, currency: "EUR" }, interval: "jaehrlich" },
  coverageSum: { amount: 10_000_000, currency: "EUR" },
  deductible: null,
  insuredPersons: "single",
};

describe("extractContract", () => {
  it("rejects documents that are not contracts", async () => {
    const result = await extractContract(doc, provider({ contractType: null, confidence: 0 }));
    expect(result.status).toBe("rejected");
  });

  it("rejects low-confidence classifications", async () => {
    const result = await extractContract(
      doc,
      provider({ contractType: "privathaftpflicht", confidence: 0.3 })
    );
    expect(result.status).toBe("rejected");
  });

  it("returns ok for clean high-confidence extraction", async () => {
    const fieldConfidence = Object.fromEntries(
      Object.keys(liabilityData).map((k) => [k, 0.95])
    );
    const result = await extractContract(
      doc,
      provider(
        { contractType: "privathaftpflicht", confidence: 0.98 },
        { data: liabilityData, fieldConfidence }
      )
    );
    expect(result.status).toBe("ok");
    if (result.status !== "rejected") {
      expect(result.contract.provider).toBe("HUK-COBURG");
    }
  });

  it("flags low-confidence fields as needs_review", async () => {
    const fieldConfidence = {
      ...Object.fromEntries(Object.keys(liabilityData).map((k) => [k, 0.95])),
      startDate: 0.4,
    };
    const result = await extractContract(
      doc,
      provider(
        { contractType: "privathaftpflicht", confidence: 0.98 },
        { data: liabilityData, fieldConfidence }
      )
    );
    expect(result.status).toBe("needs_review");
    if (result.status !== "rejected") {
      expect(result.fields["startDate"]?.needsReview).toBe(true);
    }
  });

  it("nulls invalid fields and marks them for review instead of failing", async () => {
    const badData = { ...liabilityData, startDate: "01.03.2019" };
    const fieldConfidence = Object.fromEntries(
      Object.keys(badData).map((k) => [k, 0.95])
    );
    const result = await extractContract(
      doc,
      provider(
        { contractType: "privathaftpflicht", confidence: 0.98 },
        { data: badData, fieldConfidence }
      )
    );
    expect(result.status).toBe("needs_review");
    if (result.status !== "rejected") {
      expect(result.contract.startDate).toBeNull();
      expect(result.fields["startDate"]?.confidence).toBe(0);
    }
  });
});
