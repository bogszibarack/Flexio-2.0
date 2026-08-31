// Open Food Facts import: a nyilvános dumpot streamelve dolgozza fel, kiszűri a
// Magyarországon kapható termékeket, és beírja a Supabase `foods` táblájába.
//
// Futtatás:  DATABASE_URL=postgres://... node worker/import_off.mjs
// Renderen Cron Job-ként heti egyszer.
//
// Az adat forrása az Open Food Facts, licenc: Open Database License (ODbL).

import { createInterface } from "node:readline";
import { createGunzip } from "node:zlib";
import { get } from "node:https";
import pg from "pg";

const DUMP_URL =
  process.env.OFF_DUMP_URL ??
  "https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz";

const BATCH_SIZE = Number(process.env.OFF_BATCH_SIZE ?? 500);
const MAX_ROWS = Number(process.env.OFF_MAX_ROWS ?? 0); // 0 = nincs limit
const USER_AGENT =
  process.env.OFF_USER_AGENT ?? "Flexio/1.0 (kapcsolat: hello@flexio.app)";

const NUMERIC_FIELDS = {
  kcal: "energy-kcal_100g",
  protein: "proteins_100g",
  fat: "fat_100g",
  carbs: "carbohydrates_100g",
  sugar: "sugars_100g",
  saturated_fat: "saturated-fat_100g",
  salt: "salt_100g",
  fiber: "fiber_100g",
};

function fail(message) {
  console.error(`[off-import] ${message}`);
  process.exit(1);
}

function openDump(url, redirects = 0) {
  return new Promise((resolve, reject) => {
    if (redirects > 5) {
      reject(new Error("Túl sok átirányítás"));
      return;
    }

    get(url, { headers: { "User-Agent": USER_AGENT } }, (response) => {
      const status = response.statusCode ?? 0;

      if (status >= 300 && status < 400 && response.headers.location) {
        response.resume();
        openDump(response.headers.location, redirects + 1).then(resolve, reject);
        return;
      }

      if (status !== 200) {
        reject(new Error(`A dump letöltése ${status} kóddal elutasítva`));
        return;
      }

      resolve(response);
    }).on("error", reject);
  });
}

function toNumber(value) {
  if (value === undefined || value === null || value === "") {
    return null;
  }
  const parsed = Number.parseFloat(value.replace(",", "."));
  return Number.isFinite(parsed) ? parsed : null;
}

function isHungarian(row) {
  const countries = (row["countries_tags"] ?? "").toLowerCase();
  if (countries.includes("hungary") || countries.includes("magyarorszag")) {
    return true;
  }
  return Boolean((row["product_name_hu"] ?? "").trim());
}

function pickName(row) {
  const candidates = [
    row["product_name_hu"],
    row["product_name"],
    [row["brands"], row["quantity"]].filter(Boolean).join(" "),
  ];

  for (const candidate of candidates) {
    const value = (candidate ?? "").trim();
    if (value.length >= 2) {
      return value.slice(0, 200);
    }
  }
  return null;
}

// A hiányos tápanyagadat rontja a keresési rangsort.
function qualityScore(values) {
  let score = 0.3;
  if ((values.kcal ?? 0) > 0) score += 0.25;
  if ((values.protein ?? 0) + (values.fat ?? 0) + (values.carbs ?? 0) > 0) score += 0.25;
  if (values.fiber !== null || values.salt !== null) score += 0.2;
  return Math.min(score, 1).toFixed(2);
}

function buildRecord(row) {
  const barcode = (row["code"] ?? "").replace(/[^0-9]/g, "");
  if (barcode.length < 8 || barcode.length > 14) {
    return null;
  }

  const name = pickName(row);
  if (!name) {
    return null;
  }

  const values = {};
  for (const [key, column] of Object.entries(NUMERIC_FIELDS)) {
    values[key] = toNumber(row[column]);
  }

  // Tápanyag nélküli termék naplózásra használhatatlan.
  if (!values.kcal && !values.protein && !values.fat && !values.carbs) {
    return null;
  }

  const servingGrams = toNumber((row["serving_size"] ?? "").replace(/[^0-9.,]/g, ""));

  return {
    barcode,
    name,
    brand: (row["brands"] ?? "").trim().slice(0, 120) || null,
    quantity: (row["quantity"] ?? "").trim().slice(0, 60) || null,
    image_url: (row["image_small_url"] ?? "").trim() || null,
    kcal: values.kcal ?? 0,
    protein: values.protein ?? 0,
    fat: values.fat ?? 0,
    carbs: values.carbs ?? 0,
    sugar: values.sugar,
    saturated_fat: values.saturated_fat,
    salt: values.salt,
    fiber: values.fiber,
    quality_score: qualityScore(values),
    serving_grams:
      servingGrams && servingGrams > 0 && servingGrams < 2000 ? servingGrams : null,
  };
}

