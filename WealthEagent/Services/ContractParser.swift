// ContractParser.swift
// Services — pure static functions. No I/O, no state, no framework imports beyond Foundation.
//
// Heuristic extraction from German insurance/financial document OCR text.
// Stage-1 MVP: keyword matching + simple regex patterns.
// Accuracy is intentionally limited — all extracted fields require user review
// via PendingContractReviewView before promotion to confirmed Contract.

import Foundation

// MARK: - ContractParser

enum ContractParser {

    // MARK: - ParseResult

    struct ParseResult: Equatable {
        var categoryHint: String?
        var provider: String?
        var contractNumber: String?
        var premiumAmount: Double?
        var premiumInterval: String?
        var extractedFields: ContractFields
        var fieldConfidences: [String: FieldConfidence]
    }

    // MARK: - Public entry point

    /// Extracts structured contract data from raw OCR text.
    /// Pure function — no I/O, deterministic, zero side effects.
    static func parse(text: String) -> ParseResult {
        var fields = ContractFields()
        var confidences: [String: FieldConfidence] = [:]

        let provider = extractProvider(from: text)
        let contractNumber = extractContractNumber(from: text)
        let (premiumAmount, premiumInterval) = extractPremium(from: text)
        let categoryHint = extractCategoryHint(from: text)

        if let providerName = provider {
            fields["provider"] = .text(providerName)
            confidences["provider"] = FieldConfidence(confidence: 0.90, needsReview: false)
        }
        if let cn = contractNumber {
            fields["contract_number"] = .text(cn)
            confidences["contract_number"] = FieldConfidence(confidence: 0.85, needsReview: false)
        }
        if let amount = premiumAmount {
            fields["premium_amount"] = .number(amount)
            confidences["premium_amount"] = FieldConfidence(confidence: 0.80, needsReview: true)
        }
        if let interval = premiumInterval {
            fields["premium_interval"] = .text(interval)
            confidences["premium_interval"] = FieldConfidence(confidence: 0.85, needsReview: false)
        }

        return ParseResult(
            categoryHint: categoryHint,
            provider: provider,
            contractNumber: contractNumber,
            premiumAmount: premiumAmount,
            premiumInterval: premiumInterval,
            extractedFields: fields,
            fieldConfidences: confidences
        )
    }

    // MARK: - Provider extraction

    private static let knownProviders: [String] = [
        "HUK-COBURG", "HUK Coburg", "HUK24",
        "Allianz", "AXA", "Zurich", "Zürich",
        "ERGO", "Generali", "Gothaer", "Helvetia",
        "VHV", "DEVK", "R+V", "Signal Iduna", "Signal-Iduna",
        "Württembergische", "Nürnberger", "Nürnberger Versicherung",
        "Debeka", "Continentale", "LVM", "Provinzial",
        "Concordia", "Grundeigentümer-Versicherung", "GVV",
        "Interrisk", "ÖRAG", "Roland Rechtsschutz", "Auxilia",
        "ARAG", "DAS", "Hanse Merkur", "Barmenia", "HDI",
        "Talanx", "Sparkasse Versicherung", "ADAC",
        "Techniker Krankenkasse", "Techniker", "DAK-Gesundheit", "DAK",
        "AOK", "Barmer", "IKK", "Knappschaft",
        "DKV", "Central", "Hallesche", "SDK",
        "Deutsche Bank", "Commerzbank", "Postbank", "Sparkasse",
        "DZ Bank", "Union Investment", "Deka", "Flossbach",
        "comdirect", "ING", "N26"
    ]

    static func extractProvider(from text: String) -> String? {
        for provider in knownProviders {
            let range = text.range(of: provider, options: [.caseInsensitive, .diacriticInsensitive])
            if range != nil {
                return provider
            }
        }
        return nil
    }

    // MARK: - Contract number extraction

