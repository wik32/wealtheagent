// ObservationsView.swift
// Views — SwiftUI. Reads from ObservationsViewModel (@Observable). No business logic.
//
// Stage-1 vocabulary constraint (CLAUDE.md):
//   - "Beobachtungen" — headline (NOT "Empfehlungen")
//   - "Dopplung" → Tap → CompareView
//   - "Lücke" → Tap → AddContractView (Kategorie vorausgewählt)
//   - "Empfehlung" / "empfehlen" BANNED

import SwiftUI

// MARK: - ObservationsView

struct ObservationsView: View {

    @State var viewModel: ObservationsViewModel
    @State private var comparingInsight: Insight?
    @State private var showAddForMissing = false
    @State private var missingCategoryKey = ""
    @State private var detailInsight: Insight?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.insights.isEmpty {
                    emptyStateView
                } else {
                    insightsList
                }
            }
            .navigationTitle("Beobachtungen")
            .sheet(item: $comparingInsight) { insight in
                compareSheet(for: insight)
            }
            .sheet(item: $detailInsight) { insight in
                InsightDetailView(insight: insight, onDismiss: { detailInsight = nil })
            }
            .sheet(isPresented: $showAddForMissing, onDismiss: {
                Task { await viewModel.loadInsights() }
            }) {
                AddContractView(
                    viewModel: AddContractViewModel(
                        contractRepository: viewModel.contractRepository,
                        catalog: viewModel.catalog,
                        preselectedCategoryKey: missingCategoryKey
                    ),
                    onDismiss: { showAddForMissing = false }
                )
            }
        }
        .task { await viewModel.loadInsights() }
    }

    // MARK: - Insights list

    @ViewBuilder
    private var insightsList: some View {
        List(viewModel.insights.beobachtungen) { insight in
            switch insight.kind {
            case .duplicate:
                Button {
                    comparingInsight = insight
                } label: {
                    BeobachtungRow(insight: insight, isInteractive: true)
                }
                .buttonStyle(.plain)

            case .missing:
                Button {
                    missingCategoryKey = insight.categoryKey
                    showAddForMissing = true
                } label: {
                    BeobachtungRow(insight: insight, isInteractive: true)
                }
                .buttonStyle(.plain)

            case .comparison:
                Button {
                    detailInsight = insight
                } label: {
                    BeobachtungRow(insight: insight, isInteractive: true)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Compare sheet

    @ViewBuilder
    private func compareSheet(for insight: Insight) -> some View {
        let contracts = viewModel.contracts.filter { $0.categoryKey == insight.categoryKey }
        let compareVM = CompareViewModel(
            categoryKey: insight.categoryKey,
            contracts: contracts,
            catalog: viewModel.catalog
        )
        NavigationStack {
            CompareView(viewModel: compareVM)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fertig") { comparingInsight = nil }
                    }
                }
        }
    }

    // MARK: - Empty state

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "eye.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Keine Beobachtungen — füge Verträge hinzu")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - BeobachtungRow

struct BeobachtungRow: View {

    let insight: Insight
    let isInteractive: Bool

    private var kindLabel: String {
        switch insight.kind {
        case .duplicate:  return "Dopplung"
        case .missing:    return "Lücke"
        case .comparison: return "Vergleich"
        }
    }

    private var kindColor: Color {
        switch insight.kind {
        case .duplicate:  return .orange
        case .missing:    return .gray
        case .comparison: return .blue
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(kindLabel)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(kindColor.opacity(0.15))
                .foregroundStyle(kindColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.titleDe)
                    .font(.body)
                    .fontWeight(.medium)
                Text(insight.detailDe)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isInteractive {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
