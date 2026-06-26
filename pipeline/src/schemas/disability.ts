import { z } from "zod";
import { ContractBase, Money } from "./common.js";

export const DisabilityContract = ContractBase.extend({
  contractType: z.literal("berufsunfaehigkeit"),
  monthlyBenefit: Money.nullable(),
  benefitEndAge: z.number().int().min(50).max(75).nullable(),
  dynamics: z.boolean().nullable(),
});
export type DisabilityContract = z.infer<typeof DisabilityContract>;
