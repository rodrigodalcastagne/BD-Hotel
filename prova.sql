CREATE DATABASE hospedar_db; 
USE hospedar_db;

CREATE TABLE Hotel (
    hotel_id INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cidade VARCHAR(255) NOT NULL,
    ratting INT NOT NULL CHECK (ratting >= 1 AND ratting <= 5)
);

CREATE TABLE Quarto (
    quarto_id INT PRIMARY KEY,
    hotel_id INT NOT NULL,
    número INT NOT NULL,
    tipo VARCHAR(255) NOT NULL,
    preco_diaria DECIMAL NOT NULL,
    FOREIGN KEY (hotel_id) REFERENCES Hotel(hotel_id)
);

CREATE TABLE Cliente (
    cliente_id INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefone VARCHAR(255) NOT NULL,
    cpf VARCHAR(255) NOT NULL UNIQUE
);
CREATE TABLE Hospedagem ( 
    hospedagem_id INT PRIMARY KEY, 
    cliente_id INT NOT NULL, 
    quarto_id INT NOT NULL, 
    data_checkin DATE NOT NULL, 
    data_checkout DATE NOT NULL, 
    valor_total FLOAT NOT NULL, 
    status VARCHAR(255) NOT NULL CHECK (status IN ('reserva', 'finalizada', 'hospedado', 'cancelada')), 
    FOREIGN KEY (cliente_id) REFERENCES Cliente(cliente_id), 
    FOREIGN KEY (quarto_id) REFERENCES Quarto(quarto_id) 
);

INSERT INTO Hotel (hotel_id, nome, cidade, ratting) VALUES 
(1, 'Hotel A', 'Cidade X', 4), 
(2, 'Hotel B', 'Cidade Y', 5);

INSERT INTO Quarto (quarto_id, hotel_id, numero, tipo, preco_diaria) VALUES 
(1, 1, 101, 'Standard', 100.0), 
(2, 1, 102, 'Deluxe', 200.0), 
(3, 1, 103, 'Suíte', 300.0), 
(4, 2, 201, 'Standard', 150.0), 
(5, 2, 202, 'Deluxe', 250.0);

INSERT INTO Cliente (cliente_id, nome, email, telefone, cpf) VALUES 
(1, 'Cliente A', 'clienteA@email.com', '1234567890', '11122233344'), 
(2, 'Cliente B', 'clienteB@email.com', '0987654321', '55566677788'), 
(3, 'Cliente C', 'clienteC@email.com', '1122334455', '99988877766'); 
 
INSERT INTO Hospedagem (hospedagem_id, cliente_id, quarto_id, data_checkin, data_checkout, valor_total, status) VALUES 
(1, 1, 1, '2023-01-01', '2023-01-02', 100.0, 'reserva'), 
(2, 1, 2, '2023-01-03', '2023-01-04', 200.0, 'reserva'), 
(3, 2, 3, '2023-01-05', '2023-01-06', 300.0, 'finalizada'), 
(4, 2, 4, '2023-01-07', '2023-01-08', 150.0, 'finalizada'), 
(5, 3, 5, '2023-01-09', '2023-01-10', 250.0, 'hospedado');

SELECT Hotel.nome, Hotel.cidade, Quarto.tipo, Quarto.preco_diaria 
FROM Hotel 
JOIN Quarto ON Hotel.hotel_id = Quarto.hotel_id;

ALTER DATABASE hospedar_db RENAME TO hospeda_mais;

SELECT Cliente.nome, Quarto.quarto_id, Hotel.nome 
FROM Hospedagem 
JOIN Cliente ON Hospedagem.cliente_id = Cliente.cliente_id 
JOIN Quarto ON Hospedagem.quarto_id = Quarto.quarto_id 
JOIN Hotel ON Quarto.hotel_id = Hotel.hotel_id 
WHERE Hospedagem.status = 'finalizada';

SELECT * 
FROM Hospedagem 
WHERE cliente_id = <id_do_cliente> 
ORDER BY data_checkin;

SELECT cliente_id, COUNT(*) as num_hospedagens 
FROM Hospedagem 
GROUP BY cliente_id 
ORDER BY num_hospedagens DESC 
LIMIT 1;

SELECT Cliente.nome, Quarto.quarto_id, Hotel.nome 
FROM Hospedagem 
JOIN Cliente ON Hospedagem.cliente_id = Cliente.cliente_id 
JOIN Quarto ON Hospedagem.quarto_id = Quarto.quarto_id 
JOIN Hotel ON Quarto.hotel_id = Hotel.hotel_id 
WHERE Hospedagem.status = 'cancelada';

SELECT Hotel.nome, SUM(Hospedagem.valor_total) as receita 
FROM Hospedagem 
JOIN Quarto ON Hospedagem.quarto_id = Quarto.quarto_id 
JOIN Hotel ON Quarto.hotel_id = Hotel.hotel_id 
WHERE Hospedagem.status = 'finalizada' 
GROUP BY Hotel.nome 
ORDER BY receita DESC;

SELECT Cliente.nome 
FROM Hospedagem 
JOIN Cliente ON Hospedagem.cliente_id = Cliente.cliente_id 
JOIN Quarto ON Hospedagem.quarto_id = Quarto.quarto_id 
WHERE Quarto.hotel_id = <id_do_hotel>;

SELECT Cliente.nome, SUM(Hospedagem.valor_total) as total_gasto 
FROM Hospedagem 
JOIN Cliente ON Hospedagem.cliente_id = Cliente.cliente_id 
WHERE Hospedagem.status = 'finalizada' 
GROUP BY Cliente.nome 
ORDER BY total_gasto DESC;


SELECT quarto_id 
FROM Quarto 
WHERE quarto_id NOT IN (SELECT DISTINCT quarto_id FROM Hospedagem);

SELECT Hotel.nome, Quarto.tipo, AVG(Quarto.preco_diaria) as media_preco 
FROM Quarto 
JOIN Hotel ON Quarto.hotel_id = Hotel.hotel_id 
GROUP BY Hotel.nome, Quarto.tipo;

DELETE FROM Hospedagem WHERE status = 'cancelada';

ALTER TABLE Hospedagem ADD COLUMN checkin_realizado BOOLEAN; 
UPDATE Hospedagem SET checkin_realizado = TRUE WHERE status IN ('finalizada', 'hospedado'); 
UPDATE Hospedagem SET checkin_realizado = FALSE WHERE status IN ('reserva', 'cancelada');

ALTER TABLE Hotel CHANGE COLUMN ratting classificacao INT; 
 
 CREATE VIEW ReservasFuturas AS 
SELECT Cliente.*, Quarto.*, Hotel.* 
FROM Hospedagem 
JOIN Cliente ON Hospedagem.cliente_id = Cliente.cliente_id 
JOIN Quarto ON Hospedagem.quarto_id = Quarto.quarto_id 
JOIN Hotel ON Quarto.hotel_id = Hotel.hotel_id 
WHERE Hospedagem.status = 'reserva' AND Hospedagem.data_checkin >= NOW() 
ORDER BY Hospedagem.data_checkin;