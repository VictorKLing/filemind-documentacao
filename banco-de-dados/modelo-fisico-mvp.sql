-- Modelo físico de referência do FileMind MVP.
-- Data: 29/10/2026.
-- Não é uma migração e não deve ser executado automaticamente sobre o banco atual.
-- A dimensão do vetor será fixada depois da escolha do modelo de embeddings.

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS tb_usuarios (
    id_usuario BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(100) NOT NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tb_arquivos (
    id_arquivo BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    nome_arquivo VARCHAR(255) NOT NULL,
    caminho_virtual VARCHAR(1024) NOT NULL,
    extensao_arquivo VARCHAR(10) NOT NULL,
    tipo_mime VARCHAR(100),
    tamanho_bytes BIGINT NOT NULL,
    hash_conteudo CHAR(64) NOT NULL,
    s3_key VARCHAR(1024) NOT NULL UNIQUE,
    metadados JSONB NOT NULL DEFAULT '{}'::jsonb,
    status_rag VARCHAR(20) NOT NULL DEFAULT 'ENVIADO',
    erro_processamento VARCHAR(1000),
    criado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_arquivos_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES tb_usuarios (id_usuario)
        ON DELETE RESTRICT,

    CONSTRAINT uk_arquivos_usuario_caminho
        UNIQUE (usuario_id, caminho_virtual),

    CONSTRAINT ck_arquivos_tamanho
        CHECK (tamanho_bytes >= 0),

    CONSTRAINT ck_arquivos_hash_sha256
        CHECK (hash_conteudo ~ '^[0-9a-fA-F]{64}$'),

    CONSTRAINT ck_arquivos_extensao
        CHECK (extensao_arquivo = 'MD'),

    CONSTRAINT ck_arquivos_status_rag
        CHECK (status_rag IN ('ENVIADO', 'PROCESSANDO', 'PROCESSADO', 'ERRO'))
);

CREATE TABLE IF NOT EXISTS tb_chunks_arquivo (
    id_chunk BIGSERIAL PRIMARY KEY,
    arquivo_id BIGINT NOT NULL,
    indice INTEGER NOT NULL,
    conteudo TEXT NOT NULL,
    embedding vector NOT NULL,
    metadados JSONB NOT NULL DEFAULT '{}'::jsonb,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_chunks_arquivo
        FOREIGN KEY (arquivo_id)
        REFERENCES tb_arquivos (id_arquivo)
        ON DELETE CASCADE,

    CONSTRAINT uk_chunks_arquivo_indice
        UNIQUE (arquivo_id, indice),

    CONSTRAINT ck_chunks_indice
        CHECK (indice >= 0),

    CONSTRAINT ck_chunks_conteudo
        CHECK (length(btrim(conteudo)) > 0)
);

CREATE INDEX IF NOT EXISTS idx_arquivos_usuario_id
    ON tb_arquivos (usuario_id);

CREATE INDEX IF NOT EXISTS idx_arquivos_usuario_status
    ON tb_arquivos (usuario_id, status_rag);

CREATE INDEX IF NOT EXISTS idx_chunks_arquivo_id
    ON tb_chunks_arquivo (arquivo_id);

-- Índice vetorial intencionalmente pendente.
-- Depois de escolher o modelo de embeddings, fixar embedding como vector(N)
-- e avaliar HNSW ou IVFFlat conforme o volume e a estratégia de busca.

COMMENT ON COLUMN tb_usuarios.senha IS
    'Hash seguro da senha; nunca armazenar senha em texto puro.';

COMMENT ON COLUMN tb_arquivos.caminho_virtual IS
    'Caminho completo apresentado no FileMind, independente da chave S3.';

COMMENT ON COLUMN tb_arquivos.s3_key IS
    'Identificador interno do objeto no S3; não expor ao frontend.';

COMMENT ON COLUMN tb_arquivos.hash_conteudo IS
    'SHA-256 do conteúdo atual, usado para detectar reprocessamento da mesma versão.';

COMMENT ON COLUMN tb_chunks_arquivo.embedding IS
    'Vetor sem dimensão fixa enquanto o modelo de embeddings não estiver definido.';
