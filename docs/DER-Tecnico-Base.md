# DER técnico completo — FarmaLocal

## 1) Premissas de modelagem

### Padrão adotado

* banco relacional normalizado
* nomenclatura em `snake_case`
* chave primária padrão: `id`
* chaves estrangeiras: `nome_entidade_id`
* colunas booleanas com nomes afirmativos
* colunas de auditoria básicas em tabelas principais
* catálogo central com especializações por domínio
* venda feita por **apresentação**
* estoque controlado por **lote**
* receita vinculada ao **item da venda**

### Estratégia técnica

A modelagem foi pensada para:

* suportar medicamentos, higiene, correlatos, equipamentos e suplementos
* permitir busca por nome comercial e princípio ativo
* suportar FEFO
* permitir regras regulatórias
* ficar boa para consultas SQL manuais com Dapper
* manter portabilidade para SQL Server

---

# 2) Entidades e colunas

---

## 2.1. `filial`

Representa uma unidade da farmácia.

```sql
filial
- id                      bigint PK
- codigo                  varchar(20) not null unique
- nome                    varchar(150) not null
- cnpj                    varchar(18) null
- telefone                varchar(20) null
- email                   varchar(150) null
- cep                     varchar(9) null
- logradouro              varchar(150) null
- numero                  varchar(20) null
- complemento             varchar(100) null
- bairro                  varchar(100) null
- cidade                  varchar(100) null
- uf                      char(2) null
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

---

## 2.2. `usuario`

Usuários internos do sistema.

```sql
usuario
- id                      bigint PK
- filial_id               bigint FK -> filial.id
- nome                    varchar(150) not null
- email                   varchar(150) not null unique
- login                   varchar(80) not null unique
- senha_hash              varchar(255) not null
- perfil                  varchar(50) not null
- ativo                   boolean not null default true
- ultimo_acesso_em        timestamp null
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

Perfis iniciais sugeridos:

* ADMIN
* GERENTE
* FARMACEUTICO
* CAIXA
* ESTOQUISTA

---

## 2.3. `categoria`

Macrogrupo do catálogo.

```sql
categoria
- id                      bigint PK
- nome                    varchar(100) not null unique
- descricao               varchar(255) null
- controla_lote           boolean not null default false
- exige_validade          boolean not null default false
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

Exemplos:

* Medicamento
* Higiene
* Perfumaria
* Equipamento
* Correlato
* Suplemento

---

## 2.4. `fabricante`

Laboratório ou marca fabricante.

```sql
fabricante
- id                      bigint PK
- razao_social            varchar(150) not null
- nome_fantasia           varchar(150) null
- cnpj                    varchar(18) null unique
- telefone                varchar(20) null
- email                   varchar(150) null
- site_url                varchar(255) null
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

---

## 2.5. `fornecedor`

Fornecedor comercial de compra.

```sql
fornecedor
- id                      bigint PK
- razao_social            varchar(150) not null
- nome_fantasia           varchar(150) null
- cnpj                    varchar(18) null unique
- telefone                varchar(20) null
- email                   varchar(150) null
- contato_nome            varchar(100) null
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

---

## 2.6. `substancia_ativa`

Princípios ativos.

```sql
substancia_ativa
- id                      bigint PK
- nome                    varchar(150) not null unique
- descricao               varchar(255) null
- codigo_referencia       varchar(50) null
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

Exemplos:

* Paracetamol
* Dipirona Monoidratada
* Ibuprofeno
* Amoxicilina

---

## 2.7. `produto`

Entidade-base do catálogo.

```sql
produto
- id                      bigint PK
- categoria_id            bigint not null FK -> categoria.id
- fabricante_id           bigint not null FK -> fabricante.id
- codigo_interno          varchar(30) not null unique
- nome_comercial          varchar(150) null
- nome_reduzido           varchar(120) not null
- descricao               varchar(255) null
- tipo_produto            varchar(30) not null
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

Valores sugeridos para `tipo_produto`:

* MEDICAMENTO
* HIGIENE
* PERFUMARIA
* EQUIPAMENTO
* CORRELATO
* SUPLEMENTO

---

## 2.8. `produto_apresentacao`

Unidade comercial vendável.

```sql
produto_apresentacao
- id                      bigint PK
- produto_id              bigint not null FK -> produto.id
- codigo_ean              varchar(20) null unique
- sku_interno             varchar(40) not null unique
- unidade_medida          varchar(20) not null
- quantidade_embalagem    numeric(12,3) null
- forma_farmaceutica      varchar(50) null
- dosagem_texto           varchar(80) null
- volume_texto            varchar(80) null
- concentracao_texto      varchar(80) null
- descricao_apresentacao  varchar(255) not null
- preco_venda             numeric(14,2) not null
- permite_fracionamento   boolean not null default false
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

