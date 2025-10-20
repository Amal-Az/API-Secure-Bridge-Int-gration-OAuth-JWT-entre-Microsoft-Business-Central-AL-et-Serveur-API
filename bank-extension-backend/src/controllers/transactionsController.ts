import { Response } from 'express';
import { AuthRequest } from '../middleware/authMiddleware.js'; 
import { query } from '../config/database.js'; 

// ----------------------------------------------------------------------
//  NOTE : Définition temporaire du type de transaction attendue
interface RawTransaction {
    external_id: string;
    date_transaction: string; // Attendu au format ISO 8601 (YYYY-MM-DDTHH:MM:SSZ)
    montant: number;
    devise: string;
    description: string;
}
// ----------------------------------------------------------------------


export const ingestTransactions = async (req: AuthRequest, res: Response) => {
    // 1. Vérification des droits du client
    const clientRole = req.user?.role;
    if (clientRole !== 'businessCentral' && clientRole !== 'admin') {
        return res.status(403).json({ message: "Rôle client non autorisé pour cette opération." });
    }
    
    // 2. Extraction des données
    const rawTransactions: RawTransaction[] = req.body.transactions;

    if (!rawTransactions || rawTransactions.length === 0) {
        return res.status(400).json({ message: "Le corps de la requête doit contenir un tableau 'transactions' non vide." });
    }

    // 3. Préparation de la requête d'insertion en lot (Batch Insertion)
    const columns = [
        'external_id', 'date_transaction', 'montant', 'devise', 'description', 
        'date_ingestion', 'statut_traitement', 'client_id'
    ];
    
    let valuesClause = '';
    const params: any[] = [];
    
    // Construction dynamique de la clause VALUES
    rawTransactions.forEach((tx, index) => {
        const baseIndex = params.length;
        
        // Ajout des valeurs dans l'ordre des colonnes
        params.push(
            tx.external_id,
            tx.date_transaction,
            tx.montant,
            tx.devise,
            tx.description,
            new Date().toISOString(), // date_ingestion : la date actuelle
            'RAW',                    // statut_traitement par défaut
            req.user?.clientId || 'N/A' // client_id (issu du jeton JWT)
        );
        
        // Construction de la clause ($1, $2, ..., $8)
        const placeholder = `($${baseIndex + 1}, $${baseIndex + 2}, $${baseIndex + 3}, $${baseIndex + 4}, $${baseIndex + 5}, $${baseIndex + 6}, $${baseIndex + 7}, $${baseIndex + 8})`;
        
        valuesClause += placeholder + (index < rawTransactions.length - 1 ? ', ' : '');
    });

    const sqlQuery = `
        INSERT INTO transactions_externes (${columns.join(', ')}) 
        VALUES ${valuesClause}
        ON CONFLICT (external_id) DO NOTHING;
    `;

    try {
        // 4. Exécution de la requête
        const result = await query(sqlQuery, params);

        res.status(201).json({ 
            message: `Ingestion réussie. ${result.rowCount} transactions insérées ou mises à jour.`,
            inserted_count: result.rowCount
        });

    } catch (error) {
        console.error("Erreur lors de l'insertion des transactions:", error);
        res.status(500).json({ 
            message: "Erreur interne du serveur lors de l'ingestion des données.",
            detail: (error as Error).message
        });
    }
};