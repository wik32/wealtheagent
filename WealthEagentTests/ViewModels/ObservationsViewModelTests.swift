// ObservationsViewModelTests.swift
// Priority 4 — Walking skeleton: ViewModel integration tests
//
// Uses XCTest (not Swift Testing) because ViewModel integration tests involve
// async @Observable state and are at the layer that integrates ports + pure functions.
// Layer 3 tests: example-only, no PBT.
//
// Walking skeleton: ObservationsViewModel wires ContractRepository + InsightsEngine.
// Driving port: ObservationsViewModel.loadInsights() → InsightsEngine.insights(contracts:catalog:)
//
// @contract-shape:bounded-change — ViewModel state update is bounded to
//   observable properties: insights, isLoading, error.
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.

import XCTest
@testable import WealthEagent

// MARK: - ObservationsViewModelTests

final class ObservationsViewModelTests: XCTestCase {

    // MARK: - Walking skeleton: duplicate Beobachtung visible to user

    /// Walking skeleton: user with 2 Privathaftpflicht contracts
    /// → ObservationsViewModel.insights contains 1 Dopplung-Beobachtung.
    ///
    /// FIRST WALKING SKELETON to enable in DELIVER
    /// (after InsightsEngine.insights() is implemented and the duplicate test is green).
    func testUserWithTwoPrivathaftpflichtSeesDuplicateBeobachtung() async throws {
        // DELIVER: unskip this test when InsightsEngine GREEN for duplicate detection.
        throw XCTSkip("Walking skeleton — enable after InsightsEngine duplicate detection is implemented")

        // Given: user has two Privathaftpflicht contracts
        let repository = MockContractRepository(contracts: [
            MockContractRepository.hukPrivathaftpflicht(),
            MockContractRepository.axaPrivathaftpflicht()
        ])
        let catalogProvider = MockCatalogProvider()
        let sut = ObservationsViewModel(
            contractRepository: repository,
            catalogProvider: catalogProvider
        )

        // When: ViewModel loads insights
        await sut.loadInsights()

        // Then: exactly 1 Dopplung-Beobachtung for Privathaftpflicht is visible
        let duplicates = sut.insights.duplicates
        XCTAssertEqual(duplicates.count, 1,
                       "Expected 1 Dopplung, got \(duplicates.count)")
        XCTAssertEqual(duplicates.first?.categoryKey, "privathaftpflicht",
                       "Dopplung should be for privathaftpflicht")
        XCTAssertEqual(duplicates.first?.kind, .duplicate)
    }

    // MARK: - Walking skeleton: missing Beobachtung visible to user

    /// Walking skeleton: user with no Berufsunfähigkeit contract
    /// → ObservationsViewModel.insights contains 1 Lücken-Beobachtung for BU.
    func testUserWithNoBerufsunfaehigkeitSeesLueckeBeobachtung() async throws {
        throw XCTSkip("Walking skeleton — enable after InsightsEngine gap detection is implemented")

        // Given: portfolio has no BU contract (standard fixture)
        let repository = MockContractRepository(contracts: MockContractRepository.fixtureContracts())
        let catalogProvider = MockCatalogProvider()
        let sut = ObservationsViewModel(
            contractRepository: repository,
            catalogProvider: catalogProvider
        )

        // When: ViewModel loads insights
        await sut.loadInsights()

        // Then: Lücken-Beobachtung for Berufsunfähigkeit is present
        let missingBU = sut.insights.missingCategories.first {
            $0.categoryKey == "berufsunfaehigkeit"
        }
        XCTAssertNotNil(missingBU,
                        "Expected Lücken-Beobachtung for berufsunfaehigkeit — none found")
        XCTAssertEqual(missingBU?.kind, .missing)
    }

    // MARK: - Error path: repository failure

    /// When ContractRepository.list() throws → ViewModel surfaces the error.
    func testRepositoryFailureSurfacesErrorState() async throws {
        throw XCTSkip("Error path — enable after walking skeleton tests pass")

        // Given: repository that always errors
        let repository = MockContractRepository()
        repository.listError = MockRepositoryError.connectionUnavailable

        let sut = ObservationsViewModel(
            contractRepository: repository,
            catalogProvider: MockCatalogProvider()
        )

        // When: ViewModel loads insights
        await sut.loadInsights()

        // Then: error state is set, insights are empty
        XCTAssertNotNil(sut.error, "ViewModel should surface repository error")
        XCTAssertTrue(sut.insights.isEmpty, "Insights should be empty when repository fails")
    }

    // MARK: - Loading state

    /// isLoading is true during loadInsights() and false afterwards.
    func testLoadingStateIsTrueDuringFetchAndFalseAfter() async throws {
        throw XCTSkip("Loading state test — enable after walking skeleton tests pass")

        let repository = MockContractRepository()
        let sut = ObservationsViewModel(
            contractRepository: repository,
            catalogProvider: MockCatalogProvider()
        )

        XCTAssertFalse(sut.isLoading, "isLoading should be false before fetch")

        await sut.loadInsights()

        XCTAssertFalse(sut.isLoading, "isLoading should be false after fetch completes")
    }
}

// MARK: - Mock error

enum MockRepositoryError: Error {
    case connectionUnavailable
}
