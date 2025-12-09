-- =====================================================
-- CONFIGURATION PRINCIPALE DU FRAMEWORK AMA
-- =====================================================

Config = {}

-- =====================================================
-- CONFIGURATION DES LOGS
-- =====================================================
Config.Logs = {
    -- Activer les logs dans la console
    EnableConsole = true,
    
    -- Niveau de log minimum (DEBUG, INFO, WARN, ERROR)
    MinLevel = "INFO",
    
    -- Activer les logs détaillés
    Verbose = false
}

-- =====================================================
-- CONFIGURATION JOUEUR
-- =====================================================
Config.Player = {
    -- Argent de départ
    StartMoney = 5000,
    StartBank = 0,
    StartBitcoin = 0,
    
    -- Sauvegarder automatiquement la position
    SavePosition = true,
    
    -- Intervalle de sauvegarde automatique (en millisecondes)
    -- 300000 = 5 minutes
    AutoSaveInterval = 300000,
    
    -- Identifiants prioritaires (dans l'ordre)
    IdentifierPriority = {
        "license",
        "steam",
        "discord",
        "fivem"
    }
}

-- =====================================================
-- CONFIGURATION BASE DE DONNÉES
-- =====================================================
Config.Database = {
    -- Nom de la base de données
    -- IMPORTANT: Créez la base de données "framework" avant de démarrer le serveur
    -- Utilisez le fichier sql/framework.sql pour créer les tables
    Name = "framework",
    
    -- Timeout pour les requêtes (millisecondes)
    Timeout = 5000,
    
    -- Debug des requêtes SQL
    Debug = false
}

-- =====================================================
-- CONFIGURATION SPAWN
-- =====================================================
Config.Spawn = {
    -- Activer le spawn à la dernière position
    EnableLastPosition = true,
    
    -- Position de spawn par défaut
    Default = {
        coords = vector3(-269.4, -955.3, 31.2),
        heading = 206.0
    },
    
    -- Positions de spawn alternatives
    Alternatives = {
        -- Aéroport
        {
            label = "Aéroport de Los Santos",
            coords = vector3(-1042.0, -2745.8, 21.3),
            heading = 329.0
        },
        -- Plage
        {
            label = "Plage de Vespucci",
            coords = vector3(-1393.4, -588.4, 30.3),
            heading = 33.0
        }
    },
    
    -- Position de respawn (hôpital)
    Hospital = {
        coords = vector3(299.58, -584.76, 43.26),
        heading = 82.14
    },
    
    -- Délai avant respawn après la mort (millisecondes)
    RespawnDelay = 5000
}

-- =====================================================
-- CONFIGURATION MESSAGES
-- =====================================================
Config.Messages = {
    -- Message de bienvenue (première connexion)
    FirstConnection = "~g~Bienvenue~s~ sur le serveur !",
    
    -- Message de retour
    WelcomeBack = "~b~Bon retour~s~ !",
    
    -- Messages d'erreur
    Errors = {
        NoIdentifier = "Erreur: Impossible de récupérer votre identifiant",
        DatabaseError = "Erreur de base de données",
        LoadFailed = "Impossible de charger vos données"
    }
}

-- =====================================================
-- CONFIGURATION JOBS (MÉTIERS)
-- =====================================================
Config.Jobs = {
    -- Liste des métiers disponibles
    List = {
        unemployed = {
            label = "Sans emploi",
            defaultGrade = 0
        },
        police = {
            label = "Police",
            defaultGrade = 0
        },
        ambulance = {
            label = "Ambulance",
            defaultGrade = 0
        },
        mechanic = {
            label = "Mécanicien",
            defaultGrade = 0
        }
    }
}

-- =====================================================
-- CONFIGURATION CREWS (ORGANISATIONS)
-- =====================================================
Config.Crews = {
    -- Activer le système de crews
    Enabled = true,
    
    -- Nombre maximum de membres par crew
    MaxMembers = 10,
    
    -- Prix de création d'un crew
    CreationPrice = 50000,
    
    -- Activer le système de grades
    EnableGrades = true
}

-- =====================================================
-- CONFIGURATION BITCOIN
-- =====================================================
Config.Bitcoin = {
    -- Activer le système de Bitcoin
    Enabled = true,
    
    -- Taux de change par défaut (1 BTC = X$)
    DefaultRate = 50000,
    
    -- Variation du taux (en pourcentage)
    RateVariation = 10,
    
    -- Intervalle de mise à jour du taux (millisecondes)
    -- 600000 = 10 minutes
    UpdateInterval = 600000,
    
    -- Commission sur les transactions (en pourcentage)
    TransactionFee = 2
}

-- =====================================================
-- CONFIGURATION PERMISSIONS
-- =====================================================
Config.Permissions = {
    -- Groupes et leurs permissions
    Groups = {
        user = {
            label = "Joueur",
            level = 0
        },
        helper = {
            label = "Helper",
            level = 1
        },
        moderator = {
            label = "Modérateur",
            level = 2
        },
        admin = {
            label = "Administrateur",
            level = 3
        },
        superadmin = {
            label = "Super Administrateur",
            level = 4
        }
    }
}

-- =====================================================
-- CONFIGURATION INVENTAIRE
-- =====================================================
Config.Inventory = {
    -- Nombre maximum de slots
    MaxSlots = 50,
    
    -- Poids maximum (en kg)
    MaxWeight = 100,
    
    -- Activer le drop d'items au sol
    EnableDrop = true
}

-- =====================================================
-- CONFIGURATION DÉVELOPPEMENT
-- =====================================================
Config.Dev = {
    -- Mode debug
    Debug = false,
    
    -- Afficher les coordonnées
    ShowCoords = false,
    
    -- Activer les commandes de développement
    EnableDevCommands = false
}
