-- Gestion du spawn du joueur

local HasSpawned = false
local FirstSpawn = true

-- Désactiver le spawn automatique de FiveM
AddEventHandler('onClientMapStart', function()
    exports.spawnmanager:setAutoSpawn(false)
end)

-- Fonction pour spawn le joueur
local function SpawnPlayer(coords, heading, skipFade)
    local ped = PlayerPedId()
    
    if not skipFade then
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Wait(0)
        end
    end
    
    -- Nettoyer l'entité précédente si nécessaire
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
    
    -- Créer le nouveau ped
    local playerModel = GetHashKey("mp_m_freemode_01")
    RequestModel(playerModel)
    while not HasModelLoaded(playerModel) do
        Wait(0)
    end
    
    -- Spawn à la position
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(ped, heading)
    
    -- Geler le joueur pendant le chargement
    FreezeEntityPosition(ped, true)
    
    -- Attendre que tout soit chargé
    SetPlayerInvincible(PlayerId(), true)
    SetEntityVisible(ped, false, false)
    
    -- Attendre que la collision soit chargée
    local timeout = 0
    while not HasCollisionLoadedAroundEntity(ped) and timeout < 2000 do
        Wait(0)
        timeout = timeout + 1
    end
    
    -- Nettoyer le cache du modèle
    SetModelAsNoLongerNeeded(playerModel)
    
    -- Rendre le joueur visible
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    
    -- Restaurer la caméra
    RenderScriptCams(false, true, 500, true, true)
    
    if not skipFade then
        DoScreenFadeIn(500)
    end
    
    -- Marquer comme spawné
    HasSpawned = true
    TriggerEvent('ama:onPlayerSpawn')
    TriggerServerEvent('ama:hasSpawned')
    
    AMA.Log("INFO", "Joueur spawné avec succès")
end

-- Événement de spawn du joueur
RegisterNetEvent('ama:playerSpawn')
AddEventHandler('ama:playerSpawn', function(playerData)
    PlayerData = playerData
    PlayerLoaded = true
    
    local spawnCoords = Config.Spawn.Default.coords
    local spawnHeading = Config.Spawn.Default.heading
    
    -- Si le joueur a une dernière position et que c'est activé
    if Config.Spawn.EnableLastPosition and playerData.position then
        spawnCoords = vector3(
            playerData.position.x,
            playerData.position.y,
            playerData.position.z
        )
        spawnHeading = playerData.position.heading or Config.Spawn.Default.heading
        
        AMA.Log("INFO", "Spawn à la dernière position")
    else
        AMA.Log("INFO", "Spawn à la position par défaut")
    end
    
    -- Spawn le joueur
    SpawnPlayer(spawnCoords, spawnHeading, FirstSpawn)
    
    -- Mettre à jour la dernière position
    LastPosition = spawnCoords
    
    -- Notification de bienvenue
    Wait(1000)
    if playerData.position then
        AMA.ShowNotification(Config.Messages.WelcomeBack)
    else
        AMA.ShowNotification(Config.Messages.FirstConnection)
    end
    
    FirstSpawn = false
end)

-- Événement pour forcer un respawn
RegisterNetEvent('ama:forceRespawn')
AddEventHandler('ama:forceRespawn', function(coords, heading)
    if coords then
        SpawnPlayer(coords, heading or 0.0, false)
    else
        SpawnPlayer(Config.Spawn.Default.coords, Config.Spawn.Default.heading, false)
    end
end)

-- Gestion de la mort du joueur
CreateThread(function()
    while true do
        Wait(1000)
        
        if PlayerLoaded then
            local ped = PlayerPedId()
            
            if IsEntityDead(ped) and HasSpawned then
                HasSpawned = false
                
                -- Attendre 5 secondes avant de respawn
                Wait(5000)
                
                -- Respawn à l'hôpital (ou dernière position)
                local hospital = vector3(299.58, -584.76, 43.26)
                SpawnPlayer(hospital, 82.14, false)
                
                -- Soigner le joueur
                local newPed = PlayerPedId()
                SetEntityHealth(newPed, GetEntityMaxHealth(newPed))
                
                AMA.ShowNotification("Vous avez été réanimé à l'hôpital")
            end
        end
    end
end)