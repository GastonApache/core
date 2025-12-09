-- =====================================================
-- SYSTÈME DE LOGS DISCORD
-- =====================================================

AMA.Discord = {}
local lastWebhookTime = {}

-- =====================================================
-- FONCTION PRINCIPALE D'ENVOI DE WEBHOOK
-- =====================================================

---Envoyer un webhook Discord
---@param webhook string URL du webhook
---@param embed table Données de l'embed
---@param callback function Fonction de callback (optionnel)
function AMA.Discord.SendWebhook(webhook, embed, callback)
    if not Config.Discord.Enabled then return end
    if not webhook or webhook == "" or webhook:find("VOTRE_ID") then
        AMA.Log("WARN", "Webhook Discord non configuré")
        return
    end
    
    -- Rate limiting
    local now = GetGameTimer()
    if lastWebhookTime[webhook] and (now - lastWebhookTime[webhook]) < Config.Discord.RateLimit.Delay then
        AMA.Log("DEBUG", "Webhook rate limité, attente...")
        Wait(Config.Discord.RateLimit.Delay)
    end
    lastWebhookTime[webhook] = now
    
    local data = {
        username = Config.Discord.BotName,
        avatar_url = Config.Discord.BotAvatar,
        embeds = {embed}
    }
    
    -- Envoyer la requête HTTP
    PerformHttpRequest(webhook, function(statusCode, response, headers)
        if statusCode == 204 then
            AMA.Log("DEBUG", "Webhook Discord envoyé avec succès")
            if callback then callback(true) end
        else
            AMA.Log("ERROR", "Erreur webhook Discord: " .. statusCode)
            if callback then callback(false, statusCode) end
        end
    end, 'POST', json.encode(data), {
        ['Content-Type'] = 'application/json'
    })
end

-- =====================================================
-- FORMATAGE DES DONNÉES
-- =====================================================

---Obtenir la date formatée
---@return string Date formatée
local function GetFormattedDate()
    return os.date(Config.Discord.Settings.DateFormat)
end

---Obtenir tous les identifiants d'un joueur
---@param source number ID du joueur
---@return string Identifiants formatés
local function GetPlayerIdentifiers(source)
    local identifiers = GetPlayerIdentifiers(source)
    local formatted = {}
    
    for _, identifier in pairs(identifiers) do
        if identifier:match("steam:") then
            table.insert(formatted, "Steam: `" .. identifier .. "`")
        elseif identifier:match("license:") then
            table.insert(formatted, "License: `" .. identifier .. "`")
        elseif identifier:match("discord:") then
            local discordId = identifier:gsub("discord:", "")
            table.insert(formatted, "Discord: <@" .. discordId .. ">")
        elseif identifier:match("fivem:") then
            table.insert(formatted, "FiveM: `" .. identifier .. "`")
        end
    end
    
    return table.concat(formatted, "\n")
end

---Formater la position
---@param position table Position du joueur
---@return string Position formatée
local function FormatPosition(position)
    if not position then return "Non disponible" end
    return string.format("X: %.2f, Y: %.2f, Z: %.2f", 
        position.x or 0, 
        position.y or 0, 
        position.z or 0
    )
end

-- =====================================================
-- LOG DE CONNEXION (DONNÉES COMPLÈTES)
-- =====================================================

