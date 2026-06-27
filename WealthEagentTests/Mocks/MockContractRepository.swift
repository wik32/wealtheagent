// MockContractRepository.swift
// Test mock — implements ContractRepository protocol with fixture data.
//
// Fixture portfolio (criteria-research.md + brief.md):
//   • HUK-COBURG Privathaftpflicht — 7/10 criteria met
//   • AXA Privathaftpflicht — 3/10 criteria met  [→ triggers DuplicateBeobachtung]
//   • No Berufsunfähigkeit contract              [→ triggers MissingBeobachtung for BU]
//   • Depot with TER 1.45%                       [→ triggers ComparisonBeobachtung]

import Foundation
@testable import WealthEagent

// MARK: - MockContractRepository

final class MockContractRepository: ContractRepository, @unchecked Sendable {

    // MARK: - In-memory state

    private(set) var contracts: [Contract]
    private(set) var pendingContracts: [PendingContract]

    // MARK: - Error injection (for error-path tests)

    var listError: Error?
    var saveError: Error?
    var deleteError: Error?

    // MARK: - Init

    init(contracts: [Contract] = MockContractRepository.fixtureContracts(),
         pendingContracts: [PendingContract] = []) {
        self.contracts = contracts
        self.pendingContracts = pendingContracts
    }

    // MARK: - ContractRepository conformance

    func list() async throws -> [Contract] {
        if let error = listError { throw error }
        return contracts
    }

    func listPending() async throws -> [PendingContract] {
        return pendingContracts
    }

    func save(_ contract: Contract) async throws {
        if let error = saveError { throw error }
        if let index = contracts.firstIndex(where: { $0.id == contract.id }) {
            contracts[index] = contract
        } else {
            contracts.append(contract)
        }
    }

    func savePending(_ pending: PendingContract) async throws {
        if let error = saveError { throw error }
        if let index = pendingContracts.firstIndex(where: { $0.id == pending.id }) {
            pendingContracts[index] = pending
        } else {
            pendingContracts.append(pending)
        }
    }

    func confirm(_ pending: PendingContract, corrected: ContractFields?) async throws -> Contract {
        if let error = saveError { throw error }
        // Remove pending
        pendingContracts.removeAll { $0.id == pending.id }
        // Create confirmed contract — no rawOCRText
        let confirmed = Contract(
            id: pending.id,
            categoryKey: pending.categoryKey,
            provider: corrected != nil ? (pending.extractedFields.values["provider"]?.textValue ?? "Unknown") : "Unknown",
            fields: corrected ?? pending.extractedFields,
            confirmedAt: Date()
        )
        contracts.append(confirmed)
        return confirmed
    }

    func delete(id: UUID) async throws {
        if let error = deleteError { throw error }
        contracts.removeAll { $0.id == id }
    }

    func discard(id: UUID) async throws {
        pendingContracts.removeAll { $0.id == id }
    }

    // MARK: - Fixture contracts

    /// Standard fixture: 2 Privathaftpflicht (triggers DuplicateBeobachtung) + 1 Depot (triggers ComparisonBeobachtung).
    /// No Berufsunfähigkeit → triggers MissingBeobachtung.
    static func fixtureContracts() -> [Contract] {
        [
            hukPrivathaftpflicht(),
            axaPrivathaftpflicht(),
            depotWithHighTER()
        ]
    }

    /// Portfolio with only one Privathaftpflicht (no duplicate).
    static func singlePhvContracts() -> [Contract] {
        [hukPrivathaftpflicht()]
    }

    /// Empty portfolio.
    static func emptyPortfolio() -> [Contract] { [] }

    // MARK: - Individual fixture contract builders

    /// HUK-COBURG Privathaftpflicht: 7/10 criteria met.
    /// gross_negligence_waiver=true, lost_key_cover=true, tenant_damage=true,
    /// overseas_cover=true, gradual_damage=true, e_mobility=true, contingency_cover=true
    static func hukPrivathaftpflicht() -> Contract {
        Contract(
            id: UUID(uuidString: "11111111-0000-0000-0000-000000000001")!,
            categoryKey: "privathaftpflicht",
            provider: "HUK-COBURG",
            premiumAmount: 89.00,
            premiumInterval: "jaehrlich",
            criteria: [
                "min_coverage_sum": false,       // HUK standard 15 Mio. < 50 Mio.
                "gradual_damage": true,
                "gross_negligence_waiver": true,
                "lost_key_cover": true,
                "volunteer_work": false,
                "tenant_damage": true,
                "overseas_cover": true,
                "pet_sitting": false,
                "contingency_cover": true,
                "e_mobility": true
            ]
        )
    }

    /// AXA Privathaftpflicht: 3/10 criteria met.
    /// gross_negligence_waiver=false, lost_key_cover=true, tenant_damage=false
    static func axaPrivathaftpflicht() -> Contract {
        Contract(
            id: UUID(uuidString: "22222222-0000-0000-0000-000000000002")!,
            categoryKey: "privathaftpflicht",
            provider: "AXA",
            premiumAmount: 65.00,
            premiumInterval: "jaehrlich",
            criteria: [
                "min_coverage_sum": false,
                "gradual_damage": false,
                "gross_negligence_waiver": false,
                "lost_key_cover": true,
                "volunteer_work": false,
                "tenant_damage": false,
                "overseas_cover": false,
                "pet_sitting": false,
                "contingency_cover": false,
                "e_mobility": true
            ]
        )
    }

    /// Depot with TER 1.45% — triggers ComparisonBeobachtung (threshold ≥ 1.0%).
    static func depotWithHighTER() -> Contract {
        var depot = Contract(
            id: UUID(uuidString: "33333333-0000-0000-0000-000000000003")!,
            categoryKey: "depot",
            provider: "Deutsche Bank",
            premiumAmount: nil,
            premiumInterval: nil
        )
        depot.fields = ContractFields(["ter_percent": .number(1.45)])
        return depot
    }
}

// textValue/numberValue helpers are defined in PendingContractReviewViewModel.swift
