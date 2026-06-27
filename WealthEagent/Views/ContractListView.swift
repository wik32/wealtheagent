// ContractListView.swift
// Views — SwiftUI. Verträge-Tab mit Suche, Detail-Navigation, Add und Scan.
//
// Stage-1 vocabulary constraint (CLAUDE.md):
//   - "Deine Verträge" — title
//   - "Noch nichts erfasst" — empty state
//   - "Empfehlung" / "empfehlen" BANNED

import SwiftUI

// MARK: - ContractListView

struct ContractListView: View {

    @State var viewModel: ContractListViewModel
    let catalogProvider: CatalogProvider
    let scanViewModel: ScanViewModel

    @State private var showAddContract = false
    @State private var showScan = false
    @State private var pendingToReview: PendingContract?
    @State private var searchText = ""

    // MARK: - Filtered contracts

    private var filteredContracts: [Contract] {
        guard !searchText.isEmpty else { return viewModel.contracts }
        let query = searchText.lowercased()
        return viewModel.contracts.filter { contract in
            let categoryName = catalogProvider.catalog()
                .category(for: contract.categoryKey)?.nameDe ?? contract.categoryKey
            return contract.provider.lowercased().contains(query) ||
                   categoryName.lowercased().contains(query)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.contracts.isEmpty {
                    emptyStateView
                } else if filteredContracts.isEmpty {
                    noResultsView
                } else {
                    contractList
                }
            }
            .navigationTitle("Deine Verträge")
            .searchable(text: $searchText, prompt: "Anbieter oder Kategorie")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addButton
                }
                ToolbarItem(placement: .secondaryAction) {
                    scanButton
                }
            }
            .navigationDestination(for: Contract.self) { contract in
                ContractDetailView(
                    contract: contract,
                    catalog: catalogProvider.catalog(),
                    contractRepository: viewModel.contractRepository
                )
            }
            // Add-contract sheet
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
            // Review sheet after scan
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

    // MARK: - Contract list

    private var contractList: some View {
        List {
            ForEach(filteredContracts) { contract in
                NavigationLink(value: contract) {
                    ContractRow(
                        contract: contract,
                        categoryDisplayName: catalogProvider.catalog()
                            .category(for: contract.categoryKey)?.nameDe ?? contract.categoryKey
                    )
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let contract = filteredContracts[index]
                    Task { await viewModel.delete(contract: contract) }
                }
            }
        }
        .listStyle(.plain)
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
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("Kein Vertrag gefunden für \"\(searchText)\"")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var addButton: some View {
        Button { showAddContract = true } label: {
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

    private func formattedPremium(amount: Double, interval: String?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "de_DE")
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        let label: String
        switch interval {
        case "monatlich":        label = "/ Monat"
        case "vierteljaehrlich": label = "/ Quartal"
        case "halbjaehrlich":    label = "/ Halbjahr"
        case "jaehrlich":        label = "/ Jahr"
        case "einmalig":         label = "(einmalig)"
        default:                 label = ""
        }
        return label.isEmpty ? formatted : "\(formatted) \(label)"
    }
}
