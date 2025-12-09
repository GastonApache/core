# 💡 Exemples de Code - Framework AMA

## Table des matières

1. [Créer un nouveau job](#créer-un-nouveau-job)
2. [Ajouter une commande personnalisée](#ajouter-une-commande-personnalisée)
3. [Système de paiement](#système-de-paiement)
4. [Intégration Discord](#intégration-discord)
5. [Système de missions](#système-de-missions)
6. [Menu NUI personnalisé](#menu-nui-personnalisé)
7. [Système de véhicules](#système-de-véhicules)
8. [Système d'inventaire](#système-dinventaire)

---

## Créer un nouveau job

### Étape 1 : Ajouter le job dans la base de données

```sql
-- Créer le job
INSERT INTO `ama_jobs` (`name`, `label`, `whitelisted`) VALUES
('taxi', 'Taxi', 0);

-- Créer les grades
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('taxi', 0, 'recrue', 'Recrue', 500, '{}', '{}'),
('taxi', 1, 'chauffeur', 'Chauffeur', 750, '{}', '{}'),
('taxi', 2, 'experimente', 'Expérimenté', 1000, '{}', '{}'),
('taxi', 3, 'chef', 'Chef d\'équipe', 1500, '{}', '{}');
```

### Étape 2 : Créer le script du job

Créez `resources/ama_taxi/fxmanifest.lua` :

```lua
fx_version 'cerulean'
game 'gta5'

author 'Votre Nom'
description 'Job de Taxi'
version '1.0.0'

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

shared_scripts {
    'config.lua'
}

dependencies {
    'framework'
}
```

### Étape 3 : Configuration

`config.lua` :

```lua
Config = {}

Config.Job = "taxi"

Config.Prices = {
    BasePrice = 10,      -- Prix de base
    PricePerKm = 5,      -- Prix par kilomètre
    WaitingPrice = 1     -- Prix par seconde d'attente
}

Config.VehicleSpawn = {
    coords = vector3(895.0, -179.0, 74.7),
    heading = 240.0,
    model = "taxi"
}

Config.Blip = {
    coords = vector3(895.0, -179.0, 74.7),
    sprite = 198,
    color = 5,
    scale = 0.8,
    label = "Taxi"
}
```

### Étape 4 : Script serveur

`server/main.lua` :

```lua
local activeMissions = {}

-- Commande pour commencer une course
RegisterNetEvent('ama_taxi:startMission')
AddEventHandler('ama_taxi:startMission', function(targetCoords)
    local source = source
    local xPlayer = exports['framework']:GetPlayer(source)
    
    if not xPlayer then return end
    
    local job = xPlayer:getJob()
    if job.name ~= Config.Job then
        TriggerClientEvent('ama:showNotification', source, "Vous n'êtes pas taxi")
        return
    end
    
    -- Créer la mission
    activeMissions[source] = {
        startTime = os.time(),
        startCoords = GetEntityCoords(GetPlayerPed(source)),
        targetCoords = targetCoords,
        distance = 0,
        waitingTime = 0
    }
    
    TriggerClientEvent('ama_taxi:missionStarted', source, targetCoords)
    TriggerClientEvent('ama:showNotification', source, "Course commencée!")
end)

-- Terminer une course
RegisterNetEvent('ama_taxi:completeMission')
AddEventHandler('ama_taxi:completeMission', function()
    local source = source
    local xPlayer = exports['framework']:GetPlayer(source)
    
    if not xPlayer then return end
    
    local mission = activeMissions[source]
    if not mission then
        TriggerClientEvent('ama:showNotification', source, "Aucune course en cours")
        return
    end
    
    -- Calculer le prix
    local basePrice = Config.Prices.BasePrice
    local distancePrice = mission.distance * Config.Prices.PricePerKm
    local waitingPrice = mission.waitingTime * Config.Prices.WaitingPrice
    local totalPrice = math.floor(basePrice + distancePrice + waitingPrice)
    
    -- Payer le chauffeur
    xPlayer:addMoney(totalPrice, "Course de taxi")
    
    -- Notification
    TriggerClientEvent('ama:showNotification', source, 
        string.format("Course terminée! Vous avez gagné $%d", totalPrice))
    
    -- Logger
    print(string.format("[Taxi] %s a terminé une course de %.2f km pour $%d", 
        xPlayer.name, mission.distance, totalPrice))
    
    -- Nettoyer
    activeMissions[source] = nil
    TriggerClientEvent('ama_taxi:missionCompleted', source)
end)

-- Mettre à jour la distance
RegisterNetEvent('ama_taxi:updateDistance')
AddEventHandler('ama_taxi:updateDistance', function(distance)
    local source = source
    if activeMissions[source] then
        activeMissions[source].distance = distance
    end
end)

-- Cleanup à la déconnexion
AddEventHandler('playerDropped', function()
    local source = source
    if activeMissions[source] then
        activeMissions[source] = nil
    end
end)
```

### Étape 5 : Script client

`client/main.lua` :

```lua
local onDuty = false
local currentMission = nil
local missionBlip = nil
local missionVehicle = nil

-- Créer le blip
CreateThread(function()
    local blip = AddBlipForCoord(Config.Blip.coords)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(blip)
end)

-- Menu de service
RegisterCommand('taxiduty', function()
    local playerData = exports['framework']:GetPlayerData()
    
    if playerData.job ~= Config.Job then
        exports['framework']:ShowNotification("Vous n'êtes pas taxi")
        return
    end
    
    onDuty = not onDuty
    
    if onDuty then
        exports['framework']:ShowNotification("Vous êtes en service")
        SpawnVehicle()
    else
        exports['framework']:ShowNotification("Vous n'êtes plus en service")
        DeleteVehicle()
    end
end)

-- Spawn du véhicule
function SpawnVehicle()
    local model = GetHashKey(Config.VehicleSpawn.model)
    RequestModel(model)
    
    while not HasModelLoaded(model) do
        Wait(100)
    end
    
    missionVehicle = CreateVehicle(
        model,
        Config.VehicleSpawn.coords.x,
        Config.VehicleSpawn.coords.y,
        Config.VehicleSpawn.coords.z,
        Config.VehicleSpawn.heading,
        true,
        false
    )
    
    SetVehicleNumberPlateText(missionVehicle, "TAXI" .. math.random(100, 999))
    SetEntityAsMissionEntity(missionVehicle, true, true)
    SetModelAsNoLongerNeeded(model)
end

-- Supprimer le véhicule
function DeleteVehicle()
    if DoesEntityExist(missionVehicle) then
        DeleteEntity(missionVehicle)
        missionVehicle = nil
    end
end

-- Commencer une mission
RegisterCommand('taxicourse', function()
    if not onDuty then
        exports['framework']:ShowNotification("Vous devez être en service")
        return
    end
    
    if currentMission then
        exports['framework']:ShowNotification("Vous avez déjà une course en cours")
        return
    end
    
    -- Obtenir un point aléatoire
    local targetCoords = GetRandomStreetCoords()
    TriggerServerEvent('ama_taxi:startMission', targetCoords)
end)

-- Mission commencée
RegisterNetEvent('ama_taxi:missionStarted')
AddEventHandler('ama_taxi:missionStarted', function(targetCoords)
    currentMission = {
        targetCoords = targetCoords,
        startCoords = GetEntityCoords(PlayerPedId()),
        startTime = GetGameTimer()
    }
    
    -- Créer le waypoint et le blip
    SetNewWaypoint(targetCoords.x, targetCoords.y)
    
    missionBlip = AddBlipForCoord(targetCoords.x, targetCoords.y, targetCoords.z)
    SetBlipSprite(missionBlip, 1)
    SetBlipColour(missionBlip, 5)
    SetBlipRoute(missionBlip, true)
    
    -- Thread de mise à jour
    CreateThread(UpdateMissionThread)
end)

-- Thread de mise à jour de la mission
function UpdateMissionThread()
    while currentMission do
        Wait(1000)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - currentMission.startCoords) / 1000.0
        
        TriggerServerEvent('ama_taxi:updateDistance', distance)
        
        -- Vérifier si arrivé
        if #(playerCoords - currentMission.targetCoords) < 20.0 then
            TriggerServerEvent('ama_taxi:completeMission')
            break
        end
    end
end

-- Mission terminée
RegisterNetEvent('ama_taxi:missionCompleted')
AddEventHandler('ama_taxi:missionCompleted', function()
    currentMission = nil
    
    if DoesBlipExist(missionBlip) then
        RemoveBlip(missionBlip)
        missionBlip = nil
    end
end)

-- Fonction utilitaire
function GetRandomStreetCoords()
    local x = math.random(-3000, 3000) + 0.0
    local y = math.random(-3000, 3000) + 0.0
    local z = 0.0
    
    local found, outPosition, outHeading = GetClosestVehicleNodeWithHeading(x, y, z, 1, 3.0, 0)
    
    if found then
        return vector3(outPosition.x, outPosition.y, outPosition.z)
    else
        return vector3(x, y, z)
    end
end
```

---

## Ajouter une commande personnalisée

### Commande de guérison (admin)

**Serveur** (`server/commands.lua`) :

```lua
RegisterCommand('heal', function(source, args, rawCommand)
    local xPlayer = exports['framework']:GetPlayer(source)
    
    -- Vérifier les permissions
    if not xPlayer or xPlayer.group ~= "admin" then
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas la permission")
        return
    end
    
    local targetId = tonumber(args[1])
    
    if not targetId then
        -- Se soigner soi-même
        TriggerClientEvent('ama_admin:heal', source)
        TriggerClientEvent('ama:showNotification', source, "Vous vous êtes soigné")
    else
        -- Soigner un joueur
        local xTarget = exports['framework']:GetPlayer(targetId)
        
        if not xTarget then
            TriggerClientEvent('ama:showNotification', source, "Joueur introuvable")
            return
        end
        
        TriggerClientEvent('ama_admin:heal', targetId)
        TriggerClientEvent('ama:showNotification', source, 
            "Vous avez soigné " .. xTarget.name)
        TriggerClientEvent('ama:showNotification', targetId, "Vous avez été soigné")
    end
end, false)
```

**Client** (`client/commands.lua`) :

```lua
RegisterNetEvent('ama_admin:heal')
AddEventHandler('ama_admin:heal', function()
    local ped = PlayerPedId()
    
    -- Soigner le joueur
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    
    -- Réparer l'armure
    SetPedArmour(ped, 100)
    
    -- Effet visuel
    AnimpostfxPlay("RaceTurbo", 0, false)
    Wait(1000)
    AnimpostfxStop("RaceTurbo")
end)
```

---

## Système de paiement

### Distributeur ATM

**Client** :

```lua
local atmLocations = {
    vector3(89.0, 2.0, 68.0),
    vector3(147.0, -1035.0, 29.0),
    vector3(-1212.0, -330.0, 37.0),
    -- Ajoutez plus de positions
}

-- Créer les blips
CreateThread(function()
    for _, coords in ipairs(atmLocations) do
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, 108)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("ATM")
        EndTextCommandSetBlipName(blip)
    end
end)

-- Thread de détection
CreateThread(function()
    while true do
        Wait(0)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearATM = false
        
        for _, coords in ipairs(atmLocations) do
            local distance = #(playerCoords - coords)
            
            if distance < 10.0 then
                nearATM = true
                
                -- Afficher le texte d'aide
                if distance < 2.0 then
                    DrawText3D(coords.x, coords.y, coords.z, "[E] Distributeur")
                    
                    if IsControlJustPressed(0, 38) then  -- E
                        OpenATMMenu()
                    end
                end
            end
        end
        
        if not nearATM then
            Wait(500)
        end
    end
end)

function OpenATMMenu()
    local playerData = exports['framework']:GetPlayerData()
    
    SendNUIMessage({
        action = "openATM",
        money = playerData.money,
        bank = playerData.bank
    })
    
    SetNuiFocus(true, true)
end

-- Callbacks NUI
RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('ama_atm:deposit', data.amount)
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    TriggerServerEvent('ama_atm:withdraw', data.amount)
    cb('ok')
end)

RegisterNUICallback('closeATM', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end
```

**Serveur** :

```lua
RegisterNetEvent('ama_atm:deposit')
AddEventHandler('ama_atm:deposit', function(amount)
    local source = source
    local xPlayer = exports['framework']:GetPlayer(source)
    
    if not xPlayer then return end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('ama:showNotification', source, "Montant invalide")
        return
    end
    
    if xPlayer:removeMoney(amount, "Dépôt ATM") then
        xPlayer:addBank(amount, "Dépôt ATM")
        TriggerClientEvent('ama:showNotification', source, 
            string.format("Déposé $%d", amount))
    else
        TriggerClientEvent('ama:showNotification', source, "Argent insuffisant")
    end
end)

RegisterNetEvent('ama_atm:withdraw')
AddEventHandler('ama_atm:withdraw', function(amount)
    local source = source
    local xPlayer = exports['framework']:GetPlayer(source)
    
    if not xPlayer then return end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('ama:showNotification', source, "Montant invalide")
        return
    end
    
    if xPlayer:removeBank(amount, "Retrait ATM") then
        xPlayer:addMoney(amount, "Retrait ATM")
        TriggerClientEvent('ama:showNotification', source, 
            string.format("Retiré $%d", amount))
    else
        TriggerClientEvent('ama:showNotification', source, "Solde insuffisant")
    end
end)
```

---

## Intégration Discord

### Logger une action personnalisée

**Serveur** :

```lua
function LogToDiscord(title, description, color, fields)
    local webhook = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN"
    
    local embed = {
        title = title,
        description = description,
        color = color or 3447003,  -- Bleu par défaut
        fields = fields or {},
        footer = {
            text = "AMA Framework",
            icon_url = "https://i.imgur.com/votre-icone.png"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    PerformHttpRequest(webhook, function(statusCode, response, headers)
        if statusCode == 204 then
            print("^2[Discord]^7 Log envoyé avec succès")
        else
            print("^1[Discord]^7 Erreur lors de l'envoi: " .. statusCode)
        end
    end, 'POST', json.encode({
        username = "AMA Bot",
        embeds = {embed}
    }), {
        ['Content-Type'] = 'application/json'
    })
end

-- Exemple d'utilisation
RegisterNetEvent('ama_shop:purchase')
AddEventHandler('ama_shop:purchase', function(itemName, price)
    local source = source
    local xPlayer = exports['framework']:GetPlayer(source)
    
    if not xPlayer then return end
    
    if xPlayer:removeMoney(price, "Achat: " .. itemName) then
        -- Donner l'item au joueur
        -- ...
        
        -- Logger sur Discord
        LogToDiscord(
            "🛒 Achat effectué",
            string.format("%s a acheté %s", xPlayer.name, itemName),
            3066993,  -- Vert
            {
                {
                    name = "Joueur",
                    value = xPlayer.name,
                    inline = true
                },
                {
                    name = "Item",
                    value = itemName,
                    inline = true
                },
                {
                    name = "Prix",
                    value = "$" .. price,
                    inline = true
                }
            }
        )
        
        TriggerClientEvent('ama:showNotification', source, "Achat effectué")
    else
        TriggerClientEvent('ama:showNotification', source, "Argent insuffisant")
    end
end)
```

---

## Système de missions

### Missions quotidiennes

**Serveur** :

```lua
local dailyMissions = {
    {
        id = "drive_distance",
        label = "Conduire 10 km",
        description = "Parcourez 10 kilomètres en véhicule",
        target = 10000,  -- en mètres
        reward = 1000,
        type = "distance"
    },
    {
        id = "earn_money",
        label = "Gagner $5000",
        description = "Gagnez $5000 en travaillant",
        target = 5000,
        reward = 2000,
        type = "money"
    },
    {
        id = "complete_jobs",
        label = "Compléter 5 jobs",
        description = "Complétez 5 tâches de votre métier",
        target = 5,
        reward = 1500,
        type = "jobs"
    }
}

local playerMissions = {}  -- [source] = {mission_id = progress}

RegisterNetEvent('ama_missions:getDaily')
AddEventHandler('ama_missions:getDaily', function()
    local source = source
    local xPlayer = exports['framework']:GetPlayer(source)
    
    if not xPlayer then return end
    
    -- Initialiser si nécessaire
    if not playerMissions[source] then
        playerMissions[source] = {}
        for _, mission in ipairs(dailyMissions) do
            playerMissions[source][mission.id] = 0
        end
    end
    
    -- Envoyer les missions
    TriggerClientEvent('ama_missions:receiveDaily', source, dailyMissions, playerMissions[source])
end)

RegisterNetEvent('ama_missions:updateProgress')
AddEventHandler('ama_missions:updateProgress', function(missionId, progress)
    local source = source
    local xPlayer = exports['framework']:GetPlayer(source)
    
    if not xPlayer or not playerMissions[source] then return end
    
    playerMissions[source][missionId] = progress
    
    -- Vérifier si complété
    for _, mission in ipairs(dailyMissions) do
        if mission.id == missionId and progress >= mission.target then
            -- Mission complétée
            xPlayer:addMoney(mission.reward, "Mission quotidienne complétée")
            
            TriggerClientEvent('ama:showNotification', source,
                string.format("Mission complétée! Récompense: $%d", mission.reward))
            
            -- Logger sur Discord
            LogToDiscord(
                "✅ Mission complétée",
                string.format("%s a complété: %s", xPlayer.name, mission.label),
                3066993,
                {
                    {name = "Joueur", value = xPlayer.name, inline = true},
                    {name = "Mission", value = mission.label, inline = true},
                    {name = "Récompense", value = "$" .. mission.reward, inline = true}
                }
            )
            
            -- Réinitialiser
            playerMissions[source][missionId] = 0
        end
    end
end)
```

**Client** :

```lua
local currentMissions = {}
local missionsProgress = {}

RegisterCommand('missions', function()
    TriggerServerEvent('ama_missions:getDaily')
end)

RegisterNetEvent('ama_missions:receiveDaily')
AddEventHandler('ama_missions:receiveDaily', function(missions, progress)
    currentMissions = missions
    missionsProgress = progress
    
    -- Afficher le menu
    SendNUIMessage({
        action = "openMissions",
        missions = missions,
        progress = progress
    })
    
    SetNuiFocus(true, true)
end)

-- Thread pour traquer la distance parcourue
CreateThread(function()
    local lastCoords = nil
    local totalDistance = 0
    
    while true do
        Wait(1000)
        
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local currentCoords = GetEntityCoords(ped)
            
            if lastCoords then
                local distance = #(currentCoords - lastCoords)
                totalDistance = totalDistance + distance
                
                -- Mettre à jour la mission
                TriggerServerEvent('ama_missions:updateProgress', 'drive_distance', totalDistance)
            end
            
            lastCoords = currentCoords
        else
            lastCoords = nil
        end
    end
end)
```

---

## 📚 Voir aussi

- [API Serveur](API_SERVEUR.md) - Pour plus de fonctions serveur
- [API Client](API_CLIENT.md) - Pour plus de fonctions client
- [Commandes](COMMANDES.md) - Liste des commandes

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2025
