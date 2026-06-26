// MockCatalogProvider.swift
// FinanzAppTests — Test Mocks
// SCAFFOLD: true — RED scaffold created by DISTILL wave

import Foundation

/// In-memory implementation of CatalogProvider for tests.
/// Returns a minimal catalog with the 22 categories needed to exercise InsightsEngine.
final class MockCatalogProvider: CatalogProvider {

    private let mockCatalog: Catalog

    init(catalog: Catalog = MockCatalogFixtures.standard) {
        self.mockCatalog = catalog
    }

    func catalog() -> Catalog {
        return mockCatalog
    }

    func criteriaFor(_ categoryKey: String) -> [ContractCriterion] {
        return mockCatalog.criteria(for: categoryKey)
    }

    func probe() -> ProbeResult {
        return .success
    }
}

// MARK: - Catalog Fixture

enum MockCatalogFixtures {

    /// Standard catalog with all 22 categories — mirrors catalog.json structure.
    /// Level 1 categories (existential, 11 total):
    ///   privathaftpflicht, berufsunfaehigkeit, krankenversicherung, pflegeversicherung,
    ///   risikoleben, unfallversicherung, hausrat, wohngebaeude, rechtsschutz, kfz,
    ///   tierhalterhaftpflicht
    /// Level 2 categories (provision, 8 total):
    ///   liquiditaetsreserve, altersvorsorge, lebensversicherung, immobilienfinanzierung,
    ///   bausparvertrag, depot, sparplan, tagesgeld_festgeld
    /// Level 3 categories (supplements, 3 total):
    ///   sterbegeld, reiseversicherung, krankentagegeld
    static var standard: Catalog {
        Catalog(
            schemaVersion: "1.0",
            categories: allCategories
        )
    }

    // MARK: Level 1 — Existential Protection

    static let privathaftpflichtCategory = ContractCategory(
        key: "privathaftpflicht",
        nameDE: "Privathaftpflicht",
        nameEN: "Personal Liability",
        needsLevel: 1,
        purpose: "Schützt vor finanziellen Schäden, die du anderen zufügst.",
        relevance: "Ohne Haftpflichtschutz können Schadensersatzforderungen existenzbedrohend werden.",
        watch: nil,
        fields: privathaftpflichtFields,
        criteria: privathaftpflichtCriteria,
        knowledgeArticles: []
    )

    static let berufsunfaehigkeitCategory = ContractCategory(
        key: "berufsunfaehigkeit",
        nameDE: "Berufsunfähigkeit",
        nameEN: "Disability Insurance",
        needsLevel: 1,
        purpose: "Sichert dein Einkommen, wenn du deinen Beruf nicht mehr ausüben kannst.",
        relevance: "Das Risiko einer Berufsunfähigkeit wird häufig unterschätzt.",
        watch: nil,
        fields: [],
        criteria: buCriteria,
        knowledgeArticles: []
    )

    static let krankenversicherungCategory = ContractCategory(
        key: "krankenversicherung",
        nameDE: "Krankenversicherung",
        nameEN: "Health Insurance",
        needsLevel: 1,
        purpose: "Deckt Kosten für Arztbesuche, Krankenhausaufenthalte und Medikamente.",
        relevance: "In Deutschland gesetzlich vorgeschrieben.",
        watch: nil,
        fields: [],
        criteria: [],
        knowledgeArticles: []
    )

