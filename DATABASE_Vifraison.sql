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


-- ALTA Usuarios
DELIMITER $$

CREATE PROCEDURE sp_alta_usuario(
    IN p_nombre VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_telefono INT,
    IN p_numero_ss INT,
    IN p_estado VARCHAR(50)
)
BEGIN
    -- Validación de campos obligatorios
    IF p_nombre = '' OR p_email = '' OR p_estado = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nombre, email y estado son obligatorios';
    END IF;

    -- Validar email único
    IF EXISTS (SELECT 1 FROM Usuarios WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El email ya existe';
    END IF;

    -- Validar número SS único
    IF EXISTS (SELECT 1 FROM Usuarios WHERE numero_ss = p_numero_ss) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El número de seguro social ya existe';
    END IF;

    INSERT INTO Usuarios (nombre, email, telefono, numero_ss, estado)
    VALUES (p_nombre, p_email, p_telefono, p_numero_ss, p_estado);
END$$

DELIMITER ;

-- BAJA usuario
DELIMITER $$

CREATE PROCEDURE sp_baja_usuario(
    IN p_id_usuario INT
)
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;

    UPDATE Usuarios
    SET estado = 'INACTIVO'
    WHERE id_usuario = p_id_usuario;
END$$

DELIMITER ;

-- MODIFICACIÓN usuarios

DELIMITER $$

CREATE PROCEDURE sp_modificar_usuario(
    IN p_id_usuario INT,
    IN p_nombre VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_telefono INT,
    IN p_estado VARCHAR(50)
)
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario no encontrado';
    END IF;

    -- Validar email único
    IF EXISTS (
        SELECT 1 FROM Usuarios 
        WHERE email = p_email AND id_usuario <> p_id_usuario
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El email ya está en uso por otro usuario';
    END IF;

    UPDATE Usuarios
    SET nombre = p_nombre,
        email = p_email,
        telefono = p_telefono,
        estado = p_estado
    WHERE id_usuario = p_id_usuario;
END$$

DELIMITER ;

-- CONSULTA por ID

DELIMITER $$

CREATE PROCEDURE sp_consultar_usuario(
    IN p_id_usuario INT
)
BEGIN
    SELECT * 
    FROM Usuarios
    WHERE id_usuario = p_id_usuario;
END$$

DELIMITER ;

-- CONSULTA Activos

DELIMITER $$

CREATE PROCEDURE sp_listar_usuarios_activos()
BEGIN
    SELECT *
    FROM Usuarios
    WHERE estado = 'ACTIVO';
END$$

DELIMITER ;

-- ALTA recompensas

DELIMITER $$

CREATE PROCEDURE sp_alta_recompensa(
    IN p_descripcion VARCHAR(255),
    IN p_puntos INT
)
BEGIN
    IF p_puntos <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Los puntos deben ser mayores a cero';
    END IF;

    INSERT INTO Recompensas (descripcion, puntos_requeridos)
    VALUES (p_descripcion, p_puntos);
END$$

DELIMITER ;

-- CONSULTA recompensas

DELIMITER $$

CREATE PROCEDURE sp_listar_recompensas()
BEGIN
    SELECT * FROM Recompensas;
END$$

DELIMITER ;

--ALTA login
DELIMITER $$

CREATE PROCEDURE sp_alta_login(
    IN p_id_usuario INT,
    IN p_contrasena VARCHAR(20)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;

    IF EXISTS (SELECT 1 FROM Login WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario ya tiene un login';
    END IF;

    IF LENGTH(p_contrasena) < 6 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La contraseña debe tener al menos 6 caracteres';
    END IF;

    INSERT INTO Login (id_usuario, contraseña)
    VALUES (p_id_usuario, p_contrasena);
END$$

DELIMITER ;

-- MODIFICAR login

DELIMITER $$

CREATE PROCEDURE sp_modificar_login(
    IN p_id_usuario INT,
    IN p_contrasena VARCHAR(20)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Login WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Login no encontrado';
    END IF;

    IF LENGTH(p_contrasena) < 6 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La contraseña es demasiado corta';
    END IF;

    UPDATE Login
    SET contraseña = p_contrasena
    WHERE id_usuario = p_id_usuario;
END$$

DELIMITER ;

-- BAJA login

DELIMITER $$

CREATE PROCEDURE sp_baja_login(
    IN p_id_usuario INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Login WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Login no existe';
    END IF;

    DELETE FROM Login WHERE id_usuario = p_id_usuario;
END$$

DELIMITER ;

-- CONSULTA login

DELIMITER $$

CREATE PROCEDURE sp_consultar_login(
    IN p_id_usuario INT
)
BEGIN
    SELECT id_usuario
    FROM Login
    WHERE id_usuario = p_id_usuario;
END$$

DELIMITER ;

-- ALTA horario

DELIMITER $$

CREATE PROCEDURE sp_alta_horario(
    IN p_fecha DATE,
    IN p_entrada TIME,
    IN p_salida TIME
)
BEGIN
    IF p_entrada >= p_salida THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La hora de entrada debe ser menor que la de salida';
    END IF;

    IF EXISTS (SELECT 1 FROM Horario WHERE fecha = p_fecha) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un horario para esa fecha';
    END IF;

    INSERT INTO Horario (fecha, entrada, salida)
    VALUES (p_fecha, p_entrada, p_salida);
END$$

DELIMITER ;

-- MODIFICAR horario

DELIMITER $$

CREATE PROCEDURE sp_modificar_horario(
    IN p_fecha DATE,
    IN p_entrada TIME,
    IN p_salida TIME
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Horario WHERE fecha = p_fecha) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Horario no encontrado';
    END IF;

    IF p_entrada >= p_salida THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Horario inválido';
    END IF;

    UPDATE Horario
    SET entrada = p_entrada,
        salida = p_salida
    WHERE fecha = p_fecha;
END$$

DELIMITER ;

-- BAJA usuario

DELIMITER $$

CREATE PROCEDURE sp_baja_horario(
    IN p_fecha DATE
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Horario WHERE fecha = p_fecha) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existe horario para esa fecha';
    END IF;

    DELETE FROM Horario WHERE fecha = p_fecha;
END$$

DELIMITER ;

-- CONSULTAR horario

DELIMITER $$

CREATE PROCEDURE sp_consultar_horario(
    IN p_fecha DATE
)
BEGIN
    SELECT * FROM Horario WHERE fecha = p_fecha;
END$$

DELIMITER ;

-- ALTA mapa

DELIMITER $$

CREATE PROCEDURE sp_alta_mapa(
    IN p_id_usuario INT,
    IN p_direccion VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario no existe';
    END IF;

    IF EXISTS (SELECT 1 FROM Mapa WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario ya tiene dirección registrada';
    END IF;

    IF p_direccion = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La dirección no puede estar vacía';
    END IF;

    INSERT INTO Mapa (id_usuario, direccion)
    VALUES (p_id_usuario, p_direccion);
END$$

DELIMITER ;

-- MODIFICAR mapa

DELIMITER $$

CREATE PROCEDURE sp_modificar_mapa(
    IN p_id_usuario INT,
    IN p_direccion VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Mapa WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dirección no encontrada';
    END IF;

    UPDATE Mapa
    SET direccion = p_direccion
    WHERE id_usuario = p_id_usuario;
END$$

DELIMITER ;

-- BAJA MAPA

DELIMITER $$

CREATE PROCEDURE sp_baja_mapa(
    IN p_id_usuario INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Mapa WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existe dirección para el usuario';
    END IF;

    DELETE FROM Mapa WHERE id_usuario = p_id_usuario;
END$$

DELIMITER ;

-- CONSULTA mapa

DELIMITER $$

CREATE PROCEDURE sp_consultar_mapa(
    IN p_id_usuario INT
)
BEGIN
    SELECT *
    FROM Mapa
    WHERE id_usuario = p_id_usuario;
END$$

DELIMITER ;



-- Uso alta, baja, modificacion y consulta

CALL sp_alta_usuario('Pedro Lopez','pedro@mail.com',111222333,555111000,'ACTIVO');
CALL sp_alta_usuario('Ana Torres','ana@mail.com',222333444,555111001,'ACTIVO');
CALL sp_alta_usuario('Luis Diaz','luis@mail.com',333444555,555111002,'ACTIVO');
CALL sp_alta_usuario('Sofia Ruiz','sofia@mail.com',444555666,555111003,'ACTIVO');
CALL sp_alta_usuario('Mario Cano','mario@mail.com',555666777,555111004,'ACTIVO');

CALL sp_modificar_usuario(1,'Juan Perez','juan@empresa.com',123456789,'ACTIVO');
CALL sp_modificar_usuario(2,'Maria Gomez','maria@empresa.com',987654321,'ACTIVO');
CALL sp_modificar_usuario(3,'Yeison Benito','yeison@empresa.com',555555555,'ACTIVO');
CALL sp_modificar_usuario(4,'Nicolas Maduro','nmaduro@empresa.com',111111111,'INACTIVO');
CALL sp_modificar_usuario(5,'Donald Trump','trump@empresa.com',999999999,'ACTIVO');
CALL sp_modificar_usuario(6,'Oscar Gonzalez','gonzalez@empresa.com',244454425,'ACTIVO');

CALL sp_baja_usuario(6);

CALL sp_consultar_usuario(1);
CALL sp_consultar_usuario(2);
CALL sp_consultar_usuario(3);
CALL sp_consultar_usuario(4);
CALL sp_consultar_usuario(5);

CALL sp_listar_usuarios_activos();
CALL sp_listar_usuarios_activos();
CALL sp_listar_usuarios_activos();
CALL sp_listar_usuarios_activos();
CALL sp_listar_usuarios_activos();

CALL sp_alta_login(1,'clave123');
CALL sp_alta_login(2,'password456');
CALL sp_alta_login(3,'login789');
CALL sp_alta_login(4,'admin001');
CALL sp_alta_login(5,'secure999');
CALL sp_alta_login(6,'pass1234');

CALL sp_modificar_login(1,'nuevaClave1');
CALL sp_modificar_login(2,'nuevaClave2');
CALL sp_modificar_login(3,'nuevaClave3');
CALL sp_modificar_login(4,'nuevaClave4');
CALL sp_modificar_login(5,'nuevaClave5');

CALL sp_baja_login(6);

CALL sp_consultar_login(1);
CALL sp_consultar_login(2);
CALL sp_consultar_login(3);
CALL sp_consultar_login(4);
CALL sp_consultar_login(5);

CALL sp_alta_horario('2024-02-01','08:00','17:00');
CALL sp_alta_horario('2024-02-02','09:00','18:00');
CALL sp_alta_horario('2024-02-03','07:30','16:30');
CALL sp_alta_horario('2024-02-04','10:00','19:00');
CALL sp_alta_horario('2024-02-05','08:30','17:30');
CALL sp_alta_horario('2024-02-06','08:30','17:30');

CALL sp_baja_horario('2024-02-06');

CALL sp_consultar_horario('2024-01-01');
CALL sp_consultar_horario('2024-01-02');
CALL sp_consultar_horario('2024-01-03');
CALL sp_consultar_horario('2024-01-04');
CALL sp_consultar_horario('2024-01-05');

CALL sp_alta_mapa(1,'Calle 10 123');
CALL sp_alta_mapa(2,'Av. Central 456');
CALL sp_alta_mapa(3,'Carrera 7 #89');
CALL sp_alta_mapa(4,'Boulevard Norte 321');
CALL sp_alta_mapa(5,'Camino Real 654');
CALL sp_alta_mapa(6,'Calle juan 64');

CALL sp_baja_mapa(6);

CALL sp_consultar_mapa(1);
CALL sp_consultar_mapa(2);
CALL sp_consultar_mapa(3);
CALL sp_consultar_mapa(4);
CALL sp_consultar_mapa(5);

/* ============================
   VALIDACIONES – USUARIOS
   ============================ */

-- ERROR: Nombre, email y estado son obligatorios
CALL sp_alta_usuario('', 'correo@mail.com', 123456789, 999000111, 'ACTIVO');

-- ERROR: El email ya existe
CALL sp_alta_usuario('Usuario Duplicado', 'juan.perez@example.com', 123123123, 999000112, 'ACTIVO');

-- ERROR: El número de seguro social ya existe
CALL sp_alta_usuario('Usuario SS', 'nuevo@mail.com', 123123123, 987654321, 'ACTIVO');

-- ERROR: El usuario no existe
CALL sp_baja_usuario(999);

-- ERROR: Usuario no encontrado
CALL sp_modificar_usuario(999, 'Nombre', 'mail@mail.com', 111111111, 'ACTIVO');

-- ERROR: El email ya está en uso por otro usuario
CALL sp_modificar_usuario(1, 'Juan', 'maria.gomez@example.com', 123456789, 'ACTIVO');


/* ============================
   VALIDACIONES – LOGIN
   ============================ */

-- ERROR: El usuario no existe
CALL sp_alta_login(999, 'clave123');

-- ERROR: El usuario ya tiene un login
CALL sp_alta_login(1, 'clave123');

-- ERROR: La contraseña debe tener al menos 6 caracteres
CALL sp_alta_login(2, '123');

-- ERROR: Login no encontrado
CALL sp_modificar_login(999, 'nuevaClave');

-- ERROR: La contraseña es demasiado corta
CALL sp_modificar_login(1, 'abc');

-- ERROR: Login no existe
CALL sp_baja_login(999);


/* ============================
   VALIDACIONES – HORARIO
   ============================ */

-- ERROR: La hora de entrada debe ser menor que la de salida
CALL sp_alta_horario('2024-03-01', '18:00', '08:00');

-- ERROR: Ya existe un horario para esa fecha
CALL sp_alta_horario('2024-01-01', '08:00', '17:00');

-- ERROR: Horario no encontrado
CALL sp_modificar_horario('2030-01-01', '08:00', '17:00');

-- ERROR: Horario inválido
CALL sp_modificar_horario('2024-01-02', '18:00', '08:00');

-- ERROR: No existe horario para esa fecha
CALL sp_baja_horario('2035-01-01');


/* ============================
   VALIDACIONES – MAPA
   ============================ */

-- ERROR: Usuario no existe
CALL sp_alta_mapa(999, 'Direccion falsa');

-- ERROR: El usuario ya tiene dirección registrada
CALL sp_alta_mapa(1, 'Otra direccion');

-- ERROR: La dirección no puede estar vacía
CALL sp_alta_mapa(2, '');

-- ERROR: Dirección no encontrada
CALL sp_modificar_mapa(999, 'Direccion nueva');

-- ERROR: No existe dirección para el usuario
CALL sp_baja_mapa(999);