import { z } from "zod";
import { SCHEMA_VERSION } from "./common.js";
import { LiabilityContract } from "./liability.js";
import { DisabilityContract } from "./disability.js";
import { HealthContract } from "./health.js";
import { LifeContract } from "./life.js";
import { InvestmentContract } from "./investment.js";
import { PensionContract } from "./pension.js";

export * from "./common.js";
export * from "./liability.js";
export * from "./disability.js";
export * from "./health.js";
export * from "./life.js";
export * from "./investment.js";
export * from "./pension.js";

export const ContractType = z.enum([
  "privathaftpflicht",
  "berufsunfaehigkeit",
  "krankenversicherung",
  "lebensversicherung",
  "depot",
  "altersvorsorge",
]);
export type ContractType = z.infer<typeof ContractType>;

export const ExtractedContract = z.discriminatedUnion("contractType", [
  LiabilityContract,
  DisabilityContract,
  HealthContract,
  LifeContract,
  InvestmentContract,
  PensionContract,
]);
export type ExtractedContract = z.infer<typeof ExtractedContract>;

export const schemaFor = (type: ContractType) => {
  const map = {
    privathaftpflicht: LiabilityContract,
    berufsunfaehigkeit: DisabilityContract,
    krankenversicherung: HealthContract,
    lebensversicherung: LifeContract,
    depot: InvestmentContract,
    altersvorsorge: PensionContract,
  } as const;
  return map[type];
};

export const ExtractionEnvelope = z.object({
  schemaVersion: z.literal(SCHEMA_VERSION),
  contract: ExtractedContract,
});
export type ExtractionEnvelope = z.infer<typeof ExtractionEnvelope>;
