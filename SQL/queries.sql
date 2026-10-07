CREATE VIEW vw_churn_rate AS
WITH clientes AS (
    SELECT
        c.nome AS cliente,
        DATEDIFF(CURDATE(), MAX(p.data_pedido)) AS diferencas_dias
    FROM clientes c
    INNER JOIN pedidos p
        ON c.id_cliente = p.id_cliente
    GROUP BY c.nome, c.id_cliente
)
SELECT
    cliente,
    diferencas_dias,
    ROUND(
        SUM(
            CASE
                WHEN diferencas_dias >= 90 THEN 1
                ELSE 0
            END
        ) over() / COUNT(*) over() * 100,
        2
    ) AS churn_rate
FROM clientes;


CREATE VIEW vw_classificacao_clientes AS
SELECT
    c.nome AS cliente,
    SUM(i.quantidade * i.preco_unitario) AS faturamento,
    CASE
        WHEN SUM(i.quantidade * i.preco_unitario) >= 7000 THEN 'Alto'
        WHEN SUM(i.quantidade * i.preco_unitario) >= 5000 THEN 'Médio'
        ELSE 'Baixo'
    END AS classificacao
FROM clientes c
INNER JOIN pedidos p
    ON c.id_cliente = p.id_cliente
INNER JOIN itens_pedido i
    ON i.id_pedido = p.id_pedido
GROUP BY c.nome;


CREATE VIEW vw_clientes_inativos AS
SELECT
    c.nome AS cliente,
    MAX(p.data_pedido) AS ultima_compra,
    DATEDIFF(CURDATE(), MAX(p.data_pedido)) AS dias_inativo
FROM clientes c
INNER JOIN pedidos p
    ON c.id_cliente = p.id_cliente
GROUP BY c.nome
HAVING max(p.data_pedido) < date_sub(curdate(), interval 90 day);


CREATE VIEW vw_crescimento_percentual AS
WITH faturamento_mensal AS (
    SELECT
        c.nome AS cliente,
        MONTH(p.data_pedido) AS mes,
        YEAR(p.data_pedido) AS ano,
        SUM(i.quantidade * i.preco_unitario) AS faturamento
    FROM clientes c
    INNER JOIN pedidos p
        ON c.id_cliente = p.id_cliente
    INNER JOIN itens_pedido i
        ON i.id_pedido = p.id_pedido
    GROUP BY
        c.nome,
        MONTH(p.id_pedido),
        YEAR(p.id_pedido)
),
crescimento AS (
    SELECT
        *,
        LAG(faturamento) OVER (
            ORDER BY ano, mes
        ) AS faturamento_anterior
    FROM faturamento_mensal
)
SELECT
    cliente,
    mes,
    ano,
    faturamento,
    faturamento_anterior,
    ROUND(
        (faturamento - faturamento_anterior)
        / NULLIF(faturamento_anterior, 0) * 100,
        2
    ) AS crescimento_percentual
FROM crescimento;


CREATE VIEW vw_faturamento_categoria AS
SELECT
    pr.categoria,
    SUM(i.quantidade * i.preco_unitario) AS faturamento
FROM produtos pr
INNER JOIN itens_pedido i
    ON pr.id_produto = i.id_produto
GROUP BY pr.categoria;


CREATE VIEW vw_faturamento_mensal AS
SELECT
    MONTH(p.data_pedido) AS mes,
    YEAR(p.data_pedido) AS ano,
    SUM(i.quantidade * i.preco_unitario) AS faturamento
FROM pedidos p
INNER JOIN itens_pedido i
    ON p.id_pedido = i.id_pedido
GROUP BY
    MONTH(p.data_pedido),
    YEAR(p.data_pedido);


CREATE VIEW vw_faturamento_vendedor AS
SELECT
    v.nome AS vendedor,
    SUM(i.quantidade * i.preco_unitario) AS faturamento
FROM vendedores v
INNER JOIN pedidos p
    ON v.id_vendedor = p.id_vendedor
INNER JOIN itens_pedido i
    ON i.id_pedido = p.id_pedido
GROUP BY v.nome;


CREATE VIEW vw_percentual_participacao AS
SELECT
    c.nome AS cliente,
    SUM(i.quantidade * i.preco_unitario) AS faturamento,
    ROUND(
        SUM(i.quantidade * i.preco_unitario)
        / (
            SELECT SUM(i2.quantidade * i2.preco_unitario)
            FROM itens_pedido i2
        ) * 100,
        2
    ) AS percentual_partitipacao
FROM clientes c
INNER JOIN pedidos p
    ON c.id_cliente = p.id_cliente
INNER JOIN itens_pedido i
    ON i.id_pedido = p.id_pedido
GROUP BY c.nome;


CREATE VIEW vw_ranking_vendedores AS
SELECT
    v.nome AS vendedor,
    SUM(i.quantidade * i.preco_unitario) AS faturamento,
    DENSE_RANK() OVER (
        ORDER BY SUM(i.quantidade * i.preco_unitario) DESC
    ) AS ranking
FROM vendedores v
INNER JOIN pedidos p
    ON v.id_vendedor = p.id_vendedor
INNER JOIN itens_pedido i
    ON i.id_pedido = p.id_pedido
GROUP BY v.nome;


