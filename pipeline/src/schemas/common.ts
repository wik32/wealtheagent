import { z } from "zod";

export const SCHEMA_VERSION = "0.1.0";

export const Money = z.object({
  amount: z.number().nonnegative(),
  currency: z.literal("EUR").default("EUR"),
});
export type Money = z.infer<typeof Money>;

export const PaymentInterval = z.enum([
  "monatlich",
  "vierteljaehrlich",
  "halbjaehrlich",
  "jaehrlich",
  "einmalig",
]);
export type PaymentInterval = z.infer<typeof PaymentInterval>;

export const IsoDate = z
  .string()
  .regex(/^\d{4}-\d{2}-\d{2}$/, "ISO date YYYY-MM-DD expected");

export const Premium = z.object({
  amount: Money,
  interval: PaymentInterval,
});
export type Premium = z.infer<typeof Premium>;

export const ContractBase = z.object({
  provider: z.string().min(1),
  contractNumber: z.string().min(1).nullable(),
  startDate: IsoDate.nullable(),
  endDate: IsoDate.nullable(),
  premium: Premium.nullable(),
});
export type ContractBase = z.infer<typeof ContractBase>;

export const monthlyEur = (p: Premium): number => {
  const factor: Record<PaymentInterval, number> = {
    monatlich: 1,
    vierteljaehrlich: 1 / 3,
    halbjaehrlich: 1 / 6,
    jaehrlich: 1 / 12,
    einmalig: 0,
  };
  return p.amount.amount * factor[p.interval];
};
