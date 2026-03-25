USE [farmalocal];
GO

IF OBJECT_ID(N'farmalocal.filial', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.filial
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        codigo VARCHAR(20) NOT NULL,
        nome VARCHAR(150) NOT NULL,
        cnpj VARCHAR(18) NULL,
        telefone VARCHAR(20) NULL,
        email VARCHAR(150) NULL,
        cep VARCHAR(9) NULL,
        logradouro VARCHAR(150) NULL,
        numero VARCHAR(20) NULL,
        complemento VARCHAR(100) NULL,
        bairro VARCHAR(100) NULL,
        cidade VARCHAR(100) NULL,
        uf CHAR(2) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_filial_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_filial_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_filial PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_filial_codigo UNIQUE (codigo),
        CONSTRAINT CK_filial_uf CHECK (uf IS NULL OR LEN(uf) = 2)
    );
END
GO

IF OBJECT_ID(N'farmalocal.categoria', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.categoria
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        nome VARCHAR(100) NOT NULL,
        descricao VARCHAR(255) NULL,
        controla_lote BIT NOT NULL CONSTRAINT DF_categoria_controla_lote DEFAULT (0),
        exige_validade BIT NOT NULL CONSTRAINT DF_categoria_exige_validade DEFAULT (0),
        ativo BIT NOT NULL CONSTRAINT DF_categoria_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_categoria_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_categoria PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_categoria_nome UNIQUE (nome)
    );
END
GO

