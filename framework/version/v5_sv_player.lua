-- Classe Player
local Player = {}
Player.__index = Player

function Player:new(data)
    local self = setmetatable({}, Player)
    
    self.source = data.source
    self.identifier = data.identifier
    self.uuid = data.uuid or AMA.GenerateUUID()
    self.wallet_uuid = data.wallet_uuid or AMA.GenerateUUID()
    self.name = GetPlayerName(data.source)
    self.firstname = data.firstname or "John"
    self.lastname = data.lastname or "Doe"
    self.money = data.money or Config.Player.StartMoney
    self.bank = data.bank or Config.Player.StartBank
    self.bitcoin = data.bitcoin or Config.Player.StartBitcoin
    self.job = data.job or "unemployed"
    self.job_grade = data.job_grade or 0
    self.crew = data.crew or "none"
    self.crew_grade = data.crew_grade or 0
    self.group = data.group or "user"
    self.position = data.position or nil
    self.inventory = data.inventory or {}
    self.accounts = data.accounts or {}
    
    return self
end

function Player:getMoney()
    return self.money
end

function Player:addMoney(amount, reason)
    self.money = self.money + amount
    TriggerClientEvent('ama:updateMoney', self.source, self.money)
    
    -- Hook pour les transactions
    AMA.TriggerHook("ama:hook:moneyChanged", self.source, "add", "money", amount, reason)
    
    -- DISCORD: Logger la transaction
    if Config.Discord and Config.Discord.Enabled and Config.Discord.Webhooks.Transactions then
        AMA.Discord.LogTransaction(self.source, self, "add", "money", amount, reason or "Argent ajouté")
    end
end

function Player:removeMoney(amount, reason)
    if self.money >= amount then
        self.money = self.money - amount
        TriggerClientEvent('ama:updateMoney', self.source, self.money)
        
        -- Hook pour les transactions
        AMA.TriggerHook("ama:hook:moneyChanged", self.source, "remove", "money", amount, reason)
        
        -- DISCORD: Logger la transaction
        if Config.Discord and Config.Discord.Enabled and Config.Discord.Webhooks.Transactions then
            AMA.Discord.LogTransaction(self.source, self, "remove", "money", amount, reason or "Argent retiré")
        end
        
        return true
    end
    return false
end

function Player:getBank()
    return self.bank
end

function Player:addBank(amount, reason)
    self.bank = self.bank + amount
    TriggerClientEvent('ama:updateBank', self.source, self.bank)
    
    -- Hook pour les transactions
    AMA.TriggerHook("ama:hook:moneyChanged", self.source, "add", "bank", amount, reason)
    
    -- DISCORD: Logger la transaction
    if Config.Discord and Config.Discord.Enabled and Config.Discord.Webhooks.Transactions then
        AMA.Discord.LogTransaction(self.source, self, "add", "bank", amount, reason or "Dépôt bancaire")
    end
end

function Player:removeBank(amount, reason)
    if self.bank >= amount then
        self.bank = self.bank - amount
        TriggerClientEvent('ama:updateBank', self.source, self.bank)
        
        -- Hook pour les transactions
        AMA.TriggerHook("ama:hook:moneyChanged", self.source, "remove", "bank", amount, reason)
        
        -- DISCORD: Logger la transaction
        if Config.Discord and Config.Discord.Enabled and Config.Discord.Webhooks.Transactions then
            AMA.Discord.LogTransaction(self.source, self, "remove", "bank", amount, reason or "Retrait bancaire")
        end
        
        return true
    end
    return false
end

-- Fonctions AMACoins (Bitcoin)
function Player:getBitcoin()
    return self.bitcoin
end

function Player:addBitcoin(amount, reason)
    if not Config.AMACoin.Enabled then return false end
    
    local newAmount = self.bitcoin + amount
    if newAmount > Config.AMACoin.MaxPerPlayer then
        return false
    end
    
    self.bitcoin = newAmount
    TriggerClientEvent('ama:updateBitcoin', self.source, self.bitcoin)
    
    -- Hook pour les transactions
    AMA.TriggerHook("ama:hook:bitcoinChanged", self.source, "add", amount, reason)
    
    AMA.Log("INFO", string.format("AMACoin ajouté: %s (+%.2f ₿)", self.name, amount))
    return true
end

function Player:removeBitcoin(amount, reason)
    if not Config.AMACoin.Enabled then return false end
    
    if self.bitcoin >= amount then
        self.bitcoin = self.bitcoin - amount
        TriggerClientEvent('ama:updateBitcoin', self.source, self.bitcoin)
        
        -- Hook pour les transactions
        AMA.TriggerHook("ama:hook:bitcoinChanged", self.source, "remove", amount, reason)
        
        AMA.Log("INFO", string.format("AMACoin retiré: %s (-%.2f ₿)", self.name, amount))
        return true
    end
    return false
