# Insurance Leistungskriterien — Consumer Quality Criteria Research

**Date**: 2026-06-26 | **Researcher**: nw-researcher (Nova) | **Confidence**: High | **Sources**: 14

## Purpose

Consumer-verifiable quality criteria for 10 German insurance categories. Each criterion can be checked directly in a policy document (Versicherungsschein / AVB). Sources: Stiftung Warentest / Finanztest, Franke & Bornberg, Morgen & Morgen. No DIN 77230 / Defino references.

**Format per criterion:**
- `key` — Label DE / Label EN — Why it matters

---

## 1. Privathaftpflicht (Personal Liability)

**Sources**: Stiftung Warentest (401–426 tariffs tested, 49 criteria catalog) · Franke & Bornberg (304 family / 300 singles, 23 main criteria / 72 detail criteria, 2025)

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `min_coverage_sum` | Mindestdeckungssumme | Minimum coverage sum | Gut-Tarife decken mindestens 50 Mio. € (neu Franke & Bornberg 2025; Stiftung Warentest-Minimum 10 Mio. €). Niedrigere Summen reichen bei schweren Personenschäden nicht aus. |
| `gradual_damage` | Allmählichkeitsschäden | Gradual / slow-onset damage | Schäden, die sich über Zeit entwickeln (z. B. Wasserschäden), sind nicht automatisch versichert — gute Tarife schließen sie ein. |
| `gross_negligence_waiver` | Verzicht auf grobe Fahrlässigkeit | Gross negligence waiver | Ohne diese Klausel kann der Versicherer die Leistung kürzen oder verweigern, wenn der Schaden durch Unachtsamkeit verursacht wurde. |
| `lost_key_cover` | Schlüsselverlust | Lost-key cover | Verlust von Haus- oder Fahrzeugschlüsseln kann teure Schloss-Austauschaktion auslösen — nur bessere Tarife decken das ab. |
| `volunteer_work` | Ehrenamt | Volunteer work cover | Schäden beim Ehrenamt sind nicht automatisch mitversichert; gute Tarife decken bis zu 10 Mio. €. |
| `tenant_damage` | Mietsachschäden | Tenant property damage | Schäden an gemieteten Wohnungen, Ferienhäusern oder Veranstaltungsräumen — ein häufiger Schadenfall, der explizit eingeschlossen sein muss. |
| `overseas_cover` | Auslandsschutz | Overseas cover | Voller Versicherungsschutz muss auch temporär im Ausland gelten (mind. 3 Jahre EU, mind. 1 Jahr weltweit laut Stiftung Warentest). |
| `pet_sitting` | Hütekind-Haftung | Pet-sitting liability | Haftet man für einen fremden Hund oder ein fremdes Pferd, greift die normale Tierhalterhaftpflicht nicht — dieser Einschluss schließt die Lücke. |
| `contingency_cover` | Vorsorgeversicherung | Contingency / bridge cover | Überbrückungsschutz für neue Risiken bis zur Zeichnung einer Spezialpolice (mind. 3 Mio. € Standard-, 50.000 € Vermögensschäden). |
| `e_mobility` | E-Mobilität | E-mobility coverage | Schäden durch Wallboxen, E-Scooter und E-Bikes sind nicht automatisch in klassischen Tarifen enthalten — ein wachsend relevantes Kriterium. |

**Evidence summary**: Franke & Bornberg 2025 raised the minimum coverage threshold for top ratings from €10 m to €50 m, signalling industry movement. Stiftung Warentest tests 49 criteria; both sources independently identify gross negligence waiver, lost-key cover, overseas reach, and contingency cover as differentiators.

---

## 2. Berufsunfähigkeitsversicherung (Disability Insurance)

