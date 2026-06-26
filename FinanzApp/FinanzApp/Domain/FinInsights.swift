// FinInsights.swift
// FinanzApp — Domain Layer
// SCAFFOLD: true — RED scaffold created by DISTILL wave

import Foundation

/// The complete set of computed observations and measurements for a user's portfolio.
/// Produced by InsightsEngine. Never persisted.
/// DE: Auswertung
struct FinInsights {
    var observations: [Insight]
    var coverageScore: Double        // percentage 0.0–1.0
    var monthlySpend: Double         // EUR, monthly equivalent of all premiums
    var level1CategoriesCovered: Int
    var level1CategoriesTotal: Int
}

/// A single factual observation derived from the contract portfolio.
/// DE: Beobachtung — NEVER "Empfehlung"
struct Insight: Identifiable {
    var id: UUID
    var kind: InsightKind
    var categoryKey: String
    var title: String       // DE user-facing; never contains "empfehlen" or "Empfehlung"
    var detail: String
    var educationLink: String?
    var articleId: String?
    var compareCategory: String?
}

/// The category of a factual observation.
/// DE: Art der Beobachtung
enum InsightKind: String, CaseIterable {
    /// User has more than one confirmed contract of the same category.
    /// DE: Dopplung
    case duplicate

    /// User has no confirmed contract in a level-1 category.
    /// DE: Lücke
    case missing

    /// A measurable value in the portfolio (e.g. TER ≥ 1.0%).
    /// DE: Kennzahl
    case comparison
}
