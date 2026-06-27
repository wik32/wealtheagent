// OCRResult.swift
// Domain — pure Swift value types. No framework imports beyond Foundation.

import Foundation

/// Result of an on-device OCR scan.
/// Scanergebnis in German user-facing strings.
struct OCRResult: Equatable {
    /// All recognized text, lines joined with newline.
    var rawText: String
    /// Mean confidence across all VNRecognizedTextObservation candidates. 0.0–1.0.
    var confidence: Double
}
