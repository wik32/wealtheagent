import { z } from "zod";
import { ContractBase, Money } from "./common.js";

export const PensionContract = ContractBase.extend({
  contractType: z.literal("altersvorsorge"),
  kind: z
    .enum(["gesetzlich", "riester", "ruerup", "bav", "privat"])
    .nullable(),
  expectedMonthlyPension: Money.nullable(),
  guaranteedMonthlyPension: Money.nullable(),
  retirementAge: z.number().int().min(55).max(75).nullable(),
  currentBalance: Money.nullable(),
});
export type PensionContract = z.infer<typeof PensionContract>;
