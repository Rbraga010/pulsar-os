-- Pulsar OS · schema telemetria heartbeat
-- Roda no DB do projeto host (War Room, Pulsar API, etc)

CREATE TABLE IF NOT EXISTS pulsar_os_installs (
  install_id UUID PRIMARY KEY,
  version    TEXT NOT NULL,
  last_active TIMESTAMPTZ NOT NULL,
  first_seen  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pulsar_os_installs_last_active
  ON pulsar_os_installs (last_active DESC);

CREATE INDEX IF NOT EXISTS idx_pulsar_os_installs_version
  ON pulsar_os_installs (version);

-- Views uteis (opcional)

CREATE OR REPLACE VIEW pulsar_os_active_7d AS
SELECT COUNT(*)::int as count
FROM pulsar_os_installs
WHERE last_active >= NOW() - INTERVAL '7 days';

CREATE OR REPLACE VIEW pulsar_os_version_distribution AS
SELECT version, COUNT(*)::int as installs
FROM pulsar_os_installs
WHERE last_active >= NOW() - INTERVAL '30 days'
GROUP BY version
ORDER BY installs DESC;