CREATE VIEW vw_relatorio_clientes AS
WITH relatorio_clientes AS (
    SELECT
        c.nome AS cliente,
        c.email AS email,
        c.cidade AS cidade,
        COUNT(DISTINCT c.id_cliente) AS total_clientes,
        MONTH(p.data_pedido) AS mes,
        YEAR(p.data_pedido) AS ano,
        SUM(i.quantidade * i.preco_unitario) AS faturamento,
        datediff(CURDATE(), MAX(p.data_pedido)) AS diferencas_dias
    FROM clientes c
    INNER JOIN pedidos p
        ON c.id_cliente = p.id_cliente
    INNER JOIN itens_pedido i
        ON i.id_pedido = p.id_pedido
    GROUP BY
        c.nome,
        c.id_cliente,
        c.email,
        c.cidade,
        MONTH(p.data_pedido),
        YEAR(p.data_pedido)
),
ranking AS (
    SELECT
        relatorio_clientes.*,
        DENSE_RANK() OVER (
            ORDER BY faturamento DESC
        ) AS ranking
    FROM relatorio_clientes
),
faturamento_anterior AS (
    SELECT
        ranking.*,
        LAG(faturamento) OVER (
            ORDER BY ano, mes
        ) AS faturamento_anterior
    FROM ranking
),
crescimento_percentual AS (
    SELECT
        faturamento_anterior.*,
        ROUND(
            (faturamento - faturamento_anterior)
            / NULLIF(faturamento_anterior, 0) * 100,
            2
        ) AS crescimento_percentual
    FROM faturamento_anterior
),
proximo_faturamento AS (
    SELECT
        crescimento_percentual.*,
        LEAD(faturamento, 1) OVER (
            ORDER BY ano, mes
        ) AS proximo_faturamento
    FROM crescimento_percentual
),
primeiro_faturamento AS (
    SELECT
        proximo_faturamento.*,
        FIRST_VALUE(faturamento) OVER (
            ORDER BY ano, mes  ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
        ) AS primeiro_faturamento
    FROM proximo_faturamento
),
percentual_participacao AS (
    SELECT
        primeiro_faturamento.*,
        ROUND(
            faturamento
            / SUM(faturamento) OVER () * 100,
            2
        ) AS percentual_participacao
    FROM primeiro_faturamento
),
ultimo_faturamento AS (
    SELECT
        percentual_participacao.*,
        LAST_VALUE(faturamento) OVER (
            ORDER BY ano, mes
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
        ) AS ultimo_faturamento
    FROM percentual_participacao
),
clientes_inativos AS (
    SELECT
        ultimo_faturamento.*,
        CASE
            WHEN diferencas_dias >= 90 THEN 'Inativo'
            ELSE 'Ativo'
        END AS status_cliente
    FROM ultimo_faturamento
)
SELECT *
FROM clientes_inativos;


CREATE VIEW vw_taxa_cancelamento AS
SELECT
    ROUND(
        SUM(
            CASE
                WHEN p.status = 'Cancelado' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS taxa_cancelamento
FROM pedidos p;


CREATE VIEW vw_ticket_medio AS
SELECT
    ROUND(
        SUM(i.quantidade * i.preco_unitario)
        / COUNT(DISTINCT p.id_pedido),
        2
    ) AS ticket_medio
FROM pedidos p
INNER JOIN itens_pedido i
    ON p.id_pedido = i.id_pedido;


CREATE VIEW vw_top_5_clientes AS
SELECT
    c.nome AS cliente,
    SUM(i.quantidade * i.preco_unitario) AS faturamento
FROM clientes c
INNER JOIN pedidos p
    ON c.id_cliente = p.id_cliente
INNER JOIN itens_pedido i
    ON i.id_pedido = p.id_pedido
GROUP BY c.nome
ORDER BY faturamento DESC
LIMIT 5;


CREATE VIEW vw_top_5_produtos AS
SELECT
    pr.nome_produto AS produto,
    SUM(i.quantidade) AS quantidade_vendida,
    SUM(i.quantidade * i.preco_unitario) AS faturamento
FROM produtos pr
INNER JOIN itens_pedido i
    ON pr.id_produto = i.id_produto
GROUP BY pr.nome_produto
ORDER BY quantidade_vendida DESC
LIMIT 5;


CREATE VIEW vw_top_produto AS
SELECT
    pr.nome_produto AS produto,
    SUM(i.quantidade) AS quantidade_vendida,
    SUM(i.quantidade * i.preco_unitario) AS faturamento,
    DENSE_RANK() OVER (
        ORDER BY SUM(i.quantidade) ASC
    ) AS ranking
FROM produtos pr
INNER JOIN itens_pedido i
    ON pr.id_produto = i.id_produto
GROUP BY pr.nome_produto
ORDER BY ranking 
limit 1;


CREATE VIEW vw_top_vendedor AS
SELECT
    v.nome AS vendedor,
    SUM(i.quantidade * i.preco_unitario) AS faturamento,
    DENSE_RANK() OVER (
        ORDER BY SUM(i.quantidade * i.preco_unitario) DESC
    ) AS ranking
FROM vendedores v
INNER JOIN pedidos p
    ON v.id_vendedor = p.id_vendedor
INNER JOIN itens_pedido i
    ON i.id_pedido = p.id_pedido
GROUP BY v.nome
ORDER BY ranking
LIMIT 1;