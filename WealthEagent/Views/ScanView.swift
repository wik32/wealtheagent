// ScanView.swift
// Views — SwiftUI. Document scan flow using PhotosPicker (on-device, no cloud).
//
// Stage-1 vocabulary constraint (CLAUDE.md):
//   - "Dokument scannen" — sheet title
//   - "Dokument auswählen" — picker label
//   - "Dokument wird analysiert" — scanning state
//   - "Entwurf gespeichert" — success state
//   - "Empfehlung" / "empfehlen" BANNED

import SwiftUI
import PhotosUI

// MARK: - ScanView

/// Modal sheet for scanning a document photo with Apple Vision (on-device OCR).
/// After a successful scan, dismisses to allow the caller to show PendingContractReviewView.
struct ScanView: View {

    @Bindable var viewModel: ScanViewModel
    var onDismiss: () -> Void

    @State private var selectedItem: PhotosPickerItem?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                content
                Spacer()
            }
            .padding()
            .navigationTitle("Dokument scannen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { onDismiss() }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task { await loadAndScan(item: newItem) }
            }
        }
    }

    // MARK: - Content states

    @ViewBuilder
    private var content: some View {
        if viewModel.isScanning {
            scanningState
        } else if viewModel.scannedPending != nil {
            successState
        } else {
            pickerState
        }
    }

    @ViewBuilder
    private var pickerState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Versicherungspolice oder Kontoauszug fotografieren")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ) {
                Label("Dokument auswählen", systemImage: "photo.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if let error = viewModel.error {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @ViewBuilder
    private var scanningState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Dokument wird analysiert …")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var successState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("Entwurf gespeichert")
                .font(.headline)
            Text("Bitte die erkannten Daten prüfen und bestätigen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Zur Prüfung") { onDismiss() }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Helpers

    private func loadAndScan(item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        await viewModel.scan(imageData: data)
    }
}
