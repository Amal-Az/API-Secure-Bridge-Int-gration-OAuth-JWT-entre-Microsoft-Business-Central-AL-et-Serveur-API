
import { Router } from 'express';
import { getToken } from '../controllers/authController.js';

const router = Router();

// Route pour obtenir un jeton d'accès (Utilisé par Business Central)
// Le client envoie: { clientId: '...', clientSecret: '...' }
router.post('/token', getToken);

export default router;