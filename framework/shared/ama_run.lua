-- =====================================================
-- SYSTÈME DE SÉRIALISATION POUR MODDEURS
-- =====================================================
-- Ce fichier permet aux moddeurs d'étendre le framework
-- sans modifier les fichiers core

AMA.Serialization = {}
AMA.Modules = {}
AMA.Hooks = {}

-- =====================================================
-- SYSTÈME DE MODULES
-- =====================================================

---Enregistrer un module personnalisé
---@param name string Nom du module
---@param module table Table contenant le module
function AMA.RegisterModule(name, module)
    if AMA.Modules[name] then
        AMA.Log("WARN", "Le module '" .. name .. "' existe déjà et sera écrasé")
    end
    
    AMA.Modules[name] = module
    AMA.Log("INFO", "Module enregistré: " .. name)
    
    -- Appeler l'initialisation du module si elle existe
    if module.Init and type(module.Init) == "function" then
        local success, err = pcall(module.Init)
        if not success then
            AMA.Log("ERROR", "Erreur lors de l'initialisation du module " .. name .. ": " .. err)
        end
    end
    
    return true
end

---Obtenir un module
---@param name string Nom du module
---@return table|nil
function AMA.GetModule(name)
    return AMA.Modules[name]
end

-- =====================================================
-- SYSTÈME DE HOOKS (ÉVÉNEMENTS PERSONNALISÉS)
-- =====================================================

---Enregistrer un hook
---@param hookName string Nom du hook
---@param callback function Fonction à appeler
---@param priority number Priorité (plus petit = exécuté en premier)
function AMA.RegisterHook(hookName, callback, priority)
    priority = priority or 50
    
    if not AMA.Hooks[hookName] then
        AMA.Hooks[hookName] = {}
    end
    
    table.insert(AMA.Hooks[hookName], {
        callback = callback,
        priority = priority
    })
    
    -- Trier par priorité
    table.sort(AMA.Hooks[hookName], function(a, b)
        return a.priority < b.priority
    end)
    
    AMA.Log("DEBUG", "Hook enregistré: " .. hookName .. " (priorité: " .. priority .. ")")
end

---Déclencher un hook
---@param hookName string Nom du hook
---@param ... any Arguments à passer aux callbacks
---@return any Résultat du dernier callback ou nil
function AMA.TriggerHook(hookName, ...)
    if not AMA.Hooks[hookName] then
        return nil
    end
    
    local result = nil
    local args = {...}
    
    for _, hook in ipairs(AMA.Hooks[hookName]) do
        local success, res = pcall(hook.callback, table.unpack(args))
        if success then
            result = res
            -- Si un hook retourne false, arrêter la chaîne
            if result == false then
                break
            end
        else
            AMA.Log("ERROR", "Erreur dans le hook " .. hookName .. ": " .. res)
        end
    end
    
    return result
end

-- =====================================================
-- HOOKS PRÉDÉFINIS DU FRAMEWORK
-- =====================================================

--[[
    Liste des hooks disponibles:
    
    CLIENT:
    - ama:hook:playerLoaded(playerData)           -> Quand le joueur est chargé
    - ama:hook:playerSpawned(coords, heading)     -> Quand le joueur spawn
    - ama:hook:playerDied(deathCoords)            -> Quand le joueur meurt
    - ama:hook:positionSaving(coords)             -> Avant de sauvegarder la position
    - ama:hook:moneyUpdated(newMoney)             -> Quand l'argent change
    - ama:hook:bankUpdated(newBank)               -> Quand la banque change
    - ama:hook:jobUpdated(job, grade)             -> Quand le job change
    
    SERVER:
    - ama:hook:playerConnected(source, identifier)        -> Quand un joueur se connecte
    - ama:hook:playerDisconnected(source, xPlayer)        -> Quand un joueur se déconnecte
    - ama:hook:playerDataLoaded(source, xPlayer)          -> Quand les données sont chargées
    - ama:hook:beforeSave(source, xPlayer)                -> Avant la sauvegarde
    - ama:hook:afterSave(source, xPlayer)                 -> Après la sauvegarde
    - ama:hook:moneyChanged(source, type, amount, reason) -> Quand l'argent change
]]

-- =====================================================
-- SÉRIALISATION DE DONNÉES
-- =====================================================

---Encoder des données en JSON de manière sécurisée
---@param data any Données à encoder
---@return string|nil
function AMA.Encode(data)
    local success, result = pcall(json.encode, data)
    if success then
        return result
    else
        AMA.Log("ERROR", "Erreur lors de l'encodage JSON: " .. result)
        return nil
    end
