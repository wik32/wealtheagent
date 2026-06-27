// PortfolioExporter.swift
// Services — pure static functions. No I/O, no state.
// Generates a formatted text summary of the contract portfolio.

import Foundation

enum PortfolioExporter {

    // MARK: - Text export

    static func exportText(contracts: [Contract], catalog: Catalog) -> String {
        let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        var lines: [String] = [
            "WealthEagent — Portfolio-Übersicht",
            "Stand: \(dateStr)",
            "Verträge: \(contracts.count)",
            String(repeating: "─", count: 40)
        ]

        let sorted = contracts.sorted { $0.provider < $1.provider }
        for contract in sorted {
            let categoryName = catalog.category(for: contract.categoryKey)?.nameDe ?? contract.categoryKey
            lines.append("\n● \(contract.provider)")
            lines.append("  Vertragsart: \(categoryName)")
            if let amount = contract.premiumAmount {
                let interval = intervalLabel(contract.premiumInterval)
                lines.append("  Beitrag:     \(formatted(amount)) EUR\(interval)")
            }
            if let start = contract.startDate {
                lines.append("  Beginn:      \(formatted(start))")
            }
            if let end = contract.endDate {
                lines.append("  Ende:        \(formatted(end))")
            }
            if let number = contract.contractNumber {
                lines.append("  Vertrag-Nr.: \(number)")
            }
            let criteria = catalog.criteriaFor(contract.categoryKey)
            let met = criteria.filter { contract.criteria[$0.key] == true }
            if !criteria.isEmpty {
                lines.append("  Kriterien:   \(met.count)/\(criteria.count) erfüllt")
            }
        }

        lines.append("\n\(String(repeating: "─", count: 40))")
        lines.append("Erstellt mit WealthEagent — messen, nicht beraten.")
        return lines.joined(separator: "\n")
    }

    static func exportURL(contracts: [Contract], catalog: Catalog) -> URL {
        let text = exportText(contracts: contracts, catalog: catalog)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("WealthEagent-Portfolio.txt")
        try? text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Helpers

    private static func formatted(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    private static func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }

    private static func intervalLabel(_ interval: String?) -> String {
        switch interval {
        case "monatlich":        return " / Monat"
        case "vierteljaehrlich": return " / Quartal"
        case "halbjaehrlich":    return " / Halbjahr"
        case "jaehrlich":        return " / Jahr"
        case "einmalig":         return " (einmalig)"
        default:                 return ""
        }
    }
}
