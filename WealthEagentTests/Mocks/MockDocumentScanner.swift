// MockDocumentScanner.swift
// Test mock — implements DocumentScanner protocol with configurable OCRResult fixtures.
// No Apple Vision dependency, no camera, no device required.

import Foundation
@testable import WealthEagent

// MARK: - MockDocumentScanner

final class MockDocumentScanner: DocumentScanner, @unchecked Sendable {

    // MARK: - Configurable state

    var result: OCRResult = OCRResult(rawText: "", confidence: 0.0)
    var error: Error?

    // MARK: - DocumentScanner conformance

    func scan(imageData: Data) async throws -> OCRResult {
        if let error { throw error }
        return result
    }

    // MARK: - Convenience builders

    /// Returns a fixture result with HUK-COBURG Privathaftpflicht text.
    static func hukPrivathaftpflichtFixture() -> OCRResult {
        OCRResult(
            rawText: """
            HUK-COBURG Allgemeine Versicherung AG
            Privathaftpflichtversicherung
            Vers.-Nr. PHV-12345678
            Jahresbeitrag: 89,00 EUR
            jährlich fällig am 01.01.
            Beginn: 01.01.2022
            """,
            confidence: 0.92
        )
    }

    /// Returns a fixture result with Allianz Hausratversicherung text.
    static func allianzHausratFixture() -> OCRResult {
        OCRResult(
            rawText: """
            Allianz Versicherungs-AG
            Hausratversicherung
            Versicherungsschein-Nr. HR-9876543
            Monatsbeitrag: 12,50 EUR
            monatlich
            """,
            confidence: 0.87
        )
    }

    /// Returns an empty OCR result (scanner found no text).
    static func emptyFixture() -> OCRResult {
        OCRResult(rawText: "", confidence: 0.0)
    }
}
