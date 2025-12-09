-- =====================================================
-- EXEMPLE DE MODULE PERSONNALISÉ - SYSTÈME DE LEVEL
-- =====================================================
-- Placez ce fichier dans: ama_framework/modules/exemple_level.lua

local LevelSystem = {
    name = "Système de Level",
    version = "1.0.0",
    author = "Votre Nom"
}

-- =====================================================
-- CONFIGURATION DU MODULE
-- =====================================================

LevelSystem.Config = {
    -- XP nécessaire par niveau
    XPPerLevel = 1000,
    
    -- XP bonus par niveau
    XPMultiplier = 1.5,
    
    -- Niveau maximum
    MaxLevel = 100,
    
    -- Récompenses par niveau
    Rewards = {
        money = 500,      -- Argent par niveau
        bank = 1000       -- Bonus banque tous les 5 niveaux
    },
    
    -- Actions qui donnent de l'XP
    Actions = {
        kill = 50,
        job_complete = 100,
        distance_traveled = 1  -- XP par km
    }
}

-- =====================================================
-- INITIALISATION DU MODULE
-- =====================================================

function LevelSystem.Init()
    AMA.Log("INFO", "Module Level System initialisé v" .. LevelSystem.version)
    
    -- Enregistrer les hooks pour donner de l'XP
    if not IsDuplicityVersion() then
        -- CLIENT
        LevelSystem.InitClient()
    else
        -- SERVER
        LevelSystem.InitServer()
    end
end

-- =====================================================
-- FONCTIONS SERVEUR
-- =====================================================

function LevelSystem.InitServer()
    -- Hook quand le joueur se connecte
    AMA.RegisterHook("ama:hook:playerDataLoaded", function(source, xPlayer)
        local level = AMA.GetPlayerMeta(source, "level") or 1
        local xp = AMA.GetPlayerMeta(source, "xp") or 0
        
        AMA.Log("DEBUG", "Joueur " .. xPlayer.name .. " - Level: " .. level .. " XP: " .. xp)
        
        -- Envoyer au client
        TriggerClientEvent('level:updateUI', source, level, xp)
    end)
    
    -- Hook avant la sauvegarde
    AMA.RegisterHook("ama:hook:beforeSave", function(source, xPlayer)
        local level = AMA.GetPlayerMeta(source, "level") or 1
        local xp = AMA.GetPlayerMeta(source, "xp") or 0
        
        -- Sauvegarder dans la base de données
        MySQL.update('UPDATE ama_players SET accounts = JSON_SET(COALESCE(accounts, "{}"), "$.level", ?, "$.xp", ?) WHERE identifier = ?',
            {level, xp, xPlayer.identifier}
        )
    end)
    
    -- Événement pour ajouter de l'XP
    RegisterNetEvent('level:addXP')
    AddEventHandler('level:addXP', function(amount, reason)
        local source = source
        LevelSystem.AddXP(source, amount, reason)
    end)
end

---Ajouter de l'XP à un joueur
---@param source number ID du joueur
---@param amount number Montant d'XP
---@param reason string Raison (optionnel)
function LevelSystem.AddXP(source, amount, reason)
    local xPlayer = AMA.GetPlayer(source)
    if not xPlayer then return end
    
    local currentXP = AMA.GetPlayerMeta(source, "xp") or 0
    local currentLevel = AMA.GetPlayerMeta(source, "level") or 1
    local newXP = currentXP + amount
    
    -- Calculer l'XP nécessaire pour le prochain niveau
    local xpNeeded = LevelSystem.GetXPForLevel(currentLevel + 1)
    
    -- Vérifier si le joueur monte de niveau
    while newXP >= xpNeeded and currentLevel < LevelSystem.Config.MaxLevel do
        newXP = newXP - xpNeeded
        currentLevel = currentLevel + 1
        
        -- Appeler la fonction de montée de niveau
        LevelSystem.OnLevelUp(source, currentLevel)
        
        -- Recalculer l'XP nécessaire
        xpNeeded = LevelSystem.GetXPForLevel(currentLevel + 1)
    end
    
    -- Sauvegarder
    AMA.SetPlayerMeta(source, "xp", newXP)
    AMA.SetPlayerMeta(source, "level", currentLevel)
    
    -- Notifier le client
    TriggerClientEvent('level:updateUI', source, currentLevel, newXP)
    
    if reason then
        TriggerClientEvent('ama:showNotification', source, "+" .. amount .. " XP (" .. reason .. ")")
    end
    
    AMA.Log("DEBUG", "XP ajouté: " .. amount .. " -> Level: " .. currentLevel .. " XP: " .. newXP)
end

---Obtenir l'XP nécessaire pour un niveau
---@param level number Niveau
---@return number XP nécessaire
function LevelSystem.GetXPForLevel(level)
    return math.floor(LevelSystem.Config.XPPerLevel * math.pow(LevelSystem.Config.XPMultiplier, level - 1))
end

