import { Pool } from 'pg';
import 'dotenv/config'; 

// Configuration de la connexion 
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT || '5432', 10),
});

// Test de la connexion (très important au démarrage)
pool.on('connect', () => {
  console.log(' Connexion à PostgreSQL établie avec succès.');
});

pool.on('error', (err) => {
  console.error(' Erreur inattendue lors de la connexion à PostgreSQL:', err);
  process.exit(-1); // Quitte l'application si la connexion DB échoue
});

export const query = (text: string, params?: any[]) => pool.query(text, params);
export default pool;