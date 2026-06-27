// ContractParserTests.swift
// Layer 1 — Unit tests for ContractParser (pure static functions).
// Framework: Swift Testing (@Test, #expect) — no async, no I/O, no mocks needed.
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.

import Testing
@testable import WealthEagent

// MARK: - ContractParserTests

@Suite("ContractParser")
struct ContractParserTests {

    // MARK: - Empty text

    @Test("Leerer Text liefert leere Felder")
    func leerTextLiefertLeereFelder() {
        let result = ContractParser.parse(text: "")
        #expect(result.provider == nil)
        #expect(result.categoryHint == nil)
        #expect(result.contractNumber == nil)
        #expect(result.premiumAmount == nil)
        #expect(result.premiumInterval == nil)
    }

    // MARK: - Provider extraction

    @Test("HUK-COBURG wird als Anbieter erkannt")
    func hukCoburgWirdErkannt() {
        let text = "HUK-COBURG Allgemeine Versicherung AG\nPrivathaftpflichtversicherung"
        let result = ContractParser.extractProvider(from: text)
        #expect(result == "HUK-COBURG")
    }

    @Test("Allianz wird als Anbieter erkannt")
    func allianzWirdErkannt() {
        let result = ContractParser.extractProvider(from: "Allianz Versicherungs-AG")
        #expect(result == "Allianz")
    }

    @Test("Unbekannter Anbieter liefert nil")
    func unbekannterAnbieterLiefertNil() {
        let result = ContractParser.extractProvider(from: "Muster Versicherung GmbH")
        #expect(result == nil)
    }

    // MARK: - Category hint extraction

    @Test("Privathaftpflicht wird als Kategorie erkannt")
    func privathaftpflichtWirdErkannt() {
        let text = "Privathaftpflichtversicherung — Jahresbeitrag 89 EUR"
        let result = ContractParser.extractCategoryHint(from: text)
        #expect(result == "privathaftpflicht")
    }

    @Test("Hausratversicherung wird als Kategorie erkannt")
    func hausratWirdErkannt() {
        let text = "Hausratversicherung, Vers.-Nr. HR-123"
        let result = ContractParser.extractCategoryHint(from: text)
        #expect(result == "hausrat")
    }

    @Test("Kfz-Versicherung wird als Kategorie erkannt")
    func kfzWirdErkannt() {
        let text = "Kfz-Versicherung für PKW, Kennzeichen: HH-AB 1234"
        let result = ContractParser.extractCategoryHint(from: text)
        #expect(result == "kfz")
    }

    @Test("Berufsunfähigkeit wird als Kategorie erkannt")
    func buWirdErkannt() {
        let text = "Berufsunfähigkeitsversicherung BU-Schutz"
        let result = ContractParser.extractCategoryHint(from: text)
        #expect(result == "berufsunfaehigkeit")
    }

    @Test("Depot wird als Kategorie erkannt")
    func depotWirdErkannt() {
        let text = "Investmentdepot Kontoauszug 2024"
        let result = ContractParser.extractCategoryHint(from: text)
        #expect(result == "depot")
    }

    // MARK: - Contract number extraction

    @Test("Vertragsnummer mit Vers.-Nr. Präfix wird extrahiert")
    func vertragsNummerMitVersNrWirdExtrahiert() {
        let text = "Vers.-Nr. PHV-12345678\nJahresbeitrag: 89,00 EUR"
        let result = ContractParser.extractContractNumber(from: text)
        #expect(result != nil)
        #expect(result?.contains("PHV") == true)
    }

    // MARK: - Premium extraction

    @Test("Jährlicher Beitrag 89,00 EUR wird extrahiert")
    func jahresbeitrag8900EurWirdExtrahiert() {
        let text = "Jahresbeitrag: 89,00 EUR jährlich"
        let (amount, interval) = ContractParser.extractPremium(from: text)
        #expect(amount != nil)
        #expect(abs((amount ?? 0) - 89.0) < 0.01)
        #expect(interval == "jaehrlich")
    }

    @Test("Monatlicher Beitrag 12,50 EUR wird extrahiert")
    func monatsbeitrag1250EurWirdExtrahiert() {
        let text = "Monatsbeitrag: 12,50 EUR monatlich"
        let (amount, interval) = ContractParser.extractPremium(from: text)
        #expect(amount != nil)
        #expect(abs((amount ?? 0) - 12.50) < 0.01)
        #expect(interval == "monatlich")
    }

    @Test("Vierteljährlicher Rhythmus wird erkannt")
    func vierteljährlichWirdErkannt() {
        let (_, interval) = ContractParser.extractPremium(from: "Beitrag vierteljährlich 45,00 EUR")
        #expect(interval == "vierteljaehrlich")
    }

    @Test("Halbjährlicher Rhythmus wird erkannt")
    func halbjaehrlichWirdErkannt() {
        let (_, interval) = ContractParser.extractPremium(from: "Beitrag halbjährlich 180,00 EUR")
        #expect(interval == "halbjaehrlich")
    }

    // MARK: - Full parse integration

    @Test("Vollständiges HUK-Dokument wird korrekt geparst")
    func vollstaendigesHukDokumentWirdGeparst() {
        let text = """
        HUK-COBURG Allgemeine Versicherung AG
        Privathaftpflichtversicherung
        Vers.-Nr. PHV-12345678
        Jahresbeitrag: 89,00 EUR
        jährlich fällig am 01.01.
        """
        let result = ContractParser.parse(text: text)
        #expect(result.provider == "HUK-COBURG")
        #expect(result.categoryHint == "privathaftpflicht")
        #expect(result.premiumInterval == "jaehrlich")
        #expect(result.premiumAmount != nil)
        #expect(result.contractNumber != nil)
    }
}
