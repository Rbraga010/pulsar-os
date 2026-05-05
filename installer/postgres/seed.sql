-- ══════════════════════════════════════════════════════════════════════════
-- Pulsar OS — seed v1
-- 30 agents canonicos (8 oficiais + 22 heads) + 23 skills generalizadas
-- + 1 projeto default + Brand v1.0 Half-Light tokens
-- Idempotente: ON CONFLICT DO NOTHING em todos os INSERTs.
-- Sem nenhuma referencia a PulsarH/Rodrigo/Instituto — generico.
-- ══════════════════════════════════════════════════════════════════════════

-- ─── BRAND TOKENS v1.0 Half-Light ─────────────────────────────────────────
INSERT INTO brand_tokens (version, codename, tokens) VALUES (
  'v1.0-half-light',
  'Half-Light',
  '{
    "color": {
      "navy":   {"deep":"#0B0C1F","base":"#121A2E","mid":"#181A36","soft":"#1F2245"},
      "violet": {"deep":"#3B1750","base":"#5C4280","soft":"#7A5BA0"},
      "gold":   {"base":"#C9A84A","soft":"#B89C4A"},
      "cream":  "#F2EFE6",
      "white":  "#FFFFFF",
      "gray":   {"100":"#E8E9F0","300":"#A8AAC2","400":"#7B7E9E","500":"#54577A","600":"#383B5C"},
      "semantic": {"success":"#4ADE80","danger":"#E04D6C","warning":"#C9A84A","info":"#7A5BA0"}
    },
    "typography": {
      "display":    {"family":"Fraunces","minSize":18,"weights":{"32+":200,"18-32":300}},
      "ui":         {"family":"Sora"},
      "body":       {"family":"Inter","weight":350},
      "mono":       {"family":"JetBrains Mono"}
    },
    "motion": {"duration":"320ms","easing":"cubic-bezier(0.16, 1, 0.3, 1)"},
    "hairline": {"width":"0.5px","opacity":0.18},
    "rules": {
      "goldUseRule": "max 1 occurrence per fold (CTA OR primary KPI)",
      "darkModeDefault": true,
      "noEmojiInProductCopy": true
    }
  }'::jsonb
) ON CONFLICT (version) DO NOTHING;

-- ─── AGENTS (8 oficiais) ──────────────────────────────────────────────────
INSERT INTO agents (slug, name, role, inspiration, bio_short, parent_slug, is_head, active) VALUES
('pulseh',  'Pulseh',  'CEO Orquestrador',     'Tallis Gomes',     'Empreendedor brasileiro, fundador da Singu e EasyTaxi. Orquestrador, nao executor.', NULL, FALSE, TRUE),
('donna',   'Donna',   'Secretaria Executiva', 'Donna Paulsen',    'Sarcastica com elegancia, leal ate o osso. Filtra o caos antes que chegue no chefe.', NULL, FALSE, TRUE),
('alfredo', 'Alfredo', 'VP Comercial',         'Alfredo Soares',   'Construiu maquina de vendas antes de virar grife. Marca sem venda e hobby.', NULL, FALSE, TRUE),
('caio',    'Caio',    'VP Vendas Diretas',    'Caio Carneiro',    'Mestre de vendas diretas. Linguagem reta, sem floreio.', NULL, FALSE, TRUE),
('flavia',  'Flavia',  'VP Produtos',          'Flavia Lippi',     'Especialista em produto educacional aplicado. Aluno e usuario, aula e produto.', NULL, FALSE, TRUE),
('falconi', 'Falconi', 'VP Operacoes',         'Vicente Falconi',  'Engenheiro brasileiro, fundador Falconi Consultores. PDCA virou padrao.', NULL, FALSE, TRUE),
('simon',   'Simon',   'VP People & Cultura',  'Simon Sinek',      'Comecar pelo porque. Cultura forte come estrategia no cafe da manha.', NULL, FALSE, TRUE),
('dalio',   'Dalio',   'VP Financeiro',        'Ray Dalio',        'Principios sobre tudo. Macro investidor, transparencia radical.', NULL, FALSE, TRUE)
ON CONFLICT (slug) DO NOTHING;

