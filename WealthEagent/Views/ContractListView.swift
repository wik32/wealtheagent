// ContractListView.swift
// Views — SwiftUI. Reads from ContractListViewModel (@Observable). No business logic.
//
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
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.contracts.isEmpty {
                    emptyStateView
                } else {
                    List(viewModel.contracts) { contract in
                        ContractRow(contract: contract)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Deine Verträge")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addButton
                }
            }
        }
        .task { await viewModel.load() }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Noch nichts erfasst")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var addButton: some View {
        Button {
            // Add-contract flow — Stage 2 scope
        } label: {
            Image(systemName: "plus")
        }
    }
}

// MARK: - ContractRow

/// Single row in the Verträge list.
/// Shows: provider name + category key + monthly premium (if available).
struct ContractRow: View {

    let contract: Contract

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(contract.provider)
                    .font(.body)
                    .fontWeight(.medium)
                Text(contract.categoryKey)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let amount = contract.premiumAmount {
                Text(formattedPremium(amount: amount, interval: contract.premiumInterval))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Formatting

    private func formattedPremium(amount: Double, interval: String?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "de_DE")
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        let intervalLabel: String
        switch interval {
        case "monatlich":        intervalLabel = "/ Monat"
        case "vierteljaehrlich": intervalLabel = "/ Quartal"
        case "halbjaehrlich":    intervalLabel = "/ Halbjahr"
        case "jaehrlich":        intervalLabel = "/ Jahr"
        case "einmalig":         intervalLabel = "(einmalig)"
        default:                 intervalLabel = ""
        }
        return intervalLabel.isEmpty ? formatted : "\(formatted) \(intervalLabel)"
    }
}