end

---Décoder des données JSON de manière sécurisée
---@param jsonString string Chaîne JSON à décoder
---@return any|nil
function AMA.Decode(jsonString)
    if not jsonString or jsonString == "" then
        return nil
    end
    
    local success, result = pcall(json.decode, jsonString)
    if success then
        return result
    else
        AMA.Log("ERROR", "Erreur lors du décodage JSON: " .. result)
        return nil
    end
end

-- =====================================================
-- SYSTÈME DE DONNÉES PERSONNALISÉES (META DATA)
-- =====================================================

AMA.PlayerMetaData = {}

---Définir une métadonnée pour un joueur (SERVEUR)
---@param source number ID du joueur
---@param key string Clé de la métadonnée
---@param value any Valeur
function AMA.SetPlayerMeta(source, key, value)
    if not AMA.PlayerMetaData[source] then
        AMA.PlayerMetaData[source] = {}
    end
    
    AMA.PlayerMetaData[source][key] = value
    
    -- Synchroniser avec le client si demandé
    if Config.Serialization and Config.Serialization.SyncMetaToClient then
        TriggerClientEvent('ama:updateMeta', source, key, value)
    end
end

---Obtenir une métadonnée d'un joueur (SERVEUR)
---@param source number ID du joueur
---@param key string Clé de la métadonnée
---@return any
function AMA.GetPlayerMeta(source, key)
    if not AMA.PlayerMetaData[source] then
        return nil
    end
    
    return AMA.PlayerMetaData[source][key]
end

---Obtenir toutes les métadonnées d'un joueur (SERVEUR)
---@param source number ID du joueur
---@return table
function AMA.GetAllPlayerMeta(source)
    return AMA.PlayerMetaData[source] or {}
end

-- =====================================================
-- SYSTÈME D'EXPORT POUR AUTRES RESSOURCES
-- =====================================================

---Exporter une fonction pour d'autres ressources
---@param name string Nom de l'export
---@param func function Fonction à exporter
function AMA.Export(name, func)
    exports(name, func)
    AMA.Log("DEBUG", "Export créé: " .. name)
end

-- =====================================================
-- UTILITAIRES POUR MODDEURS
-- =====================================================

---Vérifier si un joueur est en ligne (SERVEUR)
---@param source number ID du joueur
---@return boolean
function AMA.IsPlayerOnline(source)
    return GetPlayerPing(source) > 0
end

---Obtenir la distance entre deux coordonnées 3D
---@param coords1 vector3 Première coordonnée
---@param coords2 vector3 Deuxième coordonnée
---@return number Distance
function AMA.GetDistanceBetweenCoords(coords1, coords2)
    return #(coords1 - coords2)
end

---Obtenir les joueurs dans un rayon
---@param coords vector3 Coordonnées centrales
---@param radius number Rayon en mètres
---@return table Liste des joueurs
function AMA.GetPlayersInArea(coords, radius)
    local players = {}
    
    if IsDuplicityVersion() then
        -- Code serveur
        for _, playerId in ipairs(GetPlayers()) do
            local playerPed = GetPlayerPed(playerId)
            local playerCoords = GetEntityCoords(playerPed)
            
            if #(coords - playerCoords) <= radius then
                table.insert(players, tonumber(playerId))
            end
        end
    else
        -- Code client
        local playerPed = PlayerPedId()
        local allPlayers = GetActivePlayers()
        
        for _, player in ipairs(allPlayers) do
            local targetPed = GetPlayerPed(player)
            local targetCoords = GetEntityCoords(targetPed)
            
            if #(coords - targetCoords) <= radius then
                table.insert(players, player)
            end
        end
    end
    
    return players
end

---Générer un identifiant unique
---@return string UUID
function AMA.GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