-- ─── HEADS (22 sub-agentes) ──────────────────────────────────────────────
INSERT INTO agents (slug, name, role, inspiration, parent_slug, is_head, active) VALUES
-- Alfredo (3)
('alfredo-betina',          'Betina',   'Head de Copy',                'Betina Carlini',    'alfredo', TRUE, TRUE),
('alfredo-mauricio',        'Mauricio', 'Head de Design',              'Mauricio Mendonca', 'alfredo', TRUE, TRUE),
('alfredo-leo-dias',        'Leo Dias', 'Head de Radar',               'Leo Dias',          'alfredo', TRUE, TRUE),
-- Caio (2)
('caio-hunter',             'Hunter',   'Head de Prospeccao',          'Hunter S.',         'caio',    TRUE, TRUE),
('caio-closer',             'Closer',   'Head de Fechamento',          'Closer',            'caio',    TRUE, TRUE),
-- Flavia (3)
('flavia-naming',           'Naming',   'Head de Naming/Branding Produto', 'Naming',        'flavia',  TRUE, TRUE),
('flavia-esteira',          'Esteira',  'Head de Esteira de Produtos', 'Esteira',           'flavia',  TRUE, TRUE),
('flavia-tendencias',       'Tendencias','Head de Tendencias',         'Trend',             'flavia',  TRUE, TRUE),
-- Falconi (6)
('falconi-metodologia',     'Metodologia','Head de Metodologia (PDCA aplicado)','Metodo',  'falconi', TRUE, TRUE),
('falconi-automacao',       'Automacao','Head de Automacoes',          'Auto',              'falconi', TRUE, TRUE),
('falconi-deploy',          'Deploy',   'Head de Deploy',              'Deploy',            'falconi', TRUE, TRUE),
('falconi-memoria',         'Memoria',  'Head de Memoria/Auditoria',   'Memoria',           'falconi', TRUE, TRUE),
('falconi-infra',           'Infra',    'Head de Infraestrutura',      'Pacheco',           'falconi', TRUE, TRUE),
('falconi-seguranca',       'Seguranca','Head de Seguranca',           'Sec',               'falconi', TRUE, TRUE),
-- Simon (4)
('simon-cultura',           'Cultura',  'Head de Cultura',             'Cultura',           'simon',   TRUE, TRUE),
('simon-curadoria-saber',   'Curadoria','Head de Curadoria de Saber',  'Curadoria',         'simon',   TRUE, TRUE),
('simon-recrutamento',      'Recrutamento','Head de Recrutamento',     'Recruta',           'simon',   TRUE, TRUE),
('simon-cs',                'CS',       'Head de Customer Success',    'CS',                'simon',   TRUE, TRUE),
-- Dalio (4)
('dalio-dre',               'DRE',      'Head de DRE',                 'DRE',               'dalio',   TRUE, TRUE),
('dalio-margem',            'Margem',   'Head de Margem & Pricing',    'Margem',            'dalio',   TRUE, TRUE),
('dalio-investimento',      'Investimento','Head de Investimento',     'Invest',            'dalio',   TRUE, TRUE),
('dalio-tesouraria',        'Tesouraria','Head de Tesouraria',         'Tesouro',           'dalio',   TRUE, TRUE)
ON CONFLICT (slug) DO NOTHING;

