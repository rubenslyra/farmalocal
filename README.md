# 💊 FarmaLocal

Sistema de gerenciamento para farmácias locais, desenvolvido com **.NET 10**, focado em boas práticas de acesso a dados, arquitetura limpa e estímulo ao pensamento crítico e analítico do desenvolvedor.
---

Sim — e o melhor caminho é justamente transformar os dois em uma **proposta única, coerente e madura**, unindo:

* o **material bruto de pesquisa farmacêutica**
* a **visão de negócio do FarmaLocal**
* a **modelagem corporativa do banco**
* a **estratégia técnica para estudo com SQL, C#, Dapper e futuras variações**

Abaixo está o **merge completo e rico**, já consolidado como base oficial do projeto.

---

# FarmaLocal — Modelo de Negócio + Modelo de Dados + Direção Técnica

## 1. Visão geral do projeto

O **FarmaLocal** é um projeto de estudos com foco em engenharia de software aplicada ao domínio farmacêutico. A proposta é desenvolver um sistema de gestão e vendas para farmácias, com base em práticas reais de mercado, permitindo estudar e comparar tecnologias como **SQL, PostgreSQL, SQL Server, C#, Dapper, APIs, aplicações desktop e futuras versões em outras linguagens e frameworks**.

O projeto não deve ser tratado como um CRUD simples. Ele deve funcionar como um **laboratório de arquitetura de software**, com um domínio suficientemente rico para exigir:

* modelagem relacional séria
* regras transacionais
* integridade referencial
* especialização de entidades
* rastreabilidade de estoque
* validações regulatórias
* separação entre núcleo operacional e extensões do domínio

Em outras palavras, o FarmaLocal pode virar um projeto-âncora de portfólio técnico.

---

## 2. Objetivo do sistema

O objetivo do FarmaLocal é permitir a gestão integrada de:

* catálogo de produtos farmacêuticos e não farmacêuticos
* medicamentos e suas particularidades regulatórias
* estoque por lote e validade
* vendas no balcão/PDV
* receitas vinculadas à venda
* clientes, convênios e histórico de compra
* relatórios operacionais e gerenciais

Além disso, o sistema deve servir como base para diferentes implementações, mantendo o mesmo domínio e a mesma lógica de negócio.

---

## 3. Conceito central da modelagem

O ponto mais importante do seu material está correto e deve ser preservado no desenho final:

> **medicamento não deve existir como um sistema isolado fora do catálogo**
>
> o correto é ter uma **base única de produtos**, com especializações para os itens que possuem exigências próprias, como medicamentos, equipamentos e itens de higiene.

Essa é a abordagem mais profissional porque:

* mantém o PDV unificado
* evita duplicação de estrutura
* facilita estoque e financeiro
* permite especializar sem quebrar o núcleo
* funciona melhor para expansão futura

Portanto, o FarmaLocal deve nascer com uma arquitetura baseada em:

### núcleo central

* produto
* categoria
* fabricante
* apresentação
* estoque
* venda

### extensões especializadas

* medicamento
* princípio ativo
* receita
* equipamento
* atributos extras por categoria

---

## 4. Modelo de negócio consolidado

## 4.1. Proposta de valor

O FarmaLocal oferece uma estrutura de gestão farmacêutica que une:

* operação de loja
* controle de estoque com rastreabilidade
* suporte à venda de medicamentos sujeitos a regras
* busca por nome comercial e princípio ativo
* unificação de medicamentos, higiene, perfumaria, correlatos e equipamentos em um único sistema

Para projeto de estudo, isso tem um valor enorme porque permite praticar cenários reais como:

* venda com transação
* controle de lote
* integridade de estoque
* descontos e convênios
* busca inteligente
* validação regulatória
* relatórios orientados a negócio

---

## 4.2. Público-alvo do sistema

Embora seja um projeto de estudos, o modelo deve refletir um sistema que serviria para:

* farmácias independentes
* drogarias de bairro
* pequenas redes
* balcão
* caixa
* farmacêutico
* gestor de estoque
* administrador da loja

---

## 4.3. Problemas que o sistema resolve

O sistema precisa resolver estes problemas centrais:

* controlar diferentes tipos de produto em um mesmo catálogo
* permitir a venda segura de medicamentos
* rastrear lotes e validade
* impedir venda irregular de itens que exigem receita
* permitir busca por nome comercial, fabricante e princípio ativo
* manter integridade no estoque
* suportar descontos, convênios e histórico do cliente
* gerar dados confiáveis para relatórios

---

## 4.4. Módulos do sistema

