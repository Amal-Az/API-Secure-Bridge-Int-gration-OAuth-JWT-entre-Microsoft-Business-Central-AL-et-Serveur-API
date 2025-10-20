// Fichier: src/app.ts

import express, { Request, Response } from 'express';
import 'dotenv/config';
import pool from './config/database.js'; 
import authRouter from './routes/auth.js';
import transactionsRouter from './routes/transactions.js';
// On importe le pool, et on va l'utiliser pour tester la connexion dans la route /status
// Note : Pour utiliser 'query', il faudrait l'importer de database.js,
// mais on va garder ça simple ici en utilisant directement pool.query

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json()); 
app.use(express.urlencoded({ extended: true })); 

// --- Route de Test de Santé Complète ---
app.get('/api/status', async (req: Request, res: Response) => {
    let dbStatus = 'disconnected';
    
    try {
        //  vérifier la connexion DB
        await pool.query('SELECT 1'); 
        dbStatus = 'connected';
        
        res.status(200).json({ 
            message: 'Service Externe est opérationnel.', 
            environment: process.env.NODE_ENV,
            database_status: dbStatus // Ajout du statut DB
        });

    } catch (error) {
        console.error('Erreur lors du test de santé de la DB:', error);
        dbStatus = 'error';

        res.status(503).json({ 
            message: 'Service Externe est opérationnel MAIS la base de données est INACCESSIBLE.', 
            database_status: dbStatus
        });
    }
});

// NOUVEAU : Routes d'authentification
app.use('/api/auth', authRouter); 

// NOUVEAU : Routes des transactions (Protégées)
app.use('/api/transactions', transactionsRouter);
 

// --- Démarrage du Serveur ---
app.listen(PORT, () => {
  console.log(` Serveur Node.js démarré sur le port ${PORT}`);
});