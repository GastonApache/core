-- Variables locales
local PlayerLoaded = false
local PlayerData = {}
local LastPosition = nil
local LastSaveTime = 0

-- Callbacks client
local CurrentRequestId = 0
local ServerCallbacks = {}

function AMA.TriggerServerCallback(name, cb, ...)
    ServerCallbacks[CurrentRequestId] = cb
    TriggerServerEvent('ama:triggerServerCallback', name, CurrentRequestId, ...)
    CurrentRequestId = CurrentRequestId + 1
end

RegisterNetEvent('ama:serverCallback')
AddEventHandler('ama:serverCallback', function(requestId, ...)
    if ServerCallbacks[requestId] then
        ServerCallbacks[requestId](...)
        ServerCallbacks[requestId] = nil
    end
end)

-- Fonction pour obtenir les données du joueur
function AMA.GetPlayerData()
    return PlayerData
end

-- Fonction pour vérifier si le joueur est chargé
function AMA.IsPlayerLoaded()
    return PlayerLoaded
end

-- Thread de sauvegarde automatique de position
CreateThread(function()
    while true do
        Wait(Config.Spawn.SaveDelay)
        
        if PlayerLoaded then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            
            local currentPos = vector3(coords.x, coords.y, coords.z)
            
            -- Vérifier si le joueur s'est déplacé suffisamment
            if LastPosition then
                local distance = #(currentPos - LastPosition)
                if distance < Config.Spawn.MinDistanceToSave then
                    goto continue
                end
            end
            
            -- Vérifier si le joueur n'est pas en véhicule (optionnel)
            if IsPedInAnyVehicle(ped, false) then
                goto continue
            end
            
            -- Sauvegarder la position
            local positionData = {
                x = AMA.Round(coords.x, 2),
                y = AMA.Round(coords.y, 2),
                z = AMA.Round(coords.z, 2),
                heading = AMA.Round(heading, 2)
            }
            
            TriggerServerEvent('ama:savePosition', positionData)
            LastPosition = currentPos
            LastSaveTime = GetGameTimer()
            
            if Config.Framework.Debug then
                print("^5[AMA]^7 Position sauvegardée: " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
            end
        end
        
        ::continue::
    end
end)

-- Fonction pour afficher une notification
function AMA.ShowNotification(message, type)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, true)
end

-- Événement pour afficher une notification
RegisterNetEvent('ama:showNotification')
AddEventHandler('ama:showNotification', function(message, type)
    AMA.ShowNotification(message, type)
end)

-- Événement pour mettre à jour l'argent
RegisterNetEvent('ama:updateMoney')
AddEventHandler('ama:updateMoney', function(money)
    PlayerData.money = money
    SendNUIMessage({
        action = "updateMoney",
        money = money
    })
end)

-- Événement pour mettre à jour la banque
RegisterNetEvent('ama:updateBank')
AddEventHandler('ama:updateBank', function(bank)
    PlayerData.bank = bank
    SendNUIMessage({
        action = "updateBank",
        bank = bank
    })
end)

-- Événement pour mettre à jour le job
RegisterNetEvent('ama:setJob')
AddEventHandler('ama:setJob', function(job, grade)
    PlayerData.job = job
    PlayerData.job_grade = grade
    AMA.ShowNotification("Nouveau job: " .. job .. " (Grade: " .. grade .. ")")
end)

-- Événement pour téléporter le joueur
RegisterNetEvent('ama:teleportPlayer')
AddEventHandler('ama:teleportPlayer', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
    AMA.ShowNotification("Téléportation effectuée")
end)

-- Initialisation au chargement
AddEventHandler('playerSpawned', function()
    if not PlayerLoaded then
        TriggerServerEvent('ama:playerLoaded')
    end
end)

-- Export des fonctions
exports('GetPlayerData', AMA.GetPlayerData)
exports('IsPlayerLoaded', AMA.IsPlayerLoaded)
exports('ShowNotification', AMA.ShowNotification)