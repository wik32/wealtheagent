// PendingContractReviewView.swift
// Views — SwiftUI. User reviews and corrects OCR-extracted contract data before confirming.
//
// Stage-1 vocabulary constraint (CLAUDE.md):
//   - "Entwurf prüfen" — title
//   - "Erkannte Daten" / "Vertragsart" / "Anbieter" — section labels
//   - "Vertrag übernehmen" — confirm action
//   - "Verwerfen" — discard action
//   - "Empfehlung" / "empfehlen" BANNED

import SwiftUI

// MARK: - PendingContractReviewView

/// Form allowing the user to review and correct OCR-extracted fields before confirming.
/// Presents the OCR confidence score so the user knows how much to trust the extraction.
struct PendingContractReviewView: View {

    @Bindable var viewModel: PendingContractReviewViewModel
    var onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                confidenceSection
                vertragsartSection
                anbieterSection
                optionalSection
                actionsSection
            }
            .navigationTitle("Entwurf prüfen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { onDismiss() }
                }
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var confidenceSection: some View {
        Section("Erkannte Daten") {
            LabeledContent("Texterkennung") {
                Text(String(format: "%.0f %%", viewModel.pending.ocrConfidence * 100))
                    .foregroundStyle(confidenceColor)
            }
            LabeledContent("Erkannter Text") {
                Text(viewModel.pending.rawOCRText.isEmpty
                     ? "Kein Text erkannt"
                     : String(viewModel.pending.rawOCRText.prefix(120)))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            }
        }
    }

    @ViewBuilder
    private var vertragsartSection: some View {
        Section("Vertragsart") {
            Picker("Kategorie", selection: $viewModel.selectedCategoryKey) {
                Text("Nicht erkannt").tag("")
                ForEach(viewModel.catalog.categories, id: \.key) { category in
                    Text(category.nameDe).tag(category.key)
                }
            }
        }
    }

    @ViewBuilder
    private var anbieterSection: some View {
        Section("Anbieter") {
            TextField("Anbieter eingeben", text: $viewModel.provider)
                .textInputAutocapitalization(.words)
        }
    }

    @ViewBuilder
    private var optionalSection: some View {
        Section("Optional") {
            TextField("Vertragsnummer", text: $viewModel.contractNumber)
                .keyboardType(.numbersAndPunctuation)
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        Section {
            Button("Vertrag übernehmen") {
                Task {
                    try? await viewModel.confirm()
                    onDismiss()
                }
            }
            .disabled(!viewModel.canConfirm)

            Button("Verwerfen", role: .destructive) {
                Task {
                    try? await viewModel.discard()
                    onDismiss()
                }
            }
        }
    }

    // MARK: - Helpers

    private var confidenceColor: Color {
        let c = viewModel.pending.ocrConfidence
        if c >= 0.8 { return .green }
        if c >= 0.5 { return .orange }
        return .red
    }
}
