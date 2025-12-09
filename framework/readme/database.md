# 🗄️ Documentation Base de Données - AMA Framework

## 📋 Vue d'ensemble

Le framework AMA utilise 8 tables principales pour gérer les joueurs, métiers, crews et transactions.

---

## 📊 Structure des tables

### 1. `ama_players` - Joueurs

Table principale contenant toutes les données des joueurs.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | INT(11) | ID auto-incrémenté |
| `identifier` | VARCHAR(60) | Identifiant unique (Steam/License) ⭐ |
| `uuid` | VARCHAR(36) | UUID unique du joueur ⭐ |
| `wallet_uuid` | VARCHAR(36) | UUID unique du wallet AMACoin ⭐ |
| `firstname` | VARCHAR(50) | Prénom |
| `lastname` | VARCHAR(50) | Nom |
| `money` | INT(11) | Argent liquide |
| `bank` | INT(11) | Argent en banque |
| `bitcoin` | DECIMAL(15,8) | Solde AMACoin |
| `job` | VARCHAR(50) | Métier actuel |
| `job_grade` | INT(11) | Grade du métier |
| `crew` | VARCHAR(50) | Crew/Organisation |
| `crew_grade` | INT(11) | Grade dans le crew |
| `group` | VARCHAR(50) | Groupe (user, admin) |
| `position` | TEXT | Dernière position (JSON) |
| `inventory` | LONGTEXT | Inventaire (JSON) |
| `accounts` | LONGTEXT | Comptes supplémentaires (JSON) |
| `skin` | LONGTEXT | Apparence (JSON) |
| `last_seen` | TIMESTAMP | Dernière connexion |
| `created_at` | TIMESTAMP | Date de création |

**Index :**
- PRIMARY KEY: `id`
- UNIQUE: `identifier`, `uuid`, `wallet_uuid`
- INDEX: `job`, `crew`, `group`, `last_seen`

---

### 2. `ama_jobs` - Métiers

Liste des métiers disponibles sur le serveur.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | INT(11) | ID auto-incrémenté |
| `name` | VARCHAR(50) | Nom unique du métier ⭐ |
| `label` | VARCHAR(100) | Nom affiché |
| `whitelisted` | TINYINT(1) | Métier whitelist (0=non, 1=oui) |

**Métiers par défaut :**
- unemployed (Sans emploi)
- police (Police) - Whitelist
- ambulance (Ambulance) - Whitelist
- mechanic (Mécanicien)
- taxi (Taxi)
- realestateagent (Agent Immobilier)
- cardealer (Concessionnaire) - Whitelist
- banker (Banquier) - Whitelist

---

### 3. `ama_job_grades` - Grades des métiers

Grades et salaires pour chaque métier.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | INT(11) | ID auto-incrémenté |
| `job_name` | VARCHAR(50) | Nom du métier (FK) |
| `grade` | INT(11) | Niveau du grade (0-4) |
| `name` | VARCHAR(50) | Nom du grade |
| `label` | VARCHAR(100) | Label affiché |
| `salary` | INT(11) | Salaire |
| `skin_male` | LONGTEXT | Tenue homme (JSON) |
| `skin_female` | LONGTEXT | Tenue femme (JSON) |

**Exemple (Police) :**
- Grade 0: Recrue ($500)
- Grade 1: Officier ($750)
- Grade 2: Sergent ($1000)
- Grade 3: Lieutenant ($1250)
- Grade 4: Commandant ($1500)

---

### 4. `ama_crews` - Organisations illégales

Crews et organisations pour le côté illégal.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | INT(11) | ID auto-incrémenté |
| `name` | VARCHAR(50) | Nom unique du crew ⭐ |
| `label` | VARCHAR(100) | Nom affiché |
| `color` | VARCHAR(7) | Couleur HEX |
| `bank` | INT(11) | Coffre du crew |
| `created_at` | TIMESTAMP | Date de création |