    static let pflegeversicherungCategory = ContractCategory(
        key: "pflegeversicherung",
        nameDE: "Pflegeversicherung",
        nameEN: "Long-term Care Insurance",
        needsLevel: 1,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let risikolebensversicherungCategory = ContractCategory(
        key: "risikoleben",
        nameDE: "Risikolebensversicherung",
        nameEN: "Term Life Insurance",
        needsLevel: 1,
        fields: [], criteria: risikolebCriteria, knowledgeArticles: []
    )

    static let unfallversicherungCategory = ContractCategory(
        key: "unfallversicherung",
        nameDE: "Unfallversicherung",
        nameEN: "Accident Insurance",
        needsLevel: 1,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let hausratCategory = ContractCategory(
        key: "hausrat",
        nameDE: "Hausratversicherung",
        nameEN: "Contents Insurance",
        needsLevel: 1,
        fields: [], criteria: hausratCriteria, knowledgeArticles: []
    )

    static let wohngebaeudeCategory = ContractCategory(
        key: "wohngebaeude",
        nameDE: "Wohngebäudeversicherung",
        nameEN: "Building Insurance",
        needsLevel: 1,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let rechtsschutzCategory = ContractCategory(
        key: "rechtsschutz",
        nameDE: "Rechtsschutzversicherung",
        nameEN: "Legal Protection Insurance",
        needsLevel: 1,
        fields: [], criteria: rechtsschutzCriteria, knowledgeArticles: []
    )

    static let kfzCategory = ContractCategory(
        key: "kfz",
        nameDE: "Kfz-Versicherung",
        nameEN: "Motor Insurance",
        needsLevel: 1,
        fields: [], criteria: kfzCriteria, knowledgeArticles: []
    )

    static let tierhalterhaftpflichtCategory = ContractCategory(
        key: "tierhalterhaftpflicht",
        nameDE: "Tierhalterhaftpflicht",
        nameEN: "Animal Owner Liability",
        needsLevel: 1,
        fields: [], criteria: [], knowledgeArticles: []
    )

    // MARK: Level 2 — Provision & Wealth Building (noDuplicate types)

    static let liquiditaetsreserveCategory = ContractCategory(
        key: "liquiditaetsreserve",
        nameDE: "Liquiditätsreserve",
        nameEN: "Emergency Fund",
        needsLevel: 2,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let altersvorsorgeCategory = ContractCategory(
        key: "altersvorsorge",
        nameDE: "Altersvorsorge",
        nameEN: "Retirement Provision",
        needsLevel: 2,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let lebensversicherungCategory = ContractCategory(
        key: "lebensversicherung",
        nameDE: "Kapitallebensversicherung",
        nameEN: "Endowment Life Insurance",
        needsLevel: 2,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let immobilienfinanzierungCategory = ContractCategory(
        key: "immobilienfinanzierung",
        nameDE: "Immobilienfinanzierung",
        nameEN: "Property Financing",
        needsLevel: 2,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let bausparvertragCategory = ContractCategory(
        key: "bausparvertrag",
        nameDE: "Bausparvertrag",
        nameEN: "Building Savings Contract",
        needsLevel: 2,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let depotCategory = ContractCategory(
        key: "depot",
        nameDE: "Wertpapierdepot",
        nameEN: "Investment Account",
        needsLevel: 2,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let sparplanCategory = ContractCategory(
        key: "sparplan",
        nameDE: "Sparplan / ETF-Sparplan",
        nameEN: "Savings Plan / ETF Plan",
        needsLevel: 2,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let tagesgeldFestgeldCategory = ContractCategory(
        key: "tagesgeld_festgeld",
        nameDE: "Tagesgeld / Festgeld",
        nameEN: "Savings Account / Fixed Deposit",
        needsLevel: 2,
        fields: [], criteria: [], knowledgeArticles: []
    )

    // MARK: Level 3 — Supplements

    static let sterbegeldCategory = ContractCategory(
        key: "sterbegeld",
        nameDE: "Sterbegeldversicherung",
        nameEN: "Funeral Expense Insurance",
        needsLevel: 3,
        fields: [], criteria: [], knowledgeArticles: []
    )

    static let reiseversicherungCategory = ContractCategory(
        key: "reiseversicherung",
        nameDE: "Reiseversicherung",
        nameEN: "Travel Insurance",
        needsLevel: 3,
        fields: [], criteria: reiseCriteria, knowledgeArticles: []
    )

    static let krankentagegeldCategory = ContractCategory(
        key: "krankentagegeld",
        nameDE: "Krankentagegeld",
        nameEN: "Sick Pay Insurance",
        needsLevel: 3,
        fields: [], criteria: [], knowledgeArticles: []
    )

    // MARK: All Categories

    static let allCategories: [ContractCategory] = [
        privathaftpflichtCategory,
        berufsunfaehigkeitCategory,
        krankenversicherungCategory,
        pflegeversicherungCategory,
        risikolebensversicherungCategory,
        unfallversicherungCategory,
        hausratCategory,
        wohngebaeudeCategory,
        rechtsschutzCategory,
        kfzCategory,
        tierhalterhaftpflichtCategory,
        liquiditaetsreserveCategory,
        altersvorsorgeCategory,
        lebensversicherungCategory,
        immobilienfinanzierungCategory,
        bausparvertragCategory,
        depotCategory,
        sparplanCategory,
        tagesgeldFestgeldCategory,
        sterbegeldCategory,
        reiseversicherungCategory,
        krankentagegeldCategory
    ]

    // MARK: Criteria Fixtures

    static let privathaftpflichtCriteria: [ContractCriterion] = [
        ContractCriterion(key: "forderungsausfall", labelDE: "Forderungsausfalldeckung", labelEN: "Third-party claim cover"),
        ContractCriterion(key: "schluesselverlust", labelDE: "Schlüsselverlust", labelEN: "Key loss cover"),
        ContractCriterion(key: "ehrenamtlich", labelDE: "Ehrenamtliche Tätigkeit", labelEN: "Voluntary work cover"),
        ContractCriterion(key: "gewerblich", labelDE: "Gewerbliche Mitversicherung", labelEN: "Commercial co-insurance"),
        ContractCriterion(key: "tierschaden", labelDE: "Tierschäden an Mietobjekten", labelEN: "Animal damage to rented property"),
        ContractCriterion(key: "ausland", labelDE: "Weltweite Geltung", labelEN: "Worldwide cover"),
        ContractCriterion(key: "selbstbehalt_null", labelDE: "Kein Selbstbehalt", labelEN: "No excess"),
        ContractCriterion(key: "deckungssumme_50m", labelDE: "Deckungssumme ≥ 50 Mio.", labelEN: "Coverage ≥ 50M EUR")
    ]

    static let privathaftpflichtFields: [ContractFieldSpec] = [
        ContractFieldSpec(fieldKey: "coverageSum", labelDE: "Deckungssumme (EUR)", labelEN: "Coverage sum (EUR)", kind: .money, required: true, choices: []),
        ContractFieldSpec(fieldKey: "insuredPersons", labelDE: "Versicherte Personen", labelEN: "Insured persons", kind: .choice, required: true, choices: [
            ContractFieldChoice(key: "single", labelDE: "Einzelperson", labelEN: "Single"),
            ContractFieldChoice(key: "familie", labelDE: "Familie", labelEN: "Family")
        ])
    ]

    static let buCriteria: [ContractCriterion] = [
        ContractCriterion(key: "abstract", labelDE: "Abstrakter Verweis ausgeschlossen", labelEN: "No abstract referral"),
        ContractCriterion(key: "nachversicherung", labelDE: "Nachversicherungsgarantie", labelEN: "Guaranteed insurability"),
        ContractCriterion(key: "rueckwirkend", labelDE: "Rückwirkende Leistung", labelEN: "Retroactive benefit"),
        ContractCriterion(key: "weltweite_geltung", labelDE: "Weltweite Geltung", labelEN: "Worldwide cover"),
        ContractCriterion(key: "infektionsklausel", labelDE: "Infektionsschutzgesetz-Klausel", labelEN: "Infection protection clause")
    ]

    static let hausratCriteria: [ContractCriterion] = [
        ContractCriterion(key: "fahrrad", labelDE: "Fahrraddiebstahl", labelEN: "Bicycle theft"),
        ContractCriterion(key: "elementar", labelDE: "Elementarschäden", labelEN: "Elemental damage"),
        ContractCriterion(key: "grobe_fahrlassigkeit", labelDE: "Grobe Fahrlässigkeit mitversichert", labelEN: "Gross negligence covered"),
        ContractCriterion(key: "ueberspannung", labelDE: "Überspannungsschäden", labelEN: "Power surge damage"),
        ContractCriterion(key: "glasbruch", labelDE: "Glasbruch", labelEN: "Glass breakage")
    ]

    static let rechtsschutzCriteria: [ContractCriterion] = [
        ContractCriterion(key: "privatrecht", labelDE: "Privatrecht", labelEN: "Civil law"),
        ContractCriterion(key: "berufsrecht", labelDE: "Berufsrecht", labelEN: "Employment law"),
        ContractCriterion(key: "verkehrsrecht", labelDE: "Verkehrsrecht", labelEN: "Traffic law"),
        ContractCriterion(key: "mietrecht", labelDE: "Mietrecht", labelEN: "Rental law"),
        ContractCriterion(key: "steuerrecht", labelDE: "Steuerrecht", labelEN: "Tax law"),
        ContractCriterion(key: "strafrecht", labelDE: "Strafrechtsschutz", labelEN: "Criminal law protection")
    ]

    static let kfzCriteria: [ContractCriterion] = [
        ContractCriterion(key: "vollkasko", labelDE: "Vollkaskoversicherung", labelEN: "Comprehensive cover"),
        ContractCriterion(key: "rabattschutz", labelDE: "Rabattschutz", labelEN: "No-claims bonus protection"),
        ContractCriterion(key: "fahrerschutz", labelDE: "Fahrerschutzversicherung", labelEN: "Driver protection"),
        ContractCriterion(key: "mallorca", labelDE: "Mallorca-Police", labelEN: "Mallorca policy"),
        ContractCriterion(key: "pannenhilfe", labelDE: "Pannenhilfe inkl.", labelEN: "Breakdown assistance included"),
        ContractCriterion(key: "marderschaeden", labelDE: "Marderschäden", labelEN: "Marten damage"),
        ContractCriterion(key: "umweltschaden", labelDE: "Umweltschadendeckung", labelEN: "Environmental damage cover")
    ]

    static let risikolebCriteria: [ContractCriterion] = [
        ContractCriterion(key: "nachversicherung", labelDE: "Nachversicherungsgarantie", labelEN: "Guaranteed insurability"),
        ContractCriterion(key: "teilzahlungsoption", labelDE: "Teilzahlungsoption", labelEN: "Instalment option"),
        ContractCriterion(key: "umtausch_recht", labelDE: "Umtauschrecht", labelEN: "Conversion right"),
        ContractCriterion(key: "sofortleistung", labelDE: "Sofortleistung bei Diagnose", labelEN: "Immediate benefit on diagnosis"),
        ContractCriterion(key: "fallschirmspringen", labelDE: "Fallschirmspringen mitversichert", labelEN: "Skydiving covered")
    ]

    static let reiseCriteria: [ContractCriterion] = [
        ContractCriterion(key: "krankenruecktransport", labelDE: "Krankenrücktransport", labelEN: "Medical repatriation"),
        ContractCriterion(key: "reiseruecktritt", labelDE: "Reiserücktritt", labelEN: "Trip cancellation"),
        ContractCriterion(key: "gepaeck", labelDE: "Gepäckversicherung", labelEN: "Luggage cover"),
        ContractCriterion(key: "haftpflicht", labelDE: "Reise-Haftpflicht", labelEN: "Travel liability"),
        ContractCriterion(key: "auslandsrankenversicherung", labelDE: "Auslandskrankenversicherung", labelEN: "Travel health insurance")
    ]
}