---Copier une table en profondeur
---@param original table Table à copier
---@return table Copie de la table
function AMA.DeepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[AMA.DeepCopy(key)] = AMA.DeepCopy(value)
        end
        setmetatable(copy, AMA.DeepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

---Fusionner deux tables
---@param t1 table Première table
---@param t2 table Deuxième table
---@return table Table fusionnée
function AMA.MergeTables(t1, t2)
    local result = AMA.DeepCopy(t1)
    for k, v in pairs(t2) do
        if type(v) == 'table' and type(result[k]) == 'table' then
            result[k] = AMA.MergeTables(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- =====================================================
-- EXEMPLES D'UTILISATION POUR MODDEURS
-- =====================================================

--[[

EXEMPLE 1: Créer un module personnalisé
────────────────────────────────────────

local MyModule = {
    name = "Système de Level",
    version = "1.0.0"
}

function MyModule.Init()
    print("Module Level initialisé!")
end

function MyModule.AddXP(source, amount)
    local currentXP = AMA.GetPlayerMeta(source, "xp") or 0
    AMA.SetPlayerMeta(source, "xp", currentXP + amount)
end

AMA.RegisterModule("level_system", MyModule)

-- Utilisation:
local levelModule = AMA.GetModule("level_system")
levelModule.AddXP(source, 100)


EXEMPLE 2: Utiliser les hooks
────────────────────────────────

-- Quand un joueur se connecte, lui donner un bonus
AMA.RegisterHook("ama:hook:playerLoaded", function(playerData)
    print("Bienvenue " .. playerData.firstname .. "!")
    -- Donner 1000$ de bonus de connexion
    TriggerServerEvent('ama:giveLoginBonus', 1000)
end, 10)

-- Avant de sauvegarder, vérifier quelque chose
AMA.RegisterHook("ama:hook:beforeSave", function(source, xPlayer)
    print("Sauvegarde du joueur: " .. xPlayer.name)
    -- Faire des vérifications personnalisées
    return true -- Continuer la sauvegarde
end)


EXEMPLE 3: Métadonnées personnalisées
────────────────────────────────────────

-- Côté serveur
AMA.SetPlayerMeta(source, "premium", true)
AMA.SetPlayerMeta(source, "vip_level", 3)

local isPremium = AMA.GetPlayerMeta(source, "premium")
if isPremium then
    print("Joueur premium!")
end

-- Toutes les métadonnées
local allMeta = AMA.GetAllPlayerMeta(source)
for key, value in pairs(allMeta) do
    print(key, value)
end


EXEMPLE 4: Exports pour autres ressources
────────────────────────────────────────────

-- Dans votre resource
exports['ama_framework']:RegisterModule("mon_module", MonModule)

local xPlayer = exports['ama_framework']:GetPlayer(source)
local money = xPlayer:getMoney()

]]

-- =====================================================
-- CONFIGURATION POUR LA SÉRIALISATION
-- =====================================================

-- Ajouter ceci dans shared/config.lua si pas présent
if not Config.Serialization then
    Config.Serialization = {
        -- Synchroniser les métadonnées avec le client
        SyncMetaToClient = true,
        
        -- Activer le système de modules
        EnableModules = true,
        
        -- Activer le système de hooks
        EnableHooks = true,
        
        -- Dossier des modules personnalisés
        ModulesFolder = "modules/",
        
        -- Activer le mode debug pour la sérialisation
        Debug = false
    }
end

AMA.Log("INFO", "Système de sérialisation chargé")

# AMA Framework pour FiveM

## 📋 Description

AMA Framework est un framework moderne et optimisé pour FiveM, inspiré d'ESX mais avec des améliorations significatives en termes de fluidité et de fonctionnalités. Il gère automatiquement le spawn des joueurs, la sauvegarde de leurs positions et leurs données persistantes.

## ✨ Fonctionnalités principales

- **Spawn intelligent** : Les joueurs spawent à leur dernière position enregistrée
- **Sauvegarde automatique** : Position et données du joueur sauvegardées automatiquement
- **Système de job** : Gestion complète des métiers et grades
- **Gestion de l'argent** : Argent liquide et compte en banque
- **Optimisé** : Performance améliorée par rapport aux frameworks traditionnels
- **Base de données** : Utilise oxmysql pour une meilleure performance
- **Système de callbacks** : Communication client-serveur optimisée

## 📦 Installation

### ⚠️ IMPORTANT

**Vous DEVEZ importer le fichier `installation.sql` dans votre base de données avant de démarrer le serveur !**

### Installation rapide

1. **Importer la base de données**
   - Ouvrez phpMyAdmin
   - Sélectionnez votre base de données
   - Importez le fichier `installation.sql`
   - ✅ Vérifiez que 8 tables ont été créées

2. **Configurer oxmysql**
   ```cfg
   set mysql_connection_string "mysql://user:password@localhost/database?charset=utf8mb4"
   ```

3. **Ajouter au server.cfg**
   ```cfg
   ensure oxmysql
   ensure ama_framework
   ```

4. **Configuration** (optionnel)
   - Modifiez `shared/config.lua`
   - Configurez les webhooks Discord dans `shared/discord_config.lua`

📖 **[Guide d'installation complet](INSTALLATION.md)** - Consultez ce guide pour les instructions détaillées

## 🎮 Utilisation

### Commandes disponibles

#### Joueurs
- `/save` - Sauvegarder manuellement sa position
- `/me` - Afficher ses informations
- `/pos` - Afficher sa position actuelle
- `/fps` - Afficher/masquer les FPS

#### Administrateurs
- `/givemoney [id] [montant]` - Donner de l'argent
- `/tp [id]` - Se téléporter vers un joueur

### API Serveur

```lua
-- Obtenir un joueur
local xPlayer = AMA.GetPlayer(source)

-- Obtenir tous les joueurs
local players = AMA.GetPlayers()

-- Ajouter de l'argent
xPlayer:addMoney(amount)

-- Retirer de l'argent
if xPlayer:removeMoney(amount) then
    print("Argent retiré")
end

-- Changer de job
xPlayer:setJob('police', 2)

-- Obtenir le job
local job = xPlayer:getJob()
print(job.name, job.grade)
```

### API Client

```lua
-- Vérifier si le joueur est chargé
if AMA.IsPlayerLoaded() then
    print("Joueur chargé")
end

-- Obtenir les données du joueur
local playerData = AMA.GetPlayerData()
print(playerData.money, playerData.job)

-- Afficher une notification
AMA.ShowNotification("Message")

-- Callback serveur
AMA.TriggerServerCallback('nom_callback', function(result)
    print(result)
end, arg1, arg2)
```

## 🗂️ Structure des fichiers

```
ama_framework/
├── fxmanifest.lua
├── installation.sql
├── README.md
├── shared/
│   ├── config.lua          # Configuration principale
│   └── functions.lua       # Fonctions partagées
├── server/
│   ├── main.lua           # Initialisation serveur
│   ├── player.lua         # Gestion des joueurs
│   └── commands.lua       # Commandes serveur
└── client/
    ├── main.lua           # Initialisation client
    ├── spawn.lua          # Gestion du spawn
    └── events.lua         # Événements client
```

## ⚙️ Configuration

### Spawn par défaut
```lua
Config.Spawn = {
    Default = {
        coords = vector3(-1037.72, -2738.93, 20.17),
        heading = 329.39
    },
    SaveDelay = 30000,
    MinDistanceToSave = 10.0,
    EnableLastPosition = true
}
```

### Argent de départ
```lua
Config.Player = {
    StartMoney = 5000,
    DefaultData = {
        job = "unemployed",
        job_grade = 0,
        group = "user"
    }
}
```

## 🔧 Base de données

### Table principale : `ama_players`
- Stocke toutes les informations des joueurs
- Position automatiquement sauvegardée
- Inventaire et comptes en JSON
- Historique de connexion

### Tables des métiers
- `ama_jobs` : Liste des métiers
- `ama_job_grades` : Grades et salaires

### Autres tables
- `ama_vehicles` : Véhicules des joueurs
- `ama_transactions` : Historique des transactions

## 🚀 Optimisations

1. **Sauvegarde intelligente** : Ne sauvegarde que si le joueur sest déplacé
2. **Distance minimale** : Évite les sauvegardes inutiles
3. **Sauvegarde automatique** : Toutes les 5 minutes pour tous les joueurs
4. **Callbacks optimisés** : Communication client-serveur efficace
5. **Threads optimisés** : Utilisation de Wait() adaptatifs

## 🐛 Debug

Activez le mode debug dans `shared/config.lua` :
```lua
Config.Framework = {
    Debug = true
}
```

Les logs apparaîtront dans la console avec des couleurs :
- 🔵 INFO : Informations générales
- 🟡 WARN : Avertissements
- 🔴 ERROR : Erreurs

## 📝 Notes importantes

- Les positions sont sauvegardées automatiquement toutes les 30 secondes (configurable)
- Le joueur ne doit pas être en véhicule pour que la position soit sauvegardée
- La sauvegarde se fait uniquement si le joueur s'est déplacé d'au moins 10 mètres
- À la déconnexion, une dernière sauvegarde est effectuée automatiquement

## 🤝 Support

Pour toute question ou problème, consultez la documentation ou contactez le support.

## 📄 Licence

Ce framework est fourni tel quel. Vous êtes libre de le modifier selon vos besoins.

---

**Version** : 1.0.0  
**Auteur** : AMA Framework Team  
**Compatibilité** : FiveM Build 2545+