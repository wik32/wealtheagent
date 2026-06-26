import { z } from "zod";
import { ContractBase, Money } from "./common.js";

export const LifeContract = ContractBase.extend({
  contractType: z.literal("lebensversicherung"),
  kind: z.enum(["risikoleben", "kapitalleben", "fondsgebunden"]).nullable(),
  sumInsured: Money.nullable(),
  beneficiary: z.string().nullable(),
  surrenderValue: Money.nullable(),
});
export type LifeContract = z.infer<typeof LifeContract>;
