DROP DATABASE IF EXISTS Vifraison;
CREATE DATABASE Vifraison;
USE Vifraison;

-- ============================
-- TABLAS
-- ============================

CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono BIGINT NOT NULL,
    numero_ss BIGINT NOT NULL UNIQUE,
    estado VARCHAR(50) NOT NULL
);

CREATE TABLE Login (
    id_usuario INT,
    contraseña VARCHAR(20) NOT NULL,
    FOREIGN KEY(id_usuario) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Horario (
    fecha DATE NOT NULL,
    entrada TIME NOT NULL,
    salida TIME NOT NULL
);

CREATE TABLE Recompensas (
    id_recompensa INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(255) NOT NULL,
    puntos_requeridos INT NOT NULL
);

CREATE TABLE Mapa (
    id_usuario INT,
    direccion VARCHAR(255) NOT NULL,
    FOREIGN KEY(id_usuario) REFERENCES Usuarios(id_usuario)
);

-- ============================
-- PROCEDIMIENTOS ALMACENADOS
-- ============================

DELIMITER $$

-- ALTA Usuarios
CREATE PROCEDURE sp_alta_usuario(
    IN p_nombre VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_telefono BIGINT,
    IN p_numero_ss BIGINT,
    IN p_estado VARCHAR(50)
)
BEGIN
    IF p_nombre = '' OR p_email = '' OR p_estado = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre, email y estado son obligatorios';
    END IF;

    IF EXISTS (SELECT 1 FROM Usuarios WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El email ya existe';
    END IF;

    IF EXISTS (SELECT 1 FROM Usuarios WHERE numero_ss = p_numero_ss) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de seguro social ya existe';
    END IF;

    INSERT INTO Usuarios (nombre, email, telefono, numero_ss, estado)
    VALUES (p_nombre, p_email, p_telefono, p_numero_ss, p_estado);
END$$

-- BAJA usuario (Lógico)
CREATE PROCEDURE sp_baja_usuario(
    IN p_id_usuario INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;

    UPDATE Usuarios SET estado = 'INACTIVO' WHERE id_usuario = p_id_usuario;
END$$

-- MODIFICACIÓN usuarios
CREATE PROCEDURE sp_modificar_usuario(
    IN p_id_usuario INT,
    IN p_nombre VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_telefono BIGINT,
    IN p_estado VARCHAR(50)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no encontrado';
    END IF;

    IF EXISTS (SELECT 1 FROM Usuarios WHERE email = p_email AND id_usuario <> p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El email ya está en uso por otro usuario';
    END IF;

    UPDATE Usuarios
    SET nombre = p_nombre, email = p_email, telefono = p_telefono, estado = p_estado
    WHERE id_usuario = p_id_usuario;
END$$

-- CONSULTAS Usuarios
CREATE PROCEDURE sp_consultar_usuario(IN p_id_usuario INT)
BEGIN
    SELECT * FROM Usuarios WHERE id_usuario = p_id_usuario;
END$$

CREATE PROCEDURE sp_listar_usuarios_activos()
BEGIN
    SELECT * FROM Usuarios WHERE estado = 'ACTIVO';
END$$

-- RECOMPENSAS
CREATE PROCEDURE sp_alta_recompensa(IN p_descripcion VARCHAR(255), IN p_puntos INT)
BEGIN
    IF p_puntos <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los puntos deben ser mayores a cero';
    END IF;
    INSERT INTO Recompensas (descripcion, puntos_requeridos) VALUES (p_descripcion, p_puntos);
END$$

CREATE PROCEDURE sp_listar_recompensas()
BEGIN
    SELECT * FROM Recompensas;
END$$

-- LOGIN
CREATE PROCEDURE sp_alta_login(IN p_id_usuario INT, IN p_contrasena VARCHAR(20))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;
    IF EXISTS (SELECT 1 FROM Login WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario ya tiene un login';
    END IF;
    IF LENGTH(p_contrasena) < 6 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña debe tener al menos 6 caracteres';
    END IF;
    INSERT INTO Login (id_usuario, contraseña) VALUES (p_id_usuario, p_contrasena);
END$$

CREATE PROCEDURE sp_modificar_login(IN p_id_usuario INT, IN p_contrasena VARCHAR(20))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Login WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Login no encontrado';
    END IF;
    UPDATE Login SET contraseña = p_contrasena WHERE id_usuario = p_id_usuario;
END$$

CREATE PROCEDURE sp_baja_login(IN p_id_usuario INT)
BEGIN
    DELETE FROM Login WHERE id_usuario = p_id_usuario;
END$$

CREATE PROCEDURE sp_consultar_login(IN p_id_usuario INT)
BEGIN
    SELECT id_usuario FROM Login WHERE id_usuario = p_id_usuario;
END$$

-- HORARIO
CREATE PROCEDURE sp_alta_horario(IN p_fecha DATE, IN p_entrada TIME, IN p_salida TIME)
BEGIN
    IF p_entrada >= p_salida THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La hora de entrada debe ser menor que la de salida';
    END IF;
    INSERT INTO Horario (fecha, entrada, salida) VALUES (p_fecha, p_entrada, p_salida);
END$$

CREATE PROCEDURE sp_modificar_horario(IN p_fecha DATE, IN p_entrada TIME, IN p_salida TIME)
BEGIN
    UPDATE Horario SET entrada = p_entrada, salida = p_salida WHERE fecha = p_fecha;
END$$

CREATE PROCEDURE sp_baja_horario(IN p_fecha DATE)
BEGIN
    DELETE FROM Horario WHERE fecha = p_fecha;
END$$

CREATE PROCEDURE sp_consultar_horario(IN p_fecha DATE)
BEGIN
    SELECT * FROM Horario WHERE fecha = p_fecha;
END$$

-- MAPA
CREATE PROCEDURE sp_alta_mapa(IN p_id_usuario INT, IN p_direccion VARCHAR(255))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no existe';
    END IF;
    INSERT INTO Mapa (id_usuario, direccion) VALUES (p_id_usuario, p_direccion);
END$$

CREATE PROCEDURE sp_modificar_mapa(IN p_id_usuario INT, IN p_direccion VARCHAR(255))
BEGIN
    UPDATE Mapa SET direccion = p_direccion WHERE id_usuario = p_id_usuario;
END$$

CREATE PROCEDURE sp_baja_mapa(IN p_id_usuario INT)
BEGIN
    DELETE FROM Mapa WHERE id_usuario = p_id_usuario;
END$$

CREATE PROCEDURE sp_consultar_mapa(IN p_id_usuario INT)
BEGIN
    SELECT * FROM Mapa WHERE id_usuario = p_id_usuario;
END$$

DELIMITER ;

-- ============================
-- PRUEBAS DE INSERCIÓN (CALLS)
-- ============================

CALL sp_alta_usuario('Pedro Lopez','pedro@mail.com',111222333,555111000,'ACTIVO');
CALL sp_alta_usuario('Ana Torres','ana@mail.com',222333444,555111001,'ACTIVO');
CALL sp_alta_usuario('Luis Diaz','luis@mail.com',333444555,555111002,'ACTIVO');
CALL sp_alta_usuario('Sofia Ruiz','sofia@mail.com',444555666,555111003,'ACTIVO');
CALL sp_alta_usuario('Mario Cano','mario@mail.com',555666777,555111004,'ACTIVO');
CALL sp_alta_usuario('Oscar Gonzalez','gonzalez@empresa.com',244454425,555111005,'ACTIVO');

CALL sp_alta_login(1,'clave123');
CALL sp_alta_login(2,'password456');
CALL sp_alta_login(3,'login789');

CALL sp_alta_horario('2024-02-01','08:00:00','17:00:00');
CALL sp_alta_mapa(1, 'Calle Falsa 123');