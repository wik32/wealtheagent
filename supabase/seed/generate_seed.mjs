// Generiert supabase/migrations/0003_seed_catalog.sql aus der kanonischen
// Inhaltsquelle app/assets/catalog.json — so bleiben App-Fallback und DB-Seed
// garantiert synchron. Erneut ausführen nach jeder Inhaltsänderung:
//   node supabase/seed/generate_seed.mjs
import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, "..", "..");
const catalog = JSON.parse(
  readFileSync(join(root, "app", "assets", "catalog.json"), "utf8"),
);

const q = (v) => {
  if (v === null || v === undefined) return "null";
  return "'" + String(v).replaceAll("'", "''") + "'";
};
const jb = (v) => "'" + JSON.stringify(v).replaceAll("'", "''") + "'::jsonb";
const b = (v) => (v ? "true" : "false");

const lines = [];
lines.push("-- AUTO-GENERIERT aus app/assets/catalog.json — nicht von Hand bearbeiten.");
lines.push("-- Neu erzeugen: node supabase/seed/generate_seed.mjs");
lines.push("-- Idempotent: upsert je Schlüssel.");
lines.push("");

// --- Kategorien -----------------------------------------------------------
lines.push("insert into public.contract_categories");
lines.push(
  "  (key, defino_level, defino_field, name_de, name_en, icon, sort_order," +
    " purpose_de, purpose_en, relevance_de, relevance_en, watch_de, watch_en, active)",
);
lines.push("values");
const catRows = catalog.categories.map(
  (c) =>
    "  (" +
    [
      q(c.key),
      c.defino_level,
      q(c.defino_field),
      q(c.name_de),
      q(c.name_en),
      q(c.icon),
      c.sort_order,
      q(c.purpose_de),
      q(c.purpose_en),
      q(c.relevance_de),
      q(c.relevance_en),
      q(c.watch_de),
      q(c.watch_en),
      "true",
    ].join(", ") +
    ")",
);
lines.push(catRows.join(",\n"));
lines.push("on conflict (key) do update set");
lines.push(
  [
    "  defino_level = excluded.defino_level",
    "  defino_field = excluded.defino_field",
    "  name_de = excluded.name_de",
    "  name_en = excluded.name_en",
    "  icon = excluded.icon",
    "  sort_order = excluded.sort_order",
    "  purpose_de = excluded.purpose_de",
    "  purpose_en = excluded.purpose_en",
    "  relevance_de = excluded.relevance_de",
    "  relevance_en = excluded.relevance_en",
    "  watch_de = excluded.watch_de",
    "  watch_en = excluded.watch_en",
    "  active = excluded.active",
  ].join(",\n"),
);
lines.push(";");
lines.push("");

// --- Felder ---------------------------------------------------------------
// Erst alle Felder der bekannten Kategorien löschen, dann neu einfügen
// (sauberer als Feld-für-Feld-Upsert bei Umbenennungen).
const catKeys = catalog.categories.map((c) => q(c.key)).join(", ");
lines.push(
  `delete from public.contract_fields where category_key in (${catKeys});`,
);
lines.push("");
lines.push("insert into public.contract_fields");
lines.push(
  "  (category_key, field_key, kind, label_de, label_en, sort_order, required, choices, active)",
);
lines.push("values");
const fieldRows = [];
for (const c of catalog.categories) {
  for (const f of c.fields) {
    fieldRows.push(
      "  (" +
        [
          q(c.key),
          q(f.field_key),
          q(f.kind),
          q(f.label_de),
          q(f.label_en),
          f.sort_order,
          b(f.required),
          jb(f.choices ?? []),
          "true",
        ].join(", ") +
        ")",
    );
  }
}
lines.push(fieldRows.join(",\n"));
lines.push(";");
lines.push("");

// --- Wissensartikel -------------------------------------------------------
lines.push("insert into public.knowledge_articles");
lines.push(
  "  (slug, category_de, category_en, title_de, title_en, body_de, body_en," +
    " contract_key, sort_order, active)",
);
lines.push("values");
const artRows = catalog.articles.map(
  (a) =>
    "  (" +
    [
      q(a.slug),
      q(a.category_de),
      q(a.category_en),
      q(a.title_de),
      q(a.title_en),
      jb(a.body_de),
      jb(a.body_en),
      q(a.contract_key),
      a.sort_order,
      "true",
    ].join(", ") +
    ")",
);
lines.push(artRows.join(",\n"));
lines.push("on conflict (slug) do update set");
lines.push(
  [
    "  category_de = excluded.category_de",
    "  category_en = excluded.category_en",
    "  title_de = excluded.title_de",
    "  title_en = excluded.title_en",
    "  body_de = excluded.body_de",
    "  body_en = excluded.body_en",
    "  contract_key = excluded.contract_key",
    "  sort_order = excluded.sort_order",
    "  active = excluded.active",
  ].join(",\n"),
);
lines.push(";");
lines.push("");

// --- Fremdschlüssel jetzt setzen (Kategorien existieren) ------------------
lines.push(
  "-- contracts.contract_type an den Katalog binden (idempotent neu anlegen).",
);
lines.push(
  "alter table public.contracts drop constraint if exists contracts_contract_type_fkey;",
);
lines.push(
  "alter table public.contracts add constraint contracts_contract_type_fkey\n" +
    "  foreign key (contract_type) references public.contract_categories (key) on update cascade;",
);
lines.push("");

const out = join(root, "supabase", "migrations", "0003_seed_catalog.sql");
writeFileSync(out, lines.join("\n"), "utf8");
console.log(
  `0003_seed_catalog.sql geschrieben: ${catalog.categories.length} Kategorien, ` +
    `${fieldRows.length} Felder, ${catalog.articles.length} Artikel.`,
);

// --- Leistungskriterien (eigene Datei 0005; Tabelle entsteht in 0004) ------
const cLines = [];
cLines.push("-- AUTO-GENERIERT aus app/assets/catalog.json — nicht von Hand bearbeiten.");
cLines.push("-- Neu erzeugen: node supabase/seed/generate_seed.mjs");
cLines.push("");
const withCrit = catalog.categories.filter(
  (c) => (c.criteria ?? []).length > 0,
);
const critKeys = withCrit.map((c) => q(c.key)).join(", ");
if (withCrit.length > 0) {
  cLines.push(
    `delete from public.contract_criteria where category_key in (${critKeys});`,
  );
  cLines.push("");
  cLines.push("insert into public.contract_criteria");
  cLines.push("  (category_key, criterion_key, label_de, label_en, sort_order, active)");
  cLines.push("values");
  const critRows = [];
  for (const c of withCrit) {
    for (const cr of c.criteria) {
      critRows.push(
        "  (" +
          [
            q(c.key),
            q(cr.key),
            q(cr.label_de),
            q(cr.label_en),
            cr.sort_order ?? 0,
            "true",
          ].join(", ") +
          ")",
      );
    }
  }
  cLines.push(critRows.join(",\n"));
  cLines.push(";");
  cLines.push("");
  const cOut = join(root, "supabase", "migrations", "0005_seed_criteria.sql");
  writeFileSync(cOut, cLines.join("\n"), "utf8");
  console.log(
    `0005_seed_criteria.sql geschrieben: ${critRows.length} Kriterien ` +
      `(${withCrit.length} Vertragsarten).`,
  );
}
