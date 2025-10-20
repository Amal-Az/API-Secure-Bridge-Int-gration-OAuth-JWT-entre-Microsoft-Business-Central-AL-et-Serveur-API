import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload as BaseJwtPayload } from 'jsonwebtoken';
import 'dotenv/config';

export interface AuthPayload extends BaseJwtPayload {
    clientId: string;
    role: 'businessCentral' | 'admin' | string;
}

export interface AuthRequest extends Request {
    user?: AuthPayload;
}

// Définition du Secret avec une assertion de type pour la clarté
const SECRET: string | undefined = process.env.OAUTH_SECRET;

// Vérification Critique au Démarrage : Garanti l'arrêt si manquant
if (!SECRET) {
    console.error(" OAUTH_SECRET n'est pas défini. La sécurité de l'API est compromise. Arrêt du processus.");
    process.exit(1); 
}

//  vérifier le jeton JWT
export const protectRoute = (req: AuthRequest, res: Response, next: NextFunction) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ 
            message: "Accès refusé. Jeton manquant ou mal formaté. Utilisez l'en-tête 'Authorization: Bearer [token]'." 
        });
    }

    // Le token est extrait, mais pour satisfaire TypeScript dans l'appel jwt.verify,
    // on le définit comme potentiellement undefined avant le split.
    const token = authHeader.split(' ')[1];

    try {
        //  L'opérateur ! est sur le token pour satisfaire le compilateur
        const decoded = jwt.verify(token!, SECRET) as object; 
        
        const userPayload = decoded as AuthPayload; 
        
        req.user = userPayload;
        
        next();

    } catch (error) {
        return res.status(403).json({ 
            message: "Jeton invalide ou expiré.", 
            error: (error as Error).message 
        });
    }
};