-- ══════════════════════════════════════════════════════════════════════════
-- Pulsar OS — schema base v1
-- Extraido de /root/pulsarh-war-room/prisma/schema.prisma (53 models)
-- Removido: campos PulsarH-especificos (mentoria, command, hotmart-bound).
-- Mantido: 14 tabelas core do War Room que servem qualquer tenant.
-- Idempotente: CREATE TABLE IF NOT EXISTS em todas.
-- ══════════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─── 1. agents (IA.gentes do tenant) ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS agents (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  slug            TEXT UNIQUE NOT NULL,
  name            TEXT NOT NULL,
  role            TEXT NOT NULL,
  inspiration     TEXT,
  bio_short       TEXT,
  parent_slug     TEXT,
  is_head         BOOLEAN NOT NULL DEFAULT FALSE,
  active          BOOLEAN NOT NULL DEFAULT TRUE,
  soul_md         TEXT,
  status          TEXT NOT NULL DEFAULT 'idle',
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS agents_parent_idx ON agents(parent_slug);

-- ─── 2. skill_references (skills generalizadas — fonte da verdade) ────────
CREATE TABLE IF NOT EXISTS skill_references (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  slug            TEXT UNIQUE NOT NULL,
  title           TEXT NOT NULL,
  category        TEXT,
  agent_slug      TEXT REFERENCES agents(slug) ON DELETE CASCADE,
  content         TEXT NOT NULL,
  version         TEXT NOT NULL DEFAULT 'v1',
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS skill_refs_agent_idx ON skill_references(agent_slug);

-- ─── 3. agent_memory (memoria/aprendizados dos agents) ────────────────────
CREATE TABLE IF NOT EXISTS agent_memory (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  agent_slug      TEXT NOT NULL REFERENCES agents(slug) ON DELETE CASCADE,
  type            TEXT NOT NULL,
  title           TEXT NOT NULL,
  content         TEXT NOT NULL,
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS agent_memory_slug_idx ON agent_memory(agent_slug, created_at DESC);

-- ─── 4. projects (Kanban /projetos) ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS projects (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  slug            TEXT UNIQUE NOT NULL,
  name            TEXT NOT NULL,
  description     TEXT,
  goal            TEXT,
  deadline        TIMESTAMPTZ,
  status          TEXT NOT NULL DEFAULT 'active',
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 5. initiatives (P/U/L/S/A/R do PULSAR+H) ─────────────────────────────
CREATE TABLE IF NOT EXISTS initiatives (
  id                  TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  project_id          TEXT REFERENCES projects(id) ON DELETE CASCADE,
  title               TEXT NOT NULL,
  description         TEXT,
  phase               TEXT NOT NULL DEFAULT 'planning',
  category            TEXT,
  responsible_agent_id TEXT REFERENCES agents(id) ON DELETE SET NULL,
  tasks               JSONB NOT NULL DEFAULT '[]'::jsonb,
  frequency           TEXT,
  automation_level    TEXT,
  sop_url             TEXT,
  has_leverage_potential BOOLEAN NOT NULL DEFAULT FALSE,
  metadata            JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS initiatives_project_idx ON initiatives(project_id);
CREATE INDEX IF NOT EXISTS initiatives_phase_idx ON initiatives(phase);

-- ─── 6. bau_tasks (tarefas BAU) ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS bau_tasks (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  initiative_id   TEXT REFERENCES initiatives(id) ON DELETE CASCADE,
  title           TEXT NOT NULL,
  description     TEXT,
  frequency       TEXT,
  done            BOOLEAN NOT NULL DEFAULT FALSE,
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 7. pipeline_runs (state machine de pipelines longos) ─────────────────
CREATE TABLE IF NOT EXISTS pipeline_runs (
  id                TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  slug              TEXT UNIQUE NOT NULL,
  name              TEXT NOT NULL,
  type              TEXT NOT NULL,
  agent_slug        TEXT REFERENCES agents(slug) ON DELETE SET NULL,
  state             TEXT NOT NULL DEFAULT 'running',
  current_step      INT NOT NULL DEFAULT 0,
  total_steps       INT,
  awaiting_msg      TEXT,
  payload           JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS pipeline_state_idx ON pipeline_runs(state, updated_at DESC);

-- ─── 8. content (calendario editorial) ────────────────────────────────────
CREATE TABLE IF NOT EXISTS content (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  title           TEXT NOT NULL,
  body            TEXT,
  format          TEXT NOT NULL,
  channel         TEXT,
  status          TEXT NOT NULL DEFAULT 'draft',
  scheduled_at    TIMESTAMPTZ,
  published_at    TIMESTAMPTZ,
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 9. inspirations (radar Leo Dias) ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS inspirations (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  source          TEXT NOT NULL,
  source_url      TEXT,
  headline        TEXT NOT NULL,
  summary         TEXT,
  pulsar_hook     TEXT,
  dimension       TEXT,
  status          TEXT NOT NULL DEFAULT 'new',
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 10. prospects ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS prospects (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  name            TEXT NOT NULL,
  handle          TEXT,
  channel         TEXT,
  status          TEXT NOT NULL DEFAULT 'new',
  score           INT,
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 11. leads ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS leads (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  name            TEXT,
  email           TEXT,
  phone           TEXT,
  source          TEXT,
  status          TEXT NOT NULL DEFAULT 'new',
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 12. automations ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS automations (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  slug            TEXT UNIQUE NOT NULL,
  name            TEXT NOT NULL,
  description     TEXT,
  status          TEXT NOT NULL DEFAULT 'active',
  trigger_type    TEXT,
  config          JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 13. expenses ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS expenses (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  amount_cents    BIGINT NOT NULL,
  category        TEXT NOT NULL,
  description     TEXT,
  occurred_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 14. revenues ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS revenues (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  amount_cents    BIGINT NOT NULL,
  source          TEXT NOT NULL,
  product_slug    TEXT,
  occurred_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 15. brand_tokens (Brand v1.0 Half-Light — assinatura Pulsar OS) ──────
CREATE TABLE IF NOT EXISTS brand_tokens (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  version         TEXT UNIQUE NOT NULL,
  codename        TEXT,
  tokens          JSONB NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Trigger generico pra updated_at ──────────────────────────────────────
CREATE OR REPLACE FUNCTION trg_set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY['agents','skill_references','projects','initiatives','bau_tasks','pipeline_runs','content','prospects','leads','automations'])
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS set_updated_at ON %I; CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();', t, t);
  END LOOP;
END $$;