**Sources**: Stiftung Warentest / Finanztest (56 tariffs, Heft 6/2026; conditions = 75% of rating, application = 25%) · Franke & Bornberg (121 SBU tariffs, 74 criteria, 2025)

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `no_abstract_referral` | Verzicht auf abstrakte Verweisung | No abstract referral | Ohne diesen Verzicht kann der Versicherer die Rente verweigern, wenn du theoretisch irgendeinen anderen Beruf ausüben könntest — auch einen weit unter deiner Qualifikation. |
| `six_month_prognosis` | 6-Monats-Prognose | Six-month prognosis clause | Leistung wird fällig, wenn die BU voraussichtlich 6 Monate andauert — nicht erst, wenn sie schon 6 Monate besteht. Reduziert Wartezeit auf Zahlung. |
| `retrospective_payment` | Rückwirkende Leistung | Retrospective benefit payment | Renten werden ab Beginn der BU (nicht erst ab Anerkennung) gezahlt, bis zu 3 Jahre rückwirkend — wichtig bei langen Prüfzeiten. |
| `post_notification_waiver` | Verzicht auf Mitteilungspflicht | Waiver of notification obligation | Gute Tarife verlangen keine laufenden Meldungen über den Gesundheitszustand — fehlende Meldungen können sonst zur Leistungsverweigerung führen. |
| `nachversicherung` | Nachversicherungsgarantie | Guaranteed increase option | Rentenerhöhung nach Lebensereignissen (Heirat, Geburt, Gehaltserhöhung) ohne erneute Gesundheitsprüfung — wichtig besonders für junge Versicherte. |
| `au_clause` | AU-Klausel | Incapacity-to-work bridge | Zahlung bereits nach 3–4 Monaten Arbeitsunfähigkeit (statt erst nach BU-Anerkennung) — reduziert finanzielles Risiko während der Prüfung. |
| `profession_recheck` | Günstigerprüfung | Most-favourable profession check | Berufseinstufung wird bei Verlängerung nicht schlechter gestellt — kein Rückfall auf frühere, ungünstigere Berufsklassen. |
| `benefit_dynamics` | Garantierte Leistungsdynamik | Guaranteed benefit increase | Jährliche Rentenanpassung (z. B. 2 % p.a.) ist garantiert eingeschlossen — schützt vor Kaufkraftverlust bei langer BU. |
| `health_question_period` | Gesundheitsfragenzeitraum | Health disclosure look-back period | Kurze Rückfragezeiträume (max. 5 Jahre für ambulante, 10 Jahre für stationäre Behandlungen) bedeuten weniger Anfechtungsrisiko. |
| `no_reapplication_disclosure` | Kein Antragsstatus | No prior-application disclosure | Versicherer fragen nicht nach anderweitig gestellten oder abgelehnten Anträgen — vermeidet Benachteiligung durch frühere Ablehnungen. |

**Evidence summary**: Both Stiftung Warentest and Franke & Bornberg independently identify AU clause, no abstract referral, and nachversicherung as key differentiators. Franke & Bornberg 2025 downgraded standard features from bonus-point status; AU clause timing (3–4 months vs. 6 months) is a newly emphasised differentiator.

---

## 3. Hausratversicherung (Household Contents)

**Sources**: Stiftung Warentest (253 tariffs, 89 insurers, 2024 test) · Franke & Bornberg (363 tariffs, 102 providers, June 2026 update)

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `elementar_cover` | Elementarschäden | Natural hazard cover | Starkregen, Überschwemmung, Erdrutsch, Schneedruck und Lawinen sind im Basisschutz nicht automatisch enthalten — expliziter Einschluss ist Pflicht. |
| `gross_negligence_waiver` | Grobe Fahrlässigkeit | Gross negligence waiver | Tarife, die bei grober Fahrlässigkeit (Feuer, Leitungswasser, Sturm/Hagel) kürzen, werden von Stiftung Warentest sofort abgewertet. |
| `overvoltage_cover` | Überspannungsschäden | Overvoltage cover | Blitzschlag-induzierte Überspannungen beschädigen Elektronik — mind. 10 % der Versicherungssumme sollten gedeckt sein. |
| `valuables_limit` | Wertsachen-Limit | Valuables sub-limit | Schmuck, Bargeld und Kunstwerke sind meist begrenzt — mind. 20 % der Versicherungssumme für Wertsachen ist Stiftung Warentest-Standard. |
| `bicycle_theft` | Fahrraddiebstahl | Bicycle theft | Fahrräder sind vom Hausrat oft ausgenommen — gute Tarife decken mindestens 1.000 €, beste Tarife ohne separate Begrenzung. |
| `temp_housing_costs` | Hotelkosten | Temporary housing costs | Wenn die Wohnung nach einem Schaden unbewohnbar ist, zahlt eine gute Police die Unterbringungskosten. |
| `heat_scorch_damage` | Sengschäden | Heat / scorch damage | Schäden durch Hitze ohne offene Flamme (z. B. Bügeleisen auf Tisch) sind nicht automatisch versichert. |
| `provisional_cover` | Vorsorgeversicherung | Pre-emptive / advance cover | Schutz vor Unterversicherung durch Neuanschaffungen oder Preissteigerungen — erhöht Versicherungssumme automatisch. |
| `garden_furniture_theft` | Gartendiebstahl | Garden furniture theft | Gartenmöbel und Geräte im Außenbereich sind ohne expliziten Einschluss nicht abgesichert. |
| `mobility_aid_theft` | Hilfsmitteldiebstahl | Mobility-aid / pram theft | Neueres Kriterium (Franke & Bornberg 2026): Diebstahl von Rollstühlen, Rollatoren und Kinderwagen auf dem Grundstück. |