---Quand un joueur monte de niveau
---@param source number ID du joueur
---@param newLevel number Nouveau niveau
function LevelSystem.OnLevelUp(source, newLevel)
    local xPlayer = AMA.GetPlayer(source)
    if not xPlayer then return end
    
    -- Récompense en argent
    xPlayer:addMoney(LevelSystem.Config.Rewards.money)
    
    -- Bonus tous les 5 niveaux
    if newLevel % 5 == 0 then
        xPlayer:addBank(LevelSystem.Config.Rewards.bank)
        TriggerClientEvent('ama:showNotification', source, 
            "🎉 Niveau " .. newLevel .. " ! Bonus: $" .. LevelSystem.Config.Rewards.bank)
    else
        TriggerClientEvent('ama:showNotification', source, 
            "⭐ Niveau " .. newLevel .. " ! +$" .. LevelSystem.Config.Rewards.money)
    end
    
    -- Effet visuel
    TriggerClientEvent('level:levelUpEffect', source)
    
    AMA.Log("INFO", xPlayer.name .. " est passé niveau " .. newLevel)
end

---Obtenir le niveau d'un joueur
---@param source number ID du joueur
---@return number, number Level, XP
function LevelSystem.GetPlayerLevel(source)
    local level = AMA.GetPlayerMeta(source, "level") or 1
    local xp = AMA.GetPlayerMeta(source, "xp") or 0
    return level, xp
end

-- =====================================================
-- FONCTIONS CLIENT
-- =====================================================

function LevelSystem.InitClient()
    -- Recevoir les mises à jour
    RegisterNetEvent('level:updateUI')
    AddEventHandler('level:updateUI', function(level, xp)
        -- Mettre à jour l'interface
        SendNUIMessage({
            action = "updateLevel",
            level = level,
            xp = xp,
            xpNeeded = LevelSystem.GetXPForLevel(level + 1)
        })
    end)
    
    -- Effet de montée de niveau
    RegisterNetEvent('level:levelUpEffect')
    AddEventHandler('level:levelUpEffect', function()
        -- Effet visuel
        PlaySoundFrontend(-1, "RANK_UP", "HUD_AWARDS", true)
        
        -- Particules
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        SetParticleFxNonLoopedAtCoord(
            "scr_xs_celebrate_firework", 
            coords.x, coords.y, coords.z, 
            0.0, 0.0, 0.0, 
            1.0, 
            false, false, false
        )
    end)
    
    -- Distance parcourue pour donner de l'XP
    CreateThread(function()
        local lastPos = nil
        local totalDistance = 0
        
        while true do
            Wait(5000) -- Vérifier toutes les 5 secondes
            
            if AMA.IsPlayerLoaded() then
                local ped = PlayerPedId()
                local currentPos = GetEntityCoords(ped)
                
                if lastPos then
                    local distance = #(currentPos - lastPos) / 1000 -- En km
                    totalDistance = totalDistance + distance
                    
                    -- Donner de l'XP tous les 1 km
                    if totalDistance >= 1.0 then
                        local xpToGive = math.floor(totalDistance) * LevelSystem.Config.Actions.distance_traveled
                        TriggerServerEvent('level:addXP', xpToGive, "Distance parcourue")
                        totalDistance = 0
                    end
                end
                
                lastPos = currentPos
            end
        end
    end)
end

-- =====================================================
-- COMMANDES
-- =====================================================

if IsDuplicityVersion() then
    -- Commande admin pour définir le niveau
    RegisterCommand('setlevel', function(source, args)
        local xPlayer = AMA.GetPlayer(source)
        if xPlayer and xPlayer.group == "admin" then
            local targetId = tonumber(args[1])
            local level = tonumber(args[2])
            
            if targetId and level then
                AMA.SetPlayerMeta(targetId, "level", level)
                AMA.SetPlayerMeta(targetId, "xp", 0)
                TriggerClientEvent('level:updateUI', targetId, level, 0)
                TriggerClientEvent('ama:showNotification', source, "Level défini: " .. level)
            end
        end
    end)
    
    -- Commande admin pour donner de l'XP
    RegisterCommand('givexp', function(source, args)
        local xPlayer = AMA.GetPlayer(source)
        if xPlayer and xPlayer.group == "admin" then
            local targetId = tonumber(args[1])
            local amount = tonumber(args[2])
            
            if targetId and amount then
                LevelSystem.AddXP(targetId, amount, "Admin")
                TriggerClientEvent('ama:showNotification', source, amount .. " XP donnés")
            end
        end
    end)
else
    -- Commande pour voir son niveau
    RegisterCommand('level', function()
        TriggerServerEvent('level:checkLevel')
    end)
end

-- =====================================================
-- EXPORTS POUR AUTRES RESSOURCES
-- =====================================================

if IsDuplicityVersion() then
    exports('AddXP', LevelSystem.AddXP)
    exports('GetPlayerLevel', LevelSystem.GetPlayerLevel)
    exports('GetXPForLevel', LevelSystem.GetXPForLevel)
end

-- =====================================================
-- ENREGISTREMENT DU MODULE
-- =====================================================

AMA.RegisterModule("level_system", LevelSystem)