import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';


const OAUTH_SECRET = process.env.OAUTH_SECRET;
const CLIENT_ID_BC = process.env.CLIENT_ID_BC;
const CLIENT_SECRET_BC = process.env.CLIENT_SECRET_BC; 

if (!OAUTH_SECRET || !CLIENT_ID_BC || !CLIENT_SECRET_BC) {
    console.error(" Les secrets OAuth (CLIENT_ID/SECRET/OAUTH_SECRET) ne sont pas définis dans .env.");
    process.exit(1);
}

// Génère un nouveau jeton JWT si les identifiants sont valides
export const getToken = (req: Request, res: Response) => {
    
    const { clientId, clientSecret } = req.body;

    // 1. Validation de base des identifiants du client
    if (!clientId || !clientSecret) {
        return res.status(400).json({ message: 'Identifiant (clientId) et Secret (clientSecret) sont requis.' });
    }

    // 2. Vérification de l'identité du client 
    if (clientId !== CLIENT_ID_BC || clientSecret !== CLIENT_SECRET_BC) {
        // Loggez la tentative échouée pour la sécurité
        console.warn(`Tentative de connexion échouée pour l'ID: ${clientId}`); 
        return res.status(401).json({ message: 'Identifiants non valides.' });
    }
    
    // 3. Identifiants valides : Génération du jeton
    try {
        const payload = {
            clientId: clientId,
            role: 'businessCentral',
        };

        const token = jwt.sign(payload, OAUTH_SECRET, {
            expiresIn: '1h' 
        });

        // 4. Succès : Renvoyer le jeton
        res.status(200).json({ 
            access_token: token,
            token_type: 'Bearer',
            expires_in: 3600 //  = 1 heure
        });

    } catch (error) {
        console.error("Erreur lors de la génération du JWT:", error);
        res.status(500).json({ message: 'Erreur interne lors de la génération du jeton.' });
    }
};