-- Classe Player
local Player = {}
Player.__index = Player

function Player:new(data)
    local self = setmetatable({}, Player)
    
    self.source = data.source
    self.identifier = data.identifier
    self.name = GetPlayerName(data.source)
    self.firstname = data.firstname or "John"
    self.lastname = data.lastname or "Doe"
    self.money = data.money or Config.Player.StartMoney
    self.bank = data.bank or 0
    self.job = data.job or "unemployed"
    self.job_grade = data.job_grade or 0
    self.group = data.group or "user"
    self.position = data.position or nil
    self.inventory = data.inventory or {}
    self.accounts = data.accounts or {}
    
    return self
end

function Player:getMoney()
    return self.money
end

function Player:addMoney(amount)
    self.money = self.money + amount
    TriggerClientEvent('ama:updateMoney', self.source, self.money)
    
    -- DISCORD: Logger la transaction
    if Config.Discord and Config.Discord.Enabled and Config.Discord.Webhooks.Transactions then
        AMA.Discord.LogTransaction(self.source, self, "add", "money", amount, "Argent ajouté")
    end
end

function Player:removeMoney(amount)
    if self.money >= amount then
        self.money = self.money - amount
        TriggerClientEvent('ama:updateMoney', self.source, self.money)
        
        -- DISCORD: Logger la transaction
        if Config.Discord and Config.Discord.Enabled and Config.Discord.Webhooks.Transactions then
            AMA.Discord.LogTransaction(self.source, self, "remove", "money", amount, "Argent retiré")
        end
        
        return true
    end
    return false
end

function Player:getBank()
    return self.bank
end

function Player:addBank(amount)
    self.bank = self.bank + amount
    TriggerClientEvent('ama:updateBank', self.source, self.bank)
end

function Player:removeBank(amount)
    if self.bank >= amount then
        self.bank = self.bank - amount
        TriggerClientEvent('ama:updateBank', self.source, self.bank)
        return true
    end
    return false
end

function Player:setJob(job, grade)
    local oldJob = self.job
    self.job = job
    self.job_grade = grade or 0
    TriggerClientEvent('ama:setJob', self.source, self.job, self.job_grade)
    
    -- DISCORD: Logger le changement de job
    if Config.Discord and Config.Discord.Enabled and Config.Discord.Webhooks.JobChanges then
        AMA.Discord.LogJobChange(self.source, self, oldJob, job, grade or 0)
    end
end

function Player:getJob()
    return {name = self.job, grade = self.job_grade}
end

function Player:updatePosition(coords)
    self.position = coords
end

function Player:getPosition()
    return self.position
end

-- Fonction pour charger un joueur
function AMA.LoadPlayer(source, identifier)
    MySQL.single('SELECT * FROM ama_players WHERE identifier = ?', {identifier}, function(result)
        local playerData = {
            source = source,
            identifier = identifier
        }
        
        if result then
            -- Joueur existant
            playerData.firstname = result.firstname
            playerData.lastname = result.lastname
            playerData.money = result.money
            playerData.bank = result.bank
            playerData.job = result.job
            playerData.job_grade = result.job_grade
            playerData.group = result.group
            playerData.position = json.decode(result.position)
            playerData.inventory = json.decode(result.inventory) or {}
            playerData.accounts = json.decode(result.accounts) or {}
            
            AMA.Log("INFO", "Joueur existant chargé: " .. GetPlayerName(source))
            TriggerClientEvent('ama:showNotification', source, Config.Messages.WelcomeBack)
        else
            -- Nouveau joueur
            playerData.money = Config.Player.StartMoney
            playerData.job = Config.Player.DefaultData.job
            playerData.job_grade = Config.Player.DefaultData.job_grade
            playerData.group = Config.Player.DefaultData.group
            
            MySQL.insert('INSERT INTO ama_players (identifier, money, job, job_grade, `group`) VALUES (?, ?, ?, ?, ?)',
                {identifier, playerData.money, playerData.job, playerData.job_grade, playerData.group}
            )
            
            AMA.Log("INFO", "Nouveau joueur créé: " .. GetPlayerName(source))
            TriggerClientEvent('ama:showNotification', source, Config.Messages.FirstConnection)
        end
        
        local xPlayer = Player:new(playerData)
        AMA.Players[source] = xPlayer
        
        -- DISCORD: Logger la connexion avec toutes les données
        if Config.Discord and Config.Discord.Enabled then
            AMA.Discord.LogPlayerConnection(source, xPlayer)
            
            -- Backup complet des données
            AMA.Discord.LogPlayerDataBackup(source, xPlayer)
        end
        
        -- Déclencher le hook
        AMA.TriggerHook("ama:hook:playerDataLoaded", source, xPlayer)
        
        -- Envoyer les données au client
        TriggerClientEvent('ama:playerSpawn', source, playerData)
    end)
end

-- Fonction pour sauvegarder un joueur
function AMA.SavePlayer(source)
    local xPlayer = AMA.GetPlayer(source)
    if not xPlayer then return end
    
    MySQL.update([[
        UPDATE ama_players SET
            firstname = ?,
            lastname = ?,
            money = ?,
            bank = ?,
            job = ?,
            job_grade = ?,
            `group` = ?,
            position = ?,
            inventory = ?,
            accounts = ?
        WHERE identifier = ?
    ]], {
        xPlayer.firstname,
        xPlayer.lastname,
        xPlayer.money,
        xPlayer.bank,
        xPlayer.job,
        xPlayer.job_grade,
        xPlayer.group,
        json.encode(xPlayer.position),
        json.encode(xPlayer.inventory),
        json.encode(xPlayer.accounts),
        xPlayer.identifier
    })
    
    if Config.Framework.Debug then
        AMA.Log("DEBUG", "Position sauvegardée pour: " .. GetPlayerName(source))
    end
end

-- Événement pour sauvegarder la position
RegisterNetEvent('ama:savePosition')
AddEventHandler('ama:savePosition', function(coords)
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer then
        xPlayer:updatePosition(coords)
        AMA.SavePlayer(source)
    end
end)