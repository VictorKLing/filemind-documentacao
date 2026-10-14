-- Protótipo do banco de dados do FileMind.
-- Modelo correspondente às entidades Usuario e Arquivo observadas em 14/10/2026.
-- Este arquivo não contém DROP e não é executado automaticamente pelo backend.

CREATE TABLE IF NOT EXISTS tb_usuarios (
    id_usuario BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(100) NOT NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    senha VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS tb_arquivos (
    id_arquivo BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    nome_arquivo VARCHAR(255) NOT NULL,
    extensao_arquivo VARCHAR(10) NOT NULL,
    tipo_mime VARCHAR(100),
    tamanho_bytes BIGINT,
    s3_key VARCHAR(1024) NOT NULL UNIQUE,
    metadados JSONB,
    status_rag VARCHAR(20) NOT NULL DEFAULT 'ENVIADO',

    CONSTRAINT fk_arquivos_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES tb_usuarios (id_usuario)
        ON DELETE RESTRICT,

    CONSTRAINT ck_arquivos_tamanho
        CHECK (tamanho_bytes IS NULL OR tamanho_bytes >= 0),

    CONSTRAINT ck_arquivos_extensao
        CHECK (extensao_arquivo IN ('PDF', 'DOCX', 'TXT', 'XLSX', 'MD')),

    CONSTRAINT ck_arquivos_status_rag
        CHECK (status_rag IN ('ENVIADO', 'PROCESSANDO', 'PROCESSADO', 'ERRO'))
);

CREATE INDEX IF NOT EXISTS idx_arquivos_usuario_id
    ON tb_arquivos (usuario_id);

CREATE INDEX IF NOT EXISTS idx_arquivos_status_rag
    ON tb_arquivos (status_rag);

COMMENT ON TABLE tb_usuarios IS
    'Usuarios proprietarios dos arquivos do FileMind.';

COMMENT ON TABLE tb_arquivos IS
    'Metadados dos arquivos armazenados no S3; o conteudo binario nao fica no PostgreSQL.';
