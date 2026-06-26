// MockContractRepository.swift
// FinanzAppTests — Test Mocks
// SCAFFOLD: true — RED scaffold created by DISTILL wave
//
// Mock data mirrors the Flutter reference app (app/lib/data/contracts_repository.dart):
// 11 contracts total:
//   - 2x Privathaftpflicht: HUK-COBURG (7/8 criteria met) + AXA (3/8 criteria met)
//   - Missing: Berufsunfähigkeit
//   - 1x Depot with fund TER 1.45%
//   - 8 further contracts covering various level-1 and level-2 categories

import Foundation

/// In-memory implementation of ContractRepository for tests and SwiftUI Previews.
/// Does not use CloudKit. Deterministic. Synchronous internally.
final class MockContractRepository: ContractRepository {

    // MARK: - State

    private(set) var savedContracts: [Contract] = []
    private(set) var pendingContracts: [PendingContract] = []
    var shouldFailNextOperation: Bool = false

    // MARK: - ContractRepository

    func listContracts() async throws -> [Contract] {
        if shouldFailNextOperation { throw MockRepositoryError.simulatedFailure }
        return savedContracts
    }

    func listPendingContracts() async throws -> [PendingContract] {
        if shouldFailNextOperation { throw MockRepositoryError.simulatedFailure }
        return pendingContracts
    }

    func save(_ contract: Contract) async throws {
        if shouldFailNextOperation { throw MockRepositoryError.simulatedFailure }
        if let idx = savedContracts.firstIndex(where: { $0.id == contract.id }) {
            savedContracts[idx] = contract
        } else {
            savedContracts.append(contract)
        }
    }

    func savePending(_ pending: PendingContract) async throws {
        if shouldFailNextOperation { throw MockRepositoryError.simulatedFailure }
        pendingContracts.append(pending)
    }

    func confirm(_ pending: PendingContract, corrected: [String: String]?) async throws {
        if shouldFailNextOperation { throw MockRepositoryError.simulatedFailure }
        pendingContracts.removeAll { $0.id == pending.id }
        let confirmed = Contract(
            id: pending.id,
            categoryKey: pending.categoryKey ?? "unknown",
            provider: pending.provider ?? "unknown",
            contractNumber: pending.contractNumber,
            startDate: pending.startDate,
            premiumAmount: pending.premiumAmount,
            premiumInterval: pending.premiumInterval,
            fieldsJSON: pending.fieldsJSON ?? "{}",
            criteriaJSON: nil,
            confirmedAt: Date()
        )
        savedContracts.append(confirmed)
    }

    func discard(_ pending: PendingContract) async throws {
        pendingContracts.removeAll { $0.id == pending.id }
    }

    func delete(id: UUID) async throws {
        if shouldFailNextOperation { throw MockRepositoryError.simulatedFailure }
        savedContracts.removeAll { $0.id == id }
    }

    func deleteOrphanedPending(olderThan: Date) async throws {
        pendingContracts.removeAll { $0.extractedAt < olderThan }
    }

    func probe() async -> ProbeResult {
        return .success
    }

    // MARK: - Test Helpers

    /// Resets to empty state.
    func reset() {
        savedContracts = []
        pendingContracts = []
        shouldFailNextOperation = false
    }

    /// Loads the standard 11-contract fixture set mirroring the Flutter reference mock.
    func loadFixtures() {
        savedContracts = MockContractFixtures.all
        pendingContracts = []
    }
}

enum MockRepositoryError: Error {
    case simulatedFailure
}

// MARK: - Fixture Data

/// Mock contracts mirroring the Flutter reference app's 11-contract fixture.
enum MockContractFixtures {

    static let hukPrivathaftpflicht = Contract(
        id: UUID(uuidString: "00000000-0001-0000-0000-000000000001")!,
        categoryKey: "privathaftpflicht",
        provider: "HUK-COBURG",
        contractNumber: "PHV-12345678",
        startDate: Calendar.current.date(from: DateComponents(year: 2019, month: 3, day: 1)),
        premiumAmount: 7.50,
        premiumInterval: "monatlich",
        fieldsJSON: """
        {"coverageSum": 50000000, "insuredPersons": "familie", "forderungsausfall": true,
         "schluesselverlust": true, "ehrenamtlich": false, "gewerblich": false,
         "tierschaden": true, "ausland": true}
        """,
        criteriaJSON: """
        {"forderungsausfall": true, "schluesselverlust": true, "ehrenamtlich": false,
         "gewerblich": false, "tierschaden": true, "ausland": true,
         "selbstbehalt_null": true, "deckungssumme_50m": true}
        """,
        confirmedAt: Date()
    )