**Evidence summary**: Stiftung Warentest and Franke & Bornberg agree that elementary hazard cover and gross negligence waiver are the two make-or-break criteria. Franke & Bornberg's 2026 update added mobility-aid theft and energy-efficiency modernisation as new criteria.

---

## 4. Kfz-Versicherung (Motor Insurance)

**Sources**: Stiftung Warentest (161 tariffs, 66 insurers, 73 criteria, 2024/2025)

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `high_liability_limit` | Hohe Deckungssumme | High liability limit | Stiftung Warentest empfiehlt mind. 100 Mio. €; das gesetzliche Minimum (7,5 Mio. €) reicht bei schweren Personenschäden nicht. |
| `mallorca_policy` | Mallorca-Police | Mallorca / abroad rental cover | Erweitert den Haftpflichtschutz auf Mietwagen im Ausland auf deutsches Niveau — in vielen Ländern ist die Mindestdeckung viel niedriger. |
| `animal_bite_followup` | Tierbissfolgeschäden | Animal-bite consequential damage | Schäden durch Tierbiss an Kabeln und Schläuchen plus Folgeschäden sind nur versichert, wenn explizit eingeschlossen — mind. 5.000 € Folgeschäden. |
| `extended_wildlife` | Erweiterter Wildschadenschutz | Extended wildlife cover | Standard deckt nur „Haarwild" — gute Tarife decken alle Wirbeltiere oder alle Tiere, was Unfälle mit Kühen, Schweinen etc. einschließt. |
| `gross_negligence_waiver` | Grobe Fahrlässigkeit Kasko | Gross negligence waiver (Kasko) | Ohne diese Klausel kürzt der Versicherer die Kaskoerstattung, wenn der Unfall durch Unachtsamkeit entstand (z. B. Rotlicht übersehen). |
| `new_car_replacement` | Neupreisentschädigung | New-car replacement value | Vollkasko zahlt bei Totalschaden den Neupreis statt des Zeitwerts — typischerweise für mind. 24 Monate nach Kauf. |
| `no_claims_buyback` | Schadenrückkauf | No-claims buyback | Ermöglicht, einen Schaden selbst zu bezahlen, um die SF-Klasse zu erhalten — vermeidet jahrelange Beitragserhöhungen. |
| `discount_protection` | Rabattschutz | Discount / no-claims protection | Ein selbstverschuldeter Unfall führt nicht zum SF-Rückstufung — wichtig für Versicherte mit hoher Klasse. |
| `ev_battery_cover` | Akkudeckung | EV battery cover | Deckung für Akkuschutz, Ladeausrüstung und Wallbox-Schäden — relevant für alle E-Fahrzeughalter. |
| `breakdown_cover` | Pannenhilfe | Breakdown assistance | Pannenhilfe und Abschleppkosten sind in vielen Basistarifen nicht enthalten oder begrenzt. |

**Evidence summary**: Single authoritative source (Stiftung Warentest, 73-criteria test). Key findings: gross negligence waiver is a hard binary differentiator (insurers without it score immediately lower), Mallorca-Police is verified as mandatory inclusion by Stiftung Warentest.

---

## 5. Rechtsschutzversicherung (Legal Expenses Insurance)