async function flush(client, batch) {
  if (batch.length === 0) {
    return 0;
  }

  const columns = [
    "source",
    "external_id",
    "barcode",
    "name",
    "brand",
    "quantity",
    "lang",
    "kcal",
    "protein",
    "fat",
    "carbs",
    "sugar",
    "saturated_fat",
    "salt",
    "fiber",
    "image_url",
    "quality_score",
  ];

  const values = [];
  const tuples = batch.map((record, index) => {
    const offset = index * columns.length;
    values.push(
      "off",
      record.barcode,
      record.barcode,
      record.name,
      record.brand,
      record.quantity,
      "hu",
      record.kcal,
      record.protein,
      record.fat,
      record.carbs,
      record.sugar,
      record.saturated_fat,
      record.salt,
      record.fiber,
      record.image_url,
      record.quality_score
    );
    return `(${columns.map((_, i) => `$${offset + i + 1}`).join(", ")})`;
  });

  await client.query(
    `insert into public.foods (${columns.join(", ")})
     values ${tuples.join(", ")}
     on conflict (barcode) do update set
       name = excluded.name,
       brand = coalesce(excluded.brand, public.foods.brand),
       quantity = coalesce(excluded.quantity, public.foods.quantity),
       kcal = excluded.kcal,
       protein = excluded.protein,
       fat = excluded.fat,
       carbs = excluded.carbs,
       sugar = coalesce(excluded.sugar, public.foods.sugar),
       saturated_fat = coalesce(excluded.saturated_fat, public.foods.saturated_fat),
       salt = coalesce(excluded.salt, public.foods.salt),
       fiber = coalesce(excluded.fiber, public.foods.fiber),
       image_url = coalesce(excluded.image_url, public.foods.image_url),
       quality_score = greatest(public.foods.quality_score, excluded.quality_score)`,
    values
  );

  const withServing = batch.filter((record) => record.serving_grams);
  if (withServing.length > 0) {
    const servingValues = [];
    const servingTuples = withServing.map((record, index) => {
      servingValues.push(record.barcode, `1 adag (${record.serving_grams} g)`, record.serving_grams);
      const offset = index * 3;
      return `($${offset + 1}, $${offset + 2}, $${offset + 3})`;
    });

    await client.query(
      `insert into public.food_servings (food_id, label, grams)
       select f.id, v.label, v.grams::numeric
       from (values ${servingTuples.join(", ")}) as v(barcode, label, grams)
       join public.foods f on f.barcode = v.barcode
       on conflict (food_id, label) do nothing`,
      servingValues
    );
  }

  return batch.length;
}

async function main() {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    fail("Hiányzó DATABASE_URL környezeti változó.");
  }

  const client = new pg.Client({
    connectionString,
    ssl: process.env.PGSSL_DISABLE ? undefined : { rejectUnauthorized: false },
    statement_timeout: 120_000,
  });

  await client.connect();
  console.log("[off-import] Kapcsolódva, dump letöltése indul...");

  const response = await openDump(DUMP_URL);
  const reader = createInterface({
    input: response.pipe(createGunzip()),
    crlfDelay: Infinity,
  });

  let header = null;
  let seen = 0;
  let imported = 0;
  let batch = [];
  const startedAt = Date.now();

  for await (const line of reader) {
    if (!header) {
      // Az OFF export tabulátorral tagolt, a kiterjesztés ellenére.
      header = line.split("\t");
      continue;
    }

    seen += 1;
    const cells = line.split("\t");
    if (cells.length < header.length / 2) {
      continue;
    }

    const row = {};
    for (let i = 0; i < header.length; i += 1) {
      row[header[i]] = cells[i];
    }

    if (!isHungarian(row)) {
      continue;
    }

    const record = buildRecord(row);
    if (!record) {
      continue;
    }

    batch.push(record);

    if (batch.length >= BATCH_SIZE) {
      imported += await flush(client, batch);
      batch = [];
      console.log(`[off-import] ${imported} magyar termék mentve (${seen} sor beolvasva)`);
    }

    if (MAX_ROWS > 0 && seen >= MAX_ROWS) {
      break;
    }
  }

  imported += await flush(client, batch);

  const seconds = Math.round((Date.now() - startedAt) / 1000);
  console.log(
    `[off-import] Kész: ${imported} termék, ${seen} beolvasott sor, ${seconds} másodperc.`
  );

  await client.end();
}

main().catch((error) => {
  fail(error.stack ?? String(error));
});