O FarmaLocal pode ser dividido em módulos:

### Catálogo

* categorias
* fabricantes/laboratórios
* produtos
* apresentações
* princípios ativos

### Medicamentos

* tipo do medicamento
* tarja
* registro
* exigência de receita
* controle especial

### Estoque

* lotes
* validade
* movimentações
* entrada e saída
* critério FEFO

### PDV

* venda
* itens
* desconto
* pagamento
* vinculação ao lote

### Receita e regulação

* dados da receita
* médico
* paciente
* retenção
* vínculo ao item vendido

### Relacionamento

* cliente
* convênio
* histórico
* compras por CPF

### Relatórios

* produtos vencendo
* mais vendidos
* giro por categoria
* venda por fabricante
* venda por princípio ativo
* clientes recorrentes

---

# 5. Modelo conceitual do domínio

Agora vem o merge mais importante: o seu material bruto com uma modelagem mais sólida.

## 5.1. Produto como entidade-base

A entidade **Produto** é a base comercial e operacional do sistema. Ela representa o item de catálogo, independentemente de ser:

* medicamento
* correlato
* higiene
* perfumaria
* equipamento
* suplemento

Isso evita criar “silos” de modelagem.

### Produto deve conter

* identidade comercial
* categoria
* fabricante
* nome de exibição
* status de ativação

Mas ele **não deve carregar tudo sozinho**.

---

## 5.2. Apresentação como unidade vendável

Aqui está uma melhoria importante sobre o texto bruto: o que é vendido no PDV normalmente não é o “produto abstrato”, mas a sua **apresentação específica**.

Exemplo:

* Produto: Paracetamol
* Apresentação 1: Paracetamol 500mg comprimido caixa com 10
* Apresentação 2: Paracetamol 750mg comprimido caixa com 20
* Apresentação 3: Paracetamol gotas 200mg/ml frasco 15ml

Por isso, o sistema deve ter uma tabela de **apresentação**.

Essa tabela é a verdadeira unidade comercial de venda, estoque, EAN e preço.

---

## 5.3. Distinção entre marca, nome comercial e princípio ativo

O seu material já traz essa distinção, e ela deve ser mantida.

### Fabricante / laboratório

É a empresa responsável pela marca, produção ou titularidade do produto.

Exemplos:

* EMS
* Medley
* Eurofarma
* Pfizer
* Bayer

### Nome comercial

É o nome fantasia usado comercialmente.

Exemplos:

* Tylenol
* Novalgina
* Advil
* Aspirina

### Princípio ativo

É a substância química responsável pelo efeito terapêutico.

Exemplos:

* Paracetamol
* Dipirona monoidratada
* Ibuprofeno
* Amoxicilina

### Conclusão de modelagem

Então o correto é:

* **Fabricante** em tabela própria
* **Nome comercial** como atributo do produto
* **Princípio ativo** em tabela própria ou estrutura própria de relacionamento

Isso permite:

* agrupar similares e genéricos
* buscar por substância
* sugerir alternativa terapêutica equivalente
* separar identidade comercial da identidade farmacológica

---

## 5.4. Princípio ativo e composição não são a mesma coisa

Esse ponto do seu material também está correto, mas merece fechamento técnico.

### Princípio ativo

É a substância que faz efeito.

### Composição

É a fórmula completa, podendo incluir:

* princípio ativo
* excipientes
* veículos
* corantes
* conservantes

Para o **escopo do sistema de vendas e estoque**, você não precisa cadastrar a composição completa da bula em nível detalhado.

A modelagem ideal é:

* cadastrar **princípio ativo**
* cadastrar **concentração/dosagem**
* permitir associação de uma apresentação com uma ou mais substâncias ativas

Ou seja: para fins operacionais, o sistema precisa modelar o que influencia atendimento, intercambialidade, busca e venda — não necessariamente toda a formulação química da bula.

---

# 6. Estrutura corporativa recomendada para o banco

A melhor forma corporativa para “fechar o banco” do FarmaLocal é esta:

## 6.1. Estratégia geral

Usar:

* **modelo relacional normalizado no núcleo**
* **tabelas especializadas para domínios específicos**
* **integridade forte no banco**
* **campos flexíveis só para cenários não críticos**

Traduzindo:

* nada de uma tabela única gigante
* nada de jogar tudo em JSON
* nada de duplicar informações centrais
* especialização onde a regra muda
* estoque por lote
* venda por apresentação
* medicamento com detalhes próprios

---

## 6.2. Grandes blocos do modelo

### Núcleo mestre

* categoria
* fabricante
* produto
* produto_apresentacao
* substancia_ativa

