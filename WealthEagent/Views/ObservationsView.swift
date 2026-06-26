// ObservationsView.swift
// Views — SwiftUI. Reads from ObservationsViewModel (@Observable). No business logic.
//
// SCAFFOLD: true
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
        fatalError("SCAFFOLD — ObservationsView body not yet implemented. Remove fatalError in DELIVER.")
        // Design spec:
        //
        // NavigationStack {
        //     if viewModel.isLoading {
        //         ProgressView()
        //     } else if viewModel.insights.isEmpty {
        //         emptyStateView   // "Keine Beobachtungen — füge Verträge hinzu"
        //     } else {
        //         List(viewModel.insights.beobachtungen) { insight in
        //             BeobachtungRow(insight: insight)
        //         }
        //     }
        // }
        // .navigationTitle("Beobachtungen")
        // .task { await viewModel.loadInsights() }
    }

    // MARK: - Subviews (declared for documentation; wired in DELIVER)

    @ViewBuilder
    private var emptyStateView: some View {
        EmptyView() // SCAFFOLD — implement in DELIVER
        // Text("Keine Beobachtungen — füge Verträge hinzu")
    }
}

// MARK: - BeobachtungRow (row scaffold)

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

    var body: some View {
        fatalError("SCAFFOLD — BeobachtungRow body not yet implemented. Remove fatalError in DELIVER.")
        // Design spec:
        // HStack {
        //     Text(kindLabel).badge-style
        //     VStack(alignment: .leading) {
        //         Text(insight.titleDe)
        //         Text(insight.detailDe).secondary
        //     }
        // }
    }
}