-- ─── SKILLS GENERALIZADAS (23 — fonte: /skills-template/) ────────────────
-- Cada skill aponta pra um agente owner. content e placeholder; render-pipeline
-- substitui {{tenant.*}} no runtime. Aqui salvamos so o titulo + slug — o
-- conteudo full vem com o repo via filesystem em /core/skills/.
INSERT INTO skill_references (slug, title, agent_slug, content, version) VALUES
('betina-copy',                'Betina — Copy AIDA/PAS/Bold Claim',          'alfredo-betina',         '# Betina — Copy\n\nFramework AIDA + PAS + Bold Claim. Conteudo full em /core/skills/betina-copy.md', 'v1'),
('branding-pulsar-geral',      'Branding & Manifesto Geral',                 'alfredo',                '# Branding\n\nManifesto + ICPs + vocabulario. Slots tenant.brand.*. Conteudo full em /core/skills/branding-pulsar-geral.md', 'v1'),
('caio-closer',                'Caio — Closer (Fechamento + Objections)',    'caio-closer',            '# Closer\n\nSPIN + objection handling. Conteudo full em /core/skills/caio-closer.md', 'v1'),
('caio-hunter',                'Caio — Hunter (Prospeccao Cold)',            'caio-hunter',            '# Hunter\n\nProspeccao ativa cold IG/email. Conteudo full em /core/skills/caio-hunter.md', 'v1'),
('cliente-onboarding-template','Pulse — Onboarding do Cliente (template)',   'pulseh',                 '# Onboarding template\n\nEntrevista 14 perguntas. Conteudo full em /core/skills/cliente-onboarding-template.md', 'v1'),
('dalio-dre',                  'Dalio — DRE',                                 'dalio-dre',              '# DRE\n\nEstrutura de DRE + KPIs financeiros. Conteudo full em /core/skills/dalio-dre.md', 'v1'),
('dalio-investimento',         'Dalio — Investimento',                        'dalio-investimento',     '# Investimento\n\nROI por campanha/produto. Conteudo full em /core/skills/dalio-investimento.md', 'v1'),
('dalio-margem',               'Dalio — Margem & Pricing',                    'dalio-margem',           '# Margem\n\nPricing methods + ancoragem. Conteudo full em /core/skills/dalio-margem.md', 'v1'),
('dalio-tesouraria',           'Dalio — Tesouraria',                          'dalio-tesouraria',       '# Tesouraria\n\nProjecoes & cenarios. Conteudo full em /core/skills/dalio-tesouraria.md', 'v1'),
('falconi-automacao',          'Falconi — Automacoes',                        'falconi-automacao',      '# Automacao\n\nN8N + cron + webhooks. Conteudo full em /core/skills/falconi-automacao.md', 'v1'),
('falconi-deploy',             'Falconi — Deploy',                            'falconi-deploy',         '# Deploy\n\nCI/CD + rollback + health checks. Conteudo full em /core/skills/falconi-deploy.md', 'v1'),
('falconi-infra',              'Falconi — Infraestrutura',                    'falconi-infra',          '# Infra\n\nVPS + docker + traefik. Conteudo full em /core/skills/falconi-infra.md', 'v1'),
('falconi-memoria',            'Falconi — Memoria/Auditoria',                 'falconi-memoria',        '# Memoria\n\nRitual semanal de auditoria. Conteudo full em /core/skills/falconi-memoria.md', 'v1'),
('falconi-metodologia',        'Falconi — Metodologia (PDCA aplicado)',       'falconi-metodologia',    '# Metodologia\n\nPDCA + metodo {{tenant.method.name}}. Conteudo full em /core/skills/falconi-metodologia.md', 'v1'),
('falconi-seguranca',          'Falconi — Seguranca',                         'falconi-seguranca',      '# Seguranca\n\nGit anti-destrutivo + secrets. Conteudo full em /core/skills/falconi-seguranca.md', 'v1'),
('flavia-esteira',             'Flavia — Esteira de Produtos',                'flavia-esteira',         '# Esteira\n\nFunil de produtos + LTV. Conteudo full em /core/skills/flavia-esteira.md', 'v1'),
('flavia-naming',              'Flavia — Naming',                             'flavia-naming',          '# Naming\n\nMetodologia de naming. Conteudo full em /core/skills/flavia-naming.md', 'v1'),
('flavia-tendencias',          'Flavia — Tendencias',                         'flavia-tendencias',      '# Tendencias\n\nRadar de tendencias produto. Conteudo full em /core/skills/flavia-tendencias.md', 'v1'),
('leo-dias-radar',             'Leo Dias — Radar Editorial',                  'alfredo-leo-dias',       '# Radar\n\n3 fontes (news/competitor/autoral) + 5 blocos. Conteudo full em /core/skills/leo-dias-radar.md', 'v1'),
('mauricio-design',            'Mauricio — Direcao de Arte',                  'alfredo-mauricio',       '# Design\n\nBrand v1.0 Half-Light + carrossel pipeline. Conteudo full em /core/skills/mauricio-design.md', 'v1'),
('simon-cs',                   'Simon — Customer Success',                    'simon-cs',               '# CS\n\nRetention + NPS + escalation. Conteudo full em /core/skills/simon-cs.md', 'v1'),
('simon-cultura',              'Simon — Cultura',                             'simon-cultura',          '# Cultura\n\nManifesto + rituais + golden circle. Conteudo full em /core/skills/simon-cultura.md', 'v1'),
('simon-curadoria-saber',      'Simon — Curadoria de Saber',                  'simon-curadoria-saber',  '# Curadoria\n\nKnowledge base + materiais. Conteudo full em /core/skills/simon-curadoria-saber.md', 'v1'),
('simon-recrutamento',         'Simon — Recrutamento',                        'simon-recrutamento',     '# Recrutamento\n\nFunil de recrutamento + ICP profissional. Conteudo full em /core/skills/simon-recrutamento.md', 'v1')
ON CONFLICT (slug) DO NOTHING;

-- ─── PROJETO DEFAULT — Onboarding Pulsar OS ──────────────────────────────
INSERT INTO projects (slug, name, description, goal, status) VALUES
('onboarding-pulsar-os',
 'Onboarding Pulsar OS',
 'Projeto inicial vazio. Pulse vai preencher iniciativas/tasks apos a entrevista de onboarding com o founder.',
 'Concluir entrevista de onboarding e gerar /tenant/CLAUDE.md em ate 7 dias',
 'active')
ON CONFLICT (slug) DO NOTHING;
