pageextension 50100 "Bank Ext Posted Invoice Ext" extends "Posted Sales Invoice"
{
    actions
    {
        //  Utiliser 'addlast' pour spécifier l'emplacement de l'action.
        addlast(Processing) 
        {
            action(SendToBankExternalAPI)
            {
                Caption = 'Send to Bank API';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = Post; 
                ToolTip = 'Déclenche l''envoi des données de transaction au service externe pour traitement.';

                trigger OnAction()
                var
                    BankExtProcess: Codeunit "Bank Ext Process"; 
                    ProcessedCount: Integer;
                begin
                    // Pour le test, on exécute le processus général
                    BankExtProcess.RunIngestionProcess(ProcessedCount);
                end;
            }
        }
    }
}