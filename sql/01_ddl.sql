-- PostgreSQL 17. Execute em uma base vazia e exclusiva da atividade.
-- Sem DROP: falha se os objetos ja existirem, preservando dados anteriores.
BEGIN;

CREATE TABLE product_type (
    code VARCHAR(20) CONSTRAINT pk_product_type PRIMARY KEY,
    label VARCHAR(80) NOT NULL,
    CONSTRAINT ck_product_type_code CHECK (btrim(code) <> ''),
    CONSTRAINT ck_product_type_label CHECK (btrim(label) <> '')
);

CREATE TABLE product (
    product_id UUID DEFAULT gen_random_uuid() CONSTRAINT pk_product PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    description TEXT,
    type_code VARCHAR(20) NOT NULL,
    price NUMERIC(12,2) NOT NULL,
    CONSTRAINT ck_product_name CHECK (btrim(name) <> ''),
    CONSTRAINT ck_product_price CHECK (price >= 0),
    CONSTRAINT fk_product_type FOREIGN KEY (type_code)
        REFERENCES product_type (code)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_product_type_code ON product (type_code);

COMMIT;
