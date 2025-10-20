codeunit 50100 "Bank Ext API Mgt"
{
    Access = Public; 

    var
        Config: Record "Bank Ext API Config";
        HttpClient: HttpClient;

    // =========================================================================
    // FONCTION 1 : GESTION DU JETON D'ACCÈS (OAuth)
    // =========================================================================

    /// <summary>
    /// Récupère un jeton d'accès JWT valide.
    /// Si le jeton est expiré, une nouvelle requête est envoyée à l'API externe.
    /// </summary>
    /// <returns>Le jeton d'accès (Bearer Token) si la connexion réussit.</returns>
    procedure GetAccessToken(): Text
    var
        TokenExpiryTimeUtc: DateTime;
    begin
        // 1. Récupérer la configuration unique
        if not Config.Get(1) then
            Error('La configuration de l''API externe est manquante.');

        // 2. Vérification de l'expiration du jeton existant
        TokenExpiryTimeUtc := GetUTCDateTime(Config."Token Expiry Time");

        // Le jeton est considéré comme expiré si le temps UTC actuel est supérieur
        // à l'heure d'expiration du jeton, moins une petite marge de sécurité (5 minutes).
        if (Config."Last Token" = '') or (CurrentDateTime() > TokenExpiryTimeUtc - 300000) then begin // 300000 ms = 5 min
            // Le jeton est manquant ou expiré, on demande un nouveau jeton
            if not RequestNewToken(Config) then
                Error('Échec de la récupération du jeton d''accès.');
        end;

        // 3. Retourner le jeton valide
        exit(Config."Last Token");
    end;

    local procedure RequestNewToken(var Config: Record "Bank Ext API Config"): Boolean
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestUrl: Text;
        ContentText: Text; // Pour le corps de la requête JSON
        ContentMessage: HttpContent; // Pour écrire le contenu dans la requête HTTP
        JObject: JsonObject;
        JToken: JsonToken;
        TokenText: Text;
        ExpirySeconds: Integer;
        ExpiryTime: DateTime;
    begin
        // Construction de l'URL du point d'accès du jeton
        RequestUrl := Config."API Base URL" + '/auth/token';

        // 1. Préparation du corps de la requête (JSON)
        JObject.Add('clientId', Config."Client ID");
        JObject.Add('clientSecret', Config."Client Secret");
        JObject.WriteTo(ContentText);

        // 2. Configuration de la requête
        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(RequestUrl);

        RequestMessage.Headers.Add('Content-Type', 'application/json');

        // Utiliser ContentMessage pour écrire dans le contenu
        ContentMessage.WriteString(ContentText);
        RequestMessage.Content := ContentMessage;

        // 3. Envoi de la requête
        if not HttpClient.Send(RequestMessage, ResponseMessage) then begin
            Message('Erreur de communication : Impossible d''envoyer la requête au service externe.');
            exit(false);
        end;

        // 4. Traitement de la réponse
        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content().ReadAs(ContentText);
            Message('Erreur d''authentification (%1) : %2', ResponseMessage.HttpStatusCode(), ContentText);
            exit(false);
        end;

        // 5. Lecture et stockage du jeton
        ResponseMessage.Content().ReadAs(ContentText);
        if not JObject.ReadFrom(ContentText) then
            Error('La réponse du jeton n''est pas un JSON valide.');

        if JObject.Get('access_token', JToken) then
            
            TokenText := JToken.AsValue().AsText();

        if JObject.Get('expires_in', JToken) then
            
            ExpirySeconds := JToken.AsValue().AsInteger();

        // Calcul de l'expiration: CurrentDateTime + secondes d'expiration
        ExpiryTime := CurrentDateTime() + (ExpirySeconds * 1000); // ExpirySeconds est en secondes, CurrentDateTime est en ms

        // Stockage des résultats
        Config."Last Token" := TokenText;
        Config."Token Expiry Time" := ExpiryTime;
        Config.Modify(true);

        exit(true);
    end;

    // =========================================================================
    // FONCTION 2 : ENVOI SÉCURISÉ DES TRANSACTIONS
    // =========================================================================

    /// <summary>
    /// Envoie un tableau de transactions brutes au service externe.
    /// </summary>
    /// <param name="JsonTransactions">Un JsonArray contenant les transactions à envoyer.</param>
    /// <returns>True si l'ingestion a réussi, False sinon.</returns>
    procedure PostTransactions(JsonTransactions: JsonArray): Boolean
    var
        AccessToken: Text;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestUrl: Text;
        ContentText: Text; 
        ContentMessage: HttpContent; 
        JObject: JsonObject;
    begin
        // 1. Obtenir un jeton valide (gère le rafraîchissement si nécessaire)
        AccessToken := GetAccessToken();

        // 2. Construction de l'URL de la route d'ingestion
        RequestUrl := Config."API Base URL" + '/transactions/ingest';

        // 3. Préparation du corps de la requête (encapsuler l'array dans un objet 'transactions')
        JObject.Add('transactions', JsonTransactions);
        JObject.WriteTo(ContentText);

        // 4. Configuration de la requête sécurisée
        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(RequestUrl);

        RequestMessage.Headers.Add('Content-Type', 'application/json');

        // Ajout du jeton d'accès (Sécurité Bearer)
        RequestMessage.Headers.Add('Authorization', StrSubstNo('Bearer %1', AccessToken));

        //  Utiliser ContentMessage pour écrire dans le contenu
        ContentMessage.WriteString(ContentText);
        RequestMessage.Content := ContentMessage;


        // 5. Envoi de la requête
        if not HttpClient.Send(RequestMessage, ResponseMessage) then begin
            Message('Erreur de communication : Impossible d''envoyer les transactions au service externe.');
            exit(false);
        end;

        // 6. Traitement de la réponse
        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content().ReadAs(ContentText);
            Message('Échec de l''ingestion des transactions (%1) : %2', ResponseMessage.HttpStatusCode(), ContentText);
            exit(false);
        end;

        // 7. Succès
        ResponseMessage.Content().ReadAs(ContentText); // Lire la réponse JSON 
        Message('Transactions envoyées avec succès. Réponse du service: %1', ContentText);
        exit(true);
    end;

    // =========================================================================
    // FONCTIONS UTILITAIRES
    // =========================================================================

    local procedure GetUTCDateTime(InputDateTime: DateTime): DateTime
    begin
        // Convertit l'heure locale stockée en UTC, car les jetons sont souvent basés sur l'heure du serveur.
        // Puisque nous faisons le calcul d'expiration directement en CurrentDateTime() (qui est locale), 
        // nous supposons que l'heure locale de BC est proche de l'heure du serveur Node.js.
        // NOTE: Une gestion plus précise nécessiterait une conversion vers un fuseau horaire explicite.
        exit(InputDateTime);
    end;
}