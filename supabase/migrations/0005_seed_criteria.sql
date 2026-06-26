-- AUTO-GENERIERT aus app/assets/catalog.json — nicht von Hand bearbeiten.
-- Neu erzeugen: node supabase/seed/generate_seed.mjs

delete from public.contract_criteria where category_key in ('privathaftpflicht', 'berufsunfaehigkeit', 'hausratversicherung');

insert into public.contract_criteria
  (category_key, criterion_key, label_de, label_en, sort_order, active)
values
  ('privathaftpflicht', 'forderungsausfall', 'Forderungsausfalldeckung', 'Failure-of-debtor cover', 10, true),
  ('privathaftpflicht', 'schluesselverlust', 'Schlüsselverlust', 'Lost-key cover', 20, true),
  ('privathaftpflicht', 'deliktunfaehige', 'Deliktunfähige Kinder mitversichert', 'Children not legally liable covered', 30, true),
  ('privathaftpflicht', 'gefaelligkeitsschaeden', 'Gefälligkeitsschäden', 'Damage from favours', 40, true),
  ('privathaftpflicht', 'mietsachschaeden', 'Mietsachschäden', 'Damage to rented property', 50, true),
  ('privathaftpflicht', 'auslandsdeckung', 'Auslandsaufenthalt langfristig', 'Long-term stays abroad', 60, true),
  ('privathaftpflicht', 'allmaehlichkeitsschaeden', 'Allmählichkeitsschäden', 'Gradual damage', 70, true),
  ('privathaftpflicht', 'bestleistungsgarantie', 'Best-Leistungs-Garantie', 'Best-benefit guarantee', 80, true),
  ('berufsunfaehigkeit', 'verzicht_abstrakte_verweisung', 'Verzicht auf abstrakte Verweisung', 'No abstract referral', 10, true),
  ('berufsunfaehigkeit', 'nachversicherungsgarantie', 'Nachversicherungsgarantie', 'Top-up guarantee', 20, true),
  ('berufsunfaehigkeit', 'weltweiter_schutz', 'Weltweiter Versicherungsschutz', 'Worldwide cover', 30, true),
  ('berufsunfaehigkeit', 'rueckwirkende_leistung', 'Rückwirkende Leistung', 'Retroactive benefit', 40, true),
  ('berufsunfaehigkeit', 'stundung_beitrag', 'Beitragsstundung bei Zahlungsproblemen', 'Premium deferral if needed', 50, true),
  ('hausratversicherung', 'fahrraddiebstahl', 'Fahrraddiebstahl', 'Bicycle theft', 10, true),
  ('hausratversicherung', 'elementarschaeden', 'Elementarschäden', 'Natural-hazard damage', 20, true),
  ('hausratversicherung', 'ueberspannung', 'Überspannungsschäden', 'Power-surge damage', 30, true),
  ('hausratversicherung', 'grobe_fahrlaessigkeit', 'Grobe Fahrlässigkeit mitversichert', 'Gross negligence covered', 40, true),
  ('hausratversicherung', 'hotelkosten', 'Hotelkosten bei Unbewohnbarkeit', 'Hotel costs if uninhabitable', 50, true)
;
