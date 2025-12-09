-- Commandes administrateur

-- Commande pour donner de l'argent
RegisterCommand('givemoney', function(source, args, rawCommand)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer and xPlayer.group == "admin" then
        local targetId = tonumber(args[1])
        local amount = tonumber(args[2])
        
        if targetId and amount then
            local xTarget = AMA.GetPlayer(targetId)
            if xTarget then
                xTarget:addMoney(amount)
                TriggerClientEvent('ama:showNotification', source, "Vous avez donné $" .. amount .. " à " .. GetPlayerName(targetId))
                TriggerClientEvent('ama:showNotification', targetId, "Vous avez reçu $" .. amount)
            else
                TriggerClientEvent('ama:showNotification', source, "Joueur introuvable")
            end
        else
            TriggerClientEvent('ama:showNotification', source, "Usage: /givemoney [id] [montant]")
        end
    else
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas la permission")
    end
end, false)

-- Commande pour se téléporter
RegisterCommand('tp', function(source, args, rawCommand)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer and xPlayer.group == "admin" then
        local targetId = tonumber(args[1])
        
        if targetId then
            local targetPed = GetPlayerPed(targetId)
            local targetCoords = GetEntityCoords(targetPed)
            
            TriggerClientEvent('ama:teleportPlayer', source, targetCoords)
            TriggerClientEvent('ama:showNotification', source, "Téléportation vers " .. GetPlayerName(targetId))
        else
            TriggerClientEvent('ama:showNotification', source, "Usage: /tp [id]")
        end
    else
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas la permission")
    end
end, false)

-- Commande pour sauvegarder manuellement
RegisterCommand('save', function(source, args, rawCommand)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer then
        AMA.SavePlayer(source)
        TriggerClientEvent('ama:showNotification', source, Config.Messages.PositionSaved)
    end
end, false)

-- Commande pour afficher les informations du joueur
RegisterCommand('me', function(source, args, rawCommand)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer then
        local info = string.format(
            "^5=== Informations Joueur ===^7\n" ..
            "Nom: %s %s\n" ..
            "Argent: $%d\n" ..
            "Banque: $%d\n" ..
            "Job: %s (Grade: %d)\n" ..
            "Groupe: %s",
            xPlayer.firstname, xPlayer.lastname,
            xPlayer.money, xPlayer.bank,
            xPlayer.job, xPlayer.job_grade,
            xPlayer.group
        )
        
        TriggerClientEvent('chat:addMessage', source, {
            args = {info}
        })
    end
end, false)