# 💊 FarmaLocal

Sistema de gerenciamento para farmácias locais, desenvolvido com **.NET 10**, focado em boas práticas de acesso a dados, arquitetura limpa e estímulo ao pensamento crítico e analítico do desenvolvedor.

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Tecnologias Utilizadas](#tecnologias-utilizadas)
3. [Por que Dapper?](#por-que-dapper)
4. [Transações e Consistência de Dados](#transações-e-consistência-de-dados)
5. [Stored Procedures, Views e Functions](#stored-procedures-views-e-functions)
6. [Padrões de Acesso a Dados](#padrões-de-acesso-a-dados)
7. [Paginação e Performance](#paginação-e-performance)
8. [Migrações de Banco de Dados](#migrações-de-banco-de-dados)
9. [Arquitetura e Padrões de Projeto](#arquitetura-e-padrões-de-projeto)
10. [Pensamento Crítico e Analítico para o Desenvolvedor](#pensamento-crítico-e-analítico-para-o-desenvolvedor)
11. [Como Executar o Projeto](#como-executar-o-projeto)
12. [Contribuição](#contribuição)

---

## 🔍 Visão Geral

O **FarmaLocal** é uma API RESTful para gestão de farmácias de bairro. O projeto cobre os seguintes domínios:

- **Catálogo de Medicamentos** – cadastro, busca e controle de estoque
- **Vendas e Prescrições** – registro de vendas com e sem receita médica
- **Fornecedores** – gestão de fornecedores e pedidos de reposição
- **Funcionários e Papéis** – controle de acesso por perfil (farmacêutico, atendente, gerente)
- **Relatórios e Auditoria** – rastreio de operações para fins legais e gerenciais

---

## 🛠️ Tecnologias Utilizadas

| Camada | Tecnologia |
|---|---|
| Linguagem / Runtime | C# 14 / .NET 10 |
| Banco de Dados | SQL Server / PostgreSQL |
| Micro-ORM | **Dapper 2.x** |
| Migrações | FluentMigrator ou scripts SQL versionados |
| Testes | xUnit + NSubstitute + Testcontainers |
| Documentação da API | Scalar (alternativa ao Swagger UI, compatível com OpenAPI nativo do .NET 10) |
| Contêineres | Docker + Docker Compose |

> **Nota sobre o .NET 10:** O .NET 10 (LTS) traz melhorias significativas de performance no pipeline de HTTP, novos recursos de `System.Text.Json`, suporte aprimorado a OpenAPI nativo e um conjunto de APIs `Span<T>` / `Memory<T>` ainda mais amplo. Aproveite essas melhorias ao implementar os repositórios e os endpoints da API.

---

## ⚙️ Por que Dapper?

### Contexto de decisão

Em muitos projetos, o **Entity Framework Core** é a escolha padrão por abstrair completamente o SQL. No entanto, existem cenários em que um micro-ORM como o **Dapper** é mais adequado:

| Critério | Entity Framework Core | Dapper |
|---|---|---|
| Curva de aprendizado | Alta (LINQ, migrations, change tracker) | Baixa (SQL puro + mapeamento) |
| Performance em consultas complexas | Pode gerar SQL ineficiente | SQL escrito à mão, previsível |
| Stored Procedures / Views / TVFs | Suporte limitado | Suporte nativo e direto |
| Controle total sobre o SQL | Difícil | Total |
| Manutenção em projetos legados | Complicada | Simples (SQL existente reaproveitado) |

### Por que Dapper neste projeto?

1. **SQL explícito**: o desenvolvedor vê e controla exatamente o que é enviado ao banco.
2. **Performance**: mapeamento direto de `IDataReader` para objetos C# sem overhead de rastreamento.
3. **Stored Procedures**: integração nativa via `CommandType.StoredProcedure`.
4. **Aprendizado**: obriga o desenvolvedor a pensar em **índices**, **planos de execução** e **normalização**.

### Exemplo básico de uso

```csharp
public sealed class MedicamentoRepository : IMedicamentoRepository
{
    private readonly IDbConnection _db;

    public MedicamentoRepository(IDbConnection db) => _db = db;

    // Consulta parametrizada – nunca concatene strings com input do usuário!
    public async Task<Medicamento?> ObterPorIdAsync(int id)
    {
        const string sql = "SELECT Id, Nome, PrincipioAtivo, Estoque FROM Medicamentos WHERE Id = @Id";
        return await _db.QueryFirstOrDefaultAsync<Medicamento>(sql, new { Id = id });
    }

    // Inserção com retorno do Id gerado
    public async Task<int> InserirAsync(Medicamento medicamento)
    {
        const string sql = """
            INSERT INTO Medicamentos (Nome, PrincipioAtivo, Estoque)
            OUTPUT INSERTED.Id
            VALUES (@Nome, @PrincipioAtivo, @Estoque)
            """;
        return await _db.ExecuteScalarAsync<int>(sql, medicamento);
    }
}
```

> 💡 **Ponto de reflexão:** Qual o custo de não utilizar parâmetros em consultas SQL? Pesquise sobre **SQL Injection** e como o Dapper mitiga esse risco por padrão.

---

## 🔄 Transações e Consistência de Dados

Transações garantem que um conjunto de operações seja **atômico** (tudo ou nada), **consistente**, **isolado** e **durável** — os famosos critérios **ACID**.

### Quando usar transações?

- Ao registrar uma **venda**: debitar o estoque e criar o registro de venda devem ocorrer juntos.
- Ao processar um **pedido de reposição**: múltiplos itens devem ser persistidos ou todos revertidos.
- Em qualquer operação que envolva **mais de uma tabela** com dependência lógica entre elas.

### Transação manual com Dapper

```csharp
public async Task RegistrarVendaAsync(Venda venda)
{
    using var connection = _connectionFactory.Create();
    await connection.OpenAsync();

    using var transaction = connection.BeginTransaction();
    try
    {
        const string sqlVenda = """
            INSERT INTO Vendas (ClienteId, DataVenda, Total)
            OUTPUT INSERTED.Id
            VALUES (@ClienteId, @DataVenda, @Total)
            """;

        int vendaId = await connection.ExecuteScalarAsync<int>(
            sqlVenda, venda, transaction);

        foreach (var item in venda.Itens)
        {
            const string sqlItem = """
                INSERT INTO ItensVenda (VendaId, MedicamentoId, Quantidade, PrecoUnitario)
                VALUES (@VendaId, @MedicamentoId, @Quantidade, @PrecoUnitario)
                """;
            await connection.ExecuteAsync(sqlItem,
                new { VendaId = vendaId, item.MedicamentoId, item.Quantidade, item.PrecoUnitario },
                transaction);

            const string sqlEstoque = """
                UPDATE Medicamentos
                SET Estoque = Estoque - @Quantidade
                WHERE Id = @Id AND Estoque >= @Quantidade
                """;
            int linhasAfetadas = await connection.ExecuteAsync(
                sqlEstoque, new { item.Quantidade, Id = item.MedicamentoId }, transaction);

            if (linhasAfetadas == 0)
                throw new EstoqueInsuficienteException(item.MedicamentoId);
        }

        transaction.Commit();
    }
    catch
    {
        transaction.Rollback();
        throw;
    }
}
```

### Níveis de isolamento

O SQL Server e o PostgreSQL oferecem diferentes níveis de isolamento. Escolha o nível adequado ao contexto:

| Nível | Phantom Reads | Non-Repeatable Reads | Dirty Reads | Indicado para |
|---|---|---|---|---|
| `READ UNCOMMITTED` | ✅ | ✅ | ✅ | Relatórios não críticos |
| `READ COMMITTED` (padrão) | ✅ | ✅ | ❌ | Maioria das operações |
| `REPEATABLE READ` | ✅ | ❌ | ❌ | Leituras que devem ser estáveis |
| `SERIALIZABLE` | ❌ | ❌ | ❌ | Operações financeiras críticas |
| `SNAPSHOT` (SQL Server) | ❌ | ❌ | ❌ | Alta concorrência sem bloqueios |

```csharp
using var transaction = connection.BeginTransaction(IsolationLevel.RepeatableRead);
```

> 💡 **Ponto de reflexão:** O que acontece com o estoque se duas vendas forem processadas simultaneamente sem o nível de isolamento correto? Estude **race conditions** e **pessimistic vs optimistic concurrency**.

---

## 🗄️ Stored Procedures, Views e Functions

### Stored Procedures

As **Stored Procedures** são blocos de código SQL compilados e armazenados no banco. Elas oferecem:

- **Performance**: plano de execução reutilizado pelo banco
- **Segurança**: permissões granulares por procedure, sem expor tabelas diretamente
- **Centralização**: lógica de negócio complexa mantida no banco quando apropriado

#### Exemplo: Procedure para venda com controle de estoque

```sql
-- SQL Server
CREATE PROCEDURE sp_RegistrarVenda
    @ClienteId  INT,
    @Itens      NVARCHAR(MAX), -- JSON: [{"MedicamentoId":1,"Quantidade":2,"Preco":10.50}]
    @VendaId    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        INSERT INTO Vendas (ClienteId, DataVenda)
        VALUES (@ClienteId, GETDATE());

        SET @VendaId = SCOPE_IDENTITY();

        INSERT INTO ItensVenda (VendaId, MedicamentoId, Quantidade, PrecoUnitario)
        SELECT @VendaId,
               j.MedicamentoId,
               j.Quantidade,
               j.Preco
        FROM OPENJSON(@Itens)
        WITH (MedicamentoId INT, Quantidade INT, Preco DECIMAL(10,2)) AS j;

        UPDATE m
        SET m.Estoque = m.Estoque - j.Quantidade
        FROM Medicamentos m
        JOIN (
            SELECT MedicamentoId, Quantidade
            FROM OPENJSON(@Itens) WITH (MedicamentoId INT, Quantidade INT)
        ) j ON m.Id = j.MedicamentoId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
```

#### Chamada com Dapper

```csharp
public async Task<int> RegistrarVendaViaSpAsync(int clienteId, IEnumerable<ItemVenda> itens)
{
    var parameters = new DynamicParameters();
    parameters.Add("@ClienteId", clienteId);
    parameters.Add("@Itens", JsonSerializer.Serialize(itens));
    parameters.Add("@VendaId", dbType: DbType.Int32, direction: ParameterDirection.Output);

    await _db.ExecuteAsync(
        "sp_RegistrarVenda",
        parameters,
        commandType: CommandType.StoredProcedure);

    return parameters.Get<int>("@VendaId");
}
```

### Views

**Views** são consultas nomeadas e reutilizáveis. Use-as para:
- Simplificar consultas complexas com múltiplos `JOIN`
- Criar uma camada de abstração entre o schema físico e a aplicação
- Implementar **Row-Level Security** via views filtradas

```sql
CREATE VIEW vw_EstoqueCritico AS
SELECT
    m.Id,
    m.Nome,
    m.PrincipioAtivo,
    m.Estoque,
    m.EstoqueMinimo,
    (m.EstoqueMinimo - m.Estoque) AS Deficit
FROM Medicamentos m
WHERE m.Estoque < m.EstoqueMinimo;
```

```csharp
// Consultar a view é idêntico a consultar uma tabela
var criticos = await _db.QueryAsync<AlertaEstoque>(
    "SELECT * FROM vw_EstoqueCritico ORDER BY Deficit DESC");
```

### Table-Valued Functions (TVFs)

Funções de tabela permitem consultas parametrizadas reutilizáveis:

```sql
CREATE FUNCTION fn_VendasPorPeriodo
(
    @Inicio DATE,
    @Fim    DATE
)
RETURNS TABLE AS
RETURN
(
    SELECT
        v.Id,
        v.DataVenda,
        c.Nome AS Cliente,
        SUM(i.Quantidade * i.PrecoUnitario) AS Total
    FROM Vendas v
    JOIN Clientes c ON c.Id = v.ClienteId
    JOIN ItensVenda i ON i.VendaId = v.Id
    WHERE v.DataVenda BETWEEN @Inicio AND @Fim
    GROUP BY v.Id, v.DataVenda, c.Nome
);
```

```csharp
var vendas = await _db.QueryAsync<ResumoVenda>(
    "SELECT * FROM fn_VendasPorPeriodo(@Inicio, @Fim)",
    new { Inicio = DateTime.Today.AddDays(-30), Fim = DateTime.Today });
```

> 💡 **Ponto de reflexão:** Quando faz sentido colocar lógica no banco (procedures/functions) versus na aplicação? Avalie os impactos em **testabilidade**, **portabilidade** e **manutenabilidade**.

---

## 📊 Padrões de Acesso a Dados

### Repository Pattern

Abstraia o acesso ao banco atrás de interfaces para facilitar testes e trocar implementações:

```csharp
public interface IMedicamentoRepository
{
    Task<Medicamento?> ObterPorIdAsync(int id);
    Task<IEnumerable<Medicamento>> ListarAsync(FiltroMedicamento filtro);
    Task<int> InserirAsync(Medicamento medicamento);
    Task AtualizarAsync(Medicamento medicamento);
    Task RemoverAsync(int id);
}
```

### Unit of Work

Coordene múltiplos repositórios dentro da mesma transação:

```csharp
public interface IUnitOfWork : IDisposable
{
    IMedicamentoRepository Medicamentos { get; }
    IVendaRepository Vendas { get; }
    Task<int> CommitAsync();
    Task RollbackAsync();
}

public sealed class UnitOfWork : IUnitOfWork
{
    private readonly IDbConnection _connection;
    private IDbTransaction? _transaction;

    public UnitOfWork(IDbConnection connection)
    {
        _connection = connection;
        _connection.Open();
        _transaction = _connection.BeginTransaction();

        Medicamentos = new MedicamentoRepository(_connection, _transaction);
        Vendas = new VendaRepository(_connection, _transaction);
    }

    public IMedicamentoRepository Medicamentos { get; }
    public IVendaRepository Vendas { get; }

    public Task<int> CommitAsync()
    {
        _transaction?.Commit();
        return Task.FromResult(0);
    }

    public Task RollbackAsync()
    {
        _transaction?.Rollback();
        return Task.CompletedTask;
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _connection.Dispose();
    }
}
```

### CQRS (Command Query Responsibility Segregation)

Separe as operações de **leitura** (queries) das de **escrita** (commands). Em farmácias, relatórios e buscas são muito mais frequentes do que inserções. O CQRS permite otimizar cada lado de forma independente:

```
src/
  Application/
    Commands/
      RegistrarVendaCommand.cs
      RegistrarVendaHandler.cs
    Queries/
      ListarMedicamentosQuery.cs
      ListarMedicamentosHandler.cs   ← Dapper direto, sem repositórios complexos
```

---

## 🚀 Paginação e Performance

### Paginação com OFFSET/FETCH

Nunca retorne listas inteiras ao cliente. Use paginação do lado do banco:

```csharp
public async Task<PagedResult<Medicamento>> ListarPaginadoAsync(int pagina, int tamanhoPagina)
{
    const string sqlDados = """
        SELECT Id, Nome, PrincipioAtivo, Estoque
        FROM Medicamentos
        ORDER BY Nome
        OFFSET @Offset ROWS FETCH NEXT @TamanhoPagina ROWS ONLY
        """;

    const string sqlTotal = "SELECT COUNT(*) FROM Medicamentos";

    // Ambos os fragmentos são constantes – não há interpolação de input do usuário
    using var multi = await _db.QueryMultipleAsync(
        sqlDados + "; " + sqlTotal,
        new { Offset = (pagina - 1) * tamanhoPagina, TamanhoPagina = tamanhoPagina });

    var dados = (await multi.ReadAsync<Medicamento>()).ToList();
    int total = await multi.ReadFirstAsync<int>();

    return new PagedResult<Medicamento>(dados, total, pagina, tamanhoPagina);
}
```

### Índices

Crie índices nas colunas mais consultadas. Ausência de índices é uma das causas mais comuns de lentidão:

```sql
-- Busca frequente por nome de medicamento
CREATE INDEX IX_Medicamentos_Nome ON Medicamentos (Nome);

-- Busca por princípio ativo
CREATE INDEX IX_Medicamentos_PrincipioAtivo ON Medicamentos (PrincipioAtivo);

-- Índice composto para relatórios de vendas por período e cliente
CREATE INDEX IX_Vendas_ClienteId_DataVenda ON Vendas (ClienteId, DataVenda DESC);
```

> 💡 **Ponto de reflexão:** Índices aceleram leituras mas custam espaço e tornam escritas mais lentas. Como você avaliaria quais índices criar? Pesquise sobre o **Execution Plan** (SSMS / `EXPLAIN ANALYZE` no PostgreSQL) e **index selectivity**.

---

## 🔄 Migrações de Banco de Dados

Jamais altere o banco manualmente em produção. Use migrações versionadas:

```
database/
  migrations/
    V001__criar_tabela_medicamentos.sql
    V002__criar_tabela_clientes.sql
    V003__criar_tabela_vendas.sql
    V004__criar_stored_procedure_registrar_venda.sql
    V005__criar_view_estoque_critico.sql
    V006__adicionar_indice_medicamentos_nome.sql
```

Cada arquivo deve ser **idempotente** quando possível:

```sql
-- V001__criar_tabela_medicamentos.sql
IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE name = 'Medicamentos' AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE Medicamentos (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        Nome            NVARCHAR(200)     NOT NULL,
        PrincipioAtivo  NVARCHAR(200)     NOT NULL,
        Estoque         INT               NOT NULL DEFAULT 0,
        EstoqueMinimo   INT               NOT NULL DEFAULT 5,
        Preco           DECIMAL(10, 2)    NOT NULL,
        CriadoEm        DATETIME2         NOT NULL DEFAULT GETUTCDATE(),
        AtualizadoEm    DATETIME2         NOT NULL DEFAULT GETUTCDATE()
    );
END;
```

---

## 🏗️ Arquitetura e Padrões de Projeto

```
farmalocal/
├── src/
│   ├── FarmaLocal.API/            # Endpoints HTTP (Minimal APIs / Controllers)
│   ├── FarmaLocal.Application/    # Use Cases, Commands, Queries, DTOs
│   ├── FarmaLocal.Domain/         # Entidades, Value Objects, Enums, Interfaces
│   └── FarmaLocal.Infrastructure/ # Repositórios (Dapper), Migrations, Configs
├── tests/
│   ├── FarmaLocal.UnitTests/      # Testes das regras de negócio (sem banco)
│   └── FarmaLocal.IntegrationTests/ # Testes com banco real (Testcontainers)
├── database/
│   ├── migrations/                # Scripts SQL versionados
│   └── seeds/                     # Dados iniciais para desenvolvimento
└── docker-compose.yml
```

### Princípios aplicados

- **Clean Architecture** – dependências apontam para dentro (domínio não depende de infraestrutura)
- **Dependency Inversion** – repositórios e serviços injetados via interface
- **Single Responsibility** – cada classe tem uma única razão para mudar
- **Fail Fast** – validações e verificações de estoque ocorrem o quanto antes, evitando operações desnecessárias no banco

---

## 🧠 Pensamento Crítico e Analítico para o Desenvolvedor

Este projeto foi desenhado para estimular perguntas difíceis. Para cada funcionalidade que você implementar, questione:

### Sobre o banco de dados
- [ ] Esta consulta vai funcionar bem com 1 milhão de registros? Existe índice nas colunas do `WHERE` e `ORDER BY`?
- [ ] Estou buscando colunas que não utilizo (`SELECT *`)? Isso desperdiça banda de rede e memória.
- [ ] A transação está no menor escopo possível? Transações longas causam bloqueios.
- [ ] Devo usar otimismo (`ROWVERSION` / `ETag`) ou pessimismo (`WITH (UPDLOCK)`) para controlar concorrência?
- [ ] Procedure ou lógica na aplicação? Qual é mais fácil de testar, versionar e manter?

### Sobre o código
- [ ] Estou vazando a `IDbConnection` para camadas que não deveriam conhecer o banco?
- [ ] A string de conexão está em variável de ambiente / secrets, não no `appsettings.json`?
- [ ] Os repositórios são testáveis unitariamente? Posso substituir a conexão por um mock?
- [ ] Estou tratando corretamente exceções do banco (`SqlException`, `DbException`)?

### Sobre a arquitetura
- [ ] Se eu precisar trocar SQL Server por PostgreSQL amanhã, quantos arquivos precisam mudar?
- [ ] Minhas migrations são reversíveis? Consigo fazer rollback sem perder dados?
- [ ] Os endpoints da API são idempotentes? Uma segunda chamada com os mesmos dados causa duplicação?
- [ ] Como vou rastrear erros em produção? Os logs contêm contexto suficiente?

### Desafios propostos
1. **Auditoria**: implemente uma tabela de log que registre automaticamente toda alteração em `Medicamentos` usando um trigger SQL.
2. **Concorrência**: simule duas requisições simultâneas de venda do mesmo medicamento com estoque = 1. Qual nível de isolamento garante que apenas uma seja aprovada?
3. **Relatório de desempenho**: use `EXPLAIN ANALYZE` (PostgreSQL) ou o "Execution Plan" (SQL Server) para comparar uma consulta sem índice e com índice.
4. **Retry com Polly**: adicione uma política de retry para transações que falham por deadlock (`SqlException` com código 1205).
5. **Soft Delete**: implemente exclusão lógica (`AtivoEm`/`InativoEm`) e garanta que todas as queries filtrem corretamente os registros inativos.

---

## ▶️ Como Executar o Projeto

### Pré-requisitos

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)
- [Docker](https://www.docker.com/) (para o banco de dados)

### Subindo o banco com Docker

```bash
docker compose up -d
```

### Executando as migrações

```bash
# Exemplo com script de migração manual
dotnet run --project src/FarmaLocal.Migrations
```

### Rodando a API

```bash
dotnet run --project src/FarmaLocal.API
```

A documentação interativa da API estará disponível em: `https://localhost:5001/scalar`

### Executando os testes

```bash
# Testes unitários
dotnet test tests/FarmaLocal.UnitTests

# Testes de integração (requer Docker)
dotnet test tests/FarmaLocal.IntegrationTests
```

---

## 🤝 Contribuição

1. Faça um fork do repositório
2. Crie uma branch: `git checkout -b feature/minha-feature`
3. Implemente sua mudança seguindo os padrões do projeto
4. Escreva testes para o código novo
5. Abra um Pull Request descrevendo o problema resolvido e a solução adotada

---

## 📄 Licença

Distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
