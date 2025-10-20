import { Router } from 'express';
import { ingestTransactions } from '../controllers/transactionsController.js';
import { protectRoute } from '../middleware/authMiddleware.js';

const router = Router();

// Route POST pour ingérer les transactions brutes. "Elle est protégée par le middleware 'protectRoute'"
router.post('/ingest', protectRoute, ingestTransactions);

export default router;