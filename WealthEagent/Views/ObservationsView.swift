// ObservationsView.swift
// Views — SwiftUI. Reads from ObservationsViewModel (@Observable). No business logic.
//
// Stage-1 vocabulary constraint (ubiquitous-language.md + CLAUDE.md):
//   - "Beobachtungen" — headline and list title (NOT "Empfehlungen")
//   - "Dopplung" / "Lücke" / "Vergleich" — kind badge labels
//   - "Keine Beobachtungen — füge Verträge hinzu" — empty state
//   - "Empfehlung" / "empfehlen" are BANNED from all View text

import SwiftUI

// MARK: - ObservationsView

/// Beobachtungen tab — lists factual observations derived from the contract portfolio.
/// Each row shows kind badge (Dopplung/Lücke/Vergleich), title, and detail.
/// Receives an ObservationsViewModel via dependency injection (Pillar 3).
struct ObservationsView: View {

    @State var viewModel: ObservationsViewModel

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.insights.isEmpty {
                    emptyStateView
                } else {
                    List(viewModel.insights.beobachtungen) { insight in
                        BeobachtungRow(insight: insight)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Beobachtungen")
        }
        .task { await viewModel.loadInsights() }
    }

    // MARK: - Subviews

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
struct BeobachtungRow: View {

    let insight: Insight

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
        }
        .padding(.vertical, 4)
    }
}
