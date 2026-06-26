import { z } from "zod";
import { ContractBase, Money } from "./common.js";

export const LiabilityContract = ContractBase.extend({
  contractType: z.literal("privathaftpflicht"),
  coverageSum: Money.nullable(),
  deductible: Money.nullable(),
  insuredPersons: z.enum(["single", "paar", "familie"]).nullable(),
});
export type LiabilityContract = z.infer<typeof LiabilityContract>;