**Crews par défaut :**
- none (Aucun Crew)
- mafia (La Mafia) - Rouge
- cartel (Le Cartel) - Orange
- yakuza (Yakuza) - Violet
- gang_street (Gang des Rues) - Vert
- bikers (Club de Motards) - Gris foncé
- triad (Les Triades) - Rose
- bratva (Bratva) - Rouge foncé

---

### 5. `ama_bitcoin_transactions` - Transactions AMACoin

Historique des transactions crypto-monnaie.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | INT(11) | ID auto-incrémenté |
| `sender_uuid` | VARCHAR(36) | UUID wallet expéditeur |
| `receiver_uuid` | VARCHAR(36) | UUID wallet destinataire |
| `amount` | DECIMAL(15,8) | Montant de la transaction |
| `type` | VARCHAR(20) | Type (send, receive, convert) |
| `reason` | VARCHAR(255) | Raison |
| `created_at` | TIMESTAMP | Date |

---

### 6. `ama_vehicles` - Véhicules

Véhicules des joueurs.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | INT(11) | ID auto-incrémenté |
| `owner` | VARCHAR(60) | Identifiant propriétaire |
| `plate` | VARCHAR(12) | Plaque unique ⭐ |
| `vehicle` | VARCHAR(50) | Modèle |
| `hash` | VARCHAR(50) | Hash du modèle |
| `stored` | TINYINT(1) | En garage (1) ou sorti (0) |
| `garage` | VARCHAR(50) | Garage actuel |
| `state` | INT(11) | État (0-1000) |
| `fuel` | INT(11) | Essence (0-100) |
| `engine` | FLOAT | État moteur |
| `body` | FLOAT | État carrosserie |
| `mods` | LONGTEXT | Modifications (JSON) |
| `created_at` | TIMESTAMP | Date d'achat |

---

### 7. `ama_transactions` - Transactions financières

Historique de toutes les transactions d'argent.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | INT(11) | ID auto-incrémenté |
| `identifier` | VARCHAR(60) | Identifiant joueur |
| `type` | VARCHAR(20) | Type (add, remove) |
| `account` | VARCHAR(20) | Compte (money, bank, bitcoin) |
| `amount` | DECIMAL(15,2) | Montant |
| `reason` | VARCHAR(255) | Raison |
| `balance_after` | DECIMAL(15,2) | Solde après transaction |
| `created_at` | TIMESTAMP | Date |

---

### 8. `ama_crew_logs` - Logs des crews

Logs des actions dans les crews.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | INT(11) | ID auto-incrémenté |
| `crew_name` | VARCHAR(50) | Nom du crew |
| `player_identifier` | VARCHAR(60) | Identifiant joueur |
| `action` | VARCHAR(50) | Action effectuée |
| `details` | TEXT | Détails |
| `created_at` | TIMESTAMP | Date |

---

## 🔍 Vues (Views)

Le framework inclut 3 vues pour faciliter les statistiques :

### `v_players_stats`
Statistiques générales des joueurs actifs (dernières 24h).

### `v_richest_players`
Top 10 des joueurs les plus riches.

### `v_crew_stats`
Statistiques des crews (membres, coffre).

**Exemple d'utilisation :**
```sql
SELECT * FROM v_richest_players;
SELECT * FROM v_crew_stats WHERE member_count > 0;
```

---

## ⚡ Triggers

### `log_player_money_change`
Enregistre automatiquement dans `ama_transactions` quand l'argent d'un joueur change.

---

## 🧹 Maintenance

### Procédure de nettoyage

```sql
-- Nettoyer les transactions de plus de 90 jours
CALL cleanup_old_transactions();
```

### Optimisation manuelle

```sql
OPTIMIZE TABLE ama_players;
OPTIMIZE TABLE ama_transactions;
OPTIMIZE TABLE ama_bitcoin_transactions;
```

### Sauvegarde

```bash
# Sauvegarder toute la base
mysqldump -u user -p database_name > backup.sql

# Sauvegarder uniquement les tables AMA
mysqldump -u user -p database_name ama_players ama_jobs ama_job_grades ama_crews ama_vehicles ama_transactions ama_bitcoin_transactions ama_crew_logs > backup_ama.sql
```

