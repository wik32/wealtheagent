// ObservationsView.swift
// Views — SwiftUI. Reads from ObservationsViewModel (@Observable). No business logic.
//
// Stage-1 vocabulary constraint (ubiquitous-language.md + CLAUDE.md):
//   - "Beobachtungen" — headline and list title (NOT "Empfehlungen")
//   - "Dopplung" / "Lücke" / "Vergleich" — kind badge labels
//   - "Keine Beobachtungen — füge Verträge hinzu" — empty state
//   - Tapping a "Dopplung" row opens CompareView (factual comparison, NO Empfehlung)
//   - "Empfehlung" / "empfehlen" are BANNED from all View text

import SwiftUI

// MARK: - ObservationsView

/// Beobachtungen tab — lists factual observations derived from the contract portfolio.
/// Duplicate insights are tappable and open a side-by-side CompareView.
struct ObservationsView: View {

    @State var viewModel: ObservationsViewModel
    @State private var comparingInsight: Insight?

    // MARK: - Body

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
        }
        .task { await viewModel.loadInsights() }
    }

    // MARK: - Insights list

    @ViewBuilder
    private var insightsList: some View {
        List(viewModel.insights.beobachtungen) { insight in
            if insight.kind == .duplicate {
                Button {
                    comparingInsight = insight
                } label: {
                    BeobachtungRow(insight: insight, isInteractive: true)
                }
                .buttonStyle(.plain)
            } else {
                BeobachtungRow(insight: insight, isInteractive: false)
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

/// Single row in the Beobachtungen list.
/// Shows: kind badge (Dopplung/Lücke/Vergleich) + title + detail.
/// Interactive duplicate rows show a chevron to signal tappability.
struct BeobachtungRow: View {

    let insight: Insight
    let isInteractive: Bool

    // MARK: - Kind badge label mapping (domain language — no technical terms)

    private var kindLabel: String {
        switch insight.kind {
        case .duplicate:   return "Dopplung"
        case .missing:     return "Lücke"
        case .comparison:  return "Vergleich"
        }
    }

    private var kindColor: Color {
        switch insight.kind {
        case .duplicate:   return .orange
        case .missing:     return .gray
        case .comparison:  return .blue
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
