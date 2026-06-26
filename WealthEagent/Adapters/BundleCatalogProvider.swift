// BundleCatalogProvider.swift
// Adapters — implements CatalogProvider protocol with hard-coded Swift catalog data.
// Single source of truth for catalog content in the production app.
// Equivalent data is mirrored in MockCatalogProvider for tests.

import Foundation

// MARK: - BundleCatalogProvider

/// Implements CatalogProvider by returning a hard-coded Catalog built from Swift data.
/// Synchronous and pure — returns the same Catalog on every call.
final class BundleCatalogProvider: CatalogProvider {

    // MARK: - CatalogProvider

    func catalog() -> Catalog {
        Catalog(
            categories: Self.allCategories(),
            schemaVersion: "1.0"
        )
    }

    /// Verifies catalog is loadable at startup (no-op for hard-coded provider).
    func probe() throws {
        // Hard-coded catalog never fails to load.
    }

    // MARK: - Category builders

    static func allCategories() -> [ContractCategory] {
        [
            // Level 1 — Basisabsicherung (11)
            privathaftpflicht(),
            berufsunfaehigkeit(),
            krankenversicherung(),
            pflegeversicherung(),
            risikoleben(),
            unfallversicherung(),
            hausrat(),
            wohngebaeude(),
            rechtsschutz(),
            kfz(),
            tierhalterhaftpflicht(),
            // Level 2 — Vermögensaufbau & Vorsorge (8)
            liquiditaetsreserve(),
            altersvorsorge(),
            lebensversicherung(),
            immobilienfinanzierung(),
            bausparvertrag(),
            depot(),
            sparplan(),
            tagesgeld(),
            // Level 3 — Ergänzungen (3)
            sterbegeld(),
            reiseversicherung(),
            krankentagegeld()
        ]
    }

    // MARK: - Level 1

    private static func privathaftpflicht() -> ContractCategory {
        ContractCategory(
            key: "privathaftpflicht",
            nameDe: "Privathaftpflicht",
            nameEn: "Personal Liability",
            needsLevel: 1,
            purpose: "Schützt vor finanziellen Folgen, wenn du anderen Personen oder deren Eigentum Schaden zufügst.",
            relevance: "Ein einziger Haftpflichtschaden kann existenzbedrohend sein. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "Deckungssumme, grobe Fahrlässigkeit, Schlüsselverlust, Auslandsschutz.",
            fieldSpecs: phvFieldSpecs(),
            criteria: phvCriteria(),
            knowledgeArticles: []
        )
    }

    private static func berufsunfaehigkeit() -> ContractCategory {
        ContractCategory(
            key: "berufsunfaehigkeit",
            nameDe: "Berufsunfähigkeit",
            nameEn: "Disability Insurance",
            needsLevel: 1,
            purpose: "Sichert das Einkommen ab, wenn du deinen Beruf dauerhaft nicht mehr ausüben kannst.",
            relevance: "Einer der häufigsten Gründe für Altersarmut. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "Verzicht auf abstrakte Verweisung, AU-Klausel, Nachversicherungsgarantie.",
            fieldSpecs: [],
            criteria: buCriteria(),
            knowledgeArticles: []
        )
    }

