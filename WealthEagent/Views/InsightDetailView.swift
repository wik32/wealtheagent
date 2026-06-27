// InsightDetailView.swift
// Views — Detail-Sheet für eine einzelne Beobachtung.
// Zeigt Titel, Detail und (für Vergleichs-Kennzahlen) eine Erklärung.
//
// Stage-1 vocabulary constraint (CLAUDE.md): "Empfehlung" / "empfehlen" BANNED
// swiftlint:disable line_length

import SwiftUI

// MARK: - InsightDetailView

struct InsightDetailView: View {

    let insight: Insight
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    detailSection
                    if let explanation = explanationFor(insight) {
                        explanationSection(explanation)
                    }
                }
                .padding()
            }
            .navigationTitle("Beobachtung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { onDismiss() }
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(kindLabel)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(kindColor.opacity(0.15))
                .foregroundStyle(kindColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(insight.titleDe)
                .font(.title3)
                .fontWeight(.bold)
        }
    }

    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Messergebnis")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Text(insight.detailDe)
                .font(.body)
        }
    }

    private func explanationSection(_ explanation: InsightExplanation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            Text("Was bedeutet das?")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(explanation.what)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let benchmark = explanation.benchmark {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Orientierungswert")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(benchmark)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(10)
                .background(Color.blue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    // MARK: - Helpers

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

    private func explanationFor(_ insight: Insight) -> InsightExplanation? {
        if insight.categoryKey == "depot" && insight.kind == .comparison {
            return InsightExplanation(
                what: "Die TER (Total Expense Ratio) gibt an, welcher Anteil des Fondsvermögens jährlich als Kosten abgezogen wird. Sie beinhaltet Verwaltungsgebühren, Vertriebskosten und weitere laufende Gebühren.",
                benchmark: "Günstige ETFs haben eine TER von 0,05–0,30 %. Aktiv gemanagte Fonds liegen oft bei 1,0–2,0 %. Bei der TER deines Depots: unter 1,0 % gilt als günstig. Quelle: Stiftung Warentest."
            )
        }
        return nil
    }
}

// MARK: - InsightExplanation

private struct InsightExplanation {
    let what: String
    let benchmark: String?
}
