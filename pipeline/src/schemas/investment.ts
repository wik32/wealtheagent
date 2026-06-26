import { z } from "zod";
import { ContractBase, Money } from "./common.js";

export const InvestmentPosition = z.object({
  name: z.string().min(1),
  isin: z
    .string()
    .regex(/^[A-Z]{2}[A-Z0-9]{9}\d$/, "ISIN format expected")
    .nullable(),
  units: z.number().nonnegative().nullable(),
  marketValue: Money.nullable(),
  ter: z.number().min(0).max(10).nullable(),
});
export type InvestmentPosition = z.infer<typeof InvestmentPosition>;

export const InvestmentContract = ContractBase.extend({
  contractType: z.literal("depot"),
  custodian: z.string().nullable(),
  totalValue: Money.nullable(),
  asOfDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).nullable(),
  positions: z.array(InvestmentPosition),
});
export type InvestmentContract = z.infer<typeof InvestmentContract>;
