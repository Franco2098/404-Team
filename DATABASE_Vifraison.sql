DROP DATABASE IF EXIST Vifraison;
CREATE DATABASE Vifraison;
USE Vifraison;

CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono INT NOT NULL,
    numero_ss INT NOT NULL UNIQUE,
    estado VARCHAR(50) NOT NULL,
);
CREATE TABLE Login (
    id_usuario INT,
    contraseña VARCHAR(20) NOT NULL,
    FOREIGN KEY(id_usuario) REFERENCES Usuarios(id_usuario)
);
CREATE TABLE Horario (
    fecha DATE NOT NULL,
    entrada TIME NOT NULL
    salida TIME NOT NULL,
);
CREATE TABLE Recompensas (
    id_recompensa INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(255) NOT NULL,
    puntos_requeridos INT NOT NULL
);
CREATE TABLE Mapa (
    id_usuario INT,
    direccion 
    FOREIGN KEY(id_usuario) REFERENCES Usuarios(id_usuario)
);

INSERT INTO Usuarios (nombre, email, telefono, numero_ss) VALUES
('Juan Perez', 'juan.perez@example.com', 123456789, 987654321),
('Maria Gomez','maria.gomez@example.com', 987654321, 123456789),
('Yeison Benito','yeison.benito@example.com', 555555555, 111111111),
('Nicolas Maduro','nicolas.maduro@example.com', 111111111, 222222222),
('DONALD TRUMP','donald.trump@example.com', 999999999, 333333333);
('Carlos Valverde','carlos.valverde@example.com', 777777777, 444444444);
INSERT INTO Login (id_usuario,contraseña) VALUES
(1, 'password123'),
(2, 'securepass456'),
(3, 'mypassword789'),
(4, 'adminpass101'),
(5, 'trumppass202');
(6, 'francoockingtoday');
INSERT INTO Horario (fecha, entrada, salida) VALUES
('2024-01-01', '08:00:00', '17:00:00'),
('2024-01-02', '09:00:00', '18:00:00'),
('2024-01-03', '07:30:00', '16:30:00'),
('2024-01-04', '10:00:00', '19:00:00'),
('2024-01-05', '08:30:00', '17:30:00');
('2024-01-06', '09:30:00', '18:30:00');
INSERT INTO Recompensas (descripcion, puntos_requeridos) VALUES
('Descuento del 30% en la cafeteria de la empresa', 100),
('tarjeta de regalo de $50 para tiendas en linea', 200),
('entrada para eventos deportivos',300),
('entradas al cine', 99);
INSERT INTO Mapa (id_usuario, direccion) VALUES
(1, 'Calle Falsa 123, Ciudad, Pais'),
(2, 'Avenida Siempre Viva 742, Ciudad, Pais'),
(3, 'Boulevard de los Sueños Rotos 456, Ciudad, Pais'),
(4, 'Plaza Mayor 789, Ciudad, Pais'),
(5, 'Calle del Sol 101, Ciudad, Pais');
(6, 'Camino Real 202, Ciudad, Pais');