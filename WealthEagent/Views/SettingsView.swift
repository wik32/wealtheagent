// SettingsView.swift
// Views — "Mehr"-Tab: Export, Benachrichtigungen, Datenspeicherung, Rechtliches.

import SwiftUI
import UserNotifications

// MARK: - SettingsView

struct SettingsView: View {

    let contractRepository: ContractRepository
    let catalogProvider: CatalogProvider
    let notificationPort: NotificationPort

    @State private var notificationGranted: Bool? = nil
    @State private var showExportSheet = false
    @State private var exportURL: URL?

    private var iCloudConnected: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    var body: some View {
        NavigationStack {
            List {
                exportSection
                benachrichtigungenSection
                datenspeicherungSection
                appInfoSection
                legalSection
                versionSection
            }
            .navigationTitle("Mehr")
            .listStyle(.insetGrouped)
            .task { await checkNotificationStatus() }
        }
    }

    // MARK: - Export

    private var exportSection: some View {
        Section("Portfolio") {
            Button {
                Task { await generateExport() }
            } label: {
                Label("Portfolio exportieren", systemImage: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $showExportSheet) {
            if let url = exportURL {
                ShareSheet(url: url)
            }
        }
    }

    // MARK: - Benachrichtigungen

    private var benachrichtigungenSection: some View {
        Section("Benachrichtigungen") {
            HStack {
                Label("Vertragserinnerungen", systemImage: "bell.badge")
                Spacer()
                if let granted = notificationGranted {
                    Text(granted ? "Aktiv" : "Nicht erlaubt")
                        .font(.subheadline)
                        .foregroundStyle(granted ? .green : .secondary)
                } else {
                    ProgressView().scaleEffect(0.7)
                }
            }
            if notificationGranted == false {
                Button("Benachrichtigungen erlauben") {
                    Task {
                        let granted = await notificationPort.requestPermission()
                        notificationGranted = granted
                    }
                }
            } else if notificationGranted == true {
                Text("Du erhältst 30 Tage vor Vertragsende eine Erinnerung.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Datenspeicherung

    private var datenspeicherungSection: some View {
        Section("Datenspeicherung") {
            LabeledContent("Speicherort") {
                Text("Gerät (lokal)").foregroundStyle(.secondary)
            }
            LabeledContent("iCloud-Konto") {
                if iCloudConnected {
                    Label("Verbunden", systemImage: "checkmark.circle.fill").foregroundStyle(.green).font(.subheadline)
                } else {
                    Label("Nicht angemeldet", systemImage: "xmark.circle").foregroundStyle(.secondary).font(.subheadline)
                }
            }
            Text(iCloudConnected
                 ? "iCloud ist aktiv — Sync wird in einer kommenden Version freigeschaltet."
                 : "Mit Apple ID anmelden, um iCloud-Sync nutzen zu können (kommende Version).")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    // MARK: - App-Info

    private var appInfoSection: some View {
        Section("WealthEagent") {
            NavigationLink(destination: DisclaimerView()) {
                Label("Haftungsausschluss", systemImage: "exclamationmark.shield")
            }
            NavigationLink(destination: DatenschutzView()) {
                Label("Datenschutz", systemImage: "lock.shield")
            }
            NavigationLink(destination: ImpressumView()) {
                Label("Impressum", systemImage: "info.circle")
            }
        }
    }

    // MARK: - Hinweis

    private var legalSection: some View {
        Section("Hinweis") {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "info.circle.fill").foregroundStyle(.blue).padding(.top, 2)
                Text("WealthEagent zeigt ausschließlich Fakten aus deinen eigenen Unterlagen. Keine Finanz- oder Versicherungsberatung.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Version

    private var versionSection: some View {
        Section {
            LabeledContent("Version") {
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Helpers

    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationGranted = settings.authorizationStatus == .authorized
    }

    private func generateExport() async {
        do {
            let contracts = try await contractRepository.list()
            let catalog = catalogProvider.catalog()
            exportURL = PortfolioExporter.exportURL(contracts: contracts, catalog: catalog)
            showExportSheet = true
        } catch {
            // Export fehler — kein Crash
        }
    }
}

// MARK: - ShareSheet

private struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
