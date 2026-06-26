// InsightsEngine.swift
// Services — pure Swift function. No I/O. No mutation. Fully unit-testable.
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
        let duplicates = detectDuplicates(contracts: contracts, catalog: catalog)
        let gaps = detectGaps(contracts: contracts, catalog: catalog)
        let comparisons = detectComparisons(contracts: contracts)
        let score = computeCoverageScore(contracts: contracts, catalog: catalog)
        return FinInsights(
            beobachtungen: duplicates + gaps + comparisons,
            coverageScore: score
        )
    }

    // MARK: - Rule 1: Duplicate detection

    private static func detectDuplicates(contracts: [Contract], catalog: Catalog) -> [Insight] {
        let grouped = Dictionary(grouping: contracts, by: \.categoryKey)
        var result: [Insight] = []
        for (key, group) in grouped {
            guard group.count >= 2 else { continue }
            guard catalog.category(for: key)?.allowsDuplicateObservation == true else { continue }
            let insight = Insight(
                kind: .duplicate,
                categoryKey: key,
                titleDe: "Du hast \(group.count) \(catalog.category(for: key)?.nameDe ?? key)-Policen erfasst.",
                titleEn: "You have \(group.count) \(catalog.category(for: key)?.nameEn ?? key) contracts recorded.",
                detailDe: "In deinen Unterlagen sind \(group.count) Verträge dieser Art hinterlegt.",
                detailEn: "Your records contain \(group.count) contracts of this type."
            )
            result.append(insight)
        }
        return result
    }

    // MARK: - Rule 2: Gap detection (level-1 categories only)

    private static func detectGaps(contracts: [Contract], catalog: Catalog) -> [Insight] {
        let coveredKeys = Set(contracts.map(\.categoryKey))
        var result: [Insight] = []
        for category in catalog.level1Categories {
            guard !coveredKeys.contains(category.key) else { continue }
            let insight = Insight(
                kind: .missing,
                categoryKey: category.key,
                titleDe: "In deinen Unterlagen ist keine \(category.nameDe) vorhanden.",
                titleEn: "No \(category.nameEn) found in your records.",
                detailDe: "Diese Kategorie ist in deinem Portfolio nicht erfasst.",
                detailEn: "This category is not recorded in your portfolio."
            )
            result.append(insight)
        }
        return result
    }

    // MARK: - Rule 3: Coverage score

    private static func computeCoverageScore(contracts: [Contract], catalog: Catalog) -> Int {
        let level1Categories = catalog.level1Categories
        guard !level1Categories.isEmpty else { return 0 }
        let coveredKeys = Set(contracts.map(\.categoryKey))
        let coveredLevel1Count = level1Categories.filter { coveredKeys.contains($0.key) }.count
        return Int(Double(coveredLevel1Count) / Double(level1Categories.count) * 100.0)
    }

    // MARK: - Rule 4: Cost comparison (TER ≥ 1.0% on depot contracts)

    private static let terAlertThreshold: Double = 1.0
    private static let depotCategoryKey = "depot"
    private static let terFieldKey = "ter_percent"

    private static func detectComparisons(contracts: [Contract]) -> [Insight] {
        var result: [Insight] = []
        for contract in contracts {
            guard contract.categoryKey == depotCategoryKey else { continue }
            guard case .number(let ter) = contract.fields[terFieldKey], ter >= terAlertThreshold else { continue }
            let insight = Insight(
                kind: .comparison,
                categoryKey: contract.categoryKey,
                titleDe: "Depot-Kosten: TER \(String(format: "%.2f", ter)) %",
                titleEn: "Portfolio costs: TER \(String(format: "%.2f", ter)) %",
                detailDe: "Die laufenden Kosten dieses Depots betragen \(String(format: "%.2f", ter)) % (TER). Werte ab 1,0 % werden hier gemessen.",
                detailEn: "The ongoing costs of this portfolio are \(String(format: "%.2f", ter)) % (TER). Values of 1.0 % or above are recorded here."
            )
            result.append(insight)
        }
        return result
    }
}
