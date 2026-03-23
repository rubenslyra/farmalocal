# Dicionário de dados profissional — FarmaLocal

## Premissas de modelagem

- Banco relacional normalizado (PostgreSQL)
- Nomenclatura em `snake_case`
- Chave primária padrão: `id` (`bigint generated always as identity`)
- Chaves estrangeiras: `nome_entidade_id`
- Colunas booleanas com nomes afirmativos
- Colunas de auditoria básicas em todas as tabelas principais (`data_criacao`, `data_atualizacao`)
- Catálogo central (`produto`) com especializações por domínio
- Venda feita por **apresentação** (`produto_apresentacao`)
- Estoque controlado por **lote** (`lote_estoque`)
- Receita vinculada ao **item da venda** (`venda_item`)

---

## 1. `filial`

**Objetivo:** representa uma unidade física ou operacional da farmácia.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| codigo | varchar(20) | não | | UQ | código interno da filial |
| nome | varchar(150) | não | | | nome da unidade |
| cnpj | varchar(18) | sim | | | opcional no MVP |
| telefone | varchar(20) | sim | | | |
| email | varchar(150) | sim | | | |
| cep | varchar(9) | sim | | | |
| logradouro | varchar(150) | sim | | | |
| numero | varchar(20) | sim | | | |
| complemento | varchar(100) | sim | | | |
| bairro | varchar(100) | sim | | | |
| cidade | varchar(100) | sim | | | |
| uf | char(2) | sim | | | UF da filial |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

---

## 2. `usuario`

**Objetivo:** usuários internos do sistema.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| filial\_id | bigint | não | | FK → filial | unidade do usuário |
| nome | varchar(150) | não | | | |
| email | varchar(150) | não | | UQ | |
| login | varchar(80) | não | | UQ | |
| senha\_hash | varchar(255) | não | | | hash bcrypt |
| perfil | varchar(50) | não | | | ver valores abaixo |
| ativo | boolean | não | true | | controle lógico |
| ultimo\_acesso\_em | timestamp | sim | | | |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

**Valores de `perfil`:** `ADMIN`, `GERENTE`, `FARMACEUTICO`, `CAIXA`, `ESTOQUISTA`

---

## 3. `categoria`

**Objetivo:** macrogrupo do catálogo de produtos.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| nome | varchar(100) | não | | UQ | |
| descricao | varchar(255) | sim | | | |
| controla\_lote | boolean | não | false | | habilita controle por lote |
| exige\_validade | boolean | não | false | | habilita controle de validade |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

**Exemplos:** `Medicamento`, `Higiene`, `Perfumaria`, `Equipamento`, `Correlato`, `Suplemento`

---

## 4. `fabricante`

**Objetivo:** laboratório ou marca fabricante do produto.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| razao\_social | varchar(150) | não | | | |
| nome\_fantasia | varchar(150) | sim | | | |
| cnpj | varchar(18) | sim | | UQ parcial | índice único somente quando não nulo |
| telefone | varchar(20) | sim | | | |
| email | varchar(150) | sim | | | |
| site\_url | varchar(255) | sim | | | |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

---

## 5. `fornecedor`

**Objetivo:** fornecedor comercial de compra (distribuidor, atacado).

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| razao\_social | varchar(150) | não | | | |
| nome\_fantasia | varchar(150) | sim | | | |
| cnpj | varchar(18) | sim | | UQ parcial | índice único somente quando não nulo |
| telefone | varchar(20) | sim | | | |
| email | varchar(150) | sim | | | |
| contato\_nome | varchar(100) | sim | | | |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

---

## 6. `substancia_ativa`

**Objetivo:** princípios ativos (DCI — Denominação Comum Internacional).

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| nome | varchar(150) | não | | UQ | nome DCI |
| descricao | varchar(255) | sim | | | |
| codigo\_referencia | varchar(50) | sim | | | ex.: código ATC |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

**Exemplos:** Paracetamol, Dipirona Monoidratada, Ibuprofeno, Amoxicilina

---

## 7. `cliente`

**Objetivo:** consumidor final da farmácia.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| nome | varchar(150) | não | | | |
| cpf | varchar(14) | sim | | UQ parcial | índice único somente quando não nulo |
| data\_nascimento | date | sim | | | |
| telefone | varchar(20) | sim | | | |
| email | varchar(150) | sim | | | |
| observacoes | varchar(500) | sim | | | |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

---

## 8. `convenio`

**Objetivo:** convênio, programa ou acordo comercial.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| nome | varchar(150) | não | | UQ | |
| percentual\_desconto | numeric(5,2) | sim | | | 0.00–100.00 |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

---

## 9. `produto`

**Objetivo:** entidade-base do catálogo (item genérico, sem embalagem específica).

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| categoria\_id | bigint | não | | FK → categoria | |
| fabricante\_id | bigint | não | | FK → fabricante | |
| codigo\_interno | varchar(30) | não | | UQ | |
| nome\_comercial | varchar(150) | sim | | | ex.: Tylenol |
| nome\_reduzido | varchar(120) | não | | | usado em tela e relatório |
| descricao | varchar(255) | sim | | | |
| tipo\_produto | varchar(30) | não | | | ver valores abaixo |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

