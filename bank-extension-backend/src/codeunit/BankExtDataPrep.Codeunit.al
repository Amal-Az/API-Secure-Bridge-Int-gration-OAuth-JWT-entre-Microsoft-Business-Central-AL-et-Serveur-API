codeunit 50101 "Bank Ext Data Prep"
{
    Access = Public;

    /// <summary>
    /// Simule l'extraction des données brutes de Business Central et les formate pour l'API externe.
    /// </summary>
    /// <returns>Un JsonArray prêt à être envoyé à la fonction PostTransactions.</returns>
    procedure GetTransactionsForAPI(): JsonArray
    var
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        GLLedgerEntry: Record "G/L Entry"; // Exemple : Utiliser le Grand Livre comme source
        RecordLimit: Integer;
    begin
        RecordLimit := 5; // Simuler l'envoi des 5 premières écritures pour le test

        // Simulation : Trouver les 5 premières écritures pour l'exemple
        if GLLedgerEntry.FindSet(false, false) then begin
            repeat
                // 1. Créer l'objet JSON pour la transaction unique
                JsonObject.Add('external_id', Format(GLLedgerEntry."Entry No.") + '-BC');
                JsonObject.Add('date_transaction', Format(GLLedgerEntry."Posting Date", 0, '<yyyy-MM-ddT00:00:00Z>'));
                JsonObject.Add('montant', Abs(GLLedgerEntry.Amount));
                JsonObject.Add('devise', 'EUR'); // Simuler la devise
                JsonObject.Add('description', GLLedgerEntry.Description);

                // 2. Ajouter l'objet JSON à l'array
                JsonArray.Add(JsonObject);

                RecordLimit -= 1;
                if RecordLimit = 0 then
                    break;
            until GLLedgerEntry.Next() = 0;
        end;

        exit(JsonArray);
    end;
}