---Logger la connexion d'un joueur avec toutes ses données
---@param source number ID du joueur
---@param xPlayer table Objet joueur
function AMA.Discord.LogPlayerConnection(source, xPlayer)
    if not Config.Discord.Settings.SendFullDataOnConnect then return end
    
    local fields = {
        {
            name = "👤 Joueur",
            value = string.format("**%s %s**\nID: `%d`", 
                xPlayer.firstname or "John", 
                xPlayer.lastname or "Doe",
                source
            ),
            inline = true
        },
        {
            name = "🕐 Heure de connexion",
            value = "`" .. GetFormattedDate() .. "`",
            inline = true
        },
        {
            name = "💰 Finances",
            value = string.format("Liquide: `$%d`\nBanque: `$%d`\nTotal: `$%d`", 
                xPlayer.money or 0,
                xPlayer.bank or 0,
                (xPlayer.money or 0) + (xPlayer.bank or 0)
            ),
            inline = true
        },
        {
            name = "💼 Emploi",
            value = string.format("Job: `%s`\nGrade: `%d`", 
                xPlayer.job or "unemployed",
                xPlayer.job_grade or 0
            ),
            inline = true
        },
        {
            name = "🎖️ Groupe",
            value = "`" .. (xPlayer.group or "user") .. "`",
            inline = true
        }
    }
    
    -- Ajouter la position si activé
    if Config.Discord.Settings.IncludePosition and xPlayer.position then
        table.insert(fields, {
            name = "📍 Dernière position",
            value = "`" .. FormatPosition(xPlayer.position) .. "`",
            inline = false
        })
    end
    
    -- Ajouter les identifiants si activé
    if Config.Discord.Settings.IncludeIdentifiers then
        table.insert(fields, {
            name = "🔑 Identifiants",
            value = GetPlayerIdentifiers(source),
            inline = false
        })
    end
    
    -- Ajouter l'inventaire si activé (limité à 1024 caractères)
    if Config.Discord.Settings.IncludeInventory and xPlayer.inventory then
        local inventoryText = "Vide"
        if next(xPlayer.inventory) then
            local items = {}
            for item, count in pairs(xPlayer.inventory) do
                if #items < 10 then -- Limiter à 10 items
                    table.insert(items, item .. " x" .. count)
                end
            end
            inventoryText = table.concat(items, "\n")
        end
        
        table.insert(fields, {
            name = "🎒 Inventaire",
            value = "`" .. inventoryText .. "`",
            inline = false
        })
    end
    
    local embed = {
        title = "✅ Connexion au serveur",
        description = string.format("**%s %s** s'est connecté(e) au serveur", 
            xPlayer.firstname or "John",
            xPlayer.lastname or "Doe"
        ),
        color = Config.Discord.Colors.Connection,
        fields = fields,
        footer = {
            text = Config.Discord.FooterText,
            icon_url = Config.Discord.FooterIcon
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
    }
    
    AMA.Discord.SendWebhook(Config.Discord.Webhooks.Connection, embed)
    AMA.Log("INFO", "Log de connexion envoyé pour: " .. GetPlayerName(source))
end

-- =====================================================
-- LOG DE DÉCONNEXION (SIMPLE)
-- =====================================================

---Logger la déconnexion d'un joueur
---@param source number ID du joueur
---@param xPlayer table Objet joueur
---@param reason string Raison de la déconnexion
function AMA.Discord.LogPlayerDisconnection(source, xPlayer, reason)
    if not xPlayer then return end
    
    local fields = {
        {
            name = "👤 Joueur",
            value = string.format("**%s %s**\nID: `%d`", 
                xPlayer.firstname or "John",
                xPlayer.lastname or "Doe",
                source
            ),
            inline = true
        },
        {
            name = "🕐 Heure de déconnexion",
            value = "`" .. GetFormattedDate() .. "`",
            inline = true
        }
    }
    
    -- Ajouter la raison si elle existe
    if reason and reason ~= "" then
        table.insert(fields, {
            name = "ℹ️ Raison",
            value = "`" .. reason .. "`",
            inline = false
        })
    end
    
    -- Ajouter les finances finales
    if not Config.Discord.Settings.SendOnlyTimeOnDisconnect then
        table.insert(fields, {
            name = "💰 Finances finales",
            value = string.format("Liquide: `$%d`\nBanque: `$%d`", 
                xPlayer.money or 0,
                xPlayer.bank or 0
            ),
            inline = true
        })
        
        table.insert(fields, {
            name = "💼 Emploi",
            value = string.format("`%s` (Grade %d)", 
                xPlayer.job or "unemployed",
                xPlayer.job_grade or 0
            ),
            inline = true
        })
    end
    
    local embed = {
        title = "❌ Déconnexion du serveur",
        description = string.format("**%s %s** s'est déconnecté(e) du serveur", 
            xPlayer.firstname or "John",
            xPlayer.lastname or "Doe"
        ),
        color = Config.Discord.Colors.Disconnection,
        fields = fields,
        footer = {
            text = Config.Discord.FooterText,
            icon_url = Config.Discord.FooterIcon
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
    }
    
    AMA.Discord.SendWebhook(Config.Discord.Webhooks.Disconnection, embed)
    AMA.Log("INFO", "Log de déconnexion envoyé pour: " .. GetPlayerName(source))
end

-- =====================================================
-- SAUVEGARDE COMPLÈTE DES DONNÉES
-- =====================================================

---Sauvegarder toutes les données d'un joueur sur Discord
---@param source number ID du joueur
---@param xPlayer table Objet joueur
function AMA.Discord.LogPlayerDataBackup(source, xPlayer)
    if not xPlayer then return end
    
    -- Créer un backup JSON complet
    local backup = {
        identifier = xPlayer.identifier,
        firstname = xPlayer.firstname,
        lastname = xPlayer.lastname,
        money = xPlayer.money,
        bank = xPlayer.bank,
        job = xPlayer.job,
        job_grade = xPlayer.job_grade,
        group = xPlayer.group,
        position = xPlayer.position,
        inventory = xPlayer.inventory,
        accounts = xPlayer.accounts,
        timestamp = os.time(),
        date = GetFormattedDate()
    }
    
    local backupJson = json.encode(backup, {indent = true})
    
    -- Limiter la taille (Discord limite à 2048 caractères par field)
    if #backupJson > 2000 then
        backupJson = string.sub(backupJson, 1, 1997) .. "..."
    end
    
    local embed = {
        title = "💾 Sauvegarde des données joueur",
        description = string.format("Backup complet de **%s %s**", 
            xPlayer.firstname or "John",
            xPlayer.lastname or "Doe"
        ),
        color = Config.Discord.Colors.PlayerData,
        fields = {
            {
                name = "📊 Données JSON",
                value = "```json\n" .. backupJson .. "\n```",
                inline = false
            },
            {
                name = "🕐 Date du backup",
                value = "`" .. GetFormattedDate() .. "`",
                inline = false
            }
        },
        footer = {
            text = Config.Discord.FooterText,
            icon_url = Config.Discord.FooterIcon
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
    }
    
    AMA.Discord.SendWebhook(Config.Discord.Webhooks.PlayerData, embed)
    AMA.Log("DEBUG", "Backup de données envoyé pour: " .. GetPlayerName(source))
end

-- =====================================================
-- LOGS OPTIONNELS
-- =====================================================

---Logger une transaction d'argent
---@param source number ID du joueur
---@param xPlayer table Objet joueur
---@param type string Type (add/remove)
---@param account string Compte (money/bank)
---@param amount number Montant
---@param reason string Raison
function AMA.Discord.LogTransaction(source, xPlayer, type, account, amount, reason)
    if not Config.Discord.Webhooks.Transactions then return end
    
    local emoji = type == "add" and "➕" or "➖"
    local color = type == "add" and 3066993 or 15158332
    
    local embed = {
        title = emoji .. " Transaction",
        description = string.format("**%s %s** - %s",
            xPlayer.firstname or "John",
            xPlayer.lastname or "Doe",
            type == "add" and "Ajout" or "Retrait"
        ),
        color = color,
        fields = {
            {
                name = "💵 Montant",
                value = string.format("`$%d`", amount),
                inline = true
            },
            {
                name = "💼 Compte",
                value = "`" .. account .. "`",
                inline = true
            },
            {
                name = "📝 Raison",
                value = "`" .. (reason or "Non spécifiée") .. "`",
                inline = false
            },
            {
                name = "💰 Nouveau solde",
                value = string.format("Liquide: `$%d`\nBanque: `$%d`",
                    xPlayer.money or 0,
                    xPlayer.bank or 0
                ),
                inline = false
            }
        },
        footer = {
            text = Config.Discord.FooterText,
            icon_url = Config.Discord.FooterIcon
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
    }
    
    AMA.Discord.SendWebhook(Config.Discord.Webhooks.Transactions, embed)
end

---Logger un changement de job
---@param source number ID du joueur
---@param xPlayer table Objet joueur
---@param oldJob string Ancien job
---@param newJob string Nouveau job
---@param newGrade number Nouveau grade
function AMA.Discord.LogJobChange(source, xPlayer, oldJob, newJob, newGrade)
    if not Config.Discord.Webhooks.JobChanges then return end
    
    local embed = {
        title = "💼 Changement d'emploi",
        description = string.format("**%s %s** a changé d'emploi",
            xPlayer.firstname or "John",
            xPlayer.lastname or "Doe"
        ),
        color = Config.Discord.Colors.JobChange,
        fields = {
            {
                name = "📤 Ancien emploi",
                value = "`" .. (oldJob or "unemployed") .. "`",
                inline = true
            },
            {
                name = "📥 Nouveau emploi",
                value = string.format("`%s` (Grade %d)", newJob, newGrade),
                inline = true
            },
            {
                name = "🕐 Date",
                value = "`" .. GetFormattedDate() .. "`",
                inline = false
            }
        },
        footer = {
            text = Config.Discord.FooterText,
            icon_url = Config.Discord.FooterIcon
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
    }
    
    AMA.Discord.SendWebhook(Config.Discord.Webhooks.JobChanges, embed)
end

-- =====================================================
-- EXPORTS
-- =====================================================

exports('SendDiscordLog', AMA.Discord.SendWebhook)
exports('LogPlayerConnection', AMA.Discord.LogPlayerConnection)
exports('LogPlayerDisconnection', AMA.Discord.LogPlayerDisconnection)

AMA.Log("INFO", "Système de logs Discord chargé")