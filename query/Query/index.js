// Importing necessary libraries
const sql = require('mssql');
require('dotenv').config();

module.exports = async function (context, _) {
    context.log('JavaScript HTTP trigger function processed a request.');
    context.log(process.env["DB_USER"]);
    try {
        // Getting database and container
        const pool = await sql.connect({
            server: process.env["DB_SERVER"],
            database: process.env["DB_DATABASE"],
            user: process.env["DB_USER"],
            password: process.env["DB_PASSWORD"],
            encrypt: true
        });

        // Getting people from read Database
        const result = await pool.request().query('SELECT * FROM Persons');

        // Responder con un mensaje de éxito
        context.res = { status: 200, body: result.recordset };
    } catch (error) {
        context.log(error)
        // Si ocurre un error, responder con el mensaje de error
        context.res = { status: 500, body: error.message };
    }
}