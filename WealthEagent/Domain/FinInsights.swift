// FinInsights.swift
// Domain — pure Swift value types. No framework imports beyond Foundation.
//
// Insights Context language constraint (ADR-004 + ubiquitous-language.md):
// The word "Empfehlung" (recommendation) is BANNED from this file.
// All observations are Beobachtung (factual), not Empfehlung (advice).

import Foundation

// MARK: - InsightKind

/// The category of a single factual Beobachtung.
/// Art der Beobachtung in German user-facing strings.
enum InsightKind: Equatable {
    /// User has more than one confirmed contract of the same category.
    /// Dopplung — factual, not a recommendation to cancel.
    case duplicate

    /// User has no confirmed contract in a level-1 category.
    /// Lücke — factual, not a recommendation to buy.
    case missing

    /// A measurable value in the portfolio (e.g. fund cost TER, coverage amount).
    /// Kennzahl — a measurement, not a judgement.
    case comparison
}

// MARK: - Insight (Beobachtung)

/// A single factual observation derived from the contract portfolio.
/// Beobachtung in German user-facing strings.
struct Insight: Identifiable, Equatable {
    var id: UUID
    var kind: InsightKind
    var categoryKey: String
    var titleDe: String
    var titleEn: String
    var detailDe: String
    var detailEn: String
    var articleId: String?              // links to KnowledgeArticle

    init(
        id: UUID = UUID(),
        kind: InsightKind,
        categoryKey: String,
        titleDe: String,
        titleEn: String,
        detailDe: String,
        detailEn: String,
        articleId: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.categoryKey = categoryKey
        self.titleDe = titleDe
        self.titleEn = titleEn
        self.detailDe = detailDe
        self.detailEn = detailEn
        self.articleId = articleId
    }
}

// MARK: - FinInsights (Auswertung)

/// The complete set of computed observations and measurements for a user's portfolio.
/// Produced by InsightsEngine. Auswertung in German user-facing strings.
///
/// Observation framing rules (ubiquitous-language.md):
/// - Duplicates: "Du hast [N] [Vertragsart]-Policen erfasst." (not: "Eine davon ist überflüssig.")
/// - Coverage gaps: "In deinen Unterlagen ist keine [Vertragsart] vorhanden." (not: "Du solltest...")
/// - Comparisons: factual measurements only.
struct FinInsights: Equatable {
    var beobachtungen: [Insight]        // all observations (duplicates + gaps + comparisons)
    var coverageScore: Int              // 0–100: % of level-1 categories with ≥1 contract

    init(beobachtungen: [Insight] = [], coverageScore: Int = 0) {
        self.beobachtungen = beobachtungen
        self.coverageScore = coverageScore
    }

    // MARK: - Computed views

    var duplicates: [Insight] {
        beobachtungen.filter { $0.kind == .duplicate }
    }

    var missingCategories: [Insight] {
        beobachtungen.filter { $0.kind == .missing }
    }

    var comparisons: [Insight] {
        beobachtungen.filter { $0.kind == .comparison }
    }

    var isEmpty: Bool {
        beobachtungen.isEmpty
    }
}
