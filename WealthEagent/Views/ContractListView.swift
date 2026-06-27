// ContractListView.swift
// Views — SwiftUI. Reads from ContractListViewModel (@Observable). No business logic.
//
// Stage-1 vocabulary constraint (ubiquitous-language.md + CLAUDE.md):
//   - "Noch nichts erfasst" — empty state
//   - "+" button — opens AddContractView sheet
//   - Camera button — opens ScanView sheet
//   - "Empfehlung" / "empfehlen" are BANNED from all View text

import SwiftUI

// MARK: - ContractListView

/// Verträge tab — lists confirmed contracts in the user's portfolio.
/// Each row shows: provider name, category name, monthly premium.
/// Toolbar: "+" (manual entry) + camera (OCR scan).
struct ContractListView: View {

    @State var viewModel: ContractListViewModel
    let catalogProvider: CatalogProvider
    let scanViewModel: ScanViewModel

    @State private var showAddContract = false
    @State private var showScan = false
    @State private var pendingToReview: PendingContract?
    @State private var editingContract: Contract?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.contracts.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(viewModel.contracts) { contract in
                            ContractRow(
                                contract: contract,
                                categoryDisplayName: catalogProvider.catalog()
                                    .category(for: contract.categoryKey)?.nameDe
                                    ?? contract.categoryKey
                            )
                                .contentShape(Rectangle())
                                .onTapGesture { editingContract = contract }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let contract = viewModel.contracts[index]
                                Task { await viewModel.delete(contract: contract) }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Deine Verträge")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addButton
                }
                ToolbarItem(placement: .secondaryAction) {
                    scanButton
                }
            }
            // Add-contract sheet (manual entry)
            .sheet(isPresented: $showAddContract, onDismiss: {
                Task { await viewModel.load() }
            }) {
                AddContractView(
                    viewModel: AddContractViewModel(
                        contractRepository: viewModel.contractRepository,
                        catalog: catalogProvider.catalog()
                    ),
                    onDismiss: { showAddContract = false }
                )
            }
            // OCR scan sheet
            .sheet(isPresented: $showScan, onDismiss: {
                if let pending = scanViewModel.scannedPending {
                    pendingToReview = pending
                }
                Task { await viewModel.load() }
            }) {
                ScanView(viewModel: scanViewModel, onDismiss: { showScan = false })
            }
            // Edit-contract sheet (tap on existing contract row)
            .sheet(item: $editingContract, onDismiss: {
                Task { await viewModel.load() }
            }) { contract in
                EditContractView(
                    viewModel: EditContractViewModel(
                        contract: contract,
                        contractRepository: viewModel.contractRepository,
                        catalog: catalogProvider.catalog()
                    ),
                    onDismiss: { editingContract = nil }
                )
            }
            // Review sheet (shown after successful scan)
            .sheet(item: $pendingToReview, onDismiss: {
                scanViewModel.reset()
                Task { await viewModel.load() }
            }) { pending in
                PendingContractReviewView(
                    viewModel: PendingContractReviewViewModel(
                        pending: pending,
                        contractRepository: viewModel.contractRepository,
                        catalog: catalogProvider.catalog()
                    ),
                    onDismiss: { pendingToReview = nil }
                )
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
            showAddContract = true
        } label: {
            Image(systemName: "plus")
        }
    }

    @ViewBuilder
    private var scanButton: some View {
        Button {
            scanViewModel.reset()
            showScan = true
        } label: {
            Image(systemName: "camera.viewfinder")
        }
    }
}

// MARK: - ContractRow

/// Single row in the Verträge list.
/// Shows: provider name + category key + monthly premium (if available).
struct ContractRow: View {

    let contract: Contract
    let categoryDisplayName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(contract.provider)
                    .font(.body)
                    .fontWeight(.medium)
                Text(categoryDisplayName)
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
