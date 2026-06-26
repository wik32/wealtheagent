// InsightsEngine.swift
// Services — pure Swift function. No I/O. No mutation. Fully unit-testable.
// SCAFFOLD: true
//
// Insights Context language constraint (ADR-004):
// Output is always Beobachtung (observation). NEVER Empfehlung (recommendation).
// The word "Empfehlung" must not appear in user-facing strings produced here.

import Foundation

// MARK: - InsightsEngine

/// Pure function: derives FinInsights from [Contract] + Catalog.
/// No storage. No mutation. No async. Deterministic.
///
/// Driving port: called by ObservationsViewModel to populate the Beobachtungen tab.
enum InsightsEngine {

    // MARK: - SCAFFOLD: fatalError placeholder
    // DELIVER wave: replace fatalError with real implementation.

    /// Computes factual Beobachtungen from a confirmed contract portfolio.
    ///
    /// Rules:
    /// 1. Duplicate detection: ≥2 contracts with same categoryKey
    ///    → InsightKind.duplicate (only for allowsDuplicateObservation categories)
    /// 2. Gap detection: level-1 category with 0 contracts
    ///    → InsightKind.missing
    /// 3. Coverage score: count(level-1 categories with ≥1 contract) / count(all level-1 categories) × 100
    /// 4. Cost comparison: TER ≥ 1.0% on a depot/investment contract
    ///    → InsightKind.comparison
    ///
    /// - Parameters:
    ///   - contracts: Confirmed contracts only. PendingContract is excluded by type.
    ///   - catalog: The 22-category catalog (from BundleCatalogProvider or MockCatalogProvider).
    /// - Returns: FinInsights with all Beobachtungen and the CoverageScore.
    static func insights(contracts: [Contract], catalog: Catalog) -> FinInsights {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }
}
