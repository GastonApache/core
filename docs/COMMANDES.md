# ⌨️ Commandes - Framework AMA

## Table des matières

1. [Commandes joueur](#commandes-joueur)
2. [Commandes administrateur](#commandes-administrateur)
3. [Commandes AMACoin](#commandes-amacoin)
4. [Commandes crew](#commandes-crew)
5. [Commandes de debug](#commandes-de-debug)
6. [Créer des commandes personnalisées](#créer-des-commandes-personnalisées)

---

## Commandes joueur

### `/me`

Affiche vos informations personnelles.

**Syntaxe** :
```
/me
```

**Résultat** :
```
=== Informations Joueur ===
Nom: John Doe
Argent: $5000
Banque: $10000
Job: police (Grade: 2)
Groupe: user
```

**Exemple d'utilisation** :
```lua
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
```

---

### `/save`

Sauvegarde manuellement votre position.

**Syntaxe** :
```
/save
```

**Effets** :
- Sauvegarde votre position actuelle dans la base de données
- Notification de confirmation

**Exemple** :
```
/save
> Position sauvegardée
```

---

### `/pos`

Affiche votre position actuelle (coordonnées et heading).

**Syntaxe** :
```
/pos
```

**Résultat** :
```
Position: vector3(-1037.72, -2738.93, 20.17)
Heading: 329.39
```

**Exemple côté client** :
```lua
RegisterCommand('pos', function()
    if PlayerLoaded then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        
        print(string.format("^5Position:^7 vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z))
        print(string.format("^5Heading:^7 %.2f", heading))
        
        -- Copier dans le presse-papier
        local posString = string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z)
        SendNUIMessage({
            action = "copyToClipboard",
            text = posString
        })
    end
end, false)
```

---

### `/fps`

Affiche ou masque les FPS à l'écran.

**Syntaxe** :
```
/fps
```

**Effets** :
- Active/désactive l'affichage des FPS
- FPS affichés en haut à gauche de l'écran

**Exemple** :
```
/fps
> FPS activé
```

---

## Commandes administrateur

### `/givemoney`

Donne de l'argent à un joueur.

**Syntaxe** :
```
/givemoney [id] [montant]
```

**Paramètres** :
- `id` : ID du joueur cible
- `montant` : Montant d'argent à donner

**Permissions** :
- Groupe "admin" requis

**Exemples** :
```
/givemoney 1 5000
> Vous avez donné $5000 à John Doe

/givemoney 2 10000
> Vous avez donné $10000 à Jane Smith
```

**Erreurs possibles** :
```
/givemoney
> Usage: /givemoney [id] [montant]

/givemoney 999 1000
> Joueur introuvable

/givemoney 1 1000
> Vous n'avez pas la permission
```

**Code serveur** :
```lua
RegisterCommand('givemoney', function(source, args, rawCommand)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer and xPlayer.group == "admin" then
        local targetId = tonumber(args[1])
        local amount = tonumber(args[2])
        
        if targetId and amount then
            local xTarget = AMA.GetPlayer(targetId)
            if xTarget then
                xTarget:addMoney(amount, "Admin")
                TriggerClientEvent('ama:showNotification', source, 
                    "Vous avez donné $" .. amount .. " à " .. GetPlayerName(targetId))
                TriggerClientEvent('ama:showNotification', targetId, 
                    "Vous avez reçu $" .. amount)
            else
                TriggerClientEvent('ama:showNotification', source, "Joueur introuvable")
            end
        else
            TriggerClientEvent('ama:showNotification', source, 
                "Usage: /givemoney [id] [montant]")
        end
    else
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas la permission")
    end
end, false)
```

---

### `/tp`

Se téléporte vers un joueur.

**Syntaxe** :
```
/tp [id]
```

**Paramètres** :
- `id` : ID du joueur cible

**Permissions** :
- Groupe "admin" requis

**Exemples** :
```
/tp 1
> Téléportation vers John Doe

/tp 5
> Téléportation vers Jane Smith
```

**Code** :
```lua
RegisterCommand('tp', function(source, args, rawCommand)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer and xPlayer.group == "admin" then
        local targetId = tonumber(args[1])
        
        if targetId then
            local targetPed = GetPlayerPed(targetId)
            local targetCoords = GetEntityCoords(targetPed)
            
            TriggerClientEvent('ama:teleportPlayer', source, targetCoords)
            TriggerClientEvent('ama:showNotification', source, 
                "Téléportation vers " .. GetPlayerName(targetId))
        else
            TriggerClientEvent('ama:showNotification', source, "Usage: /tp [id]")
        end
    else
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas la permission")
    end
end, false)
```

---

### `/setjob`

Définit le métier d'un joueur.

**Syntaxe** :
```
/setjob [id] [job] [grade]
```

**Paramètres** :
- `id` : ID du joueur
- `job` : Nom du métier
- `grade` : Grade (optionnel, défaut: 0)

**Permissions** :
- Groupe "admin" requis

**Exemples** :
```
/setjob 1 police 2
> Job défini pour John Doe: police (Grade: 2)

/setjob 2 ambulance
> Job défini pour Jane Smith: ambulance (Grade: 0)

/setjob 3 unemployed
> Job défini pour Bob: unemployed (Grade: 0)
```

**Code** :
```lua
RegisterCommand('setjob', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer and xPlayer.group == "admin" then
        local targetId = tonumber(args[1])
        local job = args[2]
        local grade = tonumber(args[3]) or 0
        
        if targetId and job then
            local xTarget = AMA.GetPlayer(targetId)
            if xTarget then
                xTarget:setJob(job, grade)
                TriggerClientEvent('ama:showNotification', source,
                    string.format("Job défini pour %s: %s (Grade: %d)", xTarget.name, job, grade))
            end
        else
            TriggerClientEvent('ama:showNotification', source, 
                "Usage: /setjob [id] [job] [grade]")
        end
    end
end)
```

---

### `/setcrew`

Définit le crew d'un joueur.

**Syntaxe** :
```
/setcrew [id] [crew] [grade]
```

**Paramètres** :
- `id` : ID du joueur
- `crew` : Nom du crew
- `grade` : Grade (optionnel, défaut: 0)

**Permissions** :
- Groupe "admin" requis

**Exemples** :
```
/setcrew 1 mafia 2
> Crew défini pour John Doe: mafia (Grade: 2)

/setcrew 2 cartel
> Crew défini pour Jane Smith: cartel (Grade: 0)

/setcrew 3 none
> John a quitté son crew
```

---

## Commandes AMACoin

### `/wallet`

Affiche les informations de votre wallet AMACoin.

**Syntaxe** :
```
/wallet
```

**Résultat** :
```
=== AMACoin Wallet ===
UUID: 550e8400-e29b-41d4-a716-446655440000
Solde: 5.2500 ₿
Valeur: $525
Taux: 1 ₿ = $100
```

**Code** :
```lua
RegisterCommand('wallet', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer then
        local info = string.format(
            "^5=== AMACoin Wallet ===^7\n" ..
            "UUID: %s\n" ..
            "Solde: %.4f %s\n" ..
            "Valeur: $%d\n" ..
            "Taux: 1 %s = $%d",
            xPlayer.wallet_uuid,
            xPlayer.bitcoin,
            Config.AMACoin.Symbol,
            math.floor(xPlayer.bitcoin * Config.AMACoin.ExchangeRate),
            Config.AMACoin.Symbol,
            Config.AMACoin.ExchangeRate
        )
        
        TriggerClientEvent('chat:addMessage', source, {args = {info}})
    end
end, false)
```

---

### `/sendcoin`

Envoie des AMACoins à un autre joueur.

**Syntaxe** :
```
/sendcoin [wallet_uuid] [montant]
```

**Paramètres** :
- `wallet_uuid` : UUID du wallet du destinataire
- `montant` : Montant en AMACoin à envoyer

**Exemples** :
```
/sendcoin 550e8400-e29b-41d4-a716-446655440000 0.5
> Envoyé 0.5000 ₿ à John Doe (Frais: 0.0125 ₿)

/sendcoin 123e4567-e89b-12d3-a456-426614174000 1.0
> Envoyé 1.0000 ₿ à Jane Smith (Frais: 0.0250 ₿)
```

**Erreurs possibles** :
```
/sendcoin
> Usage: /sendcoin [wallet_uuid] [montant]

/sendcoin INVALID_UUID 0.5
> Wallet introuvable

/sendcoin 550e8400-e29b-41d4-a716-446655440000 0.001
> Montant minimum: 0.01 ₿

/sendcoin 550e8400-e29b-41d4-a716-446655440000 100
> Solde insuffisant (Frais: 2.5 ₿)
```

---

### `/givecoin`

Donne des AMACoins à un joueur (admin).

**Syntaxe** :
```
/givecoin [id] [montant]
```

**Paramètres** :
- `id` : ID du joueur
- `montant` : Montant en AMACoin

**Permissions** :
- Groupe "admin" requis

**Exemples** :
```
/givecoin 1 5.0
> Donné 5.0000 ₿ à John Doe

/givecoin 2 10.5
> Donné 10.5000 ₿ à Jane Smith
```

---

### `/cashout`

Convertit des AMACoins en argent liquide.

**Syntaxe** :
```
/cashout [montant_bitcoin]
```

**Paramètres** :
- `montant_bitcoin` : Montant en AMACoin à convertir

**Exemples** :
```
/cashout 1.0
> Converti 1.00 ₿ en $97 (Frais: $3)

/cashout 5.0
> Converti 5.00 ₿ en $487 (Frais: $13)
```

**Calcul** :
- Montant en argent = montant_bitcoin × taux_de_change
- Frais = montant_argent × (pourcentage_frais / 100)
- Argent reçu = montant_argent - frais

**Exemple avec Config.AMACoin.ExchangeRate = 100 et TransactionFee = 2.5%** :
- 1.0 ₿ → $100 - $2.5 = $97.5

---

### `/buycoin`

Convertit de l'argent liquide en AMACoins.

**Syntaxe** :
```
/buycoin [montant_argent]
```

**Paramètres** :
- `montant_argent` : Montant en argent à convertir

**Exemples** :
```
/buycoin 100
> Converti $100 en 1.00 ₿ (Frais: $3)

/buycoin 500
> Converti $500 en 5.00 ₿ (Frais: $13)
```

**Calcul** :
- Montant en AMACoin = montant_argent / taux_de_change
- Frais = montant_argent × (pourcentage_frais / 100)
- Argent total requis = montant_argent + frais

---

## Commandes crew

### `/crew`

Affiche les informations de votre crew.

**Syntaxe** :
```
/crew
```

**Résultat** :
```
=== Crew: La Mafia ===
Membres en ligne: 3
Coffre: $50000
Votre grade: 2 (Lieutenant)
Salaire: $1500

Membres:
- John Doe (Grade 3)
- Jane Smith (Grade 2)
- Bob Johnson (Grade 1)
```

**Code** :
```lua
RegisterCommand('crew', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer or xPlayer.crew == "none" then
        TriggerClientEvent('ama:showNotification', source, "Vous n'êtes dans aucun crew")
        return
    end
    
    TriggerEvent('ama:getCrewInfo', source)
end, false)
```

---

## Commandes de debug

### `/showpos`

Active/désactive l'affichage de la position en temps réel.

**Syntaxe** :
```
/showpos
```

**Effets** :
- Affiche vos coordonnées en continu à l'écran
- Utile pour le développement et le placement d'objets

**Code client** :
```lua
local showPos = false

RegisterCommand('showpos', function()
    showPos = not showPos
    AMA.ShowNotification(showPos and "Position activée" or "Position désactivée")
end)

CreateThread(function()
    while true do
        Wait(0)
        
        if showPos then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            
            local x = AMA.Round(coords.x, 2)
            local y = AMA.Round(coords.y, 2)
            local z = AMA.Round(coords.z, 2)
            local h = AMA.Round(heading, 2)
            
            SetTextFont(4)
            SetTextScale(0.4, 0.4)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(string.format("X: %.2f Y: %.2f Z: %.2f H: %.2f", x, y, z, h))
            DrawText(0.5, 0.9)
        else
            Wait(500)
        end
    end
end)
```

---

## Créer des commandes personnalisées

### Commande simple (client)

```lua
RegisterCommand('macommande', function()
    print("Commande exécutée!")
    AMA.ShowNotification("Commande exécutée")
end, false)  -- false = pas de restriction
```

---

### Commande avec arguments (client)

```lua
RegisterCommand('saluer', function(source, args, rawCommand)
    local nom = args[1]
    
    if not nom then
        AMA.ShowNotification("Usage: /saluer [nom]")
        return
    end
    
    AMA.ShowNotification("Bonjour " .. nom .. "!")
end, false)
```

**Utilisation** :
```
/saluer John
> Bonjour John!
```

---

### Commande serveur simple

```lua
RegisterCommand('hello', function(source, args, rawCommand)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer then
        TriggerClientEvent('ama:showNotification', source, 
            "Bonjour " .. xPlayer.firstname .. "!")
    end
end, false)
```

---

### Commande avec permissions

```lua
RegisterCommand('admincommand', function(source, args, rawCommand)
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer or xPlayer.group ~= "admin" then
        TriggerClientEvent('ama:showNotification', source, "Vous n'avez pas la permission")
        return
    end
    
    -- Votre code admin ici
    TriggerClientEvent('ama:showNotification', source, "Commande admin exécutée")
end, false)
```

---

### Commande avec vérification de job

```lua
RegisterCommand('policeaction', function(source, args, rawCommand)
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    local job = xPlayer:getJob()
    if job.name ~= "police" then
        TriggerClientEvent('ama:showNotification', source, "Vous devez être policier")
        return
    end
    
    if job.grade < 2 then
        TriggerClientEvent('ama:showNotification', source, "Grade insuffisant (minimum 2)")
        return
    end
    
    -- Action police
    TriggerClientEvent('ama:showNotification', source, "Action effectuée")
end, false)
```

---

### Commande avec vérification de crew

```lua
RegisterCommand('crewaction', function(source, args, rawCommand)
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    local crew = xPlayer:getCrew()
    if crew.name == "none" then
        TriggerClientEvent('ama:showNotification', source, "Vous devez être dans un crew")
        return
    end
    
    if not xPlayer:hasCrewPermission("special_action") then
        TriggerClientEvent('ama:showNotification', source, "Permission insuffisante")
        return
    end
    
    -- Action crew
    TriggerClientEvent('ama:showNotification', source, "Action de crew effectuée")
end, false)
```

---

### Commande avec callback serveur

**Client** :
```lua
RegisterCommand('checkbalance', function()
    AMA.TriggerServerCallback('getPlayerBalance', function(money, bank)
        AMA.ShowNotification(string.format("Liquide: $%d | Banque: $%d", money, bank))
    end)
end, false)
```

**Serveur** :
```lua
AMA.RegisterServerCallback('getPlayerBalance', function(source, cb)
    local xPlayer = AMA.GetPlayer(source)
    if xPlayer then
        cb(xPlayer.money, xPlayer.bank)
    else
        cb(0, 0)
    end
end)
```

---

### Commande avec menu NUI

**Client** :
```lua
RegisterCommand('menu', function()
    if not AMA.IsPlayerLoaded() then return end
    
    local data = AMA.GetPlayerData()
    
    SendNUIMessage({
        action = "openMenu",
        data = {
            money = data.money,
            bank = data.bank,
            job = data.job,
            crew = data.crew
        }
    })
    
    SetNuiFocus(true, true)
end, false)

-- Callback NUI
RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
```

---

### Suggestions de commandes

```lua
-- Ajouter des suggestions pour les commandes
TriggerEvent('chat:addSuggestion', '/givemoney', 'Donner de l\'argent à un joueur', {
    {name="id", help="ID du joueur"},
    {name="montant", help="Montant à donner"}
})

TriggerEvent('chat:addSuggestion', '/tp', 'Se téléporter vers un joueur', {
    {name="id", help="ID du joueur"}
})

TriggerEvent('chat:addSuggestion', '/setjob', 'Définir le job d\'un joueur', {
    {name="id", help="ID du joueur"},
    {name="job", help="Nom du job"},
    {name="grade", help="Grade (optionnel)"}
})
```

---

## 📚 Voir aussi

- [API Serveur](API_SERVEUR.md) - Pour créer des commandes serveur avancées
- [API Client](API_CLIENT.md) - Pour créer des commandes client avancées
- [Exemples de code](EXEMPLES_CODE.md) - Plus d'exemples de commandes

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2025
