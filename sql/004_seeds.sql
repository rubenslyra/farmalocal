USE [farmalocal];
GO

MERGE farmalocal.categoria AS target
USING (VALUES
    ('Medicamento', 'Medicamentos em geral', 1, 1),
    ('Higiene', 'Itens de higiene pessoal', 0, 0),
    ('Perfumaria', 'Itens de perfumaria', 0, 0),
    ('Equipamento', 'Equipamentos e aparelhos', 0, 0),
    ('Correlato', 'Itens correlatos farmacêuticos', 1, 1),
    ('Suplemento', 'Vitaminas e suplementos', 1, 1)
) AS src(nome, descricao, controla_lote, exige_validade)
ON target.nome = src.nome
WHEN NOT MATCHED THEN
    INSERT (nome, descricao, controla_lote, exige_validade, ativo, data_criacao)
    VALUES (src.nome, src.descricao, src.controla_lote, src.exige_validade, 1, SYSDATETIME());
GO

MERGE farmalocal.convenio AS target
USING (VALUES
    ('PARTICULAR', NULL),
    ('FARMACIA_POPULAR', NULL)
) AS src(nome, percentual_desconto)
ON target.nome = src.nome
WHEN NOT MATCHED THEN
    INSERT (nome, percentual_desconto, ativo, data_criacao)
    VALUES (src.nome, src.percentual_desconto, 1, SYSDATETIME());
GO

IF NOT EXISTS (SELECT 1 FROM farmalocal.filial WHERE codigo = 'MATRIZ')
BEGIN
    INSERT INTO farmalocal.filial (codigo, nome, ativo, data_criacao)
    VALUES ('MATRIZ', 'FarmaLocal Matriz', 1, SYSDATETIME());
END
GO

IF NOT EXISTS (SELECT 1 FROM farmalocal.usuario WHERE login = 'admin')
BEGIN
    INSERT INTO farmalocal.usuario
    (
        filial_id, nome, email, login, senha_hash, perfil, ativo, data_criacao
    )
    SELECT TOP (1)
        f.id,
        'Administrador',
        'admin@farmalocal.local',
        'admin',
        'HASH_AQUI',
        'ADMIN',
        1,
        SYSDATETIME()
    FROM farmalocal.filial f
    WHERE f.codigo = 'MATRIZ';
END
GO
