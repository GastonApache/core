# 📖 Guide Complet du Framework AMA

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Installation détaillée](#installation-détaillée)
4. [Configuration](#configuration)
5. [Structure des fichiers](#structure-des-fichiers)
6. [Système de modules](#système-de-modules)
7. [Hooks et événements](#hooks-et-événements)
8. [Optimisations](#optimisations)

---

## Vue d'ensemble

### 🎯 Qu'est-ce que le Framework AMA ?

AMA Framework est un framework moderne et optimisé pour FiveM, conçu pour offrir une base solide pour la création de serveurs roleplay. Inspiré d'ESX mais complètement réécrit, il apporte des améliorations significatives en termes de :

- **Performance** : Optimisé pour réduire la charge serveur
- **Flexibilité** : Système de modules et hooks extensibles
- **Fonctionnalités** : Jobs, crews, AMACoin (crypto-monnaie), Discord logging
- **Maintenance** : Code propre et bien documenté

### ✨ Fonctionnalités principales

#### Gestion des joueurs
- Spawn automatique à la dernière position
- Sauvegarde automatique des données
- UUID unique pour chaque joueur
- Système de groupes (user, admin)

#### Système économique
- **Argent liquide** : Pour les transactions courantes
- **Compte bancaire** : Pour l'épargne
- **AMACoin** : Crypto-monnaie intégrée (Bitcoin)
- Historique complet des transactions

#### Système de jobs
- Métiers légaux avec grades
- Salaires configurables
- Permissions par grade
- Système de whitelist

#### Système de crews
- Organisations illégales
- Grades et permissions
- Coffre partagé
- Logs des actions

#### Intégration Discord
- Logs de connexion/déconnexion
- Backup automatique des données
- Logs de transactions
- Logs de changements de jobs
- Embeds personnalisables

### 🔧 Technologies utilisées

- **Lua 5.4** : Langage de script moderne
- **oxmysql** : Bibliothèque MySQL performante
- **FiveM Build 2545+** : Compatibilité garantie

---

## Architecture

### 📊 Schéma de l'architecture

```
┌─────────────────────────────────────────────────────────┐
│                    FIVEM SERVER                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐          ┌──────────────┐            │
│  │   CLIENT    │◄────────►│   SERVEUR    │            │
│  │             │          │              │            │
│  │ • Spawn     │          │ • Players    │            │
│  │ • Events    │          │ • Jobs       │            │
│  │ • UI        │          │ • Crews      │            │
│  │ • Add-ons   │          │ • Bitcoin    │            │
│  └─────────────┘          │ • Commands   │            │
│        │                  │ • Discord    │            │
│        │                  └──────────────┘            │
│        │                         │                     │
│        │                         ▼                     │
│        │                  ┌──────────────┐            │
│        └─────────────────►│   SHARED     │            │
│                           │              │            │
│                           │ • Config     │            │
│                           │ • Functions  │            │
│                           │ • Discord    │            │
│                           └──────────────┘            │
│                                  │                     │
└──────────────────────────────────┼─────────────────────┘
                                   ▼
                          ┌──────────────┐
                          │   OXMYSQL    │
                          └──────────────┘
                                   │
                                   ▼
                          ┌──────────────┐
                          │   DATABASE   │
                          │              │
                          │ • Players    │
                          │ • Jobs       │
                          │ • Crews      │
                          │ • Vehicles   │
                          │ • Bitcoin    │
                          └──────────────┘
```

### 🔄 Flux de données

#### 1. Connexion d'un joueur

```
Joueur se connecte
    │
    ├─► Serveur détecte la connexion
    │
    ├─► Récupération de l'identifier
    │
    ├─► Recherche dans la base de données
    │   │
    │   ├─► Joueur existant : Chargement des données
    │   └─► Nouveau joueur : Création + UUID
    │
    ├─► Création de l'objet Player
    │
    ├─► Envoi des données au client
    │
    ├─► Client spawn le joueur
    │
    └─► Log Discord de la connexion
```

#### 2. Transaction d'argent

```
xPlayer:addMoney(amount)
    │
    ├─► Mise à jour self.money
    │
    ├─► Événement client 'ama:updateMoney'
    │
    ├─► Hook 'ama:hook:moneyChanged'
    │
    ├─► Log Discord (si activé)
    │
    └─► Sauvegarde dans la base de données
```

### 📁 Organisation du code

#### Côté serveur (`server/`)

- **ama_player.lua** : Classe Player et gestion des joueurs
- **ama_bitcoin.lua** : Système de crypto-monnaie
- **ama_crew.lua** : Système de crews/organisations
- **ama_discord.lua** : Intégration Discord
- **command.lua** : Commandes administrateur
- **ama_done.lua** : Fonctions principales

#### Côté client (`client/`)

- **ama_add.lua** : Fonctions additionnelles
- **event.lua** : Gestion des événements
- **spwan.lua** : Système de spawn

#### Partagé (`shared/`)

- **functions.lua** : Fonctions utilitaires
- **ama_discord.lua** : Configuration Discord
- **ama_run.lua** : Fonctions communes
- **serialization.lua** : Système de sérialisation

---

## Installation détaillée

### 📋 Prérequis

Avant de commencer, assurez-vous d'avoir :

- ✅ Un serveur FiveM fonctionnel (Build 2545+)
- ✅ Une base de données MySQL/MariaDB
- ✅ Accès SSH ou FTP au serveur
- ✅ oxmysql installé
- ✅ Connaissances de base en Lua (recommandé)

### 🚀 Étapes d'installation

#### Étape 1 : Téléchargement

```bash
cd /path/to/your/fivem/resources
git clone [votre-repo] framework
```

Ou téléchargez le ZIP et extrayez-le dans `resources/framework`.

#### Étape 2 : Configuration de la base de données

**IMPORTANT** : Cette étape est obligatoire !

##### Via phpMyAdmin

1. Ouvrez phpMyAdmin
2. Sélectionnez votre base de données FiveM
3. Cliquez sur "Importer"
4. Sélectionnez `framework/sql/framework.sql`
5. Cliquez sur "Exécuter"

##### Via ligne de commande

```bash
mysql -u votre_utilisateur -p votre_base < framework/sql/framework.sql
```

##### Vérification

Exécutez cette requête pour vérifier :

```sql
SHOW TABLES LIKE 'ama_%';
```

Vous devriez voir **8 tables** :
- ama_players
- ama_jobs
- ama_job_grades
- ama_crews
- ama_vehicles
- ama_transactions
- ama_bitcoin_transactions
- ama_crew_logs

#### Étape 3 : Configuration oxmysql

Éditez votre `server.cfg` :

```cfg
# Configuration MySQL
set mysql_connection_string "mysql://utilisateur:motdepasse@localhost/nombase?charset=utf8mb4"

# OU avec variables séparées
set mysql_user "utilisateur"
set mysql_password "motdepasse"
set mysql_database "nombase"
set mysql_host "localhost"
set mysql_port 3306
```

**Remplacez** :
- `utilisateur` : votre utilisateur MySQL
- `motdepasse` : votre mot de passe MySQL
- `nombase` : nom de votre base de données

#### Étape 4 : Ajout au server.cfg

```cfg
# Dépendances (AVANT le framework)
ensure oxmysql

# Framework AMA
ensure framework
```

**⚠️ ORDRE IMPORTANT** : oxmysql doit être démarré AVANT framework !

#### Étape 5 : Configuration du framework

Éditez les fichiers de configuration selon vos besoins.

##### Configuration de base (`shared/config.lua`)

Créez ou éditez ce fichier :

```lua
Config = {}

-- Framework
Config.Framework = {
    Debug = false,  -- Mode debug
    Locale = "fr"
}

-- Spawn
Config.Spawn = {
    Default = {
        coords = vector3(-1037.72, -2738.93, 20.17),
        heading = 329.39
    },
    SaveDelay = 30000,  -- 30 secondes
    MinDistanceToSave = 10.0,  -- 10 mètres
    EnableLastPosition = true
}

-- Joueurs
Config.Player = {
    StartMoney = 5000,
    StartBank = 0,
    StartBitcoin = 0,
    DefaultData = {
        job = "unemployed",
        job_grade = 0,
        crew = "none",
        crew_grade = 0,
        group = "user"
    }
}

-- AMACoin (Bitcoin)
Config.AMACoin = {
    Enabled = true,
    Name = "AMACoin",
    Symbol = "₿",
    ExchangeRate = 100,  -- 1 ₿ = $100
    TransactionFee = 2.5,  -- 2.5%
    MinTransaction = 0.01,
    MaxPerPlayer = 1000
}

-- Crews
Config.Crews = {
    Enabled = true,
    Available = {
        {name = "mafia", label = "La Mafia", color = "#FF0000"},
        {name = "cartel", label = "Le Cartel", color = "#FF8C00"},
        {name = "yakuza", label = "Yakuza", color = "#9B59B6"}
    },
    Grades = {
        {grade = 0, name = "recrue", salary = 500},
        {grade = 1, name = "membre", salary = 1000},
        {grade = 2, name = "lieutenant", salary = 1500},
        {grade = 3, name = "boss", salary = 2500}
    },
    Permissions = {
        [0] = {},
        [1] = {"access_stash"},
        [2] = {"access_stash", "manage_money"},
        [3] = {"access_stash", "manage_money", "promote", "kick"}
    }
}

-- Messages
Config.Messages = {
    WelcomeBack = "Bon retour !",
    FirstConnection = "Bienvenue sur le serveur !",
    PositionSaved = "Position sauvegardée",
    NotEnoughMoney = "Vous n'avez pas assez d'argent"
}
```

##### Configuration Discord (`shared/discord_config.lua`)

```lua
Config.Discord = {
    Enabled = true,  -- Mettre false pour désactiver
    
    -- Nom et avatar du bot
    BotName = "AMA Framework",
    BotAvatar = "https://i.imgur.com/votre-image.png",
    
    -- Webhooks Discord
    Webhooks = {
        Connection = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        Disconnection = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        PlayerData = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        Transactions = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        JobChanges = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN"
    },
    
    -- Paramètres
    Settings = {
        SendFullDataOnConnect = true,
        SendOnlyTimeOnDisconnect = true,
        IncludePosition = true,
        IncludeInventory = false,
        IncludeIdentifiers = true,
        DateFormat = "%d/%m/%Y %H:%M:%S"
    },
    
    -- Couleurs des embeds (décimal)
    Colors = {
        Connection = 3066993,      -- Vert
        Disconnection = 15158332,  -- Rouge
        PlayerData = 3447003,      -- Bleu
        Transaction = 15844367,    -- Or
        JobChange = 10181046       -- Violet
    },
    
    -- Rate limiting
    RateLimit = {
        Delay = 1000,      -- 1 seconde
        MaxRetries = 3
    }
}
```

#### Étape 6 : Premier démarrage

1. Sauvegardez tous les fichiers
2. Démarrez votre serveur FiveM
3. Regardez les logs dans la console

**✅ Messages de succès attendus :**

```
[AMA Framework] Système de sérialisation chargé
[AMA Framework] Système de logs Discord chargé
[AMA Framework] Système de Crews chargé
[AMA Framework] Système AMACoin chargé
[AMA Framework] Framework AMA chargé avec succès
```

**❌ Si vous voyez des erreurs :**

- `TABLES NON TROUVÉES` → Importez le fichier SQL
- `Can't connect to MySQL` → Vérifiez la configuration MySQL
- `oxmysql not found` → Assurez-vous qu'oxmysql est démarré avant

#### Étape 7 : Création d'un compte admin

Connectez-vous au serveur, puis exécutez dans la base de données :

```sql
UPDATE ama_players 
SET `group` = 'admin' 
WHERE identifier = 'license:VOTRE_LICENSE_ID';
```

Pour trouver votre license ID, regardez dans les logs serveur ou :

```sql
SELECT identifier, firstname, lastname 
FROM ama_players 
ORDER BY id DESC 
LIMIT 5;
```

### 🎨 Personnalisation post-installation

#### Modifier le point de spawn

```lua
Config.Spawn.Default = {
    coords = vector3(X, Y, Z),  -- Vos coordonnées
    heading = 0.0
}
```

Pour obtenir vos coordonnées, utilisez `/pos` en jeu.

#### Ajouter des métiers personnalisés

```sql
-- Ajouter le métier
INSERT INTO ama_jobs (name, label, whitelisted) VALUES
('votre_metier', 'Votre Métier', 0);

-- Ajouter les grades
INSERT INTO ama_job_grades (job_name, grade, name, label, salary) VALUES
('votre_metier', 0, 'debutant', 'Débutant', 500),
('votre_metier', 1, 'experimente', 'Expérimenté', 1000),
('votre_metier', 2, 'expert', 'Expert', 1500);
```

#### Ajouter des crews personnalisés

```sql
INSERT INTO ama_crews (name, label, color, bank) VALUES
('votre_crew', 'Votre Crew', '#FF5733', 10000);
```

Puis ajoutez dans `Config.Crews.Available` :

```lua
{name = "votre_crew", label = "Votre Crew", color = "#FF5733"}
```

---

## Configuration

### ⚙️ Options de configuration avancées

#### Sauvegarde automatique

```lua
Config.Spawn = {
    SaveDelay = 30000,  -- Délai en millisecondes (30s)
    MinDistanceToSave = 10.0,  -- Distance minimale en mètres
    EnableLastPosition = true  -- Spawn à la dernière position
}
```

**Recommandations** :
- `SaveDelay` : 30000 (30s) pour équilibrer performance/sécurité
- `MinDistanceToSave` : 10.0 pour éviter les sauvegardes inutiles
- `EnableLastPosition` : true pour le confort des joueurs

#### Économie

```lua
Config.Player = {
    StartMoney = 5000,    -- Argent de départ
    StartBank = 0,        -- Banque de départ
    StartBitcoin = 0      -- AMACoin de départ
}

Config.AMACoin = {
    ExchangeRate = 100,       -- 1 ₿ = $100
    TransactionFee = 2.5,     -- 2.5% de frais
    MinTransaction = 0.01,    -- Minimum 0.01 ₿
    MaxPerPlayer = 1000       -- Maximum 1000 ₿ par joueur
}
```

**Conseils d'équilibrage** :
- Argent de départ : 5000-10000 pour permettre des premiers achats
- Taux de change : 100-500 selon votre économie
- Frais : 2-5% pour limiter les abus
- Maximum : 1000-10000 selon la taille du serveur

#### Crews

```lua
Config.Crews = {
    Enabled = true,  -- Activer/désactiver les crews
    
    -- Liste des crews disponibles
    Available = {
        {
            name = "mafia",
            label = "La Mafia",
            color = "#FF0000",
            salary_multiplier = 1.2  -- +20% de salaire
        }
    },
    
    -- Permissions par grade
    Permissions = {
        [0] = {},  -- Recrue : aucune permission
        [1] = {"access_stash"},  -- Membre : accès au coffre
        [2] = {"access_stash", "manage_money"},  -- Lieutenant
        [3] = {"access_stash", "manage_money", "promote", "kick"}  -- Boss
    }
}
```

#### Discord

Pour activer les logs Discord, configurez les webhooks dans `shared/discord_config.lua` :

```lua
Config.Discord = {
    Enabled = true,
    
    Webhooks = {
        Connection = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        Disconnection = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        PlayerData = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        Transactions = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        JobChanges = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN"
    },
    
    Settings = {
        SendFullDataOnConnect = true,
        IncludePosition = true,
        IncludeInventory = false,
        IncludeIdentifiers = true
    }
}
```

Pour créer un webhook Discord :
1. Clic droit sur un salon Discord → Modifier le salon
2. Intégrations → Webhooks → Créer un webhook
3. Copier l'URL du webhook
4. Remplacer "VOTRE_ID/VOTRE_TOKEN" dans la configuration

---

## Structure des fichiers

### 📂 Arborescence complète

```
framework/
├── fxmanifest.lua                    # Manifest principal
├── sql/
│   └── framework.sql                 # Script SQL d'installation
├── readme/
│   ├── readme.md                     # Documentation générale
│   ├── database.md                   # Documentation BDD
│   └── red.md                        # Notes
├── shared/                           # Scripts partagés
│   ├── functions.lua                 # Fonctions utilitaires
│   ├── ama_discord.lua              # Config Discord
│   ├── ama_run.lua                  # Fonctions communes
│   └── serialization.lua            # Système de sérialisation
├── server/                          # Scripts serveur
│   ├── ama_player.lua              # Gestion des joueurs
│   ├── ama_bitcoin.lua             # Système AMACoin
│   ├── ama_crew.lua                # Système de crews
│   ├── ama_discord.lua             # Logs Discord
│   ├── ama_done.lua                # Fonctions principales
│   └── command.lua                 # Commandes
├── client/                          # Scripts client
│   ├── ama_add.lua                 # Fonctions additionnelles
│   ├── event.lua                   # Événements
│   └── spwan.lua                   # Système de spawn
├── modules/                         # Modules optionnels
│   └── (vos modules personnalisés)
└── version/                         # Versions alternatives
    └── (fichiers de versions)
```

### 📄 Description des fichiers principaux

#### `fxmanifest.lua`

Fichier de configuration du resource FiveM.

```lua
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
    'shared/functions.lua',
    'shared/ama_discord.lua',
    'shared/ama_run.lua',
    'shared/serialization.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/ama_done.lua',
    'server/ama_player.lua',
    'server/ama_discord.lua',
    'server/ama_crew.lua',
    'server/ama_bitcoin.lua',
    'server/command.lua'
}

client_scripts {
    'client/ama_add.lua',
    'client/event.lua',
    'client/spwan.lua'
}

dependencies {
    'oxmysql'
}
```

**Note** : Les fichiers dans `version/` ne sont PAS chargés par défaut.

#### `server/ama_player.lua`

Contient la classe `Player` et toutes les méthodes de gestion des joueurs.

**Fonctions principales** :
- `Player:new()` - Constructeur
- `Player:addMoney()` - Ajouter de l'argent
- `Player:removeMoney()` - Retirer de l'argent
- `Player:setJob()` - Changer de job
- `Player:setCrew()` - Rejoindre un crew
- `AMA.LoadPlayer()` - Charger un joueur
- `AMA.SavePlayer()` - Sauvegarder un joueur

#### `server/ama_bitcoin.lua`

Système de crypto-monnaie AMACoin.

**Fonctions principales** :
- `AMA.Bitcoin.SendCoins()` - Envoyer des AMACoins
- `AMA.Bitcoin.GetTransactionHistory()` - Historique
- `AMA.Bitcoin.GetExchangeRate()` - Taux de change

#### `server/ama_crew.lua`

Gestion des crews/organisations.

**Fonctions principales** :
- `AMA.Crews.GetCrewMembers()` - Obtenir les membres
- `AMA.Crews.GetCrewBank()` - Obtenir le coffre
- `AMA.Crews.AddCrewBank()` - Ajouter au coffre
- `AMA.Crews.RemoveCrewBank()` - Retirer du coffre

#### `client/spwan.lua`

Gestion du spawn des joueurs.

#### `client/event.lua`

Événements client (argent, job, notifications, etc.).

---

## Système de modules

### 🔌 Créer un module personnalisé

Le framework AMA supporte un système de modules pour étendre ses fonctionnalités sans modifier le code core.

#### Structure de base

Créez `modules/mon_module.lua` :

```lua
local MonModule = {
    name = "Mon Module",
    version = "1.0.0",
    author = "Votre Nom"
}

-- Initialisation
function MonModule.Init()
    print("^2[Mon Module]^7 Chargé !")
    
    if IsDuplicityVersion() then
        MonModule.InitServer()
    else
        MonModule.InitClient()
    end
end

-- Initialisation serveur
function MonModule.InitServer()
    RegisterNetEvent('mon_module:event')
    AddEventHandler('mon_module:event', function()
        -- Votre code serveur
    end)
end

-- Initialisation client
function MonModule.InitClient()
    -- Votre code client
end

-- Vos fonctions
function MonModule.MaFonction(param)
    return "Résultat: " .. param
end

-- Enregistrer le module
if AMA and AMA.RegisterModule then
    AMA.RegisterModule("mon_module", MonModule)
end

return MonModule
```

#### Charger le module

Ajoutez dans `fxmanifest.lua` :

```lua
shared_scripts {
    'shared/functions.lua',
    'shared/serialization.lua',
    'modules/mon_module.lua'  -- ← Votre module
}
```

#### Utiliser le module

```lua
-- Récupérer le module
local monModule = AMA.GetModule("mon_module")

-- Utiliser ses fonctions
local result = monModule.MaFonction("test")
print(result)  -- "Résultat: test"
```

---

## Hooks et événements

### 🪝 Système de hooks

Les hooks permettent d'exécuter du code à des moments précis sans modifier le core.

#### Hooks disponibles

##### Serveur

```lua
-- Connexion
AMA.RegisterHook("ama:hook:playerConnected", function(source, identifier)
    print("Connexion:", identifier)
end)

-- Déconnexion
AMA.RegisterHook("ama:hook:playerDisconnected", function(source, xPlayer)
    print("Déconnexion:", xPlayer.name)
end)

-- Données chargées
AMA.RegisterHook("ama:hook:playerDataLoaded", function(source, xPlayer)
    print("Données chargées:", xPlayer.name)
end)

-- Changement d'argent
AMA.RegisterHook("ama:hook:moneyChanged", function(source, action, account, amount, reason)
    print(action, account, amount, reason)
end)

-- Changement de job
AMA.RegisterHook("ama:hook:jobChanged", function(source, oldJob, newJob, grade)
    print("Job:", oldJob, "→", newJob)
end)

-- Avant sauvegarde (peut annuler)
AMA.RegisterHook("ama:hook:beforeSave", function(source, xPlayer)
    return true  -- false pour annuler
end)
```

##### Client

```lua
-- Joueur chargé
AMA.RegisterHook("ama:hook:playerLoaded", function(playerData)
    print("Chargé:", playerData.firstname)
end)

-- Joueur spawné
AMA.RegisterHook("ama:hook:playerSpawned", function(coords, heading)
    print("Spawn:", coords)
end)

-- Argent mis à jour
AMA.RegisterHook("ama:hook:moneyUpdated", function(newMoney)
    print("Argent:", newMoney)
end)
```

#### Priorité des hooks

```lua
-- Exécuté en premier (priorité 10)
AMA.RegisterHook("ama:hook:playerLoaded", function(data)
    print("Hook 1")
end, 10)

-- Exécuté en second (priorité 50, par défaut)
AMA.RegisterHook("ama:hook:playerLoaded", function(data)
    print("Hook 2")
end)

-- Exécuté en dernier (priorité 100)
AMA.RegisterHook("ama:hook:playerLoaded", function(data)
    print("Hook 3")
end, 100)
```

---

## Optimisations

### ⚡ Optimisations intégrées

#### 1. Sauvegarde intelligente

Le framework ne sauvegarde que si nécessaire :

```lua
-- Vérifie si le joueur s'est déplacé
if #(currentPos - LastPosition) < Config.Spawn.MinDistanceToSave then
    return  -- Pas de sauvegarde
end

-- Vérifie si le joueur est en véhicule
if IsPedInAnyVehicle(ped, false) then
    return  -- Pas de sauvegarde
end
```

#### 2. Threads optimisés

```lua
-- Thread adaptatif
CreateThread(function()
    while true do
        if PlayerLoaded then
            Wait(0)  -- Actif
        else
            Wait(1000)  -- En attente
        end
    end
end)
```

#### 3. Base de données

- **Index** sur les colonnes fréquemment recherchées
- **UUID** pour les recherches rapides
- **Triggers** pour les logs automatiques
- **Vues** pour les statistiques

#### 4. Rate limiting Discord

```lua
-- Évite le spam de webhooks
if (now - lastWebhookTime[webhook]) < Config.Discord.RateLimit.Delay then
    Wait(Config.Discord.RateLimit.Delay)
end
```

### 📊 Mesurer les performances

#### Serveur

```lua
-- Dans server.cfg
set sv_fpsLimit 60
set onesync on
set sv_maxclients 32
```

#### Client

Utilisez la commande `/fps` pour afficher les FPS en jeu.

### 🔧 Conseils d'optimisation

1. **Désactivez les fonctionnalités inutilisées**
   ```lua
   Config.AMACoin.Enabled = false
   Config.Crews.Enabled = false
   Config.Discord.Enabled = false
   ```

2. **Augmentez les délais de sauvegarde**
   ```lua
   Config.Spawn.SaveDelay = 60000  -- 1 minute
   ```

3. **Limitez les logs Discord**
   ```lua
   Config.Discord.Settings.IncludeInventory = false
   ```

4. **Nettoyez régulièrement la base de données**
   ```sql
   CALL cleanup_old_transactions();
   ```

---

## 📚 Documentation complémentaire

- [API Serveur](API_SERVEUR.md) - Documentation complète de l'API serveur
- [API Client](API_CLIENT.md) - Documentation complète de l'API client
- [Commandes](COMMANDES.md) - Liste de toutes les commandes
- [Exemples de code](EXEMPLES_CODE.md) - Exemples pratiques
- [Troubleshooting](TROUBLESHOOTING.md) - Résolution de problèmes
- [Base de données](BASE_DONNEES.md) - Structure de la BDD
- [FAQ](FOIRE_AUX_QUESTIONS.md) - Questions fréquentes

---

## 🆘 Support

Pour toute question ou problème :

1. Consultez la [FAQ](FOIRE_AUX_QUESTIONS.md)
2. Vérifiez le [Troubleshooting](TROUBLESHOOTING.md)
3. Activez le mode debug : `Config.Framework.Debug = true`
4. Contactez le support sur Discord

---

**Version** : 1.0.0  
**Auteur** : AMA Framework Team  
**Dernière mise à jour** : Décembre 2025
