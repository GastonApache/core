Config = {}

-- Configuration générale
Config.Framework = {
    Name = "AMA Framework",
    Version = "1.0.0",
    Debug = true
}

-- Configuration du spawn
Config.Spawn = {
    -- Point de spawn par défaut pour les nouveaux joueurs
    Default = {
        coords = vector3(-1037.72, -2738.93, 20.17),
        heading = 329.39
    },
    
    -- Délai avant de sauvegarder la position (en millisecondes)
    SaveDelay = 30000, -- 30 secondes
    
    -- Distance minimale pour déclencher une sauvegarde
    MinDistanceToSave = 10.0,
    
    -- Activer le spawn à la dernière position
    EnableLastPosition = true
}

-- Configuration de la base de données
Config.Database = {
    TablePrefix = "ama_",
    AutoCreateTables = true
}

-- Configuration du joueur
Config.Player = {
    -- Argent de départ
    StartMoney = 5000,
    
    -- Données par défaut du joueur
    DefaultData = {
        job = "unemployed",
        job_grade = 0,
        group = "user",
        inventory = {}
    }
}

-- Messages système
Config.Messages = {
    WelcomeBack = "Bienvenue de retour sur le serveur !",
    FirstConnection = "Bienvenue sur le serveur pour la première fois !",
    PositionSaved = "Position sauvegardée avec succès",
    ErrorLoading = "Erreur lors du chargement de vos données"
}

-- Configuration des logs
Config.Logs = {
    EnableConsole = true,
    EnableFile = false,
    LogLevel = "INFO" -- DEBUG, INFO, WARN, ERROR
}