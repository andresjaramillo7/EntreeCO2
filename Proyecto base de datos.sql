SELECT * FROM Bitacora_Logins;

SELECT * FROM Restaurante;
SELECT * FROM Usuarios;
SELECT * FROM Sesiones;
SELECT * FROM Ingredientes;
SELECT * FROM Recetas;
SELECT * FROM Receta_Ingredientes;
SELECT * FROM Reportes_Diarios;

-- 1. Crear tabla Restaurante
CREATE TABLE Restaurante (
    id_restaurante SERIAL PRIMARY KEY,
    nombre_restaurante VARCHAR(100) NOT NULL
);

-- 2. Crear tabla Usuarios 
CREATE TABLE Usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    tipo_usuario VARCHAR(20) NOT NULL CHECK (tipo_usuario IN ('administrador', 'cliente')),
    id_restaurante INT
);

-- 3. Crear tabla Sesiones 
CREATE TABLE Sesiones (
    id_sesion SERIAL PRIMARY KEY,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT,
    id_restaurante INT
);

-- 4. Crear tabla Bitacora_Logins
CREATE TABLE Bitacora_Logins (
    id_login SERIAL PRIMARY KEY,
    fecha_login TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tabla_afectada VARCHAR(100) NOT NULL,
    valor_afectado VARCHAR(255) NOT NULL,
    estado_login VARCHAR(50)
);

-- 5. Crear tabla Ingredientes
CREATE TABLE Ingredientes (
    id_ingrediente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    peso_carbono DECIMAL(10, 2) NOT NULL
);

-- 6. Crear tabla Recetas 
CREATE TABLE Recetas (
    id_receta SERIAL PRIMARY KEY,
    nombre_receta VARCHAR(100) NOT NULL,
    metodo_preparacion TEXT,
    id_restaurante INT
);

-- 7. Crear tabla intermedia Receta_Ingredientes
CREATE TABLE Receta_Ingredientes (
    id_receta_ingrediente SERIAL PRIMARY KEY,
    id_receta INT,
    id_ingrediente INT
);

-- 8. Crear tabla Reportes_Diarios 
CREATE TABLE Reportes_Diarios (
    id_reporte SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    total_carbono_dia DECIMAL(10, 2),
    recetas_preparadas INT,
    id_sesion INT
);

-- 9. Agregar FK
ALTER TABLE Usuarios 
ADD CONSTRAINT fk_usuario_restaurante 
FOREIGN KEY (id_restaurante) REFERENCES Restaurante(id_restaurante);

ALTER TABLE Sesiones 
ADD CONSTRAINT fk_sesion_usuario 
FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario);

ALTER TABLE Sesiones 
ADD CONSTRAINT fk_sesion_restaurante 
FOREIGN KEY (id_restaurante) REFERENCES Restaurante(id_restaurante);

ALTER TABLE Recetas 
ADD CONSTRAINT fk_receta_restaurante 
FOREIGN KEY (id_restaurante) REFERENCES Restaurante(id_restaurante);

ALTER TABLE Receta_Ingredientes 
ADD CONSTRAINT fk_receta_ingrediente_receta 
FOREIGN KEY (id_receta) REFERENCES Recetas(id_receta);

ALTER TABLE Receta_Ingredientes 
ADD CONSTRAINT fk_receta_ingrediente_ingrediente 
FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente);

ALTER TABLE Reportes_Diarios 
ADD CONSTRAINT fk_reporte_sesion 
FOREIGN KEY (id_sesion) REFERENCES Sesiones(id_sesion);

