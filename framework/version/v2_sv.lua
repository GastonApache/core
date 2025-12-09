-- Initialisation du framework côté serveur
AMA.ServerCallbacks = {}

-- Création automatique des tables
CreateThread(function()
    if Config.Database.AutoCreateTables then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `ama_players` (
                `id` INT(11) NOT NULL AUTO_INCREMENT,
                `identifier` VARCHAR(60) NOT NULL,
                `firstname` VARCHAR(50) DEFAULT NULL,
                `lastname` VARCHAR(50) DEFAULT NULL,
                `money` INT(11) DEFAULT 5000,
                `bank` INT(11) DEFAULT 0,
                `job` VARCHAR(50) DEFAULT 'unemployed',
                `job_grade` INT(11) DEFAULT 0,
                `group` VARCHAR(50) DEFAULT 'user',
                `position` TEXT DEFAULT NULL,
                `inventory` LONGTEXT DEFAULT NULL,
                `accounts` LONGTEXT DEFAULT NULL,
                `last_seen` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                UNIQUE KEY `identifier` (`identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
        
        AMA.Log("INFO", "Tables de base de données vérifiées/créées")
    end
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