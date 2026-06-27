// OnboardingDisclaimerView.swift
// Views — Pflichthinweis beim ersten App-Start.
// Wird einmalig angezeigt; Bestätigung wird in UserDefaults gespeichert.
//
// Zweck: Nutzer bestätigt explizit, dass die App keine Finanzberatung ist.
// Ohne Bestätigung bleibt die App gesperrt (fullScreenCover).

import SwiftUI

// MARK: - OnboardingDisclaimerView

struct OnboardingDisclaimerView: View {

    var onAccept: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            iconHeader
            Spacer()
            hinweisText
            Spacer()
            acceptButton
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 28)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Subviews

    private var iconHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            Text("WealthEagent")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Messen, nicht beraten.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var hinweisText: some View {
        VStack(alignment: .leading, spacing: 16) {
            hinweisRow(
                icon: "doc.text.magnifyingglass",
                color: .blue,
                text: "Die App zeigt Fakten aus deinen eigenen Unterlagen — keine Empfehlungen, keine Beratung."
            )
            hinweisRow(
                icon: "hand.raised.fill",
                color: .orange,
                text: "WealthEagent ist kein zugelassener Finanz- oder Versicherungsberater. Die Nutzung ersetzt keine individuelle Beratung."
            )
            hinweisRow(
                icon: "lock.shield.fill",
                color: .green,
                text: "Deine Daten bleiben auf deinem Gerät und in deiner privaten iCloud-Datenbank. Kein WealthEagent-Server empfängt deine Daten."
            )
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var acceptButton: some View {
        Button(action: onAccept) {
            Text("Verstanden — App starten")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func hinweisRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
                .padding(.top, 2)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