---

## 📊 Requêtes utiles

### Statistiques générales

```sql
-- Nombre total de joueurs
SELECT COUNT(*) FROM ama_players;

-- Argent total en circulation
SELECT 
    SUM(money) as total_cash,
    SUM(bank) as total_bank,
    SUM(money + bank) as total_money
FROM ama_players;

-- Joueurs par métier
SELECT job, COUNT(*) as count 
FROM ama_players 
GROUP BY job 
ORDER BY count DESC;

-- Joueurs par crew
SELECT crew, COUNT(*) as count 
FROM ama_players 
WHERE crew != 'none'
GROUP BY crew 
ORDER BY count DESC;
```

### Recherche de joueurs

```sql
-- Trouver un joueur par nom
SELECT * FROM ama_players 
WHERE firstname LIKE '%John%' OR lastname LIKE '%Doe%';

-- Trouver un joueur par UUID
SELECT * FROM ama_players WHERE uuid = 'uuid-here';

-- Trouver un joueur par wallet
SELECT * FROM ama_players WHERE wallet_uuid = 'wallet-uuid-here';
```

### Transactions

```sql
-- Dernières transactions
SELECT * FROM ama_transactions 
ORDER BY created_at DESC 
LIMIT 50;

-- Transactions d'un joueur
SELECT * FROM ama_transactions 
WHERE identifier = 'license:xxxxxx' 
ORDER BY created_at DESC;

-- Total des transactions par jour
SELECT 
    DATE(created_at) as date,
    COUNT(*) as total_transactions,
    SUM(amount) as total_amount
FROM ama_transactions
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### AMACoin

```sql
-- Top détenteurs de AMACoin
SELECT 
    CONCAT(firstname, ' ', lastname) as name,
    bitcoin,
    (bitcoin * 100) as value_usd
FROM ama_players
WHERE bitcoin > 0
ORDER BY bitcoin DESC
LIMIT 10;

-- Transactions AMACoin aujourd'hui
SELECT * FROM ama_bitcoin_transactions
WHERE DATE(created_at) = CURDATE()
ORDER BY created_at DESC;
```

---

## 🔒 Sécurité

### Permissions recommandées

```sql
-- Créer un utilisateur dédié
CREATE USER 'ama_user'@'localhost' IDENTIFIED BY 'password_secure';

-- Donner uniquement les permissions nécessaires
GRANT SELECT, INSERT, UPDATE, DELETE ON database.ama_* TO 'ama_user'@'localhost';

-- NE PAS donner DROP, CREATE, ALTER
FLUSH PRIVILEGES;
```

### Backup automatique

Configurez un cron pour sauvegarder quotidiennement :

```bash
# Crontab: Backup tous les jours à 3h du matin
0 3 * * * mysqldump -u user -p'password' database > /backups/ama_$(date +\%Y\%m\%d).sql
```

---

## ⚠️ Notes importantes

1. **UUID et wallet_uuid sont UNIQUES** - Ne jamais dupliquer
2. **Les transactions sont archivées** - Nettoyage automatique après 90 jours
3. **Les triggers log automatiquement** - Vérifiez `ama_transactions`
4. **DECIMAL pour bitcoin** - Supporte jusqu'à 8 décimales
5. **JSON pour inventory/position** - Utiliser json_encode/json_decode

---

## 🆘 Problèmes courants

### "Duplicate entry for key 'identifier'"
Un joueur avec cet identifier existe déjà. Vérifiez avec :
```sql
SELECT * FROM ama_players WHERE identifier = 'license:xxxxx';
```

### "Foreign key constraint fails"
Assurez-vous que le job existe dans `ama_jobs` avant de l'assigner.

### Transactions manquantes
Vérifiez que les triggers sont actifs :
```sql
SHOW TRIGGERS LIKE 'ama_players';
```

---

**📚 Pour plus d'informations, consultez [INSTALLATION.md](INSTALLATION.md)**