Exemplo de `descricao_apresentacao`:

* Paracetamol 750mg comprimido caixa com 20
* Fralda infantil G pacote com 32
* Medidor de pressão digital braço

---

## 2.9. `apresentacao_substancia`

Relação entre apresentação e substância ativa.

```sql
apresentacao_substancia
- id                      bigint PK
- apresentacao_id         bigint not null FK -> produto_apresentacao.id
- substancia_ativa_id     bigint not null FK -> substancia_ativa.id
- concentracao            numeric(12,4) null
- unidade_concentracao    varchar(20) null
- principal               boolean not null default false
- data_criacao            timestamp not null default now()
```

Regra:

* uma apresentação pode ter 1..N substâncias
* uma delas pode ser marcada como principal

---

## 2.10. `medicamento_detalhe`

Extensão regulatória para apresentações farmacêuticas.

```sql
medicamento_detalhe
- apresentacao_id         bigint PK FK -> produto_apresentacao.id
- tipo_medicamento        varchar(20) not null
- registro_anvisa         varchar(50) null
- tarja                   varchar(20) not null
- requer_receita          boolean not null default false
- retencao_receita        boolean not null default false
- controlado_sngpc        boolean not null default false
- antimicrobiano          boolean not null default false
- uso_continuo            boolean not null default false
- permite_intercambialidade boolean not null default true
- observacoes             varchar(500) null
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

Valores sugeridos:

* `tipo_medicamento`: REFERENCIA, GENERICO, SIMILAR
* `tarja`: SEM_TARJA, AMARELA, VERMELHA, PRETA

---

## 2.11. `equipamento_detalhe`

Extensão opcional para equipamentos.

```sql
equipamento_detalhe
- apresentacao_id         bigint PK FK -> produto_apresentacao.id
- garantia_meses          int null
- possui_registro_anvisa  boolean not null default false
- numero_registro_anvisa  varchar(50) null
- voltagem                varchar(30) null
- manual_url              varchar(255) null
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

---

## 2.12. `produto_atributo_extra`

Atributos flexíveis para categorias não críticas.

```sql
produto_atributo_extra
- id                      bigint PK
- apresentacao_id         bigint not null FK -> produto_apresentacao.id
- nome_atributo           varchar(100) not null
- valor_atributo          varchar(255) not null
- data_criacao            timestamp not null default now()
```

Exemplos:

* tamanho = G
* quantidade_pacote = 32
* peso_suportado = 9kg a 12kg

---

## 2.13. `cliente`

Consumidor final.

```sql
cliente
- id                      bigint PK
- nome                    varchar(150) not null
- cpf                     varchar(14) null unique
- data_nascimento         date null
- telefone                varchar(20) null
- email                   varchar(150) null
- observacoes             varchar(500) null
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

---

## 2.14. `convenio`

Convênio, programa ou acordo comercial.

```sql
convenio
- id                      bigint PK
- nome                    varchar(150) not null unique
- percentual_desconto     numeric(5,2) null
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

---

## 2.15. `cliente_convenio`

Relacionamento cliente-convênio.

```sql
cliente_convenio
- id                      bigint PK
- cliente_id              bigint not null FK -> cliente.id
- convenio_id             bigint not null FK -> convenio.id
- matricula               varchar(50) null
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
```

---

## 2.16. `lote_estoque`

Controle físico e rastreável do estoque.

