// DocumentScanner.swift
// FinanzApp — Ports Layer
// SCAFFOLD: true — RED scaffold created by DISTILL wave

import Foundation

/// Driving port: extracts text from a document image using on-device OCR.
/// Contract shape: bounded-change — returns OCRResult only, never mutates store.
/// Implemented by VisionDocumentScanner in production (Apple Vision framework).
/// Implemented by MockDocumentScanner in tests.
protocol DocumentScanner {

    /// Runs on-device OCR on the provided image data.
    /// Returns an OCRResult (plan-value) — a plain struct of text blocks.
    /// Never mutates the ContractRepository directly.
    func scan(imageData: Data) async throws -> OCRResult

    /// Verifies that Apple Vision is available on this device.
    /// Creates a 1×1 test image and runs VNRecognizeTextRequest.
    func probe() async -> ProbeResult
}

/// The raw output of Apple Vision OCR.
/// A plan-value: plain struct, no I/O, passed to ContractParser.
struct OCRResult {
    var textBlocks: [TextBlock]
    var meanConfidence: Double
    var capturedAt: Date
}

/// One recognised text span from OCR.
struct TextBlock {
    var text: String
    var confidence: Double
    // Note: CGRect not used here to keep Domain layer free of CoreGraphics
    var boundingBoxX: Double?
    var boundingBoxY: Double?
    var boundingBoxWidth: Double?
    var boundingBoxHeight: Double?
}
