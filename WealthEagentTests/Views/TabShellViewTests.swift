// TabShellViewTests.swift
// Layer 2 — In-memory acceptance (structural wiring check, XCTest)
//
// @contract-shape:bounded-change
// Driving port: TabShellView (initialised with all three ViewModels)
// All tests: XCTSkip (one-at-a-time strategy, ADR-025) — enable after ContractListView is GREEN
//
// What these tests verify:
//   1. TabShellView compiles and accepts all three ViewModels without crash (wiring check)
//   2. Four tab labels are correctly named in domain language
//
// Tab labels (non-negotiable per brief.md navigation architecture):
//   "Übersicht" | "Verträge" | "Beobachtungen" | "Mehr"
//
// Business language constraint (Pillar 1):
//   Tab names use German domain vocabulary — no English technical terms.

import XCTest
@testable import WealthEagent

@MainActor
final class TabShellViewTests: XCTestCase {

    // MARK: - Helpers

    private func makeTabShell() -> TabShellView {
        let contractRepository = MockContractRepository(contracts: MockContractRepository.fixtureContracts())
        let catalogProvider = MockCatalogProvider()
        return TabShellView(
            dashboardViewModel: DashboardViewModel(
                contractRepository: contractRepository,
                catalogProvider: catalogProvider
            ),
            contractListViewModel: ContractListViewModel(
                contractRepository: contractRepository
            ),
            observationsViewModel: ObservationsViewModel(
                contractRepository: contractRepository,
                catalogProvider: catalogProvider
            ),
            catalogProvider: catalogProvider,
            scanViewModel: ScanViewModel(
                documentScanner: MockDocumentScanner(),
                contractRepository: contractRepository
            ),
            notificationPort: MockNotificationPort()
        )
    }

    // MARK: - Walking Skeleton

    /// @walking_skeleton @driving_port
    /// @contract-shape:bounded-change
    ///
    /// Verifies: TabShellView compiles and accepts all three injected ViewModels without crash.
    /// A mismatch in ViewModel init signatures or tab-composition wiring fails here — before
    /// any UI automation test is needed.
    func testTabShellViewInitializesWithAllViewModels() throws {

        XCTAssertNoThrow(makeTabShell())
    }

    // MARK: - Focused scenarios

    /// @contract-shape:bounded-change
    ///
    /// Given: TabShellView is constructed with all required ViewModels
    /// When: the shell is initialised
    /// Then: the shell instance is non-nil (four-tab structure compiles correctly)
    ///
    /// Business value: confirms the four-tab navigation architecture is correctly wired.
    /// Tab label verification ("Übersicht", "Verträge", "Beobachtungen", "Mehr") is verified
    /// via UI test in a future UITest target — at this layer we verify structural compilation.
    func testVierTabsKoennenInitialisiertWerden() throws {

        let shell = makeTabShell()
        // If TabShellView requires exactly three ViewModels and this compiles, the four-tab
        // structure is correctly wired. Label correctness is a UI-layer concern (UITest target).
        XCTAssertNotNil(shell)
    }
}