### Especialização farmacêutica

* medicamento_detalhe
* apresentacao_substancia
* receita_venda_item

### Operação

* fornecedor
* lote_estoque
* movimento_estoque
* venda
* venda_item
* pagamento

### Relacionamento

* cliente
* convenio
* cliente_convenio

### Governança

* usuario
* filial
* auditoria_log

---

# 7. Modelo lógico consolidado

Abaixo está a versão mais madura da modelagem.

## 7.1. `categoria`

Representa o macrogrupo do item.

**Campos sugeridos**

* id
* nome
* descricao
* ativo

**Exemplos**

* Medicamento
* Higiene
* Perfumaria
* Equipamento
* Correlato
* Suplemento

---

## 7.2. `fabricante`

Representa a empresa/laboratório.

**Campos sugeridos**

* id
* razao_social
* nome_fantasia
* cnpj
* email
* telefone
* ativo

---

## 7.3. `produto`

Representa o item-base de catálogo.

**Campos sugeridos**

* id
* categoria_id
* fabricante_id
* nome_comercial
* nome_reduzido
* descricao
* tipo_produto
* ativo
* data_criacao
* data_atualizacao

### Observação

Para genéricos, `nome_comercial` pode ser nulo, e o sistema pode exibir algo derivado do princípio ativo + fabricante.

---

## 7.4. `substancia_ativa`

Representa o princípio ativo.

**Campos sugeridos**

* id
* nome
* descricao
* ativo

---

## 7.5. `produto_apresentacao`

Essa é uma das entidades mais importantes do sistema.

Representa a forma vendável do produto.

**Campos sugeridos**

* id
* produto_id
* codigo_ean
* sku_interno
* unidade_medida
* quantidade_embalagem
* forma_farmaceutica
* dosagem_texto
* volume_texto
* concentracao_principal_texto
* preco_venda
* ativo

### Exemplos

* Novalgina 500mg comprimido cx 20
* Dipirona gotas 500mg/ml frasco 20ml
* Fralda infantil G pacote 32 un
* Medidor de pressão digital braço

---

## 7.6. `apresentacao_substancia`

Relaciona uma apresentação a uma ou mais substâncias ativas.

**Campos sugeridos**

* id
* apresentacao_id
* substancia_ativa_id
* concentracao
* unidade_concentracao
* principal

### Por que ela é importante?

Porque resolve:

* busca por princípio ativo
* agrupamento de genérico/similar/referência
* produtos com mais de uma substância

---

## 7.7. `medicamento_detalhe`

Tabela de extensão para apresentações que pertencem ao universo farmacêutico.

**Campos sugeridos**

* apresentacao_id
* tipo_medicamento
* registro_anvisa
* tarja
* requer_receita
* retencao_receita
* controlado_sngpc
* uso_continuo
* permite_intercambialidade
* observacoes

### Valores possíveis

**tipo_medicamento**

* Referência
* Genérico
* Similar

**tarja**

* Sem Tarja
* Amarela
* Vermelha
* Preta

---

## 7.8. `fornecedor`

Origem de compra do item.

**Campos sugeridos**

* id
* razao_social
* nome_fantasia
* cnpj
* telefone
* email
* ativo

---

## 7.9. `lote_estoque`

Controla rastreabilidade, validade e quantidade do lote.

**Campos sugeridos**

* id
* apresentacao_id
* fornecedor_id
* numero_lote
* data_fabricacao
* data_validade
* quantidade_atual
* quantidade_reservada
* custo_unitario
* ativo

### Regra essencial

A venda deve sugerir o lote com validade mais próxima, respeitando FEFO.

---

## 7.10. `movimento_estoque`

Registra tudo que entra e sai do estoque.

**Campos sugeridos**

* id
* lote_id
* tipo_movimento
* quantidade
* data_movimento
* documento_referencia
* origem
* usuario_id
* observacoes

### Tipos possíveis

* Entrada
* Saída
* Ajuste
* Perda
* Cancelamento
* Inventário

---

## 7.11. `cliente`

Cadastro do consumidor.

**Campos sugeridos**

* id
* nome
* cpf
* data_nascimento
* telefone
* email
* ativo

---

## 7.12. `convenio`

Tabela de convênios ou programas de desconto.

**Campos sugeridos**

* id
* nome
* percentual_desconto
* ativo

---

## 7.13. `cliente_convenio`

Relacionamento entre cliente e convênio.

**Campos sugeridos**

* id
* cliente_id
* convenio_id
* matricula
* ativo

---

## 7.14. `venda`

