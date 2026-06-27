// CompareView.swift
// Views — SwiftUI. Side-by-side Leistungskriterien comparison for duplicate contracts.
//
// Stage-1 vocabulary constraint (CLAUDE.md):
//   - "Vergleich" — sheet title
//   - "Kriterien erfüllt" — score label
//   - "Beitrag" — premium row label
//   - "Empfehlung" / "empfehlen" are BANNED

import SwiftUI

// MARK: - CompareView

/// Shows two or more contracts of the same category side-by-side with a
/// criterion-by-criterion comparison matrix.
/// Factual only — no ranking, no "bessere" Wahl, no Empfehlung.
struct CompareView: View {

    let viewModel: CompareViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                contractHeaderRow
                Divider()
                    .padding(.horizontal)
                criterionGrid
                premiumFooterRow
            }
        }
        .navigationTitle(viewModel.categoryName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Contract header row

    private var contractHeaderRow: some View {
        HStack(alignment: .top, spacing: 0) {
            // Spacer for the criterion label column
            Text("Kriterium")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)

            ForEach(viewModel.summaries) { summary in
                VStack(alignment: .center, spacing: 2) {
                    Text(summary.contract.provider)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    Text(summary.scoreText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(Color(.secondarySystemGroupedBackground))
    }

    // MARK: - Criterion comparison grid

    private var criterionGrid: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.criterionRows) { row in
                HStack(alignment: .center, spacing: 0) {
                    Text(row.criterion.labelDe)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)

                    ForEach(viewModel.contracts) { contract in
                        CriterionCell(met: row.results[contract.id] ?? nil)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 10)
                .background(Color(.systemGroupedBackground))
                Divider()
                    .padding(.leading, 16)
            }
        }
    }

    // MARK: - Premium footer row

    private var premiumFooterRow: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("Beitrag")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)

            ForEach(viewModel.summaries) { summary in
                Text(formattedPremium(summary.contract))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
    }

    // MARK: - Helpers

    private func formattedPremium(_ contract: Contract) -> String {
        guard let amount = contract.premiumAmount else { return "–" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "de_DE")
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        switch contract.premiumInterval {
        case "monatlich":        return "\(formatted) / Monat"
        case "vierteljaehrlich": return "\(formatted) / Quartal"
        case "halbjaehrlich":    return "\(formatted) / Halbjahr"
        case "jaehrlich":        return "\(formatted) / Jahr"
        case "einmalig":         return "\(formatted) einmalig"
        default:                 return formatted
        }
    }
}

// MARK: - CriterionCell

/// Visual indicator for a single criterion result.
private struct CriterionCell: View {
    let met: Bool?

    var body: some View {
        Group {
            if let met {
                Image(systemName: met ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(met ? Color.green : Color.red.opacity(0.7))
            } else {
                Image(systemName: "minus.circle")
                    .foregroundStyle(Color.secondary.opacity(0.4))
            }
        }
        .font(.system(size: 18))
    }
}
