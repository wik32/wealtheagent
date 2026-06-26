// ContractListView.swift
// Views — SwiftUI. Reads from ContractListViewModel (@Observable). No business logic.
//
// SCAFFOLD: true
// Stage-1 vocabulary constraint (ubiquitous-language.md + CLAUDE.md):
//   - "Noch nichts erfasst" — empty state
//   - "+" button label — navigates to add-contract sheet
//   - "Empfehlung" / "empfehlen" are BANNED from all View text

import SwiftUI

// MARK: - ContractListView

/// Verträge tab — lists confirmed contracts in the user's portfolio.
/// Each row shows: provider name, category name, monthly premium.
/// "+" toolbar button navigates to add-contract flow.
/// Receives a ContractListViewModel via dependency injection (Pillar 3).
struct ContractListView: View {

    @State var viewModel: ContractListViewModel

    // MARK: - Body

    var body: some View {
        fatalError("SCAFFOLD — ContractListView body not yet implemented. Remove fatalError in DELIVER.")
        // Design spec:
        //
        // NavigationStack {
        //     if viewModel.isLoading {
        //         ProgressView()
        //     } else if viewModel.contracts.isEmpty {
        //         emptyStateView   // "Noch nichts erfasst"
        //     } else {
        //         List(viewModel.contracts) { contract in
        //             ContractRow(contract: contract)
        //         }
        //     }
        // }
        // .navigationTitle("Verträge")
        // .toolbar { ToolbarItem(placement: .primaryAction) { addButton } }
        // .task { await viewModel.load() }
    }

    // MARK: - Subviews (declared for documentation; wired in DELIVER)

    @ViewBuilder
    private var emptyStateView: some View {
        EmptyView() // SCAFFOLD — implement in DELIVER
        // Text("Noch nichts erfasst")
    }

    @ViewBuilder
    private var addButton: some View {
        EmptyView() // SCAFFOLD — implement in DELIVER
        // Button { /* navigate to scan/add flow */ } label: { Image(systemName: "plus") }
    }
}

// MARK: - ContractRow (row scaffold)

/// Single row in the Verträge list.
/// Shows: provider name + category name + monthly premium.
struct ContractRow: View {

    let contract: Contract

    var body: some View {
        fatalError("SCAFFOLD — ContractRow body not yet implemented. Remove fatalError in DELIVER.")
        // Design spec:
        // HStack {
        //     VStack(alignment: .leading) {
        //         Text(contract.provider)
        //         Text(categoryName).secondary   // resolved from catalog
        //     }
        //     Spacer()
        //     Text(formattedPremium)             // monthly-equivalent EUR
        // }
    }
}
