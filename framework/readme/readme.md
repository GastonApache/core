# AMA Framework pour FiveM

## 📋 Description

AMA Framework est un framework moderne et optimisé pour FiveM, inspiré d'ESX mais avec des améliorations significatives en termes de fluidité et de fonctionnalités. Il gère automatiquement le spawn des joueurs, la sauvegarde de leurs positions et leurs données persistantes.

## ✨ Fonctionnalités principales

- **Spawn intelligent** : Les joueurs spawent à leur dernière position enregistrée
- **Sauvegarde automatique** : Position et données du joueur sauvegardées automatiquement
- **Système de job** : Gestion complète des métiers et grades
- **Gestion de l'argent** : Argent liquide et compte en banque
- **Optimisé** : Performance améliorée par rapport aux frameworks traditionnels
- **Base de données** : Utilise oxmysql pour une meilleure performance
- **Système de callbacks** : Communication client-serveur optimisée

## 📦 Installation

### Prérequis

- Un serveur FiveM fonctionnel
- oxmysql installé
- Une base de données MySQL/MariaDB

### Étapes d'installation

1. **Télécharger le framework**
   ```bash
   cd resources
   git clone [votre-repo] ama_framework
   ```

2. **Configurer la base de données**
   - Exécutez le fichier `installation.sql` dans votre base de données
   - Cela créera toutes les tables nécessaires et insérera les données par défaut

3. **Configurer oxmysql**
   Ajoutez dans votre `server.cfg` :
   ```cfg
   set mysql_connection_string "mysql://utilisateur:motdepasse@localhost/nombase?charset=utf8mb4"
   ```

4. **Ajouter au server.cfg**
   ```cfg
   ensure oxmysql
   ensure ama_framework
   ```

5. **Configurer le framework**
   Modifiez le fichier `shared/config.lua` selon vos besoins :
   - Point de spawn par défaut
   - Argent de départ
   - Délai de sauvegarde
   - Messages personnalisés

## 🎮 Utilisation

### Commandes disponibles

#### Joueurs
- `/save` - Sauvegarder manuellement sa position
- `/me` - Afficher ses informations
- `/pos` - Afficher sa position actuelle
- `/fps` - Afficher/masquer les FPS

#### Administrateurs
- `/givemoney [id] [montant]` - Donner de l'argent
- `/tp [id]` - Se téléporter vers un joueur

### API Serveur

```lua
-- Obtenir un joueur
local xPlayer = AMA.GetPlayer(source)

-- Obtenir tous les joueurs
local players = AMA.GetPlayers()

-- Ajouter de l'argent
xPlayer:addMoney(amount)

-- Retirer de l'argent
if xPlayer:removeMoney(amount) then
    print("Argent retiré")
end

-- Changer de job
xPlayer:setJob('police', 2)

-- Obtenir le job
local job = xPlayer:getJob()
print(job.name, job.grade)
```

### API Client

```lua
-- Vérifier si le joueur est chargé
if AMA.IsPlayerLoaded() then
    print("Joueur chargé")
end

-- Obtenir les données du joueur
local playerData = AMA.GetPlayerData()
print(playerData.money, playerData.job)

-- Afficher une notification
AMA.ShowNotification("Message")

-- Callback serveur
AMA.TriggerServerCallback('nom_callback', function(result)
    print(result)
end, arg1, arg2)
```

## 🗂️ Structure des fichiers

```
ama_framework/
├── fxmanifest.lua
├── installation.sql
├── README.md
├── shared/
│   ├── config.lua          # Configuration principale
│   └── functions.lua       # Fonctions partagées
├── server/
│   ├── main.lua           # Initialisation serveur
│   ├── player.lua         # Gestion des joueurs
│   └── commands.lua       # Commandes serveur
└── client/
    ├── main.lua           # Initialisation client
    ├── spawn.lua          # Gestion du spawn
    └── events.lua         # Événements client
```

## ⚙️ Configuration

### Spawn par défaut
```lua
Config.Spawn = {
    Default = {
        coords = vector3(-1037.72, -2738.93, 20.17),
        heading = 329.39
    },
    SaveDelay = 30000,
    MinDistanceToSave = 10.0,
    EnableLastPosition = true
}
```

### Argent de départ
```lua
Config.Player = {
    StartMoney = 5000,
    DefaultData = {
        job = "unemployed",
        job_grade = 0,
        group = "user"
    }
}
```

## 🔧 Base de données

### Table principale : `ama_players`
- Stocke toutes les informations des joueurs
- Position automatiquement sauvegardée
- Inventaire et comptes en JSON
- Historique de connexion

### Tables des métiers
- `ama_jobs` : Liste des métiers
- `ama_job_grades` : Grades et salaires

### Autres tables
- `ama_vehicles` : Véhicules des joueurs
- `ama_transactions` : Historique des transactions

## 🚀 Optimisations

1. **Sauvegarde intelligente** : Ne sauvegarde que si le joueur s'est déplacé
2. **Distance minimale** : Évite les sauvegardes inutiles
3. **Sauvegarde automatique** : Toutes les 5 minutes pour tous les joueurs
4. **Callbacks optimisés** : Communication client-serveur efficace
5. **Threads optimisés** : Utilisation de Wait() adaptatifs

