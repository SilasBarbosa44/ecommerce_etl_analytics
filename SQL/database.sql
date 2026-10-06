CREATE DATABASE ETL_ecommerce_analytics;
USE ETL_ecommerce_analytics;

CREATE TABLE clientes (
    id_cliente INT NOT NULL,
    nome VARCHAR(100) DEFAULT NULL,
    email VARCHAR(150) DEFAULT NULL,
    cidade VARCHAR(100) DEFAULT NULL,
    estado VARCHAR(2) DEFAULT NULL,
    data_cadastro DATE DEFAULT NULL,
    PRIMARY KEY (id_cliente)
);

CREATE TABLE produtos (
    id_produto INT NOT NULL,
    nome_produto VARCHAR(100) DEFAULT NULL,
    categoria VARCHAR(50) DEFAULT NULL,
    preco DECIMAL(10,2) DEFAULT NULL,
    custo DECIMAL(10,2) DEFAULT NULL,
    estoque INT DEFAULT NULL,
    PRIMARY KEY (id_produto)
);

CREATE TABLE vendedores (
    id_vendedor INT NOT NULL,
    nome VARCHAR(100) DEFAULT NULL,
    departamento VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (id_vendedor)
);

CREATE TABLE pedidos (
    id_pedido INT NOT NULL,
    id_cliente INT DEFAULT NULL,
    id_vendedor INT DEFAULT NULL,
    data_pedido DATE DEFAULT NULL,
    status VARCHAR(30) DEFAULT NULL,
    PRIMARY KEY (id_pedido),
    KEY id_cliente (id_cliente),
    KEY id_vendedor (id_vendedor),
    CONSTRAINT pedidos_ibfk_1
        FOREIGN KEY (id_cliente)
        REFERENCES clientes (id_cliente),
    CONSTRAINT pedidos_ibfk_2
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedores (id_vendedor)
);

CREATE TABLE itens_pedido (
    id_item INT NOT NULL,
    id_pedido INT DEFAULT NULL,
    id_produto INT DEFAULT NULL,
    quantidade INT DEFAULT NULL,
    preco_unitario DECIMAL(10,2) DEFAULT NULL,
    PRIMARY KEY (id_item),
    KEY id_pedido (id_pedido),
    KEY id_produto (id_produto),
    CONSTRAINT itens_pedido_ibfk_1
        FOREIGN KEY (id_pedido)
        REFERENCES pedidos (id_pedido),
    CONSTRAINT itens_pedido_ibfk_2
        FOREIGN KEY (id_produto)
        REFERENCES produtos (id_produto)
);