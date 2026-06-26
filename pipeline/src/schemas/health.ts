import { z } from "zod";
import { ContractBase, Money } from "./common.js";

export const HealthContract = ContractBase.extend({
  contractType: z.literal("krankenversicherung"),
  kind: z
    .enum(["vollversicherung", "zusatz_zahn", "zusatz_stationaer", "zusatz_sonstige"])
    .nullable(),
  tariff: z.string().nullable(),
  reimbursementPercent: z.number().min(0).max(100).nullable(),
  annualLimit: Money.nullable(),
});
export type HealthContract = z.infer<typeof HealthContract>;
