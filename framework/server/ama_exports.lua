-- =====================================================
-- EXPORTS SERVEUR - AMA Framework
-- =====================================================
-- Ce fichier exporte toutes les fonctions serveur
-- pour qu'elles soient utilisables depuis d'autres ressources.
--
-- Utilisation depuis une autre ressource :
--   local ama = exports['ama_framework']
--
--   local xPlayer = ama:GetPlayer(source)
--   local players = ama:GetPlayers()
--   ama:SetPlayerMeta(source, "premium", true)
-- =====================================================

-- Gestion des joueurs
exports('GetPlayer',     AMA.GetPlayer)
exports('GetPlayers',    AMA.GetPlayers)
exports('GetIdentifier', AMA.GetIdentifier)
exports('SavePlayer',    AMA.SavePlayer)

-- Callbacks serveur
exports('RegisterServerCallback', AMA.RegisterServerCallback)

-- Système de hooks
exports('RegisterHook', AMA.RegisterHook)
exports('TriggerHook',  AMA.TriggerHook)

-- Système de modules
exports('RegisterModule', AMA.RegisterModule)
exports('GetModule',      AMA.GetModule)

-- Métadonnées joueurs
exports('SetPlayerMeta',    AMA.SetPlayerMeta)
exports('GetPlayerMeta',    AMA.GetPlayerMeta)
exports('GetAllPlayerMeta', AMA.GetAllPlayerMeta)

-- Utilitaires
exports('IsPlayerOnline',   AMA.IsPlayerOnline)
exports('GetPlayersInArea', AMA.GetPlayersInArea)

AMA.Log("INFO", "Exports serveur chargés")
