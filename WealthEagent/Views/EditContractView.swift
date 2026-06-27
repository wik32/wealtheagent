// EditContractView.swift
// Views — SwiftUI. Pre-filled form for editing a confirmed Contract.
//
// Stage-1 vocabulary constraint (CLAUDE.md):
//   - "Vertrag bearbeiten" — sheet title
//   - "Leistungskriterien" — criteria section
//   - "Speichern" / "Abbrechen" — action buttons
//   - "Empfehlung" / "empfehlen" BANNED

import SwiftUI

// MARK: - EditContractView

/// Modal form for editing an existing confirmed contract.
/// Pre-fills all fields from the existing contract data.
/// Saving preserves the original contract ID (upsert).
struct EditContractView: View {

    @Bindable var viewModel: EditContractViewModel
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                vertragsartSection
                anbieterSection
                beitragSection
                laufzeitSection
                if !viewModel.availableCriteria.isEmpty {
                    kriterienSection
                }
                optionalSection
            }
            .navigationTitle("Vertrag bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { onDismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task {
                            try? await viewModel.save()
                            onDismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }

    @ViewBuilder
    private var vertragsartSection: some View {
        Section("Vertragsart") {
            Picker("Kategorie", selection: $viewModel.selectedCategoryKey) {
                Text("Bitte wählen").tag("")
                ForEach(viewModel.catalog.categories, id: \.key) { category in
                    Text(category.nameDe).tag(category.key)
                }
            }
        }
    }

    @ViewBuilder
    private var anbieterSection: some View {
        Section("Anbieter") {
            TextField("z.B. HUK-COBURG", text: $viewModel.provider)
                .textInputAutocapitalization(.words)
        }
    }

    @ViewBuilder
    private var beitragSection: some View {
        Section("Beitrag") {
            HStack {
                TextField("0,00", text: $viewModel.premiumAmountText)
                    .keyboardType(.decimalPad)
                Text("EUR").foregroundStyle(.secondary)
            }
            Picker("Zahlungsrhythmus", selection: $viewModel.premiumInterval) {
                Text("Monatlich").tag("monatlich")
                Text("Vierteljährlich").tag("vierteljaehrlich")
                Text("Halbjährlich").tag("halbjaehrlich")
                Text("Jährlich").tag("jaehrlich")
                Text("Einmalig").tag("einmalig")
            }
        }
    }

    @ViewBuilder
    private var laufzeitSection: some View {
        Section("Laufzeit") {
            Toggle("Startdatum", isOn: $viewModel.hasStartDate)
            if viewModel.hasStartDate {
                DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            Toggle("Vertragsende", isOn: $viewModel.hasEndDate)
            if viewModel.hasEndDate {
                DatePicker("", selection: $viewModel.endDate, in: viewModel.startDate..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
        }
    }

    @ViewBuilder
    private var kriterienSection: some View {
        Section {
            ForEach(viewModel.availableCriteria) { criterion in
                Toggle(isOn: Binding(
                    get: { viewModel.criteriaChecked[criterion.key] ?? false },
                    set: { viewModel.criteriaChecked[criterion.key] = $0 }
                )) {
                    Text(criterion.labelDe)
                }
            }
        } header: {
            Text("Leistungskriterien")
        } footer: {
            Text("Welche Merkmale bietet dein Vertrag?")
                .font(.caption)
        }
    }

    @ViewBuilder
    private var optionalSection: some View {
        Section("Optional") {
            TextField("Vertragsnummer", text: $viewModel.contractNumber)
                .keyboardType(.numbersAndPunctuation)
        }
    }
}