**Valores de `tipo_produto`:** `MEDICAMENTO`, `HIGIENE`, `PERFUMARIA`, `EQUIPAMENTO`, `CORRELATO`, `SUPLEMENTO`

---

## 10. `produto_apresentacao`

**Objetivo:** unidade comercial vendável (embalagem + forma + dosagem).

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| produto\_id | bigint | não | | FK → produto | |
| codigo\_ean | varchar(20) | sim | | UQ parcial | código de barras EAN |
| sku\_interno | varchar(40) | não | | UQ | SKU interno da farmácia |
| unidade\_medida | varchar(20) | não | | | ex.: CX, UN, ML |
| quantidade\_embalagem | numeric(12,3) | sim | | | ex.: 20 (comprimidos) |
| forma\_farmaceutica | varchar(50) | sim | | | ex.: comprimido, cápsula |
| dosagem\_texto | varchar(80) | sim | | | ex.: 750 mg |
| volume\_texto | varchar(80) | sim | | | ex.: 120 mL |
| concentracao\_texto | varchar(80) | sim | | | ex.: 500 mg/5 mL |
| descricao\_apresentacao | varchar(255) | não | | | descrição completa |
| preco\_venda | numeric(14,2) | não | | | ≥ 0 |
| permite\_fracionamento | boolean | não | false | | |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

---

## 11. `apresentacao_substancia`

**Objetivo:** relacionamento N:N entre apresentação e substância ativa.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| apresentacao\_id | bigint | não | | FK → produto\_apresentacao | |
| substancia\_ativa\_id | bigint | não | | FK → substancia\_ativa | |
| concentracao | numeric(12,4) | sim | | | quantidade numérica |
| unidade\_concentracao | varchar(20) | sim | | | ex.: mg, mg/mL |
| principal | boolean | não | false | | marca substância principal |
| data\_criacao | timestamp | não | now() | | auditoria |

**Regra:** par `(apresentacao_id, substancia_ativa_id)` é único.

---

## 12. `medicamento_detalhe`

**Objetivo:** extensão regulatória para apresentações farmacêuticas (1:1 com `produto_apresentacao`).

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| apresentacao\_id | bigint | não | | PK / FK → produto\_apresentacao | chave compartilhada |
| tipo\_medicamento | varchar(20) | não | | | ver valores abaixo |
| registro\_anvisa | varchar(50) | sim | | | número do registro |
| tarja | varchar(20) | não | | | ver valores abaixo |
| requer\_receita | boolean | não | false | | |
| retencao\_receita | boolean | não | false | | |
| controlado\_sngpc | boolean | não | false | | psicotrópicos/entorpecentes |
| antimicrobiano | boolean | não | false | | notificação antimicrobiano |
| uso\_continuo | boolean | não | false | | |
| permite\_intercambialidade | boolean | não | true | | troca por genérico/similar |
| observacoes | varchar(500) | sim | | | |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

**Valores de `tipo_medicamento`:** `REFERENCIA`, `GENERICO`, `SIMILAR`

**Valores de `tarja`:** `SEM_TARJA`, `AMARELA`, `VERMELHA`, `PRETA`

---

## 13. `equipamento_detalhe`

**Objetivo:** extensão opcional para equipamentos (1:1 com `produto_apresentacao`).

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| apresentacao\_id | bigint | não | | PK / FK → produto\_apresentacao | chave compartilhada |
| garantia\_meses | int | sim | | | ≥ 0 |
| possui\_registro\_anvisa | boolean | não | false | | |
| numero\_registro\_anvisa | varchar(50) | sim | | | |
| voltagem | varchar(30) | sim | | | ex.: Bivolt |
| manual\_url | varchar(255) | sim | | | link do manual |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

---

## 14. `produto_atributo_extra`

**Objetivo:** atributos flexíveis (EAV) para categorias sem especialização própria.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| apresentacao\_id | bigint | não | | FK → produto\_apresentacao | |
| nome\_atributo | varchar(100) | não | | | ex.: tamanho |
| valor\_atributo | varchar(255) | não | | | ex.: G |
| data\_criacao | timestamp | não | now() | | auditoria |

**Regra:** par `(apresentacao_id, nome_atributo)` é único.

---

## 15. `cliente_convenio`

**Objetivo:** relacionamento N:N entre cliente e convênio.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| cliente\_id | bigint | não | | FK → cliente | |
| convenio\_id | bigint | não | | FK → convenio | |
| matricula | varchar(50) | sim | | | número de matrícula |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |

**Regra:** par `(cliente_id, convenio_id)` é único.

---

## 16. `lote_estoque`

**Objetivo:** controle físico e rastreável do estoque por lote e filial.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| filial\_id | bigint | não | | FK → filial | |
| apresentacao\_id | bigint | não | | FK → produto\_apresentacao | |
| fornecedor\_id | bigint | sim | | FK → fornecedor | |
| numero\_lote | varchar(60) | não | | | número do lote do fabricante |
| data\_fabricacao | date | sim | | | |
| data\_validade | date | sim | | | base para FEFO |
| quantidade\_atual | numeric(14,3) | não | | | ≥ 0 |
| quantidade\_reservada | numeric(14,3) | não | 0 | | ≥ 0 |
| custo\_unitario | numeric(14,4) | sim | | | ≥ 0 quando informado |
| ativo | boolean | não | true | | controle lógico |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

