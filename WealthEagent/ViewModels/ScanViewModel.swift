// ScanViewModel.swift
// ViewModels — @Observable. Imports Ports + Domain + Foundation only.
//
// Supports single-page scan and multi-page accumulation.
// Multi-page: addPage(imageData:) → repeatable → finalizeMultiPage() → PendingContract

import Foundation
import Observation

@Observable
@MainActor
final class ScanViewModel {

    // MARK: - Observable state

    private(set) var isScanning: Bool = false
    var scannedPending: PendingContract?
    private(set) var error: Error?

    /// Accumulated OCR page results for multi-page mode.
    private(set) var pageTexts: [String] = []

    var pageCount: Int { pageTexts.count }
    var hasPages: Bool { !pageTexts.isEmpty }

    // MARK: - Dependencies

    private let documentScanner: DocumentScanner
    private let contractRepository: ContractRepository

    // MARK: - Init

    init(documentScanner: DocumentScanner, contractRepository: ContractRepository) {
        self.documentScanner = documentScanner
        self.contractRepository = contractRepository
    }

    // MARK: - Single-page scan (convenience — scan + save in one step)

    func scan(imageData: Data) async {
        isScanning = true
        error = nil
        scannedPending = nil
        pageTexts = []

        do {
            let ocrResult = try await documentScanner.scan(imageData: imageData)
            let pending = buildPending(from: ocrResult)
            try await contractRepository.savePending(pending)
            scannedPending = pending
        } catch {
            self.error = error
        }

        isScanning = false
    }

    // MARK: - Multi-page scan

    /// Scans one page and appends its text to the accumulator. Does NOT save yet.
    func addPage(imageData: Data) async {
        isScanning = true
        error = nil

        do {
            let ocrResult = try await documentScanner.scan(imageData: imageData)
            pageTexts.append(ocrResult.rawText)
        } catch {
            self.error = error
        }

        isScanning = false
    }

    /// Combines all accumulated page texts, parses them as one document, saves PendingContract.
    func finalizeMultiPage() async {
        guard !pageTexts.isEmpty else { return }
        isScanning = true
        error = nil

        let combinedText = pageTexts.joined(separator: "\n\n--- Seite \(pageTexts.count) ---\n\n")
        let ocrResult = OCRResult(rawText: combinedText, confidence: 0.85)

        do {
            let pending = buildPending(from: ocrResult)
            try await contractRepository.savePending(pending)
            scannedPending = pending
        } catch {
            self.error = error
        }

        isScanning = false
    }

    // MARK: - Reset

    func reset() {
        scannedPending = nil
        error = nil
        isScanning = false
        pageTexts = []
    }

    // MARK: - Private

    private func buildPending(from ocrResult: OCRResult) -> PendingContract {
        let parsed = ContractParser.parse(text: ocrResult.rawText)
        return PendingContract(
            categoryKey: parsed.categoryHint ?? "",
            rawOCRText: ocrResult.rawText,
            ocrConfidence: ocrResult.confidence,
            extractedFields: parsed.extractedFields,
            fieldConfidences: parsed.fieldConfidences
        )
    }
}
