-- Initialisation du framework côté serveur
AMA.ServerCallbacks = {}

-- Vérification des tables (sans création automatique)
CreateThread(function()
    MySQL.query('SHOW TABLES LIKE "ama_players"', {}, function(result)
        if result and #result > 0 then
            AMA.Log("INFO", "Tables de base de données détectées")
        else
            AMA.Log("ERROR", "❌ TABLES NON TROUVÉES ! Veuillez importer le fichier installation.sql")
            AMA.Log("ERROR", "Le serveur ne fonctionnera pas correctement sans les tables")
        end
    end)
end)

-- Fonction pour obtenir l'identifiant du joueur
function AMA.GetIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in pairs(identifiers) do
        if string.match(identifier, "license:") then
            return identifier
        end
    end
    return nil
end

-- Fonction pour obtenir un joueur
function AMA.GetPlayer(source)
    return AMA.Players[source]
end

-- Fonction pour obtenir tous les joueurs
function AMA.GetPlayers()
    local players = {}
    for k, v in pairs(AMA.Players) do
        table.insert(players, v)
    end
    return players
end

-- Callback système
function AMA.RegisterServerCallback(name, cb)
    AMA.ServerCallbacks[name] = cb
end

RegisterNetEvent('ama:triggerServerCallback')
AddEventHandler('ama:triggerServerCallback', function(name, requestId, ...)
    local source = source
    
    if AMA.ServerCallbacks[name] then
        AMA.ServerCallbacks[name](source, function(...)
            TriggerClientEvent('ama:serverCallback', source, requestId, ...)
        end, ...)
    else
        AMA.Log("ERROR", "Callback serveur introuvable: " .. name)
    end
end)

-- Événement de connexion du joueur
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local source = source
    local identifier = AMA.GetIdentifier(source)
    
    deferrals.defer()
    Wait(100)
    
    deferrals.update("Chargement de vos données...")
    
    if not identifier then
        deferrals.done("Erreur: Impossible de récupérer votre identifiant Steam")
        return
    end
    
    deferrals.done()
end)

-- Événement quand le joueur est prêt
RegisterNetEvent('ama:playerLoaded')
AddEventHandler('ama:playerLoaded', function()
    local source = source
    local identifier = AMA.GetIdentifier(source)
    
    if not identifier then
        DropPlayer(source, "Erreur: Identifiant introuvable")
        return
    end
    
    AMA.LoadPlayer(source, identifier)
end)

-- Événement de déconnexion
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    if AMA.Players[source] then
        local xPlayer = AMA.Players[source]
        
        -- DISCORD: Logger la déconnexion
        if Config.Discord and Config.Discord.Enabled then
            AMA.Discord.LogPlayerDisconnection(source, xPlayer, reason)
        end
        
        -- Sauvegarder avant de supprimer
        AMA.SavePlayer(source)
        
        -- Déclencher le hook
        AMA.TriggerHook("ama:hook:playerDisconnected", source, xPlayer)
        
        AMA.Players[source] = nil
        AMA.Log("INFO", "Joueur déconnecté: " .. GetPlayerName(source))
    end
end)

-- Sauvegarde automatique toutes les 5 minutes
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        
        for playerId, _ in pairs(AMA.Players) do
            if GetPlayerPing(playerId) > 0 then
                AMA.SavePlayer(playerId)
            end
        end
        
        AMA.Log("INFO", "Sauvegarde automatique effectuée pour " .. #AMA.GetPlayers() .. " joueurs")
    end
end)

-- Export des fonctions
exports('GetPlayer', AMA.GetPlayer)
exports('GetPlayers', AMA.GetPlayers)