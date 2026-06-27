// ScanViewModel.swift
// ViewModels — @Observable. Imports Ports + Domain + Foundation only.
//
// Driving port: scan(imageData:) → OCR → ContractParser → PendingContract in repository.
//
// Universe (observable properties for tests):
//   - isScanning: Bool
//   - scannedPending: PendingContract?
//   - error: Error?

import Foundation
import Observation

@Observable
@MainActor
final class ScanViewModel {

    // MARK: - Observable state

    private(set) var isScanning: Bool = false
    var scannedPending: PendingContract?
    private(set) var error: Error?

    // MARK: - Dependencies

    private let documentScanner: DocumentScanner
    private let contractRepository: ContractRepository

    // MARK: - Init

    init(documentScanner: DocumentScanner, contractRepository: ContractRepository) {
        self.documentScanner = documentScanner
        self.contractRepository = contractRepository
    }

    // MARK: - Commands

    /// Runs OCR on the given image data, parses the result, and saves a PendingContract.
    /// After success, `scannedPending` holds the new pending record for user review.
    func scan(imageData: Data) async {
        isScanning = true
        error = nil
        scannedPending = nil

        do {
            let ocrResult = try await documentScanner.scan(imageData: imageData)
            let parsed = ContractParser.parse(text: ocrResult.rawText)

            let pending = PendingContract(
                categoryKey: parsed.categoryHint ?? "",
                rawOCRText: ocrResult.rawText,
                ocrConfidence: ocrResult.confidence,
                extractedFields: parsed.extractedFields,
                fieldConfidences: parsed.fieldConfidences
            )

            try await contractRepository.savePending(pending)
            scannedPending = pending
        } catch {
            self.error = error
        }

        isScanning = false
    }

    /// Resets state for a new scan attempt.
    func reset() {
        scannedPending = nil
        error = nil
        isScanning = false
    }
}
