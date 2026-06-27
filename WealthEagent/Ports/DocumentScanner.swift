// DocumentScanner.swift
// Ports — Swift protocols. Import Domain + Foundation only. No Apple-framework imports.

import Foundation

// MARK: - DocumentScanner protocol

/// Driving port: on-device document scanning and OCR text extraction.
/// Implemented by VisionDocumentScanner (Apple Vision) in production.
/// Implemented by MockDocumentScanner in tests.
///
/// Uses Data (not UIImage) to keep this port free of UIKit imports (layer boundary).
/// Adapters convert Data → UIImage internally.
protocol DocumentScanner: Sendable {
    /// Extracts all recognizable text from the image data.
    /// - Parameter imageData: JPEG or PNG image bytes from the user's camera or photo library.
    /// - Returns: OCRResult with rawText and mean confidence.
    /// - Throws: ScanError if the image cannot be processed.
    func scan(imageData: Data) async throws -> OCRResult
}

// MARK: - ScanError

enum ScanError: Error, LocalizedError {
    case invalidImage
    case recognitionFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Das Bild konnte nicht verarbeitet werden."
        case .recognitionFailed(let reason):
            return "Texterkennung fehlgeschlagen: \(reason)"
        }
    }
}
