-- =====================================================
-- SYSTÈME AMACOIN (BITCOIN)
-- =====================================================

AMA.Bitcoin = {}

-- =====================================================
-- FONCTIONS PRINCIPALES
-- =====================================================

---Envoyer des AMACoins à un autre joueur
---@param senderSource number Source de l'expéditeur
---@param receiverWalletUUID string UUID du wallet du destinataire
---@param amount number Montant à envoyer
function AMA.Bitcoin.SendCoins(senderSource, receiverWalletUUID, amount)
    if not Config.AMACoin.Enabled then return false end
    
    local xSender = AMA.GetPlayer(senderSource)
    if not xSender then return false end
    
    -- Vérifier le montant minimum
    if amount < Config.AMACoin.MinTransaction then
        TriggerClientEvent('ama:showNotification', senderSource, 
            "Montant minimum: " .. Config.AMACoin.MinTransaction .. " " .. Config.AMACoin.Symbol)
        return false
    end
    
    -- Trouver le destinataire par UUID de wallet
    local xReceiver = nil
    for _, player in pairs(AMA.Players) do
        if player.wallet_uuid == receiverWalletUUID then
            xReceiver = player
            break
        end
    end
    
    if not xReceiver then
        TriggerClientEvent('ama:showNotification', senderSource, "Wallet introuvable")
        return false
    end
    
    -- Vérifier que le destinataire n'est pas l'expéditeur
    if xSender.wallet_uuid == xReceiver.wallet_uuid then
        TriggerClientEvent('ama:showNotification', senderSource, 
            "Vous ne pouvez pas vous envoyer des " .. Config.AMACoin.Name)
        return false
    end
    
    -- Calculer les frais
    local fee = amount * (Config.AMACoin.TransactionFee / 100)
    local totalAmount = amount + fee
    
    -- Vérifier le solde
    if xSender.bitcoin < totalAmount then
        TriggerClientEvent('ama:showNotification', senderSource, 
            "Solde insuffisant (Frais: " .. fee .. " " .. Config.AMACoin.Symbol .. ")")
        return false
    end
    
    -- Effectuer la transaction
    if xSender:removeBitcoin(totalAmount, "Envoi vers " .. xReceiver.name) then
        xReceiver:addBitcoin(amount, "Reçu de " .. xSender.name)
        
        -- Logger la transaction
        MySQL.insert([[
            INSERT INTO ama_bitcoin_transactions 
            (sender_uuid, receiver_uuid, amount, type, reason) 
            VALUES (?, ?, ?, 'send', ?)
        ]], {
            xSender.wallet_uuid,
            xReceiver.wallet_uuid,
            amount,
            string.format("Envoi de %s à %s", xSender.name, xReceiver.name)
        })
        
        -- Notifications
        TriggerClientEvent('ama:showNotification', senderSource, 
            string.format("Envoyé %.4f %s à %s (Frais: %.4f %s)", 
                amount, Config.AMACoin.Symbol, xReceiver.name, fee, Config.AMACoin.Symbol))
        TriggerClientEvent('ama:showNotification', xReceiver.source, 
            string.format("Reçu %.4f %s de %s", 
                amount, Config.AMACoin.Symbol, xSender.name))
        
        AMA.Log("INFO", string.format("Transaction AMACoin: %s -> %s (%.4f ₿)", 
            xSender.name, xReceiver.name, amount))
        
        return true
    end
    
    return false
end

---Obtenir l'historique des transactions d'un wallet
---@param walletUUID string UUID du wallet
---@param callback function Callback avec l'historique
function AMA.Bitcoin.GetTransactionHistory(walletUUID, callback)
    MySQL.query([[
        SELECT * FROM ama_bitcoin_transactions 
        WHERE sender_uuid = ? OR receiver_uuid = ? 
        ORDER BY created_at DESC 
        LIMIT 50
    ]], {walletUUID, walletUUID}, function(results)
        callback(results or {})
    end)
end

---Obtenir le taux de change actuel
---@return number Taux de change
function AMA.Bitcoin.GetExchangeRate()
    return Config.AMACoin.ExchangeRate
end

---Calculer les frais de transaction
---@param amount number Montant
---@return number Frais
function AMA.Bitcoin.CalculateFee(amount)
    return amount * (Config.AMACoin.TransactionFee / 100)
end

-- =====================================================
-- ÉVÉNEMENTS SERVEUR
-- =====================================================

-- Envoyer des AMACoins
RegisterNetEvent('ama:sendBitcoin')
AddEventHandler('ama:sendBitcoin', function(receiverWalletUUID, amount)
    local source = source
    AMA.Bitcoin.SendCoins(source, receiverWalletUUID, amount)
end)

