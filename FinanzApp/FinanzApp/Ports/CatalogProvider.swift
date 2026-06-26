// CatalogProvider.swift
// FinanzApp — Ports Layer
// SCAFFOLD: true — RED scaffold created by DISTILL wave

import Foundation

/// Driving port: provides the catalog of contract categories.
/// Synchronous — the catalog is loaded from the app bundle (offline-capable).
/// Implemented by BundleCatalogProvider in production.
/// Implemented by MockCatalogProvider in tests.
protocol CatalogProvider {

    /// Returns the complete catalog.
    /// Synchronous: catalog.json is bundled and cached after first decode.
    func catalog() -> Catalog

    /// Returns the evaluation criteria for a given category key.
    /// Convenience method over catalog().criteria(for:).
    func criteriaFor(_ categoryKey: String) -> [ContractCriterion]

    /// Verifies that catalog.json is decodable and schema version matches.
    /// Called at app startup.
    func probe() -> ProbeResult
}
