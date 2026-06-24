# maximus-sync — backend opcional

Servidor de sincronización **opcional** para la app Maximus Precision. La app
funciona 100% local; este backend solo replica registros (autos, clientes,
servicios) entre dispositivos, resolviendo conflictos **last-write-wins** por
`updatedAt` (milisegundos desde 1970), con **Redis** como almacén.

## Endpoints

- `GET /health` — liveness (`{ ok, redis, ts }`).
- `POST /sync` — body: `SyncPayload`. Mezcla los registros entrantes (LWW) y
  devuelve el estado completo del servidor como `SyncPayload`.

Auth opcional: si `SYNC_TOKEN` está seteado, las peticiones deben mandar el
header `X-Sync-Token`.

## Variables de entorno

- `REDIS_URL` — conexión a Redis (Railway la inyecta al referenciar el servicio).
- `PORT` — lo provee Railway.
- `SYNC_TOKEN` — opcional, token compartido.

## Deploy (Railway)

Proyecto `maximus-sync` (servicios `maximus-api` + `Redis`). Desde la raíz del
repo:

```bash
railway up server --path-as-root --service maximus-api
```

URL pública actual: https://maximus-api-production-e2bd.up.railway.app

## Local

```bash
cd server
npm install
REDIS_URL=redis://localhost:6379 npm start
```
