// DashboardView.swift
// Views — SwiftUI. Übersicht-Tab: Abdeckungsgrad, monatliche Ausgaben, Kategorien-Status.
//
// Stage-1 vocabulary constraint (CLAUDE.md):
//   - "Dein Finanzbild" — headline
//   - "Abgedeckt" / "Noch nicht erfasst" — category status labels
//   - "Empfehlung" / "empfehlen" BANNED

import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {

    @State var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.contractCount == 0 {
                    emptyStateView
                } else {
                    scrollContent
                }
            }
            .navigationTitle("Dein Finanzbild")
        }
        .task { await viewModel.load() }
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                coverageCard
                spendCard
                if !viewModel.coveredCategories.isEmpty {
                    categorySection(
                        title: "Abgedeckt",
                        categories: viewModel.coveredCategories,
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                }
                if !viewModel.missingCategories.isEmpty {
                    categorySection(
                        title: "Noch nicht erfasst",
                        categories: viewModel.missingCategories,
                        icon: "circle",
                        color: .secondary
                    )
                }
            }
            .padding()
        }
    }

    // MARK: - Coverage card

    private var coverageCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Basisabsicherung")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.coverageScore) %")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            ProgressView(value: Double(viewModel.coverageScore), total: 100)
                .tint(coverageTint)
            Text("\(viewModel.coveredCategories.count) von 11 Kategorien erfasst")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var coverageTint: Color {
        switch viewModel.coverageScore {
        case 70...: return .green
        case 40...: return .orange
        default:    return .red
        }
    }

    // MARK: - Monthly spend card

    private var spendCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Monatliche Ausgaben")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(formattedMonthlySpend)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            Spacer()
            Image(systemName: "eurosign.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.blue.opacity(0.8))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Category section

    private func categorySection(
        title: String,
        categories: [ContractCategory],
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            VStack(spacing: 0) {
                ForEach(categories) { category in
                    HStack(spacing: 10) {
                        Image(systemName: icon)
                            .foregroundStyle(color)
                            .frame(width: 20)
                        Text(category.nameDe)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    if category.id != categories.last?.id {
                        Divider().padding(.leading, 46)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Empty state

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Noch keine Verträge erfasst")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Füge deinen ersten Vertrag im Tab \"Verträge\" hinzu.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
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
