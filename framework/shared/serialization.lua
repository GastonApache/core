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