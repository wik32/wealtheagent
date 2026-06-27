// BundleCatalogProvider.swift
// Adapters — implements CatalogProvider by decoding catalog.json from the app bundle.

import Foundation

// MARK: - BundleCatalogProvider

/// Decodes Catalog from `catalog.json` bundled with the app.
/// Synchronous: JSON is parsed once and cached in memory.
/// Crashes at startup (fatalError) if the file is missing or malformed — intentional:
/// a broken catalog is an unrecoverable developer error, not a runtime condition.
final class BundleCatalogProvider: CatalogProvider {

    private let cached: Catalog

    init() {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json") else {
            fatalError("catalog.json missing from app bundle — add it to WealthEagent/Resources/")
        }
        do {
            let data = try Data(contentsOf: url)
            cached = try JSONDecoder().decode(Catalog.self, from: data)
        } catch {
            fatalError("catalog.json decode failed: \(error)")
        }
    }

    func catalog() -> Catalog { cached }

    // MARK: - Test / Preview support

    /// Decodes catalog from an explicit JSON file path (for integration tests and Previews).
    static func from(url: URL) throws -> Catalog {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Catalog.self, from: data)
    }
}
