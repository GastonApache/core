-- =====================================================
-- SYSTÈME DE CREWS (ORGANISATIONS ILLÉGALES)
-- =====================================================

AMA.Crews = {}

-- =====================================================
-- FONCTIONS PRINCIPALES
-- =====================================================

---Obtenir les informations d'un crew
---@param crewName string Nom du crew
---@return table|nil Informations du crew
function AMA.Crews.GetCrewData(crewName)
    for _, crew in ipairs(Config.Crews.Available) do
        if crew.name == crewName then
            return crew
        end
    end
    return nil
end

---Obtenir tous les membres d'un crew
---@param crewName string Nom du crew
---@return table Liste des joueurs
function AMA.Crews.GetCrewMembers(crewName)
    local members = {}
    for _, xPlayer in pairs(AMA.Players) do
        if xPlayer.crew == crewName then
            table.insert(members, {
                source = xPlayer.source,
                name = xPlayer.name,
                firstname = xPlayer.firstname,
                lastname = xPlayer.lastname,
                grade = xPlayer.crew_grade
            })
        end
    end
    return members
end

---Obtenir le nombre de membres dans un crew
---@param crewName string Nom du crew
---@return number Nombre de membres
function AMA.Crews.GetCrewMemberCount(crewName)
    local count = 0
    for _, xPlayer in pairs(AMA.Players) do
        if xPlayer.crew == crewName then
            count = count + 1
        end
    end
    return count
end

---Obtenir le coffre du crew
---@param crewName string Nom du crew
---@param callback function Callback avec le montant
function AMA.Crews.GetCrewBank(crewName, callback)
    MySQL.single('SELECT bank FROM ama_crews WHERE name = ?', {crewName}, function(result)
        if result then
            callback(result.bank or 0)
        else
            callback(0)
        end
    end)
end

---Ajouter de l'argent au coffre du crew
---@param crewName string Nom du crew
---@param amount number Montant à ajouter
function AMA.Crews.AddCrewBank(crewName, amount)
    MySQL.update('UPDATE ama_crews SET bank = bank + ? WHERE name = ?', {amount, crewName})
    
    -- Notifier tous les membres
    for _, xPlayer in pairs(AMA.Players) do
        if xPlayer.crew == crewName then
            TriggerClientEvent('ama:showNotification', xPlayer.source, 
                string.format("Le coffre du crew a reçu $%d", amount))
        end
    end
    
    AMA.Log("INFO", string.format("Crew %s: +$%d au coffre", crewName, amount))
end

---Retirer de l'argent du coffre du crew
---@param crewName string Nom du crew
---@param amount number Montant à retirer
---@param callback function Callback avec succès (true/false)
function AMA.Crews.RemoveCrewBank(crewName, amount, callback)
    AMA.Crews.GetCrewBank(crewName, function(currentBank)
        if currentBank >= amount then
            MySQL.update('UPDATE ama_crews SET bank = bank - ? WHERE name = ?', {amount, crewName})
            
            -- Notifier tous les membres
            for _, xPlayer in pairs(AMA.Players) do
                if xPlayer.crew == crewName then
                    TriggerClientEvent('ama:showNotification', xPlayer.source, 
                        string.format("$%d retirés du coffre du crew", amount))
                end
            end
            
            AMA.Log("INFO", string.format("Crew %s: -$%d du coffre", crewName, amount))
            callback(true)
        else
            callback(false)
        end
    end)
end

-- =====================================================
-- ÉVÉNEMENTS SERVEUR
-- =====================================================

-- Rejoindre un crew
RegisterNetEvent('ama:joinCrew')
AddEventHandler('ama:joinCrew', function(crewName, grade)
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    -- Vérifier que le crew existe
    local crewData = AMA.Crews.GetCrewData(crewName)
    if not crewData then
        TriggerClientEvent('ama:showNotification', source, "Ce crew n'existe pas")
        return
    end
    
    xPlayer:setCrew(crewName, grade or 0)
    TriggerClientEvent('ama:showNotification', source, 
        "Vous avez rejoint: " .. crewData.label)
end)

-- Quitter un crew
RegisterNetEvent('ama:leaveCrew')
AddEventHandler('ama:leaveCrew', function()
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    if xPlayer.crew == "none" then
        TriggerClientEvent('ama:showNotification', source, "Vous n'êtes dans aucun crew")
        return
    end
    
    local oldCrew = xPlayer:getCrewLabel()
    xPlayer:setCrew("none", 0)
    TriggerClientEvent('ama:showNotification', source, "Vous avez quitté: " .. oldCrew)
end)

-- Promouvoir un membre du crew
RegisterNetEvent('ama:promoteCrewMember')
AddEventHandler('ama:promoteCrewMember', function(targetId, newGrade)
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    local xTarget = AMA.GetPlayer(targetId)
    
    if not xPlayer or not xTarget then return end
    
    -- Vérifier que les deux sont dans le même crew
    if xPlayer.crew ~= xTarget.crew or xPlayer.crew == "none" then
        TriggerClientEvent('ama:showNotification', source, "Vous n'êtes pas dans le même crew")
        return
    end
    
    -- Vérifier les permissions
    if not xPlayer:hasCrewPermission("promote") then
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas la permission")
        return
    end
    
    -- Ne peut pas promouvoir au-dessus de son propre grade
    if newGrade >= xPlayer.crew_grade then
        TriggerClientEvent('ama:showNotification', source, 
            "Vous ne pouvez pas promouvoir à un grade égal ou supérieur au vôtre")
        return
    end
    
    xTarget:setCrew(xTarget.crew, newGrade)
    TriggerClientEvent('ama:showNotification', source, 
        string.format("%s a été promu grade %d", xTarget.name, newGrade))
    TriggerClientEvent('ama:showNotification', targetId, 
        string.format("Vous avez été promu grade %d", newGrade))
end)

