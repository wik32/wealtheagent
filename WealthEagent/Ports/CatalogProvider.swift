// CatalogProvider.swift
// Ports — Swift protocols. Import Domain only. No framework imports.

import Foundation

// MARK: - CatalogProvider protocol

/// Driving port: provides the 22-category Catalog.
/// Synchronous — catalog.json is a bundle resource, always available.
/// Implemented by BundleCatalogProvider in production.
/// Implemented by MockCatalogProvider in tests.
protocol CatalogProvider: Sendable {
    /// Returns the decoded Catalog.
    /// Pure function after first load (result is cached in memory).
    func catalog() -> Catalog
}