```sql
lote_estoque
- id                      bigint PK
- filial_id               bigint not null FK -> filial.id
- apresentacao_id         bigint not null FK -> produto_apresentacao.id
- fornecedor_id           bigint null FK -> fornecedor.id
- numero_lote             varchar(60) not null
- data_fabricacao         date null
- data_validade           date null
- quantidade_atual        numeric(14,3) not null
- quantidade_reservada    numeric(14,3) not null default 0
- custo_unitario          numeric(14,4) null
- ativo                   boolean not null default true
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

---

## 2.17. `movimento_estoque`

Histórico de entradas, saídas e ajustes.

```sql
movimento_estoque
- id                      bigint PK
- lote_id                 bigint not null FK -> lote_estoque.id
- tipo_movimento          varchar(30) not null
- quantidade              numeric(14,3) not null
- documento_referencia    varchar(80) null
- origem                  varchar(50) not null
- observacoes             varchar(500) null
- usuario_id              bigint null FK -> usuario.id
- data_movimento          timestamp not null default now()
```

Valores sugeridos:

* ENTRADA
* SAIDA
* AJUSTE_POSITIVO
* AJUSTE_NEGATIVO
* CANCELAMENTO
* INVENTARIO
* PERDA
* DEVOLUCAO

---

## 2.18. `venda`

Cabeçalho da venda.

```sql
venda
- id                      bigint PK
- filial_id               bigint not null FK -> filial.id
- cliente_id              bigint null FK -> cliente.id
- usuario_id              bigint not null FK -> usuario.id
- convenio_id             bigint null FK -> convenio.id
- data_hora               timestamp not null default now()
- subtotal                numeric(14,2) not null
- desconto                numeric(14,2) not null default 0
- total                   numeric(14,2) not null
- status                  varchar(20) not null
- observacoes             varchar(500) null
- data_criacao            timestamp not null default now()
- data_atualizacao        timestamp null
```

Valores sugeridos:

* ABERTA
* FINALIZADA
* CANCELADA

---

## 2.19. `venda_item`

Itens da venda.

```sql
venda_item
- id                      bigint PK
- venda_id                bigint not null FK -> venda.id
- apresentacao_id         bigint not null FK -> produto_apresentacao.id
- lote_id                 bigint null FK -> lote_estoque.id
- quantidade              numeric(14,3) not null
- preco_unitario          numeric(14,2) not null
- desconto                numeric(14,2) not null default 0
- subtotal                numeric(14,2) not null
- data_criacao            timestamp not null default now()
```

---

## 2.20. `pagamento`

Pagamentos vinculados à venda.

```sql
pagamento
- id                      bigint PK
- venda_id                bigint not null FK -> venda.id
- tipo_pagamento          varchar(30) not null
- valor                   numeric(14,2) not null
- codigo_autorizacao      varchar(80) null
- observacoes             varchar(255) null
- data_pagamento          timestamp not null default now()
```

Valores sugeridos:

* DINHEIRO
* DEBITO
* CREDITO
* PIX
* CONVENIO

---

## 2.21. `receita_venda_item`

Dados da receita vinculados ao item que exige prescrição.

```sql
receita_venda_item
- id                      bigint PK
- venda_item_id           bigint not null unique FK -> venda_item.id
- nome_medico             varchar(150) not null
- crm                     varchar(30) not null
- uf_crm                  char(2) not null
- nome_paciente           varchar(150) not null
- cpf_paciente            varchar(14) null
- data_emissao_receita    date not null
- data_validade_receita   date null
- tipo_documento          varchar(30) null
- receita_retida          boolean not null default false
- observacoes             varchar(500) null
- data_criacao            timestamp not null default now()
```

---

## 2.22. `auditoria_log`

Registro de ações críticas.

```sql
auditoria_log
- id                      bigint PK
- tabela_nome             varchar(100) not null
- registro_id             bigint not null
- acao                    varchar(30) not null
- dados_antes             text null
- dados_depois            text null
- usuario_id              bigint null FK -> usuario.id
- data_evento             timestamp not null default now()
```

---

# 3) Relacionamentos do DER

Aqui está a visão relacional central.

## Relacionamentos principais

* `filial (1) -> (N) usuario`

* `filial (1) -> (N) lote_estoque`

* `filial (1) -> (N) venda`

* `categoria (1) -> (N) produto`

* `fabricante (1) -> (N) produto`

* `produto (1) -> (N) produto_apresentacao`

* `produto_apresentacao (1) -> (N) apresentacao_substancia`

* `substancia_ativa (1) -> (N) apresentacao_substancia`

* `produto_apresentacao (1) -> (0..1) medicamento_detalhe`

* `produto_apresentacao (1) -> (0..1) equipamento_detalhe`

* `produto_apresentacao (1) -> (N) produto_atributo_extra`

* `fornecedor (1) -> (N) lote_estoque`

* `produto_apresentacao (1) -> (N) lote_estoque`

* `lote_estoque (1) -> (N) movimento_estoque`

* `cliente (1) -> (N) venda`

* `usuario (1) -> (N) venda`

* `convenio (1) -> (N) venda`

* `venda (1) -> (N) venda_item`

* `produto_apresentacao (1) -> (N) venda_item`

* `lote_estoque (1) -> (N) venda_item`

* `venda (1) -> (N) pagamento`

* `venda_item (1) -> (0..1) receita_venda_item`

* `cliente (1) -> (N) cliente_convenio`

* `convenio (1) -> (N) cliente_convenio`

---

# 4) Constraints e regras técnicas

Agora a parte que realmente “fecha” o banco.

## 4.1. Unique constraints

### `filial`

* `codigo` unique

### `usuario`

* `email` unique
* `login` unique

### `categoria`

* `nome` unique

### `fabricante`

* `cnpj` unique quando não nulo

### `fornecedor`

* `cnpj` unique quando não nulo

### `substancia_ativa`

* `nome` unique

### `produto`

* `codigo_interno` unique

### `produto_apresentacao`

* `codigo_ean` unique quando não nulo
* `sku_interno` unique

### `cliente`

* `cpf` unique quando não nulo

### `convenio`

* `nome` unique

### `receita_venda_item`

* `venda_item_id` unique

---

## 4.2. Check constraints recomendadas

### `produto`

* `tipo_produto in (...)`

### `medicamento_detalhe`

* `tipo_medicamento in ('REFERENCIA','GENERICO','SIMILAR')`
* `tarja in ('SEM_TARJA','AMARELA','VERMELHA','PRETA')`

### `movimento_estoque`

* `tipo_movimento in (...)`
* `quantidade > 0`

### `venda`

* `status in ('ABERTA','FINALIZADA','CANCELADA')`
* `subtotal >= 0`
* `desconto >= 0`
* `total >= 0`

### `venda_item`

* `quantidade > 0`
* `preco_unitario >= 0`
* `desconto >= 0`
* `subtotal >= 0`

### `pagamento`

* `tipo_pagamento in ('DINHEIRO','DEBITO','CREDITO','PIX','CONVENIO')`
* `valor > 0`

### `lote_estoque`

* `quantidade_atual >= 0`
* `quantidade_reservada >= 0`
* `custo_unitario >= 0` quando não nulo
* `data_validade >= data_fabricacao` quando ambas não nulas

### `receita_venda_item`

* `uf_crm` com 2 caracteres

---

## 4.3. Constraints compostas importantes

### `lote_estoque`

Evitar duplicação do mesmo lote para a mesma filial e apresentação:

* unique `(filial_id, apresentacao_id, numero_lote)`

### `cliente_convenio`

Evitar duplicidade de vínculo:

* unique `(cliente_id, convenio_id)`

### `apresentacao_substancia`

Evitar a mesma substância repetida na mesma apresentação:

* unique `(apresentacao_id, substancia_ativa_id)`

### `produto_atributo_extra`

Opcional:

* unique `(apresentacao_id, nome_atributo)`

---

# 5) Regras de negócio que merecem trigger ou validação na aplicação

Nem tudo vale a pena travar só no banco, mas algumas regras devem ser formalizadas.

## 5.1. Regra FEFO

Na venda, o sistema deve sugerir o lote com menor `data_validade` ainda disponível.

Implementação ideal:

* regra na aplicação
* consulta SQL ordenada por validade ascendente

---

## 5.2. Medicamento que exige receita

Se a apresentação tiver registro em `medicamento_detalhe` com:

* `requer_receita = true`
  ou
* `retencao_receita = true`
  ou
* `controlado_sngpc = true`

então o item da venda deve exigir registro em `receita_venda_item`.

Melhor deixar essa regra:

* validada na aplicação
* e opcionalmente reforçada por procedure de fechamento de venda

---

## 5.3. Cancelamento de venda

Ao cancelar:

* restaurar estoque do lote
* registrar `movimento_estoque`
* alterar status da venda

---

## 5.4. Integridade financeira

Na finalização:

* soma dos `venda_item.subtotal` = `venda.subtotal`
* soma dos `pagamento.valor` = `venda.total`

Pode ser conferido:

* na aplicação
* ou em procedure de fechamento

---

# 6) Índices recomendados

## 6.1. Busca de catálogo

### `produto`

* index em `nome_comercial`
* index em `nome_reduzido`
* index em `(categoria_id, fabricante_id)`

### `produto_apresentacao`

* index em `codigo_ean`
* index em `descricao_apresentacao`
* index em `produto_id`

### `substancia_ativa`

* index em `nome`

### `apresentacao_substancia`

* index em `substancia_ativa_id`
* index em `apresentacao_id`

---

## 6.2. Estoque

### `lote_estoque`

* index em `(filial_id, apresentacao_id)`
* index em `(filial_id, data_validade)`
* index em `(apresentacao_id, data_validade)`
* index em `numero_lote`

### `movimento_estoque`

* index em `lote_id`
* index em `data_movimento`

---

## 6.3. Vendas

### `venda`

* index em `filial_id`
* index em `cliente_id`
* index em `usuario_id`
* index em `data_hora`
* index em `(filial_id, data_hora)`

### `venda_item`

* index em `venda_id`
* index em `apresentacao_id`
* index em `lote_id`

### `pagamento`

* index em `venda_id`
* index em `tipo_pagamento`

### `receita_venda_item`

* index em `cpf_paciente`
* index em `crm`
* index em `data_emissao_receita`

---

# 7) DER textual resumido

Aqui está uma visão compacta do desenho.

```text
filial 1---N usuario
filial 1---N lote_estoque
filial 1---N venda

