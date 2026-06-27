// SettingsView.swift
// Views — "Mehr"-Tab: Datenspeicherung, iCloud-Status, rechtliche Texte, App-Version.

import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    private var iCloudConnected: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    var body: some View {
        NavigationStack {
            List {
                datenspeicherungSection
                appInfoSection
                legalSection
                versionSection
            }
            .navigationTitle("Mehr")
            .listStyle(.insetGrouped)
        }
    }

    // MARK: - Datenspeicherung + iCloud

    private var datenspeicherungSection: some View {
        Section("Datenspeicherung") {
            LabeledContent("Speicherort") {
                Text("Gerät (lokal)")
                    .foregroundStyle(.secondary)
            }

            LabeledContent("iCloud-Konto") {
                if iCloudConnected {
                    Label("Verbunden", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.subheadline)
                } else {
                    Label("Nicht angemeldet", systemImage: "xmark.circle")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: iCloudConnected ? "icloud" : "icloud.slash")
                    .foregroundStyle(.secondary)
                    .padding(.top, 1)
                Text(iCloudConnected
                     ? "iCloud ist aktiv — automatische Synchronisation wird in einer kommenden Version aktiviert."
                     : "Melde dich mit deiner Apple ID an, um iCloud-Sync nutzen zu können (kommende Version).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
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
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                    .padding(.top, 2)
                Text("WealthEagent zeigt ausschließlich Fakten aus deinen eigenen Unterlagen. Die App ist keine Finanz- oder Versicherungsberatung.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
}
