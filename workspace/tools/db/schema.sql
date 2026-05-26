-- Clara · SQLite schema
-- DB local em /opt/clones/clara/workspace/data/clara.db
-- Princípio: 1 banco por lojista (isolamento total · multi-tenancy por VPS)

PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

-- =========================
-- 1. LOJISTA (dono · 1 só)
-- =========================
CREATE TABLE IF NOT EXISTS lojista (
  id              INTEGER PRIMARY KEY CHECK (id = 1),
  nome            TEXT NOT NULL,
  loja_nome       TEXT NOT NULL,
  cidade          TEXT,
  estado          TEXT,
  endereco        TEXT,
  whatsapp        TEXT,
  instagram       TEXT,
  google_place_id TEXT,
  chave_pix       TEXT,
  pix_nome        TEXT,
  pix_cidade      TEXT,
  credenciado_claro INTEGER DEFAULT 0,  -- 0/1
  observacoes     TEXT,
  created_at      TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at      TEXT DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 2. PRODUTOS PRÓPRIOS DA LOJA (não-Claro · catálogo dele)
-- =========================
CREATE TABLE IF NOT EXISTS produtos_loja (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  nome          TEXT NOT NULL,
  categoria     TEXT,            -- ex: 'assistencia', 'acessorio', 'celular_usado'
  preco         REAL,
  custo         REAL,
  estoque       INTEGER DEFAULT 0,
  descricao     TEXT,
  ativo         INTEGER DEFAULT 1,
  created_at    TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at    TEXT DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 3. CACHE LOCAL DO CLARO-CANON (sync da skill)
-- =========================
CREATE TABLE IF NOT EXISTS claro_canon_local (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  tipo          TEXT NOT NULL,    -- 'plano_controle', 'plano_pos', 'pre_pago', 'fixo'
  nome          TEXT NOT NULL,
  preco         REAL,
  gb            INTEGER,
  fidelidade_meses INTEGER,
  features_json TEXT,             -- JSON array
  prioridade    INTEGER DEFAULT 5, -- 1=destacar / 10=fundo gaveta
  ativo         INTEGER DEFAULT 1,
  ultima_sync   TEXT DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 4. CLIENTES (CRM básico)
-- =========================
CREATE TABLE IF NOT EXISTS clientes (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  nome          TEXT NOT NULL,
  whatsapp      TEXT,
  telefone      TEXT,
  email         TEXT,
  cpf           TEXT,
  origem        TEXT,             -- 'balcao', 'instagram', 'indicacao', 'gmb'
  primeira_visita TEXT DEFAULT CURRENT_TIMESTAMP,
  ultima_visita TEXT,
  ticket_total  REAL DEFAULT 0,
  ticket_medio  REAL DEFAULT 0,
  n_compras     INTEGER DEFAULT 0,
  tem_plano_claro INTEGER DEFAULT 0,
  observacoes   TEXT,
  created_at    TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at    TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_clientes_whatsapp ON clientes(whatsapp);

-- =========================
-- 5. FOLLOW-UPS (próxima ação por cliente · TIPO RECORRENTE OU PONTUAL)
-- =========================
CREATE TABLE IF NOT EXISTS follow_ups (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  cliente_id    INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  motivo        TEXT NOT NULL,         -- 'pos_venda_3d', 'volta_30d', 'plano_claro_oferta', etc
  prazo         TEXT NOT NULL,         -- ISO 8601 (YYYY-MM-DDTHH:MM:SS)
  canal         TEXT DEFAULT 'whatsapp', -- 'whatsapp', 'instagram_dm', 'ligacao'
  mensagem_template TEXT,
  feito         INTEGER DEFAULT 0,
  resultado     TEXT,
  feito_at      TEXT,
  created_at    TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_followups_prazo ON follow_ups(prazo, feito);

-- =========================
-- 6. POSTS AGENDADOS (calendário editorial)
-- =========================
CREATE TABLE IF NOT EXISTS posts_agendados (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  agendado_para TEXT NOT NULL,        -- ISO 8601
  canal         TEXT NOT NULL,         -- 'instagram', 'whatsapp_status', 'gmb', 'facebook'
  tipo          TEXT NOT NULL,         -- 'carrossel', 'foto', 'story', 'reels', 'post_texto'
  template      TEXT,                  -- 'T1-claro-30gb' etc · path relativo em tools/carousel-renderer/templates/
  data_json     TEXT,                  -- JSON pro template (Handlebars)
  caption       TEXT,
  midias_paths  TEXT,                  -- JSON array de paths PNG/MP4 (depois de render)
  status        TEXT DEFAULT 'agendado', -- 'agendado', 'rendering', 'pronto', 'publicado', 'falhou'
  posted_media_id TEXT,
  erro          TEXT,
  published_at  TEXT,
  created_at    TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at    TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_posts_status_prazo ON posts_agendados(status, agendado_para);

-- =========================
-- 7. EVENTOS (log de tudo que Clara fez · auditoria leve)
-- =========================
CREATE TABLE IF NOT EXISTS eventos (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  tipo          TEXT NOT NULL,         -- 'carrossel_gerado', 'wa_enviado', 'review_respondido', 'pix_gerado', etc
  cliente_id    INTEGER REFERENCES clientes(id) ON DELETE SET NULL,
  payload_json  TEXT,
  ts            TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_eventos_ts ON eventos(ts);

-- =========================
-- VIEWS úteis
-- =========================
CREATE VIEW IF NOT EXISTS v_followups_pendentes AS
SELECT fu.id, fu.cliente_id, c.nome AS cliente_nome, c.whatsapp,
       fu.motivo, fu.prazo, fu.canal, fu.mensagem_template
FROM follow_ups fu
JOIN clientes c ON c.id = fu.cliente_id
WHERE fu.feito = 0 AND fu.prazo <= datetime('now', '+1 day')
ORDER BY fu.prazo;

CREATE VIEW IF NOT EXISTS v_posts_proximos AS
SELECT id, agendado_para, canal, tipo, template, status
FROM posts_agendados
WHERE status IN ('agendado', 'rendering', 'pronto')
  AND agendado_para >= datetime('now', '-1 day')
ORDER BY agendado_para;

-- ✓ schema OK