## 🐛 Debug

Activez le mode debug dans `shared/config.lua` :
```lua
Config.Framework = {
    Debug = true
}
```

Les logs apparaîtront dans la console avec des couleurs :
- 🔵 INFO : Informations générales
- 🟡 WARN : Avertissements
- 🔴 ERROR : Erreurs

## 📝 Notes importantes

- Les positions sont sauvegardées automatiquement toutes les 30 secondes (configurable)
- Le joueur ne doit pas être en véhicule pour que la position soit sauvegardée
- La sauvegarde se fait uniquement si le joueur s'est déplacé d'au moins 10 mètres
- À la déconnexion, une dernière sauvegarde est effectuée automatiquement

## 🤝 Support

Pour toute question ou problème, consultez la documentation ou contactez le support.

## 📄 Licence

Ce framework est fourni tel quel. Vous êtes libre de le modifier selon vos besoins.

---

**Version** : 1.0.0  
**Auteur** : AMA Framework Team  
**Compatibilité** : FiveM Build 2545+

# 📥 Guide d'installation - AMA Framework

## ⚠️ IMPORTANT - Installation de la base de données

Le framework AMA nécessite une base de données MySQL/MariaDB. **Vous devez impérativement importer le fichier SQL avant de lancer le serveur.**

---

## 📋 Prérequis

- ✅ Serveur FiveM fonctionnel
- ✅ oxmysql installé et configuré
- ✅ Base de données MySQL/MariaDB
- ✅ Accès phpMyAdmin ou client SQL

---

## 🚀 Installation étape par étape

### 1️⃣ Télécharger le framework

```bash
cd resources
git clone [votre-repo] ama_framework
```

Ou extrayez le ZIP dans votre dossier `resources/`.

---

### 2️⃣ Importer la base de données SQL

**CETTE ÉTAPE EST OBLIGATOIRE !**

#### Option A : Via phpMyAdmin (Recommandé)

1. Ouvrez phpMyAdmin
2. Sélectionnez votre base de données FiveM
3. Cliquez sur l'onglet **"Importer"**
4. Cliquez sur **"Choisir un fichier"**
5. Sélectionnez le fichier `installation.sql` (dans le dossier ama_framework)
6. Cliquez sur **"Exécuter"**
7. Attendez la confirmation ✅

#### Option B : Via ligne de commande

```bash
mysql -u votre_utilisateur -p votre_base_de_donnees < installation.sql
```

#### Option C : Via HeidiSQL / MySQL Workbench

1. Connectez-vous à votre base de données
2. Ouvrez le fichier `installation.sql`
3. Exécutez le script (F9)

---

### 3️⃣ Vérifier l'importation

Vérifiez que ces tables ont bien été créées :

- ✅ `ama_players`
- ✅ `ama_jobs`
- ✅ `ama_job_grades`
- ✅ `ama_crews`
- ✅ `ama_bitcoin_transactions`
- ✅ `ama_vehicles`
- ✅ `ama_transactions`
- ✅ `ama_crew_logs`

**Requête de vérification :**
```sql
SHOW TABLES LIKE 'ama_%';
```

Vous devriez voir **8 tables**.

---

### 4️⃣ Configurer oxmysql

Dans votre fichier `server.cfg` :

```cfg
# Configuration MySQL
set mysql_connection_string "mysql://utilisateur:motdepasse@localhost/nom_base?charset=utf8mb4"

# OU en variables séparées
set mysql_user "utilisateur"
set mysql_password "motdepasse"
set mysql_database "nom_base"
set mysql_host "localhost"
```

**Remplacez :**
- `utilisateur` : votre utilisateur MySQL
- `motdepasse` : votre mot de passe
- `nom_base` : le nom de votre base de données

---

### 5️⃣ Ajouter le framework au server.cfg

```cfg
# Dépendances
ensure oxmysql

# Framework
ensure ama_framework
```

**⚠️ Attention à l'ordre !**
- oxmysql doit être démarré **AVANT** ama_framework

---

### 6️⃣ Configuration du framework

Éditez le fichier `shared/config.lua` selon vos besoins :

#### Point de spawn par défaut
```lua
Config.Spawn = {
    Default = {
        coords = vector3(-1037.72, -2738.93, 20.17),
        heading = 329.39
    }
}
```

#### Argent de départ
```lua
Config.Player = {
    StartMoney = 5000,
    StartBank = 0,
    StartBitcoin = 0
}
```

#### Webhooks Discord (optionnel)
```lua
Config.Discord = {
    Enabled = true,  -- false pour désactiver
    Webhooks = {
        Connection = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        Disconnection = "https://discord.com/api/webhooks/VOTRE_ID/VOTRE_TOKEN",
        -- ...
    }
}
```

---

### 7️⃣ Démarrer le serveur

1. Sauvegardez tous vos fichiers
2. (Re)démarrez votre serveur FiveM
3. Vérifiez les logs dans la console

**✅ Message de succès attendu :**
```
[AMA Framework] Tables de base de données détectées
[AMA Framework] Système de sérialisation chargé
[AMA Framework] Système de logs Discord chargé
[AMA Framework] Système de Crews chargé
[AMA Framework] Système AMACoin chargé
```