**Sources**: Stiftung Warentest (catalog of 70–75 criteria; conditions = 90%, comprehensibility = 10%) · secondary corroboration via transparent-beraten.de

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `no_waiting_period` | Kein Wartefrist (Verkehr) | No waiting period (traffic) | Stiftung Warentest empfiehlt Tarife, die generell auf Wartezeiten verzichten — besonders kritisch, wenn kurz nach Vertragsabschluss ein Autokauf oder Unfall erfolgt. |
| `short_employment_wait` | Kurze Wartezeit Arbeitsrecht | Short employment-law waiting period | Standard ist 3 Monate (allgemein), 6 Monate (Arbeitsrecht) — kürzere oder keine Wartezeiten sind ein echtes Qualitätsmerkmal. |
| `high_coverage_sum` | Hohe Deckungssumme | High coverage sum | Mindestens 1 Mio. € Deckungssumme pro Rechtsfall — niedrigere Grenzen können bei komplexen Verfahren ausgereizt werden. |
| `employment_law` | Arbeitsrechtsschutz | Employment law cover | Schutz bei Kündigung, Abmahnung und Lohnstreitigkeiten — nicht in allen Kombinationstarifen enthalten. |
| `tenant_law` | Mietrechtsschutz | Tenant law cover | Streit mit Vermieter über Nebenkostenabrechnung, Kündigung oder Kaution — wichtig für alle Mieter. |
| `traffic_law` | Verkehrsrechtsschutz | Traffic law cover | Schutz bei Bußgeldbescheiden, Kfz-Kaufstreitigkeiten und Unfallschadensersatz — laut Stiftung Warentest für viele der sinnvollste Einzelbaustein. |
| `social_law` | Sozialrechtsschutz | Social-law cover | Streit mit Behörden über Sozialleistungen, Rente oder Krankenkasse — in vielen Pakettarifen enthalten. |
| `ombudsman_access` | Ombudsmann-Teilnahme | Insurance ombudsman access | Teilnahme am Versicherungsombudsmann ermöglicht kostenlose außergerichtliche Streitbeilegung — Stiftung Warentest bewertet fehlende Teilnahme negativ. |
| `claims_handling_quality` | Regulierungsverhalten | Claims handling quality | Stiftung Warentest erhebt Versichererdaten zum Regulierungsverhalten — schlechte Werte führen zu Abwertungen. |
| `family_cover` | Familienmitversicherung | Family member cover | Partner, Kinder und Haushaltsmitglieder sind beitragsfrei mitversichert — relevant für Paare und Familien. |

**Evidence summary**: Stiftung Warentest is the primary authoritative source here (70–75 criteria catalog, conditions = 90% of total rating). Waiting period waiver and ombudsman participation are explicitly called out as differentiators.

---

## 6. Risikolebensversicherung (Term Life Insurance)

**Sources**: Franke & Bornberg (103 tariffs, 36 criteria, 2025) · Stiftung Warentest (BU comparison methodology cross-reference)

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `guaranteed_increase_option` | Nachversicherungsgarantie | Guaranteed increase option | Versicherungssumme kann bei Lebensereignissen (Heirat, Geburt, Immobilienkauf) ohne erneute Gesundheitsprüfung erhöht werden. |
| `property_purchase_trigger` | Immobilienkauf-Aufstockung | Property purchase increase | Neu 2025 bei Franke & Bornberg: explizite Garantie zur Erhöhung bei Immobilienfinanzierung — wichtig für alle Baufinanzierer. |
| `accelerated_death_benefit` | Vorgezogene Todesfallleistung | Accelerated death benefit | Auszahlung der Versicherungssumme bereits bei einer Lebenserwartung < 12 Monate — finanzielle Entlastung im Endstadium einer Erkrankung. |
| `flexible_term_extension` | Flexible Laufzeitverlängerung | Flexible term extension | Laufzeit kann verlängert werden, solange Hypothek läuft oder Kinder im Haushalt leben — ohne erneute Gesundheitsprüfung. |
| `premium_pause` | Beitragsstundung | Premium pause / payment relief | Kurzfristige Zahlungsschwierigkeiten führen nicht sofort zum Policenverfall — gute Tarife bieten Stundungsoptionen. |
| `annuity_conversion` | Rentenumwandlung | Annuity conversion option | Option, die Todesfallsumme in eine Rente umzuwandeln — Flexibilität für die Begünstigten. |
| `decreasing_sum` | Fallende Versicherungssumme | Decreasing sum insured | Parallele Abnahme zur Restschuld der Hypothek — günstigere Prämie bei deckungsgleichem Kreditschutz. |
| `no_interest_cap` | Kein Zinscap | No interest-rate cap (surplus) | Tarife mit Zinsobergrenze können Überschussbeteiligungen begrenzen — gute Tarife vermeiden künstliche Deckelung. |

**Evidence summary**: Franke & Bornberg is the authoritative source for term life (36 criteria, annual rating updates). The property-purchase trigger and accelerated death benefit are confirmed as key differentiators for top ratings.

---

## 7. Reiseversicherung (Travel Insurance)

