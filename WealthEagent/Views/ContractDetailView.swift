// ContractDetailView.swift
// Views — SwiftUI. Read-only Detailansicht eines bestätigten Vertrags.
//
// Stage-1 vocabulary constraint (CLAUDE.md):
//   - "Vertragsdetails" — title
//   - "Leistungskriterien" — criteria section
//   - "Laufzeit" — date section
//   - "Bearbeiten" — edit button
//   - "Empfehlung" / "empfehlen" BANNED

import SwiftUI

// MARK: - ContractDetailView

struct ContractDetailView: View {

    let contract: Contract
    let catalog: Catalog
    let contractRepository: ContractRepository

    @State private var showEdit = false
    @State private var needsDismiss = false
    @Environment(\.dismiss) private var dismiss

    private var categoryName: String {
        catalog.category(for: contract.categoryKey)?.nameDe ?? contract.categoryKey
    }

    private var criteria: [ContractCriterion] {
        catalog.criteriaFor(contract.categoryKey)
    }

    var body: some View {
        List {
            contractSection
            if contract.startDate != nil || contract.endDate != nil {
                laufzeitSection
            }
            if !criteria.isEmpty {
                kriterienSection
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(contract.provider)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Bearbeiten") { showEdit = true }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditContractView(
                viewModel: EditContractViewModel(
                    contract: contract,
                    contractRepository: contractRepository,
                    catalog: catalog
                ),
                onDismiss: {
                    showEdit = false
                    needsDismiss = true
                }
            )
        }
        .onChange(of: needsDismiss) { _, needs in
            if needs { dismiss() }
        }
    }

    // MARK: - Sections

    private var contractSection: some View {
        Section {
            LabeledContent("Kategorie", value: categoryName)
            LabeledContent("Anbieter", value: contract.provider)
            if let amount = contract.premiumAmount {
                LabeledContent("Beitrag", value: formattedPremium(amount: amount))
            }
            if let number = contract.contractNumber {
                LabeledContent("Vertragsnummer", value: number)
            }
        }
    }

    private var laufzeitSection: some View {
        Section("Laufzeit") {
            if let start = contract.startDate {
                LabeledContent("Beginn", value: formatted(start))
            }
            if let end = contract.endDate {
                LabeledContent("Ende", value: formatted(end))
            }
        }
    }

    private var kriterienSection: some View {
        Section("Leistungskriterien") {
            ForEach(criteria) { criterion in
                HStack(spacing: 10) {
                    criterionIcon(for: contract.criteria[criterion.key])
                    Text(criterion.labelDe)
                        .font(.subheadline)
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func criterionIcon(for value: Bool?) -> some View {
        switch value {
        case true:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case false:
            Image(systemName: "xmark.circle.fill").foregroundStyle(.red.opacity(0.6))
        case nil:
            Image(systemName: "minus.circle").foregroundStyle(.secondary.opacity(0.4))
        }
    }

    private func formattedPremium(amount: Double) -> String {
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

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
}
