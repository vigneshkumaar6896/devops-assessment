const express = require('express');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

// Home route
app.get('/', (req, res) => {
  res.send('DevOps Assessment Running');
});

// DB connection (WORKING VERSION)
const pool = new Pool({
  user: "appuser",
  password: "Devops@12345",
  host: "34.100.215.18",   // Cloud SQL public IP (works now)
  database: "appdb",
  port: 5432,
});

// DB test route
app.get('/db-test', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({
      message: "DB Connected Successfully ",
      time: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).send('DB Connection Failed');
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});