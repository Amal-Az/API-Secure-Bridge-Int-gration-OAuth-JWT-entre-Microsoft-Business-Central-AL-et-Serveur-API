page 50100 "Bank Ext API Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Bank Ext API Config"; 
    Caption = 'Bank External API Setup';

    layout
    {
        area(Content)
        {
            group(Connection)
            {
                Caption = 'API Connection Details';
                field("API Base URL"; Rec."API Base URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Définit l''URL de base pour la communication avec le service externe.';
                }
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    ApplicationArea = All;

                    ToolTip = 'Clé secrète utilisée pour l''authentification OAuth.';
                }
            }
            group(TokenStatus)
            {
                Caption = 'Current Token Status';
                field("Last Token"; Rec."Last Token")
                {
                    ApplicationArea = All;
                }
                field("Token Expiry Time"; Rec."Token Expiry Time")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunIngestion)
            {
                Caption = 'Run Data Ingestion';
                ApplicationArea = All;
                Image = Process; 
                
                trigger OnAction()
                var
                    IngestionProcess: Codeunit "Bank Ext Process"; 
                    ProcessedCount: Integer;
                begin
                    IngestionProcess.RunIngestionProcess(ProcessedCount);
                end;
            }
            action(TestConnection)
            {
                Caption = 'Test Connection (Auth)';
                ApplicationArea = All;
                Image = Action; 
                
                trigger OnAction()
                var
                    APIMgt: Codeunit "Bank Ext API Mgt";
                    AccessToken: Text;
                begin
                    AccessToken := APIMgt.GetAccessToken();
                    Message('Jeton obtenu avec succès. Expiration: %1', Rec."Token Expiry Time");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get(1) then begin
            Rec.Init();
            Rec."Primary Key" := 1;
            Rec.Insert();
        end;
    end;
}