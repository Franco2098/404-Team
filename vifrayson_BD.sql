-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         12.2.2-MariaDB - MariaDB Server
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.17.0.7270
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para vifraison
CREATE DATABASE IF NOT EXISTS `vifraison` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `vifraison`;

-- Volcando estructura para tabla vifraison.fichaje
CREATE TABLE IF NOT EXISTS `fichaje` (
  `id_fichaje` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora_entrada` time DEFAULT NULL,
  `hora_salida` time DEFAULT NULL,
  PRIMARY KEY (`id_fichaje`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla vifraison.fichaje: ~1 rows (aproximadamente)
INSERT INTO `fichaje` (`id_fichaje`, `id_usuario`, `fecha`, `hora_entrada`, `hora_salida`) VALUES
	(1, 1, '2026-05-24', '12:27:36', '12:27:55');

-- Volcando estructura para tabla vifraison.horario
CREATE TABLE IF NOT EXISTS `horario` (
  `fecha` date NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `entrada` time NOT NULL,
  `salida` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla vifraison.horario: ~6 rows (aproximadamente)
INSERT INTO `horario` (`fecha`, `id_usuario`, `entrada`, `salida`) VALUES
	('2026-05-19', 1, '08:00:00', '17:00:00'),
	('2026-05-20', 2, '09:00:00', '18:00:00'),
	('2026-05-21', 1, '08:00:00', '17:00:00'),
	('2026-05-22', 3, '10:00:00', '19:00:00'),
	('2026-05-23', 2, '09:00:00', '18:00:00'),
	('2026-05-18', 1, '08:00:00', '17:00:00'),
	('2026-05-20', 1, '08:00:00', '17:00:00'),
	('2026-05-22', 1, '08:00:00', '17:00:00');

-- Volcando estructura para tabla vifraison.login
CREATE TABLE IF NOT EXISTS `login` (
  `id_usuario` int(11) DEFAULT NULL,
  `contraseña` varchar(20) NOT NULL,
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla vifraison.login: ~3 rows (aproximadamente)
INSERT INTO `login` (`id_usuario`, `contraseña`) VALUES
	(1, 'clave123'),
	(2, 'password456'),
	(3, 'login789');

-- Volcando estructura para tabla vifraison.mapa
CREATE TABLE IF NOT EXISTS `mapa` (
  `id_usuario` int(11) DEFAULT NULL,
  `direccion` varchar(255) NOT NULL,
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla vifraison.mapa: ~0 rows (aproximadamente)
INSERT INTO `mapa` (`id_usuario`, `direccion`) VALUES
	(1, 'Calle Falsa 123');

-- Volcando estructura para tabla vifraison.recompensas
CREATE TABLE IF NOT EXISTS `recompensas` (
  `id_recompensa` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) NOT NULL,
  `puntos_requeridos` int(11) NOT NULL,
  PRIMARY KEY (`id_recompensa`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla vifraison.recompensas: ~4 rows (aproximadamente)
INSERT INTO `recompensas` (`id_recompensa`, `descripcion`, `puntos_requeridos`) VALUES
	(2, 'Mejor empleado del mes - Reconocimiento y bonus especial.', 100),
	(3, 'Bonus anual - Acumula 500 puntos para obtener premio.', 500),
	(4, 'Descuento en la cafetería del 15%', 250);

-- Volcando estructura para procedimiento vifraison.sp_alta_horario
DELIMITER //
CREATE PROCEDURE `sp_alta_horario`(
    IN p_fecha DATE,
    IN p_id_usuario INT,
    IN p_entrada TIME,
    IN p_salida TIME
)
BEGIN
    IF p_entrada >= p_salida THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La hora de entrada debe ser menor que la de salida';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;
    INSERT INTO Horario (fecha, id_usuario, entrada, salida)
    VALUES (p_fecha, p_id_usuario, p_entrada, p_salida);
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_alta_login
DELIMITER //
CREATE PROCEDURE `sp_alta_login`(IN p_id_usuario INT, IN p_contrasena VARCHAR(20))
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
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_alta_mapa
DELIMITER //
CREATE PROCEDURE `sp_alta_mapa`(IN p_id_usuario INT, IN p_direccion VARCHAR(255))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no existe';
    END IF;
    INSERT INTO Mapa (id_usuario, direccion) VALUES (p_id_usuario, p_direccion);
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_alta_recompensa
DELIMITER //
CREATE PROCEDURE `sp_alta_recompensa`(IN p_descripcion VARCHAR(255), IN p_puntos INT)
BEGIN
    IF p_puntos <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los puntos deben ser mayores a cero';
    END IF;
    INSERT INTO Recompensas (descripcion, puntos_requeridos) VALUES (p_descripcion, p_puntos);
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_alta_tarea
DELIMITER //
CREATE PROCEDURE `sp_alta_tarea`(
    IN p_id_usuario INT,
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_descripcion VARCHAR(255)
)
BEGIN
    INSERT INTO Tareas (id_usuario, fecha, hora, descripcion)
    VALUES (p_id_usuario, p_fecha, p_hora, p_descripcion);
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_alta_usuario
DELIMITER //
CREATE PROCEDURE `sp_alta_usuario`(
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
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_baja_horario
DELIMITER //
CREATE PROCEDURE `sp_baja_horario`(IN p_fecha DATE)
BEGIN
    DELETE FROM Horario WHERE fecha = p_fecha;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_baja_login
DELIMITER //
CREATE PROCEDURE `sp_baja_login`(IN p_id_usuario INT)
BEGIN
    DELETE FROM Login WHERE id_usuario = p_id_usuario;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_baja_mapa
DELIMITER //
CREATE PROCEDURE `sp_baja_mapa`(IN p_id_usuario INT)
BEGIN
    DELETE FROM Mapa WHERE id_usuario = p_id_usuario;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_baja_tarea
DELIMITER //
CREATE PROCEDURE `sp_baja_tarea`(IN p_id_tarea INT)
BEGIN
    DELETE FROM Tareas WHERE id_tarea = p_id_tarea;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_baja_usuario
DELIMITER //
CREATE PROCEDURE `sp_baja_usuario`(
    IN p_id_usuario INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;

    UPDATE Usuarios SET estado = 'INACTIVO' WHERE id_usuario = p_id_usuario;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_consultar_horario
DELIMITER //
CREATE PROCEDURE `sp_consultar_horario`(IN p_fecha DATE)
BEGIN
    SELECT h.fecha, h.id_usuario, u.nombre,
           TIME_FORMAT(h.entrada,'%H:%i') AS entrada,
           TIME_FORMAT(h.salida,'%H:%i')  AS salida
    FROM Horario h
    JOIN Usuarios u ON h.id_usuario = u.id_usuario
    WHERE h.fecha = p_fecha;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_consultar_login
DELIMITER //
CREATE PROCEDURE `sp_consultar_login`(IN p_id_usuario INT)
BEGIN
    SELECT id_usuario FROM Login WHERE id_usuario = p_id_usuario;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_consultar_mapa
DELIMITER //
CREATE PROCEDURE `sp_consultar_mapa`(IN p_id_usuario INT)
BEGIN
    SELECT * FROM Mapa WHERE id_usuario = p_id_usuario;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_consultar_usuario
DELIMITER //
CREATE PROCEDURE `sp_consultar_usuario`(IN p_id_usuario INT)
BEGIN
    SELECT * FROM Usuarios WHERE id_usuario = p_id_usuario;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_estado_fichaje
DELIMITER //
CREATE PROCEDURE `sp_estado_fichaje`(IN p_id_usuario INT)
BEGIN
    SELECT hora_entrada, hora_salida
    FROM Fichaje
    WHERE id_usuario = p_id_usuario AND fecha = CURDATE();
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_fichar_entrada
DELIMITER //
CREATE PROCEDURE `sp_fichar_entrada`(IN p_id_usuario INT)
BEGIN
    -- Evitar doble fichaje de entrada el mismo día
    IF EXISTS (
        SELECT 1 FROM Fichaje
        WHERE id_usuario = p_id_usuario AND fecha = CURDATE() AND hora_entrada IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya has fichado entrada hoy';
    END IF;
    INSERT INTO Fichaje (id_usuario, fecha, hora_entrada)
    VALUES (p_id_usuario, CURDATE(), CURTIME());
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_fichar_salida
DELIMITER //
CREATE PROCEDURE `sp_fichar_salida`(IN p_id_usuario INT)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Fichaje
        WHERE id_usuario = p_id_usuario AND fecha = CURDATE() AND hora_entrada IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No has fichado entrada hoy';
    END IF;
    IF EXISTS (
        SELECT 1 FROM Fichaje
        WHERE id_usuario = p_id_usuario AND fecha = CURDATE() AND hora_salida IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya has fichado salida hoy';
    END IF;
    UPDATE Fichaje
    SET hora_salida = CURTIME()
    WHERE id_usuario = p_id_usuario AND fecha = CURDATE();
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_listar_recompensas
DELIMITER //
CREATE PROCEDURE `sp_listar_recompensas`()
BEGIN
    SELECT * FROM Recompensas;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_listar_tareas_usuario
DELIMITER //
CREATE PROCEDURE `sp_listar_tareas_usuario`(IN p_id_usuario INT, IN p_fecha DATE)
BEGIN
    SELECT id_tarea, TIME_FORMAT(hora,'%h:%i %p') AS hora, descripcion
    FROM Tareas
    WHERE id_usuario = p_id_usuario AND fecha = p_fecha
    ORDER BY hora;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_listar_usuarios_activos
DELIMITER //
CREATE PROCEDURE `sp_listar_usuarios_activos`()
BEGIN
    SELECT * FROM Usuarios WHERE estado = 'ACTIVO';
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_modificar_horario
DELIMITER //
CREATE PROCEDURE `sp_modificar_horario`(
    IN p_fecha DATE,
    IN p_id_usuario INT,
    IN p_entrada TIME,
    IN p_salida TIME
)
BEGIN
    UPDATE Horario SET entrada = p_entrada, salida = p_salida
    WHERE fecha = p_fecha AND id_usuario = p_id_usuario;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_modificar_login
DELIMITER //
CREATE PROCEDURE `sp_modificar_login`(IN p_id_usuario INT, IN p_contrasena VARCHAR(20))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Login WHERE id_usuario = p_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Login no encontrado';
    END IF;
    UPDATE Login SET contraseña = p_contrasena WHERE id_usuario = p_id_usuario;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_modificar_mapa
DELIMITER //
CREATE PROCEDURE `sp_modificar_mapa`(IN p_id_usuario INT, IN p_direccion VARCHAR(255))
BEGIN
    UPDATE Mapa SET direccion = p_direccion WHERE id_usuario = p_id_usuario;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_modificar_tarea
DELIMITER //
CREATE PROCEDURE `sp_modificar_tarea`(IN p_id_tarea INT, IN p_hora TIME, IN p_descripcion VARCHAR(255))
BEGIN
    UPDATE Tareas SET hora = p_hora, descripcion = p_descripcion WHERE id_tarea = p_id_tarea;
END//
DELIMITER ;

-- Volcando estructura para procedimiento vifraison.sp_modificar_usuario
DELIMITER //
CREATE PROCEDURE `sp_modificar_usuario`(
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
END//
DELIMITER ;

-- Volcando estructura para tabla vifraison.tareas
CREATE TABLE IF NOT EXISTS `tareas` (
  `id_tarea` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  PRIMARY KEY (`id_tarea`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla vifraison.tareas: ~24 rows (aproximadamente)
INSERT INTO `tareas` (`id_tarea`, `id_usuario`, `fecha`, `hora`, `descripcion`) VALUES
	(1, 1, '2026-05-26', '09:00:00', 'Reunión de equipo'),
	(2, 1, '2026-05-26', '11:30:00', 'Revisión de proyecto'),
	(3, 1, '2026-05-26', '15:00:00', 'Presentación cliente'),
	(4, 2, '2026-05-26', '09:00:00', 'Revisión de código'),
	(5, 2, '2026-05-26', '11:00:00', 'Reunión con cliente'),
	(6, 3, '2026-05-26', '08:30:00', 'Planificación semanal'),
	(7, 3, '2026-05-26', '10:00:00', 'Desarrollo de módulo'),
	(8, 4, '2026-05-26', '09:00:00', 'Soporte técnico'),
	(9, 4, '2026-05-26', '14:00:00', 'Documentación'),
	(10, 5, '2026-05-26', '10:00:00', 'QA y Testing'),
	(11, 5, '2026-05-26', '15:00:00', 'Cierre de tickets'),
	(12, 6, '2026-05-26', '09:30:00', 'Llamada con socios'),
	(13, 6, '2026-05-26', '12:00:00', 'Almuerzo networking'),
	(14, 1, '2026-05-27', '09:00:00', 'Standup diario'),
	(15, 2, '2026-05-27', '10:00:00', 'Workshop desarrollo'),
	(16, 3, '2026-05-27', '11:00:00', 'Sesión de brainstorming'),
	(17, 4, '2026-05-27', '09:00:00', 'Revisión semanal'),
	(18, 5, '2026-05-27', '14:00:00', 'Planificación sprint'),
	(19, 6, '2026-05-27', '16:00:00', 'Retrospectiva'),
	(20, 1, '2026-05-28', '09:00:00', 'Entrega de informe'),
	(21, 2, '2026-05-28', '11:30:00', 'Revisión de diseño'),
	(22, 3, '2026-05-28', '14:00:00', 'Formación interna'),
	(23, 4, '2026-05-28', '16:00:00', 'Happy Hour / Team Building'),
	(24, 1, '2026-05-19', '09:00:00', 'Reunión de equipo'),
	(25, 1, '2026-05-18', '10:00:00', 'Workshop desarrollo'),
	(26, 1, '2026-05-18', '11:30:00', 'Revisión de proyecto'),
	(27, 1, '2026-05-18', '15:00:00', 'Presentación cliente'),
	(28, 1, '2026-05-19', '14:00:00', 'Sesión de brainstorming'),
	(29, 1, '2026-05-20', '09:30:00', 'Llamada con socios'),
	(30, 1, '2026-05-20', '12:00:00', 'Almuerzo networking'),
	(31, 1, '2026-05-20', '16:00:00', 'Revisión semanal'),
	(32, 1, '2026-05-20', '17:30:00', 'Planificación sprint'),
	(33, 1, '2026-05-21', '09:00:00', 'Soporte técnico'),
	(34, 1, '2026-05-21', '11:00:00', 'QA y Testing'),
	(35, 1, '2026-05-21', '14:30:00', 'Documentación'),
	(36, 1, '2026-05-22', '10:00:00', 'Retrospectiva'),
	(37, 1, '2026-05-22', '13:00:00', 'Cierre de tickets'),
	(38, 1, '2026-05-22', '16:00:00', 'Happy Hour / Team Building');

-- Volcando estructura para tabla vifraison.usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `telefono` bigint(20) NOT NULL,
  `numero_ss` bigint(20) NOT NULL,
  `estado` varchar(50) NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `numero_ss` (`numero_ss`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla vifraison.usuarios: ~6 rows (aproximadamente)
INSERT INTO `usuarios` (`id_usuario`, `nombre`, `email`, `telefono`, `numero_ss`, `estado`) VALUES
	(1, 'Pedro Lopez', 'pedro@mail.com', 111222333, 555111000, 'ACTIVO'),
	(2, 'Ana Torres', 'ana@mail.com', 222333444, 555111001, 'ACTIVO'),
	(3, 'Luis Diaz', 'luis@mail.com', 333444555, 555111002, 'ACTIVO'),
	(4, 'Sofia Ruiz', 'sofia@mail.com', 444555666, 555111003, 'ACTIVO'),
	(5, 'Mario Cano', 'mario@mail.com', 555666777, 555111004, 'ACTIVO'),
	(6, 'Oscar Gonzalez', 'gonzalez@empresa.com', 244454425, 555111005, 'ACTIVO');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