**Regra:** tripla `(filial_id, apresentacao_id, numero_lote)` é única.

---

## 17. `movimento_estoque`

**Objetivo:** histórico imutável de entradas, saídas e ajustes de estoque.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| lote\_id | bigint | não | | FK → lote\_estoque | |
| tipo\_movimento | varchar(30) | não | | | ver valores abaixo |
| quantidade | numeric(14,3) | não | | | > 0 |
| documento\_referencia | varchar(80) | sim | | | NF, NF-e, número de venda |
| origem | varchar(50) | não | | | ex.: VENDA, NF, AJUSTE\_MANUAL |
| observacoes | varchar(500) | sim | | | |
| usuario\_id | bigint | sim | | FK → usuario | operador responsável |
| data\_movimento | timestamp | não | now() | | |

**Valores de `tipo_movimento`:** `ENTRADA`, `SAIDA`, `AJUSTE_POSITIVO`, `AJUSTE_NEGATIVO`, `CANCELAMENTO`, `INVENTARIO`, `PERDA`, `DEVOLUCAO`

---

## 18. `venda`

**Objetivo:** cabeçalho da venda (transação comercial).

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| filial\_id | bigint | não | | FK → filial | |
| cliente\_id | bigint | sim | | FK → cliente | venda sem identificação é permitida |
| usuario\_id | bigint | não | | FK → usuario | caixa / operador |
| convenio\_id | bigint | sim | | FK → convenio | |
| data\_hora | timestamp | não | now() | | data/hora da venda |
| subtotal | numeric(14,2) | não | | | ≥ 0 |
| desconto | numeric(14,2) | não | 0 | | ≥ 0 |
| total | numeric(14,2) | não | | | ≥ 0 |
| status | varchar(20) | não | | | ver valores abaixo |
| observacoes | varchar(500) | sim | | | |
| data\_criacao | timestamp | não | now() | | auditoria |
| data\_atualizacao | timestamp | sim | | | auditoria |

**Valores de `status`:** `ABERTA`, `FINALIZADA`, `CANCELADA`

---

## 19. `venda_item`

**Objetivo:** itens individuais de uma venda.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| venda\_id | bigint | não | | FK → venda | |
| apresentacao\_id | bigint | não | | FK → produto\_apresentacao | item vendido |
| lote\_id | bigint | sim | | FK → lote\_estoque | lote baixado |
| quantidade | numeric(14,3) | não | | | > 0 |
| preco\_unitario | numeric(14,2) | não | | | ≥ 0 |
| desconto | numeric(14,2) | não | 0 | | ≥ 0 |
| subtotal | numeric(14,2) | não | | | ≥ 0 |
| data\_criacao | timestamp | não | now() | | auditoria |

---

## 20. `pagamento`

**Objetivo:** pagamentos vinculados a uma venda (suporta múltiplos pagamentos por venda).

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| venda\_id | bigint | não | | FK → venda | |
| tipo\_pagamento | varchar(30) | não | | | ver valores abaixo |
| valor | numeric(14,2) | não | | | > 0 |
| codigo\_autorizacao | varchar(80) | sim | | | NSU / código TEF |
| observacoes | varchar(255) | sim | | | |
| data\_pagamento | timestamp | não | now() | | |

**Valores de `tipo_pagamento`:** `DINHEIRO`, `DEBITO`, `CREDITO`, `PIX`, `CONVENIO`

---

## 21. `receita_venda_item`

**Objetivo:** dados da receita vinculados ao item que exige prescrição médica.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| venda\_item\_id | bigint | não | | FK → venda\_item | 1:1 — UQ |
| nome\_medico | varchar(150) | não | | | |
| crm | varchar(30) | não | | | |
| uf\_crm | char(2) | não | | | exatamente 2 caracteres |
| nome\_paciente | varchar(150) | não | | | |
| cpf\_paciente | varchar(14) | sim | | | |
| data\_emissao\_receita | date | não | | | |
| data\_validade\_receita | date | sim | | | |
| tipo\_documento | varchar(30) | sim | | | ex.: RECEITA\_SIMPLES, RECEITA\_ESPECIAL |
| receita\_retida | boolean | não | false | | |
| observacoes | varchar(500) | sim | | | |
| data\_criacao | timestamp | não | now() | | auditoria |

---

## 22. `auditoria_log`

**Objetivo:** registro de ações críticas para rastreabilidade e compliance.

| Coluna | Tipo PostgreSQL | Nulo? | Default | Chave | Regra / Observação |
|---|---|---|---|---|---|
| id | bigint | não | identity | PK | identificador |
| tabela\_nome | varchar(100) | não | | | nome da tabela afetada |
| registro\_id | bigint | não | | | id do registro afetado |
| acao | varchar(30) | não | | | ex.: INSERT, UPDATE, DELETE |
| dados\_antes | text | sim | | | JSON do estado anterior |
| dados\_depois | text | sim | | | JSON do estado posterior |
| usuario\_id | bigint | sim | | FK → usuario | operador responsável |
| data\_evento | timestamp | não | now() | | |