**❌ Si vous voyez :**
```
[ERROR] TABLES NON TROUVÉES ! Veuillez importer le fichier installation.sql
```
→ Retournez à l'étape 2 et importez le fichier SQL.

---

## 🔧 Configuration avancée

### Ajouter des métiers personnalisés

Ajoutez dans la table `ama_jobs` :

```sql
INSERT INTO `ama_jobs` (`name`, `label`, `whitelisted`) VALUES
('monmetier', 'Mon Métier', 0);

INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
('monmetier', 0, 'recrue', 'Recrue', 500),
('monmetier', 1, 'experimente', 'Expérimenté', 1000),
('monmetier', 2, 'boss', 'Patron', 1500);
```

### Ajouter des crews personnalisés

```sql
INSERT INTO `ama_crews` (`name`, `label`, `color`, `bank`) VALUES
('moncrew', 'Mon Crew', '#FF5733', 10000);
```

### Modifier le taux de change AMACoin

Dans `shared/config.lua` :

```lua
Config.AMACoin = {
    ExchangeRate = 100,  -- 1 ₿ = $100
    TransactionFee = 2.5  -- 2.5% de frais
}
```

---

## 🐛 Dépannage

### Erreur : "Tables non trouvées"

**Solution :**
1. Vérifiez que le fichier SQL a bien été importé
2. Vérifiez la connexion MySQL dans server.cfg
3. Testez la connexion avec :
   ```bash
   mysql -u utilisateur -p
   USE nom_base;
   SHOW TABLES;
   ```

### Erreur : "Can't connect to MySQL server"

**Solution :**
1. Vérifiez que MySQL est démarré
2. Vérifiez les identifiants de connexion
3. Vérifiez que l'utilisateur a les permissions nécessaires

### Les joueurs ne se connectent pas

**Solution :**
1. Activez le debug : `Config.Framework.Debug = true`
2. Regardez les logs console
3. Vérifiez les permissions de la base de données

### Les webhooks Discord ne fonctionnent pas

**Solution :**
1. Vérifiez les URLs des webhooks (ne doivent pas contenir "VOTRE_ID")
2. Testez les webhooks avec curl :
   ```bash
   curl -H "Content-Type: application/json" -d '{"content":"Test"}' WEBHOOK_URL
   ```
3. Désactivez temporairement : `Config.Discord.Enabled = false`

---

## 📊 Vérification post-installation

### 1. Test de connexion
- Connectez-vous au serveur
- Vérifiez que vous apparaissez dans la table `ama_players`

### 2. Test des commandes
```
/me              - Afficher vos informations
/wallet          - Afficher votre wallet AMACoin
/pos             - Afficher votre position
```

### 3. Vérification base de données
```sql
-- Vérifier qu'un joueur a été créé
SELECT * FROM ama_players LIMIT 1;

-- Vérifier les métiers
SELECT COUNT(*) FROM ama_jobs;

-- Vérifier les crews
SELECT COUNT(*) FROM ama_crews;
```

---

## 📝 Maintenance

### Sauvegarde régulière

Sauvegardez régulièrement vos données :

```bash
mysqldump -u utilisateur -p nom_base > backup_$(date +%Y%m%d).sql
```

### Nettoyage des anciennes transactions

Le script inclut une procédure pour nettoyer automatiquement :

```sql
CALL cleanup_old_transactions();
```

---

## 🆘 Support

Si vous rencontrez des problèmes :

1. ✅ Vérifiez ce guide d'installation
2. ✅ Consultez les logs du serveur
3. ✅ Activez le mode debug
4. ✅ Vérifiez la base de données
5. ✅ Contactez le support sur Discord

---

## ✅ Checklist finale

Avant de déclarer l'installation terminée :

- [ ] Base de données importée (8 tables créées)
- [ ] oxmysql configuré et démarré
- [ ] ama_framework ajouté au server.cfg
- [ ] Configuration personnalisée (spawn, argent, webhooks)
- [ ] Serveur redémarré avec succès
- [ ] Test de connexion effectué
- [ ] Commandes testées (/me, /wallet)
- [ ] Logs Discord reçus (si activés)

---

**🎉 Installation terminée ! Bon jeu sur votre serveur AMA Framework !**

---

## 📚 Documentation supplémentaire

- [README.md](README.md) - Documentation générale
- [GUIDE_MODDEURS.md](GUIDE_MODDEURS.md) - Guide pour développeurs
- [DISCORD_SETUP.md](DISCORD_SETUP.md) - Configuration Discord

---

**Version du guide :** 1.0.0  
**Dernière mise à jour :** Décembre 2025

# AMA Framework pour FiveM

## 📋 Description

AMA Framework est un framework moderne et optimisé pour FiveM, inspiré d'ESX mais avec des améliorations significatives en termes de fluidité et de fonctionnalités. Il gère automatiquement le spawn des joueurs, la sauvegarde de leurs positions et leurs données persistantes.

## ✨ Fonctionnalités principales

- **Spawn intelligent** : Les joueurs spawent à leur dernière position enregistrée
- **Sauvegarde automatique** : Position et données du joueur sauvegardées automatiquement
- **Système de job** : Gestion complète des métiers et grades
- **Gestion de l'argent** : Argent liquide et compte en banque
- **Optimisé** : Performance améliorée par rapport aux frameworks traditionnels
- **Base de données** : Utilise oxmysql pour une meilleure performance
- **Système de callbacks** : Communication client-serveur optimisée

