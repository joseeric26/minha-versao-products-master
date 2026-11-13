-- Execute depois do DDL e da carga inicial, em uma base exclusiva da atividade.
BEGIN;

DO $$
BEGIN
    IF (SELECT count(*) FROM product p JOIN product_type t ON t.code = p.type_code) <> 3 THEN
        RAISE EXCEPTION 'FALHOU: esperados tres produtos relacionados';
    END IF;
    IF (SELECT count(*) FROM product_type) <> 8 THEN
        RAISE EXCEPTION 'FALHOU: esperados os oito tipos do enum original';
    END IF;
    RAISE NOTICE 'PASSOU: tres produtos relacionados e oito tipos cadastrados';
END $$;

DO $$
DECLARE detalhe text; restricao text;
BEGIN
    BEGIN
        INSERT INTO product (product_id, name, description, type_code, price)
        VALUES ('99999999-9999-4999-8999-999999999999', 'Produto invalido', 'Teste de FK', 'INEXISTENTE', 10.00);
        RAISE EXCEPTION 'FALHOU: FK inexistente foi aceita';
    EXCEPTION WHEN foreign_key_violation THEN
        GET STACKED DIAGNOSTICS detalhe = PG_EXCEPTION_DETAIL, restricao = CONSTRAINT_NAME;
        IF restricao <> 'fk_product_type' THEN RAISE; END IF;
        RAISE NOTICE 'PASSOU: FK inexistente rejeitada | SQLSTATE % | % | %', SQLSTATE, SQLERRM, detalhe;
    END;

    BEGIN
        INSERT INTO product (product_id, name, description, type_code, price)
        VALUES ('11111111-1111-4111-8111-111111111111', 'Produto duplicado', 'Teste de PK', 'BOOKS', 20.00);
        RAISE EXCEPTION 'FALHOU: PK duplicada foi aceita';
    EXCEPTION WHEN unique_violation THEN
        GET STACKED DIAGNOSTICS detalhe = PG_EXCEPTION_DETAIL, restricao = CONSTRAINT_NAME;
        IF restricao <> 'pk_product' THEN RAISE; END IF;
        RAISE NOTICE 'PASSOU: PK duplicada rejeitada | SQLSTATE % | % | %', SQLSTATE, SQLERRM, detalhe;
    END;

    BEGIN
        DELETE FROM product_type WHERE code = 'ELECTRONICS';
        RAISE EXCEPTION 'FALHOU: exclusao deixou produtos orfaos';
    EXCEPTION WHEN foreign_key_violation THEN
        GET STACKED DIAGNOSTICS detalhe = PG_EXCEPTION_DETAIL, restricao = CONSTRAINT_NAME;
        IF restricao <> 'fk_product_type' THEN RAISE; END IF;
        RAISE NOTICE 'PASSOU: exclusao de tipo referenciado rejeitada | SQLSTATE % | % | %', SQLSTATE, SQLERRM, detalhe;
    END;

    BEGIN
        INSERT INTO product (product_id, name, type_code, price)
        VALUES ('88888888-8888-4888-8888-888888888888', 'Preco invalido', 'BOOKS', -1.00);
        RAISE EXCEPTION 'FALHOU: preco negativo foi aceito';
    EXCEPTION WHEN check_violation THEN
        GET STACKED DIAGNOSTICS restricao = CONSTRAINT_NAME;
        IF restricao <> 'ck_product_price' THEN RAISE; END IF;
        RAISE NOTICE 'PASSOU: preco negativo rejeitado | SQLSTATE %', SQLSTATE;
    END;

    IF (SELECT count(*) FROM product) <> 3 OR (SELECT count(*) FROM product_type) <> 8 THEN
        RAISE EXCEPTION 'FALHOU: dados alterados apos os testes';
    END IF;
    RAISE NOTICE 'PASSOU: dados preservados apos os testes';
END $$;

SELECT p.product_id, p.name, p.price, t.code AS type_code, t.label AS type_label
FROM product p JOIN product_type t ON t.code = p.type_code ORDER BY p.product_id;

SELECT 'product_type' AS tabela, count(*) AS registros FROM product_type
UNION ALL
SELECT 'product', count(*) FROM product;

COMMIT;
