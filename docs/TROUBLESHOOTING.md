# 🔧 Troubleshooting - Guide de dépannage AMA Framework

## Table des matières

1. [Erreurs courantes](#erreurs-courantes)
2. [Problèmes de base de données](#problèmes-de-base-de-données)
3. [Problèmes de connexion](#problèmes-de-connexion)
4. [Problèmes Discord](#problèmes-discord)
5. [Problèmes de performance](#problèmes-de-performance)
6. [Mode debug](#mode-debug)
7. [Logs et diagnostics](#logs-et-diagnostics)
8. [FAQ technique](#faq-technique)

---

## Erreurs courantes

### ❌ "TABLES NON TROUVÉES"

**Message complet** :
```
[ERROR] TABLES NON TROUVÉES ! Veuillez importer le fichier installation.sql
```

**Cause** :
Le fichier SQL n'a pas été importé dans la base de données.

**Solution** :

1. Ouvrez phpMyAdmin
2. Sélectionnez votre base de données
3. Cliquez sur "Importer"
4. Sélectionnez `framework/sql/framework.sql`
5. Cliquez sur "Exécuter"

**Vérification** :
```sql
SHOW TABLES LIKE 'ama_%';
```
Vous devez voir 8 tables.

---

### ❌ "Can't connect to MySQL server"

**Message complet** :
```
[ERROR] Can't connect to MySQL server on 'localhost'
```

**Causes possibles** :
1. MySQL n'est pas démarré
2. Mauvaises identifiants de connexion
3. Mauvais hôte/port

**Solutions** :

**1. Vérifier que MySQL est démarré** :

Linux :
```bash
sudo systemctl status mysql
sudo systemctl start mysql
```

Windows :
```
services.msc
> Chercher "MySQL"
> Démarrer le service
```

**2. Vérifier la configuration** :

Dans `server.cfg` :
```cfg
set mysql_connection_string "mysql://utilisateur:motdepasse@localhost/nombase?charset=utf8mb4"
```

**3. Tester la connexion** :

```bash
mysql -u utilisateur -p
```

Si ça fonctionne, le problème vient de la configuration FiveM.

**4. Vérifier les permissions** :

```sql
SHOW GRANTS FOR 'utilisateur'@'localhost';
```

Si pas de permissions :
```sql
GRANT ALL PRIVILEGES ON nombase.* TO 'utilisateur'@'localhost';
FLUSH PRIVILEGES;
```

---

### ❌ "oxmysql not found"

**Message complet** :
```
[ERROR] Could not load dependency oxmysql
```

**Cause** :
oxmysql n'est pas installé ou pas démarré avant le framework.

**Solution** :

**1. Installer oxmysql** :

```bash
cd resources
git clone https://github.com/overextended/oxmysql.git
```

**2. Configurer server.cfg** :

```cfg
# IMPORTANT: oxmysql AVANT framework
ensure oxmysql
ensure framework
```

**3. Redémarrer le serveur**

**Vérification** :
```
> resmon
```
oxmysql doit apparaître dans la liste.

---

### ❌ "attempt to index a nil value (global 'AMA')"

**Message complet** :
```
[ERROR] server/main.lua:10: attempt to index a nil value (global 'AMA')
```

**Causes** :
1. Le framework n'est pas chargé
2. Ordre de chargement incorrect
3. Dépendance manquante

**Solutions** :

**1. Vérifier le fxmanifest.lua** :

```lua
dependencies {
    'oxmysql',
    'framework'  -- Assurez-vous que c'est bien "framework"
}
```

**2. Vérifier le server.cfg** :

```cfg
ensure oxmysql
ensure framework
ensure votre_resource  # Après framework
```

**3. Vérifier que framework est démarré** :

```
> status
```
Le framework doit apparaître.

---

### ❌ "Player not loaded"

**Message** :
```
Joueur non chargé ou données manquantes
```

**Causes** :
1. Le joueur n'est pas encore spawn
2. Problème de connexion à la BDD
3. Identifier non trouvé

**Solutions** :

**1. Attendre le chargement** :

Client :
```lua
CreateThread(function()
    while not exports['framework']:IsPlayerLoaded() do
        Wait(100)
    end
    
    -- Maintenant le joueur est chargé
    InitMonScript()
end)
```

**2. Vérifier les logs** :

Activez le debug :
```lua
Config.Framework.Debug = true
```

**3. Vérifier la base de données** :

```sql
SELECT * FROM ama_players WHERE identifier LIKE '%votre_license%';
```

---

### ❌ "Duplicate entry for key 'identifier'"

**Message complet** :
```sql
Duplicate entry 'license:abc123' for key 'identifier'
```

**Cause** :
Un joueur avec cet identifier existe déjà.

**Solutions** :

**1. Vérifier dans la BDD** :

```sql
SELECT * FROM ama_players WHERE identifier = 'license:abc123';
```

**2. Supprimer si doublon** :

```sql
DELETE FROM ama_players WHERE identifier = 'license:abc123' AND id = 123;
```

**3. Prévenir les doublons** :

Le framework gère normalement cela automatiquement. Si le problème persiste, vérifiez que vous n'avez pas deux instances du framework qui tournent.

---

## Problèmes de base de données

### Connexion lente

**Symptôme** :
Les joueurs mettent longtemps à se connecter.

**Solutions** :

**1. Optimiser les tables** :

```sql
OPTIMIZE TABLE ama_players;
OPTIMIZE TABLE ama_transactions;
OPTIMIZE TABLE ama_bitcoin_transactions;
```

**2. Vérifier les index** :

```sql
SHOW INDEX FROM ama_players;
```

Si manquants :
```sql
CREATE INDEX idx_identifier ON ama_players(identifier);
CREATE INDEX idx_uuid ON ama_players(uuid);
CREATE INDEX idx_wallet_uuid ON ama_players(wallet_uuid);
```

**3. Nettoyer les anciennes données** :

```sql
CALL cleanup_old_transactions();
```

---

### Tables corrompues

**Symptôme** :
```
[ERROR] Table 'ama_players' is marked as crashed
```

**Solution** :

```sql
REPAIR TABLE ama_players;
CHECK TABLE ama_players;
```

Si échec :
```sql
DROP TABLE ama_players;
-- Réimporter depuis un backup
```

---

### Données manquantes

**Symptôme** :
Les joueurs perdent leur argent, job, etc.

**Vérifications** :

**1. Vérifier les sauvegardes** :

```sql
SELECT * FROM ama_players ORDER BY id DESC LIMIT 5;
```

**2. Vérifier les triggers** :

```sql
SHOW TRIGGERS LIKE 'ama_players';
```

**3. Vérifier les logs** :

```sql
SELECT * FROM ama_transactions ORDER BY created_at DESC LIMIT 20;
```

**Solution** :

Si les données sont perdues, restaurez depuis un backup :
```bash
mysql -u utilisateur -p nombase < backup.sql
```

---

## Problèmes de connexion

### Joueur ne spawn pas

**Symptômes** :
- Écran noir à la connexion
- Joueur coincé dans le ciel
- Pas de spawn

**Solutions** :

**1. Vérifier les coordonnées de spawn** :

```lua
Config.Spawn.Default = {
    coords = vector3(-1037.72, -2738.93, 20.17),
    heading = 329.39
}
```

**2. Désactiver temporairement le spawn à la dernière position** :

```lua
Config.Spawn.EnableLastPosition = false
```

**3. Vérifier les logs client** :

F8 dans le jeu pour ouvrir la console.

**4. Forcer un spawn** :

Console F8 :
```
tp -1037.72 -2738.93 20.17
```

---

### "Kicked: Timed out"

**Symptôme** :
Les joueurs sont expulsés après quelques secondes.

**Causes** :
1. Serveur overload
2. Connexion réseau
3. Scripts qui freeze le client

**Solutions** :

**1. Augmenter le timeout** :

`server.cfg` :
```cfg
set sv_timeout 60
```

**2. Vérifier les performances** :

```
> resmon
```

Si un script consomme > 5ms, il y a un problème.

**3. Désactiver temporairement des resources** :

```cfg
#ensure problematic_resource
```

---

### Joueur ne se charge pas

**Symptôme** :
```
Joueur chargé: false
```

**Solutions** :

**1. Vérifier l'événement playerSpawned** :

```lua
AddEventHandler('playerSpawned', function()
    print("playerSpawned déclenché")
    TriggerServerEvent('ama:playerLoaded')
end)
```

**2. Déclencher manuellement** :

Console F8 :
```lua
TriggerServerEvent('ama:playerLoaded')
```

**3. Vérifier les hooks** :

Si vous avez des hooks qui retournent `false`, ils peuvent bloquer le chargement.

---

## Problèmes Discord

### Webhooks ne s'envoient pas

**Symptômes** :
- Pas de logs Discord
- Erreur 404 ou 429

**Solutions** :

**1. Vérifier l'URL du webhook** :

```lua
Config.Discord.Webhooks.Connection = "https://discord.com/api/webhooks/123456789/abcdefghijklmnop"
```

Ne doit PAS contenir "VOTRE_ID".

**2. Tester le webhook** :

```bash
curl -H "Content-Type: application/json" \
     -d '{"content":"Test"}' \
     https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN
```

**3. Vérifier les permissions** :

Le webhook doit avoir les permissions d'écriture dans le salon.

**4. Rate limiting** :

Si erreur 429 :
```lua
Config.Discord.RateLimit.Delay = 2000  -- 2 secondes au lieu de 1
```

---

### Embeds vides ou tronqués

**Symptôme** :
Les embeds Discord ne s'affichent pas correctement.

**Causes** :
- Dépassement de la limite de caractères
- JSON invalide

**Solutions** :

**1. Limiter la taille** :

```lua
Config.Discord.Settings.IncludeInventory = false
```

**2. Vérifier les limites** :

- Titre : 256 caractères max
- Description : 4096 caractères max
- Champ : 1024 caractères max
- Total : 6000 caractères max

**3. Valider le JSON** :

```lua
local success, err = pcall(json.encode, embed)
if not success then
    print("JSON invalide:", err)
end
```

---

### Erreur 401 Unauthorized

**Symptôme** :
```
[Discord] Erreur 401: Unauthorized
```

**Cause** :
Webhook invalide ou supprimé.

**Solution** :

1. Supprimer et recréer le webhook sur Discord
2. Copier la nouvelle URL
3. Mettre à jour `Config.Discord.Webhooks`
4. Redémarrer le serveur

---

## Problèmes de performance

### Serveur lag

**Symptômes** :
- FPS bas pour tous les joueurs
- Commandes lentes
- Désynchronisation

**Diagnostic** :

```
> resmon
```

Cherchez les ressources avec :
- CPU > 5ms
- Memory > 100MB

**Solutions** :

**1. Optimiser les threads** :

Mauvais :
```lua
CreateThread(function()
    while true do
        Wait(0)  -- 0ms = maximum CPU
        -- ...
    end
end)
```

Bon :
```lua
CreateThread(function()
    while true do
        if condition then
            Wait(0)
        else
            Wait(1000)  -- 1 seconde
        end
    end
end)
```

**2. Désactiver les fonctionnalités inutilisées** :

```lua
Config.AMACoin.Enabled = false
Config.Crews.Enabled = false
Config.Discord.Enabled = false
```

**3. Augmenter les délais** :

```lua
Config.Spawn.SaveDelay = 60000  -- 1 minute au lieu de 30s
```

---

### Client lag

**Symptômes** :
- FPS bas pour un joueur spécifique
- Freeze

**Solutions** :

**1. Vérifier les mods graphiques** :

Désactivez temporairement Redux, NaturalVision, etc.

**2. Réduire la distance de rendu** :

Paramètres graphiques → Distance de vue.

**3. Vérifier les scripts client** :

F8 → Onglet "Profiling"

**4. Afficher les FPS** :

```
/fps
```

Si < 30 FPS, problème graphique.
Si > 60 FPS, problème réseau.

---

### Base de données lente

**Symptômes** :
- Connexion lente
- Sauvegarde lente

**Solutions** :

**1. Activer le cache de requêtes** :

`my.cnf` ou `my.ini` :
```ini
[mysqld]
query_cache_size = 64M
query_cache_type = 1
```

**2. Augmenter les buffers** :

```ini
innodb_buffer_pool_size = 256M
key_buffer_size = 64M
```

**3. Optimiser les requêtes** :

```sql
EXPLAIN SELECT * FROM ama_players WHERE identifier = 'license:abc';
```

---

## Mode debug

### Activer le mode debug

**Configuration** :

```lua
Config.Framework = {
    Debug = true
}
```

**Redémarrer** :

```
restart framework
```

### Logs debug

Avec le mode debug activé, vous verrez :

```
[DEBUG] Joueur chargé: John Doe
[DEBUG] Position sauvegardée: -1037.72, -2738.93, 20.17
[DEBUG] Argent ajouté: 500 (Raison: Salaire)
[DEBUG] Webhook Discord envoyé
```

### Commandes de debug

**Serveur** :

```lua
RegisterCommand('debugplayer', function(source, args)
    local xPlayer = exports['framework']:GetPlayer(source)
    if not xPlayer then return end
    
    print("=== DEBUG PLAYER ===")
    print("Source:", xPlayer.source)
    print("Identifier:", xPlayer.identifier)
    print("UUID:", xPlayer.uuid)
    print("Name:", xPlayer.name)
    print("Money:", xPlayer.money)
    print("Bank:", xPlayer.bank)
    print("Bitcoin:", xPlayer.bitcoin)
    print("Job:", xPlayer.job, "Grade:", xPlayer.job_grade)
    print("Crew:", xPlayer.crew, "Grade:", xPlayer.crew_grade)
    print("Group:", xPlayer.group)
end)
```

**Client** :

```lua
RegisterCommand('debugclient', function()
    local data = exports['framework']:GetPlayerData()
    print("=== DEBUG CLIENT ===")
    print(json.encode(data, {indent = true}))
end)
```

---

## Logs et diagnostics

### Fichiers de logs

**Serveur** :

Linux :
```bash
tail -f /path/to/fivem/server.log
```

Windows :
```
notepad C:\FiveM\server.log
```

**Client** :

F8 dans le jeu → Console

### Exporter les logs

**Serveur** :

```bash
grep "AMA" server.log > ama_debug.log
```

**Client** :

F8 → Copier le contenu → Coller dans un fichier

### Activer les logs SQL

`server.cfg` :
```cfg
set mysql_debug 1
set mysql_slow_query_warning 100
```

Cela affichera toutes les requêtes SQL.

---

## FAQ technique

### Comment réinitialiser un joueur ?

```sql
DELETE FROM ama_players WHERE identifier = 'license:abc123';
```

À la prochaine connexion, un nouveau compte sera créé.

---

### Comment changer le groupe d'un joueur ?

```sql
UPDATE ama_players SET `group` = 'admin' WHERE identifier = 'license:abc123';
```

---

### Comment sauvegarder la base de données ?

```bash
mysqldump -u utilisateur -p nombase > backup_$(date +%Y%m%d).sql
```

---

### Comment restaurer une sauvegarde ?

```bash
mysql -u utilisateur -p nombase < backup_20241209.sql
```

---

### Comment ajouter de l'argent à tous les joueurs ?

```sql
UPDATE ama_players SET money = money + 1000;
```

---

### Comment voir les joueurs en ligne ?

```
> players
```

Ou :

```sql
SELECT 
    p.identifier,
    p.firstname,
    p.lastname,
    p.job,
    p.money + p.bank as total_money
FROM ama_players p
WHERE p.last_seen > NOW() - INTERVAL 1 HOUR;
```

---

### Comment trouver un joueur riche ?

```sql
SELECT 
    firstname,
    lastname,
    money,
    bank,
    (money + bank) as total
FROM ama_players
ORDER BY total DESC
LIMIT 10;
```

---

### Le framework ne se charge pas

**Vérifications** :

1. `fxmanifest.lua` existe et est valide
2. Toutes les dépendances sont installées
3. Pas d'erreurs Lua dans les logs
4. `server.cfg` contient `ensure framework`

**Test minimal** :

Créez `test.lua` :
```lua
print("Framework test")
```

Si ça s'affiche, le problème vient d'un fichier spécifique.

---

### Comment désactiver un système ?

**Discord** :
```lua
Config.Discord.Enabled = false
```

**AMACoin** :
```lua
Config.AMACoin.Enabled = false
```

**Crews** :
```lua
Config.Crews.Enabled = false
```

---

## 🆘 Support

Si le problème persiste après avoir essayé toutes ces solutions :

1. ✅ Activez le mode debug
2. ✅ Collectez les logs (serveur + client)
3. ✅ Notez les étapes pour reproduire le problème
4. ✅ Vérifiez la base de données
5. ✅ Contactez le support sur Discord avec ces informations

**Informations à fournir** :

- Version du framework
- Version FiveM (build number)
- Logs serveur
- Logs client (F8)
- Configuration (`Config.Framework.Debug = true`)
- Étapes de reproduction

---

## 📚 Voir aussi

- [Guide complet](GUIDE_COMPLET.md) - Installation et configuration
- [FAQ](FOIRE_AUX_QUESTIONS.md) - Questions fréquentes
- [Base de données](BASE_DONNEES.md) - Structure et requêtes

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2025
