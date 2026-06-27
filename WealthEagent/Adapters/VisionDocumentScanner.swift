// VisionDocumentScanner.swift
// Adapters — Apple Vision implementation. Imports Ports + Vision + UIKit.
// On-device OCR, no data leaves the device (EU data residency requirement).

import Foundation
import Vision
import UIKit

// MARK: - VisionDocumentScanner

/// Production adapter: uses Apple Vision VNRecognizeTextRequest for on-device OCR.
/// Supports German (de-DE) + English (en-US) language recognition.
/// All processing happens on-device — no network calls, no cloud OCR.
final class VisionDocumentScanner: DocumentScanner {

    func scan(imageData: Data) async throws -> OCRResult {
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            throw ScanError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: ScanError.recognitionFailed(error.localizedDescription))
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let candidates = observations.compactMap { $0.topCandidates(1).first }
                let rawText = candidates.map(\.string).joined(separator: "\n")
                let meanConfidence: Double = candidates.isEmpty ? 0.0
                    : candidates.map { Double($0.confidence) }.reduce(0, +) / Double(candidates.count)

                continuation.resume(returning: OCRResult(rawText: rawText, confidence: meanConfidence))
            }

            request.recognitionLanguages = ["de-DE", "en-US"]
            request.usesLanguageCorrection = true
            request.recognitionLevel = .accurate

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: ScanError.recognitionFailed(error.localizedDescription))
            }
        }
    }
}
