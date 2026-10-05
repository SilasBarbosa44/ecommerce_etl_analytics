# ETL Ecommerce Analytics

Pipeline de dados desenvolvido para simular um processo completo de **ETL (Extract, Transform, Load)** utilizando Python, Pandas, MySQL, SQL e Power BI.

O projeto realiza a extração de dados de planilhas Excel, transformação e validação dos dados com Python/Pandas, carregamento em um banco de dados MySQL, análise através de consultas SQL e visualização dos indicadores em um dashboard no Power BI.

---

## 🚀 Tecnologias utilizadas

* Python
* Pandas
* SQLAlchemy
* MySQL
* SQL
* Power BI
* Excel

---

## 📊 Arquitetura do Pipeline

```text
Excel
   ↓
Python + Pandas
   ↓
Extração
   ↓
Transformação
   ↓
Validação
   ↓
MySQL
   ↓
Consultas SQL
   ↓
Power BI
   ↓
Dashboard
```

---

## 📁 Estrutura do projeto

```text
ETL_ecommerce_analytics/
│
├── dados/
│   ├── clientes.xlsx
│   ├── vendedores.xlsx
│   ├── produtos.xlsx
│   ├── pedidos.xlsx
│   └── itens_pedido.xlsx
│
├── Python/
│   └── ETL_Ecommerce_analytics.py
│
├── SQL/
│   └── queries.sql
│
├── Power BI/
│   └── Ecommerce Analytics.pbix
│
├── .gitignore
└── README.md
```

---

## 🗄️ Banco de dados

Banco utilizado:

```text
etl_ecommerce_analytics
```

O banco possui cinco tabelas:

```text
clientes
produtos
vendedores
pedidos
itens_pedido
```

### Relacionamentos

```text
clientes
   │
   └── pedidos
          │
          ├── vendedores
          │
          └── itens_pedido
                    │
                    └── produtos
```

---

## 🔄 Processo ETL

### 1. Extract

Os dados são extraídos de cinco arquivos Excel:

* `clientes.xlsx`
* `vendedores.xlsx`
* `produtos.xlsx`
* `pedidos.xlsx`
* `itens_pedido.xlsx`

A extração é realizada utilizando Pandas:

```python
pd.read_excel()
```

O processo também utiliza logging para acompanhar o carregamento das planilhas e identificar possíveis erros.

---

### 2. Transform

Os dados passam por etapas de tratamento utilizando Pandas.

Entre as transformações realizadas estão:

* Conversão de IDs para valores numéricos
* Tratamento de datas
* Remoção de espaços desnecessários
* Padronização de nomes
* Padronização de cidades
* Padronização de estados
* Padronização de categorias
* Conversão de valores monetários
* Tratamento de valores inválidos
* Remoção de registros com valores nulos em campos importantes
* Validação de valores negativos

Exemplo:

```python
df["nome"] = df["nome"].str.strip().str.lower()
```

Conversão de valores:

```python
df["preco"] = pd.to_numeric(
    df["preco"],
    errors="coerce"
)
```

Tratamento de datas:

```python
df["data_pedido"] = pd.to_datetime(
    df["data_pedido"],
    errors="coerce"
)
```

---

### 3. Load

Após o tratamento, os DataFrames são carregados no MySQL utilizando SQLAlchemy e Pandas:

```python
df.to_sql(
    nome,
    con=engine,
    if_exists="append",
    index=False
)
```

Fluxo de carregamento:

```text
Python
   ↓
SQLAlchemy
   ↓
MySQL
```

---

## 🐍 Python

O pipeline foi dividido em funções para cada etapa do processo.

### Extração

```python
extrair_dados()
```

Responsável pela leitura das cinco planilhas Excel.

### Transformação

```python
transformar_clientes()
transformar_vendedores()
transformar_produtos()
transformar_pedidos()
transformar_itens_pedido()
```

Cada função realiza o tratamento específico da respectiva tabela.

### Carga

```python
carregar_dados()
```

Responsável pelo carregamento dos dados tratados no MySQL.

### Execução do pipeline

```python
main()
```

Responsável por executar todo o fluxo ETL.

---

## 📈 Análise SQL

Após o carregamento dos dados no MySQL, foram desenvolvidas consultas SQL para análise dos dados.

Entre os indicadores analisados estão:

* Churn Rate
* Classificação de clientes
* Clientes inativos
* Crescimento percentual
* Faturamento por categoria
* Faturamento mensal
* Faturamento por vendedor
* Percentual de participação
* Ranking de vendedores
* Relatório de clientes
* Taxa de cancelamento
* Ticket médio
* Top 5 clientes
* Top 5 produtos
* Produto mais vendido
* Vendedor com maior faturamento

As consultas utilizam recursos como:

* `JOIN`
* `GROUP BY`
* `CASE`
* `CTE`
* `LAG()`
* `LEAD()`
* `FIRST_VALUE()`
* `LAST_VALUE()`
* `DENSE_RANK()`
* Funções de agregação
* Funções de janela

---

## 📊 Dashboard Power BI

Os dados tratados e analisados foram utilizados para construir um dashboard no Power BI.

O dashboard apresenta indicadores relacionados a:

## 📊 Dashboard Power BI

O dashboard apresenta indicadores e análises relacionados a:

- Faturamento
- Total de pedidos
- Ticket médio
- Faturamento por categoria
- Evolução do faturamento
- Desempenho comercial

O objetivo é transformar os dados processados pelo pipeline em informações úteis para análise e tomada de decisão.

---

## 🎯 Objetivo do projeto

O objetivo deste projeto é demonstrar, de ponta a ponta, um fluxo de dados utilizando ferramentas presentes em um cenário de Data Analytics:

```text
Dados brutos
     ↓
Extração
     ↓
Transformação
     ↓
Validação
     ↓
Banco de dados
     ↓
Análise SQL
     ↓
Dashboard
     ↓
Informação para tomada de decisão
```

O projeto demonstra conhecimentos práticos em:

* ETL
* Python
* Pandas
* SQL
* MySQL
* Power BI
* Tratamento e validação de dados
* Análise de KPIs

---

## 👨‍💻 Autor

**Silas Barbosa da Silva**

Data Analytics | SQL | Python | Power BI | ETL

* 💻 **GitHub:** [SilasBarbosa44](https://github.com/SilasBarbosa44)
* 💼 **LinkedIn:** [Silas Barbosa](https://www.linkedin.com/in/silas-barbosa-1885ab3a0/)
