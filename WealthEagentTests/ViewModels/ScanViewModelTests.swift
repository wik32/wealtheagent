// ScanViewModelTests.swift
// Layer 2 — In-memory acceptance (XCTest @MainActor)
//
// Driving port: ScanViewModel.scan(imageData:)
// Dependencies: MockDocumentScanner, MockContractRepository
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.

import XCTest
@testable import WealthEagent

@MainActor
final class ScanViewModelTests: XCTestCase {

    // MARK: - setUp / tearDown

    private var mockScanner: MockDocumentScanner!
    private var mockRepo: MockContractRepository!

    override func setUp() async throws {
        mockScanner = MockDocumentScanner()
        mockRepo = MockContractRepository(contracts: [])
    }

    override func tearDown() async throws {
        mockScanner = nil
        mockRepo = nil
    }

    // MARK: — Walking skeleton

    /// ScanViewModel initializes without crash.
    func testScanViewModelInitialisiert() {
        let sut = ScanViewModel(documentScanner: mockScanner, contractRepository: mockRepo)
        XCTAssertFalse(sut.isScanning)
        XCTAssertNil(sut.scannedPending)
        XCTAssertNil(sut.error)
    }

    // MARK: — Scan erfolgreich

    /// Successful scan with HUK text → PendingContract is saved in repository.
    func testScanErfolgreichLegtEntwurfAn() async throws {
        mockScanner.result = MockDocumentScanner.hukPrivathaftpflichtFixture()
        let sut = ScanViewModel(documentScanner: mockScanner, contractRepository: mockRepo)

        await sut.scan(imageData: Data())

        let pending = try await mockRepo.listPending()
        XCTAssertEqual(pending.count, 1, "Scan muss einen Entwurf im Repository anlegen")
        XCTAssertFalse(sut.isScanning, "isScanning muss nach Abschluss false sein")
        XCTAssertNotNil(sut.scannedPending, "scannedPending muss nach Erfolg gesetzt sein")
    }

    /// After successful scan, scannedPending has the correct categoryHint.
    func testScanErgebnisHatKategorieHinweis() async throws {
        mockScanner.result = MockDocumentScanner.hukPrivathaftpflichtFixture()
        let sut = ScanViewModel(documentScanner: mockScanner, contractRepository: mockRepo)

        await sut.scan(imageData: Data())

        XCTAssertEqual(sut.scannedPending?.categoryKey, "privathaftpflicht",
                       "Erkannte Privathaftpflicht muss als Kategorie-Hinweis gespeichert werden")
    }

    /// Scan with empty OCR result → PendingContract with empty categoryKey is created.
    func testScanMitLeeremTextLegtEntwurfMitLeererKategorieAn() async throws {
        mockScanner.result = MockDocumentScanner.emptyFixture()
        let sut = ScanViewModel(documentScanner: mockScanner, contractRepository: mockRepo)

        await sut.scan(imageData: Data())

        let pending = try await mockRepo.listPending()
        XCTAssertEqual(pending.count, 1, "Auch leerer OCR-Text muss einen Entwurf anlegen")
        XCTAssertTrue(pending.first?.categoryKey.isEmpty == true,
                      "Leerer Text darf keinen Kategorie-Hinweis produzieren")
    }

    // MARK: — Scan fehlgeschlagen

    /// Scanner error → error state surfaced, no PendingContract created.
    func testScanFehlerZeigtFehlerstatus() async throws {
        mockScanner.error = ScanError.invalidImage
        let sut = ScanViewModel(documentScanner: mockScanner, contractRepository: mockRepo)

        await sut.scan(imageData: Data())

        XCTAssertNotNil(sut.error, "Scanner-Fehler muss in der ViewModel-Fehleranzeige erscheinen")
        XCTAssertNil(sut.scannedPending, "Bei Fehler darf kein Entwurf erstellt werden")
        let pending = try await mockRepo.listPending()
        XCTAssertTrue(pending.isEmpty, "Bei Fehler darf kein Entwurf im Repository erscheinen")
    }

    // MARK: — Reset

    /// reset() clears scannedPending and error state.
    func testResetBereingtZustand() async throws {
        mockScanner.result = MockDocumentScanner.hukPrivathaftpflichtFixture()
        let sut = ScanViewModel(documentScanner: mockScanner, contractRepository: mockRepo)
        await sut.scan(imageData: Data())
        XCTAssertNotNil(sut.scannedPending, "Voraussetzung: Entwurf gesetzt")

        sut.reset()

        XCTAssertNil(sut.scannedPending, "Nach Reset muss scannedPending nil sein")
        XCTAssertNil(sut.error, "Nach Reset muss error nil sein")
    }
}