-- Stored Procedure para insertar en la tabla Restaurante
CREATE OR REPLACE PROCEDURE InsertarRestaurante(
    _nombre_restaurante VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Restaurante (nombre_restaurante)
    VALUES (_nombre_restaurante);
END;
$$;


-- Stored Procedure para insertar en la tabla Usuarios
CREATE OR REPLACE PROCEDURE InsertarUsuario(
    _nombre_usuario VARCHAR(100),
    _email VARCHAR(100),
    _contraseña VARCHAR(255),
    _tipo_usuario VARCHAR(20),
    _id_restaurante INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Usuarios (nombre_usuario, email, contraseña, tipo_usuario, id_restaurante)
    VALUES (_nombre_usuario, _email, _contraseña, _tipo_usuario, _id_restaurante);
END;
$$;

-- Stored Procedure para insertar en la tabla Ingredientes
CREATE OR REPLACE PROCEDURE InsertarIngrediente(
    _nombre VARCHAR(100),
    _peso_carbono DECIMAL(10, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Ingredientes (nombre, peso_carbono)
    VALUES (_nombre, _peso_carbono);
END;
$$;

-- Stored Procedure para insertar en la tabla Recetas
CREATE OR REPLACE PROCEDURE InsertarReceta(
    _nombre_receta VARCHAR(100),
    _metodo_preparacion TEXT,
    _id_restaurante INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Recetas (nombre_receta, metodo_preparacion, id_restaurante)
    VALUES (_nombre_receta, _metodo_preparacion, _id_restaurante);
END;
$$;

-- Stored Procedure para insertar en la tabla Sesiones
CREATE OR REPLACE PROCEDURE InsertarSesion(
    _id_usuario INT,
    _id_restaurante INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Sesiones (id_usuario, id_restaurante)
    VALUES (_id_usuario, _id_restaurante);
END;
$$;

-- Stored Procedure para insertar en la tabla Reportes_Diarios
CREATE OR REPLACE PROCEDURE InsertarReporteDiario(
    _fecha DATE,
    _total_carbono_dia DECIMAL(10, 2),
    _recetas_preparadas INT,
    _id_sesion INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Reportes_Diarios (fecha, total_carbono_dia, recetas_preparadas, id_sesion)
    VALUES (_fecha, _total_carbono_dia, _recetas_preparadas, _id_sesion);
END;
$$;

-- Triggers para llenar la Bitacora

-- Trigger para llenar la Bitacora al insertar en Usuarios
CREATE OR REPLACE FUNCTION log_insert_usuario()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Bitacora_Logins (tabla_afectada, valor_afectado, estado_login)
    VALUES ('Usuarios', NEW.id_usuario::TEXT, 'Insert');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_usuario
AFTER INSERT ON Usuarios
FOR EACH ROW
EXECUTE FUNCTION log_insert_usuario();

-- Trigger para llenar la Bitacora al insertar en Ingredientes
CREATE OR REPLACE FUNCTION log_insert_ingrediente()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Bitacora_Logins (tabla_afectada, valor_afectado, estado_login)
    VALUES ('Ingredientes', NEW.id_ingrediente::TEXT, 'Insert');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_ingrediente
AFTER INSERT ON Ingredientes
FOR EACH ROW
EXECUTE FUNCTION log_insert_ingrediente();

-- Trigger para llenar la Bitacora al insertar en Recetas
CREATE OR REPLACE FUNCTION log_insert_receta()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Bitacora_Logins (tabla_afectada, valor_afectado, estado_login)
    VALUES ('Recetas', NEW.id_receta::TEXT, 'Insert');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_receta
AFTER INSERT ON Recetas
FOR EACH ROW
EXECUTE FUNCTION log_insert_receta();

-- Trigger para llenar la Bitacora al insertar en Sesiones
CREATE OR REPLACE FUNCTION log_insert_sesion()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Bitacora_Logins (tabla_afectada, valor_afectado, estado_login)
    VALUES ('Sesiones', NEW.id_sesion::TEXT, 'Insert');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_sesion
AFTER INSERT ON Sesiones
FOR EACH ROW
EXECUTE FUNCTION log_insert_sesion();

-- Trigger para llenar la Bitacora al insertar en Reportes_Diarios
CREATE OR REPLACE FUNCTION log_insert_reporte()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Bitacora_Logins (tabla_afectada, valor_afectado, estado_login)
    VALUES ('Reportes_Diarios', NEW.id_reporte::TEXT, 'Insert');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_reporte
AFTER INSERT ON Reportes_Diarios
FOR EACH ROW
EXECUTE FUNCTION log_insert_reporte();

CREATE OR REPLACE PROCEDURE InsertarRecetaIngrediente(
    _id_receta INT,
    _id_ingrediente INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Receta_Ingredientes (id_receta, id_ingrediente)
    VALUES (_id_receta, _id_ingrediente);
END;
$$;



-- Insertar restaurantes
CALL InsertarRestaurante('Restaurante'); --(nombre de restaurantre)

-- Insertar usuarios
CALL InsertarUsuario('Santiago Calvo', 'santiago@ejemplo.com', 'password123', 'administrador', 1);--(nombre, email, contraseña, tipo de cuenta, id restaurante )
CALL InsertarUsuario('Juan Lomelí', 'juan@ejemplo.com', 'password456', 'cliente', 1);
CALL InsertarUsuario('Pedro López', 'pedro@ejemplo.com', 'password789', 'cliente', 1);

-- Insertar sesiones
CALL InsertarSesion(1, 1);  --(id usuario , id restaurante)
CALL InsertarSesion(2, 1);  
CALL InsertarSesion(3, 1);  

-- Insertar ingredientes
CALL InsertarIngrediente('Filete Talapía', 2.58); --(nombre ingrediente, emisiones)
CALL InsertarIngrediente('Cebolla', 0.38);
CALL InsertarIngrediente('Tomate', 2.26);
CALL InsertarIngrediente('Brocoli', 0.91);
CALL InsertarIngrediente('Zanahoria', 0.38);
CALL InsertarIngrediente('Cilantro', 0.88);
CALL InsertarIngrediente('Apio', 0.44);
CALL InsertarIngrediente('Sal', 0.88);
CALL InsertarIngrediente('Pimienta', 0.88);
CALL InsertarIngrediente('Pechuga Pollo', 4.78);
CALL InsertarIngrediente('Pierna Jamon', 9.85);
CALL InsertarIngrediente('Queso', 8.93);
CALL InsertarIngrediente('Huevo', 4.3);


-- Insertar recetas
CALL InsertarReceta('Pescado Empapelado', 'Asar el filete de tilapia con especias y limón', 1); --(nombre de la receta, descripción, id restaurante)
CALL InsertarReceta('Pechuga Cordon Bleu', 'Rellenar la pechuga con jamón y queso, empanizar y hornear', 1);
CALL InsertarReceta('Huevo a la Mexicana', 'Saltear tomate, cebolla, chile y mezclar con huevo batido', 1);

--Insertar reecta_ingredientes
CALL InsertarRecetaIngrediente(1, 1);--(id de la receta, id del ingrediente)
CALL InsertarRecetaIngrediente(1, 2);
CALL InsertarRecetaIngrediente(1, 3);
CALL InsertarRecetaIngrediente(1, 4);
CALL InsertarRecetaIngrediente(1, 5);
CALL InsertarRecetaIngrediente(1, 6);
CALL InsertarRecetaIngrediente(1, 7);
CALL InsertarRecetaIngrediente(1, 8);
CALL InsertarRecetaIngrediente(1, 9);

CALL InsertarRecetaIngrediente(2, 10);
CALL InsertarRecetaIngrediente(2, 11);
CALL InsertarRecetaIngrediente(2, 12);
CALL InsertarRecetaIngrediente(2, 8);
CALL InsertarRecetaIngrediente(2, 9);

CALL InsertarRecetaIngrediente(3, 13);
CALL InsertarRecetaIngrediente(3, 3);
CALL InsertarRecetaIngrediente(3, 2);
CALL InsertarRecetaIngrediente(3, 8);
CALL InsertarRecetaIngrediente(3, 9);

-- Insertar reporte diario
CALL InsertarReporteDiario(CURRENT_DATE, 5.85, 2, 1); --(fecha, emision, num recetas, id de la sesion)
CALL InsertarReporteDiario(CURRENT_DATE, 3.00, 1, 2); 

