// ImpressumView.swift
// Views — Impressum gemäß § 5 TMG (Telemediengesetz).
//
// [LEGAL REVIEW REQUIRED] — Alle PLATZHALTER vor App-Store-Submit ausfüllen.
// swiftlint:disable line_length

import SwiftUI

// MARK: - ImpressumView

struct ImpressumView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // [LEGAL REVIEW REQUIRED] — Angaben nach § 5 TMG
                warningBanner

                angabenSection
                kontaktSection
                streitschlichtungSection
            }
            .padding()
        }
        .navigationTitle("Impressum")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Warning banner

    private var warningBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 4) {
                Text("Vor Launch ausfüllen")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                Text("Alle Platzhalter müssen vor App-Store-Submit durch reale Angaben ersetzt werden (§ 5 TMG).")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Angaben nach § 5 TMG

    private var angabenSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Angaben gemäß § 5 TMG")
                .font(.headline)

            Group {
                impressumRow(label: "Name", value: "[Vorname Nachname]")
                impressumRow(label: "Anschrift", value: "[Straße Hausnr.]\n[PLZ Ort]\n[Land]")
                // Nur wenn gewerblich tätig:
                impressumRow(label: "Handelsregister", value: "[HRB-Nummer / Amtsgericht — entfällt bei Privatpersonen]")
                impressumRow(label: "USt-IdNr.", value: "[DE... — entfällt wenn nicht vorhanden]")
            }
        }
    }

    private var kontaktSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kontakt")
                .font(.headline)

            impressumRow(label: "E-Mail", value: "[kontakt@...]")
        }
    }

    private var streitschlichtungSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Streitschlichtung")
                .font(.headline)

            Text("Die Europäische Kommission stellt eine Plattform zur Online-Streitbeilegung (OS) bereit: https://ec.europa.eu/consumers/odr. Wir sind nicht verpflichtet und nicht bereit, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private func impressumRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(value.contains("[") ? .orange : .primary)
        }
        .padding(.vertical, 4)
    }
}