end

function Player:convertBitcoinToMoney(bitcoinAmount)
    if not Config.AMACoin.Enabled then return false end
    
    if self.bitcoin >= bitcoinAmount and bitcoinAmount >= Config.AMACoin.MinTransaction then
        local moneyAmount = math.floor(bitcoinAmount * Config.AMACoin.ExchangeRate)
        local fee = math.floor(moneyAmount * (Config.AMACoin.TransactionFee / 100))
        local finalAmount = moneyAmount - fee
        
        if self:removeBitcoin(bitcoinAmount, "Conversion vers argent") then
            self:addMoney(finalAmount, "Conversion depuis AMACoin")
            TriggerClientEvent('ama:showNotification', self.source, 
                string.format("Converti %.2f ₿ en $%d (Frais: $%d)", bitcoinAmount, finalAmount, fee))
            return true
        end
    end
    return false
end

function Player:convertMoneyToBitcoin(moneyAmount)
    if not Config.AMACoin.Enabled then return false end
    
    if self.money >= moneyAmount and moneyAmount >= (Config.AMACoin.MinTransaction * Config.AMACoin.ExchangeRate) then
        local bitcoinAmount = moneyAmount / Config.AMACoin.ExchangeRate
        local fee = math.floor(moneyAmount * (Config.AMACoin.TransactionFee / 100))
        local finalMoney = moneyAmount + fee
        
        if self:removeMoney(finalMoney, "Conversion vers AMACoin") then
            self:addBitcoin(bitcoinAmount, "Conversion depuis argent")
            TriggerClientEvent('ama:showNotification', self.source, 
                string.format("Converti $%d en %.2f ₿ (Frais: $%d)", moneyAmount, bitcoinAmount, fee))
            return true
        end
    end
    return false
end

function Player:getWalletUUID()
    return self.wallet_uuid
end

-- Fonctions Job
function Player:setJob(job, grade)
    local oldJob = self.job
    self.job = job
    self.job_grade = grade or 0
    TriggerClientEvent('ama:setJob', self.source, self.job, self.job_grade)
    
    -- Hook pour le changement de job
    AMA.TriggerHook("ama:hook:jobChanged", self.source, oldJob, job, grade)
    
    -- DISCORD: Logger le changement de job
    if Config.Discord and Config.Discord.Enabled and Config.Discord.Webhooks.JobChanges then
        AMA.Discord.LogJobChange(self.source, self, oldJob, job, grade or 0)
    end
end

function Player:getJob()
    return {name = self.job, grade = self.job_grade}
end

-- Fonctions Crew (Organisations illégales)
function Player:setCrew(crew, grade)
    if not Config.Crews.Enabled then return false end
    
    local oldCrew = self.crew
    self.crew = crew
    self.crew_grade = grade or 0
    TriggerClientEvent('ama:setCrew', self.source, self.crew, self.crew_grade)
    
    -- Hook pour le changement de crew
    AMA.TriggerHook("ama:hook:crewChanged", self.source, oldCrew, crew, grade)
    
    AMA.Log("INFO", string.format("%s a rejoint le crew: %s (Grade: %d)", self.name, crew, grade or 0))
    return true
end

function Player:getCrew()
    return {name = self.crew, grade = self.crew_grade}
end

function Player:getCrewLabel()
    for _, crewData in ipairs(Config.Crews.Available) do
        if crewData.name == self.crew then
            return crewData.label
        end
    end
    return "Aucun Crew"
end

function Player:hasCrewPermission(permission)
    if not Config.Crews.Enabled or self.crew == "none" then return false end
    
    local permissions = Config.Crews.Permissions[self.crew_grade] or {}
    for _, perm in ipairs(permissions) do
        if perm == permission then
            return true
        end
    end
    return false
end

function Player:getCrewSalary()
    if not Config.Crews.Enabled or self.crew == "none" then return 0 end
    
    local baseSalary = 0
    for _, gradeData in ipairs(Config.Crews.Grades) do
        if gradeData.grade == self.crew_grade then
            baseSalary = gradeData.salary
            break
        end
    end
    
    -- Appliquer le multiplicateur du crew
    for _, crewData in ipairs(Config.Crews.Available) do
        if crewData.name == self.crew and crewData.salary_multiplier then
            baseSalary = math.floor(baseSalary * crewData.salary_multiplier)
            break
        end
    end
    
    return baseSalary
end

function Player:updatePosition(coords)
    self.position = coords
end

function Player:getPosition()
    return self.position
end

function Player:getUUID()
    return self.uuid
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