-- Convertir AMACoins en argent
RegisterNetEvent('ama:convertBitcoinToMoney')
AddEventHandler('ama:convertBitcoinToMoney', function(bitcoinAmount)
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    if xPlayer:convertBitcoinToMoney(bitcoinAmount) then
        -- Logger la conversion
        MySQL.insert([[
            INSERT INTO ama_bitcoin_transactions 
            (sender_uuid, receiver_uuid, amount, type, reason) 
            VALUES (?, NULL, ?, 'convert', 'Conversion vers argent')
        ]], {xPlayer.wallet_uuid, bitcoinAmount})
        
        AMA.Log("INFO", string.format("%s a converti %.4f ₿ en argent", xPlayer.name, bitcoinAmount))
    end
end)

-- Convertir argent en AMACoins
RegisterNetEvent('ama:convertMoneyToBitcoin')
AddEventHandler('ama:convertMoneyToBitcoin', function(moneyAmount)
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    if xPlayer:convertMoneyToBitcoin(moneyAmount) then
        local bitcoinAmount = moneyAmount / Config.AMACoin.ExchangeRate
        
        -- Logger la conversion
        MySQL.insert([[
            INSERT INTO ama_bitcoin_transactions 
            (sender_uuid, receiver_uuid, amount, type, reason) 
            VALUES (?, NULL, ?, 'convert', 'Conversion depuis argent')
        ]], {xPlayer.wallet_uuid, bitcoinAmount})
        
        AMA.Log("INFO", string.format("%s a converti $%d en %.4f ₿", xPlayer.name, moneyAmount, bitcoinAmount))
    end
end)

-- Obtenir l'historique des transactions
RegisterNetEvent('ama:getBitcoinHistory')
AddEventHandler('ama:getBitcoinHistory', function()
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    AMA.Bitcoin.GetTransactionHistory(xPlayer.wallet_uuid, function(history)
        TriggerClientEvent('ama:receiveBitcoinHistory', source, history)
    end)
end)

-- Obtenir le wallet UUID
RegisterNetEvent('ama:getWalletUUID')
AddEventHandler('ama:getWalletUUID', function()
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    TriggerClientEvent('ama:receiveWalletUUID', source, xPlayer.wallet_uuid)
end)

-- Obtenir les infos du wallet
RegisterNetEvent('ama:getWalletInfo')
AddEventHandler('ama:getWalletInfo', function()
    local source = source
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    local walletInfo = {
        uuid = xPlayer.wallet_uuid,
        balance = xPlayer.bitcoin,
        exchangeRate = Config.AMACoin.ExchangeRate,
        symbol = Config.AMACoin.Symbol,
        name = Config.AMACoin.Name,
        fee = Config.AMACoin.TransactionFee
    }
    
    TriggerClientEvent('ama:receiveWalletInfo', source, walletInfo)
end)

-- =====================================================
-- COMMANDES
-- =====================================================

-- Commande pour afficher son wallet
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

-- Commande pour envoyer des AMACoins
RegisterCommand('sendcoin', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    local walletUUID = args[1]
    local amount = tonumber(args[2])
    
    if not walletUUID or not amount then
        TriggerClientEvent('ama:showNotification', source, 
            "Usage: /sendcoin [wallet_uuid] [montant]")
        return
    end
    
    AMA.Bitcoin.SendCoins(source, walletUUID, amount)
end, false)

-- Commande admin pour donner des AMACoins
RegisterCommand('givecoin', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    
    if xPlayer and xPlayer.group == "admin" then
        local targetId = tonumber(args[1])
        local amount = tonumber(args[2])
        
        if targetId and amount then
            local xTarget = AMA.GetPlayer(targetId)
            if xTarget then
                xTarget:addBitcoin(amount, "Admin")
                TriggerClientEvent('ama:showNotification', source, 
                    string.format("Donné %.4f %s à %s", amount, Config.AMACoin.Symbol, xTarget.name))
            end
        else
            TriggerClientEvent('ama:showNotification', source, 
                "Usage: /givecoin [id] [montant]")
        end
    end
end, false)

-- Commande pour convertir vers argent
RegisterCommand('cashout', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    local amount = tonumber(args[1])
    
    if not amount then
        TriggerClientEvent('ama:showNotification', source, 
            "Usage: /cashout [montant_bitcoin]")
        return
    end
    
    TriggerEvent('ama:convertBitcoinToMoney', source, amount)
end, false)

-- Commande pour acheter des AMACoins
RegisterCommand('buycoin', function(source, args)
    local xPlayer = AMA.GetPlayer(source)
    
    if not xPlayer then return end
    
    local amount = tonumber(args[1])
    
    if not amount then
        TriggerClientEvent('ama:showNotification', source, 
            "Usage: /buycoin [montant_argent]")
        return
    end
    
    TriggerEvent('ama:convertMoneyToBitcoin', source, amount)
end, false)

-- =====================================================
-- EXPORTS
-- =====================================================

exports('SendBitcoin', AMA.Bitcoin.SendCoins)
exports('GetExchangeRate', AMA.Bitcoin.GetExchangeRate)
exports('GetTransactionHistory', AMA.Bitcoin.GetTransactionHistory)

AMA.Log("INFO", "Système AMACoin chargé")