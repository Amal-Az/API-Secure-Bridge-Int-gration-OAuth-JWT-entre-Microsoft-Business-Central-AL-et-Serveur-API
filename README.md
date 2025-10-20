API Secure Bridge : Intégration Business Central $\rightarrow$ Serveur APIModule d'Ingestion Sécurisée de Transactions

Un module d'extension (AL) pour Microsoft Dynamics 365 Business Central, conçu pour extraire les données de transaction (Factures Enregistrées) et les envoyer de manière sécurisée et authentifiée à un Serveur API Externe tiers pour traitement et analyse spécialisés

Fonctionnalités Clés

Sécurité OAuth/JWT : Mise en œuvre complète d'un workflow OAuth 2.0 (Client Credentials Flow simplifié) pour obtenir un jeton d'accès JWT temporaire avant chaque envoi de données.
Transfert de Données Fiable : Envoi des données par requête HTTP POST, garantissant la fiabilité et l'intégrité des informations.
Orchestration Modulaire (AL) : La logique est séparée en trois Codeunits (Gestion API, Préparation des Données, Processus Global), facilitant la maintenance et la mise à jour.
Point d'Entrée Utilisateur : Ajout d'un bouton d'action "Send to Bank API" sur la page des Factures Client Enregistrées, offrant un déclenchement manuel et contrôlé du processus.
Configuration Centralisée : Tous les paramètres de connexion (URL de base, Client ID, Client Secret) sont stockés dans une table de configuration unique et consultables via une page de setup dédiée.

Architecture de l'Intégration

Business Central (Client AL)
Le rôle de l'extension AL est de préparer la requête et d'assurer la sécurité:
1. Extraction et Transformation : Le Codeunit Bank Ext Data Prep (50101) extrait les données de la table de base (Facture Enregistrée) et les formate en un tableau JSON précis.
2. Sécurité : Le Codeunit Bank Ext API Mgt (50100) vérifie l'expiration du Jeton. S'il est expiré, il effectue une première requête /auth/token pour obtenir un nouveau JWT.
3. Envoi : Le Codeunit 50100 effectue la requête finale /transactions/ingest en incluant le JWT valide dans l'en-tête Authorization: Bearer ....

Serveur API (Node.js/TypeScript)

Le Serveur API assure la validation et la persistance des données :
1. Authentification : Le endpoint /auth/token reçoit le clientId/clientSecret et émet un jeton JWT d'une heure.
2. Middleware de Protection : Un middleware valide la signature et l'expiration du JWT pour toutes les requêtes d'ingestion.
3. Ingestion : Le endpoint /transactions/ingest reçoit le tableau JSON et l'insère en lot dans une base de données externe, garantissant la non-duplication des transactions (ON CONFLICT DO NOTHING).

Tech Stack:
ERP =>	Microsoft Dynamics 365 Business Central   'Plateforme source des données'
Extension	=> AL Language
Serveur API	=> Node.js, TypeScript, Express
Sécurité =>	JSON Web Tokens (JWT)
HTTP =>	HttpClient (AL)	 (Module natif AL pour effectuer les requêtes web)

Déploiement et Configuration

1. Configuration du Serveur API
   
   - Variables d'Environnement : Définir les clés CLIENT_ID_BC, CLIENT_SECRET_BC et OAUTH_SECRET dans le fichier .env
   - Démarrage du Serveur : Lancer le serveur Node.js sur l'URL de base souhaitée (Ex: uvicorn main:app --reload ou npm start)
   
2. Déploiement Business Central
   
   - Environnement : S'assurer de l'accès à un environnement Sandbox avec une licence de développement valide
   - Compilation et Publication : Utiliser la fonctionnalité de publication simple de VS Code : Ctrl + F5.   
