SELECT * FROM Bitacora_Logins;

SELECT * FROM Restaurante;
SELECT * FROM Usuarios;
SELECT * FROM Sesiones;
SELECT * FROM Ingredientes;
SELECT * FROM Recetas;
SELECT * FROM Receta_Ingredientes;
SELECT * FROM Reportes_Diarios;

CALL EliminarIngrediente(6);


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

-- Stored Procedure para Obtener el Usuario
CREATE OR REPLACE PROCEDURE ObtenerUsuario(
    _id_usuario INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM Usuarios WHERE id_usuario = _id_usuario;
END;
$$;

-- Stored Procedure para Validar el Usuario
CREATE OR REPLACE PROCEDURE ValidarUsuario(
    _id_usuario INT,
    _contraseña TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT tipo_usuario FROM Usuarios WHERE id_usuario = _id_usuario AND contraseña = _contraseña;
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

-- Stored Procedure para actualizar en la tabla de Ingredientes
CREATE OR REPLACE PROCEDURE ActualizarIngrediente(
    _id_ingrediente INT,
    _nombre VARCHAR(100),
    _peso_carbono DECIMAL(10, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Ingredientes
    SET nombre = _nombre, peso_carbono = _peso_carbono
    WHERE id_ingrediente = _id_ingrediente;
END;
$$;

CALL ActualizarIngrediente(2, 'Tomate Orgánico', 1.25);  -- Actualiza el ingrediente con ID 1.


-- Stored Procedure para eliminar un ingrediente y sus referencias en la tabla Receta_Ingredientes
CREATE OR REPLACE PROCEDURE EliminarIngrediente(
    _id_ingrediente INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    DELETE FROM Receta_Ingredientes
    WHERE id_ingrediente = _id_ingrediente;

  
    DELETE FROM Ingredientes
    WHERE id_ingrediente = _id_ingrediente;
END;
$$;

--ejemplo de uso CALL EliminarIngrediente(5);
-- Stored Procedure para listar/mostrar la tabla Ingredientes
CREATE OR REPLACE PROCEDURE ListarIngredientes()
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM Ingredientes;
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

--Store procedure insertar rectea_ingrediente
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
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Agave', 2.39);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Arroz Integral', 5.91);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Azúcar Invertido', 2.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Caña De Azúcar', 1.04);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Dátiles', 0.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Glucosa', 1.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Glucosa Deshidratada', 3.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Glucosa Y Fructosa', 2.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Hibisco', 1.26);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Inulina', 1.82);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Maíz', 2.61);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Mora', 2.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jarabe De Pan De Jengibre', 2.9);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jengibre', 0.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jengibre Cristalizado', 2.09);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jengibre En Escabeche Japonés', 0.77);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jengibre Molido', 0.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jengibre Rallado', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jengibre Seco', 1.86);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Judías Verdes', 1.63);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Judías Verdes Cocidas', 0.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Judías Verdes Congeladas', 0.52);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Judías Verdes Enlatadas', 1.45);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo Concentrado De Ruibarbo', 1.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Apio', 1.26);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Arándano', 2.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Calamansi', 1.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Col Rizada', 0.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Fresa', 2.68);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Frutas Mixtas', 1.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Higo', 3.2);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Jengibre', 0.46);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Kiwi', 2.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Kokum', 1.83);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Lichi', 1.67);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Lima', 1.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Limón', 1.83);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Limón Concentrado', 1.83);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Mango', 2.31);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Manzana', 1.92);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Mora', 2.6);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Pepino', 0.99);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Pera', 0.49);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Piña', 2.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Plátano', 0.64);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Remolacha', 1.09);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Res', 24.56);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Saúco', 2.31);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Uva', 2.28);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Jugo De Zanahoria', 1.03);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Kaffir Hoja De Lima', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Kimchi', 1.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Kirsch', 3.36);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Kiwis', 0.91);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Kombú', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Konjac', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Kril', 5.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Krispies De Arroz De Kelloggs', 3.05);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Kumquats', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lactosa', 2.95);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Láminas De Lasaña', 1.62);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Langosta', 23.18);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Langosta En Polvo', 129.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Langostino Del Río Amazonas', 78.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Langostino Gigante De Río', 61.55);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Langostino Tigre', 41.72);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Langostinos', 20.55);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Langostinos Cocidos', 26.1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Langostinos De Agua Fría', 26.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Langostinos De Agua Fría Cocidos', 26.09);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Langostinos Rebozados Congelados', 10.05);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lardons De Tocino', 17.75);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lasaña Boloñesa', 9.68);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lasaña, Sin Cocer', 13.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche', 2.51);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche Condensada', 5.57);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Almendras', 0.56);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Anacardo', 0.19);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Arroz', 0.66);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Avena', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Búfala', 12.6);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Cabra', 1.97);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Coco', 0.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Coco En Polvo', 4.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Coco Enlatada', 3.61);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Coco, Grasa Reducida', 0.46);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Oveja', 17.81);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Soja', 0.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche De Vaca', 2.61);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche Desnatada En Polvo', 8.87);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche En Polvo', 8.87);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche Entera En Polvo', 8.87);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche Entera Fresca', 2.59);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Leche Evaporada', 5.81);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lechuga', 0.98);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lechuga Apolo', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lechuga De Napa', 0.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lechuga Iceberg', 0.64);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lechuga Pequeña Joya', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lechuga Romana', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lentejas', 2.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lentejas Du Berry', 2.25);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lentejas Marrones', 2.25);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lentejas Negras', 2.25);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lentejas Negras Cocidas', 3.75);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lentejas Verdes', 2.25);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lentejas Verdes Enlatadas', 3.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Levadura Comprimida', 0.82);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Levadura En Polvo', 1.94);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Levadura Líquida', 0.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Levadura Seca', 3.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Licor De Limón Italiano', 2.76);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lima Kaffir', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lima Negra', 5.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Limas', 0.32);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Limón Rallado', 1.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Limonada', 0.32);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Limonada - Schweppes', 0.32);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Limonata - San Pellegrino', 0.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Limones', 0.52);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Linaza Dorada', -0.1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Linguini', 1.62);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lollo Biondo', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lollo Rosso', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lomo De Bacalao', 3.86);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lomo De Cerdo De Corral', 11.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lomo De Ternera', 39.95);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lomo De Ternera Cortado En Dados', 39.95);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Loncha De Jamón', 14.27);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lubina', 28.92);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Lubina De Cultivo', 14.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Macarrones', 1.61);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Macarrones Cocidos', 2.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Maíz', 1.22);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Maíz Bebé', 1.12);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Maíz De Verano', 1.17);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Maíz En La Mazorca', 1.12);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Maíz Enlatado', 1.36);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Maíz Tierno Congelado', 1.14);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Malbec', 1.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Malibú', 2.76);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Malta', 1.66);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Maltodextrina', 1.9);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Malvaviscos', 4.81);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manchego', 23.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mandarina', 0.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mandioca', 2.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mango', 0.31);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mango Congelado', 1.03);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mango Deshidratado', 5.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mangos', 1.02);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manis Kecap', 1.61);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manojo De Cilantro', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manteca', 7.62);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manteca De Cerdo', 12.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mantequilla De Almendras', -0.25);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mantequilla De Anacardo', 1.58);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mantequilla De Coco', 4.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mantequilla De Cocoa', 4.86);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mantequilla De Maní', 1.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mantequilla De Maní Crujiente', 3.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mantequilla De Maní Tostada Profunda', 3.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mantequilla De Manzana', 1.14);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mantequilla Flora', 5.9);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzana', 0.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzana Cocida', 0.66);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzana Orgánica', 0.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzana Royal Gala Inglesa', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzana Seca', 1.69);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzana Y Bayas De Cawston', 0.67);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzana Y Pera De Cawston', 0.57);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzanas Bramley', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzanas Doradas Deliciosas', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzanas Granny Smith', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Manzanas Verdes', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Margarina', 1.17);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Marmita', 4.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Marrajo', 11.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Martini Amargo', 2.76);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Martini Blanco', 1.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Martini Extra Seco', 1.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Martini Rosso', 1.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Masa De Cacao', 3.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Masa Madre Multicereales', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Masa Para Galletas', 3.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mascarpone', 10.04);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Matcha En Polvo', 0.48);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mayonesa', 3.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mayonesa Baja En Calorías', 3.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mayonesa De Ajo', 3.79);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mayonesa De Campo Libre', 3.97);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mayonesa De Chipotle', 2.59);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mayonesa Japonesa', 3.86);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mayoram', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mazo', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Medias Baguettes De Granero', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Medias Baguettes De Trigo Malteado', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Medio Jamón', 14.27);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mejillones, Con Concha', 0.79);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mejillones, Sin Concha', 2.24);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mejorana', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Melaza', 1.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Melaza Negro', 2.66);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Melón', 0.39);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Melón Canario', 2.94);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Melón Cantalupo', 1.34);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Melón Galia', 1.34);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Melones', 1.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Melones Dulces', 1.34);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Menta', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Menta Seca', 3.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Merengue De Bayas', 6.6);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Merengues', 4.66);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Meri-Blanco', 4.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Merlot', 1.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Merluza', 10.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mermelada', 1.94);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mermelada De Albaricoque', 2.12);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mermelada De Cerezas Morello', 2.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mermelada De Chía', 1.98);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mermelada De Chile', 1.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mermelada De Grosella Negra', 2.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mermelada De Limon', 1.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mermelada De Mandarina', 2.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla Bombay', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Bayas De Frutas Del Bosque', 1.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Brownie De Chocolate Sin Gluten - Doves Farm', 2.58);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Brownie De Dulce De Azúcar', 2.48);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Burrito De Pollo - Love Joes, Congelado', 4.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Caldo De Cordero', 6.64);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Caldo De Pollo', 3.14);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Caldo De Res', 59.72);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Cilantro Fresco Y Perejil', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Eneldo Y Cebollino', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Especias', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Fajitas De Pollo, Cocinado', 2.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Frutos Secos', 0.99);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Granos De Café Arábica Brasileño Y Peruano', 22.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Lechugas Porque', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Masa', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Menta Fresca Y Eneldo', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Pastel De Dulce De Chocolate', 2.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Pastel De Pescado, Crudo', 5.48);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Perejil Fresco Y Cebollino', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Perejil Fresco Y Eneldo', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla De Perejil Fresco Y Menta', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mezcla Fresca De Romero Y Tomillo', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Micro Berro De Albahaca', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Micro Berro De Cilantro', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Micro Berro De Guisante', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Micro Berros', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Micro Sakura Berro', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Micro Shishu Berro', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Miel', 1.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Miel Clara', 1.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Miel De Caña', 2.98);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Miel De Flores', 1.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Miel De Flores Mixtas', 1.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Miel De Maple', 8.52);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Migas De Galleta', 3.62);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Migas De Pan', 1.73);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Migraña', 14.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mijo', 1.22);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Milano Salami', 17.26);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mini Bollos De Hamburguesa', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mini Canelones De Ricotta Y Espinacas', 8.27);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mini Conos De Oblea', 2.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mini Empanadas De Cerdo', 6.8);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mini Malvaviscos', 4.81);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mirin', 1.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Miseria', 2.34);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mizuna', 0.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Molido De Especias Mixtas', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Molokhia Seco', 3.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Momo Masala', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mora Azul', 1.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mora Negra', 1.04);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Moras Congeladas', 1.67);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Moras Secas', 5.91);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Morcilla', 9.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mostaza', 1.18);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mostaza Americana', 1.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mostaza De Dijon', 1.25);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mostaza En Polvo', 0.87);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mostaza Inglesa', 1.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mosto De Uva Cocido', 2.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mozzarella Bocconcini', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mozzarella De Búfala', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mozzarella En Cubitos', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mozzarella Ligera', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Muesli', 1.92);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Muslo De Pato Cocido', 14.52);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Muslo De Pollo Cortado En Cubitos', 4.8);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Muslos De Pollo', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Muslos De Pollo Cocidos', 5.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Muslos De Pollo Halal', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Mozzarella Rallada', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nabo', 0.35);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Naranja China', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Naranjas', 0.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Naranjas De Sangre', 0.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nata', 3.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Natilla', 2.91);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nduja', 11.49);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nectarinas', 0.43);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Negro Tapenade De La Aceituna', 3.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nori', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nueces', 0.22);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nueces De Brasil', 0.36);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nueces Mixtas', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nuez', 2.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nuez Crujiente', 1.64);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nuez De Palma', 0.8);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nuez De Tierra', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nuez Moscada', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nuez Moscada Seca', 2.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Nutella', 4.1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Orégano Seco', 3.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Orégano Seco Molido', 3.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Ortigas', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Orzo Cocido', 0.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pakchoi', 0.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Paletilla De Cordero Troceada', 40.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Palitos De Azúcar Moreno', 2.92);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Palitos De Bacalao', 2.56);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Palitos De Pan', 1.57);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Palitos De Pescado, Congelados', 7.59);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Palitos De Salvado', 1.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Palmito', 0.43);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Palo De Pescado De Merluza', 2.14);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Palo De Pescado Makerel', 1.02);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Aguacate', 1.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Palta', 1.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Brioche Vegano Congelado', 1.74);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Congelado', 1.31);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Crujiente', 1.35);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan De Ajo', 3.21);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan De Cereales Malteados', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan De Granero', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan De Mantequilla Millonario, Congelado', 3.23);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan De Plátano', 2.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan De Semillas De Calabaza Y Chía', 1.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan De Trigo', 1.12);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan De Trigo Malteado', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan De Trigo Y Centeno', 2.81);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Entero', 0.77);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Integral E Integral', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Integral Sin Gluten', 3.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Malteado', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Moreno', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Multicereal', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Naan', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Plano', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Plano De Khobez', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Rallado Seco', 2.86);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Rallado Sin Gluten', 1.73);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pan Simple', 0.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Panal', 2.63);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Panceta Cocida', 16.91);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Panceta De Cerdo Deshuesada', 11.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Panecillo', 2.49);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Panecillo De Suero De Mantequilla', 2.74);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Panecillo Enharinado', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Panga', 12.97);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Panque Ingles', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papas', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papas Fritas', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papas Hervidas', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papas Nuevas', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papaya', 1.04);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papaya Transportada Por Aire', 8.39);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Parfait De Chocolate Y Amaretto', 3.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Parmigiano Reggiano', 12.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasa', 0.81);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasas De Llama', 4.35);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasas Doradas', 4.35);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta', 1.21);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Al Huevo', 3.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Biryani', 1.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Choux', 3.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Conchiglie', 1.62);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Coreana Ssamjang', 2.75);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Ajo', 0.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Ajo Y Jengibre', 1.69);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Albahaca', 1.57);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Almendra', 2.98);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Arroz Integral', 3.23);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Avellanas', 1.69);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Barbacoa (Knorr)', 2.73);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Cacao', 3.79);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Cachemira', 1.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Cachemira Knorr', 1.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Caldo De Pescado', 4.6);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Caldo De Pollo', 2.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Caldo De Res', 19.31);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Camarones Secos', 18.68);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Champiñones', 1.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Chipotle', 2.49);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Coco', 1.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Curry De Madrás', 1.19);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Curry Korma', 1.48);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Curry Laksa', 1.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Curry Massaman', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Curry Verde', 0.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Habas', 1.35);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Jengibre', 1.58);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Maní', 1.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Miso', 3.51);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Naranja Mexicana', 1.75);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Soja Negra Fermentada', 2.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta De Tomate Balsámico Secado Al Sol', 2.82);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Farfalle', 1.62);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Gochujang', 2.66);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Harissa', 0.79);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Jerk Jamaicana', 0.82);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Penne Cocida', 0.97);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Penne Cocida Sin Gluten', 2.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Penne Sin Gluten', 1.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Sin Gluten', 1.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasta Verde Harissa', 1.99);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastas De Curry', 0.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastel De Cabaña, Cocinado', 17.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastel De Carne Picada', 2.73);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastel De Génova', 4.05);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastel De Lentejas, Cocinado', 2.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastel De Pescado, Cocido', 3);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastel De Polenta De Limón Y Almendras', 2.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastel De Zanahoria', 3.24);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastelería Brik', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastelería Filo', 0.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasteles Daneses', 3.26);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pasteles De Carne Picada Sin Gluten, Cocidos', 3.68);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patata Seca', 2.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Al Horno', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Asadas', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Blancas Baby', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Blanqueadas', 0.76);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Bombay', 1.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Cocidas', 0.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Dulces', 0.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Dulces En Cubitos', 0.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas En Cubitos', 0.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Fritas', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas King Edwards', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Maris Piper', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Maris Piper Cortadas En Cubitos', 0.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Medianas', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Patatas Medianas Al Horno', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Paté De Trufa Negra', 1.91);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pato', 14.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pavo', 13.82);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pavo Cocido', 6.08);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pavo De Corral', 5.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pecho De Res Deshuesado', 39.95);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pechuga De Pato', 14.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pechuga De Pavo De Corral', 5.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pechuga De Pavo De Corral Cortada En Dados', 5.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pechuga De Pollo', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pechuga De Pollo Cocida', 5.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pechuga De Pollo De Corral', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pechuga De Pollo De Corral Cortada En Dados', 4.8);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pechuga De Pollo En Dados', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pechuga De Pollo Picada', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pecorino', 17.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pectina De Cítricos', 1.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pectina De Frutas', 1.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pedazos De Pollo', 4.92);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pegar Fecha', 1.12);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pelador Fácil Naranja', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Penne De Arroz Integral', 3.23);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pepinillos', 0.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pepinos', 0.49);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pepinos Bebés', 0.39);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pepinos Medianos', 0.39);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pera China', 0.55);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Peras', 0.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Peras Conferencia', 0.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Percebe', 2.3);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Perejil Plano', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Perejil Rizado', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Perejil Seco', 3.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Perifollo', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Peroni Sin Gluten', 1.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Hot Dog De Frankfurt', 10.94);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pescadilla', 2.66);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pescado Azul', 11.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pescado Empanado', 11.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pescado Empanizado Sin Gluten', 3.21);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pescado Mixto', 3.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pesto', 2.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pesto De Alcachofas', 3.19);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pesto De Berenjena Y Parmesano', 3.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pesto De Chile Y Albahaca', 2.98);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pesto Sin Ajo', 2.72);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pesto Verde', 3.02);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pesto Verde Sin Nueces', 3.14);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pétalos De Aciano', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pescado', 11.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pez Diamante', 6.02);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pez Espada', 12.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pez Roca', 6.94);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Piel De Lima Kaffir', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Piel De Naranja Seca', 2.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pierna De Cordero', 40.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pierna De Cordero Deshuesada', 40.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pierna De Jamón', 9.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pierna De Jamón, Con Hueso', 17.91);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pierna De Pato', 14.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pierna De Pollo', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pierna De Pollo Cocida', 5.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pierna De Pollo, Sin Hueso', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimienta', 0.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimienta Alepo', 3.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimienta Blanca Molida', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimienta De Cayena', 2.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimienta De Cayena Molida', 2.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimienta De Szechuan Molida', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimienta Inglesa Molida', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimienta Negra', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimienta Negra Molida', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimienta Picante De Calabria', 1.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimiento Rojo Seco', 1.67);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimiento Verde Seco', 2.62);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimientos', 0.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimientos De Cayena', 0.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimientos Del Piquillo A La Plancha', 0.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimientos Mixtos', 0.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimientos Mixtos Congelados', 1.25);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimientos Picantes', 1.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimientos Rojos A La Parrilla', 0.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimientos Rojos Cortados En Cubitos', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimientos Verdes', 1.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pimientos Verdes Cortados En Cubitos', 1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Piña Congelada', 0.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Piña Deshidratada', 2.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Piña En Cubos', 0.43);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Piña Enlatada', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Piñas', 0.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pistachos', 0.36);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Plátano Congelado', 0.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Plátano Deshidratado', 3.24);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Plátanos', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Plátanos De Comercio Justo', 0.9);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Plátanos Liofilizados', 16.79);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Plátanos Verdes', 0.9);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Platija', 6.27);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo de Cacao', 6.17);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polen De Abeja', 1.1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polen De Hinojo', -0.63);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polenta Fina', 2.02);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polenta Gruesa', 2.02);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo', 5.66);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo A La Brasa', 4.94);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo A La Parrilla', 4.81);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Cocinado', 5.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Con Hueso', 2.82);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo De Corral', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Desmenuzado Cocido', 5.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Empanizado', 5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo En Cubitos', 4.8);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Orgánico', 9.04);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Pakora, Cocido', 3.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Pakora, Crudo', 2.97);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Picado', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Picado 5% Grasa', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Sin Hueso', 3.68);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pollo Supremo', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Acai', 1.73);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Ajo', 2.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Ajo Negro', 3.1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Ashwagandha', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Bacalao', 25.23);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Baobab', 1.69);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Bayas Mixtas', 2.09);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Cacao', 0.74);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Caldo De Res', 43.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Carbón', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Cáscara De Limón', 3.11);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Chocolate Caliente', 10.68);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Chocolate Caliente Oscuro', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Clavo', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Clorella', 1.36);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Curry', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Curry Suave', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Flan', 1.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Glucosa', 3.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Hongos', 18.04);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Huevo Seco', 14.67);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Jugo De Betabel', 3.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Jugo De Remolacha', 3.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Mango', 1.46);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Moringa', 5.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Mostaza Inglesa', 0.87);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Raíz De Maca', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Betabel', 3.33);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Remolacha', 3.33);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Suero De Leche', 5.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Polvo De Yema De Huevo Deshidratado', 26.03);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Primavera De Pollo', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Proteína De Arroz Integral', 11.99);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Proteína De Haba', 3.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Proteína De Soja Aislada', 10.51);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Poro', 2.05);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puerro En Polvo', 2.05);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Poro Serco', 2.05);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puerro Seco', 2.05);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Poros', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puerros', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Poros Bebés', 0.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puerros Bebés', 0.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Poros Picados', 0.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puerros Picados', 0.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pulpa De Aguacate', 2.34);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pulpa De Manzana', 0.8);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pulpo', 6.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Acai', 2.24);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Ajo', 0.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Albaricoque', 1.26);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Arándanos', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Banana', 1.08);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Calabaza Butternut', 1.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Cereza Negra', 1.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Chile Habanero', 1.76);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Chile Verde', 1.76);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Grosella Negra', 2.24);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Guisantes', 1.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Jengibre', 1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Limoncillo', 0.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Mango', 1.6);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Mango Congelado', 1.6);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Manzana', 0.8);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Patata Congelado', 0.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Patatas', 3.55);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pure De Tomate', 1.03);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Puré De Tomate Doble Concentrado', 2.2);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso', 8.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Azul', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Azul Desmenuzado', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Berkswell', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Blando Con Toda La Grasa', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Brie', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Caerphilly', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Camembert', 10.97);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Cheddar', 15.62);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Cheddar Maduro', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Cheddar Suave', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Cheddar, Reducido En Grasa', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Cotija', 20.99);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Crema', 3.74);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Crema Ligero', 3.74);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso De Cabra', 16.14);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso De Ensalada Griega', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso De Madera De Manzano', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso De Vaca', 15.83);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Duro', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Duro Medio Graso', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Duro Rallado', 14.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso En Polvo', 22.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Feta', 23.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Feta Griego', 23.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Gran Milano Rallado', 17.8);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Monterey Jack Rebanado', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Mozzarella', 13.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Queso Semiduro', 8.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Quinta', 2.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Quinoa', 0.97);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Quinua', 0.97);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Quinoa Cocida', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Quinua Cocida', 0.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Quinoa Negra', 1.14);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Quinua Negra', 1.14);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rábano', 0.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rábano Japonés', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rábano Picante', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rábanos Negros', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rábanos Para El Desayuno', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Raíces Almidónicas', 0.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Raíz De Achicoria', 0.74);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Raíz De Ashwagandha', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Raíz De Loto', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Raíz De Maca', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rape', 12.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rebanada De Focaccia', 2.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rebanada De Nduja', 10.17);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rebanada De Queso Cheddar', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rebanadas Sabor Queso', 2.58);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Recorte De Cordero', 40.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Recorte De Cuarto Delantero De Res', 42.18);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Recursos Pesqueros', 0.18);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Refresco De Lima', 1.87);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Relleno De Pollo Coronación', 4.72);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Remolacha A Rayas De Caramelo', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Remolacha Azucarera', 1.95);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Remolacha Cocida', 0.48);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Remolacha Dulce', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Remolacha En Cubitos', 0.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Remolachas', 0.33);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Remolachas Doradas', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Repollo', 0.28);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Repollo Carbonizado', 1.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Repollo Hispi', 0.3);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Requesón', 14.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Ricota De Almendras', -0.09);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Ricotta', 3.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rigatoni Cocido', 2.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Riñón De Cordero', 40.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rodaballo', 14.51);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rodaja De Limón', 0.61);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rollo Chapata', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rollo Ciabatta', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rollo De Brioche', 3.68);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rollo De Fiambres', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rollo Marrón', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rombo', 8.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Romero Seco', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Rosquilla', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sabor A Grosella Negra', 3.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sabor A Plátano', 3.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Saborizante De Avellana', 3.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Saborizante De Caramelo', 3.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Saborizante De Galleta', 3.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Saborizante De Miel', 3.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Saborizante De Natillas', 3.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Saborizante De Panal', 3.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sal De Apio', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sal De Cocina', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sal Del Himalaya', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sal Kosher', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sal Marina Ahumada De Cornualles', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sal Marina De Cornualles', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sal Marina De Maldón', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sal Marina Yodada', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sal Y Pimienta Mixta', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sal Yodada', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salami Finocchiona', 17.26);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchicha Calabresa', 11.34);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchicha Calabresa Cocida', 11.72);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchicha De Mango, Lima Y Coco', 13.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchicha De Pollo Halal', 4.56);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchicha De Pollo Tikka', 3.91);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchicha De Pollo, Cruda', 3.73);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchicha Lorne, Cruda', 6.03);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchicha Lorne, Cruda', 6.03);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchicha Merguez, Cruda', 34.93);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchichas Bratwurst', 8.86);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchichas Cumberland', 9.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchichas Cumberland Cocidas', 9.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchichas De Cerdo', 17.94);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchichas De Cerdo Sin Gluten Congeladas', 8.45);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchichas Glamorgan', 2.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salchichas Sin Carne Congeladas (Vegana)', 1.36);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salida', 0.75);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salmón', 6.43);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salmón De Piscifactoría', 7.45);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salmón Escocés De Piscifactoría', 8.32);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa', 0.69);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa BBQ Coreana', 1.83);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Barbacoa Coreana', 1.83);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa BBQ Hickory', 1.77);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Barbacoa Hickory', 1.77);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Bechamel', 4.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Bechamel Cremosa', 2.99);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Boloñesa', 14.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Carbonara De Codillo De Jamón', 7.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Coreana De Frijoles Picantes Y Pimientos', 1.39);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Arándanos', 2.03);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Barbacoa', 1.77);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Chile', 1.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Chocolate', 2.08);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Cóctel De Mariscos', 2.63);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Frijol Negro', 0.9);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Hamburguesa', 2.05);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Manzana', 2.49);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Menta', 1.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Pescado - Calamares', 9.34);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Pescado - Vish', 3.12);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Postre De Caramelo', 2.51);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Postre De Chocolate Belga', 3.43);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Queso', 4.45);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Rábano', 4.05);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Soja Ligera', 1.58);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Soja Oscura', 1.58);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Tomate', 1.46);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Tomate Al Curry', 1.8);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa De Tomate De Mostaza', 1.83);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Demi Glace', 4.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Estilo Mexicano', 0.9);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Hoisin', 2.03);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Katsu', 1.28);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Marrón', 1.48);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Picante', 1.03);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Picante De Búfalo', 1.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Picante Mexicana', 0.21);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Picante Roja De Frank', 2.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsa Tabasco Verde', 1.27);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salsas Picantes', 1.04);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Salvia Seca', 3.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sandía', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sardina', 1.1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sazonador Cajún - Frenos', 1.57);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Schnitzel De Pollo', 3.55);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sebo Vegetal De Atora', 5.69);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas Ajwain', 0.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Achiote', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Alcaravea', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Alcaravea Molidas', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Amaranto', 0.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Apio', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Carambola', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Cebolla Negra', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Chia', 2.55);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Cilantro', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Comino', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Fenogreco', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Girasol', 3.49);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Hinojo', -0.63);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Linaza', 2.63);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Lino', 2.55);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Lino Marrones', -0.1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Lino Molidas', 0.1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Lino Oscuro', 2.55);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Melón', 1.43);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Mostaza', 0.87);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Mostaza Marrón', 0.87);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Mostaza Negra', 0.87);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Sésamo', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Sésamo Molidas', 4.36);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas De Sésamo Negro', 3.92);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Semillas Mixtas', 0.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Setas Mixtas', 1.21);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sho De Cordero Deshuesado', 40.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sidra', 1.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sirope De Avellana', 0.22);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sirope De Banana', 1.76);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sirope De Caramelo', 2.02);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Soja', 3.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Soja Desgrasada', 4.27);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Soja Negra', 3.51);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Soja Negra Fermentada', 5.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Solomillo De Ternera', 39.95);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Solomillo De Ternera Cocido', 39.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sopa De Champiñones Y Tomillo', 1.09);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sopa De Ribollita De Pollo', 1.12);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sopa Minestrone', 1.56);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sopa Minestrone De Codillo De Jamón', 4.87);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sopa Minestrone Otoñal', 0.92);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sorbete De Coco', 0.53);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sorbete De Grosella Negra', 1.19);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sorbete De Limón', 1.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sorgo', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Soufflé De Remolacha Y Queso De Cabra', 8.09);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Stracchino', 4.92);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Stroganoff De Ternera', 20.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Sueco', 0.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Suero De La Leche', 2.62);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Suero De Leche', 3.05);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Suma Choi', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Suprema De Pollo Alimentada Con Maíz', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tortilla De Maíz', 2.02);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tortilla De Maíz Azul', 0.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tallo De Brócoli', 0.86);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tallo De Coliflor', 0.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tallo De Limoncillo', 0.37);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tambaquí', 30.22);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tapa De Ternera B/R', 39.95);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tarta De Grosella Negra', 2.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tarta De Queso De Nido De Abeja', 4.61);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tarta De Queso De Vainilla Al Horno', 5.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tarta De Queso Lotus Biscoff', 6.63);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tarta De Tarta De Limón Glaseada', 4.76);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Té De Bayas', 3.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Té English Breakfast', 3.56);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Té Verde', 3.29);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tempeh Congelado', 1.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Temple', 1.1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Ternera Con Hueso', 17.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tiburón', 11.44);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tilapia', 21.75);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tilapia, Bagre Africano', 47.77);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tilapia, Gurami Besucona, Gurami Gigante, Barbo Plateado, Carpa Común, Carpa Plateada, Bagre Rayado', 35.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tiras De Carne', 39.95);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tiras De Pechuga De Pollo', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tiras De Pimientos Mixtos A La Parrilla', 0.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tocino', 10.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tocino Cocido', 23.69);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tocino Cocido Sin Ahumar', 23.68);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tocino Entreverado Ahumado Cocido', 25.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tofu', 2.27);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tofu De Albahaca', 3.1);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tofu Extra Firme', 3.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tofu Firme', 3.16);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomate Arrabbiata', 1.24);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomate Frito Enlatado', 1.3);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomate Pelado', 1.3);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomate Trozado', 1.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomate Uva', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomate Y Albahaca', 1.14);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates', 0.66);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates (Ciruela Bebé)', 5.18);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates (Clásico Suelto)', 1.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates (Redondo/Globo)', 0.64);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates (Vid)', 2.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates Aplastados', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates Asados', 0.99);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates Cherry', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates Cherry En Escabeche', 1.6);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates De Res', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates Marinados Al Sol', 1.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates Mm', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates Patrimoniales', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates Pera Bebé', 3.81);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomates Verdes', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomillo De Limón', 0.88);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomillo Seco', 3.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tomillo Seco Molido', 3.07);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tónico De Pepino - Fever-Tree', 0.32);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Topinambur', 0.94);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Toronja', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Pastel Selva Negra', 3.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Torta Del Bosque Negro', 3.15);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tortilla De Maiz', 2.02);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tortilla De Maíz, Congelada', 2.09);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trigo', 2.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trigo Blando', 1.04);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trigo Bulgur, Cocido', 1.08);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trigo De Invierno', 1.28);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trigo De Primavera', 1.61);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trigo Duro', 1.06);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trigo Harinero De Invierno', 1.24);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trigo Harinero De Primavera', 0.98);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trigo Hervido, Trigo Vulgar', 1.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trigo Khorosan', 1.65);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Tripa De Salchicha De Ternera', 34.01);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trozos De Manzana Seca', 1.69);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trozos De Pollo', 4.78);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trozos De Pollo Congelados', 4.96);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trucha', 9.48);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trucha Arcoiris', 11.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trucha De Arroyo, Trucha Marrón, Trucha Arco Iris, Trucha Alpina', 12.09);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Trufa Negro', 1.21);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Único', 9.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Uvas', 0.95);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Uvas De Vino', 1.49);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Uvas Negras', 1.59);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Uvas Verdes', 1.59);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vainas De Baquetas', 1.02);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vainilla', 4.3);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Veganés De Madrás', 3.34);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vegetales Mixtos Congelados', 0.57);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Verbena De Limón', 0.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vinagre Balsámico', 2.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vinagre Chardonnay', 1.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vinagre De Brandi', 1.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vinagre De Calamansi', 1.46);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vinagre De Cidra', 1.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vinagre De Malta De Cebada', 1.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vinagre De Sidra De Manzana', 1.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vinagre De Uva', 1.71);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vinagre Destilado', 1.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vino', 1.99);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vino Blanco', 1.54);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vino Caliente', 1.77);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vino De Madeira', 1.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vino Fortificado', 1.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vino Marsala', 1.7);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Vino Tinto', 1.49);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Waffles Belgas', 4.84);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Whisky Irlandés', 4.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Wrap De Tortilla De Harina', 2.57);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Wraps De Tortilla Sin Gluten', 2.41);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yemas De Huevo', 4.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yemas De Huevo Campero', 4.39);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogur De Almendras', 0.72);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogur De Cereza Bajo En Grasa', 2.28);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogur De Coco', 0.91);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogur De Fresa Bajo En Grasa', 2.25);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogur De Soja', 1.36);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogur Griego', 2.22);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogur Griego, 2% Grasa', 2.22);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogur Griego, Bajo En Grasa', 2.22);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogur Natural Bajo En Grasa', 2.22);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogur Sin Lactosa', 3.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Yogurt Blanco', 1.69);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zanahorias', 0.36);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zanahorias Bebe', 0.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zanahorias Chanternay', 0.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zanahorias De Burro', 0.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zanahorias De Invierno', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zanahorias En Cuadritos', 0.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zanahorias En Manojo', 0.58);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zanahorias Enlatadas', 1.6);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zumo Concentrado De Grosella Roja', 2.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zumo De Cereza', 2.3);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zumo De Grosella Negra', 2.69);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zumo De Manzana Recién Exprimido', 0.99);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Zumo De Naranja', 0.46);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Al Horno', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Asadas', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Blancas Baby', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Blanqueadas', 0.76);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Bombay', 1.13);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Cocidas', 0.85);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Dulces', 0.38);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Dulces En Cubitos', 0.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa En Cubitos', 0.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Fritas', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa King Edwards', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Maris Piper', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Maris Piper Cortadas En Cubitos', 0.5);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Medianas', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Papa Medianas Al Horno', 0.47);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Betabel A Rayas De Caramelo', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Betabel Azucarero', 1.95);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Betabel Cocido', 0.48);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Betabel Dulce', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Betabel En Cubitos', 0.4);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Betabeles', 0.33);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Betabel Dorado', 0.42);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Col', 0.28);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Col Carbonizado', 1.89);
INSERT INTO Ingredientes (nombre, peso_carbono) VALUES ('Col Hispi', 0.3);


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

