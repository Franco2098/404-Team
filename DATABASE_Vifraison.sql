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