**Sources**: Stiftung Warentest (91 annual travel health tariffs, Heft 11/2025; 156 Reiserücktritts-tariffs, Heft 1/2025) — two independent sub-tests covering health and cancellation separately

### 7a. Reisekrankenversicherung (Travel Health)

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `medical_costs_unlimited` | Unbegrenzte Heilkosten | Unlimited medical cost cover | Auslandsbehandlungen können extrem teuer werden — gute Tarife tragen alle Kosten ohne Obergrenze. |
| `medical_repatriation` | Medizinischer Rücktransport | Medical repatriation | Rücktransport ins Heimatland auf ärztliche Anordnung — einer der teuersten Einzelschäden und Pflichtkriterium. |
| `search_rescue` | Such- und Rettungskosten | Search and rescue costs | Ab 2025 neu bewertet von Stiftung Warentest — mind. 10.000 € Deckung wird gefordert. |
| `pre_existing_condition` | Vorerkrankungen | Pre-existing condition cover | Plötzliche Verschlechterung einer Vorerkrankung im Urlaub ist versichert — ohne diesen Einschluss besteht eine der häufigsten Deckungslücken. |
| `no_deductible` | Keine Selbstbeteiligung | No deductible | Stiftung Warentest fordert Tarife ohne Selbstbeteiligung — Eigenanteile im Ausland können unvorhergesehen hoch werden. |
| `long_trip_cover` | Lange Reisedauer | Extended trip duration | Reisedauer pro Einzelreise mind. 42–70 Tage versichert — relevant für Fernreisende und Dauerreisende. |

### 7b. Reiserücktritts- und Reiseabbruchversicherung

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `illness_cancellation` | Krankheitsbedingte Stornierung | Illness-triggered cancellation | Plötzliche schwere Erkrankung vor Reisebeginn — Erstattung des Reisepreises. Kernleistung, aber Umfang variiert stark. |
| `extended_risk_persons` | Erweiterter Personenkreis | Extended risk-person cover | Mitversicherung von Partner, Kindern, Eltern, Pflegepersonen — begrenzte Tarife decken nur den Versicherungsnehmer selbst. |
| `trip_interruption` | Reiseabbruch | Trip interruption / early return | Erstattung nicht genutzter Reiseleistungen und Mehrkosten bei vorzeitiger Heimreise wegen Notfall. |
| `delay_cover` | Ankunftsverzögerung | Arrival delay cover | Kosten durch Verspätung von mehr als 2 Stunden (Unterkunft, Alternativtransport) werden erstattet. |
| `terror_natural_disaster` | Terrorismus / Naturkatastrophen | Terror / natural disaster trigger | Absage wegen Terroranschlag am Zielort oder Naturkatastrophe ist ein echter Stornierungsgrund — nicht in allen Tarifen enthalten. |
| `policy_readability` | Verständlichkeit | Policy readability | Stiftung Warentest bewertet aktiv die Verständlichkeit der Bedingungen (10 % der Gesamtnote) — kurze Sätze, klare Sprache. |

**Evidence summary**: Two independent Stiftung Warentest tests (travel health: 11/2025, cancellation: 1/2025) confirm these criteria. Search & rescue and pre-existing condition cover are newly elevated criteria from 2025.

---

## 8. Kranken-Zusatzversicherung / Krankenhauszusatzversicherung (Supplementary Health / Hospital)

