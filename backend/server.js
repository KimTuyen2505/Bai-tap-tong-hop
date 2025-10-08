// Save this as server.js and run with: node server.js
// Install dependencies: npm install express pg cors body-parser

const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const port = 8000;

// PostgreSQL connection pool
const pool = new Pool({
  host: '172.20.10.4',
  port: 5432,
  database: 'iot_classroom',
  user: 'postgres',
  password: '1',
});

app.use(cors());
app.use(bodyParser.json());

// Create table if not exists
async function initDatabase() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS control_history (
        id SERIAL PRIMARY KEY,
        device_id VARCHAR(100) NOT NULL,
        command VARCHAR(50) NOT NULL,
        timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
        success BOOLEAN DEFAULT TRUE
      )
    `);
    console.log('Database initialized');
  } catch (err) {
    console.error('Database initialization error:', err);
  }
}

initDatabase();

// Get control history
app.get('/api/control-history', async (req, res) => {
  try {
    const { device_id, limit = 100 } = req.query;
    
    let query, params;
    if (device_id) {
      query = `
        SELECT id, device_id, command, timestamp, success
        FROM control_history
        WHERE device_id = $1
        ORDER BY timestamp DESC
        LIMIT $2
      `;
      params = [device_id, limit];
    } else {
      query = `
        SELECT id, device_id, command, timestamp, success
        FROM control_history
        ORDER BY timestamp DESC
        LIMIT $1
      `;
      params = [limit];
    }

    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching history:', err);
    res.status(500).json({ error: 'Failed to fetch history' });
  }
});

// Save control command
app.post('/api/control-history', async (req, res) => {
  try {
    const { device_id, command, success = true } = req.body;
    
    const result = await pool.query(
      `INSERT INTO control_history (device_id, command, timestamp, success)
       VALUES ($1, $2, NOW(), $3)
       RETURNING *`,
      [device_id, command, success]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error saving command:', err);
    res.status(500).json({ error: 'Failed to save command' });
  }
});

// Clear history
app.delete('/api/control-history', async (req, res) => {
  try {
    const { device_id } = req.query;
    
    if (device_id) {
      await pool.query('DELETE FROM control_history WHERE device_id = $1', [device_id]);
    } else {
      await pool.query('DELETE FROM control_history');
    }
    
    res.json({ message: 'History cleared' });
  } catch (err) {
    console.error('Error clearing history:', err);
    res.status(500).json({ error: 'Failed to clear history' });
  }
});

app.listen(port, () => {
  console.log(`Database API server running on http://172.20.10.4:${port}`);
});
