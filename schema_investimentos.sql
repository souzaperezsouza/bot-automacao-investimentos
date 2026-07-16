BEGIN;

CREATE TABLE IF NOT EXISTS compras (
    id SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    ativo VARCHAR(80) NOT NULL,
    tipo_investimento VARCHAR(30) NOT NULL,
    corretora VARCHAR(60) NOT NULL,
    quantidade NUMERIC(20,8) NOT NULL CHECK (quantidade > 0),
    preco_unitario NUMERIC(18,6) NOT NULL CHECK (preco_unitario >= 0),
    valor_total NUMERIC(18,2) NOT NULL CHECK (valor_total >= 0),
    observacao TEXT,
    criado_em TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS vendas (
    id SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    ativo VARCHAR(80) NOT NULL,
    tipo_investimento VARCHAR(30),
    corretora VARCHAR(60) NOT NULL,
    quantidade NUMERIC(20,8) NOT NULL CHECK (quantidade > 0),
    preco_unitario NUMERIC(18,6) NOT NULL CHECK (preco_unitario >= 0),
    valor_total NUMERIC(18,2) NOT NULL CHECK (valor_total >= 0),
    custo_medio_unitario NUMERIC(18,6) NOT NULL DEFAULT 0,
    custo_total NUMERIC(18,2) NOT NULL DEFAULT 0,
    lucro_prejuizo NUMERIC(18,2) NOT NULL DEFAULT 0,
    criado_em TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS proventos (
    id SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    ativo VARCHAR(80) NOT NULL,
    corretora VARCHAR(60) NOT NULL,
    tipo_provento VARCHAR(20) NOT NULL,
    valor_recebido NUMERIC(18,2) NOT NULL CHECK (valor_recebido >= 0),
    criado_em TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS configuracoes (
    chave VARCHAR(50) PRIMARY KEY,
    valor TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_compras_ativo_data ON compras (ativo, data, id);
CREATE INDEX IF NOT EXISTS idx_vendas_ativo_data ON vendas (ativo, data, id);
CREATE INDEX IF NOT EXISTS idx_proventos_ativo_data ON proventos (ativo, data, id);
CREATE INDEX IF NOT EXISTS idx_compras_corretora ON compras (corretora);
CREATE INDEX IF NOT EXISTS idx_vendas_corretora ON vendas (corretora);
CREATE INDEX IF NOT EXISTS idx_proventos_corretora ON proventos (corretora);

COMMIT;