## 📦 Installation

### ⚠️ IMPORTANT

**Vous DEVEZ importer le fichier `installation.sql` dans votre base de données avant de démarrer le serveur !**

### Installation rapide

1. **Importer la base de données**
   - Ouvrez phpMyAdmin
   - Sélectionnez votre base de données
   - Importez le fichier `installation.sql`
   - ✅ Vérifiez que 8 tables ont été créées

2. **Configurer oxmysql**
   ```cfg
   set mysql_connection_string "mysql://user:password@localhost/database?charset=utf8mb4"
   ```

3. **Ajouter au server.cfg**
   ```cfg
   ensure oxmysql
   ensure ama_framework
   ```

4. **Configuration** (optionnel)
   - Modifiez `shared/config.lua`
   - Configurez les webhooks Discord dans `shared/discord_config.lua`

📖 **[Guide d'installation complet](INSTALLATION.md)** - Consultez ce guide pour les instructions détaillées

## 🎮 Utilisation

### Commandes disponibles

#### Joueurs
- `/save` - Sauvegarder manuellement sa position
- `/me` - Afficher ses informations
- `/pos` - Afficher sa position actuelle
- `/fps` - Afficher/masquer les FPS

#### Administrateurs
- `/givemoney [id] [montant]` - Donner de l'argent
- `/tp [id]` - Se téléporter vers un joueur

### API Serveur

```lua
-- Obtenir un joueur
local xPlayer = AMA.GetPlayer(source)

-- Obtenir tous les joueurs
local players = AMA.GetPlayers()

-- Ajouter de l'argent
xPlayer:addMoney(amount)

-- Retirer de l'argent
if xPlayer:removeMoney(amount) then
    print("Argent retiré")
end

-- Changer de job
xPlayer:setJob('police', 2)

-- Obtenir le job
local job = xPlayer:getJob()
print(job.name, job.grade)
```

### API Client

```lua
-- Vérifier si le joueur est chargé
if AMA.IsPlayerLoaded() then
    print("Joueur chargé")
end

-- Obtenir les données du joueur
local playerData = AMA.GetPlayerData()
print(playerData.money, playerData.job)

-- Afficher une notification
AMA.ShowNotification("Message")

-- Callback serveur
AMA.TriggerServerCallback('nom_callback', function(result)
    print(result)
end, arg1, arg2)
```

## 🗂️ Structure des fichiers

```
ama_framework/
├── fxmanifest.lua
├── installation.sql
├── README.md
├── shared/
│   ├── config.lua          # Configuration principale
│   └── functions.lua       # Fonctions partagées
├── server/
│   ├── main.lua           # Initialisation serveur
│   ├── player.lua         # Gestion des joueurs
│   └── commands.lua       # Commandes serveur
└── client/
    ├── main.lua           # Initialisation client
    ├── spawn.lua          # Gestion du spawn
    └── events.lua         # Événements client
```

## ⚙️ Configuration

### Spawn par défaut
```lua
Config.Spawn = {
    Default = {
        coords = vector3(-1037.72, -2738.93, 20.17),
        heading = 329.39
    },
    SaveDelay = 30000,
    MinDistanceToSave = 10.0,
    EnableLastPosition = true
}
```

### Argent de départ
```lua
Config.Player = {
    StartMoney = 5000,
    DefaultData = {
        job = "unemployed",
        job_grade = 0,
        group = "user"
    }
}
```

## 🔧 Base de données

### Table principale : `ama_players`
- Stocke toutes les informations des joueurs
- Position automatiquement sauvegardée
- Inventaire et comptes en JSON
- Historique de connexion

### Tables des métiers
- `ama_jobs` : Liste des métiers
- `ama_job_grades` : Grades et salaires

### Autres tables
- `ama_vehicles` : Véhicules des joueurs
- `ama_transactions` : Historique des transactions

## 🚀 Optimisations

1. **Sauvegarde intelligente** : Ne sauvegarde que si le joueur s'est déplacé
2. **Distance minimale** : Évite les sauvegardes inutiles
3. **Sauvegarde automatique** : Toutes les 5 minutes pour tous les joueurs
4. **Callbacks optimisés** : Communication client-serveur efficace
5. **Threads optimisés** : Utilisation de Wait() adaptatifs

## 🐛 Debug

Activez le mode debug dans `shared/config.lua` :
```lua
Config.Framework = {
    Debug = true
}
```

Les logs apparaîtront dans la console avec des couleurs :
- 🔵 INFO : Informations générales
- 🟡 WARN : Avertissements
- 🔴 ERROR : Erreurs

## 📝 Notes importantes

- Les positions sont sauvegardées automatiquement toutes les 30 secondes (configurable)
- Le joueur ne doit pas être en véhicule pour que la position soit sauvegardée
- La sauvegarde se fait uniquement si le joueur s'est déplacé d'au moins 10 mètres
- À la déconnexion, une dernière sauvegarde est effectuée automatiquement

## 🤝 Support

Pour toute question ou problème, consultez la documentation ou contactez le support.

## 📄 Licence

Ce framework est fourni tel quel. Vous êtes libre de le modifier selon vos besoins.

---

**Version** : 1.0.0  
**Auteur** : AMA Framework Team  
**Compatibilité** : FiveM Build 2545+

# 🔔 Configuration des Webhooks Discord

Ce guide explique comment configurer les logs Discord pour votre serveur FiveM avec AMA Framework.

## 📋 Fonctionnalités

Le système de logs Discord envoie automatiquement :

✅ **À la connexion** :
- Toutes les informations du joueur (nom, argent, job, grade)
- Position de spawn
- Identifiants (Steam, License, Discord, FiveM)
- Inventaire (optionnel)
- Heure et date de connexion
- Backup JSON complet des données

✅ **À la déconnexion** :
- Nom du joueur
- Heure et date de déconnexion
- Raison de la déconnexion
- Finances finales (optionnel)

✅ **Logs optionnels** :
- Transactions d'argent
- Changements de job
- Toutes modifications importantes

---

## 🚀 Installation

### Étape 1 : Créer les Webhooks Discord

1. Ouvrez Discord et allez sur votre serveur
2. Clic droit sur le salon où vous voulez les logs → **Modifier le salon**
3. Allez dans **Intégrations** → **Webhooks** → **Créer un webhook**
4. Donnez un nom au webhook (ex: "Connexions", "Déconnexions", etc.)
5. Copiez l'URL du webhook

**Recommandation** : Créez des salons séparés pour :
- 🟢 `#logs-connexions` - Connexions avec données complètes
- 🔴 `#logs-deconnexions` - Déconnexions simples
- 💾 `#backup-joueurs` - Sauvegardes complètes des données
- 💰 `#logs-transactions` - Transactions d'argent (optionnel)
- 💼 `#logs-jobs` - Changements de jobs (optionnel)

### Étape 2 : Configurer les Webhooks

Ouvrez le fichier `shared/discord_config.lua` et remplacez les URLs :

```lua
Config.Discord = {
    Enabled = true,  -- Mettre à false pour désactiver
    
    Webhooks = {
        -- Remplacez ces URLs par vos webhooks Discord
        Connection = "https://discord.com/api/webhooks/123456789/abcdefghijklmnop",
        Disconnection = "https://discord.com/api/webhooks/123456789/abcdefghijklmnop",
        PlayerData = "https://discord.com/api/webhooks/123456789/abcdefghijklmnop",
        Transactions = "https://discord.com/api/webhooks/123456789/abcdefghijklmnop",  -- Optionnel
        JobChanges = "https://discord.com/api/webhooks/123456789/abcdefghijklmnop"     -- Optionnel
    }
}
```

### Étape 3 : Personnaliser les paramètres

```lua
-- Paramètres des logs
Config.Discord.Settings = {
    SendFullDataOnConnect = true,      -- Envoyer toutes les données à la connexion
    SendOnlyTimeOnDisconnect = true,   -- Juste l'heure à la déconnexion
    IncludePosition = true,             -- Inclure la position
    IncludeInventory = false,           -- Inclure l'inventaire (peut être long)
    IncludeIdentifiers = true,          -- Inclure les identifiants
    DateFormat = "%d/%m/%Y %H:%M:%S",   -- Format de la date
}
```

---

## 🎨 Personnalisation

### Changer les couleurs des embeds

```lua
Config.Discord.Colors = {
    Connection = 3066993,      -- Vert
    Disconnection = 15158332,  -- Rouge
    PlayerData = 3447003,      -- Bleu
    Transaction = 15844367,    -- Or
    JobChange = 10181046       -- Violet
}
```

**Couleurs Discord** (décimal) :
- Rouge : `15158332` (#E74C3C)
- Vert : `3066993` (#2ECC71)
- Bleu : `3447003` (#3498DB)
- Orange : `15105570` (#E67E22)
- Jaune : `15844367` (#F1C40F)
- Violet : `10181046` (#9B59B6)

### Changer le nom et l'avatar du bot

```lua
Config.Discord.BotName = "Mon Serveur RP",
Config.Discord.BotAvatar = "https://lien-vers-votre-image.png"
```

---

## 📊 Exemples de logs

### Log de connexion (complet)

![Connexion](https://i.imgur.com/example1.png)

```
✅ Connexion au serveur
John Doe s'est connecté(e) au serveur

👤 Joueur: John Doe (ID: 1)
🕐 Heure: 08/12/2025 14:30:25
💰 Finances: 
  Liquide: $5,000
  Banque: $10,000
  Total: $15,000
💼 Emploi: police (Grade: 2)
🎖️ Groupe: user
📍 Position: X: -1037.72, Y: -2738.93, Z: 20.17
🔑 Identifiants:
  Steam: steam:110000xxxxxxxx
  License: license:xxxxxxxxxxxxxxxx
  Discord: @JohnDoe#1234
```

### Log de déconnexion (simple)

```
❌ Déconnexion du serveur
John Doe s'est déconnecté(e) du serveur

👤 Joueur: John Doe (ID: 1)
🕐 Heure: 08/12/2025 16:45:12
ℹ️ Raison: Timeout
```

### Backup JSON des données

```json
💾 Sauvegarde des données joueur
Backup complet de John Doe

📊 Données JSON:
{
  "identifier": "license:xxxxxxxxxx",
  "firstname": "John",
  "lastname": "Doe",
  "money": 5000,
  "bank": 10000,
  "job": "police",
  "job_grade": 2,
  "group": "user",
  "position": {"x": -1037.72, "y": -2738.93, "z": 20.17},
  "timestamp": 1702048825,
  "date": "08/12/2025 14:30:25"
}
```

---

## 🔧 Utilisation avancée

### Envoyer un log personnalisé

```lua
-- Serveur
local embed = {
    title = "🎉 Événement personnalisé",
    description = "Description de l'événement",
    color = 3066993,
    fields = {
        {
            name = "Champ 1",
            value = "Valeur 1",
            inline = true
        }
    }
}

AMA.Discord.SendWebhook(Config.Discord.Webhooks.Connection, embed)
```

### Utiliser depuis une autre ressource

```lua
-- Depuis une autre ressource
exports['ama_framework']:SendDiscordLog(webhookURL, embedData)
```

---

## ⚙️ Options avancées

### Rate Limiting

Pour éviter le spam, un délai minimum est appliqué entre les webhooks :

```lua
Config.Discord.RateLimit = {
    Delay = 1000,      -- 1 seconde entre chaque webhook
    MaxRetries = 3     -- Nombre de tentatives en cas d'échec
}
```

### Désactiver certains logs

Pour désactiver un type de log, mettez l'URL du webhook vide :

```lua
Config.Discord.Webhooks = {
    Connection = "https://...",
    Disconnection = "https://...",
    PlayerData = "https://...",
    Transactions = "",     -- ❌ Désactivé
    JobChanges = ""        -- ❌ Désactivé
}
```

Ou réglez les paramètres :

```lua
Config.Discord.Settings = {
    SendFullDataOnConnect = false,    -- Ne pas envoyer les données complètes
    IncludeInventory = false,         -- Ne pas inclure l'inventaire
}
```

---

## 🐛 Dépannage

### Les webhooks ne s'envoient pas

1. **Vérifiez les URLs** : Assurez-vous que les URLs sont correctes
2. **Vérifiez les permissions** : Le webhook doit avoir les permissions d'écriture
3. **Vérifiez les logs** : Regardez la console serveur pour les erreurs
4. **Activez le debug** :
   ```lua
   Config.Framework.Debug = true
   ```

### Les embeds sont tronqués

Discord limite :
- **Titre** : 256 caractères
- **Description** : 4096 caractères
- **Champ** : 1024 caractères
- **Total embed** : 6000 caractères

Solution : Désactivez `IncludeInventory` si vos inventaires sont lourds.

### Erreur "429 Too Many Requests"

Vous envoyez trop de webhooks trop rapidement. Augmentez le délai :

```lua
Config.Discord.RateLimit.Delay = 2000  -- 2 secondes
```

---

## 📱 Notification mobile

Pour recevoir les notifications sur mobile :

1. Installez l'app Discord
2. Activez les notifications pour le serveur
3. Abonnez-vous aux salons de logs
4. Configurez les mentions : `@everyone` ou `@here` (à utiliser avec modération)

---

## 🔐 Sécurité

⚠️ **IMPORTANT** :

- **NE PARTAGEZ JAMAIS** vos URLs de webhook publiquement
- Mettez vos URLs dans un fichier `.env` ou `config.lua` privé
- Les webhooks donnent accès direct à vos salons Discord
- Si compromis, **supprimez et recréez** le webhook immédiatement

---

## 📞 Support

Si vous avez des questions ou des problèmes :

1. Vérifiez ce guide
2. Consultez les logs serveur
3. Activez le mode debug
4. Demandez de l'aide sur le Discord du serveur

---

**Configuration terminée ! Vos logs Discord sont maintenant actifs ! 🎉**

# 🔧 Guide pour Moddeurs - AMA Framework

Ce guide explique comment étendre le framework AMA sans modifier les fichiers core.

## 📋 Table des matières

1. [Système de sérialisation](#système-de-sérialisation)
2. [Créer un module personnalisé](#créer-un-module-personnalisé)
3. [Utiliser les hooks](#utiliser-les-hooks)
4. [Métadonnées personnalisées](#métadonnées-personnalisées)
5. [Exports pour autres ressources](#exports-pour-autres-ressources)
6. [Fonctions utilitaires](#fonctions-utilitaires)

---

## 🎯 Système de sérialisation

Le fichier `shared/serialization.lua` contient tout le système de modding. Il doit être chargé dans le `fxmanifest.lua`:

```lua
shared_scripts {
    'shared/config.lua',
    'shared/functions.lua',
    'shared/serialization.lua'  -- ← Ajouter cette ligne
}
```

### Configuration

Dans `shared/config.lua`, ajoutez:

```lua
Config.Serialization = {
    SyncMetaToClient = true,      -- Synchroniser les métadonnées avec le client
    EnableModules = true,          -- Activer le système de modules
    EnableHooks = true,            -- Activer le système de hooks
    ModulesFolder = "modules/",    -- Dossier des modules personnalisés
    Debug = false                  -- Mode debug
}
```

---

## 📦 Créer un module personnalisé

### Structure de base

Créez un fichier dans `ama_framework/modules/mon_module.lua`:

```lua
local MonModule = {
    name = "Mon Module",
    version = "1.0.0",
    author = "Votre Nom"
}

-- Fonction d'initialisation (optionnelle mais recommandée)
function MonModule.Init()
    print("Mon module est chargé!")
    
    if IsDuplicityVersion() then
        -- Code serveur uniquement
        MonModule.InitServer()
    else
        -- Code client uniquement
        MonModule.InitClient()
    end
end

function MonModule.InitServer()
    -- Initialisation serveur
end

function MonModule.InitClient()
    -- Initialisation client
end

-- Vos fonctions personnalisées
function MonModule.MaFonction(param)
    return "Résultat: " .. param
end

-- Enregistrer le module
AMA.RegisterModule("mon_module", MonModule)
```

### Charger le module

Dans `fxmanifest.lua`, ajoutez:

```lua
shared_scripts {
    'shared/config.lua',
    'shared/functions.lua',
    'shared/serialization.lua',
    'modules/mon_module.lua'  -- ← Votre module
}
```

### Utiliser le module

```lua
-- Récupérer le module
local monModule = AMA.GetModule("mon_module")

-- Utiliser ses fonctions
local result = monModule.MaFonction("test")
```

---

## 🪝 Utiliser les hooks

Les hooks permettent d'exécuter du code à des moments précis sans modifier le core.

### Hooks disponibles

#### CLIENT
```lua
-- Quand le joueur est chargé
AMA.RegisterHook("ama:hook:playerLoaded", function(playerData)
    print("Joueur chargé: " .. playerData.firstname)
end)

-- Quand le joueur spawn
AMA.RegisterHook("ama:hook:playerSpawned", function(coords, heading)
    print("Spawn à: " .. coords.x .. ", " .. coords.y)
end)

-- Quand le joueur meurt
AMA.RegisterHook("ama:hook:playerDied", function(deathCoords)
    print("Mort à: " .. deathCoords.x)
end)

-- Avant de sauvegarder la position
AMA.RegisterHook("ama:hook:positionSaving", function(coords)
    -- Retourner false pour annuler la sauvegarde
    return true
end)

-- Quand l'argent change
AMA.RegisterHook("ama:hook:moneyUpdated", function(newMoney)
    print("Nouvel argent: " .. newMoney)
end)

-- Quand le job change
AMA.RegisterHook("ama:hook:jobUpdated", function(job, grade)
    print("Nouveau job: " .. job .. " grade " .. grade)
end)
```

#### SERVEUR
```lua
-- Quand un joueur se connecte
AMA.RegisterHook("ama:hook:playerConnected", function(source, identifier)
    print("Connexion: " .. identifier)
end)

-- Quand un joueur se déconnecte
AMA.RegisterHook("ama:hook:playerDisconnected", function(source, xPlayer)
    print("Déconnexion: " .. xPlayer.name)
end)

-- Quand les données sont chargées
AMA.RegisterHook("ama:hook:playerDataLoaded", function(source, xPlayer)
    print("Données chargées: " .. xPlayer.name)
end)

-- Avant la sauvegarde
AMA.RegisterHook("ama:hook:beforeSave", function(source, xPlayer)
    print("Sauvegarde de: " .. xPlayer.name)
    return true -- false pour annuler
end)

-- Après la sauvegarde
AMA.RegisterHook("ama:hook:afterSave", function(source, xPlayer)
    print("Sauvegarde terminée: " .. xPlayer.name)
end)

-- Quand l'argent change
AMA.RegisterHook("ama:hook:moneyChanged", function(source, type, amount, reason)
    print(type .. ": " .. amount .. " - " .. (reason or "Aucune raison"))
end)
```

### Priorité des hooks

Les hooks ont une priorité (plus petit = exécuté en premier):

```lua
-- Priorité 10 (exécuté en premier)
AMA.RegisterHook("ama:hook:playerLoaded", function(playerData)
    print("Hook prioritaire")
end, 10)

-- Priorité 50 (par défaut)
AMA.RegisterHook("ama:hook:playerLoaded", function(playerData)
    print("Hook normal")
end)

-- Priorité 100 (exécuté en dernier)
AMA.RegisterHook("ama:hook:playerLoaded", function(playerData)
    print("Hook de fin")
end, 100)
```

### Déclencher un hook personnalisé

```lua
-- Déclencher
local result = AMA.TriggerHook("mon:hook:custom", arg1, arg2)

-- Enregistrer
AMA.RegisterHook("mon:hook:custom", function(arg1, arg2)
    print(arg1, arg2)
    return "valeur de retour"
end)
```

---

## 🏷️ Métadonnées personnalisées

Les métadonnées permettent de stocker des données temporaires sur les joueurs.

### Serveur

```lua
-- Définir une métadonnée
AMA.SetPlayerMeta(source, "premium", true)
AMA.SetPlayerMeta(source, "vip_level", 3)
AMA.SetPlayerMeta(source, "last_action", "kill")

-- Obtenir une métadonnée
local isPremium = AMA.GetPlayerMeta(source, "premium")
if isPremium then
    print("Joueur premium!")
end

-- Obtenir toutes les métadonnées
local allMeta = AMA.GetAllPlayerMeta(source)
for key, value in pairs(allMeta) do
    print(key .. " = " .. tostring(value))
end
```

### Client

Les métadonnées sont automatiquement synchronisées si `Config.Serialization.SyncMetaToClient = true`:

```lua
RegisterNetEvent('ama:updateMeta')
AddEventHandler('ama:updateMeta', function(key, value)
    print("Meta reçue: " .. key .. " = " .. tostring(value))
    
    if key == "premium" and value then
        -- Afficher une UI premium par exemple
    end
end)
```

---

## 📤 Exports pour autres ressources

### Exporter des fonctions

```lua
-- Dans votre module
AMA.Export("MonModule_Fonction", function(param)
    return "Résultat: " .. param
end)

-- Utiliser depuis une autre ressource
local result = exports['ama_framework']:MonModule_Fonction("test")
```

### Accéder au framework depuis une autre ressource

```lua
-- Obtenir un joueur
local xPlayer = exports['ama_framework']:GetPlayer(source)
print(xPlayer.name, xPlayer.money)

-- Obtenir tous les joueurs
local players = exports['ama_framework']:GetPlayers()
for _, xPlayer in ipairs(players) do
    print(xPlayer.name)
end

-- Enregistrer un module depuis une autre ressource
exports['ama_framework']:RegisterModule("module_externe", MonModule)
```

---

## 🛠️ Fonctions utilitaires

### Sérialisation JSON

```lua
-- Encoder
local jsonString = AMA.Encode({name = "Test", value = 123})

-- Décoder
local data = AMA.Decode(jsonString)
print(data.name, data.value)
```

### Distance et coordonnées

```lua
-- Distance entre deux points
local dist = AMA.GetDistanceBetweenCoords(
    vector3(0, 0, 0),
    vector3(100, 100, 0)
)

-- Joueurs dans un rayon
local nearbyPlayers = AMA.GetPlayersInArea(
    vector3(0, 0, 0),
    50.0  -- 50 mètres
)

for _, playerId in ipairs(nearbyPlayers) do
    print("Joueur proche: " .. playerId)
end
```

### Tables

```lua
-- Copie profonde
local original = {a = 1, b = {c = 2}}
local copy = AMA.DeepCopy(original)

-- Fusionner
local t1 = {a = 1, b = 2}
local t2 = {b = 3, c = 4}
local merged = AMA.MergeTables(t1, t2)
-- Résultat: {a = 1, b = 3, c = 4}
```

### UUID et utilitaires

```lua
-- Générer un UUID
local id = AMA.GenerateUUID()
print(id) -- "550e8400-e29b-41d4-a716-446655440000"

-- Vérifier si un joueur est en ligne (serveur)
if AMA.IsPlayerOnline(source) then
    print("Joueur en ligne")
end
```

---

## 📚 Exemple complet: Système de level

Voir le fichier `modules/exemple_level.lua` pour un exemple complet avec:

- ✅ Système de niveau et XP
- ✅ Récompenses automatiques
- ✅ Hooks pour donner de l'XP
- ✅ Sauvegarde dans la base de données
- ✅ Interface utilisateur
- ✅ Commandes admin
- ✅ Exports pour autres ressources

### Utilisation

```lua
-- Ajouter de l'XP
local levelModule = AMA.GetModule("level_system")
levelModule.AddXP(source, 100, "Kill")

-- Obtenir le niveau
local level, xp = levelModule.GetPlayerLevel(source)

-- Depuis une autre ressource
exports['ama_framework']:AddXP(source, 100, "Quest complete")
```

---

## 🎨 Intégration dans le manifest

Votre `fxmanifest.lua` final devrait ressembler à:

```lua
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
    'shared/config.lua',
    'shared/functions.lua',
    'shared/serialization.lua',  -- ← Système de modding
    'modules/*.lua'               -- ← Tous vos modules
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/player.lua',
    'server/commands.lua'
}

client_scripts {
    'client/main.lua',
    'client/spawn.lua',
    'client/events.lua'
}
```

---

## ⚠️ Bonnes pratiques

1. **Ne modifiez JAMAIS les fichiers core** (`server/`, `client/`, `shared/functions.lua`)
2. **Utilisez toujours les hooks** plutôt que de modifier le code
3. **Préfixez vos hooks personnalisés** (ex: `mon_module:hook:action`)
4. **Testez en mode debug** (`Config.Serialization.Debug = true`)
5. **Documentez vos modules** avec des commentaires
6. **Utilisez les métadonnées** pour les données temporaires
7. **Sauvegardez les données importantes** dans la base de données

---

## 🐛 Debugging

Activez le debug pour voir les logs:

```lua
Config.Serialization.Debug = true
```

Logs disponibles:
- `DEBUG` : Informations détaillées
- `INFO` : Informations générales
- `WARN` : Avertissements
- `ERROR` : Erreurs

---

## 💡 Ressources supplémentaires

- [Documentation FiveM Lua](https://docs.fivem.net/docs/scripting-reference/runtimes/lua/)
- [Natives GTA V](https://docs.fivem.net/natives/)
- [Community Discord](https://discord.gg/fivem)

---

**Bon modding! 🚀**