    private static func krankenversicherung() -> ContractCategory {
        ContractCategory(
            key: "krankenversicherung",
            nameDe: "Krankenversicherung",
            nameEn: "Health Insurance",
            needsLevel: 1,
            purpose: "Übernimmt Kosten für medizinische Behandlungen.",
            relevance: "Pflichtversicherung in Deutschland. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "GKV vs. PKV, Zusatzleistungen, Selbstbeteiligung.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func pflegeversicherung() -> ContractCategory {
        ContractCategory(
            key: "pflegeversicherung",
            nameDe: "Pflegeversicherung",
            nameEn: "Long-term Care Insurance",
            needsLevel: 1,
            purpose: "Deckt Kosten für Pflege bei dauerhafter Pflegebedürftigkeit.",
            relevance: "Pflegelücke kann €2.000+/Monat betragen. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "Pflegegrad-Leistungen, Wartezeiten, Inflationsschutz.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func risikoleben() -> ContractCategory {
        ContractCategory(
            key: "risikoleben",
            nameDe: "Risikolebensversicherung",
            nameEn: "Term Life Insurance",
            needsLevel: 1,
            purpose: "Zahlt eine Summe an Hinterbliebene, wenn der Versicherungsnehmer stirbt.",
            relevance: "Wichtig für Haushalte mit Abhängigen oder Hypothek. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "Versicherungssumme, Laufzeit, Nachversicherungsgarantie.",
            fieldSpecs: [],
            criteria: rlvCriteria(),
            knowledgeArticles: []
        )
    }

    private static func unfallversicherung() -> ContractCategory {
        ContractCategory(
            key: "unfallversicherung",
            nameDe: "Unfallversicherung",
            nameEn: "Accident Insurance",
            needsLevel: 1,
            purpose: "Zahlt eine Kapitalleistung oder Rente bei dauerhafter Invalidität durch Unfall.",
            relevance: "Ergänzt BU für Risiken, die nicht berufsbedingt sind. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "Invaliditätssumme, Gliedertaxe, Eigenbewegungsschutz.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func hausrat() -> ContractCategory {
        ContractCategory(
            key: "hausrat",
            nameDe: "Hausratversicherung",
            nameEn: "Household Contents Insurance",
            needsLevel: 1,
            purpose: "Versichert den Hausrat gegen Feuer, Einbruch, Leitungswasser und Elementarschäden.",
            relevance: "Mobilien stellen oft mehrere Jahreseinkommen dar. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "Elementarschutz, grobe Fahrlässigkeit, Fahrraddiebstahl, Wertsachen-Limit.",
            fieldSpecs: [],
            criteria: hausratCriteria(),
            knowledgeArticles: []
        )
    }

    private static func wohngebaeude() -> ContractCategory {
        ContractCategory(
            key: "wohngebaeude",
            nameDe: "Wohngebäudeversicherung",
            nameEn: "Building Insurance",
            needsLevel: 1,
            purpose: "Versichert das Gebäude gegen Feuer, Sturm, Hagel, Leitungswasser und Elementarschäden.",
            relevance: "Pflicht für Eigentümer. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "Elementarschutz inklusive, grobe Fahrlässigkeit, Behördenmehrkosten.",
            fieldSpecs: [],
            criteria: wohngebaeuedeCriteria(),
            knowledgeArticles: []
        )
    }

    private static func rechtsschutz() -> ContractCategory {
        ContractCategory(
            key: "rechtsschutz",
            nameDe: "Rechtsschutzversicherung",
            nameEn: "Legal Expenses Insurance",
            needsLevel: 1,
            purpose: "Übernimmt Anwalts- und Gerichtskosten bei rechtlichen Auseinandersetzungen.",
            relevance: "Rechtsstreitigkeiten können schnell fünfstellig werden. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "Wartezeiten, Deckungssumme, Arbeitsrechtsschutz, Mietrechtsschutz.",
            fieldSpecs: [],
            criteria: rechtsschutzCriteria(),
            knowledgeArticles: []
        )
    }

    private static func kfz() -> ContractCategory {
        ContractCategory(
            key: "kfz",
            nameDe: "Kfz-Versicherung",
            nameEn: "Motor Insurance",
            needsLevel: 1,
            purpose: "Deckt Haftpflicht für Fahrzeugschäden und optional Kaskoschäden.",
            relevance: "Kfz-Haftpflicht ist in Deutschland Pflicht. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "Deckungssumme, grobe Fahrlässigkeit Kasko, Mallorca-Police, Neupreisentschädigung.",
            fieldSpecs: [],
            criteria: kfzCriteria(),
            knowledgeArticles: []
        )
    }

    private static func tierhalterhaftpflicht() -> ContractCategory {
        ContractCategory(
            key: "tierhalterhaftpflicht",
            nameDe: "Tierhalterhaftpflicht",
            nameEn: "Pet Liability Insurance",
            needsLevel: 1,
            purpose: "Deckt Schäden, die durch das eigene Tier an Dritten entstehen.",
            relevance: "Halter von Hunden und Pferden haften unbegrenzt für Tierschäden. Anerkannte Bedarfssystematik: Stufe 1.",
            watch: "Deckungssumme, Auslandsschutz.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    // MARK: - Level 2

    private static func liquiditaetsreserve() -> ContractCategory {
        ContractCategory(
            key: "liquiditaetsreserve",
            nameDe: "Liquiditätsreserve",
            nameEn: "Emergency Fund",
            needsLevel: 2,
            purpose: "Sofortverfügbares Kapital für ungeplante Ausgaben (3–6 Monatsnettogehälter).",
            relevance: "Verhindert Schulden bei unerwarteten Kosten. Anerkannte Bedarfssystematik: Stufe 2.",
            watch: "Höhe, Verfügbarkeit, Verzinsung.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func altersvorsorge() -> ContractCategory {
        ContractCategory(
            key: "altersvorsorge",
            nameDe: "Altersvorsorge",
            nameEn: "Retirement Provision",
            needsLevel: 2,
            purpose: "Baut Kapital für das Rentenalter auf.",
            relevance: "Die gesetzliche Rente allein reicht in der Regel nicht. Anerkannte Bedarfssystematik: Stufe 2.",
            watch: "Laufende Kosten (TER), Flexibilität, Renditechancen.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func lebensversicherung() -> ContractCategory {
        ContractCategory(
            key: "lebensversicherung",
            nameDe: "Lebensversicherung",
            nameEn: "Endowment Life Insurance",
            needsLevel: 2,
            purpose: "Kombination aus Todesfallschutz und Kapitalaufbau.",
            relevance: "Häufig aus Altverträgen; laufende Kosten prüfen. Anerkannte Bedarfssystematik: Stufe 2.",
            watch: "Laufende Kosten, garantierter Zins, Flexibilität.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func immobilienfinanzierung() -> ContractCategory {
        ContractCategory(
            key: "immobilienfinanzierung",
            nameDe: "Immobilienfinanzierung",
            nameEn: "Property Financing",
            needsLevel: 2,
            purpose: "Finanziert den Kauf oder Bau einer Immobilie.",
            relevance: "Größte Einzelverbindlichkeit für viele Haushalte. Anerkannte Bedarfssystematik: Stufe 2.",
            watch: "Zinsbindung, Tilgungsrate, Sondertilgungsrecht.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func bausparvertrag() -> ContractCategory {
        ContractCategory(
            key: "bausparvertrag",
            nameDe: "Bausparvertrag",
            nameEn: "Building Society Contract",
            needsLevel: 2,
            purpose: "Spart zinssicher Kapital für Immobilienerwerb oder -renovierung an.",
            relevance: "Staatlich gefördert über Wohnungsbauprämie. Anerkannte Bedarfssystematik: Stufe 2.",
            watch: "Sparzins, Darlehenszins, Abschlussgebühr.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func depot() -> ContractCategory {
        ContractCategory(
            key: "depot",
            nameDe: "Depot",
            nameEn: "Investment Portfolio",
            needsLevel: 2,
            purpose: "Verwahrt und verwaltet Wertpapiere (Aktien, ETFs, Fonds).",
            relevance: "Wichtigster Kanal für langfristigen Vermögensaufbau. Anerkannte Bedarfssystematik: Stufe 2.",
            watch: "Laufende Kosten (TER), Depotgebühren, Anlagepolitik.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func sparplan() -> ContractCategory {
        ContractCategory(
            key: "sparplan",
            nameDe: "Sparplan",
            nameEn: "Savings Plan",
            needsLevel: 2,
            purpose: "Regelmäßige Einzahlungen in Fonds oder ETFs (Cost Averaging).",
            relevance: "Disziplinierter Aufbau von Vermögen über Zeit. Anerkannte Bedarfssystematik: Stufe 2.",
            watch: "Ausführungsgebühren, Mindestrate, Produktauswahl.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func tagesgeld() -> ContractCategory {
        ContractCategory(
            key: "tagesgeld_festgeld",
            nameDe: "Tagesgeld / Festgeld",
            nameEn: "Savings / Fixed-term Deposit",
            needsLevel: 2,
            purpose: "Kurz- bis mittelfristige Zinsanlage mit hoher Verfügbarkeit (Tagesgeld) oder Laufzeitbindung (Festgeld).",
            relevance: "Sicherheitspuffer und Renditepuffer im Niedrigzinsumfeld. Anerkannte Bedarfssystematik: Stufe 2.",
            watch: "Zinssatz, Einlagensicherung, Laufzeit.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    // MARK: - Level 3

    private static func sterbegeld() -> ContractCategory {
        ContractCategory(
            key: "sterbegeld",
            nameDe: "Sterbegeldversicherung",
            nameEn: "Funeral Cost Insurance",
            needsLevel: 3,
            purpose: "Finanziert Bestattungskosten.",
            relevance: "Entlastet Hinterbliebene von Bestattungskosten. Anerkannte Bedarfssystematik: Stufe 3.",
            watch: "Versicherungssumme, Wartezeit, Beitragsverlauf.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    private static func reiseversicherung() -> ContractCategory {
        ContractCategory(
            key: "reiseversicherung",
            nameDe: "Reiseversicherung",
            nameEn: "Travel Insurance",
            needsLevel: 3,
            purpose: "Deckt Stornierungskosten und medizinische Notfälle im Ausland.",
            relevance: "Auslandsbehandlungen und Rücktransport können sehr teuer sein. Anerkannte Bedarfssystematik: Stufe 3.",
            watch: "Reisekranken, Rücktritt, Rückholung, Vorerkrankungen.",
            fieldSpecs: [],
            criteria: reiseCriteria(),
            knowledgeArticles: []
        )
    }

    private static func krankentagegeld() -> ContractCategory {
        ContractCategory(
            key: "krankentagegeld",
            nameDe: "Krankentagegeld",
            nameEn: "Daily Sickness Benefit",
            needsLevel: 3,
            purpose: "Zahlt bei längerer Krankheit ein Tagegeld, wenn der Arbeitgeber nicht mehr zahlt.",
            relevance: "Relevant für Selbstständige und Arbeitnehmer mit niedrigem Krankengeld. Anerkannte Bedarfssystematik: Stufe 3.",
            watch: "Wartezeit, Karenztage, Höhe des Tagegeldes.",
            fieldSpecs: [],
            criteria: [],
            knowledgeArticles: []
        )
    }

    // MARK: - Field specs

    private static func phvFieldSpecs() -> [ContractFieldSpec] {
        [
            ContractFieldSpec(fieldKey: "coverage_sum", labelDe: "Deckungssumme", labelEn: "Coverage sum", kind: .money, required: true, choices: []),
            ContractFieldSpec(fieldKey: "insured_persons", labelDe: "Versicherte Personen", labelEn: "Insured persons", kind: .choice, required: true, choices: [
                ContractFieldChoice(value: "single", labelDe: "Einzelperson", labelEn: "Single"),
                ContractFieldChoice(value: "family", labelDe: "Familie", labelEn: "Family")
            ])
        ]
    }

    // MARK: - Criteria builders

    private static func phvCriteria() -> [ContractCriterion] {
        [
            ContractCriterion(key: "min_coverage_sum", labelDe: "Mindestdeckungssumme", labelEn: "Minimum coverage sum", whyItMatters: "Gut-Tarife decken mindestens 50 Mio. € (Franke & Bornberg 2025)."),
            ContractCriterion(key: "gradual_damage", labelDe: "Allmählichkeitsschäden", labelEn: "Gradual damage", whyItMatters: "Schäden, die sich über Zeit entwickeln, sind nicht automatisch versichert."),
            ContractCriterion(key: "gross_negligence_waiver", labelDe: "Verzicht auf grobe Fahrlässigkeit", labelEn: "Gross negligence waiver", whyItMatters: "Ohne diese Klausel kann der Versicherer die Leistung kürzen."),
            ContractCriterion(key: "lost_key_cover", labelDe: "Schlüsselverlust", labelEn: "Lost-key cover", whyItMatters: "Verlust von Haus- oder Fahrzeugschlüsseln kann teure Schloss-Austauschaktionen auslösen."),
            ContractCriterion(key: "volunteer_work", labelDe: "Ehrenamt", labelEn: "Volunteer work cover", whyItMatters: "Schäden beim Ehrenamt sind nicht automatisch mitversichert."),
            ContractCriterion(key: "tenant_damage", labelDe: "Mietsachschäden", labelEn: "Tenant property damage", whyItMatters: "Schäden an gemieteten Wohnungen oder Ferienhäusern müssen explizit eingeschlossen sein."),
            ContractCriterion(key: "overseas_cover", labelDe: "Auslandsschutz", labelEn: "Overseas cover", whyItMatters: "Voller Versicherungsschutz muss auch temporär im Ausland gelten."),
            ContractCriterion(key: "pet_sitting", labelDe: "Hütekind-Haftung", labelEn: "Pet-sitting liability", whyItMatters: "Haftet man für einen fremden Hund oder ein fremdes Pferd, greift die normale Tierhalterhaftpflicht nicht."),
            ContractCriterion(key: "contingency_cover", labelDe: "Vorsorgeversicherung", labelEn: "Contingency cover", whyItMatters: "Überbrückungsschutz für neue Risiken bis zur Zeichnung einer Spezialpolice."),
            ContractCriterion(key: "e_mobility", labelDe: "E-Mobilität", labelEn: "E-mobility coverage", whyItMatters: "Schäden durch Wallboxen, E-Scooter und E-Bikes sind nicht automatisch enthalten.")
        ]
    }

    private static func buCriteria() -> [ContractCriterion] {
        [
            ContractCriterion(key: "no_abstract_referral", labelDe: "Verzicht auf abstrakte Verweisung", labelEn: "No abstract referral", whyItMatters: "Ohne Verzicht kann der Versicherer die Rente verweigern, wenn theoretisch ein anderer Beruf ausübbar wäre."),
            ContractCriterion(key: "six_month_prognosis", labelDe: "6-Monats-Prognose", labelEn: "Six-month prognosis clause", whyItMatters: "Leistung wird fällig, wenn die BU voraussichtlich 6 Monate andauert."),
            ContractCriterion(key: "retrospective_payment", labelDe: "Rückwirkende Leistung", labelEn: "Retrospective benefit payment", whyItMatters: "Renten werden ab Beginn der BU gezahlt, bis zu 3 Jahre rückwirkend."),
            ContractCriterion(key: "post_notification_waiver", labelDe: "Verzicht auf Mitteilungspflicht", labelEn: "Waiver of notification obligation", whyItMatters: "Fehlende Meldungen können zur Leistungsverweigerung führen."),
            ContractCriterion(key: "nachversicherung", labelDe: "Nachversicherungsgarantie", labelEn: "Guaranteed increase option", whyItMatters: "Rentenerhöhung nach Lebensereignissen ohne erneute Gesundheitsprüfung."),
            ContractCriterion(key: "au_clause", labelDe: "AU-Klausel", labelEn: "Incapacity-to-work bridge", whyItMatters: "Zahlung bereits nach 3–4 Monaten Arbeitsunfähigkeit."),
            ContractCriterion(key: "profession_recheck", labelDe: "Günstigerprüfung", labelEn: "Most-favourable profession check", whyItMatters: "Berufseinstufung wird bei Verlängerung nicht schlechter gestellt."),
            ContractCriterion(key: "benefit_dynamics", labelDe: "Garantierte Leistungsdynamik", labelEn: "Guaranteed benefit increase", whyItMatters: "Jährliche Rentenanpassung schützt vor Kaufkraftverlust."),
            ContractCriterion(key: "health_question_period", labelDe: "Gesundheitsfragenzeitraum", labelEn: "Health disclosure look-back period", whyItMatters: "Kurze Rückfragezeiträume bedeuten weniger Anfechtungsrisiko."),
            ContractCriterion(key: "no_reapplication_disclosure", labelDe: "Kein Antragsstatus", labelEn: "No prior-application disclosure", whyItMatters: "Vermeidet Benachteiligung durch frühere Ablehnungen.")
        ]
    }

    private static func hausratCriteria() -> [ContractCriterion] {
        [
            ContractCriterion(key: "elementar_cover", labelDe: "Elementarschäden", labelEn: "Natural hazard cover", whyItMatters: "Starkregen, Überschwemmung, Erdrutsch sind im Basisschutz nicht automatisch enthalten."),
            ContractCriterion(key: "gross_negligence_waiver", labelDe: "Grobe Fahrlässigkeit", labelEn: "Gross negligence waiver", whyItMatters: "Tarife, die bei grober Fahrlässigkeit kürzen, werden von Stiftung Warentest sofort abgewertet."),
            ContractCriterion(key: "overvoltage_cover", labelDe: "Überspannungsschäden", labelEn: "Overvoltage cover", whyItMatters: "Blitzschlag-induzierte Überspannungen beschädigen Elektronik."),
            ContractCriterion(key: "valuables_limit", labelDe: "Wertsachen-Limit", labelEn: "Valuables sub-limit", whyItMatters: "Mindest 20 % der Versicherungssumme für Wertsachen ist Stiftung Warentest-Standard."),
            ContractCriterion(key: "bicycle_theft", labelDe: "Fahrraddiebstahl", labelEn: "Bicycle theft", whyItMatters: "Fahrräder sind vom Hausrat oft ausgenommen."),
            ContractCriterion(key: "temp_housing_costs", labelDe: "Hotelkosten", labelEn: "Temporary housing costs", whyItMatters: "Unbewohnbare Wohnung nach Schaden — Unterbringungskosten sollten gedeckt sein."),
            ContractCriterion(key: "heat_scorch_damage", labelDe: "Sengschäden", labelEn: "Heat / scorch damage", whyItMatters: "Schäden durch Hitze ohne offene Flamme sind nicht automatisch versichert."),
            ContractCriterion(key: "provisional_cover", labelDe: "Vorsorgeversicherung", labelEn: "Advance cover", whyItMatters: "Schutz vor Unterversicherung durch Neuanschaffungen."),
            ContractCriterion(key: "garden_furniture_theft", labelDe: "Gartendiebstahl", labelEn: "Garden furniture theft", whyItMatters: "Gartenmöbel im Außenbereich sind ohne expliziten Einschluss nicht abgesichert."),
            ContractCriterion(key: "mobility_aid_theft", labelDe: "Hilfsmitteldiebstahl", labelEn: "Mobility-aid / pram theft", whyItMatters: "Diebstahl von Rollstühlen, Rollatoren und Kinderwagen auf dem Grundstück.")
        ]
    }

    private static func kfzCriteria() -> [ContractCriterion] {
        [
            ContractCriterion(key: "high_liability_limit", labelDe: "Hohe Deckungssumme", labelEn: "High liability limit", whyItMatters: "Mind. 100 Mio. € Deckungssumme (Stiftung Warentest)."),
            ContractCriterion(key: "mallorca_policy", labelDe: "Mallorca-Police", labelEn: "Mallorca / abroad rental cover", whyItMatters: "Erweitert Haftpflichtschutz auf Mietwagen im Ausland."),
            ContractCriterion(key: "animal_bite_followup", labelDe: "Tierbissfolgeschäden", labelEn: "Animal-bite consequential damage", whyItMatters: "Schäden durch Tierbiss an Kabeln und Schläuchen."),
            ContractCriterion(key: "extended_wildlife", labelDe: "Erweiterter Wildschadenschutz", labelEn: "Extended wildlife cover", whyItMatters: "Standard deckt nur Haarwild — gute Tarife decken alle Wirbeltiere."),
            ContractCriterion(key: "gross_negligence_waiver", labelDe: "Grobe Fahrlässigkeit Kasko", labelEn: "Gross negligence waiver (Kasko)", whyItMatters: "Ohne diese Klausel kürzt der Versicherer bei Unachtsamkeit."),
            ContractCriterion(key: "new_car_replacement", labelDe: "Neupreisentschädigung", labelEn: "New-car replacement value", whyItMatters: "Vollkasko zahlt bei Totalschaden den Neupreis statt des Zeitwerts."),
            ContractCriterion(key: "no_claims_buyback", labelDe: "Schadenrückkauf", labelEn: "No-claims buyback", whyItMatters: "Ermöglicht, einen Schaden selbst zu bezahlen, um die SF-Klasse zu erhalten."),
            ContractCriterion(key: "discount_protection", labelDe: "Rabattschutz", labelEn: "Discount / no-claims protection", whyItMatters: "Ein selbstverschuldeter Unfall führt nicht zur SF-Rückstufung."),
            ContractCriterion(key: "ev_battery_cover", labelDe: "Akkudeckung", labelEn: "EV battery cover", whyItMatters: "Deckung für Akkuschutz, Ladeausrüstung und Wallbox-Schäden."),
            ContractCriterion(key: "breakdown_cover", labelDe: "Pannenhilfe", labelEn: "Breakdown assistance", whyItMatters: "Pannenhilfe und Abschleppkosten sind in vielen Basistarifen nicht enthalten.")
        ]
    }

    private static func rechtsschutzCriteria() -> [ContractCriterion] {
        [
            ContractCriterion(key: "no_waiting_period", labelDe: "Kein Wartefrist (Verkehr)", labelEn: "No waiting period (traffic)", whyItMatters: "Tarife, die generell auf Wartezeiten verzichten, sind vorzuziehen."),
            ContractCriterion(key: "short_employment_wait", labelDe: "Kurze Wartezeit Arbeitsrecht", labelEn: "Short employment-law waiting period", whyItMatters: "Standard ist 3 Monate (allgemein), 6 Monate (Arbeitsrecht)."),
            ContractCriterion(key: "high_coverage_sum", labelDe: "Hohe Deckungssumme", labelEn: "High coverage sum", whyItMatters: "Mindestens 1 Mio. € Deckungssumme pro Rechtsfall."),
            ContractCriterion(key: "employment_law", labelDe: "Arbeitsrechtsschutz", labelEn: "Employment law cover", whyItMatters: "Schutz bei Kündigung, Abmahnung und Lohnstreitigkeiten."),
            ContractCriterion(key: "tenant_law", labelDe: "Mietrechtsschutz", labelEn: "Tenant law cover", whyItMatters: "Streit mit Vermieter über Nebenkostenabrechnung oder Kündigung."),
            ContractCriterion(key: "traffic_law", labelDe: "Verkehrsrechtsschutz", labelEn: "Traffic law cover", whyItMatters: "Schutz bei Bußgeldbescheiden, Kfz-Kaufstreitigkeiten und Unfallschadensersatz."),
            ContractCriterion(key: "social_law", labelDe: "Sozialrechtsschutz", labelEn: "Social-law cover", whyItMatters: "Streit mit Behörden über Sozialleistungen, Rente oder Krankenkasse."),
            ContractCriterion(key: "ombudsman_access", labelDe: "Ombudsmann-Teilnahme", labelEn: "Insurance ombudsman access", whyItMatters: "Ermöglicht kostenlose außergerichtliche Streitbeilegung."),
            ContractCriterion(key: "claims_handling_quality", labelDe: "Regulierungsverhalten", labelEn: "Claims handling quality", whyItMatters: "Stiftung Warentest erhebt Versichererdaten zum Regulierungsverhalten."),
            ContractCriterion(key: "family_cover", labelDe: "Familienmitversicherung", labelEn: "Family member cover", whyItMatters: "Partner, Kinder und Haushaltsmitglieder sind beitragsfrei mitversichert.")
        ]
    }

    private static func rlvCriteria() -> [ContractCriterion] {
        [
            ContractCriterion(key: "guaranteed_increase_option", labelDe: "Nachversicherungsgarantie", labelEn: "Guaranteed increase option", whyItMatters: "Versicherungssumme kann bei Lebensereignissen ohne erneute Gesundheitsprüfung erhöht werden."),
            ContractCriterion(key: "property_purchase_trigger", labelDe: "Immobilienkauf-Aufstockung", labelEn: "Property purchase increase", whyItMatters: "Explizite Garantie zur Erhöhung bei Immobilienfinanzierung."),
            ContractCriterion(key: "accelerated_death_benefit", labelDe: "Vorgezogene Todesfallleistung", labelEn: "Accelerated death benefit", whyItMatters: "Auszahlung bereits bei einer Lebenserwartung unter 12 Monate."),
            ContractCriterion(key: "flexible_term_extension", labelDe: "Flexible Laufzeitverlängerung", labelEn: "Flexible term extension", whyItMatters: "Laufzeit kann verlängert werden ohne erneute Gesundheitsprüfung."),
            ContractCriterion(key: "premium_pause", labelDe: "Beitragsstundung", labelEn: "Premium pause / payment relief", whyItMatters: "Kurzfristige Zahlungsschwierigkeiten führen nicht sofort zum Policenverfall."),
            ContractCriterion(key: "annuity_conversion", labelDe: "Rentenumwandlung", labelEn: "Annuity conversion option", whyItMatters: "Option, die Todesfallsumme in eine Rente umzuwandeln."),
            ContractCriterion(key: "decreasing_sum", labelDe: "Fallende Versicherungssumme", labelEn: "Decreasing sum insured", whyItMatters: "Parallele Abnahme zur Restschuld der Hypothek — günstigere Prämie."),
            ContractCriterion(key: "no_interest_cap", labelDe: "Kein Zinscap", labelEn: "No interest-rate cap (surplus)", whyItMatters: "Tarife mit Zinsobergrenze können Überschussbeteiligungen begrenzen.")
        ]
    }

    private static func wohngebaeuedeCriteria() -> [ContractCriterion] {
        [
            ContractCriterion(key: "elementar_included", labelDe: "Elementarschutz inklusive", labelEn: "Elementary hazard cover included", whyItMatters: "Stiftung Warentest nimmt nur Tarife in den Test, die Elementarschutz enthalten."),
            ContractCriterion(key: "gross_negligence_waiver", labelDe: "Verzicht auf grobe Fahrlässigkeit", labelEn: "Gross negligence waiver", whyItMatters: "Das wichtigste Einzelkriterium — Tarife ohne Verzicht erhalten sofort 'mangelhaft'."),
            ContractCriterion(key: "demolition_cleanup_costs", labelDe: "Abbruch- und Aufräumkosten", labelEn: "Demolition and cleanup costs", whyItMatters: "Abrisskosten nach Totalschaden sind ein häufig unterschätzter Kostenfaktor."),
            ContractCriterion(key: "regulatory_surcharge", labelDe: "Behördliche Mehrkosten", labelEn: "Regulatory surcharge cover", whyItMatters: "Behördliche Auflagen können Wiederaufbau verteuern."),
            ContractCriterion(key: "hotel_costs", labelDe: "Hotelkosten", labelEn: "Temporary accommodation", whyItMatters: "Übernachtungskosten bei vorübergehend unbewohnbarem Gebäude."),
            ContractCriterion(key: "pipe_freeze_break", labelDe: "Frost- und Rohrbruch auf Grundstück", labelEn: "Pipe freeze / break on property", whyItMatters: "Ableitungsrohre außerhalb des Gebäudes sind nicht automatisch mitversichert."),
            ContractCriterion(key: "overvoltage_lightning", labelDe: "Überspannung durch Blitz", labelEn: "Overvoltage / lightning surge", whyItMatters: "Blitzinduzierte Überspannung beschädigt Elektroinstallationen."),
            ContractCriterion(key: "advance_cover", labelDe: "Vorsorgeversicherung Gebäude", labelEn: "Advance / contingency cover", whyItMatters: "Automatischer Schutz bei Umbau oder Erweiterungen."),
            ContractCriterion(key: "expert_costs", labelDe: "Sachverständigenkosten", labelEn: "Expert witness costs", whyItMatters: "Kosten für Gutachter bei Streit über Schadenhöhe werden übernommen."),
            ContractCriterion(key: "energy_efficient_rebuild", labelDe: "Energieeffizienter Wiederaufbau", labelEn: "Energy-efficient rebuild cover", whyItMatters: "Mehrkosten für energetisch bessere Bauweise beim Wiederaufbau werden erstattet.")
        ]
    }

    private static func reiseCriteria() -> [ContractCriterion] {
        [
            ContractCriterion(key: "medical_costs_unlimited", labelDe: "Unbegrenzte Heilkosten", labelEn: "Unlimited medical cost cover", whyItMatters: "Auslandsbehandlungen können extrem teuer werden."),
            ContractCriterion(key: "medical_repatriation", labelDe: "Medizinischer Rücktransport", labelEn: "Medical repatriation", whyItMatters: "Einer der teuersten Einzelschäden — Pflichtkriterium."),
            ContractCriterion(key: "search_rescue", labelDe: "Such- und Rettungskosten", labelEn: "Search and rescue costs", whyItMatters: "Mind. 10.000 € Deckung wird von Stiftung Warentest gefordert."),
            ContractCriterion(key: "pre_existing_condition", labelDe: "Vorerkrankungen", labelEn: "Pre-existing condition cover", whyItMatters: "Plötzliche Verschlechterung einer Vorerkrankung im Urlaub."),
            ContractCriterion(key: "no_deductible", labelDe: "Keine Selbstbeteiligung", labelEn: "No deductible", whyItMatters: "Stiftung Warentest fordert Tarife ohne Selbstbeteiligung.")
        ]
    }
}
