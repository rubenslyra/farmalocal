# FarmaLocal — Scripts SQL Server (T-SQL)

Pacote de scripts para SQL Server, em T-SQL, alinhado a práticas oficiais da Microsoft:
- schema dedicado (`farmalocal`)
- tabelas com `IDENTITY(1,1)` para PKs numéricas
- `PRIMARY KEY`, `FOREIGN KEY`, `CHECK` e índices nomeados
- índices únicos filtrados para colunas anuláveis
- script-modelo de carga CSV com `BULK INSERT`
- script de reseed com `DBCC CHECKIDENT`

## Ordem sugerida
1. `001_create_schema.sql`
2. `002_create_tables.sql`
3. `003_indexes.sql`
4. `004_seeds.sql`
5. `005_bulk_import_template.sql` (opcional)
6. `006_reseed_identities.sql` (após importação manual)

## Observações
- `CREATE SCHEMA` deve rodar em batch separado.
- Ajuste o nome do banco antes de executar, se necessário.
- O script de importação usa caminhos absolutos do Windows (`C:\dados\...`) como modelo.
- Para `BULK INSERT`, o serviço do SQL Server precisa conseguir acessar os arquivos CSV.