--Funcion para insertar actualizaciones
CREATE OR REPLACE FUNCTION log_update_ingrediente()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Bitacora_Logins (tabla_afectada, valor_afectado, estado_login)
    VALUES ('Ingredientes', NEW.id_ingrediente::TEXT, 'Update');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para llenar la Bitacora al actualiozar ingredientes
CREATE TRIGGER after_update_ingrediente
AFTER UPDATE ON Ingredientes
FOR EACH ROW
EXECUTE FUNCTION log_update_ingrediente();

-- Función para registrar la eliminación en la bitácora
CREATE OR REPLACE FUNCTION log_delete_receta()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Bitacora_Logins (tabla_afectada, valor_afectado, estado_login)
    VALUES ('Recetas', OLD.id_receta::TEXT, 'Delete');
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger para registrar la eliminación de una receta
CREATE TRIGGER after_delete_receta
AFTER DELETE ON Recetas
FOR EACH ROW
EXECUTE FUNCTION log_delete_receta();

-- Función para registrar la actualización en la bitácora
CREATE OR REPLACE FUNCTION log_update_receta()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Bitacora_Logins (tabla_afectada, valor_afectado, estado_login)
    VALUES ('Recetas', NEW.id_receta::TEXT, 'Update');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para registrar la actualización de una receta
