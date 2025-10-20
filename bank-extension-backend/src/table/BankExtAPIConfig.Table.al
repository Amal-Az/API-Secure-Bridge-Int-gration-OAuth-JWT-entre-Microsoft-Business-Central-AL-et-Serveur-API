table 50100 "Bank Ext API Config"
{
    Caption = 'Bank External API Configuration';
    DataClassification = CustomerContent; // Classé comme données sensibles

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
            InitValue = 1;
        }
        field(10; "API Base URL"; Text[250])
        {
            Caption = 'API Base URL';
            DataClassification = SystemMetadata;
            
            ToolTip = 'L''URL de base de votre service Node.js externe.';
        }
        field(20; "Client ID"; Text[100])
        {
            Caption = 'Client ID (OAuth)';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'L''identifiant client que votre service externe attend.';
        }
        field(30; "Client Secret"; Text[100])
        {
            Caption = 'Client Secret (OAuth)';
            DataClassification = EndUserIdentifiableInformation;
            // IMPORTANT: Dans une vraie application, ce champ devrait être sécurisé
        }
        field(40; "Last Token"; Text[2048])
        {
            Caption = 'Last Access Token';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Le dernier jeton d''accès JWT généré. Utilisé automatiquement pour les requêtes.';
        }
        field(50; "Token Expiry Time"; DateTime)
        {
            Caption = 'Token Expiry Time';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'L''heure d''expiration du dernier jeton d''accès.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    // Le code d'initialisation garantit qu'il n'y a qu'une seule ligne de configuration
    trigger OnInsert()
    begin
        if Rec."Primary Key" <> 1 then
            Error('Cette table ne peut contenir qu''un seul enregistrement de configuration.');
    end;
}