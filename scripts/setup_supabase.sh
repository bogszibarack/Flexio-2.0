#!/usr/bin/env bash
# Flexio Supabase telepítés: migrációk, role-jelszavak, katalógus seed.
#
# Használat:
#   cp .env.supabase.example .env.supabase
#   # töltsd ki a SUPABASE_DB_PASSWORD mezőt
#   ./scripts/setup_supabase.sh
#
# Vagy egyszeri futtatás:
#   SUPABASE_DB_PASSWORD='...' ./scripts/setup_supabase.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -f .env.supabase ]]; then
  # shellcheck disable=SC1091
  set -a
  source .env.supabase
  set +a
fi

PROJECT_REF="${SUPABASE_PROJECT_REF:-qbppiqfmhoaogyzaueix}"
DB_PASSWORD="${SUPABASE_DB_PASSWORD:-${1:-}}"
DB_POOLER_HOST="${SUPABASE_DB_HOST:-aws-0-eu-central-1.pooler.supabase.com}"
DB_POOLER_PORT="${SUPABASE_DB_PORT:-5432}"

if [[ -z "$DB_PASSWORD" ]]; then
  echo "Hiba: hiányzik a SUPABASE_DB_PASSWORD."
  echo "Supabase Dashboard → Project Settings → Database → Database password"
  echo ""
  echo "  cp .env.supabase.example .env.supabase"
  echo "  # töltsd ki, majd: ./scripts/setup_supabase.sh"
  exit 1
fi

if [[ -z "${FLEXIO_API_PASSWORD:-}" ]]; then
  FLEXIO_API_PASSWORD="$(openssl rand -hex 16)"
fi
if [[ -z "${FLEXIO_JOBS_PASSWORD:-}" ]]; then
  FLEXIO_JOBS_PASSWORD="$(openssl rand -hex 16)"
fi
if [[ -z "${INTERNAL_JOBS_SHARED_SECRET:-}" ]]; then
  INTERNAL_JOBS_SHARED_SECRET="$(openssl rand -hex 24)"
fi

sql_escape() {
  printf "%s" "$1" | sed "s/'/''/g"
}

API_PW_SQL="$(sql_escape "$FLEXIO_API_PASSWORD")"
JOBS_PW_SQL="$(sql_escape "$FLEXIO_JOBS_PASSWORD")"

DB_HOST="${DB_POOLER_HOST}"
DATABASE_URL="postgresql://postgres.${PROJECT_REF}:${DB_PASSWORD}@${DB_HOST}:${DB_POOLER_PORT}/postgres?sslmode=require"
export DATABASE_URL

PSQL=(psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -q)

echo "==> Kapcsolódás: ${DB_HOST} (projekt: ${PROJECT_REF})"
"${PSQL[@]}" -c "select version();" >/dev/null

MIGRATIONS=(
  supabase/migrations/20260829090000_init.sql
  supabase/migrations/20260829090100_search.sql
  supabase/migrations/20260829090200_account.sql
  supabase/migrations/20260830190000_api_role.sql
  supabase/migrations/20260830193000_coach_usage.sql
  supabase/migrations/20260830194500_lww_updated_at.sql
  supabase/migrations/20260830195000_search_user_seam.sql
  supabase/migrations/20260831100000_backfill_auth_users.sql
  supabase/migrations/20260902120000_media_and_water_sync.sql
)

for file in "${MIGRATIONS[@]}"; do
  echo "==> Migráció: $(basename "$file")"
  "${PSQL[@]}" -f "$file"
done

echo "==> flexio_api / flexio_jobs jelszavak"
"${PSQL[@]}" <<SQL
alter role flexio_api password '${API_PW_SQL}';
alter role flexio_jobs password '${JOBS_PW_SQL}';
SQL

echo "==> Katalógus seed (postgres)"
(
  cd server
  if [[ ! -d node_modules ]]; then
    if [[ -f package-lock.json ]]; then
      npm ci
    else
      npm install
    fi
  fi
  NODE_TLS_REJECT_UNAUTHORIZED=0 DATABASE_URL="$DATABASE_URL" npm run seed:foods
)

ENV_OUT="$ROOT/.env.supabase"
cat >"$ENV_OUT" <<EOF
# Generálva: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
SUPABASE_PROJECT_REF=${PROJECT_REF}
SUPABASE_DB_PASSWORD=${DB_PASSWORD}
FLEXIO_API_PASSWORD=${FLEXIO_API_PASSWORD}
FLEXIO_JOBS_PASSWORD=${FLEXIO_JOBS_PASSWORD}
INTERNAL_JOBS_SHARED_SECRET=${INTERNAL_JOBS_SHARED_SECRET}
SUPABASE_URL=https://${PROJECT_REF}.supabase.co
DATABASE_URL=${DATABASE_URL}
FLEXIO_API_DATABASE_URL=postgresql://flexio_api.${PROJECT_REF}:${FLEXIO_API_PASSWORD}@${DB_HOST}:${DB_POOLER_PORT}/postgres?sslmode=require
FLEXIO_JOBS_DATABASE_URL=postgresql://flexio_jobs.${PROJECT_REF}:${FLEXIO_JOBS_PASSWORD}@${DB_HOST}:${DB_POOLER_PORT}/postgres?sslmode=require
EOF
chmod 600 "$ENV_OUT"

BACKEND_ENV="$ROOT/backend/.env.local"
cat >"$BACKEND_ENV" <<EOF
# Render / helyi C# API – ne commitold.
SupabaseAuth__ProjectUrl=https://${PROJECT_REF}.supabase.co
Postgres__ApiConnectionString=Host=${DB_HOST};Port=${DB_POOLER_PORT};Username=flexio_api.${PROJECT_REF};Password=${FLEXIO_API_PASSWORD};Database=postgres;SSL Mode=Require
Postgres__JobsConnectionString=Host=${DB_HOST};Port=${DB_POOLER_PORT};Username=flexio_jobs.${PROJECT_REF};Password=${FLEXIO_JOBS_PASSWORD};Database=postgres;SSL Mode=Require
InternalJobs__SharedSecret=${INTERNAL_JOBS_SHARED_SECRET}
EOF
chmod 600 "$BACKEND_ENV"

echo ""
echo "Kész. A titkok itt vannak (ne oszd meg, ne commitold):"
echo "  - .env.supabase"
echo "  - backend/.env.local"
echo ""
echo "Következő: Render deploy a backend/.env.local értékeivel,"
echo "majd Flutter: --dart-define=API_BASE_URL=https://<render-url>"
