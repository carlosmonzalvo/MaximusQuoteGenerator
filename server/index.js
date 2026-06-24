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

const PORT = process.env.PORT || 3000;
const SYNC_TOKEN = process.env.SYNC_TOKEN || "";
const REDIS_URL = process.env.REDIS_URL || process.env.REDIS_PRIVATE_URL;

const KINDS = ["clients", "vehicles", "services"];

const redis = createClient({ url: REDIS_URL });
redis.on("error", (err) => console.error("[redis] error:", err.message));

const app = express();
app.use(express.json({ limit: "8mb" }));

// Optional shared-token auth.
app.use((req, res, next) => {
  if (req.path === "/health") return next();
  if (SYNC_TOKEN && req.get("X-Sync-Token") !== SYNC_TOKEN) {
    return res.status(401).json({ error: "unauthorized" });
  }
  next();
});

app.get("/health", (_req, res) => {
  res.json({ ok: true, redis: redis.isOpen, ts: Date.now() });
});

// Merge one record list into a Redis hash (field = syncID), last-write-wins.
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
    await redis.hSet(key, rec.syncID, JSON.stringify(rec));
    applied++;
  }
  return applied;
}

async function readKind(kind) {
  const all = await redis.hGetAll(`maximus:${kind}`);
  return Object.values(all).map((v) => JSON.parse(v));
}

app.post("/sync", async (req, res) => {
  try {
    const payload = req.body || {};
    let applied = 0;
    for (const kind of KINDS) {
      applied += await mergeKind(kind, payload[kind]);
    }

    const out = { deviceID: "server", sentAt: Date.now(), applied };
    for (const kind of KINDS) {
      out[kind] = await readKind(kind);
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
