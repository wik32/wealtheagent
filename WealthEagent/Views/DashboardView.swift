// DashboardView.swift
// Views — SwiftUI. Reads from DashboardViewModel (@Observable). No business logic.
//
// SCAFFOLD: true
// Stage-1 vocabulary constraint (ubiquitous-language.md + CLAUDE.md):
//   - "Dein Finanzbild" — headline
//   - "% abgedeckt" — coverage label (NOT "Empfehlung")
//   - "Noch keine Verträge erfasst" — empty state
//   - "Beobachtungen", "Fakten", "Dopplung", "Lücke" are allowed
//   - "Empfehlung" / "empfehlen" are BANNED from all View text

import SwiftUI

// MARK: - DashboardView

/// Übersicht tab — shows Abdeckungsgrad and monatliche Ausgaben.
/// Receives a DashboardViewModel via dependency injection (Pillar 3: app as in production).
struct DashboardView: View {

    @State var viewModel: DashboardViewModel

    // MARK: - Body

    var body: some View {
        fatalError("SCAFFOLD — DashboardView body not yet implemented. Remove fatalError in DELIVER.")
        // Design spec (acceptance tests verify ViewModel-level, not rendering):
        //
        // NavigationStack {
        //     if viewModel.isLoading {
        //         ProgressView()
        //     } else if /* no contracts */ {
        //         emptyStateView
        //     } else {
        //         scoreView
        //     }
        // }
        // .navigationTitle("Dein Finanzbild")
        // .task { await viewModel.load() }
    }

    // MARK: - Subviews (declared for documentation; wired in DELIVER)

    /// Large coverage number + "% abgedeckt" label.
    @ViewBuilder
    private var scoreView: some View {
        EmptyView() // SCAFFOLD — implement in DELIVER
    }

    /// Empty state when portfolio has no confirmed contracts.
    @ViewBuilder
    private var emptyStateView: some View {
        EmptyView() // SCAFFOLD — implement in DELIVER
    }
}
