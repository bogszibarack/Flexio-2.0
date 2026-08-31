// A kurátorolt magyar katalógus betöltése a Supabase adatbázisba.
// A tételek `source = 'curated'` és `external_id = <katalógus id>` kulcson
// upsertelődnek, tehát a szkript ismételten futtatható.
//
// Futtatás:  DATABASE_URL=postgres://... node scripts/seed_foods.mjs

import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import pg from "pg";

const here = dirname(fileURLToPath(import.meta.url));
const catalogPath = resolve(here, "../../assets/food_catalog_hu.json");

async function main() {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    console.error("[seed] Hiányzó DATABASE_URL környezeti változó.");
    process.exit(1);
  }

  const catalog = JSON.parse(await readFile(catalogPath, "utf8"));
  const foods = catalog.foods ?? [];
  if (foods.length === 0) {
    console.error("[seed] A katalógus üres. Futtasd előbb: npm run build:catalog");
    process.exit(1);
  }

  const client = new pg.Client({
    connectionString,
    ssl: process.env.PGSSL_DISABLE ? undefined : { rejectUnauthorized: false },
  });

  await client.connect();
  console.log(`[seed] ${foods.length} tétel betöltése indul...`);

  let inserted = 0;

  for (const food of foods) {
    await client.query("begin");
    try {
      const { rows } = await client.query(
        `insert into public.foods (
           source, external_id, name, category, lang, kcal, protein, fat, carbs,
           sugar, saturated_fat, salt, fiber, quality_score, verified
         ) values ('curated', $1, $2, $3, 'hu', $4, $5, $6, $7, $8, $9, $10, $11, 1.0, true)
         on conflict (source, external_id) where external_id is not null do update set
           name = excluded.name,
           category = excluded.category,
           kcal = excluded.kcal,
           protein = excluded.protein,
           fat = excluded.fat,
           carbs = excluded.carbs,
           sugar = excluded.sugar,
           saturated_fat = excluded.saturated_fat,
           salt = excluded.salt,
           fiber = excluded.fiber,
           quality_score = 1.0,
           verified = true
         returning id`,
        [
          food.id,
          food.name,
          food.category ?? null,
          food.kcal,
          food.protein,
          food.fat,
          food.carbs,
          food.sugar,
          food.saturatedFat,
          food.salt,
          food.fiber,
        ]
      );

      const foodId = rows[0].id;

      for (const alias of food.aliases ?? []) {
        await client.query(
          `insert into public.food_aliases (food_id, alias)
           values ($1, $2)
           on conflict (food_id, normalized) do nothing`,
          [foodId, alias]
        );
      }

      let order = 0;
      for (const serving of food.servings ?? []) {
        await client.query(
          `insert into public.food_servings (food_id, label, grams, sort_order)
           values ($1, $2, $3, $4)
           on conflict (food_id, label) do update set
             grams = excluded.grams,
             sort_order = excluded.sort_order`,
          [foodId, serving.label, serving.grams, order]
        );
        order += 1;
      }

      await client.query("commit");
      inserted += 1;
    } catch (error) {
      await client.query("rollback");
      console.error(`[seed] Hiba a(z) ${food.id} tételnél: ${error.message}`);
    }
  }

  console.log(`[seed] Kész: ${inserted} tétel betöltve vagy frissítve.`);
  await client.end();
}

main().catch((error) => {
  console.error(error.stack ?? String(error));
  process.exit(1);
});
