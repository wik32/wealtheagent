// DashboardView.swift
// Views — SwiftUI. Reads from DashboardViewModel (@Observable). No business logic.
//
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
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.coverageScore == 0 && viewModel.monthlySpend == 0.0 {
                    emptyStateView
                } else {
                    scoreView
                }
            }
            .navigationTitle("Dein Finanzbild")
        }
        .task { await viewModel.load() }
    }

    // MARK: - Subviews

    /// Large coverage number + "% abgedeckt" label + monthly spend.
    @ViewBuilder
    private var scoreView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("\(viewModel.coverageScore)%")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                Text("abgedeckt")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Divider()
            VStack(spacing: 4) {
                Text(formattedMonthlySpend)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("monatliche Ausgaben")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Empty state when portfolio has no confirmed contracts.
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Noch keine Verträge erfasst")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Formatting

    private var formattedMonthlySpend: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: NSNumber(value: viewModel.monthlySpend)) ?? "€0,00"
    }
}
