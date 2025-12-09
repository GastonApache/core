-- Événements client supplémentaires

-- Événement déclenché quand le joueur spawn
AddEventHandler('ama:onPlayerSpawn', function()
    if Config.Framework.Debug then
        print("^5[AMA]^7 Événement onPlayerSpawn déclenché")
    end
    
    -- Vous pouvez ajouter ici des actions à effectuer au spawn
    -- Par exemple: charger l'inventaire, afficher un HUD, etc.
end)

-- Événement pour gérer la déconnexion propre
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if PlayerLoaded then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            
            local positionData = {
                x = AMA.Round(coords.x, 2),
                y = AMA.Round(coords.y, 2),
                z = AMA.Round(coords.z, 2),
                heading = AMA.Round(heading, 2)
            }
            
            -- Sauvegarder une dernière fois avant de quitter
            TriggerServerEvent('ama:savePosition', positionData)
            Wait(100) -- Attendre que la sauvegarde soit effectuée
        end
    end
end)

-- Désactiver certaines actions au spawn
CreateThread(function()
    while true do
        Wait(0)
        
        if PlayerLoaded then
            -- Désactiver les armes par défaut
            SetPedInfiniteAmmoClip(PlayerPedId(), false)
            
            -- Vous pouvez ajouter d'autres désactivations ici
            -- Par exemple: désactiver les wanted stars
            if GetPlayerWantedLevel(PlayerId()) > 0 then
                SetPlayerWantedLevel(PlayerId(), 0, false)
                SetPlayerWantedLevelNow(PlayerId(), false)
            end
        else
            -- Quand le joueur n'est pas encore chargé, on attend plus longtemps
            Wait(1000)
        end
    end
end)

-- Thread pour vérifier la santé et afficher des informations
CreateThread(function()
    while true do
        Wait(5000) -- Vérifier toutes les 5 secondes
        
        if PlayerLoaded then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            
            -- Si la santé est basse, afficher une notification
            if health < maxHealth * 0.3 and health > 0 then
                -- Vous pouvez ajouter une notification de santé faible ici
                if Config.Framework.Debug then
                    print("^3[AMA]^7 Santé faible: " .. health .. "/" .. maxHealth)
                end
            end
        end
    end
end)

-- Commandes client utiles
RegisterCommand('pos', function()
    if PlayerLoaded then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        
        print(string.format("^5Position:^7 vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z))
        print(string.format("^5Heading:^7 %.2f", heading))
        
        -- Copier dans le presse-papier (ne fonctionne pas sur tous les serveurs)
        local posString = string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z)
        SendNUIMessage({
            action = "copyToClipboard",
            text = posString
        })
    end
end, false)

-- Commande pour afficher les FPS
local showFps = false
RegisterCommand('fps', function()
    showFps = not showFps
    AMA.ShowNotification(showFps and "FPS activé" or "FPS désactivé")
end, false)

CreateThread(function()
    while true do
        Wait(0)
        
        if showFps then
            local fps = math.floor(1.0 / GetFrameTime())
            SetTextFont(4)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("FPS: " .. fps)
            DrawText(0.01, 0.01)
        else
            Wait(500)
        end
    end
end)