-- Exclure un membre du crew
RegisterNetEvent('ama:kickCrewMember')
AddEventHandler('ama:kickCrewMember', function(targetId)
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    local xTarget = AMA.GetPlayer(targetId)
    
    if not xPlayer or not xTarget then return end
    
    -- Vérifier que les deux sont dans le même crew
    if xPlayer.crew ~= xTarget.crew or xPlayer.crew == "none" then
        TriggerClientEvent('ama:showNotification', source, "Vous n'êtes pas dans le même crew")
        return
    end
    
    -- Vérifier les permissions
    if not xPlayer:hasCrewPermission("kick") then
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas la permission")
        return
    end
    
    -- Ne peut pas kick un grade supérieur ou égal
    if xTarget.crew_grade >= xPlayer.crew_grade then
        TriggerClientEvent('ama:showNotification', source, 
            "Vous ne pouvez pas exclure un membre de grade égal ou supérieur")
        return
    end
    
    local crewName = xTarget:getCrewLabel()
    xTarget:setCrew("none", 0)
    TriggerClientEvent('ama:showNotification', source, 
        string.format("%s a été exclu du crew", xTarget.name))
    TriggerClientEvent('ama:showNotification', targetId, 
        "Vous avez été exclu de " .. crewName)
end)

-- Déposer de l'argent dans le coffre du crew
RegisterNetEvent('ama:depositCrewMoney')
AddEventHandler('ama:depositCrewMoney', function(amount)
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer or xPlayer.crew == "none" then
        TriggerClientEvent('ama:showNotification', source, "Vous n'êtes dans aucun crew")
        return
    end
    
    if not xPlayer:hasCrewPermission("manage_money") then
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas la permission")
        return
    end
    
    if xPlayer:removeMoney(amount, "Dépôt coffre crew") then
        AMA.Crews.AddCrewBank(xPlayer.crew, amount)
        TriggerClientEvent('ama:showNotification', source, 
            string.format("Vous avez déposé $%d dans le coffre", amount))
    else
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas assez d'argent")
    end
end)

-- Retirer de l'argent du coffre du crew
RegisterNetEvent('ama:withdrawCrewMoney')
AddEventHandler('ama:withdrawCrewMoney', function(amount)
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer or xPlayer.crew == "none" then
        TriggerClientEvent('ama:showNotification', source, "Vous n'êtes dans aucun crew")
        return
    end
    
    if not xPlayer:hasCrewPermission("manage_money") then
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas la permission")
        return
    end
    
    AMA.Crews.RemoveCrewBank(xPlayer.crew, amount, function(success)
        if success then
            xPlayer:addMoney(amount, "Retrait coffre crew")
            TriggerClientEvent('ama:showNotification', source, 
                string.format("Vous avez retiré $%d du coffre", amount))
        else
            TriggerClientEvent('ama:showNotification', source, "Le coffre n'a pas assez d'argent")
        end
    end)
end)

-- Obtenir les informations du crew
RegisterNetEvent('ama:getCrewInfo')
AddEventHandler('ama:getCrewInfo', function()
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer or xPlayer.crew == "none" then
        TriggerClientEvent('ama:showNotification', source, "Vous n'êtes dans aucun crew")
        return
    end
    
    local members = AMA.Crews.GetCrewMembers(xPlayer.crew)
    local crewData = AMA.Crews.GetCrewData(xPlayer.crew)
    
    AMA.Crews.GetCrewBank(xPlayer.crew, function(bank)
        TriggerClientEvent('ama:receiveCrewInfo', source, {
            name = crewData.name,
            label = crewData.label,
            color = crewData.color,
            members = members,
            bank = bank,
            your_grade = xPlayer.crew_grade,
            salary = xPlayer:getCrewSalary()
        })
    end)
end)

-- =====================================================
-- COMMANDES
-- =====================================================

-- Commande pour afficher les infos du crew
RegisterCommand('crew', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer or xPlayer.crew == "none" then
        TriggerClientEvent('ama:showNotification', source, "Vous n'êtes dans aucun crew")
        return
    end
    
    TriggerEvent('ama:getCrewInfo', source)
end, false)

-- Commande admin pour définir un crew
RegisterCommand('setcrew', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer and xPlayer.group == "admin" then
        local targetId = tonumber(args[1])
        local crewName = args[2]
        local grade = tonumber(args[3]) or 0
        
        if targetId and crewName then
            local xTarget = AMA.GetPlayer(targetId)
            if xTarget then
                xTarget:setCrew(crewName, grade)
                TriggerClientEvent('ama:showNotification', source, 
                    string.format("Crew défini pour %s: %s (Grade: %d)", xTarget.name, crewName, grade))
            end
        else
            TriggerClientEvent('ama:showNotification', source, "Usage: /setcrew [id] [crew] [grade]")
        end
    end
end, false)

-- =====================================================
-- EXPORTS
-- =====================================================

exports('GetCrewMembers', AMA.Crews.GetCrewMembers)
exports('GetCrewBank', AMA.Crews.GetCrewBank)
exports('AddCrewBank', AMA.Crews.AddCrewBank)
exports('RemoveCrewBank', AMA.Crews.RemoveCrewBank)

AMA.Log("INFO", "Système de Crews chargé")