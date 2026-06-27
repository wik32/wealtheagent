// ScanView.swift
// Views — Document scan: live camera OR photo library → Apple Vision OCR.
// Unterstützt Einzelseiten- und Mehrseitenscan.
//
// Stage-1 vocabulary constraint (CLAUDE.md): "Empfehlung" / "empfehlen" BANNED

import SwiftUI
import PhotosUI

// MARK: - ScanView

struct ScanView: View {

    @Bindable var viewModel: ScanViewModel
    var onDismiss: () -> Void

    @State private var selectedItem: PhotosPickerItem?
    @State private var showCamera = false

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
                Task { await handleLibrarySelection(newItem) }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView { data in
                    Task { await handleCapture(data) }
                }
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
        } else if viewModel.hasPages {
            multiPageState
        } else {
            pickerState
        }
    }

    // MARK: - Initial picker state

    @ViewBuilder
    private var pickerState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Versicherungspolice oder Kontoauszug aufnehmen")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                if CameraPickerView.isAvailable {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Foto aufnehmen", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Aus Bibliothek wählen", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedButtonStyle())
            }

            if let error = viewModel.error {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Multi-page accumulation state

    @ViewBuilder
    private var multiPageState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.on.doc.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("\(viewModel.pageCount) \(viewModel.pageCount == 1 ? "Seite" : "Seiten") erkannt")
                .font(.headline)

            Text("Weitere Seite hinzufügen oder Auswertung starten.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                if CameraPickerView.isAvailable {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Weitere Seite aufnehmen", systemImage: "camera.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Seite aus Bibliothek", systemImage: "photo.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedButtonStyle())

                Button {
                    Task { await viewModel.finalizeMultiPage() }
                } label: {
                    Label("Auswerten", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(role: .destructive) {
                    viewModel.reset()
                } label: {
                    Text("Neu starten")
                }
                .buttonStyle(.borderless)
            }

            if let error = viewModel.error {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
    }

    // MARK: - Scanning state

    @ViewBuilder
    private var scanningState: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5)
            Text("Dokument wird analysiert …")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Success state

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

    // MARK: - Input handlers

    private func handleLibrarySelection(_ item: PhotosPickerItem?) async {
        guard let item, let data = try? await item.loadTransferable(type: Data.self) else { return }
        selectedItem = nil
        await handleCapture(data)
    }

    private func handleCapture(_ data: Data) async {
        if viewModel.hasPages || viewModel.scannedPending != nil {
            await viewModel.addPage(imageData: data)
        } else {
            await viewModel.addPage(imageData: data)
        }
    }
}
