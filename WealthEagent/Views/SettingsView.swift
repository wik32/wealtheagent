// SettingsView.swift
// Views — "Mehr"-Tab: App-Info, Haftungsausschluss, Datenschutz, Impressum.
//
// Stage-1 vocabulary constraint (CLAUDE.md):
//   - Keine Empfehlung, kein empfehlen
//   - "Beobachtungen", "Fakten", "wir messen" — nicht "wir empfehlen"

import SwiftUI

// MARK: - SettingsView

/// "Mehr"-Tab: rechtliche Texte, App-Version, Kontakt.
struct SettingsView: View {

    var body: some View {
        NavigationStack {
            List {
                appInfoSection
                legalSection
                versionSection
            }
            .navigationTitle("Mehr")
            .listStyle(.insetGrouped)
        }
    }

    // MARK: - Sections

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

    private var versionSection: some View {
        Section {
            LabeledContent("Version") {
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
