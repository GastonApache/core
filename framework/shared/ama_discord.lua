-- =====================================================
-- CONFIGURATION DISCORD WEBHOOKS
-- =====================================================

Config.Discord = {
    -- Activer/Désactiver les webhooks Discord
    Enabled = true,
    
    -- Webhooks Discord (remplacez par vos URLs)
    Webhooks = {
        -- Webhook pour les connexions
        Connection = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        
        -- Webhook pour les déconnexions
        Disconnection = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        
        -- Webhook pour la sauvegarde complète des données
        PlayerData = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        
        -- Webhook pour les transactions d'argent (optionnel)
        Transactions = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        
        -- Webhook pour les changements de job (optionnel)
        JobChanges = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN"
    },
    
    -- Configuration des embeds
    Colors = {
        Connection = 3066993,      -- Vert (0x2ECC71)
        Disconnection = 15158332,  -- Rouge (0xE74C3C)
        PlayerData = 3447003,      -- Bleu (0x3498DB)
        Transaction = 15844367,    -- Or (0xF1C40F)
        JobChange = 10181046       -- Violet (0x9B59B6)
    },
    
    -- Informations du bot
    BotName = "AMA Framework",
    BotAvatar = "https://i.imgur.com/AfFp7pu.png", -- Avatar du bot
    
    -- Footer
    FooterText = "AMA Framework • Système de logs",
    FooterIcon = "https://i.imgur.com/AfFp7pu.png",
    
    -- Logs détaillés
    Settings = {
        -- Envoyer les données complètes du joueur à la connexion
        SendFullDataOnConnect = true,
        
        -- Envoyer uniquement l'heure de déconnexion
        SendOnlyTimeOnDisconnect = true,
        
        -- Inclure la position dans les logs
        IncludePosition = true,
        
        -- Inclure l'inventaire (peut être long)
        IncludeInventory = false,
        
        -- Inclure les identifiants du joueur
        IncludeIdentifiers = true,
        
        -- Format de la date
        DateFormat = "%d/%m/%Y %H:%M:%S",
        
        -- Timezone (pour l'affichage)
        Timezone = "Europe/Paris"
    },
    
    -- Limites et sécurité
    RateLimit = {
        -- Délai minimum entre deux webhooks (millisecondes)
        Delay = 1000,
        
        -- Nombre maximum de tentatives en cas d'échec
        MaxRetries = 3
    }
}