Cabeçalho da venda.

**Campos sugeridos**

* id
* filial_id
* cliente_id
* usuario_id
* data_hora
* subtotal
* desconto
* total
* status

### Status possíveis

* Aberta
* Finalizada
* Cancelada

---

## 7.15. `venda_item`

Itens da venda.

**Campos sugeridos**

* id
* venda_id
* apresentacao_id
* lote_id
* quantidade
* preco_unitario
* desconto
* subtotal

### Regra fundamental

Todo item vendido deve apontar para a apresentação e, quando controlado por lote, para o lote específico.

---

## 7.16. `pagamento`

Pagamentos vinculados à venda.

**Campos sugeridos**

* id
* venda_id
* tipo_pagamento
* valor
* data_pagamento
* codigo_autorizacao
* observacoes

### Tipos possíveis

* Dinheiro
* Débito
* Crédito
* Pix
* Convênio

---

## 7.17. `receita_venda_item`

Guarda os dados de receita quando exigidos.

**Campos sugeridos**

* id
* venda_item_id
* nome_medico
* crm
* uf_crm
* nome_paciente
* cpf_paciente
* data_emissao_receita
* data_validade_receita
* tipo_documento
* receita_retida
* observacoes

### Observação

Essa tabela deve ser obrigatória para itens cuja regra de negócio exigir retenção ou dados formais de prescrição.

---

## 7.18. `equipamento_detalhe`

Especialização opcional para equipamentos.

**Campos sugeridos**

* apresentacao_id
* garantia_meses
* numero_registro
* possui_anvisa
* manual_url
* voltagem

---

## 7.19. `produto_atributo_extra`

Para itens não críticos com grande variação de atributos.

**Campos sugeridos**

* id
* apresentacao_id
* nome_atributo
* valor_atributo

Isso serve para:

* fraldas
* aparelhos
* itens de higiene
* variações comerciais que não justificam novas colunas

### Exemplo

Fralda:

* tamanho = G
* peso_suportado = 9kg a 12kg
* quantidade_pacote = 32

Esse recurso é bom, mas deve ser usado com moderação.
Nunca deve substituir os campos críticos do domínio.

---

# 8. Regras de negócio fechadas

Agora o merge das regras precisa ficar explícito.

## 8.1. Venda acontece pela apresentação

O PDV nunca vende o “produto abstrato”.
Ele vende a **apresentação**.

---

## 8.2. Estoque é controlado por lote quando aplicável

Medicamentos e vários itens farmacêuticos precisam de rastreabilidade por lote.

---

## 8.3. FEFO deve ser a regra padrão

O lote sugerido deve ser o que vencer primeiro, desde que esteja válido e disponível.

---

## 8.4. Receita é obrigatória quando o item exigir

Se `requer_receita = true`, o sistema precisa exigir dados mínimos de prescrição.

---

## 8.5. Retenção bloqueia finalização sem dados completos

Se `retencao_receita = true`, a venda do item não deve ser concluída sem vínculo formal da receita.

---

## 8.6. Medicamento controlado exige fluxo especial

Se `controlado_sngpc = true`, o sistema deve sinalizar fluxo especial e permitir futura integração/geração de dados regulatórios.

---

## 8.7. Busca deve ocorrer por múltiplos caminhos

O balconista precisa encontrar o item por:

* nome comercial
* princípio ativo
* EAN
* fabricante
* categoria

---

## 8.8. Genérico e referência precisam conviver no mesmo ecossistema

O sistema deve permitir localizar um produto de marca e sugerir alternativas com mesmo princípio ativo.

---

## 8.9. Produtos não medicamentos seguem o mesmo núcleo

Fralda, shampoo, medidor de pressão e suplemento devem estar no mesmo catálogo central, sem criar um sistema paralelo.

---

# 9. Como fechar o banco de forma corporativa

Aqui está a resposta mais direta à sua necessidade prática.

## 9.1. Fechar o banco não é só fazer o DER

Você precisa fechar:

* modelo conceitual
* modelo lógico
* nomenclatura
* tipos de dados
* constraints
* índices
* regras de nulidade
* regras de negócio
* scripts de migração
* dados iniciais

---

## 9.2. Dicionário de dados obrigatório

Crie um documento com:

* tabela
* finalidade
* coluna
* tipo
* obrigatório ou não
* default
* FK
* unique
* check
* regra funcional

Sem isso, o banco fica “desenhado”, mas não governado.

---

## 9.3. Padronização de nomenclatura

Sugestão:

