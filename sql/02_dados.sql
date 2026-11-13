-- Dados ficticios. As chaves dos tipos preservam os nomes do enum ProductType.
BEGIN;

INSERT INTO product_type (code, label) VALUES
    ('ELECTRONICS', 'Eletronicos'),
    ('FOOD', 'Alimentos'),
    ('CLOTHING', 'Vestuario'),
    ('FURNITURE', 'Moveis'),
    ('BEAUTY', 'Beleza'),
    ('SPORTS', 'Esportes'),
    ('BOOKS', 'Livros'),
    ('OTHER', 'Outros');

INSERT INTO product (product_id, name, description, type_code, price) VALUES
    ('11111111-1111-4111-8111-111111111111', 'Teclado USB', 'Teclado para computador', 'ELECTRONICS', 120.00),
    ('22222222-2222-4222-8222-222222222222', 'Mouse USB', 'Mouse optico', 'ELECTRONICS', 60.00),
    ('33333333-3333-4333-8333-333333333333', 'Livro de SQL', 'Introducao a bancos relacionais', 'BOOKS', 85.00);

COMMIT;
