import { describe, expect, it } from "vitest";
import {
  ExtractedContract,
  LiabilityContract,
  InvestmentContract,
  monthlyEur,
  schemaFor,
  ContractType,
} from "../src/schemas/index.js";

const validLiability = {
  contractType: "privathaftpflicht",
  provider: "HUK-COBURG",
  contractNumber: "PH-4471-882",
  startDate: "2019-03-01",
  endDate: null,
  premium: { amount: { amount: 58.9, currency: "EUR" }, interval: "jaehrlich" },
  coverageSum: { amount: 10_000_000, currency: "EUR" },
  deductible: null,
  insuredPersons: "single",
};

describe("contract schemas", () => {
  it("accepts a valid liability contract", () => {
    expect(LiabilityContract.safeParse(validLiability).success).toBe(true);
  });

  it("rejects invalid dates", () => {
    const bad = { ...validLiability, startDate: "01.03.2019" };
    expect(LiabilityContract.safeParse(bad).success).toBe(false);
  });

  it("rejects unknown contract types in the union", () => {
    const bad = { ...validLiability, contractType: "kfz" };
    expect(ExtractedContract.safeParse(bad).success).toBe(false);
  });

  it("validates ISINs on depot positions", () => {
    const depot = {
      contractType: "depot",
      provider: "DWS",
      contractNumber: null,
      startDate: null,
      endDate: null,
      premium: null,
      custodian: "DWS",
      totalValue: { amount: 25_000, currency: "EUR" },
      asOfDate: "2026-05-31",
      positions: [
        {
          name: "MSCI World ETF",
          isin: "IE00B4L5Y983",
          units: 120.5,
          marketValue: { amount: 11_000, currency: "EUR" },
          ter: 0.2,
        },
      ],
    };
    expect(InvestmentContract.safeParse(depot).success).toBe(true);
    const badIsin = {
      ...depot,
      positions: [{ ...depot.positions[0], isin: "NOT-AN-ISIN" }],
    };
    expect(InvestmentContract.safeParse(badIsin).success).toBe(false);
  });

  it("maps every contract type to a schema", () => {
    for (const type of ContractType.options) {
      expect(schemaFor(type)).toBeDefined();
    }
  });

  it("converts premiums to monthly EUR", () => {
    expect(
      monthlyEur({ amount: { amount: 120, currency: "EUR" }, interval: "jaehrlich" })
    ).toBeCloseTo(10);
    expect(
      monthlyEur({ amount: { amount: 30, currency: "EUR" }, interval: "monatlich" })
    ).toBe(30);
  });
});
