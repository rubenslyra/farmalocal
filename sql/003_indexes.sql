USE [farmalocal];
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_fabricante_cnpj_not_null' AND object_id = OBJECT_ID(N'farmalocal.fabricante'))
    CREATE UNIQUE INDEX UX_fabricante_cnpj_not_null ON farmalocal.fabricante(cnpj) WHERE cnpj IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_fornecedor_cnpj_not_null' AND object_id = OBJECT_ID(N'farmalocal.fornecedor'))
    CREATE UNIQUE INDEX UX_fornecedor_cnpj_not_null ON farmalocal.fornecedor(cnpj) WHERE cnpj IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_cliente_cpf_not_null' AND object_id = OBJECT_ID(N'farmalocal.cliente'))
    CREATE UNIQUE INDEX UX_cliente_cpf_not_null ON farmalocal.cliente(cpf) WHERE cpf IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_produto_apresentacao_ean_not_null' AND object_id = OBJECT_ID(N'farmalocal.produto_apresentacao'))
    CREATE UNIQUE INDEX UX_produto_apresentacao_ean_not_null ON farmalocal.produto_apresentacao(codigo_ean) WHERE codigo_ean IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_produto_nome_comercial' AND object_id = OBJECT_ID(N'farmalocal.produto'))
    CREATE INDEX IX_produto_nome_comercial ON farmalocal.produto(nome_comercial);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_produto_nome_reduzido' AND object_id = OBJECT_ID(N'farmalocal.produto'))
    CREATE INDEX IX_produto_nome_reduzido ON farmalocal.produto(nome_reduzido);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_produto_categoria_fabricante' AND object_id = OBJECT_ID(N'farmalocal.produto'))
    CREATE INDEX IX_produto_categoria_fabricante ON farmalocal.produto(categoria_id, fabricante_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_produto_apresentacao_produto_id' AND object_id = OBJECT_ID(N'farmalocal.produto_apresentacao'))
    CREATE INDEX IX_produto_apresentacao_produto_id ON farmalocal.produto_apresentacao(produto_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_produto_apresentacao_descricao' AND object_id = OBJECT_ID(N'farmalocal.produto_apresentacao'))
    CREATE INDEX IX_produto_apresentacao_descricao ON farmalocal.produto_apresentacao(descricao_apresentacao);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_substancia_ativa_nome' AND object_id = OBJECT_ID(N'farmalocal.substancia_ativa'))
    CREATE INDEX IX_substancia_ativa_nome ON farmalocal.substancia_ativa(nome);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_apresentacao_substancia_substancia' AND object_id = OBJECT_ID(N'farmalocal.apresentacao_substancia'))
    CREATE INDEX IX_apresentacao_substancia_substancia ON farmalocal.apresentacao_substancia(substancia_ativa_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_apresentacao_substancia_apresentacao' AND object_id = OBJECT_ID(N'farmalocal.apresentacao_substancia'))
    CREATE INDEX IX_apresentacao_substancia_apresentacao ON farmalocal.apresentacao_substancia(apresentacao_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_lote_filial_apresentacao' AND object_id = OBJECT_ID(N'farmalocal.lote_estoque'))
    CREATE INDEX IX_lote_filial_apresentacao ON farmalocal.lote_estoque(filial_id, apresentacao_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_lote_filial_validade' AND object_id = OBJECT_ID(N'farmalocal.lote_estoque'))
    CREATE INDEX IX_lote_filial_validade ON farmalocal.lote_estoque(filial_id, data_validade);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_lote_apresentacao_validade' AND object_id = OBJECT_ID(N'farmalocal.lote_estoque'))
    CREATE INDEX IX_lote_apresentacao_validade ON farmalocal.lote_estoque(apresentacao_id, data_validade);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_lote_numero' AND object_id = OBJECT_ID(N'farmalocal.lote_estoque'))
    CREATE INDEX IX_lote_numero ON farmalocal.lote_estoque(numero_lote);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_movimento_lote' AND object_id = OBJECT_ID(N'farmalocal.movimento_estoque'))
    CREATE INDEX IX_movimento_lote ON farmalocal.movimento_estoque(lote_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_movimento_data' AND object_id = OBJECT_ID(N'farmalocal.movimento_estoque'))
    CREATE INDEX IX_movimento_data ON farmalocal.movimento_estoque(data_movimento);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_venda_filial' AND object_id = OBJECT_ID(N'farmalocal.venda'))
    CREATE INDEX IX_venda_filial ON farmalocal.venda(filial_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_venda_cliente' AND object_id = OBJECT_ID(N'farmalocal.venda'))
    CREATE INDEX IX_venda_cliente ON farmalocal.venda(cliente_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_venda_usuario' AND object_id = OBJECT_ID(N'farmalocal.venda'))
    CREATE INDEX IX_venda_usuario ON farmalocal.venda(usuario_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_venda_data_hora' AND object_id = OBJECT_ID(N'farmalocal.venda'))
    CREATE INDEX IX_venda_data_hora ON farmalocal.venda(data_hora);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_venda_filial_data_hora' AND object_id = OBJECT_ID(N'farmalocal.venda'))
    CREATE INDEX IX_venda_filial_data_hora ON farmalocal.venda(filial_id, data_hora);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_venda_item_venda' AND object_id = OBJECT_ID(N'farmalocal.venda_item'))
    CREATE INDEX IX_venda_item_venda ON farmalocal.venda_item(venda_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_venda_item_apresentacao' AND object_id = OBJECT_ID(N'farmalocal.venda_item'))
    CREATE INDEX IX_venda_item_apresentacao ON farmalocal.venda_item(apresentacao_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_venda_item_lote' AND object_id = OBJECT_ID(N'farmalocal.venda_item'))
    CREATE INDEX IX_venda_item_lote ON farmalocal.venda_item(lote_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_pagamento_venda' AND object_id = OBJECT_ID(N'farmalocal.pagamento'))
    CREATE INDEX IX_pagamento_venda ON farmalocal.pagamento(venda_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_pagamento_tipo' AND object_id = OBJECT_ID(N'farmalocal.pagamento'))
    CREATE INDEX IX_pagamento_tipo ON farmalocal.pagamento(tipo_pagamento);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_receita_cpf_paciente' AND object_id = OBJECT_ID(N'farmalocal.receita_venda_item'))
    CREATE INDEX IX_receita_cpf_paciente ON farmalocal.receita_venda_item(cpf_paciente);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_receita_crm' AND object_id = OBJECT_ID(N'farmalocal.receita_venda_item'))
    CREATE INDEX IX_receita_crm ON farmalocal.receita_venda_item(crm);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_receita_data_emissao' AND object_id = OBJECT_ID(N'farmalocal.receita_venda_item'))
    CREATE INDEX IX_receita_data_emissao ON farmalocal.receita_venda_item(data_emissao_receita);
GO