---

## Script SQL completo — PostgreSQL

```sql
-- =========================================================
-- FARMALOCAL - SCHEMA INICIAL POSTGRESQL
-- =========================================================

-- Opcional: isola o schema
CREATE SCHEMA IF NOT EXISTS farmalocal;
SET search_path TO farmalocal;

-- =========================================================
-- TABELAS BASE
-- =========================================================

CREATE TABLE IF NOT EXISTS filial (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo              varchar(20)  NOT NULL,
    nome                varchar(150) NOT NULL,
    cnpj                varchar(18),
    telefone            varchar(20),
    email               varchar(150),
    cep                 varchar(9),
    logradouro          varchar(150),
    numero              varchar(20),
    complemento         varchar(100),
    bairro              varchar(100),
    cidade              varchar(100),
    uf                  char(2),
    ativo               boolean      NOT NULL DEFAULT true,
    data_criacao        timestamp    NOT NULL DEFAULT now(),
    data_atualizacao    timestamp,
    CONSTRAINT uq_filial_codigo UNIQUE (codigo),
    CONSTRAINT ck_filial_uf CHECK (uf IS NULL OR char_length(uf) = 2)
);

CREATE TABLE IF NOT EXISTS categoria (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome                varchar(100) NOT NULL,
    descricao           varchar(255),
    controla_lote       boolean      NOT NULL DEFAULT false,
    exige_validade      boolean      NOT NULL DEFAULT false,
    ativo               boolean      NOT NULL DEFAULT true,
    data_criacao        timestamp    NOT NULL DEFAULT now(),
    data_atualizacao    timestamp,
    CONSTRAINT uq_categoria_nome UNIQUE (nome)
);

CREATE TABLE IF NOT EXISTS fabricante (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    razao_social        varchar(150) NOT NULL,
    nome_fantasia       varchar(150),
    cnpj                varchar(18),
    telefone            varchar(20),
    email               varchar(150),
    site_url            varchar(255),
    ativo               boolean      NOT NULL DEFAULT true,
    data_criacao        timestamp    NOT NULL DEFAULT now(),
    data_atualizacao    timestamp
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_fabricante_cnpj_not_null
    ON fabricante (cnpj)
    WHERE cnpj IS NOT NULL;

CREATE TABLE IF NOT EXISTS fornecedor (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    razao_social        varchar(150) NOT NULL,
    nome_fantasia       varchar(150),
    cnpj                varchar(18),
    telefone            varchar(20),
    email               varchar(150),
    contato_nome        varchar(100),
    ativo               boolean      NOT NULL DEFAULT true,
    data_criacao        timestamp    NOT NULL DEFAULT now(),
    data_atualizacao    timestamp
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_fornecedor_cnpj_not_null
    ON fornecedor (cnpj)
    WHERE cnpj IS NOT NULL;

CREATE TABLE IF NOT EXISTS substancia_ativa (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome                varchar(150) NOT NULL,
    descricao           varchar(255),
    codigo_referencia   varchar(50),
    ativo               boolean      NOT NULL DEFAULT true,
    data_criacao        timestamp    NOT NULL DEFAULT now(),
    data_atualizacao    timestamp,
    CONSTRAINT uq_substancia_ativa_nome UNIQUE (nome)
);

CREATE TABLE IF NOT EXISTS cliente (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome                varchar(150) NOT NULL,
    cpf                 varchar(14),
    data_nascimento     date,
    telefone            varchar(20),
    email               varchar(150),
    observacoes         varchar(500),
    ativo               boolean      NOT NULL DEFAULT true,
    data_criacao        timestamp    NOT NULL DEFAULT now(),
    data_atualizacao    timestamp
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_cliente_cpf_not_null
    ON cliente (cpf)
    WHERE cpf IS NOT NULL;

CREATE TABLE IF NOT EXISTS convenio (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome                varchar(150)  NOT NULL,
    percentual_desconto numeric(5,2),
    ativo               boolean       NOT NULL DEFAULT true,
    data_criacao        timestamp     NOT NULL DEFAULT now(),
    data_atualizacao    timestamp,
    CONSTRAINT uq_convenio_nome UNIQUE (nome),
    CONSTRAINT ck_convenio_percentual CHECK (
        percentual_desconto IS NULL
        OR (percentual_desconto >= 0 AND percentual_desconto <= 100)
    )
);

CREATE TABLE IF NOT EXISTS usuario (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    filial_id           bigint       NOT NULL,
    nome                varchar(150) NOT NULL,
    email               varchar(150) NOT NULL,
    login               varchar(80)  NOT NULL,
    senha_hash          varchar(255) NOT NULL,
    perfil              varchar(50)  NOT NULL,
    ativo               boolean      NOT NULL DEFAULT true,
    ultimo_acesso_em    timestamp,
    data_criacao        timestamp    NOT NULL DEFAULT now(),
    data_atualizacao    timestamp,
    CONSTRAINT fk_usuario_filial    FOREIGN KEY (filial_id) REFERENCES filial(id),
    CONSTRAINT uq_usuario_email     UNIQUE (email),
    CONSTRAINT uq_usuario_login     UNIQUE (login),
    CONSTRAINT ck_usuario_perfil    CHECK (
        perfil IN ('ADMIN','GERENTE','FARMACEUTICO','CAIXA','ESTOQUISTA')
    )
);

-- =========================================================
-- CATÁLOGO
-- =========================================================

CREATE TABLE IF NOT EXISTS produto (
    id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    categoria_id        bigint       NOT NULL,
    fabricante_id       bigint       NOT NULL,
    codigo_interno      varchar(30)  NOT NULL,
    nome_comercial      varchar(150),
    nome_reduzido       varchar(120) NOT NULL,
    descricao           varchar(255),
    tipo_produto        varchar(30)  NOT NULL,
    ativo               boolean      NOT NULL DEFAULT true,
    data_criacao        timestamp    NOT NULL DEFAULT now(),
    data_atualizacao    timestamp,
    CONSTRAINT fk_produto_categoria   FOREIGN KEY (categoria_id)  REFERENCES categoria(id),
    CONSTRAINT fk_produto_fabricante  FOREIGN KEY (fabricante_id) REFERENCES fabricante(id),
    CONSTRAINT uq_produto_codigo_interno UNIQUE (codigo_interno),
    CONSTRAINT ck_produto_tipo CHECK (
        tipo_produto IN ('MEDICAMENTO','HIGIENE','PERFUMARIA','EQUIPAMENTO','CORRELATO','SUPLEMENTO')
    )
);

CREATE TABLE IF NOT EXISTS produto_apresentacao (
    id                      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    produto_id              bigint        NOT NULL,
    codigo_ean              varchar(20),
    sku_interno             varchar(40)   NOT NULL,
    unidade_medida          varchar(20)   NOT NULL,
    quantidade_embalagem    numeric(12,3),
    forma_farmaceutica      varchar(50),
    dosagem_texto           varchar(80),
    volume_texto            varchar(80),
    concentracao_texto      varchar(80),
    descricao_apresentacao  varchar(255)  NOT NULL,
    preco_venda             numeric(14,2) NOT NULL,
    permite_fracionamento   boolean       NOT NULL DEFAULT false,
    ativo                   boolean       NOT NULL DEFAULT true,
    data_criacao            timestamp     NOT NULL DEFAULT now(),
    data_atualizacao        timestamp,
    CONSTRAINT fk_produto_apresentacao_produto FOREIGN KEY (produto_id) REFERENCES produto(id),
    CONSTRAINT uq_produto_apresentacao_sku     UNIQUE (sku_interno),
    CONSTRAINT ck_produto_apresentacao_preco   CHECK (preco_venda >= 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_produto_apresentacao_ean_not_null
    ON produto_apresentacao (codigo_ean)
    WHERE codigo_ean IS NOT NULL;

CREATE TABLE IF NOT EXISTS apresentacao_substancia (
    id                   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    apresentacao_id      bigint        NOT NULL,
    substancia_ativa_id  bigint        NOT NULL,
    concentracao         numeric(12,4),
    unidade_concentracao varchar(20),
    principal            boolean       NOT NULL DEFAULT false,
    data_criacao         timestamp     NOT NULL DEFAULT now(),
    CONSTRAINT fk_apresentacao_substancia_apresentacao
        FOREIGN KEY (apresentacao_id)     REFERENCES produto_apresentacao(id),
    CONSTRAINT fk_apresentacao_substancia_substancia
        FOREIGN KEY (substancia_ativa_id) REFERENCES substancia_ativa(id),
    CONSTRAINT uq_apresentacao_substancia UNIQUE (apresentacao_id, substancia_ativa_id)
);

CREATE TABLE IF NOT EXISTS medicamento_detalhe (
    apresentacao_id             bigint       PRIMARY KEY,
    tipo_medicamento            varchar(20)  NOT NULL,
    registro_anvisa             varchar(50),
    tarja                       varchar(20)  NOT NULL,
    requer_receita              boolean      NOT NULL DEFAULT false,
    retencao_receita            boolean      NOT NULL DEFAULT false,
    controlado_sngpc            boolean      NOT NULL DEFAULT false,
    antimicrobiano              boolean      NOT NULL DEFAULT false,
    uso_continuo                boolean      NOT NULL DEFAULT false,
    permite_intercambialidade   boolean      NOT NULL DEFAULT true,
    observacoes                 varchar(500),
    data_criacao                timestamp    NOT NULL DEFAULT now(),
    data_atualizacao            timestamp,
    CONSTRAINT fk_medicamento_detalhe_apresentacao
        FOREIGN KEY (apresentacao_id) REFERENCES produto_apresentacao(id),
    CONSTRAINT ck_medicamento_tipo CHECK (
        tipo_medicamento IN ('REFERENCIA','GENERICO','SIMILAR')
    ),
    CONSTRAINT ck_medicamento_tarja CHECK (
        tarja IN ('SEM_TARJA','AMARELA','VERMELHA','PRETA')
    )
);

CREATE TABLE IF NOT EXISTS equipamento_detalhe (
    apresentacao_id         bigint      PRIMARY KEY,
    garantia_meses          int,
    possui_registro_anvisa  boolean     NOT NULL DEFAULT false,
    numero_registro_anvisa  varchar(50),
    voltagem                varchar(30),
    manual_url              varchar(255),
    data_criacao            timestamp   NOT NULL DEFAULT now(),
    data_atualizacao        timestamp,
    CONSTRAINT fk_equipamento_detalhe_apresentacao
        FOREIGN KEY (apresentacao_id) REFERENCES produto_apresentacao(id),
    CONSTRAINT ck_equipamento_garantia CHECK (
        garantia_meses IS NULL OR garantia_meses >= 0
    )
);

CREATE TABLE IF NOT EXISTS produto_atributo_extra (
    id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    apresentacao_id  bigint       NOT NULL,
    nome_atributo    varchar(100) NOT NULL,
    valor_atributo   varchar(255) NOT NULL,
    data_criacao     timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT fk_produto_atributo_extra_apresentacao
        FOREIGN KEY (apresentacao_id) REFERENCES produto_apresentacao(id),
    CONSTRAINT uq_produto_atributo_extra UNIQUE (apresentacao_id, nome_atributo)
);

-- =========================================================
-- RELACIONAMENTO COMERCIAL
-- =========================================================

CREATE TABLE IF NOT EXISTS cliente_convenio (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id   bigint      NOT NULL,
    convenio_id  bigint      NOT NULL,
    matricula    varchar(50),
    ativo        boolean     NOT NULL DEFAULT true,
    data_criacao timestamp   NOT NULL DEFAULT now(),
    CONSTRAINT fk_cliente_convenio_cliente  FOREIGN KEY (cliente_id)  REFERENCES cliente(id),
    CONSTRAINT fk_cliente_convenio_convenio FOREIGN KEY (convenio_id) REFERENCES convenio(id),
    CONSTRAINT uq_cliente_convenio UNIQUE (cliente_id, convenio_id)
);

-- =========================================================
-- ESTOQUE
-- =========================================================

CREATE TABLE IF NOT EXISTS lote_estoque (
    id                   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    filial_id            bigint        NOT NULL,
    apresentacao_id      bigint        NOT NULL,
    fornecedor_id        bigint,
    numero_lote          varchar(60)   NOT NULL,
    data_fabricacao      date,
    data_validade        date,
    quantidade_atual     numeric(14,3) NOT NULL,
    quantidade_reservada numeric(14,3) NOT NULL DEFAULT 0,
    custo_unitario       numeric(14,4),
    ativo                boolean       NOT NULL DEFAULT true,
    data_criacao         timestamp     NOT NULL DEFAULT now(),
    data_atualizacao     timestamp,
    CONSTRAINT fk_lote_estoque_filial
        FOREIGN KEY (filial_id)       REFERENCES filial(id),
    CONSTRAINT fk_lote_estoque_apresentacao
        FOREIGN KEY (apresentacao_id) REFERENCES produto_apresentacao(id),
    CONSTRAINT fk_lote_estoque_fornecedor
        FOREIGN KEY (fornecedor_id)   REFERENCES fornecedor(id),
    CONSTRAINT uq_lote_estoque UNIQUE (filial_id, apresentacao_id, numero_lote),
    CONSTRAINT ck_lote_quantidade_atual     CHECK (quantidade_atual     >= 0),
    CONSTRAINT ck_lote_quantidade_reservada CHECK (quantidade_reservada >= 0),
    CONSTRAINT ck_lote_custo_unitario       CHECK (custo_unitario IS NULL OR custo_unitario >= 0),
    CONSTRAINT ck_lote_validade_fabricacao  CHECK (
        data_fabricacao IS NULL
        OR data_validade IS NULL
        OR data_validade >= data_fabricacao
    )
);

CREATE TABLE IF NOT EXISTS movimento_estoque (
    id                   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lote_id              bigint        NOT NULL,
    tipo_movimento       varchar(30)   NOT NULL,
    quantidade           numeric(14,3) NOT NULL,
    documento_referencia varchar(80),
    origem               varchar(50)   NOT NULL,
    observacoes          varchar(500),
    usuario_id           bigint,
    data_movimento       timestamp     NOT NULL DEFAULT now(),
    CONSTRAINT fk_movimento_estoque_lote
        FOREIGN KEY (lote_id)    REFERENCES lote_estoque(id),
    CONSTRAINT fk_movimento_estoque_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario(id),
    CONSTRAINT ck_movimento_tipo CHECK (
        tipo_movimento IN (
            'ENTRADA','SAIDA','AJUSTE_POSITIVO','AJUSTE_NEGATIVO',
            'CANCELAMENTO','INVENTARIO','PERDA','DEVOLUCAO'
        )
    ),
    CONSTRAINT ck_movimento_quantidade CHECK (quantidade > 0)
);

-- =========================================================
-- VENDAS
-- =========================================================

CREATE TABLE IF NOT EXISTS venda (
    id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    filial_id        bigint        NOT NULL,
    cliente_id       bigint,
    usuario_id       bigint        NOT NULL,
    convenio_id      bigint,
    data_hora        timestamp     NOT NULL DEFAULT now(),
    subtotal         numeric(14,2) NOT NULL,
    desconto         numeric(14,2) NOT NULL DEFAULT 0,
    total            numeric(14,2) NOT NULL,
    status           varchar(20)   NOT NULL,
    observacoes      varchar(500),
    data_criacao     timestamp     NOT NULL DEFAULT now(),
    data_atualizacao timestamp,
    CONSTRAINT fk_venda_filial   FOREIGN KEY (filial_id)   REFERENCES filial(id),
    CONSTRAINT fk_venda_cliente  FOREIGN KEY (cliente_id)  REFERENCES cliente(id),
    CONSTRAINT fk_venda_usuario  FOREIGN KEY (usuario_id)  REFERENCES usuario(id),
    CONSTRAINT fk_venda_convenio FOREIGN KEY (convenio_id) REFERENCES convenio(id),
    CONSTRAINT ck_venda_status   CHECK (status IN ('ABERTA','FINALIZADA','CANCELADA')),
    CONSTRAINT ck_venda_subtotal CHECK (subtotal >= 0),
    CONSTRAINT ck_venda_desconto CHECK (desconto >= 0),
    CONSTRAINT ck_venda_total    CHECK (total    >= 0)
);

CREATE TABLE IF NOT EXISTS venda_item (
    id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venda_id         bigint        NOT NULL,
    apresentacao_id  bigint        NOT NULL,
    lote_id          bigint,
    quantidade       numeric(14,3) NOT NULL,
    preco_unitario   numeric(14,2) NOT NULL,
    desconto         numeric(14,2) NOT NULL DEFAULT 0,
    subtotal         numeric(14,2) NOT NULL,
    data_criacao     timestamp     NOT NULL DEFAULT now(),
    CONSTRAINT fk_venda_item_venda
        FOREIGN KEY (venda_id)        REFERENCES venda(id),
    CONSTRAINT fk_venda_item_apresentacao
        FOREIGN KEY (apresentacao_id) REFERENCES produto_apresentacao(id),
    CONSTRAINT fk_venda_item_lote
        FOREIGN KEY (lote_id)         REFERENCES lote_estoque(id),
    CONSTRAINT ck_venda_item_quantidade CHECK (quantidade     > 0),
    CONSTRAINT ck_venda_item_preco      CHECK (preco_unitario >= 0),
    CONSTRAINT ck_venda_item_desconto   CHECK (desconto       >= 0),
    CONSTRAINT ck_venda_item_subtotal   CHECK (subtotal       >= 0)
);

CREATE TABLE IF NOT EXISTS pagamento (
    id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venda_id           bigint        NOT NULL,
    tipo_pagamento     varchar(30)   NOT NULL,
    valor              numeric(14,2) NOT NULL,
    codigo_autorizacao varchar(80),
    observacoes        varchar(255),
    data_pagamento     timestamp     NOT NULL DEFAULT now(),
    CONSTRAINT fk_pagamento_venda  FOREIGN KEY (venda_id) REFERENCES venda(id),
    CONSTRAINT ck_pagamento_tipo   CHECK (
        tipo_pagamento IN ('DINHEIRO','DEBITO','CREDITO','PIX','CONVENIO')
    ),
    CONSTRAINT ck_pagamento_valor  CHECK (valor > 0)
);

CREATE TABLE IF NOT EXISTS receita_venda_item (
    id                    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venda_item_id         bigint       NOT NULL,
    nome_medico           varchar(150) NOT NULL,
    crm                   varchar(30)  NOT NULL,
    uf_crm                char(2)      NOT NULL,
    nome_paciente         varchar(150) NOT NULL,
    cpf_paciente          varchar(14),
    data_emissao_receita  date         NOT NULL,
    data_validade_receita date,
    tipo_documento        varchar(30),
    receita_retida        boolean      NOT NULL DEFAULT false,
    observacoes           varchar(500),
    data_criacao          timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT fk_receita_venda_item_venda_item
        FOREIGN KEY (venda_item_id) REFERENCES venda_item(id),
    CONSTRAINT uq_receita_venda_item_venda_item UNIQUE (venda_item_id),
    CONSTRAINT ck_receita_uf_crm CHECK (char_length(uf_crm) = 2)
);

-- =========================================================
-- AUDITORIA
-- =========================================================

CREATE TABLE IF NOT EXISTS auditoria_log (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tabela_nome  varchar(100) NOT NULL,
    registro_id  bigint       NOT NULL,
    acao         varchar(30)  NOT NULL,
    dados_antes  text,
    dados_depois text,
    usuario_id   bigint,
    data_evento  timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT fk_auditoria_log_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id)
);

-- =========================================================
-- ÍNDICES
-- =========================================================

CREATE INDEX IF NOT EXISTS ix_produto_nome_comercial        ON produto              (nome_comercial);
CREATE INDEX IF NOT EXISTS ix_produto_nome_reduzido         ON produto              (nome_reduzido);
CREATE INDEX IF NOT EXISTS ix_produto_categoria_fabricante  ON produto              (categoria_id, fabricante_id);

CREATE INDEX IF NOT EXISTS ix_produto_apresentacao_produto_id   ON produto_apresentacao (produto_id);
CREATE INDEX IF NOT EXISTS ix_produto_apresentacao_descricao    ON produto_apresentacao (descricao_apresentacao);

CREATE INDEX IF NOT EXISTS ix_substancia_ativa_nome             ON substancia_ativa     (nome);

CREATE INDEX IF NOT EXISTS ix_apresentacao_substancia_substancia   ON apresentacao_substancia (substancia_ativa_id);
CREATE INDEX IF NOT EXISTS ix_apresentacao_substancia_apresentacao ON apresentacao_substancia (apresentacao_id);

CREATE INDEX IF NOT EXISTS ix_lote_filial_apresentacao  ON lote_estoque (filial_id, apresentacao_id);
CREATE INDEX IF NOT EXISTS ix_lote_filial_validade      ON lote_estoque (filial_id, data_validade);
CREATE INDEX IF NOT EXISTS ix_lote_apresentacao_validade ON lote_estoque (apresentacao_id, data_validade);
CREATE INDEX IF NOT EXISTS ix_lote_numero               ON lote_estoque (numero_lote);

CREATE INDEX IF NOT EXISTS ix_movimento_lote            ON movimento_estoque (lote_id);
CREATE INDEX IF NOT EXISTS ix_movimento_data            ON movimento_estoque (data_movimento);

CREATE INDEX IF NOT EXISTS ix_venda_filial              ON venda (filial_id);
CREATE INDEX IF NOT EXISTS ix_venda_cliente             ON venda (cliente_id);
CREATE INDEX IF NOT EXISTS ix_venda_usuario             ON venda (usuario_id);
CREATE INDEX IF NOT EXISTS ix_venda_data_hora           ON venda (data_hora);
CREATE INDEX IF NOT EXISTS ix_venda_filial_data_hora    ON venda (filial_id, data_hora);

CREATE INDEX IF NOT EXISTS ix_venda_item_venda          ON venda_item (venda_id);
CREATE INDEX IF NOT EXISTS ix_venda_item_apresentacao   ON venda_item (apresentacao_id);
CREATE INDEX IF NOT EXISTS ix_venda_item_lote           ON venda_item (lote_id);

CREATE INDEX IF NOT EXISTS ix_pagamento_venda           ON pagamento (venda_id);
CREATE INDEX IF NOT EXISTS ix_pagamento_tipo            ON pagamento (tipo_pagamento);

CREATE INDEX IF NOT EXISTS ix_receita_cpf_paciente      ON receita_venda_item (cpf_paciente);
CREATE INDEX IF NOT EXISTS ix_receita_crm               ON receita_venda_item (crm);
CREATE INDEX IF NOT EXISTS ix_receita_data_emissao      ON receita_venda_item (data_emissao_receita);

-- =========================================================
-- SEEDS INICIAIS
-- =========================================================

INSERT INTO categoria (nome, descricao, controla_lote, exige_validade)
VALUES
    ('Medicamento', 'Medicamentos em geral',           true,  true),
    ('Higiene',     'Itens de higiene pessoal',         false, false),
    ('Perfumaria',  'Itens de perfumaria',              false, false),
    ('Equipamento', 'Equipamentos e aparelhos',         false, false),
    ('Correlato',   'Itens correlatos farmacêuticos',   true,  true),
    ('Suplemento',  'Vitaminas e suplementos',          true,  true)
ON CONFLICT (nome) DO NOTHING;

INSERT INTO convenio (nome, percentual_desconto)
VALUES
    ('PARTICULAR',        null),
    ('FARMACIA_POPULAR',  null)
ON CONFLICT (nome) DO NOTHING;

INSERT INTO filial (codigo, nome, ativo)
VALUES
    ('MATRIZ', 'FarmaLocal Matriz', true)
ON CONFLICT (codigo) DO NOTHING;

-- =========================================================
-- EXEMPLO DE USUÁRIO ADMIN
-- ATENÇÃO: substitua 'HASH_AQUI' pelo hash bcrypt real antes de usar
-- =========================================================

INSERT INTO usuario (filial_id, nome, email, login, senha_hash, perfil, ativo)
SELECT f.id, 'Administrador', 'admin@farmalocal.local', 'admin', 'HASH_AQUI', 'ADMIN', true
FROM filial f
WHERE f.codigo = 'MATRIZ'
  AND NOT EXISTS (
      SELECT 1 FROM usuario u WHERE u.login = 'admin'
  );

-- =========================================================
-- FIM DO SCRIPT
-- =========================================================
```

---

## Observações gerais

- As regras de negócio (ex.: cálculo de `total`, validação de estoque disponível antes da baixa) devem ficar na camada de aplicação ou em _stored procedures_ de fechamento de venda — não em triggers, para manter o schema portável e simples no MVP.
- O controle FEFO (First Expired First Out) é implementado pela aplicação usando `data_validade` de `lote_estoque`.
- O campo `dados_antes` / `dados_depois` de `auditoria_log` deve armazenar JSON serializado pela aplicação.
