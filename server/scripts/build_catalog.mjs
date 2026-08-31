// A kurátorolt magyar ételkatalógus összefűzése és ellenőrzése.
// A részfájlokból (food_catalog_part_*.json) egy validált assetet állít elő,
// amit az app offline forrásként és a seed szkript is használ.
//
// Futtatás:  node scripts/build_catalog.mjs

import { readdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const assetsDir = resolve(here, "../../assets");
const outputPath = join(assetsDir, "food_catalog_hu.json");

const REQUIRED_NUMBERS = [
  "kcal",
  "protein",
  "fat",
  "carbs",
  "sugar",
  "saturatedFat",
  "salt",
  "fiber",
];

const KCAL_TOLERANCE = 0.2;

function normalizeId(value) {
  return String(value ?? "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/// Ismétlődésnél nem dobjuk el a tételt, hanem a kereséshez hasznos részeket
/// (aliasok, adagok) beolvasztjuk a már felvett tételbe.
function mergeInto(target, food) {
  const aliases = new Set(target.aliases);
  for (const alias of Array.isArray(food.aliases) ? food.aliases : []) {
    const value = String(alias).trim().toLowerCase();
    if (value.length >= 2) {
      aliases.add(value);
    }
  }
  const name = String(food.name ?? "").trim().toLowerCase();
  if (name.length >= 2) {
    aliases.add(name);
  }
  target.aliases = Array.from(aliases).slice(0, 8);

  const labels = new Set(target.servings.map((serving) => serving.label));
  for (const serving of Array.isArray(food.servings) ? food.servings : []) {
    const label = String(serving?.label ?? "").trim();
    const grams = Number.parseFloat(serving?.grams ?? "0");
    if (label.length === 0 || !(grams > 0) || grams > 3000 || labels.has(label)) {
      continue;
    }
    if (target.servings.length >= 4) {
      break;
    }
    labels.add(label);
    target.servings.push({ label, grams });
  }
}

function validate(food, partName, errors, warnings, byId, byName) {
  const id = normalizeId(food.id ?? food.name);
  if (!id) {
    errors.push(`${partName}: azonosító nélküli tétel (${JSON.stringify(food).slice(0, 80)})`);
    return null;
  }
  if (byId.has(id)) {
    warnings.push(`${partName}: ismétlődő azonosító beolvasztva (${id})`);
    mergeInto(byId.get(id), food);
    return null;
  }

  const name = String(food.name ?? "").trim();
  if (name.length < 2) {
    errors.push(`${partName}/${id}: hiányzó név`);
    return null;
  }
  const nameKey = name.toLowerCase();
  if (byName.has(nameKey)) {
    warnings.push(`${partName}: ismétlődő név beolvasztva (${name})`);
    mergeInto(byName.get(nameKey), food);
    return null;
  }

  const values = {};
  for (const field of REQUIRED_NUMBERS) {
    const raw = food[field];
    const value = typeof raw === "number" ? raw : Number.parseFloat(raw ?? "0");
    if (!Number.isFinite(value) || value < 0) {
      errors.push(`${partName}/${id}: hibás ${field} érték (${raw})`);
      return null;
    }
    values[field] = Math.round(value * 100) / 100;
  }

  const macroKcal = values.protein * 4 + values.carbs * 4 + values.fat * 9;
  const isAlcohol = food.category === "alkohol";
  if (!isAlcohol && macroKcal > 0) {
    const drift = Math.abs(values.kcal - macroKcal) / macroKcal;
    if (drift > KCAL_TOLERANCE) {
      warnings.push(
        `${partName}/${id}: kcal (${values.kcal}) eltér a makrókból számolttól (${Math.round(macroKcal)}), javítva`
      );
      values.kcal = Math.round(macroKcal);
    }
  }

  const aliases = Array.from(
    new Set(
      [...(Array.isArray(food.aliases) ? food.aliases : []), name]
        .map((alias) => String(alias).trim().toLowerCase())
        .filter((alias) => alias.length >= 2)
    )
  ).slice(0, 8);

  const servings = (Array.isArray(food.servings) ? food.servings : [])
    .map((serving) => ({
      label: String(serving?.label ?? "").trim(),
      grams: Number.parseFloat(serving?.grams ?? "0"),
    }))
    .filter((serving) => serving.label.length > 0 && serving.grams > 0 && serving.grams <= 3000)
    .slice(0, 4);

  if (servings.length === 0) {
    servings.push({ label: "1 adag (100 g)", grams: 100 });
  }

  const entry = {
    id,
    name,
    category: String(food.category ?? "egyeb"),
    aliases,
    ...values,
    servings,
  };

  byId.set(id, entry);
  byName.set(nameKey, entry);

  return entry;
}

async function main() {
  const files = (await readdir(assetsDir))
    .filter((file) => /^food_catalog_part_.*\.json$/.test(file))
    .sort();

  if (files.length === 0) {
    console.error("[catalog] Nincs food_catalog_part_*.json az assets könyvtárban.");
    process.exit(1);
  }

  const errors = [];
  const warnings = [];
  const byId = new Map();
  const byName = new Map();
  const foods = [];

  for (const file of files) {
    const raw = await readFile(join(assetsDir, file), "utf8");
    let parsed;
    try {
      parsed = JSON.parse(raw);
    } catch (error) {
      errors.push(`${file}: érvénytelen JSON (${error.message})`);
      continue;
    }

    const list = Array.isArray(parsed) ? parsed : parsed.foods;
    if (!Array.isArray(list)) {
      errors.push(`${file}: nincs "foods" lista`);
      continue;
    }

    for (const food of list) {
      const validated = validate(food, file, errors, warnings, byId, byName);
      if (validated) {
        foods.push(validated);
      }
    }
  }

  foods.sort((a, b) => a.name.localeCompare(b.name, "hu"));

  for (const warning of warnings) {
    console.warn(`[catalog] ${warning}`);
  }

  if (errors.length > 0) {
    for (const error of errors) {
      console.error(`[catalog] HIBA ${error}`);
    }
    process.exit(1);
  }

  const payload = {
    version: 1,
    generatedAt: new Date().toISOString(),
    source: "Flexio kurátorolt magyar katalógus",
    count: foods.length,
    foods,
  };

  await writeFile(outputPath, `${JSON.stringify(payload, null, 2)}\n`, "utf8");
  console.log(
    `[catalog] ${foods.length} tétel írva: ${outputPath} (${warnings.length} figyelmeztetés)`
  );
}

main().catch((error) => {
  console.error(error.stack ?? String(error));
  process.exit(1);
});