    static let axaPrivathaftpflicht = Contract(
        id: UUID(uuidString: "00000000-0001-0000-0000-000000000002")!,
        categoryKey: "privathaftpflicht",
        provider: "AXA",
        contractNumber: "AXA-PHV-98765",
        startDate: Calendar.current.date(from: DateComponents(year: 2015, month: 7, day: 1)),
        premiumAmount: 12.00,
        premiumInterval: "monatlich",
        fieldsJSON: """
        {"coverageSum": 10000000, "insuredPersons": "single", "forderungsausfall": false,
         "schluesselverlust": true, "ehrenamtlich": false, "gewerblich": false,
         "tierschaden": false, "ausland": false}
        """,
        criteriaJSON: """
        {"forderungsausfall": false, "schluesselverlust": true, "ehrenamtlich": false,
         "gewerblich": false, "tierschaden": false, "ausland": false,
         "selbstbehalt_null": false, "deckungssumme_50m": false}
        """,
        confirmedAt: Date()
    )

    static let depot = Contract(
        id: UUID(uuidString: "00000000-0002-0000-0000-000000000003")!,
        categoryKey: "depot",
        provider: "Comdirect",
        contractNumber: "12345678",
        premiumAmount: 500.00,
        premiumInterval: "monatlich",
        fieldsJSON: """
        {"broker": "Comdirect", "positions": [{"isin": "LU0274208692", "ter": 1.45, "name": "DWS Aktien Strategie Deutschland"}]}
        """,
        confirmedAt: Date()
    )

    static let krankenversicherung = Contract(
        id: UUID(uuidString: "00000000-0003-0000-0000-000000000004")!,
        categoryKey: "krankenversicherung",
        provider: "Techniker Krankenkasse",
        premiumAmount: 380.00,
        premiumInterval: "monatlich",
        fieldsJSON: "{}",
        confirmedAt: Date()
    )

    static let hausrat = Contract(
        id: UUID(uuidString: "00000000-0004-0000-0000-000000000005")!,
        categoryKey: "hausrat",
        provider: "Allianz",
        premiumAmount: 15.00,
        premiumInterval: "monatlich",
        fieldsJSON: """
        {"coverageSum": 80000, "address": "Musterstraße 1, 12345 Berlin"}
        """,
        confirmedAt: Date()
    )

    static let rechtsschutz = Contract(
        id: UUID(uuidString: "00000000-0005-0000-0000-000000000006")!,
        categoryKey: "rechtsschutz",
        provider: "ARAG",
        premiumAmount: 22.00,
        premiumInterval: "monatlich",
        fieldsJSON: "{}",
        confirmedAt: Date()
    )

    static let kfz = Contract(
        id: UUID(uuidString: "00000000-0006-0000-0000-000000000007")!,
        categoryKey: "kfz",
        provider: "ADAC Versicherung",
        premiumAmount: 55.00,
        premiumInterval: "monatlich",
        fieldsJSON: """
        {"licensePlate": "B-MU 1234", "vehicleType": "PKW"}
        """,
        confirmedAt: Date()
    )

    static let altersvorsorge = Contract(
        id: UUID(uuidString: "00000000-0007-0000-0000-000000000008")!,
        categoryKey: "altersvorsorge",
        provider: "Deutsche Rentenversicherung",
        premiumAmount: 600.00,
        premiumInterval: "monatlich",
        fieldsJSON: """
        {"expectedMonthlyPension": 1200.0}
        """,
        confirmedAt: Date()
    )

    static let sparplan = Contract(
        id: UUID(uuidString: "00000000-0008-0000-0000-000000000009")!,
        categoryKey: "sparplan",
        provider: "ING",
        premiumAmount: 150.00,
        premiumInterval: "monatlich",
        fieldsJSON: """
        {"isin": "IE00B4L5Y983", "name": "iShares Core MSCI World ETF", "ter": 0.20}
        """,
        confirmedAt: Date()
    )

    static let tagesgeld = Contract(
        id: UUID(uuidString: "00000000-0009-0000-0000-000000000010")!,
        categoryKey: "tagesgeld_festgeld",
        provider: "DKB",
        premiumAmount: 0,
        premiumInterval: "jaehrlich",
        fieldsJSON: """
        {"balance": 15000.0, "interestRate": 3.5}
        """,
        confirmedAt: Date()
    )

    static let risikoleben = Contract(
        id: UUID(uuidString: "00000000-0010-0000-0000-000000000011")!,
        categoryKey: "risikoleben",
        provider: "Hannoversche",
        premiumAmount: 18.00,
        premiumInterval: "monatlich",
        fieldsJSON: """
        {"coverageSum": 300000, "term": "2040-01-01"}
        """,
        confirmedAt: Date()
    )

    /// All 11 fixture contracts — mirrors Flutter MockContractsRepository.
    /// NOTE: Berufsunfähigkeit is intentionally ABSENT to trigger a gap observation.
    static let all: [Contract] = [
        hukPrivathaftpflicht,
        axaPrivathaftpflicht,  // triggers duplicate observation with hukPrivathaftpflicht
        depot,                  // triggers TER comparison observation (TER 1.45%)
        krankenversicherung,
        hausrat,
        rechtsschutz,
        kfz,
        altersvorsorge,
        sparplan,
        tagesgeld,
        risikoleben
    ]
}
