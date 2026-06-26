export const REVIEW_THRESHOLD = 0.8;

export interface FieldAssessment {
  confidence: number;
  needsReview: boolean;
}

export function assessFields(
  fieldConfidence: Record<string, number>,
  invalidFields: string[]
): Record<string, FieldAssessment> {
  const out: Record<string, FieldAssessment> = {};
  for (const [field, raw] of Object.entries(fieldConfidence)) {
    const confidence = invalidFields.includes(field) ? 0 : clamp01(raw);
    out[field] = { confidence, needsReview: confidence < REVIEW_THRESHOLD };
  }
  for (const field of invalidFields) {
    if (!(field in out)) out[field] = { confidence: 0, needsReview: true };
  }
  return out;
}

const clamp01 = (n: number) => Math.min(1, Math.max(0, n));
