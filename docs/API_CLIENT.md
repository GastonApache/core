# 💻 API Client - Framework AMA

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Fonctions client](#fonctions-client)
3. [Événements](#événements)
4. [Callbacks](#callbacks)
5. [Notifications](#notifications)
6. [Données du joueur](#données-du-joueur)
7. [Exemples pratiques](#exemples-pratiques)

---

## Vue d'ensemble

L'API client du framework AMA permet d'interagir avec le joueur local, d'afficher des notifications, de gérer les événements et de communiquer avec le serveur.

### Objet global

```lua
-- Objet global AMA côté client
AMA = {}

-- Variables locales
PlayerLoaded = false  -- Le joueur est-il chargé ?
PlayerData = {}       -- Données du joueur local
```

---

## Fonctions client

### `AMA.GetPlayerData()`

Obtient les données complètes du joueur local.

**Retour** :
- (table) : Données du joueur

**Exemple** :
```lua
local playerData = AMA.GetPlayerData()
print("Nom:", playerData.firstname, playerData.lastname)
print("Argent:", playerData.money)
print("Job:", playerData.job)
print("Crew:", playerData.crew)
```

**Structure des données** :
```lua
{
    source = number,        -- ID du joueur
    identifier = string,    -- Identifier unique
    uuid = string,          -- UUID unique
    wallet_uuid = string,   -- UUID du wallet AMACoin
    firstname = string,     -- Prénom
    lastname = string,      -- Nom
    money = number,         -- Argent liquide
    bank = number,          -- Compte bancaire
    bitcoin = number,       -- Solde AMACoin
    job = string,           -- Métier
    job_grade = number,     -- Grade du métier
    crew = string,          -- Crew
    crew_grade = number,    -- Grade du crew
    group = string,         -- Groupe (user, admin)
    position = table,       -- Position {x, y, z, heading}
    inventory = table,      -- Inventaire
    accounts = table        -- Comptes additionnels
}
```

---

### `AMA.IsPlayerLoaded()`

Vérifie si le joueur est chargé.

**Retour** :
- (boolean) : true si chargé, false sinon

**Exemple** :
```lua
if AMA.IsPlayerLoaded() then
    print("Joueur chargé et prêt")
    -- Initialiser votre script
else
    print("En attente du chargement...")
end
```

**Utilisation recommandée** :
```lua
CreateThread(function()
    while not AMA.IsPlayerLoaded() do
        Wait(100)
    end
    
    -- Le joueur est maintenant chargé
    print("Joueur chargé!")
    InitMonScript()
end)
```

---

### `AMA.ShowNotification(message, type)`

Affiche une notification au joueur.

**Paramètres** :
- `message` (string) : Message à afficher
- `type` (string, optionnel) : Type de notification

**Exemple** :
```lua
AMA.ShowNotification("Bienvenue sur le serveur!")
AMA.ShowNotification("Attention!", "warning")
AMA.ShowNotification("Erreur critique", "error")
```

---

### `AMA.Round(value, decimals)`

Arrondit un nombre à N décimales.

**Paramètres** :
- `value` (number) : Nombre à arrondir
- `decimals` (number) : Nombre de décimales

**Retour** :
- (number) : Nombre arrondi

**Exemple** :
```lua
local rounded = AMA.Round(123.456789, 2)
print(rounded)  -- 123.46

local coords = GetEntityCoords(PlayerPedId())
local x = AMA.Round(coords.x, 2)
local y = AMA.Round(coords.y, 2)
local z = AMA.Round(coords.z, 2)
print(x, y, z)
```

---

## Événements

### Événements de réception

Ces événements sont déclenchés par le serveur et reçus par le client.

#### `ama:playerSpawn`

Déclenché quand le joueur spawn.

**Paramètres** :
- `playerData` (table) : Données du joueur

**Exemple** :
```lua
RegisterNetEvent('ama:playerSpawn')
AddEventHandler('ama:playerSpawn', function(playerData)
    print("Spawn du joueur:", playerData.firstname)
    PlayerLoaded = true
    PlayerData = playerData
    
    -- Initialiser votre UI, HUD, etc.
end)
```

---

#### `ama:showNotification`

Affiche une notification.

**Paramètres** :
- `message` (string) : Message
- `type` (string, optionnel) : Type

**Exemple** :
```lua
RegisterNetEvent('ama:showNotification')
AddEventHandler('ama:showNotification', function(message, type)
    -- Gestion automatique par le framework
    -- Ou personnalisez :
    if type == "error" then
        -- Afficher en rouge
    end
end)
```

---

#### `ama:updateMoney`

Met à jour l'argent liquide.

**Paramètres** :
- `money` (number) : Nouveau montant

**Exemple** :
```lua
RegisterNetEvent('ama:updateMoney')
AddEventHandler('ama:updateMoney', function(money)
    PlayerData.money = money
    
    -- Mettre à jour votre HUD
    SendNUIMessage({
        action = "updateMoney",
        money = money
    })
end)
```

---

#### `ama:updateBank`

Met à jour le compte bancaire.

**Paramètres** :
- `bank` (number) : Nouveau montant

**Exemple** :
```lua
RegisterNetEvent('ama:updateBank')
AddEventHandler('ama:updateBank', function(bank)
    PlayerData.bank = bank
    
    -- Mettre à jour votre HUD
    SendNUIMessage({
        action = "updateBank",
        bank = bank
    })
end)
```

---

#### `ama:updateBitcoin`

Met à jour le solde AMACoin.

**Paramètres** :
- `bitcoin` (number) : Nouveau montant

**Exemple** :
```lua
RegisterNetEvent('ama:updateBitcoin')
AddEventHandler('ama:updateBitcoin', function(bitcoin)
    PlayerData.bitcoin = bitcoin
    
    -- Mettre à jour votre HUD
    SendNUIMessage({
        action = "updateBitcoin",
        bitcoin = bitcoin
    })
end)
```

---

#### `ama:setJob`

Change le métier du joueur.

**Paramètres** :
- `job` (string) : Nouveau métier
- `grade` (number) : Grade

**Exemple** :
```lua
RegisterNetEvent('ama:setJob')
AddEventHandler('ama:setJob', function(job, grade)
    PlayerData.job = job
    PlayerData.job_grade = grade
    
    print("Nouveau job:", job, "Grade:", grade)
    AMA.ShowNotification(string.format("Nouveau métier: %s (Grade %d)", job, grade))
end)
```

---

#### `ama:setCrew`

Change le crew du joueur.

**Paramètres** :
- `crew` (string) : Nouveau crew
- `grade` (number) : Grade

**Exemple** :
```lua
RegisterNetEvent('ama:setCrew')
AddEventHandler('ama:setCrew', function(crew, grade)
    PlayerData.crew = crew
    PlayerData.crew_grade = grade
    
    if crew ~= "none" then
        print("Crew:", crew, "Grade:", grade)
    end
end)
```

---

#### `ama:teleportPlayer`

Téléporte le joueur.

**Paramètres** :
- `coords` (table) : Coordonnées {x, y, z}

**Exemple** :
```lua
RegisterNetEvent('ama:teleportPlayer')
AddEventHandler('ama:teleportPlayer', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
    AMA.ShowNotification("Téléportation effectuée")
end)
```

---

#### `ama:receiveWalletUUID`

Reçoit l'UUID du wallet AMACoin.

**Paramètres** :
- `walletUUID` (string) : UUID du wallet

**Exemple** :
```lua
RegisterNetEvent('ama:receiveWalletUUID')
AddEventHandler('ama:receiveWalletUUID', function(walletUUID)
    print("Wallet UUID:", walletUUID)
    -- Afficher dans une UI
end)
```

---

#### `ama:receiveWalletInfo`

Reçoit les informations complètes du wallet.

**Paramètres** :
- `walletInfo` (table) : Infos du wallet

**Exemple** :
```lua
RegisterNetEvent('ama:receiveWalletInfo')
AddEventHandler('ama:receiveWalletInfo', function(info)
    print("UUID:", info.uuid)
    print("Balance:", info.balance, info.symbol)
    print("Taux:", "1", info.symbol, "=", info.exchangeRate, "$")
    print("Frais:", info.fee, "%")
end)
```

---

#### `ama:receiveBitcoinHistory`

Reçoit l'historique des transactions AMACoin.

**Paramètres** :
- `history` (table) : Liste des transactions

**Exemple** :
```lua
RegisterNetEvent('ama:receiveBitcoinHistory')
AddEventHandler('ama:receiveBitcoinHistory', function(history)
    print("Historique:", #history, "transactions")
    
    for _, transaction in ipairs(history) do
        print(transaction.type, transaction.amount, transaction.created_at)
    end
end)
```

---

#### `ama:receiveCrewInfo`

Reçoit les informations du crew.

**Paramètres** :
- `crewInfo` (table) : Infos du crew

**Exemple** :
```lua
RegisterNetEvent('ama:receiveCrewInfo')
AddEventHandler('ama:receiveCrewInfo', function(info)
    print("Crew:", info.label)
    print("Couleur:", info.color)
    print("Membres:", #info.members)
    print("Coffre:", info.bank, "$")
    print("Votre grade:", info.your_grade)
    print("Salaire:", info.salary, "$")
    
    -- Afficher dans une UI
    for _, member in ipairs(info.members) do
        print("-", member.name, "Grade", member.grade)
    end
end)
```

---

### Événements d'envoi

Ces événements sont déclenchés par le client et envoyés au serveur.

#### Envoyer des AMACoins

```lua
TriggerServerEvent('ama:sendBitcoin', receiverWalletUUID, amount)
```

#### Convertir AMACoins en argent

```lua
TriggerServerEvent('ama:convertBitcoinToMoney', bitcoinAmount)
```

#### Convertir argent en AMACoins

```lua
TriggerServerEvent('ama:convertMoneyToBitcoin', moneyAmount)
```

#### Obtenir l'historique AMACoin

```lua
TriggerServerEvent('ama:getBitcoinHistory')
```

#### Obtenir l'UUID du wallet

```lua
TriggerServerEvent('ama:getWalletUUID')
```

#### Obtenir les infos du wallet

```lua
TriggerServerEvent('ama:getWalletInfo')
```

#### Rejoindre un crew

```lua
TriggerServerEvent('ama:joinCrew', crewName, grade)
```

#### Quitter un crew

```lua
TriggerServerEvent('ama:leaveCrew')
```

#### Obtenir les infos du crew

```lua
TriggerServerEvent('ama:getCrewInfo')
```

#### Déposer de l'argent dans le coffre du crew

```lua
TriggerServerEvent('ama:depositCrewMoney', amount)
```

#### Retirer de l'argent du coffre du crew

```lua
TriggerServerEvent('ama:withdrawCrewMoney', amount)
```

#### Sauvegarder la position

```lua
local ped = PlayerPedId()
local coords = GetEntityCoords(ped)
local heading = GetEntityHeading(ped)

local positionData = {
    x = coords.x,
    y = coords.y,
    z = coords.z,
    heading = heading
}

TriggerServerEvent('ama:savePosition', positionData)
```

---

## Callbacks

### `AMA.TriggerServerCallback(name, callback, ...)`

Appelle un callback serveur et attend la réponse.

**Paramètres** :
- `name` (string) : Nom du callback
- `callback` (function) : Fonction de retour
- `...` : Arguments à passer

**Exemple** :
```lua
-- Obtenir l'argent du joueur
AMA.TriggerServerCallback('getPlayerMoney', function(money)
    print("Argent:", money)
end)

-- Avec arguments
AMA.TriggerServerCallback('checkPermission', function(hasPermission)
    if hasPermission then
        print("Autorisé")
    end
end, "admin")
```

**Créer un callback serveur** :

Côté serveur :
```lua
AMA.RegisterServerCallback('getPlayerMoney', function(source, cb)
    local xPlayer = AMA.GetPlayer(source)
    if xPlayer then
        cb(xPlayer.money)
    else
        cb(0)
    end
end)
```

---

## Notifications

### Types de notifications

Le framework supporte plusieurs types de notifications.

#### Notification standard

```lua
AMA.ShowNotification("Message simple")
```

#### Notification avec type

```lua
AMA.ShowNotification("Information", "info")
AMA.ShowNotification("Avertissement", "warning")
AMA.ShowNotification("Erreur", "error")
AMA.ShowNotification("Succès", "success")
```

#### Notification depuis le serveur

Côté serveur :
```lua
TriggerClientEvent('ama:showNotification', source, "Message au joueur")
```

Côté client (réception automatique) :
```lua
-- Géré automatiquement par le framework
```

---

## Données du joueur

### Accéder aux données

```lua
local data = AMA.GetPlayerData()

-- Informations personnelles
print("Nom:", data.firstname, data.lastname)
print("UUID:", data.uuid)

-- Finances
print("Argent:", data.money)
print("Banque:", data.bank)
print("AMACoin:", data.bitcoin)

-- Job
print("Métier:", data.job)
print("Grade:", data.job_grade)

-- Crew
print("Crew:", data.crew)
print("Grade crew:", data.crew_grade)

-- Groupe
print("Groupe:", data.group)  -- "user" ou "admin"

-- Position
if data.position then
    print("Position:", data.position.x, data.position.y, data.position.z)
end
```

### Vérifier les données

```lua
-- Vérifier si le joueur est chargé
if not AMA.IsPlayerLoaded() then
    print("Joueur non chargé")
    return
end

-- Vérifier si le joueur a assez d'argent
local data = AMA.GetPlayerData()
if data.money < 1000 then
    AMA.ShowNotification("Vous n'avez pas assez d'argent")
    return
end

-- Vérifier le job
if data.job == "police" and data.job_grade >= 2 then
    print("Sergent de police ou supérieur")
end

-- Vérifier le crew
if data.crew ~= "none" then
    print("Membre d'un crew:", data.crew)
end
```

---

## Exemples pratiques

### Système de HUD

```lua
-- Initialisation du HUD
CreateThread(function()
    while not AMA.IsPlayerLoaded() do
        Wait(100)
    end
    
    -- Joueur chargé, afficher le HUD
    SendNUIMessage({
        action = "showHUD",
        data = AMA.GetPlayerData()
    })
end)

-- Mise à jour de l'argent
RegisterNetEvent('ama:updateMoney')
AddEventHandler('ama:updateMoney', function(money)
    SendNUIMessage({
        action = "updateMoney",
        money = money
    })
end)

-- Mise à jour de la banque
RegisterNetEvent('ama:updateBank')
AddEventHandler('ama:updateBank', function(bank)
    SendNUIMessage({
        action = "updateBank",
        bank = bank
    })
end)
```

### Menu AMACoin

```lua
RegisterCommand('bitcoin', function()
    if not AMA.IsPlayerLoaded() then return end
    
    -- Obtenir les infos du wallet
    TriggerServerEvent('ama:getWalletInfo')
end)

RegisterNetEvent('ama:receiveWalletInfo')
AddEventHandler('ama:receiveWalletInfo', function(info)
    -- Afficher un menu NUI avec les infos
    SendNUIMessage({
        action = "openBitcoinMenu",
        wallet = info
    })
end)

-- Callback NUI pour envoyer des coins
RegisterNUICallback('sendBitcoin', function(data, cb)
    TriggerServerEvent('ama:sendBitcoin', data.receiverWallet, data.amount)
    cb('ok')
end)

-- Callback NUI pour convertir
RegisterNUICallback('convertToMoney', function(data, cb)
    TriggerServerEvent('ama:convertBitcoinToMoney', data.amount)
    cb('ok')
end)
```

### Indicateur de position

```lua
-- Afficher la position en continu
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
            
            -- Afficher à l'écran
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

### Menu crew

```lua
RegisterCommand('crewmenu', function()
    if not AMA.IsPlayerLoaded() then return end
    
    local data = AMA.GetPlayerData()
    if data.crew == "none" then
        AMA.ShowNotification("Vous n'êtes dans aucun crew")
        return
    end
    
    -- Obtenir les infos du crew
    TriggerServerEvent('ama:getCrewInfo')
end)

RegisterNetEvent('ama:receiveCrewInfo')
AddEventHandler('ama:receiveCrewInfo', function(info)
    -- Afficher un menu avec les infos
    SendNUIMessage({
        action = "openCrewMenu",
        crew = info
    })
end)

-- Callback pour déposer de l'argent
RegisterNUICallback('depositMoney', function(data, cb)
    TriggerServerEvent('ama:depositCrewMoney', data.amount)
    cb('ok')
end)

-- Callback pour retirer de l'argent
RegisterNUICallback('withdrawMoney', function(data, cb)
    TriggerServerEvent('ama:withdrawCrewMoney', data.amount)
    cb('ok')
end)
```

### Sauvegarde manuelle

```lua
RegisterCommand('save', function()
    if not AMA.IsPlayerLoaded() then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    local positionData = {
        x = AMA.Round(coords.x, 2),
        y = AMA.Round(coords.y, 2),
        z = AMA.Round(coords.z, 2),
        heading = AMA.Round(heading, 2)
    }
    
    TriggerServerEvent('ama:savePosition', positionData)
    AMA.ShowNotification("Position sauvegardée")
end)
```

### Vérification de permissions

```lua
function HasPermission(permission)
    local data = AMA.GetPlayerData()
    
    if permission == "admin" then
        return data.group == "admin"
    end
    
    if permission == "police" then
        return data.job == "police"
    end
    
    if permission == "crew_manage" then
        return data.crew ~= "none" and data.crew_grade >= 2
    end
    
    return false
end

-- Utilisation
RegisterCommand('adminmenu', function()
    if not HasPermission("admin") then
        AMA.ShowNotification("Vous n'avez pas la permission")
        return
    end
    
    -- Ouvrir le menu admin
end)
```

### Affichage des FPS

```lua
local showFPS = false

RegisterCommand('fps', function()
    showFPS = not showFPS
    AMA.ShowNotification(showFPS and "FPS activé" or "FPS désactivé")
end)

CreateThread(function()
    while true do
        Wait(0)
        
        if showFPS then
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
```

---

## 📚 Voir aussi

- [API Serveur](API_SERVEUR.md) - Documentation de l'API serveur
- [Exemples de code](EXEMPLES_CODE.md) - Plus d'exemples pratiques
- [Commandes](COMMANDES.md) - Liste des commandes

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2025
