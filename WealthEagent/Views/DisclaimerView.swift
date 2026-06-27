// DisclaimerView.swift
// Views — Haftungsausschluss: keine Anlage- oder Versicherungsberatung.
//
// [LEGAL REVIEW REQUIRED] kennzeichnet prüfungspflichtige Stellen.
// swiftlint:disable line_length

import SwiftUI

// MARK: - DisclaimerView

struct DisclaimerView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                keinBeratungsvertragSection
                datenbasisSection
                ocrHinweisSection
                keinHaftungSection
            }
            .padding()
        }
        .navigationTitle("Haftungsausschluss")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var keinBeratungsvertragSection: some View {
        LegalSection(
            icon: "hand.raised.fill",
            iconColor: .orange,
            title: "Keine Finanz- oder Versicherungsberatung",
            text: """
            WealthEagent ist kein zugelassener Anlage- oder Versicherungsberater und erbringt keine Finanzdienstleistungen im Sinne des Wertpapierhandelsgesetzes (WpHG) oder des Versicherungsaufsichtsgesetzes (VAG).

            Die App zeigt ausschließlich Fakten, die du selbst erfasst hast — aus deinen eigenen Versicherungspolicen und Finanzunterlagen. Die dargestellten Beobachtungen (Dopplungen, Lücken, Kennzahlen) sind rein informative Messungen deiner Vertragsdaten.

            Sie ersetzen keine individuelle Beratung durch einen zugelassenen Finanz- oder Versicherungsvermittler (§ 34d GewO) oder Anlageberater.
            """
        )
    }

    private var datenbasisSection: some View {
        LegalSection(
            icon: "doc.text.magnifyingglass",
            iconColor: .blue,
            title: "Datenbasis und Vollständigkeit",
            text: """
            Die Qualität der Beobachtungen hängt ausschließlich von den von dir erfassten Vertragsdaten ab. WealthEagent kann nur das anzeigen, was du der App mitgeteilt hast.

            Unvollständige oder fehlerhafte Eingaben führen zu unvollständigen oder fehlerhaften Beobachtungen. Die App trifft keine Annahmen über Verträge, die nicht erfasst wurden.

            Leistungskriterien basieren auf öffentlich zugänglichen Quellen (Stiftung Warentest, Franke & Bornberg). Sie spiegeln den Stand zum Zeitpunkt der letzten Katalogaktualisierung wider und können vom aktuellen Marktstand abweichen.
            """
        )
    }

    private var ocrHinweisSection: some View {
        LegalSection(
            icon: "camera.viewfinder",
            iconColor: .purple,
            title: "Texterkennung (OCR)",
            text: """
            Die automatische Texterkennung (Apple Vision, vollständig auf deinem Gerät) kann Fehler enthalten. Erkannte Werte wie Vertragsnummer, Beitrag oder Anbieter müssen vor der Bestätigung von dir geprüft werden.

            WealthEagent übernimmt keine Haftung für Fehler, die durch fehlerhafte OCR-Erkennung entstehen.
            """
        )
    }

    private var keinHaftungSection: some View {
        LegalSection(
            icon: "shield.slash",
            iconColor: .red,
            title: "Haftungsbeschränkung",
            // [LEGAL REVIEW REQUIRED] — Haftungsausschlussformulierung vor Launch anwaltlich prüfen
            text: """
            Die Nutzung der App erfolgt auf eigene Verantwortung. WealthEagent haftet nicht für Entscheidungen, die auf Basis der in der App dargestellten Informationen getroffen werden.

            Für Schäden, die durch die Nutzung oder Nicht-Nutzung der bereitgestellten Informationen entstehen, wird keine Haftung übernommen, soweit diese nicht auf Vorsatz oder grober Fahrlässigkeit beruhen.
            """
        )
    }
}

// MARK: - LegalSection

private struct LegalSection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.headline)
            }
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