    static func extractContractNumber(from text: String) -> String? {
        // Matches: "Vers.-Nr.", "Versicherungs-Nr.", "VS-Nr.", "Policen-Nr.", "Vertragsnummer:", etc.
        let patterns = [
            "(?:(?:Vers(?:icherungs)?|Policen|VS|Schein)[\\s.\\-]*(?:Nr|Nummer)[\\s.\\-]*|Vertrag(?:s(?:nummer|nr))?[\\s.\\-]*)[:=\\s]*([A-Z0-9][A-Z0-9.\\-/ ]{2,20})",
            "(?:Versicherungsschein|Schein-Nr\\.?)[\\s:]*([A-Z0-9][A-Z0-9.\\-/ ]{2,20})"
        ]
        for pattern in patterns {
            if let result = firstMatch(pattern: pattern, in: text, groupIndex: 1) {
                return result.trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    // MARK: - Premium extraction

    static func extractPremium(from text: String) -> (amount: Double?, interval: String?) {
        let amountPatterns = [
            "(\\d{1,3}(?:\\.\\d{3})*,\\d{2})\\s*(?:EUR|€)",
            "(?:EUR|€)\\s*(\\d{1,3}(?:\\.\\d{3})*,\\d{2})",
            "(\\d+,\\d{2})\\s*(?:EUR|€)",
            "(?:Beitrag|Prämie|Jahresbeitrag|Monatsbeitrag)\\s*:?\\s*(\\d{1,3}(?:\\.\\d{3})*,\\d{2})"
        ]

        var extractedAmount: Double?
        for pattern in amountPatterns {
            if let match = firstMatch(pattern: pattern, in: text, groupIndex: 1) {
                let normalized = match
                    .replacingOccurrences(of: ".", with: "")
                    .replacingOccurrences(of: ",", with: ".")
                if let value = Double(normalized) {
                    extractedAmount = value
                    break
                }
            }
        }

        let interval = extractInterval(from: text)
        return (extractedAmount, interval)
    }

    private static func extractInterval(from text: String) -> String? {
        let lower = text.lowercased()
        if lower.contains("vierteljährlich") || lower.contains("quartal") { return "vierteljaehrlich" }
        if lower.contains("halbjährlich") || lower.contains("halbj.") { return "halbjaehrlich" }
        if lower.contains("jährlich") || lower.contains("jährl.") || lower.contains("jahresbeitrag") { return "jaehrlich" }
        if lower.contains("monatlich") || lower.contains("mtl.") || lower.contains("monatsbeitrag") { return "monatlich" }
        if lower.contains("einmalig") || lower.contains("einmalbeitrag") { return "einmalig" }
        return nil
    }

    // MARK: - Category hint extraction

    private static let categoryKeywords: [(keywords: [String], key: String)] = [
        (["Haftpflichtversicherung", "Privathaftpflicht", "Haftpflicht"], "privathaftpflicht"),
        (["Berufsunfähigkeit", "BU-Versicherung", "BU-Schutz"], "berufsunfaehigkeit"),
        (["Krankenversicherung", "Private Kranken", "PKV"], "krankenversicherung"),
        (["Pflegeversicherung", "Pflege-Tagegeld", "Pflegepflicht"], "pflegeversicherung"),
        (["Risikolebensversicherung", "Risikoschutz", "Todesfallschutz"], "risikoleben"),
        (["Unfallversicherung", "Unfall-Schutz"], "unfallversicherung"),
        (["Hausratversicherung", "Hausrat"], "hausrat"),
        (["Wohngebäude", "Gebäudeversicherung"], "wohngebaeude"),
        (["Rechtsschutzversicherung", "Rechtsschutz", "Rechtsschutz-Police"], "rechtsschutz"),
        (["Kfz-Versicherung", "Kraftfahrzeug", "Kraftfahrtversicherung", "KFZ", "Auto-Versicherung"], "kfz"),
        (["Tierhalterhaftpflicht", "Hundehaftpflicht", "Pferdehaftpflicht"], "tierhalterhaftpflicht"),
        (["Investmentdepot", "Depot", "Wertpapierdepot"], "depot"),
        (["Altersvorsorge", "Rentenversicherung", "Riester", "Rürup"], "altersvorsorge"),
        (["Kapitallebensversicherung", "Lebensversicherung"], "lebensversicherung"),
        (["Immobilienfinanzierung", "Hypothek", "Immobiliendarlehen", "Baufinanzierung"], "immobilienfinanzierung"),
        (["Bausparvertrag", "Bausparen", "LBS", "Wüstenrot"], "bausparvertrag"),
        (["Sparplan", "Fondssparplan", "ETF-Sparplan"], "sparplan"),
        (["Tagesgeld", "Festgeld"], "tagesgeld_festgeld"),
        (["Liquiditätsreserve", "Girokonto", "Tagesgeldkonto"], "liquiditaetsreserve"),
        (["Sterbegeldversicherung", "Sterbegeld"], "sterbegeld"),
        (["Reiseversicherung", "Reisekranken", "Reiserücktritt"], "reiseversicherung"),
        (["Krankentagegeld"], "krankentagegeld")
    ]

    static func extractCategoryHint(from text: String) -> String? {
        for (keywords, key) in categoryKeywords {
            for keyword in keywords {
                if text.range(of: keyword, options: [.caseInsensitive, .diacriticInsensitive]) != nil {
                    return key
                }
            }
        }
        return nil
    }

    // MARK: - Regex helper

    private static func firstMatch(pattern: String, in text: String, groupIndex: Int) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range) else {
            return nil
        }
        let groupRange = match.range(at: groupIndex)
        guard groupRange.location != NSNotFound,
              let swiftRange = Range(groupRange, in: text) else {
            return nil
        }
        return String(text[swiftRange])
    }
}
