// DatenschutzView.swift
// Views — Datenschutzerklärung (DSGVO-konform).
//
// [LEGAL REVIEW REQUIRED] — vor App-Store-Submit anwaltlich prüfen lassen.
// swiftlint:disable line_length

import SwiftUI

// MARK: - DatenschutzView

struct DatenschutzView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                grundsatzSection
                lokaleGerätespeicherungSection
                iCloudSection
                ocrSection
                keineWeitergabeSection
                betroffenenrechteSection
                verantwortlicherSection
            }
            .padding()
        }
        .navigationTitle("Datenschutz")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var grundsatzSection: some View {
        LegalSection(
            icon: "lock.shield.fill",
            iconColor: .green,
            title: "Datenschutz durch Design",
            text: """
            WealthEagent wurde nach dem Prinzip „Privacy by Design" entwickelt. Deine Finanzdaten sind sensibel — sie verlassen dein Gerät nur unter deiner Kontrolle und ausschließlich über Apples verschlüsselte iCloud-Infrastruktur.

            Es gibt keinen WealthEagent-Server, der deine Daten empfängt, speichert oder verarbeitet.
            """
        )
    }

    private var lokaleGerätespeicherungSection: some View {
        LegalSection(
            icon: "iphone",
            iconColor: .blue,
            title: "Lokale Gerätespeicherung",
            text: """
            Alle von dir erfassten Vertragsdaten werden primär auf deinem iPhone gespeichert (SwiftData, lokal). Die Verarbeitung findet ausschließlich auf deinem Gerät statt.

            Rechtsgrundlage: Art. 6 Abs. 1 lit. b DSGVO (Vertragserfüllung / Nutzung der App auf deinen Wunsch).
            """
        )
    }

    private var iCloudSection: some View {
        LegalSection(
            icon: "icloud.fill",
            iconColor: .blue,
            title: "iCloud Private Database (optional)",
            text: """
            Wenn du mit deiner Apple ID angemeldet bist und iCloud aktiviert hast, synchronisiert die App deine Daten über Apples CloudKit Private Database. Diese Daten:

            • sind ausschließlich für dich zugänglich (privat, keine geteilten Zonen)
            • werden von Apple Ende-zu-Ende-verschlüsselt gespeichert
            • liegen in EU-Rechenzentren für EU-Nutzer (Apple-Datenzentren in Irland und Dänemark)

            WealthEagent hat keinen Zugriff auf deine iCloud-Daten. Apple verarbeitet diese Daten gemäß Apples eigener Datenschutzerklärung (apple.com/legal/privacy/de-ww/).

            Du kannst die iCloud-Synchronisierung jederzeit in den iPhone-Einstellungen deaktivieren.
            """
        )
    }

    private var ocrSection: some View {
        LegalSection(
            icon: "camera.viewfinder",
            iconColor: .purple,
            title: "Texterkennung (OCR)",
            text: """
            Die Texterkennung erfolgt mit Apple Vision vollständig auf deinem Gerät. Kein Foto und kein erkannter Text wird an externe Server übertragen.

            Apple Vision ist ein On-Device-Framework ohne Netzwerkverbindung.
            """
        )
    }

    private var keineWeitergabeSection: some View {
        LegalSection(
            icon: "person.slash",
            iconColor: .red,
            title: "Keine Weitergabe an Dritte",
            text: """
            WealthEagent gibt keinerlei personenbezogene Daten an Dritte weiter. Es werden keine Analyse-SDKs, Werbenetzwerke oder Crash-Reporting-Dienste eingebunden, die Daten erheben.

            Die App enthält:
            • Kein Tracking
            • Keine Werbung
            • Keine Affiliate-Links
            • Kein Analytics-Framework
            """
        )
    }

    private var betroffenenrechteSection: some View {
        LegalSection(
            icon: "person.badge.key",
            iconColor: .orange,
            title: "Deine Rechte (Art. 15–22 DSGVO)",
            text: """
            Da deine Daten ausschließlich auf deinem Gerät und in deiner privaten iCloud-Datenbank liegen, kannst du deine Rechte direkt selbst ausüben:

            • Auskunft: Alle Daten sind in der App sichtbar
            • Berichtigung: Direkt in der App über „Vertrag bearbeiten"
            • Löschung: Über Swipe-to-Delete in der Vertragsliste oder Gerät zurücksetzen
            • Datenübertragbarkeit: Daten liegen strukturiert in deiner iCloud

            Für Anfragen zum Datenschutz: [LEGAL REVIEW REQUIRED — Kontaktadresse eintragen]
            """
        )
    }

    private var verantwortlicherSection: some View {
        // [LEGAL REVIEW REQUIRED] — Verantwortlichen-Angaben vor Launch eintragen
        LegalSection(
            icon: "building.2",
            iconColor: .secondary,
            title: "Verantwortlicher (Art. 13 DSGVO)",
            text: """
            [PLATZHALTER — vor App-Store-Submit auszufüllen]

            Name und Anschrift des Verantwortlichen:
            [Name]
            [Straße, Hausnummer]
            [PLZ, Ort]
            [Land]

            E-Mail: [datenschutz@...]

            Stand: \(currentDateString)
            """
        )
    }

    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: Date())
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