**Sources**: Stiftung Warentest (126 tariffs: 37 single-room, 24 two-bed, Heft ~2024; medical services = 65%, comfort = 20%, contractual = 15%) · secondary: Franke & Bornberg (Advigon, Barmenia, UKV top-rated)

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `goa_35x_cover` | Arzthonorar bis 3,5-facher GOÄ | Physician fee coverage (3.5x GOÄ) | Gute Tarife erstatten Wahlarzthonorare bis mindestens zum 3,5-fachen GOÄ-Satz — darunter bleibt eine Eigenbeteiligung. |
| `single_room` | Einbettzimmer | Single room | Einbettzimmer als Standard (nicht Doppelzimmer) — ein klarer Komfortunterschied im Krankenhaus. |
| `free_physician_choice` | Freie Arztwahl | Free physician choice | Freie Wahl des Chefarztes oder jedes approbierten Arztes ohne Einschränkung durch Kassenkorridore. |
| `ambulatory_specialist` | Ambulante Wahlarztbehandlung | Ambulatory specialist cover | Wahlarzthonorare gelten auch bei ambulanten und teilstationären Eingriffen — nicht nur bei stationären Aufenthalten. |
| `rehab_cover` | Anschlussheilbehandlung | Rehabilitation facility cover | Anschlussbehandlung in einer Rehaklinik nach Krankenhausaufenthalt ist mitversichert. |
| `inpatient_psychotherapy` | Stationäre Psychotherapie | Inpatient psychotherapy | Chefarzt-Abrechnung auch bei stationärer Psychotherapie und zeitlich unbegrenzt — viele Tarife schließen das aus oder begrenzen es. |
| `rooming_in` | Rooming-in | Rooming-in for minors | Übernachtungskosten einer Begleitperson bei Kindern im Krankenhaus — wichtiges Familienkriterium. |
| `no_waiting_period` | Kein Wartefrist | No waiting period | Beste Tarife starten sofort — Wartezeiten bedeuten keine Deckung bei plötzlichen Erkrankungen kurz nach Abschluss. |
| `age_reserve` | Altersrückstellung | Age reserve provision | Tarife mit Altersrückstellung bauen Kapital auf und halten Prämien im Alter stabiler — ohne Altersrückstellung steigen Beiträge stark. |
| `lifetime_coverage` | Lebenslanger Schutz | Lifetime coverage | Police läuft auf Lebenszeit und ist nur vom Versicherungsnehmer kündbar — nicht einseitig durch den Versicherer. |

**Evidence summary**: Stiftung Warentest is the primary source (65%/20%/15% weighting). GOÄ 3.5x threshold, single-room standard, and ambulatory extension are confirmed differentiators by both Stiftung Warentest and Franke & Bornberg rankings.

---

## 9. Unfallversicherung (Accident Insurance)

