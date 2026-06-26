// MockDocumentScanner.swift
// FinanzAppTests — Test Mocks
// SCAFFOLD: true — RED scaffold created by DISTILL wave

import Foundation

/// In-memory implementation of DocumentScanner for tests.
/// Returns configurable OCRResult fixtures. No Apple Vision dependency.
final class MockDocumentScanner: DocumentScanner {

    // MARK: - State

    var nextResult: OCRResult = MockOCRFixtures.privathaftpflichtDocument
    var shouldFail: Bool = false

    // MARK: - DocumentScanner

    func scan(imageData: Data) async throws -> OCRResult {
        if shouldFail {
            throw MockScannerError.simulatedOCRFailure
        }
        return nextResult
    }

    func probe() async -> ProbeResult {
        return .success
    }
}

enum MockScannerError: Error {
    case simulatedOCRFailure
}

// MARK: - OCR Fixture Data

enum MockOCRFixtures {

    /// Simulates OCR output from a Privathaftpflicht policy document.
    static let privathaftpflichtDocument = OCRResult(
        textBlocks: [
            TextBlock(text: "Privathaftpflichtversicherung", confidence: 0.98, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "HUK-COBURG", confidence: 0.97, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "Versicherungsschein Nr.: PHV-12345678", confidence: 0.95, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "Versicherungsbeginn: 01.03.2019", confidence: 0.94, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "Beitrag: 7,50 € monatlich", confidence: 0.93, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "Deckungssumme: 50.000.000 €", confidence: 0.96, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil)
        ],
        meanConfidence: 0.955,
        capturedAt: Date()
    )

    /// Simulates OCR output from a Depot statement.
    static let depotStatement = OCRResult(
        textBlocks: [
            TextBlock(text: "Wertpapierdepot", confidence: 0.97, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "Comdirect", confidence: 0.98, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "Depot-Nr.: 12345678", confidence: 0.95, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "DWS Aktien Strategie Deutschland", confidence: 0.92, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "ISIN: LU0274208692", confidence: 0.95, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "Laufende Kosten (TER): 1,45% p.a.", confidence: 0.91, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil)
        ],
        meanConfidence: 0.947,
        capturedAt: Date()
    )

    /// Simulates low-confidence OCR output (poorly photographed document).
    static let lowConfidenceDocument = OCRResult(
        textBlocks: [
            TextBlock(text: "V rsi h ungssc ein", confidence: 0.35, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil),
            TextBlock(text: "??..##", confidence: 0.12, boundingBoxX: nil, boundingBoxY: nil, boundingBoxWidth: nil, boundingBoxHeight: nil)
        ],
        meanConfidence: 0.235,
        capturedAt: Date()
    )

    /// Empty result — blank image or complete OCR failure.
    static let emptyDocument = OCRResult(
        textBlocks: [],
        meanConfidence: 0.0,
        capturedAt: Date()
    )
}
