-- =====================================================
-- EXPORTS CLIENT - AMA Framework
-- =====================================================
-- Ce fichier exporte toutes les fonctions client
-- pour qu'elles soient utilisables depuis d'autres ressources.
--
-- Utilisation depuis une autre ressource :
--   local ama = exports['ama_framework']
--
--   local data     = ama:GetPlayerData()
--   local loaded   = ama:IsPlayerLoaded()
--   ama:ShowNotification("Message", "info")
--   ama:TriggerServerCallback('monCallback', function(result)
--       -- traitement du résultat
--   end)
-- =====================================================

-- Données joueur
exports('GetPlayerData',  AMA.GetPlayerData)
exports('IsPlayerLoaded', AMA.IsPlayerLoaded)

-- Notifications
exports('ShowNotification', AMA.ShowNotification)

-- Callbacks serveur
exports('TriggerServerCallback', AMA.TriggerServerCallback)

-- Système de hooks
exports('RegisterHook', AMA.RegisterHook)
exports('TriggerHook',  AMA.TriggerHook)

-- Système de modules
exports('RegisterModule', AMA.RegisterModule)
exports('GetModule',      AMA.GetModule)

-- Utilitaires
exports('GetPlayersInArea', AMA.GetPlayersInArea)

AMA.Log("INFO", "Exports client chargés")