CREATE TRIGGER after_update_receta
AFTER UPDATE ON Recetas
FOR EACH ROW
EXECUTE FUNCTION log_update_receta();


--Queries:

--1 Consultar usuarios registrados junto con su tipo y el restaurante asociado
SELECT nombre_usuario, email, tipo_usuario, nombre_restaurante 
FROM Usuarios u
JOIN Restaurante r ON u.id_restaurante = r.id_restaurante;

--2 Consultar las acciones recientes registradas en la bitácora en las últimas 24 horas
SELECT * FROM Bitacora_Logins 
WHERE fecha_login >= NOW() - INTERVAL '1 day' 
ORDER BY fecha_login DESC;

--3 Consultar recetas y los ingredientes utilizados junto con el peso de carbono de cada ingrediente
SELECT r.nombre_receta, i.nombre AS ingrediente, i.peso_carbono
FROM Recetas r
JOIN Receta_Ingredientes ri ON r.id_receta = ri.id_receta
JOIN Ingredientes i ON ri.id_ingrediente = i.id_ingrediente;

--4 Consultar los reportes diarios de huella de carbono, mostrando el total de carbono y las recetas preparadas
SELECT fecha, total_carbono_dia, recetas_preparadas 
FROM Reportes_Diarios 
ORDER BY fecha DESC;

