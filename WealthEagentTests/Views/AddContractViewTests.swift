// AddContractViewTests.swift
// Layer 2 — In-memory acceptance (structural wiring check, XCTest)
//
// @contract-shape:bounded-change
// Driving port: AddContractViewModel (initialised with MockContractRepository + MockCatalogProvider)
// Walking skeleton: testAddContractViewInitialisiert — verifies view + viewmodel wiring

import XCTest
@testable import WealthEagent

@MainActor
final class AddContractViewTests: XCTestCase {

    // MARK: - Walking Skeleton

    /// @walking_skeleton @driving_port
    ///
    /// Verifies: AddContractView compiles and accepts AddContractViewModel without crash.
    /// Catches init-signature mismatches and missing imports before any UI test is needed.
    func testAddContractViewInitialisiert() throws {
        let vm = AddContractViewModel(
            contractRepository: MockContractRepository(contracts: []),
            catalog: MockCatalogProvider().catalog()
        )
        XCTAssertNoThrow(AddContractView(viewModel: vm, onDismiss: {}))
    }

    /// Verifies: canSave = false on freshly created ViewModel is reflected correctly.
    func testNeuFormularZeigtSpeichernDeaktiviert() throws {
        let vm = AddContractViewModel(
            contractRepository: MockContractRepository(contracts: []),
            catalog: MockCatalogProvider().catalog()
        )
        XCTAssertFalse(vm.canSave,
                       "Neu geöffnetes Formular darf Speichern nicht aktiviert anzeigen")
    }
}