categoria 1---N produto
fabricante 1---N produto
produto 1---N produto_apresentacao

produto_apresentacao 1---N apresentacao_substancia
substancia_ativa 1---N apresentacao_substancia

produto_apresentacao 1---0..1 medicamento_detalhe
produto_apresentacao 1---0..1 equipamento_detalhe
produto_apresentacao 1---N produto_atributo_extra

fornecedor 1---N lote_estoque
produto_apresentacao 1---N lote_estoque
lote_estoque 1---N movimento_estoque

cliente 1---N cliente_convenio
convenio 1---N cliente_convenio

cliente 1---N venda
usuario 1---N venda
convenio 1---N venda
venda 1---N venda_item
venda 1---N pagamento

produto_apresentacao 1---N venda_item
lote_estoque 1---N venda_item

venda_item 1---0..1 receita_venda_item
```

---

# 8) Ordem ideal de criação das tabelas

Para evitar problema de FK, crie nessa ordem:

1. `filial`
2. `usuario`
3. `categoria`
4. `fabricante`
5. `fornecedor`
6. `substancia_ativa`
7. `cliente`
8. `convenio`
9. `produto`
10. `produto_apresentacao`
11. `apresentacao_substancia`
12. `medicamento_detalhe`
13. `equipamento_detalhe`
14. `produto_atributo_extra`
15. `cliente_convenio`
16. `lote_estoque`
17. `movimento_estoque`
18. `venda`
19. `venda_item`
20. `pagamento`
21. `receita_venda_item`
22. `auditoria_log`

---

# 9) Escopo MVP recomendado dentro desse DER

Para você não começar grande demais, eu sugiro implementar primeiro:

### fase 1

* categoria
* fabricante
* substancia_ativa
* produto
* produto_apresentacao
* medicamento_detalhe
* apresentacao_substancia
* cliente
* lote_estoque

### fase 2

* venda
* venda_item
* pagamento
* receita_venda_item
* movimento_estoque

### fase 3

* fornecedor
* convenio
* cliente_convenio
* equipamento_detalhe
* produto_atributo_extra
* auditoria_log

---

# 10) Minha recomendação final de fechamento

Para o **FarmaLocal**, eu consideraria o banco “fechado” quando você tiver:

* DER lógico aprovado
* nomes padronizados
* enums decididos
* nullability decidida
* FKs definidas
* checks definidos
* índices principais definidos
* fluxo de venda fechado
* fluxo de estoque fechado
* fluxo de receita fechado


