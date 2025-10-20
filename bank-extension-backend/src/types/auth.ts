// Informations qui seront encodées dans le JWT (le "payload")
export interface JwtPayload {
    clientId: string;
    role: 'businessCentral' | 'admin'; // Définit le rôle de l'application cliente
    // Autres informations non sensibles, comme l'ID de l'intermédiaire
}

// Informations sur le client BC (simulées ici, dans la réalité elles viendraient d'une DB)
export interface ClientSecret {
    clientId: string;
    secret: string;
}