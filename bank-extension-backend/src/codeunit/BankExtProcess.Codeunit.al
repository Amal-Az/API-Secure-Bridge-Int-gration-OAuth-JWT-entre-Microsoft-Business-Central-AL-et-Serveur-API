codeunit 50102 "Bank Ext Process"
{
    Access = Public;

    var
        // Le compilateur AL se plaindra de ces lignes tant que les symboles ne seront pas téléchargés.
        APIMgt: Codeunit "Bank Ext API Mgt";
        DataPrep: Codeunit "Bank Ext Data Prep";

    /// <summary>
    /// Fonction principale pour déclencher le processus complet d'envoi des données à l'API externe.
    /// </summary>
    /// <param name="varProcessedCount">Compte le nombre de transactions envoyées.</param>
    // Correction de l'erreur AL0105: 'var' placé devant le nom du paramètre.
    procedure RunIngestionProcess(var varProcessedCount: Integer)
    var
        JsonTransactions: JsonArray;
    begin
        // 1. Préparation des données
        JsonTransactions := DataPrep.GetTransactionsForAPI();

        if JsonTransactions.Count() = 0 then begin
            Message('Aucune transaction à envoyer.');
            exit;
        end;

        // 2. Envoi sécurisé via l'API Management (gère l'Auth et le POST)
        if APIMgt.PostTransactions(JsonTransactions) then begin
            varProcessedCount := JsonTransactions.Count();
            Message('%1 transactions envoyées avec succès à l''API externe.', varProcessedCount);
        end else begin
            Error('Le processus d''ingestion a échoué. Voir les messages d''erreur précédents pour les détails.');
        end;
    end;
}