IF OBJECT_ID(N'farmalocal.fabricante', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.fabricante
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        razao_social VARCHAR(150) NOT NULL,
        nome_fantasia VARCHAR(150) NULL,
        cnpj VARCHAR(18) NULL,
        telefone VARCHAR(20) NULL,
        email VARCHAR(150) NULL,
        site_url VARCHAR(255) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_fabricante_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_fabricante_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_fabricante PRIMARY KEY CLUSTERED (id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.fornecedor', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.fornecedor
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        razao_social VARCHAR(150) NOT NULL,
        nome_fantasia VARCHAR(150) NULL,
        cnpj VARCHAR(18) NULL,
        telefone VARCHAR(20) NULL,
        email VARCHAR(150) NULL,
        contato_nome VARCHAR(100) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_fornecedor_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_fornecedor_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_fornecedor PRIMARY KEY CLUSTERED (id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.substancia_ativa', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.substancia_ativa
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        nome VARCHAR(150) NOT NULL,
        descricao VARCHAR(255) NULL,
        codigo_referencia VARCHAR(50) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_substancia_ativa_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_substancia_ativa_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_substancia_ativa PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_substancia_ativa_nome UNIQUE (nome)
    );
END
GO

IF OBJECT_ID(N'farmalocal.cliente', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.cliente
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        nome VARCHAR(150) NOT NULL,
        cpf VARCHAR(14) NULL,
        data_nascimento DATE NULL,
        telefone VARCHAR(20) NULL,
        email VARCHAR(150) NULL,
        observacoes VARCHAR(500) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_cliente_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_cliente_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_cliente PRIMARY KEY CLUSTERED (id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.convenio', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.convenio
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        nome VARCHAR(150) NOT NULL,
        percentual_desconto DECIMAL(5,2) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_convenio_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_convenio_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_convenio PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_convenio_nome UNIQUE (nome),
        CONSTRAINT CK_convenio_percentual CHECK (percentual_desconto IS NULL OR (percentual_desconto >= 0 AND percentual_desconto <= 100))
    );
END
GO

IF OBJECT_ID(N'farmalocal.usuario', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.usuario
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        filial_id BIGINT NOT NULL,
        nome VARCHAR(150) NOT NULL,
        email VARCHAR(150) NOT NULL,
        login VARCHAR(80) NOT NULL,
        senha_hash VARCHAR(255) NOT NULL,
        perfil VARCHAR(50) NOT NULL,
        ativo BIT NOT NULL CONSTRAINT DF_usuario_ativo DEFAULT (1),
        ultimo_acesso_em DATETIME2(0) NULL,
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_usuario_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_usuario PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_usuario_email UNIQUE (email),
        CONSTRAINT UQ_usuario_login UNIQUE (login),
        CONSTRAINT CK_usuario_perfil CHECK (perfil IN ('ADMIN','GERENTE','FARMACEUTICO','CAIXA','ESTOQUISTA')),
        CONSTRAINT FK_usuario_filial FOREIGN KEY (filial_id) REFERENCES farmalocal.filial(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.produto', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.produto
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        categoria_id BIGINT NOT NULL,
        fabricante_id BIGINT NOT NULL,
        codigo_interno VARCHAR(30) NOT NULL,
        nome_comercial VARCHAR(150) NULL,
        nome_reduzido VARCHAR(120) NOT NULL,
        descricao VARCHAR(255) NULL,
        tipo_produto VARCHAR(30) NOT NULL,
        ativo BIT NOT NULL CONSTRAINT DF_produto_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_produto_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_produto PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_produto_codigo_interno UNIQUE (codigo_interno),
        CONSTRAINT CK_produto_tipo CHECK (tipo_produto IN ('MEDICAMENTO','HIGIENE','PERFUMARIA','EQUIPAMENTO','CORRELATO','SUPLEMENTO')),
        CONSTRAINT FK_produto_categoria FOREIGN KEY (categoria_id) REFERENCES farmalocal.categoria(id),
        CONSTRAINT FK_produto_fabricante FOREIGN KEY (fabricante_id) REFERENCES farmalocal.fabricante(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.produto_apresentacao', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.produto_apresentacao
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        produto_id BIGINT NOT NULL,
        codigo_ean VARCHAR(20) NULL,
        sku_interno VARCHAR(40) NOT NULL,
        unidade_medida VARCHAR(20) NOT NULL,
        quantidade_embalagem DECIMAL(12,3) NULL,
        forma_farmaceutica VARCHAR(50) NULL,
        dosagem_texto VARCHAR(80) NULL,
        volume_texto VARCHAR(80) NULL,
        concentracao_texto VARCHAR(80) NULL,
        descricao_apresentacao VARCHAR(255) NOT NULL,
        preco_venda DECIMAL(14,2) NOT NULL,
        permite_fracionamento BIT NOT NULL CONSTRAINT DF_produto_apresentacao_perm_fr DEFAULT (0),
        ativo BIT NOT NULL CONSTRAINT DF_produto_apresentacao_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_produto_apresentacao_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_produto_apresentacao PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_produto_apresentacao_sku UNIQUE (sku_interno),
        CONSTRAINT CK_produto_apresentacao_preco CHECK (preco_venda >= 0),
        CONSTRAINT FK_produto_apresentacao_produto FOREIGN KEY (produto_id) REFERENCES farmalocal.produto(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.apresentacao_substancia', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.apresentacao_substancia
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        apresentacao_id BIGINT NOT NULL,
        substancia_ativa_id BIGINT NOT NULL,
        concentracao DECIMAL(12,4) NULL,
        unidade_concentracao VARCHAR(20) NULL,
        principal BIT NOT NULL CONSTRAINT DF_apresentacao_substancia_principal DEFAULT (0),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_apresentacao_substancia_data_criacao DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_apresentacao_substancia PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_apresentacao_substancia UNIQUE (apresentacao_id, substancia_ativa_id),
        CONSTRAINT FK_apresentacao_substancia_apresentacao FOREIGN KEY (apresentacao_id) REFERENCES farmalocal.produto_apresentacao(id),
        CONSTRAINT FK_apresentacao_substancia_substancia FOREIGN KEY (substancia_ativa_id) REFERENCES farmalocal.substancia_ativa(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.medicamento_detalhe', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.medicamento_detalhe
    (
        apresentacao_id BIGINT NOT NULL,
        tipo_medicamento VARCHAR(20) NOT NULL,
        registro_anvisa VARCHAR(50) NULL,
        tarja VARCHAR(20) NOT NULL,
        requer_receita BIT NOT NULL CONSTRAINT DF_medicamento_detalhe_requer_receita DEFAULT (0),
        retencao_receita BIT NOT NULL CONSTRAINT DF_medicamento_detalhe_retencao_receita DEFAULT (0),
        controlado_sngpc BIT NOT NULL CONSTRAINT DF_medicamento_detalhe_controlado DEFAULT (0),
        antimicrobiano BIT NOT NULL CONSTRAINT DF_medicamento_detalhe_antimicrobiano DEFAULT (0),
        uso_continuo BIT NOT NULL CONSTRAINT DF_medicamento_detalhe_uso_continuo DEFAULT (0),
        permite_intercambialidade BIT NOT NULL CONSTRAINT DF_medicamento_detalhe_perm_interc DEFAULT (1),
        observacoes VARCHAR(500) NULL,
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_medicamento_detalhe_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_medicamento_detalhe PRIMARY KEY CLUSTERED (apresentacao_id),
        CONSTRAINT CK_medicamento_detalhe_tipo CHECK (tipo_medicamento IN ('REFERENCIA','GENERICO','SIMILAR')),
        CONSTRAINT CK_medicamento_detalhe_tarja CHECK (tarja IN ('SEM_TARJA','AMARELA','VERMELHA','PRETA')),
        CONSTRAINT FK_medicamento_detalhe_apresentacao FOREIGN KEY (apresentacao_id) REFERENCES farmalocal.produto_apresentacao(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.equipamento_detalhe', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.equipamento_detalhe
    (
        apresentacao_id BIGINT NOT NULL,
        garantia_meses INT NULL,
        possui_registro_anvisa BIT NOT NULL CONSTRAINT DF_equipamento_detalhe_possui_reg DEFAULT (0),
        numero_registro_anvisa VARCHAR(50) NULL,
        voltagem VARCHAR(30) NULL,
        manual_url VARCHAR(255) NULL,
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_equipamento_detalhe_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_equipamento_detalhe PRIMARY KEY CLUSTERED (apresentacao_id),
        CONSTRAINT CK_equipamento_detalhe_garantia CHECK (garantia_meses IS NULL OR garantia_meses >= 0),
        CONSTRAINT FK_equipamento_detalhe_apresentacao FOREIGN KEY (apresentacao_id) REFERENCES farmalocal.produto_apresentacao(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.produto_atributo_extra', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.produto_atributo_extra
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        apresentacao_id BIGINT NOT NULL,
        nome_atributo VARCHAR(100) NOT NULL,
        valor_atributo VARCHAR(255) NOT NULL,
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_produto_atributo_extra_data_criacao DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_produto_atributo_extra PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_produto_atributo_extra UNIQUE (apresentacao_id, nome_atributo),
        CONSTRAINT FK_produto_atributo_extra_apresentacao FOREIGN KEY (apresentacao_id) REFERENCES farmalocal.produto_apresentacao(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.cliente_convenio', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.cliente_convenio
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        cliente_id BIGINT NOT NULL,
        convenio_id BIGINT NOT NULL,
        matricula VARCHAR(50) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_cliente_convenio_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_cliente_convenio_data_criacao DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_cliente_convenio PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_cliente_convenio UNIQUE (cliente_id, convenio_id),
        CONSTRAINT FK_cliente_convenio_cliente FOREIGN KEY (cliente_id) REFERENCES farmalocal.cliente(id),
        CONSTRAINT FK_cliente_convenio_convenio FOREIGN KEY (convenio_id) REFERENCES farmalocal.convenio(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.lote_estoque', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.lote_estoque
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        filial_id BIGINT NOT NULL,
        apresentacao_id BIGINT NOT NULL,
        fornecedor_id BIGINT NULL,
        numero_lote VARCHAR(60) NOT NULL,
        data_fabricacao DATE NULL,
        data_validade DATE NULL,
        quantidade_atual DECIMAL(14,3) NOT NULL,
        quantidade_reservada DECIMAL(14,3) NOT NULL CONSTRAINT DF_lote_estoque_qtd_res DEFAULT (0),
        custo_unitario DECIMAL(14,4) NULL,
        ativo BIT NOT NULL CONSTRAINT DF_lote_estoque_ativo DEFAULT (1),
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_lote_estoque_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_lote_estoque PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_lote_estoque UNIQUE (filial_id, apresentacao_id, numero_lote),
        CONSTRAINT CK_lote_estoque_qtd_atual CHECK (quantidade_atual >= 0),
        CONSTRAINT CK_lote_estoque_qtd_reservada CHECK (quantidade_reservada >= 0),
        CONSTRAINT CK_lote_estoque_custo CHECK (custo_unitario IS NULL OR custo_unitario >= 0),
        CONSTRAINT CK_lote_estoque_datas CHECK (data_fabricacao IS NULL OR data_validade IS NULL OR data_validade >= data_fabricacao),
        CONSTRAINT FK_lote_estoque_filial FOREIGN KEY (filial_id) REFERENCES farmalocal.filial(id),
        CONSTRAINT FK_lote_estoque_apresentacao FOREIGN KEY (apresentacao_id) REFERENCES farmalocal.produto_apresentacao(id),
        CONSTRAINT FK_lote_estoque_fornecedor FOREIGN KEY (fornecedor_id) REFERENCES farmalocal.fornecedor(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.movimento_estoque', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.movimento_estoque
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        lote_id BIGINT NOT NULL,
        tipo_movimento VARCHAR(30) NOT NULL,
        quantidade DECIMAL(14,3) NOT NULL,
        documento_referencia VARCHAR(80) NULL,
        origem VARCHAR(50) NOT NULL,
        observacoes VARCHAR(500) NULL,
        usuario_id BIGINT NULL,
        data_movimento DATETIME2(0) NOT NULL CONSTRAINT DF_movimento_estoque_data DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_movimento_estoque PRIMARY KEY CLUSTERED (id),
        CONSTRAINT CK_movimento_estoque_tipo CHECK (tipo_movimento IN ('ENTRADA','SAIDA','AJUSTE_POSITIVO','AJUSTE_NEGATIVO','CANCELAMENTO','INVENTARIO','PERDA','DEVOLUCAO')),
        CONSTRAINT CK_movimento_estoque_quantidade CHECK (quantidade > 0),
        CONSTRAINT FK_movimento_estoque_lote FOREIGN KEY (lote_id) REFERENCES farmalocal.lote_estoque(id),
        CONSTRAINT FK_movimento_estoque_usuario FOREIGN KEY (usuario_id) REFERENCES farmalocal.usuario(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.venda', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.venda
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        filial_id BIGINT NOT NULL,
        cliente_id BIGINT NULL,
        usuario_id BIGINT NOT NULL,
        convenio_id BIGINT NULL,
        data_hora DATETIME2(0) NOT NULL CONSTRAINT DF_venda_data_hora DEFAULT (SYSDATETIME()),
        subtotal DECIMAL(14,2) NOT NULL,
        desconto DECIMAL(14,2) NOT NULL CONSTRAINT DF_venda_desconto DEFAULT (0),
        total DECIMAL(14,2) NOT NULL,
        status VARCHAR(20) NOT NULL,
        observacoes VARCHAR(500) NULL,
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_venda_data_criacao DEFAULT (SYSDATETIME()),
        data_atualizacao DATETIME2(0) NULL,
        CONSTRAINT PK_venda PRIMARY KEY CLUSTERED (id),
        CONSTRAINT CK_venda_status CHECK (status IN ('ABERTA','FINALIZADA','CANCELADA')),
        CONSTRAINT CK_venda_subtotal CHECK (subtotal >= 0),
        CONSTRAINT CK_venda_desconto CHECK (desconto >= 0),
        CONSTRAINT CK_venda_total CHECK (total >= 0),
        CONSTRAINT FK_venda_filial FOREIGN KEY (filial_id) REFERENCES farmalocal.filial(id),
        CONSTRAINT FK_venda_cliente FOREIGN KEY (cliente_id) REFERENCES farmalocal.cliente(id),
        CONSTRAINT FK_venda_usuario FOREIGN KEY (usuario_id) REFERENCES farmalocal.usuario(id),
        CONSTRAINT FK_venda_convenio FOREIGN KEY (convenio_id) REFERENCES farmalocal.convenio(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.venda_item', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.venda_item
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        venda_id BIGINT NOT NULL,
        apresentacao_id BIGINT NOT NULL,
        lote_id BIGINT NULL,
        quantidade DECIMAL(14,3) NOT NULL,
        preco_unitario DECIMAL(14,2) NOT NULL,
        desconto DECIMAL(14,2) NOT NULL CONSTRAINT DF_venda_item_desconto DEFAULT (0),
        subtotal DECIMAL(14,2) NOT NULL,
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_venda_item_data_criacao DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_venda_item PRIMARY KEY CLUSTERED (id),
        CONSTRAINT CK_venda_item_quantidade CHECK (quantidade > 0),
        CONSTRAINT CK_venda_item_preco CHECK (preco_unitario >= 0),
        CONSTRAINT CK_venda_item_desconto CHECK (desconto >= 0),
        CONSTRAINT CK_venda_item_subtotal CHECK (subtotal >= 0),
        CONSTRAINT FK_venda_item_venda FOREIGN KEY (venda_id) REFERENCES farmalocal.venda(id),
        CONSTRAINT FK_venda_item_apresentacao FOREIGN KEY (apresentacao_id) REFERENCES farmalocal.produto_apresentacao(id),
        CONSTRAINT FK_venda_item_lote FOREIGN KEY (lote_id) REFERENCES farmalocal.lote_estoque(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.pagamento', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.pagamento
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        venda_id BIGINT NOT NULL,
        tipo_pagamento VARCHAR(30) NOT NULL,
        valor DECIMAL(14,2) NOT NULL,
        codigo_autorizacao VARCHAR(80) NULL,
        observacoes VARCHAR(255) NULL,
        data_pagamento DATETIME2(0) NOT NULL CONSTRAINT DF_pagamento_data DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_pagamento PRIMARY KEY CLUSTERED (id),
        CONSTRAINT CK_pagamento_tipo CHECK (tipo_pagamento IN ('DINHEIRO','DEBITO','CREDITO','PIX','CONVENIO')),
        CONSTRAINT CK_pagamento_valor CHECK (valor > 0),
        CONSTRAINT FK_pagamento_venda FOREIGN KEY (venda_id) REFERENCES farmalocal.venda(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.receita_venda_item', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.receita_venda_item
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        venda_item_id BIGINT NOT NULL,
        nome_medico VARCHAR(150) NOT NULL,
        crm VARCHAR(30) NOT NULL,
        uf_crm CHAR(2) NOT NULL,
        nome_paciente VARCHAR(150) NOT NULL,
        cpf_paciente VARCHAR(14) NULL,
        data_emissao_receita DATE NOT NULL,
        data_validade_receita DATE NULL,
        tipo_documento VARCHAR(30) NULL,
        receita_retida BIT NOT NULL CONSTRAINT DF_receita_venda_item_retida DEFAULT (0),
        observacoes VARCHAR(500) NULL,
        data_criacao DATETIME2(0) NOT NULL CONSTRAINT DF_receita_venda_item_data_criacao DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_receita_venda_item PRIMARY KEY CLUSTERED (id),
        CONSTRAINT UQ_receita_venda_item_venda_item UNIQUE (venda_item_id),
        CONSTRAINT CK_receita_venda_item_uf CHECK (LEN(uf_crm) = 2),
        CONSTRAINT FK_receita_venda_item_venda_item FOREIGN KEY (venda_item_id) REFERENCES farmalocal.venda_item(id)
    );
END
GO

IF OBJECT_ID(N'farmalocal.auditoria_log', N'U') IS NULL
BEGIN
    CREATE TABLE farmalocal.auditoria_log
    (
        id BIGINT IDENTITY(1,1) NOT NULL,
        tabela_nome VARCHAR(100) NOT NULL,
        registro_id BIGINT NOT NULL,
        acao VARCHAR(30) NOT NULL,
        dados_antes NVARCHAR(MAX) NULL,
        dados_depois NVARCHAR(MAX) NULL,
        usuario_id BIGINT NULL,
        data_evento DATETIME2(0) NOT NULL CONSTRAINT DF_auditoria_log_data DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_auditoria_log PRIMARY KEY CLUSTERED (id),
        CONSTRAINT FK_auditoria_log_usuario FOREIGN KEY (usuario_id) REFERENCES farmalocal.usuario(id)
    );
END
GO
