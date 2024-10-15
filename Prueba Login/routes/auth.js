const express = require('express');
const bcrypt = require('bcrypt');
const db = require('../db'); 
const router = express.Router();


router.post('/register', async (req, res) => {
    const { nombre_usuario, email, contraseña } = req.body;

  
    const existingUser = await db.query('SELECT * FROM Usuarios WHERE email = $1', [email]);
    if (existingUser.rows.length > 0) {
        return res.status(400).send('El usuario ya existe.');
    }

    // contraseña
    const hashedPassword = await bcrypt.hash(contraseña, 10);

    // nuevo usuario en la base de datos con tipo_usuario predeterminado
    const tipo_usuario = 'cliente'; 
    await db.query(
        'INSERT INTO Usuarios (nombre_usuario, email, contraseña, tipo_usuario) VALUES ($1, $2, $3, $4)', 
        [nombre_usuario, email, hashedPassword, tipo_usuario]
    );

    res.status(201).send('Usuario registrado.');
});


// Ruta para iniciar sesión
router.post('/login', async (req, res) => {
    const { email, contraseña } = req.body;

    // Busca el usuario en la base de datos
    const user = await db.query('SELECT * FROM Usuarios WHERE email = $1', [email]);
    if (user.rows.length === 0) {
        return res.status(400).send('Usuario no encontrado.');
    }

    // Compara las contraseñas
    const validPassword = await bcrypt.compare(contraseña, user.rows[0].contraseña);
    if (!validPassword) {
        return res.status(400).send('Contraseña incorrecta.');
    }

    // Si la autenticación es exitosa, redirige al home
    res.redirect('/home.html');
});

module.exports = router;
