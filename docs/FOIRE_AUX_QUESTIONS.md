# ❓ Foire Aux Questions (FAQ) - Framework AMA

## Table des matières

1. [Questions générales](#questions-générales)
2. [Installation et configuration](#installation-et-configuration)
3. [Utilisation](#utilisation)
4. [Développement](#développement)
5. [Performance](#performance)
6. [Sécurité](#sécurité)
7. [Économie](#économie)
8. [Compatibilité](#compatibilité)

---

## Questions générales

### Qu'est-ce que le Framework AMA ?

AMA Framework est un framework moderne pour FiveM, inspiré d'ESX mais entièrement réécrit pour offrir de meilleures performances et plus de fonctionnalités. Il inclut :

- Gestion complète des joueurs
- Système économique (argent, banque, AMACoin)
- Système de jobs avec grades
- Système de crews/organisations
- Intégration Discord
- Sauvegarde automatique

---

### Est-ce gratuit ?

**Réponse** : Consultez la licence fournie avec le framework. En général, le framework est fourni "tel quel" et vous êtes libre de le modifier selon vos besoins.

---

### Quelle est la différence avec ESX ?

**Principales différences** :

| Feature | AMA | ESX |
|---------|-----|-----|
| Base de données | oxmysql | mysql-async |
| Crypto-monnaie | ✅ Intégré | ❌ |
| Crews/Organisations | ✅ Intégré | ❌ |
| Discord logging | ✅ Intégré | ❌ |
| UUID unique | ✅ | ❌ |
| Performance | Optimisé | Standard |
| Code | Moderne (Lua 5.4) | Ancien |

---

### Puis-je migrer depuis ESX ?

**Réponse** : Oui, mais cela nécessite du travail manuel :

1. Exporter vos données ESX
2. Créer un script de migration
3. Adapter vos ressources existantes
4. Tester intensivement

**Note** : Aucun script de migration automatique n'est fourni actuellement.

---

### Le framework est-il compatible avec QB-Core ?

**Réponse** : Non, AMA Framework est incompatible avec QB-Core. Ils utilisent des structures de données différentes.

---

## Installation et configuration

### Comment installer le framework ?

**Réponse rapide** :

1. Importez `framework/sql/framework.sql` dans votre base de données
2. Configurez oxmysql dans `server.cfg`
3. Ajoutez `ensure framework` dans `server.cfg`
4. Configurez `shared/config.lua`
5. Redémarrez le serveur

**Guide complet** : Consultez [GUIDE_COMPLET.md](GUIDE_COMPLET.md)

---

### Dois-je obligatoirement importer le fichier SQL ?

**Réponse** : Oui, absolument ! Sans les tables de la base de données, le framework ne peut pas fonctionner.

---

### Où trouver mes identifiants MySQL ?

**Réponse** :

- **Hébergeur** : Dans le panel de votre hébergeur (section "Base de données")
- **Serveur local** :
  - User : `root`
  - Password : (celui défini lors de l'installation)
  - Database : Le nom que vous avez créé
  - Host : `localhost`

---

### Comment configurer le point de spawn ?

**Réponse** :

1. Allez à l'endroit où vous voulez spawn
2. Tapez `/pos` dans le chat
3. Copiez les coordonnées
4. Éditez `shared/config.lua` :

```lua
Config.Spawn.Default = {
    coords = vector3(-1037.72, -2738.93, 20.17),  -- Vos coordonnées
    heading = 329.39  -- Votre heading
}
```

---

### Comment changer l'argent de départ ?

**Réponse** :

Dans `shared/config.lua` :

```lua
Config.Player = {
    StartMoney = 5000,    -- Argent liquide
    StartBank = 0,        -- Compte bancaire
    StartBitcoin = 0      -- AMACoin
}
```

---

### Comment ajouter un nouveau métier ?

**Réponse** :

1. Dans la base de données :

```sql
-- Ajouter le job
INSERT INTO `ama_jobs` (`name`, `label`, `whitelisted`) VALUES
('mon_metier', 'Mon Métier', 0);

-- Ajouter les grades
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
('mon_metier', 0, 'recrue', 'Recrue', 500),
('mon_metier', 1, 'membre', 'Membre', 1000);
```

2. Redémarrer le serveur

**Guide détaillé** : [EXEMPLES_CODE.md](EXEMPLES_CODE.md#créer-un-nouveau-job)

---

### Comment devenir admin ?

**Réponse** :

1. Connectez-vous au serveur
2. Dans la base de données :

```sql
UPDATE ama_players
SET `group` = 'admin'
WHERE identifier = 'license:VOTRE_LICENSE';
```

3. Déconnectez-vous et reconnectez-vous

**Trouver votre license** :

```sql
SELECT identifier, firstname, lastname
FROM ama_players
ORDER BY id DESC
LIMIT 5;
```

---

## Utilisation

### Comment donner de l'argent à un joueur ?

**Réponse** :

**En tant qu'admin** :
```
/givemoney [id] [montant]
```

**Via script serveur** :
```lua
local xPlayer = exports['framework']:GetPlayer(targetId)
xPlayer:addMoney(1000, "Cadeau")
```

---

### Comment changer le métier d'un joueur ?

**Réponse** :

**En tant qu'admin** :
```
/setjob [id] [nom_job] [grade]
```

**Via script serveur** :
```lua
local xPlayer = exports['framework']:GetPlayer(targetId)
xPlayer:setJob("police", 2)
```

---

### Comment envoyer des AMACoins ?

**Réponse** :

1. Obtenez le wallet UUID du destinataire :
   - Le destinataire tape `/wallet`
   - Il vous communique son UUID

2. Envoyez les coins :
```
/sendcoin [wallet_uuid] [montant]
```

---

### Comment créer un crew ?

**Réponse** :

Dans la base de données :

```sql
INSERT INTO `ama_crews` (`name`, `label`, `color`, `bank`) VALUES
('mon_crew', 'Mon Crew', '#FF5733', 10000);
```

Puis ajoutez dans `shared/config.lua` :

```lua
Config.Crews.Available = {
    {name = "mon_crew", label = "Mon Crew", color = "#FF5733"}
}
```

---

### Comment sauvegarder ma position ?

**Réponse** :

Tapez dans le chat :
```
/save
```

La position est également sauvegardée automatiquement toutes les 30 secondes (configurable).

---

### Où sont sauvegardées mes données ?

**Réponse** :

Toutes les données sont dans la base de données MySQL :
- Table `ama_players` : Données principales
- Table `ama_transactions` : Historique financier
- Table `ama_bitcoin_transactions` : Historique AMACoin
- Table `ama_vehicles` : Vos véhicules

---

## Développement

### Comment accéder à l'API du framework ?

**Réponse** :

**Côté serveur** :

```lua
-- Via exports
local xPlayer = exports['framework']:GetPlayer(source)

-- Directement si dans le framework
local xPlayer = AMA.GetPlayer(source)
```

**Côté client** :

```lua
-- Via exports
local playerData = exports['framework']:GetPlayerData()

-- Directement si dans le framework
local playerData = AMA.GetPlayerData()
```

**Documentation complète** : [API_SERVEUR.md](API_SERVEUR.md) et [API_CLIENT.md](API_CLIENT.md)

---

### Comment créer une commande personnalisée ?

**Réponse** :

**Serveur** :

```lua
RegisterCommand('macommande', function(source, args)
    local xPlayer = exports['framework']:GetPlayer(source)
    if not xPlayer then return end
    
    -- Votre code ici
    TriggerClientEvent('ama:showNotification', source, "Commande exécutée!")
end, false)
```

**Client** :

```lua
RegisterCommand('macommande', function()
    -- Votre code ici
    exports['framework']:ShowNotification("Commande exécutée!")
end, false)
```

**Plus d'exemples** : [EXEMPLES_CODE.md](EXEMPLES_CODE.md#ajouter-une-commande-personnalisée)

---

### Comment enregistrer un callback serveur ?

**Réponse** :

**Serveur** :

```lua
AMA.RegisterServerCallback('mon_callback', function(source, cb, arg1, arg2)
    -- Votre code
    cb(resultat)
end)
```

**Client** :

```lua
AMA.TriggerServerCallback('mon_callback', function(resultat)
    print("Résultat:", resultat)
end, arg1, arg2)
```

---

### Comment utiliser les hooks ?

**Réponse** :

**Enregistrer un hook** :

```lua
AMA.RegisterHook("ama:hook:playerLoaded", function(playerData)
    print("Joueur chargé:", playerData.firstname)
end)
```

**Hooks disponibles** :

Consultez [GUIDE_COMPLET.md](GUIDE_COMPLET.md#hooks-et-événements)

---

### Comment logger sur Discord ?

**Réponse** :

```lua
local embed = {
    title = "📝 Mon log",
    description = "Description de l'événement",
    color = 3066993,  -- Vert
    fields = {
        {name = "Champ 1", value = "Valeur 1", inline = true}
    }
}

local webhook = Config.Discord.Webhooks.Connection
AMA.Discord.SendWebhook(webhook, embed)
```

**Configuration** : [GUIDE_COMPLET.md](GUIDE_COMPLET.md#intégration-discord)

---

### Puis-je créer des modules personnalisés ?

**Réponse** : Oui ! Le framework supporte un système de modules.

**Exemple** :

Créez `modules/mon_module.lua` :

```lua
local MonModule = {}

function MonModule.Init()
    print("Module chargé!")
end

AMA.RegisterModule("mon_module", MonModule)
```

Ajoutez dans `fxmanifest.lua` :

```lua
shared_scripts {
    'modules/mon_module.lua'
}
```

---

## Performance

### Le serveur lag, que faire ?

**Réponse** :

**1. Vérifier les performances** :

```
> resmon
```

**2. Optimiser le framework** :

```lua
-- Dans shared/config.lua
Config.Spawn.SaveDelay = 60000  -- Augmenter à 1 minute
Config.Discord.Enabled = false  -- Désactiver si non utilisé
Config.AMACoin.Enabled = false  -- Désactiver si non utilisé
```

**3. Nettoyer la base de données** :

```sql
CALL cleanup_old_transactions();
OPTIMIZE TABLE ama_players;
```

**Guide complet** : [TROUBLESHOOTING.md](TROUBLESHOOTING.md#problèmes-de-performance)

---

### Combien de joueurs le framework supporte-t-il ?

**Réponse** :

Le framework a été testé avec :
- **32 joueurs** : Aucun problème
- **64 joueurs** : Performances excellentes
- **128 joueurs** : Performances correctes avec optimisation

**Limitations** :
- Dépend de votre matériel serveur
- Dépend des autres ressources installées
- Dépend de votre connexion réseau

---

### La sauvegarde est-elle automatique ?

**Réponse** : Oui !

**Fréquence** :
- Toutes les 30 secondes (configurable)
- À la déconnexion
- Commande `/save` manuelle

**Configuration** :

```lua
Config.Spawn = {
    SaveDelay = 30000,  -- 30 secondes
    MinDistanceToSave = 10.0  -- Minimum 10m de déplacement
}
```

---

## Sécurité

### Le framework est-il sécurisé ?

**Réponse** : Le framework inclut plusieurs mesures de sécurité :

- ✅ Vérifications côté serveur
- ✅ Protection contre les doublons
- ✅ Validation des transactions
- ✅ Logs des actions importantes
- ✅ Permissions par groupe

**Recommandations** :
- Gardez le framework à jour
- Ne partagez pas vos webhooks Discord
- Utilisez des mots de passe forts pour MySQL
- Limitez les accès admin

---

### Comment protéger ma base de données ?

**Réponse** :

**1. Utiliser un mot de passe fort** :

```sql
ALTER USER 'utilisateur'@'localhost' IDENTIFIED BY 'MotDePasseTresComplexe123!';
```

**2. Limiter les permissions** :

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON nombase.* TO 'utilisateur'@'localhost';
FLUSH PRIVILEGES;
```

**3. Sauvegardes régulières** :

```bash
# Cron quotidien
0 3 * * * mysqldump -u user -p'pass' nombase > /backups/backup_$(date +\%Y\%m\%d).sql
```

**4. Ne pas exposer MySQL** :

Dans `my.cnf` :
```ini
bind-address = 127.0.0.1
```

---

### Puis-je désactiver certaines fonctionnalités ?

**Réponse** : Oui, dans `shared/config.lua` :

```lua
Config.Discord.Enabled = false    -- Désactiver Discord
Config.AMACoin.Enabled = false    -- Désactiver AMACoin
Config.Crews.Enabled = false      -- Désactiver les crews
```

---

## Économie

### Comment équilibrer l'économie ?

**Réponse** :

**1. Définir des valeurs cohérentes** :

```lua
Config.Player = {
    StartMoney = 5000,    -- Argent de départ raisonnable
    StartBank = 0
}

-- Salaires proportionnels
-- Recrue: 500
-- Expérimenté: 1000
-- Expert: 1500
-- Boss: 2500
```

**2. Surveiller** :

```sql
-- Argent moyen par joueur
SELECT AVG(money + bank) FROM ama_players;

-- Joueurs les plus riches
SELECT * FROM ama_players ORDER BY (money + bank) DESC LIMIT 10;
```

**3. Ajuster les prix** :

- Nourriture : 5-20$
- Vêtements : 50-500$
- Voitures : 5000-500000$
- Maisons : 50000-5000000$

---

### Le taux de change AMACoin est-il modifiable ?

**Réponse** : Oui, dans `shared/config.lua` :

```lua
Config.AMACoin = {
    ExchangeRate = 100,      -- 1 ₿ = $100 (modifiable)
    TransactionFee = 2.5,    -- 2.5% de frais
    MinTransaction = 0.01,
    MaxPerPlayer = 1000
}
```

**Impact** :
- Plus élevé = AMACoin plus précieux
- Plus bas = AMACoin moins précieux

---

### Comment éviter l'inflation ?

**Réponse** :

**1. Puits d'argent (money sinks)** :

- Taxes sur les transactions
- Frais de réparation
- Frais de location
- Amendes

**2. Limiter les gains** :

- Salaires raisonnables
- Cooldowns sur les missions
- Plafond d'argent

**3. Surveillance** :

```sql
-- Argent total en circulation
SELECT SUM(money + bank) FROM ama_players;
```

Si l'argent augmente trop vite, réduisez les sources de revenus.

---

## Compatibilité

### Avec quelles ressources le framework est-il compatible ?

**Réponse** :

**Compatible** :
- ✅ Resources standalone (indépendantes)
- ✅ Resources adaptées pour AMA
- ✅ oxmysql
- ✅ ox_inventory (avec adaptation)
- ✅ pma-voice
- ✅ dpemotes

**Incompatible** :
- ❌ ESX resources (sans modification)
- ❌ QB-Core resources
- ❌ VRP resources

---

### Comment adapter une resource ESX ?

**Réponse** :

**Changements principaux** :

```lua
-- ESX
ESX.GetPlayerData()
ESX.PlayerData.job
xPlayer.addMoney(amount)

-- AMA Framework
exports['framework']:GetPlayerData()
playerData.job
xPlayer:addMoney(amount)  -- Note: deux-points au lieu de point
```

**Guide** : Consultez la documentation de la resource à adapter.

---

### Le framework fonctionne-t-il avec OneSync ?

**Réponse** : Oui ! Le framework est compatible avec :

- OneSync Legacy
- OneSync Infinity

Recommandation : OneSync Infinity pour plus de 32 joueurs.

---

### Puis-je utiliser mon propre système d'inventaire ?

**Réponse** : Oui ! Le framework ne force aucun inventaire spécifique.

**Inventaires compatibles** :
- ox_inventory (avec adaptation)
- qs-inventory (avec adaptation)
- Tout inventaire custom

**Note** : Le framework stocke l'inventaire en JSON dans `ama_players.inventory`.

---

## Questions avancées

### Comment créer une économie croisée entre serveurs ?

**Réponse** : Utilisez les UUID et wallet_uuid :

1. Base de données partagée entre serveurs
2. API pour synchroniser les données
3. Vérifier les UUID au lieu des identifiers

**Attention** : Complexe et nécessite une infrastructure robuste.

---

### Comment exporter des données pour des statistiques ?

**Réponse** :

```sql
-- Export CSV
SELECT * FROM ama_players
INTO OUTFILE '/tmp/players.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Ou via mysqldump
mysqldump -u user -p --tab=/tmp nombase ama_players
```

---

### Comment migrer vers un nouveau serveur ?

**Réponse** :

**1. Sauvegarder** :

```bash
mysqldump -u user -p nombase > backup.sql
```

**2. Sur le nouveau serveur** :

```bash
mysql -u user -p nouvelle_base < backup.sql
```

**3. Configurer** :

- Mettre à jour `server.cfg`
- Copier les fichiers du framework
- Tester

---

### Où trouver plus d'aide ?

**Réponse** :

**Documentation** :
- [Guide complet](GUIDE_COMPLET.md)
- [API Serveur](API_SERVEUR.md)
- [API Client](API_CLIENT.md)
- [Exemples de code](EXEMPLES_CODE.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Base de données](BASE_DONNEES.md)

**Communauté** :
- Discord du serveur
- Forums FiveM
- Documentation FiveM officielle

---

## 💡 Conseils

### Pour les débutants

1. **Lisez le guide complet** avant de commencer
2. **Testez en local** avant de déployer
3. **Activez le mode debug** pendant le développement
4. **Faites des sauvegardes** régulières
5. **Commencez simple** et ajoutez des fonctionnalités progressivement

### Pour les développeurs

1. **Utilisez les hooks** plutôt que de modifier le core
2. **Créez des modules** pour vos fonctionnalités
3. **Documentez votre code**
4. **Testez intensivement**
5. **Suivez les conventions** du framework

### Pour les administrateurs

1. **Surveillez les logs** Discord
2. **Optimisez régulièrement** la base de données
3. **Faites des backups** quotidiens
4. **Limitez les permissions** admin
5. **Équilibrez l'économie** avec des statistiques

---

## 📚 Ressources

- [Guide complet](GUIDE_COMPLET.md)
- [API Serveur](API_SERVEUR.md)
- [API Client](API_CLIENT.md)
- [Commandes](COMMANDES.md)
- [Exemples de code](EXEMPLES_CODE.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Base de données](BASE_DONNEES.md)

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2025

**Vous ne trouvez pas votre réponse ?**  
Consultez le [Troubleshooting](TROUBLESHOOTING.md) ou contactez le support.
