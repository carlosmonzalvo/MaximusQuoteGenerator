// Maximus Precision — optional sync backend.
//
// Redis-backed, last-write-wins by `updatedAt` (milliseconds since 1970). The
// app works fully offline; this server only mirrors records between devices.
//
// Endpoints:
//   GET  /health        → liveness probe
//   POST /sync          → body: SyncPayload; merges incoming records (LWW) and
//                          returns the full server state as a SyncPayload.
//
// Optional auth: if SYNC_TOKEN is set, requests must send `X-Sync-Token`.

import express from "express";
import { createClient } from "redis";
import { timingSafeEqual } from "crypto";

const PORT = process.env.PORT || 3000;
const API_KEY = process.env.API_KEY || "";
const API_SECRET = process.env.API_SECRET || "";
const REDIS_URL = process.env.REDIS_URL || process.env.REDIS_PRIVATE_URL;

const KINDS = ["clients", "vehicles", "services"];

const redis = createClient({ url: REDIS_URL });
redis.on("error", (err) => console.error("[redis] error:", err.message));

const app = express();
app.use(express.json({ limit: "8mb" }));

// Constant-time string compare (avoids leaking via timing).
function safeEqual(a, b) {
  const ba = Buffer.from(String(a));
  const bb = Buffer.from(String(b));
  if (ba.length !== bb.length) return false;
  return timingSafeEqual(ba, bb);
}

// API key + secret auth. If both env vars are unset the server stays open
// (local dev); in production they are always set.
app.use((req, res, next) => {
  if (req.path === "/health") return next();
  if (!API_KEY && !API_SECRET) return next();
  const okKey = safeEqual(req.get("X-API-Key") || "", API_KEY);
  const okSecret = safeEqual(req.get("X-API-Secret") || "", API_SECRET);
  if (!okKey || !okSecret) {
    return res.status(401).json({ error: "unauthorized" });
  }
  next();
});

app.get("/health", (_req, res) => {
  res.json({ ok: true, redis: redis.isOpen, ts: Date.now() });
});

const SEQ_KEY = "maximus:seq";

// Merge one record list into a Redis hash (field = syncID), last-write-wins.
// Every accepted write gets a monotonic `_seq` so clients can pull deltas.
async function mergeKind(kind, incoming) {
  if (!Array.isArray(incoming) || incoming.length === 0) return 0;
  const key = `maximus:${kind}`;
  let applied = 0;
  for (const rec of incoming) {
    if (!rec || !rec.syncID) continue;
    const existingRaw = await redis.hGet(key, rec.syncID);
    if (existingRaw) {
      const existing = JSON.parse(existingRaw);
      // updatedAt is a number (ms since 1970); keep the newer one.
      if (Number(existing.updatedAt) >= Number(rec.updatedAt)) continue;
    }
    rec._seq = await redis.incr(SEQ_KEY);
    await redis.hSet(key, rec.syncID, JSON.stringify(rec));
    applied++;
  }
  return applied;
}

// Records changed past the client's cursor (delta pull). sinceSeq <= 0 → all.
async function readKind(kind, sinceSeq) {
  const all = await redis.hGetAll(`maximus:${kind}`);
  return Object.values(all)
    .map((v) => JSON.parse(v))
    .filter((r) => !sinceSeq || Number(r._seq || 0) > sinceSeq);
}

app.post("/sync", async (req, res) => {
  try {
    const payload = req.body || {};
    const sinceSeq = Number(payload.sinceSeq || 0);

    let applied = 0;
    for (const kind of KINDS) {
      applied += await mergeKind(kind, payload[kind]);
    }

    const maxSeq = Number((await redis.get(SEQ_KEY)) || 0);
    const out = { deviceID: "server", sentAt: Date.now(), applied, sinceSeq, maxSeq };
    for (const kind of KINDS) {
      out[kind] = await readKind(kind, sinceSeq);
    }
    res.json(out);
  } catch (err) {
    console.error("[sync] error:", err);
    res.status(500).json({ error: err.message });
  }
});

async function start() {
  if (!REDIS_URL) {
    console.warn("[boot] REDIS_URL not set — /sync will fail until Redis is linked.");
  } else {
    await redis.connect();
    console.log("[boot] connected to Redis");
  }
  app.listen(PORT, () => console.log(`[boot] maximus-sync listening on :${PORT}`));
}

start().catch((err) => {
  console.error("[boot] fatal:", err);
  process.exit(1);
});
