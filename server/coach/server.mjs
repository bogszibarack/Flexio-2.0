/**
 * Flexio coach API. A kliens rövid, anonim pillanatképet küld.
 * A számokat a app számolja; a Gemini csak magyar szöveget ír.
 *
 *   GEMINI_API_KEY=... node coach/server.mjs
 *   PORT=8787 GEMINI_MODEL=gemini-2.0-flash node coach/server.mjs
 */
import { createServer } from "node:http";

const PORT = Number(process.env.PORT ?? 8787);
const GEMINI_API_KEY = process.env.GEMINI_API_KEY ?? "";
const GEMINI_MODEL = process.env.GEMINI_MODEL ?? "gemini-2.0-flash";
const HOUR_MS = 60 * 60 * 1000;
const MAX_PER_HOUR = 40;

const hits = new Map();

function clientIp(req) {
  const forwarded = req.headers["x-forwarded-for"];
  if (typeof forwarded === "string" && forwarded.length > 0) {
    return forwarded.split(",")[0].trim();
  }
  return req.socket.remoteAddress ?? "unknown";
}

function allow(ip) {
  const now = Date.now();
  const bucket = hits.get(ip)?.filter((at) => now - at < HOUR_MS) ?? [];
  if (bucket.length >= MAX_PER_HOUR) {
    hits.set(ip, bucket);
    return false;
  }
  bucket.push(now);
  hits.set(ip, bucket);
  return true;
}

function send(res, status, body) {
  const payload = JSON.stringify(body);
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(payload),
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  });
  res.end(payload);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;
    req.on("data", (chunk) => {
      size += chunk.length;
      if (size > 8_192) {
        reject(new Error("too_large"));
        req.destroy();
        return;
      }
      chunks.push(chunk);
    });
    req.on("end", () => {
      try {
        resolve(JSON.parse(Buffer.concat(chunks).toString("utf8") || "{}"));
      } catch {
        reject(new Error("bad_json"));
      }
    });
    req.on("error", reject);
  });
}

function fallbackFrom(body) {
  const fallback = body?.fallback ?? {};
  return {
    prose: `${fallback.prose ?? ""}`.trim(),
    pros: `${fallback.pros ?? ""}`.trim(),
    cons: `${fallback.cons ?? ""}`.trim(),
  };
}

function promptFor(snapshot, fallback) {
  const kind = snapshot?.kind ?? "workout";
  const facts = JSON.stringify(snapshot ?? {}, null, 2);
  return [
    "Te a Flexio magyar edzőtársa vagy. Rövid, barátságos, konkrét.",
    "TILOS: orvosi diagnózis, betegség, étrend-kiegészítő, kitalált kg/kcal szám.",
    "A számokat NE változtasd. A tények adottak. Csak szöveget írsz.",
    `Típus: ${kind}`,
    `Tények:\n${facts}`,
    `Helyi javaslat, ha nincs jobb ötleted: ${JSON.stringify(fallback)}`,
    'Válaszolj CSAK JSON-nel: {"prose":"1-2 mondat","pros":"egy mondat vagy üres","cons":"egy mondat vagy üres"}',
    kind === "workout"
      ? "A prose a választott százalékra vonatkozik. A pros/cons 1-1 mondat."
      : "A prose egy rövid magyar összefoglaló. A pros és cons legyen üres, kivéve ha tényleg kell.",
  ].join("\n");
}

function parseModelText(text, fallback) {
  const raw = `${text ?? ""}`.trim();
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");
  if (start < 0 || end <= start) {
    return fallback;
  }
  try {
    const parsed = JSON.parse(raw.slice(start, end + 1));
    return {
      prose: `${parsed.prose ?? fallback.prose}`.trim() || fallback.prose,
      pros: `${parsed.pros ?? fallback.pros}`.trim(),
      cons: `${parsed.cons ?? fallback.cons}`.trim(),
    };
  } catch {
    return fallback;
  }
}

async function askGemini(snapshot, fallback) {
  if (!GEMINI_API_KEY) {
    return fallback;
  }
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/` +
    `${encodeURIComponent(GEMINI_MODEL)}:generateContent?key=${encodeURIComponent(GEMINI_API_KEY)}`;
  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ parts: [{ text: promptFor(snapshot, fallback) }] }],
      generationConfig: {
        temperature: 0.6,
        maxOutputTokens: 256,
        responseMimeType: "application/json",
      },
    }),
  });
  if (!response.ok) {
    console.error("gemini_http", response.status);
    return fallback;
  }
  const data = await response.json();
  const text = data?.candidates?.[0]?.content?.parts
    ?.map((part) => part.text ?? "")
    .join("\n");
  return parseModelText(text, fallback);
}

const server = createServer(async (req, res) => {
  if (req.method === "OPTIONS") {
    send(res, 204, {});
    return;
  }

  const url = new URL(req.url ?? "/", "http://localhost");
  if (req.method === "GET" && (url.pathname === "/" || url.pathname === "/health")) {
    send(res, 200, { ok: true, gemini: Boolean(GEMINI_API_KEY) });
    return;
  }

  if (req.method !== "POST" || url.pathname !== "/coach") {
    send(res, 404, { error: "not_found" });
    return;
  }

  const ip = clientIp(req);
  if (!allow(ip)) {
    send(res, 429, { error: "rate_limited" });
    return;
  }

  let body;
  try {
    body = await readBody(req);
  } catch {
    send(res, 400, { error: "bad_request" });
    return;
  }

  const fallback = fallbackFrom(body);
  try {
    const copy = await askGemini(body.snapshot, fallback);
    send(res, 200, copy);
  } catch (error) {
    console.error("coach_failed", error instanceof Error ? error.message : error);
    send(res, 200, fallback);
  }
});

server.listen(PORT, () => {
  console.log(`flexio coach listening on :${PORT} gemini=${Boolean(GEMINI_API_KEY)}`);
});