* tabelas em `snake_case`
* chave primária sempre `id`
* FK sempre `xxx_id`
* datas em `data_criacao`, `data_atualizacao`
* booleanos sem ambiguidade:

  * ativo
  * requer_receita
  * controlado_sngpc
  * receita_retida

---

## 9.4. Integridade no banco

Não deixe toda a responsabilidade só na aplicação.

Use:

* `primary key`
* `foreign key`
* `unique`
* `check constraints`
* `not null`
* índices

### Exemplos

* `codigo_ean` único quando preenchido
* `cpf` único para cliente
* `quantidade_atual >= 0`
* `preco_venda >= 0`
* `data_validade > data_fabricacao` quando aplicável

---

## 9.5. Normalização com pragmatismo

A recomendação é:

* núcleo em 3FN
* sem duplicar fabricante
* sem duplicar substância ativa
* sem repetir categoria em tudo
* views para leitura quando necessário

---

## 9.6. Versionamento do schema

Isso é essencial para estudo sério e padrão corporativo.

Estruture assim:

```text
/database
  /postgresql
    /migrations
    /seeds
    /views
    /functions
  /sqlserver
    /migrations
    /seeds
    /views
    /functions
```

Cada mudança no banco deve virar migration.

---

# 10. Estratégia técnica para PostgreSQL e SQL Server

Como você quer estudar múltiplos bancos, a melhor abordagem é:

## 10.1. Mesmo modelo lógico, implementação física adaptada

Mantenha iguais:

* entidades
* relacionamentos
* regras
* nomes de tabelas
* semântica do domínio

Adapte por SGBD:

* tipos
* identity/sequence
* funções
* sintaxe específica
* JSON/JSONB
* procedures

---

## 10.2. Estrutura recomendada do projeto

```text
/docs
  modelo-negocio.md
  regras-negocio.md
  dicionario-dados.md
  fluxos-operacionais.md

/database
  /postgresql
    /migrations
    /seeds
    /scripts
  /sqlserver
    /migrations
    /seeds
    /scripts

/src
  /FarmaLocal.Domain
  /FarmaLocal.Application
  /FarmaLocal.Infrastructure
  /FarmaLocal.Api
  /FarmaLocal.Desktop
```

---

# 11. Dapper no FarmaLocal

O Dapper entra muito bem nesse projeto porque o domínio exige:

* consultas rápidas
* joins claros
* controle fino do SQL
* transações explícitas
* boa performance no PDV

## 11.1. Onde usar Dapper

* busca de produtos
* consulta por EAN
* listagem de estoque
* seleção de lote FEFO
* fechamento de venda
* relatórios operacionais

## 11.2. Onde tomar cuidado

* múltiplos inserts dependentes
* controle de estoque
* fechamento da venda
* cancelamento
* baixa de lote

Esses cenários devem usar transação explícita.

## 11.3. Fluxo transacional de venda

Exemplo ideal:

1. abrir transação
2. inserir venda
3. inserir itens
4. validar exigência de receita
5. baixar lote
6. inserir pagamentos
7. gravar movimentos de estoque
8. commit

Se qualquer etapa falhar:

* rollback

---

# 12. Escopo ideal de MVP

Para não explodir o escopo, o MVP pode ser:

## Cadastro

* categoria
* fabricante
* substância ativa
* produto
* apresentação
* medicamento_detalhe
* lote

## Operação

* cliente
* venda
* venda_item
* pagamento
* receita_venda_item

## Regras

* busca por nome comercial e princípio ativo
* venda por apresentação
* baixa por lote
* FEFO
* exigência de receita quando aplicável

## Relatórios

* estoque atual
* lotes a vencer
* itens mais vendidos
* vendas por período

Esse MVP já é muito forte para estudo.

---

# 13. Conclusão consolidada

O merge completo entre o seu material bruto e a estrutura mais corporativa resulta nesta decisão:

## Decisão oficial para o FarmaLocal

O FarmaLocal deve ser construído como um **sistema de farmácia baseado em um catálogo central de produtos**, com **especializações para medicamentos e outros tipos de item**, **controle de estoque por lote**, **venda transacional por apresentação**, **regras regulatórias explícitas**, e **documentação formal do banco**, permitindo estudo sério de SQL, C#, Dapper e implementações futuras em outras stacks.

## Em termos práticos, isso significa:

* produto base
* apresentação vendável
* medicamento como extensão
* princípio ativo separado
* lote separado
* venda por lote
* receita vinculada ao item
* banco normalizado
* schema versionado
* domínio reaproveitável entre PostgreSQL e SQL Server

---

## 📄 Licença

Distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
