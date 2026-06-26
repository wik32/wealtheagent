// BundleCatalogProvider.swift
// Adapters — implements CatalogProvider protocol by decoding catalog.json from app bundle.
// SCAFFOLD: true

import Foundation

// MARK: - BundleCatalogProvider

/// Implements CatalogProvider by loading catalog.json from the main app bundle.
/// Synchronous after first load (result cached in memory).
/// probe() verifies JSON is decodable and schema version matches.
final class BundleCatalogProvider: CatalogProvider {

    // MARK: - SCAFFOLD: fatalError placeholder
    // DELIVER wave: implement JSON decoding from bundle.

    func catalog() -> Catalog {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }

    /// Verifies catalog.json is present and decodable at startup.
    func probe() throws {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }
}
