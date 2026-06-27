// AddContractView.swift
// Views — SwiftUI. Manual contract entry form presented as a modal sheet.
//
// Stage-1 vocabulary constraint (ubiquitous-language.md + CLAUDE.md):
//   - "Vertrag erfassen" — sheet title
//   - "Vertragsart" — category picker label
//   - "Anbieter" — provider field label
//   - "Beitrag" — premium section label
//   - "Zahlungsrhythmus" — interval picker label
//   - "Speichern" / "Abbrechen" — action buttons
//   - "Empfehlung" / "empfehlen" are BANNED from all View text

import SwiftUI

// MARK: - AddContractView

/// Modal form for manually entering a new financial contract.
/// Presented as a sheet from ContractListView when the user taps "+".
/// Receives an AddContractViewModel via dependency injection (Pillar 3).
struct AddContractView: View {

    @Bindable var viewModel: AddContractViewModel
    var onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                vertragsartSection
                anbieterSection
                beitragSection
                optionalSection
            }
            .navigationTitle("Vertrag erfassen")
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

    // MARK: - Sections

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
                Text("EUR")
                    .foregroundStyle(.secondary)
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
    private var optionalSection: some View {
        Section("Optional") {
            TextField("Vertragsnummer", text: $viewModel.contractNumber)
                .keyboardType(.numbersAndPunctuation)
        }
    }
}
