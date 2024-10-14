const { Pool } = require('pg');

//conexion al sql
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'EntreeCO22',
    password: 'pizza',
    port: 5432,
});

module.exports = pool;
