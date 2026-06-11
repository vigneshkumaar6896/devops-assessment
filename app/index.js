const express = require('express');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

// Home route
app.get('/', (req, res) => {
  res.send('DevOps Assessment Running');
});

// Cloud SQL connection (secure socket path)
const pool = new Pool({
  user: "appuser",
  password: "Devops@12345",
  host: "/cloudsql/devsecops-assesment-2026:asia-south1:devops-sql",
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