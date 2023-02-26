// Importing necessary libraries
const sql = require('mssql');
require('dotenv').config();

module.exports = async function (context, req) {
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
  
      // Creating person in write database
      await pool.request().query`INSERT INTO Persons (ID, FirstName, Age) VALUES (${req.body.id}, ${req.body.name}, ${req.body.age})`;
      res.status(201).json({ mensaje: 'Registro creado correctamente' });;
    } catch (error) {
      context.log(error);
      res.status(500).json({ error: 'Error creating person' });
    }
}