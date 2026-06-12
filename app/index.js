const express = require('express');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

// -----------------------------
// HOME ROUTE
// -----------------------------
app.get('/', (req, res) => {
  res.send('DevOps Assessment Running');
});

// -----------------------------
// DB CONNECTION 
// -----------------------------
const pool = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,

  //(NO PUBLIC IP)
  host: `/cloudsql/${process.env.INSTANCE_CONNECTION_NAME}`,

  port: 5432,
});

// -----------------------------
// DB TEST ROUTE
// -----------------------------
app.get('/db-test', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');

    res.json({
      message: "DB Connected Successfully",
      time: result.rows[0]
    });

  } catch (err) {
    console.error("DB Error:", err.message);

    res.status(500).json({
      message: "DB Connection Failed",
      error: err.message
    });
  }
});

// -----------------------------
// SERVER START
// -----------------------------
const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});