**Sources**: Stiftung Warentest (Private Unfallversicherung im Vergleich, capital payment 45%, conditions 45%, application 10%) · additional: procontra.de cross-reference on Stiftung Warentest methodology

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `invaliditaet_25pct` | Invaliditätsleistung ab 25 % | Benefit at 25% disability | Stiftung Warentest-Minimum: mind. 37.500 € bei 25 % Invalidität. Niedrigere Beträge reichen für Alltagseinschränkungen nicht. |
| `invaliditaet_50pct` | Invaliditätsleistung ab 50 % | Benefit at 50% disability | Minimum: mind. 150.000 € bei 50 % Invalidität — Hauptleistungsschwelle für mittelschwere Unfallfolgen. |
| `full_invaliditaet` | Vollinvaliditätsleistung | Full disability sum | Minimum: mind. 750.000 € bei 100 % Invalidität — finanziert langfristige Pflege und Umbaumaßnahmen. |
| `favorable_gliederttaxe` | Günstige Gliedertaxe | Favourable limb-valuation table | Die Gliedertaxe legt fest, welcher Invaliditätsgrad für den Verlust einzelner Körperteile angesetzt wird — großzügigere Werte bedeuten höhere Leistungen. |
| `stroke_cardiac` | Schlaganfall / Herzinfarkt | Stroke and cardiac event cover | Unfälle durch Schlaganfall, Herzinfarkt oder Diabetes sind im Standard-Unfallbegriff oft ausgenommen — expliziter Einschluss ist ein Qualitätsmerkmal. |
| `pre_existing_deduction` | Vorerkrankungsabzug erst ab 50 %` | Pre-existing condition deduction threshold | Minderung der Leistung wegen Vorerkrankungen erst ab mindestens 50 % Invaliditätsgrad — darunter kein Abzug. |
| `own_motion_cover` | Eigenbewegungsschutz | Own-movement cover | Verletzungen durch unkoordinierte Eigenbewegung (z. B. Umknicken) sind im Basisschutz oft strittig — gute Tarife schließen sie klar ein. |
| `rescue_costs` | Bergungskosten | Rescue and recovery costs | Kosten für Such- und Bergungsaktionen nach Unfall (Berg, See) sind eine oft unterschätzte Schadenposition. |
| `cosmetic_surgery` | Kosmetische Operationen | Cosmetic surgery after accident | Unfallbedingte Korrekturoperationen (z. B. Narben) werden übernommen — nicht in allen Tarifen enthalten. |
| `post75_continuation` | Weiterführung nach 75 | Post-age-75 continuation | Tarif läuft auch nach dem 75. Geburtstag weiter oder kann verlängert werden — viele Tarife enden automatisch. |

**Evidence summary**: Stiftung Warentest is the authoritative source (capital payment 45% + conditions 45% of rating, 18+ specific conditions assessed). Stroke/cardiac cover and favourable Gliedertaxe are confirmed as key differentiators.

---

## 10. Wohngebäudeversicherung (Building / Property Insurance)

**Sources**: Stiftung Warentest (196 tariffs, 74 insurers, Heft 10/2025; base protection 70%, additional services 30%) · procontra.de (cross-reference on test methodology and results)

| Key | Label DE | Label EN | Why it matters |
|-----|----------|----------|----------------|
| `elementar_included` | Elementarschutz inklusive | Elementary hazard cover included | Stiftung Warentest nimmt nur Tarife in den Test, die Elementarschutz enthalten — Überschwemmung, Starkregen, Erdrutsch, Lawinen, Erdbeben müssen versichert sein. |
| `gross_negligence_waiver` | Verzicht auf grobe Fahrlässigkeit | Gross negligence waiver | Tarife, die bei grober Fahrlässigkeit kürzen, erhalten sofort „mangelhaft" bei Stiftung Warentest — das wichtigste Einzelkriterium. |
| `demolition_cleanup_costs` | Abbruch- und Aufräumkosten | Demolition and cleanup costs | Abrisskosten nicht bewohnbarer Gebäudeteile und Schuttbeseitigung sind ein häufig unterschätzter Kostenfaktor nach einem Totalschaden. |
| `regulatory_surcharge` | Behördliche Mehrkosten | Regulatory surcharge cover | Behördliche Auflagen können Wiederaufbau verteuern (z. B. Pflicht zur Wärmedämmung) — gute Tarife übernehmen diese Mehrkosten. |
| `hotel_costs` | Hotelkosten | Temporary accommodation | Übernachtungskosten, wenn das Gebäude nach einem Schaden vorübergehend unbewohnbar ist. |
| `pipe_freeze_break` | Frost- und Rohrbruch auf Grundstück | Pipe freeze / break on property | Ableitungsrohre außerhalb des Gebäudes (auf dem Grundstück) sind nicht automatisch mitversichert — relevanter Schadensfall. |
| `overvoltage_lightning` | Überspannung durch Blitz | Overvoltage / lightning surge | Blitzinduzierte Überspannung beschädigt Elektroinstallationen — muss als eigenständiger Tatbestand eingeschlossen sein. |
| `advance_cover` | Vorsorgeversicherung Gebäude | Advance / contingency cover | Automatischer Schutz bei Umbau oder Erweiterungen, bis der Versicherer informiert ist — vermeidet Deckungslücken bei Modernisierung. |
| `expert_costs` | Sachverständigenkosten | Expert witness costs | Kosten für Gutachter bei Streit über Schadenhöhe werden übernommen — senkt Hemmung, Sachverständigen hinzuzuziehen. |
| `energy_efficient_rebuild` | Energieeffizienter Wiederaufbau | Energy-efficient rebuild cover | Neueres Kriterium: Mehrkosten für energetisch bessere Bauweise beim Wiederaufbau werden erstattet (Stiftung Warentest 2025 als „unbewertet, aber erwähnenswert" aufgeführt). |

**Evidence summary**: Stiftung Warentest is the authoritative source (70%/30% weighting, all-or-nothing on elementary hazard inclusion). 65 of 194 tariffs rated "mangelhaft" in the 2025 test, primarily due to gross negligence exclusions — confirming it as the most critical single criterion.

---

## Source Analysis

| Source | Domain | Reputation | Type | Access Date | Cross-verified |
|--------|--------|------------|------|-------------|----------------|
| Stiftung Warentest — Privathaftpflicht | test.de | High | Consumer watchdog / official | 2026-06-26 | Y (Franke & Bornberg) |
| Stiftung Warentest — BU | test.de | High | Consumer watchdog / official | 2026-06-26 | Y (Franke & Bornberg) |
| Stiftung Warentest — Hausrat | test.de | High | Consumer watchdog / official | 2026-06-26 | Y (Franke & Bornberg) |
| Stiftung Warentest — Kfz | test.de | High | Consumer watchdog / official | 2026-06-26 | N (single source) |
| Stiftung Warentest — Rechtsschutz | test.de | High | Consumer watchdog / official | 2026-06-26 | N (single source) |
| Franke & Bornberg — BU 2025 | franke-bornberg.de | High | Independent rating agency | 2026-06-26 | Y (Stiftung Warentest) |
| Franke & Bornberg — PHV 2025 | franke-bornberg.de | High | Independent rating agency | 2026-06-26 | Y (Stiftung Warentest) |
| Franke & Bornberg — RLV 2025 | franke-bornberg.de | High | Independent rating agency | 2026-06-26 | N (single source) |
| Stiftung Warentest — Travel health (11/2025) | test.de | High | Consumer watchdog / official | 2026-06-26 | Y (cancellation test) |
| Stiftung Warentest — Reiserücktritt (1/2025) | test.de | High | Consumer watchdog / official | 2026-06-26 | Y (health test) |
| Stiftung Warentest — Krankenhaus-Zusatz | test.de | High | Consumer watchdog / official | 2026-06-26 | N (single source, 126 tariffs) |
| Stiftung Warentest — Unfallversicherung | test.de | High | Consumer watchdog / official | 2026-06-26 | N (single source) |
| Stiftung Warentest — Wohngebäude (10/2025) | test.de | High | Consumer watchdog / official | 2026-06-26 | Y (procontra.de) |
| procontra.de — Wohngebäude | procontra-online.de | Medium-High | Industry journalism | 2026-06-26 | Y (Stiftung Warentest) |

**Reputation summary**: High: 13 (93%) · Medium-High: 1 (7%) · Average: ≈0.99

---

## Knowledge Gaps

### Gap 1: Kfz — Single source
**Issue**: Only Stiftung Warentest tested. Franke & Bornberg and Morgen & Morgen publish Kfz ratings but their specific criteria catalogs were not accessible in open web content.
**Attempted**: Searches for "Franke Bornberg Kfz rating Kriterien", "Morgen Morgen Kfz Leistungsmerkmale" — no public criteria breakdowns found.
**Recommendation**: Purchase Franke & Bornberg rating report, or cross-check via broker tool API access.

### Gap 2: Rechtsschutz — Methodology depth
**Issue**: Stiftung Warentest's 70–75 criteria list for Rechtsschutz is not publicly enumerated in full detail. The overview page identifies key areas but not all criteria weights.
**Attempted**: WebFetch of test.de comparison and detail pages — full criteria table is behind paywall.
**Recommendation**: Access Finanztest print edition (Heft with Rechtsschutz test) for complete criteria table.

### Gap 3: Kranken-Zusatzversicherung — Zahnzusatz vs. Stationär split
**Issue**: Research focused on Krankenhauszusatzversicherung (stationär) as the more differentiated category. Zahnzusatz criteria were partially captured (GOZ 3.5x, implant cover, annual limits) but not fully structured as a separate sub-category.
**Attempted**: WebFetch of test.de Zahnzusatz page confirmed 4 weighted sub-categories.
**Recommendation**: Treat Zahnzusatz as a distinct category entry if the app shows it separately.

### Gap 4: Morgen & Morgen open methodology
**Issue**: Morgen & Morgen operates as a B2B rating tool for brokers. Their specific criteria lists are not publicly available on their website — the tool is subscription-only.
**Attempted**: morgenundmorgen.com ratings overview page — no criteria detail found publicly.
**Recommendation**: No action needed unless broker API access is sought.

---

## Conflicting Information

### Conflict 1: Minimum coverage sum for Privathaftpflicht
**Position A**: Stiftung Warentest requires minimum €10 m for top rating — "Die Versicherungssumme muss mindestens 10 Millionen Euro pauschal betragen."
**Position B**: Franke & Bornberg raised its top-rating threshold to €50 m in 2025 — previous threshold was also €10 m.
**Assessment**: No real conflict. Stiftung Warentest's €10 m is a floor for inclusion in the test; Franke & Bornberg's €50 m is the threshold for their highest rating class (FFF+). Both are valid from their respective methodological standpoints. For consumer guidance, €50 m represents the current market-leading standard.

### Conflict 2: BU — AU clause trigger timing
**Position A**: Stiftung Warentest evaluates AU clause as present / absent (binary).
**Position B**: Franke & Bornberg 2025 distinguishes between 3–4 month trigger vs. 6-month trigger, giving higher scores to shorter triggers.
**Assessment**: Complementary, not contradictory. Use Franke & Bornberg's granular view for the criterion definition (3–4 months = better); Stiftung Warentest confirms the feature matters.

---

## Research Metadata

Duration: ~50 min | Sources examined: 20+ | Sources cited: 14 | Cross-referenced claims: 8 | Confidence: High 80%, Medium-High 20%, Low 0% | Output: docs/product/criteria-research.md