--5 Consultar las sesiones de usuarios recientes, mostrando el usuario y el restaurante asociado
SELECT s.fecha, u.nombre_usuario, r.nombre_restaurante
FROM Sesiones s
JOIN Usuarios u ON s.id_usuario = u.id_usuario
JOIN Restaurante r ON s.id_restaurante = r.id_restaurante
ORDER BY s.fecha DESC;

--6 Consultar los ingredientes con alto impacto de carbono, ordenados por el peso de carbono
SELECT nombre, peso_carbono 
FROM Ingredientes 
WHERE peso_carbono > 5.0 
ORDER BY peso_carbono DESC;

--7 Consultar el nombre de la receta y el total de carbono generado por los ingredientes de la receta
SELECT r.nombre_receta, SUM(i.peso_carbono) AS total_carbono
FROM Recetas r
JOIN Receta_Ingredientes ri ON r.id_receta = ri.id_receta
JOIN Ingredientes i ON ri.id_ingrediente = i.id_ingrediente
GROUP BY r.nombre_receta
ORDER BY total_carbono DESC;

-- Stored Procedure para eliminar una receta y sus ingredientes asociados
CREATE OR REPLACE PROCEDURE EliminarReceta(
    _id_receta INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    DELETE FROM Receta_Ingredientes
    WHERE id_receta = _id_receta;

  
    DELETE FROM Recetas
    WHERE id_receta = _id_receta;
END;
$$;

--eejmplo de uso CALL EliminarReceta(2);

-- Stored Procedure para actualizar una receta
CREATE OR REPLACE PROCEDURE ActualizarReceta(
    _id_receta INT,
    _nombre_receta VARCHAR(100),
    _metodo_preparacion TEXT,
    _id_restaurante INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    UPDATE Recetas
    SET nombre_receta = _nombre_receta, 
        metodo_preparacion = _metodo_preparacion,
        id_restaurante = _id_restaurante
    WHERE id_receta = _id_receta;
END;
$$;

--ejemplo de uso CALL ActualizarReceta(3, 'Pescado a la Parrilla', 'Asar el pescado a la parrilla con especias', 1);



CREATE OR REPLACE FUNCTION get_ingredientes_carbono(id_receta_input INT)
RETURNS TABLE (
    nombre_ingrediente VARCHAR,
    peso_carbono DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.nombre, 
        i.peso_carbono
    FROM 
        Ingredientes i
    JOIN 
        Receta_Ingredientes ri ON i.id_ingrediente = ri.id_ingrediente
    WHERE 
        ri.id_receta = id_receta_input;
END; 
$$ LANGUAGE plpgsql;

--ejemplo de uso SELECT * FROM get_ingredientes_carbono(1); 

CREATE OR REPLACE PROCEDURE EliminarIngredienteDeReceta(
    _id_ingrediente INT,
    _id_receta INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Eliminar la relación del ingrediente con la receta en la tabla Receta_Ingredientes
    DELETE FROM Receta_Ingredientes
    WHERE id_ingrediente = _id_ingrediente
      AND id_receta = _id_receta;
END;
$$;

--ejemplo de uso CALL EliminarIngredienteDeReceta(1, 1);  --(Id ingrediente , id receta)

CREATE OR REPLACE FUNCTION log_delete_ingrediente()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Bitacora_Logins (fecha_login, tabla_afectada, valor_afectado, estado_login)
    VALUES (NOW(), 'Ingredientes', OLD.id_ingrediente::TEXT, 'DELETE');
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger que se dispara antes de la eliminación de un ingrediente
CREATE TRIGGER before_delete_ingrediente
BEFORE DELETE ON Ingredientes
FOR EACH ROW
EXECUTE FUNCTION log_delete_ingrediente();

-- Crear la función para agregar un ingrediente a una receta
CREATE OR REPLACE FUNCTION fn_agregar_ingrediente_receta(
    _id_receta INT,
    _id_ingrediente INT
)
RETURNS VOID AS $$
BEGIN
   
    INSERT INTO Receta_Ingredientes (id_receta, id_ingrediente)
    VALUES (_id_receta, _id_ingrediente);
END;
$$ LANGUAGE plpgsql;


-- Crear la función para eliminar un ingrediente de una receta
CREATE OR REPLACE FUNCTION fn_eliminar_ingrediente_receta(
    _id_receta INT,
    _id_ingrediente INT
)
RETURNS VOID AS $$
BEGIN
    -- Eliminar ingrediente de la receta
    DELETE FROM Receta_Ingredientes
    WHERE id_receta = _id_receta AND id_ingrediente = _id_ingrediente;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para insertar en la tabla Receta_Ingredientes
CREATE OR REPLACE FUNCTION trigger_bitacora_insertar_ingrediente()
RETURNS TRIGGER AS $$
BEGIN
    -- Registrar en la bitácora cuando se inserte un nuevo ingrediente en la receta
    INSERT INTO Bitacora_Logins (fecha_login, tabla_afectada, valor_afectado, estado_login)
    VALUES (NOW(), 'Receta_Ingredientes', CONCAT('Receta:', NEW.id_receta, ' Ingrediente:', NEW.id_ingrediente), 'INSERT');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insertar_ingrediente
AFTER INSERT ON Receta_Ingredientes
FOR EACH ROW
EXECUTE FUNCTION trigger_bitacora_insertar_ingrediente();

-- Crear el trigger para eliminar en la tabla Receta_Ingredientes
CREATE OR REPLACE FUNCTION trigger_bitacora_eliminar_ingrediente()
RETURNS TRIGGER AS $$
BEGIN
    -- Registrar en la bitácora cuando se elimine un ingrediente de la receta
    INSERT INTO Bitacora_Logins (fecha_login, tabla_afectada, valor_afectado, estado_login)
    VALUES (NOW(), 'Receta_Ingredientes', CONCAT('Receta:', OLD.id_receta, ' Ingrediente:', OLD.id_ingrediente), 'DELETE');
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_eliminar_ingrediente
AFTER DELETE ON Receta_Ingredientes
FOR EACH ROW
EXECUTE FUNCTION trigger_bitacora_eliminar_ingrediente();


SELECT fn_agregar_ingrediente_receta(1, 100);
SELECT fn_eliminar_ingrediente_receta(1, 11);

SELECT * FROM Bitacora_Logins;