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
    TablePrefix = "ama_"
}

-- Configuration du joueur
Config.Player = {
    -- Argent de départ
    StartMoney = 5000,
    StartBank = 0,
    StartBitcoin = 0,  -- AMACoins de départ
    
    -- Données par défaut du joueur
    DefaultData = {
        job = "unemployed",
        job_grade = 0,
        crew = "none",  -- Crew par défaut
        crew_grade = 0,
        group = "user",
        inventory = {}
    }
}

-- Configuration des AMACoins (Bitcoin)
Config.AMACoin = {
    -- Activer le système de crypto-monnaie
    Enabled = true,
    
    -- Nom de la crypto-monnaie
    Name = "AMACoin",
    Symbol = "₿",
    
    -- Taux de conversion (1 AMACoin = X dollars)
    ExchangeRate = 100,
    
    -- Frais de transaction (%)
    TransactionFee = 2.5,
    
    -- Limites
    MaxPerPlayer = 1000000,
    MinTransaction = 1,
    
    -- Wallet UUID
    GenerateWalletUUID = true
}

-- Configuration des Crews (organisations illégales)
Config.Crews = {
    -- Activer le système de crews
    Enabled = true,
    
    -- Crews disponibles
    Available = {
        {
            name = "none",
            label = "Aucun Crew",
            color = "#95a5a6"
        },
        {
            name = "mafia",
            label = "La Mafia",
            color = "#e74c3c",
            salary_multiplier = 1.5
        },
        {
            name = "cartel",
            label = "Le Cartel",
            color = "#f39c12",
            salary_multiplier = 1.5
        },
        {
            name = "yakuza",
            label = "Yakuza",
            color = "#8e44ad",
            salary_multiplier = 1.5
        },
        {
            name = "gang_street",
            label = "Gang des Rues",
            color = "#27ae60",
            salary_multiplier = 1.3
        },
        {
            name = "bikers",
            label = "Club de Motards",
            color = "#34495e",
            salary_multiplier = 1.3
        }
    },
    
    -- Grades des crews
    Grades = {
        {grade = 0, name = "recrue", label = "Recrue", salary = 500},
        {grade = 1, name = "membre", label = "Membre", salary = 1000},
        {grade = 2, name = "lieutenant", label = "Lieutenant", salary = 1500},
        {grade = 3, name = "sous_boss", label = "Sous-Boss", salary = 2500},
        {grade = 4, name = "boss", label = "Boss", salary = 5000}
    },
    
    -- Permissions par grade
    Permissions = {
        [0] = {"access_hideout"},
        [1] = {"access_hideout", "use_vehicles"},
        [2] = {"access_hideout", "use_vehicles", "recruit"},
        [3] = {"access_hideout", "use_vehicles", "recruit", "manage_money"},
        [4] = {"access_hideout", "use_vehicles", "recruit", "manage_money", "kick", "promote"}
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