# 🖥️ API Serveur - Framework AMA

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Fonctions globales](#fonctions-globales)
3. [Classe Player](#classe-player)
4. [Gestion de l'argent](#gestion-de-largent)
5. [Système de jobs](#système-de-jobs)
6. [Système de crews](#système-de-crews)
7. [Bitcoin/AMACoin](#bitcoinamacoin)
8. [Callbacks serveur](#callbacks-serveur)
9. [Exports](#exports)

---

## Vue d'ensemble

L'API serveur du framework AMA fournit toutes les fonctions nécessaires pour gérer les joueurs, l'économie, les jobs et les crews. Toutes les fonctions sont accessibles via l'objet global `AMA`.

### Structure de base

```lua
-- Objet global AMA
AMA = {}
AMA.Players = {}  -- Table des joueurs connectés
AMA.Callbacks = {}  -- Callbacks serveur

-- Accès à un joueur
local xPlayer = AMA.GetPlayer(source)
```

---

## Fonctions globales

### `AMA.GetPlayer(source)`

Obtient l'objet Player d'un joueur connecté.

**Paramètres** :
- `source` (number) : ID du joueur

**Retour** :
- (Player|nil) : Objet Player ou nil si introuvable

**Exemple** :
```lua
local xPlayer = AMA.GetPlayer(source)
if xPlayer then
    print(xPlayer.name, xPlayer.money)
end
```

---

### `AMA.GetPlayers()`

Obtient tous les joueurs connectés.

**Retour** :
- (table) : Table des objets Player

**Exemple** :
```lua
local players = AMA.GetPlayers()
for _, xPlayer in pairs(players) do
    print(xPlayer.name, xPlayer.job)
end
```

---

### `AMA.GetPlayerFromIdentifier(identifier)`

Recherche un joueur par son identifier.

**Paramètres** :
- `identifier` (string) : Identifier du joueur

**Retour** :
- (Player|nil) : Objet Player ou nil

**Exemple** :
```lua
local xPlayer = AMA.GetPlayerFromIdentifier("license:abc123")
if xPlayer then
    xPlayer:addMoney(1000)
end
```

---

### `AMA.GenerateUUID()`

Génère un UUID unique.

**Retour** :
- (string) : UUID au format standard

**Exemple** :
```lua
local uuid = AMA.GenerateUUID()
print(uuid)  -- "550e8400-e29b-41d4-a716-446655440000"
```

---

### `AMA.Log(level, message)`

Affiche un log dans la console serveur.

**Paramètres** :
- `level` (string) : "INFO", "WARN", "ERROR", "DEBUG"
- `message` (string) : Message à logger

**Exemple** :
```lua
AMA.Log("INFO", "Serveur démarré")
AMA.Log("WARN", "Attention: configuration manquante")
AMA.Log("ERROR", "Erreur critique détectée")
AMA.Log("DEBUG", "Variable: " .. tostring(var))
```

---

### `AMA.TriggerHook(hookName, ...)`

Déclenche un hook personnalisé.

**Paramètres** :
- `hookName` (string) : Nom du hook
- `...` : Arguments à passer

**Retour** :
- (any) : Valeur de retour du hook

**Exemple** :
```lua
-- Déclencher
local result = AMA.TriggerHook("mon:hook:custom", player, amount)

-- Enregistrer
AMA.RegisterHook("mon:hook:custom", function(player, amount)
    print(player.name, amount)
    return true
end)
```

---

## Classe Player

### Propriétés

```lua
xPlayer.source          -- (number) ID du joueur
xPlayer.identifier      -- (string) Identifier unique
xPlayer.uuid            -- (string) UUID unique
xPlayer.wallet_uuid     -- (string) UUID du wallet AMACoin
xPlayer.name            -- (string) Nom du joueur
xPlayer.firstname       -- (string) Prénom
xPlayer.lastname        -- (string) Nom de famille
xPlayer.money           -- (number) Argent liquide
xPlayer.bank            -- (number) Compte bancaire
xPlayer.bitcoin         -- (number) Solde AMACoin
xPlayer.job             -- (string) Métier actuel
xPlayer.job_grade       -- (number) Grade du métier
xPlayer.crew            -- (string) Crew/Organisation
xPlayer.crew_grade      -- (number) Grade dans le crew
xPlayer.group           -- (string) Groupe (user, admin)
xPlayer.position        -- (table) Dernière position
xPlayer.inventory       -- (table) Inventaire
xPlayer.accounts        -- (table) Comptes additionnels
```

### Constructeur

### `Player:new(data)`

Crée un nouvel objet Player.

**Paramètres** :
- `data` (table) : Données du joueur

**Retour** :
- (Player) : Objet Player

**Exemple** :
```lua
local playerData = {
    source = source,
    identifier = "license:abc123",
    money = 5000,
    bank = 10000
}
local xPlayer = Player:new(playerData)
```

---

## Gestion de l'argent

### `xPlayer:getMoney()`

Obtient l'argent liquide du joueur.

**Retour** :
- (number) : Montant d'argent liquide

**Exemple** :
```lua
local money = xPlayer:getMoney()
print("Argent liquide:", money)
```

---

### `xPlayer:addMoney(amount, reason)`

Ajoute de l'argent liquide au joueur.

**Paramètres** :
- `amount` (number) : Montant à ajouter
- `reason` (string, optionnel) : Raison de la transaction

**Exemple** :
```lua
xPlayer:addMoney(500, "Salaire")
xPlayer:addMoney(1000)
```

**Effets** :
- Met à jour `xPlayer.money`
- Envoie l'événement `ama:updateMoney` au client
- Déclenche le hook `ama:hook:moneyChanged`
- Log Discord si activé

---

### `xPlayer:removeMoney(amount, reason)`

Retire de l'argent liquide du joueur.

**Paramètres** :
- `amount` (number) : Montant à retirer
- `reason` (string, optionnel) : Raison de la transaction

**Retour** :
- (boolean) : true si succès, false si solde insuffisant

**Exemple** :
```lua
if xPlayer:removeMoney(100, "Achat") then
    print("Achat effectué")
else
    TriggerClientEvent('ama:showNotification', xPlayer.source, "Argent insuffisant")
end
```

---

### `xPlayer:getBank()`

Obtient le solde bancaire du joueur.

**Retour** :
- (number) : Solde bancaire

**Exemple** :
```lua
local bank = xPlayer:getBank()
print("Banque:", bank)
```

---

### `xPlayer:addBank(amount, reason)`

Ajoute de l'argent au compte bancaire.

**Paramètres** :
- `amount` (number) : Montant à ajouter
- `reason` (string, optionnel) : Raison

**Exemple** :
```lua
xPlayer:addBank(5000, "Dépôt")
```

---

### `xPlayer:removeBank(amount, reason)`

Retire de l'argent du compte bancaire.

**Paramètres** :
- `amount` (number) : Montant à retirer
- `reason` (string, optionnel) : Raison

**Retour** :
- (boolean) : true si succès, false si insuffisant

**Exemple** :
```lua
if xPlayer:removeBank(1000, "Retrait") then
    xPlayer:addMoney(1000, "Retrait bancaire")
end
```

---

## Système de jobs

### `xPlayer:setJob(job, grade)`

Change le métier du joueur.

**Paramètres** :
- `job` (string) : Nom du métier
- `grade` (number, optionnel) : Grade (défaut: 0)

**Exemple** :
```lua
xPlayer:setJob("police", 2)
xPlayer:setJob("ambulance")  -- Grade 0 par défaut
```

**Effets** :
- Met à jour `xPlayer.job` et `xPlayer.job_grade`
- Envoie l'événement `ama:setJob` au client
- Déclenche le hook `ama:hook:jobChanged`
- Log Discord si activé

---

### `xPlayer:getJob()`

Obtient les informations du métier actuel.

**Retour** :
- (table) : {name = string, grade = number}

**Exemple** :
```lua
local job = xPlayer:getJob()
print("Job:", job.name, "Grade:", job.grade)

if job.name == "police" and job.grade >= 2 then
    print("Sergent ou supérieur")
end
```

---

## Système de crews

### `xPlayer:setCrew(crew, grade)`

Fait rejoindre un crew au joueur.

**Paramètres** :
- `crew` (string) : Nom du crew
- `grade` (number, optionnel) : Grade (défaut: 0)

**Retour** :
- (boolean) : true si succès

**Exemple** :
```lua
if xPlayer:setCrew("mafia", 1) then
    print("Rejoint la mafia")
end

-- Quitter un crew
xPlayer:setCrew("none", 0)
```

**Effets** :
- Met à jour `xPlayer.crew` et `xPlayer.crew_grade`
- Envoie l'événement `ama:setCrew` au client
- Déclenche le hook `ama:hook:crewChanged`

---

### `xPlayer:getCrew()`

Obtient les informations du crew actuel.

**Retour** :
- (table) : {name = string, grade = number}

**Exemple** :
```lua
local crew = xPlayer:getCrew()
if crew.name ~= "none" then
    print("Membre de:", crew.name, "Grade:", crew.grade)
end
```

---

### `xPlayer:getCrewLabel()`

Obtient le nom affiché du crew.

**Retour** :
- (string) : Label du crew

**Exemple** :
```lua
local label = xPlayer:getCrewLabel()
print(label)  -- "La Mafia"
```

---

### `xPlayer:hasCrewPermission(permission)`

Vérifie si le joueur a une permission dans son crew.

**Paramètres** :
- `permission` (string) : Nom de la permission

**Retour** :
- (boolean) : true si possède la permission

**Exemple** :
```lua
if xPlayer:hasCrewPermission("manage_money") then
    -- Autoriser l'accès au coffre
end

-- Permissions disponibles:
-- "access_stash"   - Accès au coffre
-- "manage_money"   - Gérer l'argent
-- "promote"        - Promouvoir des membres
-- "kick"           - Exclure des membres
```

---

### `xPlayer:getCrewSalary()`

Obtient le salaire du crew du joueur.

**Retour** :
- (number) : Salaire

**Exemple** :
```lua
local salary = xPlayer:getCrewSalary()
print("Salaire crew:", salary)
```

---

### `AMA.Crews.GetCrewMembers(crewName)`

Obtient tous les membres d'un crew.

**Paramètres** :
- `crewName` (string) : Nom du crew

**Retour** :
- (table) : Liste des membres

**Exemple** :
```lua
local members = AMA.Crews.GetCrewMembers("mafia")
for _, member in ipairs(members) do
    print(member.name, member.grade)
end
```

---

### `AMA.Crews.GetCrewBank(crewName, callback)`

Obtient le solde du coffre d'un crew.

**Paramètres** :
- `crewName` (string) : Nom du crew
- `callback` (function) : Fonction de retour

**Exemple** :
```lua
AMA.Crews.GetCrewBank("mafia", function(bank)
    print("Coffre de la mafia:", bank)
end)
```

---

### `AMA.Crews.AddCrewBank(crewName, amount)`

Ajoute de l'argent au coffre du crew.

**Paramètres** :
- `crewName` (string) : Nom du crew
- `amount` (number) : Montant à ajouter

**Exemple** :
```lua
AMA.Crews.AddCrewBank("mafia", 10000)
```

**Effets** :
- Met à jour le coffre dans la BDD
- Notifie tous les membres du crew

---

### `AMA.Crews.RemoveCrewBank(crewName, amount, callback)`

Retire de l'argent du coffre du crew.

**Paramètres** :
- `crewName` (string) : Nom du crew
- `amount` (number) : Montant à retirer
- `callback` (function) : Fonction de retour

**Exemple** :
```lua
AMA.Crews.RemoveCrewBank("mafia", 5000, function(success)
    if success then
        print("Retrait effectué")
    else
        print("Solde insuffisant")
    end
end)
```

---

## Bitcoin/AMACoin

### `xPlayer:getBitcoin()`

Obtient le solde AMACoin du joueur.

**Retour** :
- (number) : Solde en AMACoin

**Exemple** :
```lua
local bitcoin = xPlayer:getBitcoin()
print("AMACoin:", bitcoin, "₿")
```

---

### `xPlayer:addBitcoin(amount, reason)`

Ajoute des AMACoins au joueur.

**Paramètres** :
- `amount` (number) : Montant à ajouter
- `reason` (string, optionnel) : Raison

**Retour** :
- (boolean) : true si succès

**Exemple** :
```lua
if xPlayer:addBitcoin(0.5, "Récompense") then
    print("AMACoins ajoutés")
end
```

**Limitations** :
- Respecte `Config.AMACoin.MaxPerPlayer`
- Vérifie que le système est activé

---

### `xPlayer:removeBitcoin(amount, reason)`

Retire des AMACoins au joueur.

**Paramètres** :
- `amount` (number) : Montant à retirer
- `reason` (string, optionnel) : Raison

**Retour** :
- (boolean) : true si succès

**Exemple** :
```lua
if xPlayer:removeBitcoin(0.25, "Achat") then
    print("AMACoins retirés")
end
```

---

### `xPlayer:convertBitcoinToMoney(bitcoinAmount)`

Convertit des AMACoins en argent liquide.

**Paramètres** :
- `bitcoinAmount` (number) : Montant en AMACoin à convertir

**Retour** :
- (boolean) : true si succès

**Exemple** :
```lua
-- Convertir 1 ₿ en argent
if xPlayer:convertBitcoinToMoney(1.0) then
    -- Avec ExchangeRate = 100 et TransactionFee = 2.5%
    -- Le joueur reçoit : 100 - 2.5 = $97.5
    print("Conversion effectuée")
end
```

**Calcul** :
```lua
moneyAmount = bitcoinAmount * Config.AMACoin.ExchangeRate
fee = moneyAmount * (Config.AMACoin.TransactionFee / 100)
finalAmount = moneyAmount - fee
```

---

### `xPlayer:convertMoneyToBitcoin(moneyAmount)`

Convertit de l'argent en AMACoins.

**Paramètres** :
- `moneyAmount` (number) : Montant en argent à convertir

**Retour** :
- (boolean) : true si succès

**Exemple** :
```lua
-- Convertir $100 en AMACoin
if xPlayer:convertMoneyToBitcoin(100) then
    -- Avec ExchangeRate = 100 et TransactionFee = 2.5%
    -- Coût total : $102.5
    -- Le joueur reçoit : 1 ₿
    print("Conversion effectuée")
end
```

---

### `xPlayer:getWalletUUID()`

Obtient l'UUID du wallet AMACoin du joueur.

**Retour** :
- (string) : UUID du wallet

**Exemple** :
```lua
local walletUUID = xPlayer:getWalletUUID()
print("Wallet:", walletUUID)
```

---

### `AMA.Bitcoin.SendCoins(senderSource, receiverWalletUUID, amount)`

Envoie des AMACoins à un autre joueur.

**Paramètres** :
- `senderSource` (number) : Source de l'expéditeur
- `receiverWalletUUID` (string) : UUID du wallet du destinataire
- `amount` (number) : Montant à envoyer

**Retour** :
- (boolean) : true si succès

**Exemple** :
```lua
local success = AMA.Bitcoin.SendCoins(source, targetWalletUUID, 0.5)
if success then
    print("Transaction effectuée")
end
```

**Vérifications** :
- Montant >= `Config.AMACoin.MinTransaction`
- Wallet destinataire existe
- Destinataire ≠ expéditeur
- Solde suffisant (montant + frais)

---

### `AMA.Bitcoin.GetTransactionHistory(walletUUID, callback)`

Obtient l'historique des transactions d'un wallet.

**Paramètres** :
- `walletUUID` (string) : UUID du wallet
- `callback` (function) : Fonction de retour

**Exemple** :
```lua
AMA.Bitcoin.GetTransactionHistory(walletUUID, function(history)
    for _, transaction in ipairs(history) do
        print(transaction.type, transaction.amount, transaction.created_at)
    end
end)
```

---

### `AMA.Bitcoin.GetExchangeRate()`

Obtient le taux de change actuel.

**Retour** :
- (number) : Taux de change (1 ₿ = X $)

**Exemple** :
```lua
local rate = AMA.Bitcoin.GetExchangeRate()
print("1 ₿ =", rate, "$")
```

---

### `AMA.Bitcoin.CalculateFee(amount)`

Calcule les frais de transaction.

**Paramètres** :
- `amount` (number) : Montant de la transaction

**Retour** :
- (number) : Montant des frais

**Exemple** :
```lua
local fee = AMA.Bitcoin.CalculateFee(1.0)
print("Frais:", fee, "₿")
```

---

## Callbacks serveur

### `AMA.RegisterServerCallback(name, callback)`

Enregistre un callback serveur.

**Paramètres** :
- `name` (string) : Nom du callback
- `callback` (function) : Fonction à exécuter

**Exemple** :
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

### Appeler un callback depuis le client

Côté client :
```lua
AMA.TriggerServerCallback('getPlayerMoney', function(money)
    print("Argent:", money)
end)
```

---

## Exports

### Exports disponibles

```lua
-- Obtenir un joueur
exports['framework']:GetPlayer(source)

-- Obtenir tous les joueurs
exports['framework']:GetPlayers()

-- Envoyer des AMACoins
exports['framework']:SendBitcoin(senderSource, receiverWalletUUID, amount)

-- Obtenir le taux de change
exports['framework']:GetExchangeRate()

-- Obtenir l'historique Bitcoin
exports['framework']:GetTransactionHistory(walletUUID, callback)

-- Obtenir les membres d'un crew
exports['framework']:GetCrewMembers(crewName)

-- Obtenir le coffre d'un crew
exports['framework']:GetCrewBank(crewName, callback)

-- Ajouter au coffre d'un crew
exports['framework']:AddCrewBank(crewName, amount)

-- Retirer du coffre d'un crew
exports['framework']:RemoveCrewBank(crewName, amount, callback)
```

### Exemple d'utilisation

```lua
-- Dans une autre ressource
RegisterCommand('checkplayer', function(source, args)
    local xPlayer = exports['framework']:GetPlayer(source)
    if xPlayer then
        print("Job:", xPlayer.job)
        print("Argent:", xPlayer.money)
    end
end)
```

---

## Événements serveur

### Événements intégrés

```lua
-- Connexion d'un joueur
AddEventHandler('ama:hook:playerConnected', function(source, identifier)
    -- Votre code
end)

-- Déconnexion d'un joueur
AddEventHandler('ama:hook:playerDisconnected', function(source, xPlayer)
    -- Votre code
end)

-- Données chargées
AddEventHandler('ama:hook:playerDataLoaded', function(source, xPlayer)
    -- Votre code
end)

-- Changement d'argent
AddEventHandler('ama:hook:moneyChanged', function(source, action, account, amount, reason)
    -- action: "add" ou "remove"
    -- account: "money", "bank", ou "bitcoin"
end)

-- Changement de job
AddEventHandler('ama:hook:jobChanged', function(source, oldJob, newJob, grade)
    -- Votre code
end)

-- Changement de crew
AddEventHandler('ama:hook:crewChanged', function(source, oldCrew, newCrew, grade)
    -- Votre code
end)

-- Changement d'AMACoin
AddEventHandler('ama:hook:bitcoinChanged', function(source, action, amount, reason)
    -- action: "add" ou "remove"
end)

-- Avant sauvegarde
AddEventHandler('ama:hook:beforeSave', function(source, xPlayer)
    -- Retourner false pour annuler la sauvegarde
    return true
end)

-- Après sauvegarde
AddEventHandler('ama:hook:afterSave', function(source, xPlayer)
    -- Votre code
end)
```

---

## Exemples pratiques

### Donner de l'argent avec confirmation

```lua
RegisterCommand('givemoney', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    if not xPlayer or xPlayer.group ~= "admin" then return end
    
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetId or not amount then
        TriggerClientEvent('ama:showNotification', source, "Usage: /givemoney [id] [montant]")
        return
    end
    
    local xTarget = AMA.GetPlayer(targetId)
    if not xTarget then
        TriggerClientEvent('ama:showNotification', source, "Joueur introuvable")
        return
    end
    
    xTarget:addMoney(amount, "Admin")
    TriggerClientEvent('ama:showNotification', source, 
        string.format("Donné $%d à %s", amount, xTarget.name))
    TriggerClientEvent('ama:showNotification', targetId, 
        string.format("Reçu $%d d'un admin", amount))
end)
```

### Système de salaire automatique

```lua
-- Payer tous les joueurs toutes les 30 minutes
CreateThread(function()
    while true do
        Wait(30 * 60 * 1000)  -- 30 minutes
        
        local players = AMA.GetPlayers()
        for _, xPlayer in pairs(players) do
            local job = xPlayer:getJob()
            
            -- Récupérer le salaire du job depuis la BDD
            MySQL.single('SELECT salary FROM ama_job_grades WHERE job_name = ? AND grade = ?',
                {job.name, job.grade}, function(result)
                    if result then
                        xPlayer:addBank(result.salary, "Salaire")
                        TriggerClientEvent('ama:showNotification', xPlayer.source,
                            string.format("Salaire reçu: $%d", result.salary))
                    end
                end)
        end
        
        AMA.Log("INFO", "Salaires distribués")
    end
end)
```

### Système de bonus de crew

```lua
RegisterCommand('crewbonus', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    if not xPlayer or xPlayer.group ~= "admin" then return end
    
    local crewName = args[1]
    local bonus = tonumber(args[2])
    
    if not crewName or not bonus then return end
    
    local members = AMA.Crews.GetCrewMembers(crewName)
    for _, member in ipairs(members) do
        local xMember = AMA.GetPlayer(member.source)
        if xMember then
            xMember:addMoney(bonus, "Bonus de crew")
        end
    end
    
    TriggerClientEvent('ama:showNotification', source,
        string.format("Bonus de $%d distribué à %d membres", bonus, #members))
end)
```

---

## 📚 Voir aussi

- [API Client](API_CLIENT.md) - Documentation de l'API client
- [Exemples de code](EXEMPLES_CODE.md) - Plus d'exemples pratiques
- [Base de données](BASE_DONNEES.md) - Structure de la BDD

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2025
