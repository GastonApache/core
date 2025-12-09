# 🗄️ Base de Données - Framework AMA

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Structure des tables](#structure-des-tables)
3. [Relations](#relations)
4. [Requêtes utiles](#requêtes-utiles)
5. [Maintenance](#maintenance)
6. [Optimisation](#optimisation)
7. [Sauvegarde et restauration](#sauvegarde-et-restauration)

---

## Vue d'ensemble

Le framework AMA utilise **8 tables principales** pour gérer toutes les données du serveur.

### Liste des tables

| Table | Description | Lignes typiques |
|-------|-------------|-----------------|
| `ama_players` | Données des joueurs | 100-10000 |
| `ama_jobs` | Métiers disponibles | 10-50 |
| `ama_job_grades` | Grades des métiers | 50-200 |
| `ama_crews` | Organisations/Crews | 5-20 |
| `ama_vehicles` | Véhicules des joueurs | 500-50000 |
| `ama_transactions` | Historique financier | 10000+ |
| `ama_bitcoin_transactions` | Historique AMACoin | 1000+ |
| `ama_crew_logs` | Logs des crews | 5000+ |

### Taille estimée

Pour 1000 joueurs actifs :
- Base de données : ~500 MB
- Croissance : ~50 MB/mois

---

## Structure des tables

### 1. `ama_players`

Table principale contenant toutes les informations des joueurs.

```sql
CREATE TABLE `ama_players` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `uuid` VARCHAR(36) NOT NULL,
    `wallet_uuid` VARCHAR(36) NOT NULL,
    `firstname` VARCHAR(50) DEFAULT 'John',
    `lastname` VARCHAR(50) DEFAULT 'Doe',
    `money` INT(11) DEFAULT 5000,
    `bank` INT(11) DEFAULT 0,
    `bitcoin` DECIMAL(15,8) DEFAULT 0.00000000,
    `job` VARCHAR(50) DEFAULT 'unemployed',
    `job_grade` INT(11) DEFAULT 0,
    `crew` VARCHAR(50) DEFAULT 'none',
    `crew_grade` INT(11) DEFAULT 0,
    `group` VARCHAR(50) DEFAULT 'user',
    `position` TEXT,
    `inventory` LONGTEXT,
    `accounts` LONGTEXT,
    `skin` LONGTEXT,
    `last_seen` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`),
    UNIQUE KEY `uuid` (`uuid`),
    UNIQUE KEY `wallet_uuid` (`wallet_uuid`),
    KEY `idx_job` (`job`),
    KEY `idx_crew` (`crew`),
    KEY `idx_group` (`group`),
    KEY `idx_last_seen` (`last_seen`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Colonnes importantes** :

- `identifier` : Identifiant unique Steam/License (ex: "license:abc123")
- `uuid` : UUID universel unique (ex: "550e8400-e29b-41d4-a716-446655440000")
- `wallet_uuid` : UUID unique pour le wallet AMACoin
- `money` : Argent liquide
- `bank` : Compte bancaire
- `bitcoin` : Solde AMACoin (8 décimales de précision)
- `position` : JSON avec {x, y, z, heading}
- `inventory` : JSON de l'inventaire
- `last_seen` : Mise à jour automatique à chaque action

---

### 2. `ama_jobs`

Liste des métiers disponibles.

```sql
CREATE TABLE `ama_jobs` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `whitelisted` TINYINT(1) DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Jobs par défaut** :

| name | label | whitelisted |
|------|-------|-------------|
| unemployed | Sans emploi | 0 |
| police | Police | 1 |
| ambulance | Ambulance | 1 |
| mechanic | Mécanicien | 0 |
| taxi | Taxi | 0 |
| realestateagent | Agent Immobilier | 0 |
| cardealer | Concessionnaire | 1 |
| banker | Banquier | 1 |

---

### 3. `ama_job_grades`

Grades et salaires pour chaque métier.

```sql
CREATE TABLE `ama_job_grades` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `job_name` VARCHAR(50) NOT NULL,
    `grade` INT(11) NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `salary` INT(11) DEFAULT 500,
    `skin_male` LONGTEXT,
    `skin_female` LONGTEXT,
    PRIMARY KEY (`id`),
    KEY `job_name` (`job_name`),
    KEY `grade` (`grade`),
    FOREIGN KEY (`job_name`) REFERENCES `ama_jobs`(`name`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Exemple (Police)** :

| grade | name | label | salary |
|-------|------|-------|--------|
| 0 | recrue | Recrue | 500 |
| 1 | officier | Officier | 750 |
| 2 | sergent | Sergent | 1000 |
| 3 | lieutenant | Lieutenant | 1250 |
| 4 | commandant | Commandant | 1500 |

---

### 4. `ama_crews`

Organisations et crews illégaux.

```sql
CREATE TABLE `ama_crews` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `color` VARCHAR(7) DEFAULT '#FFFFFF',
    `bank` INT(11) DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Crews par défaut** :

| name | label | color | bank |
|------|-------|-------|------|
| none | Aucun Crew | #FFFFFF | 0 |
| mafia | La Mafia | #FF0000 | 50000 |
| cartel | Le Cartel | #FF8C00 | 45000 |
| yakuza | Yakuza | #9B59B6 | 60000 |
| gang_street | Gang des Rues | #2ECC71 | 30000 |
| bikers | Club de Motards | #34495E | 40000 |
| triad | Les Triades | #E91E63 | 55000 |
| bratva | Bratva | #8B0000 | 65000 |

---

### 5. `ama_vehicles`

Véhicules des joueurs.

```sql
CREATE TABLE `ama_vehicles` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `owner` VARCHAR(60) NOT NULL,
    `plate` VARCHAR(12) NOT NULL,
    `vehicle` VARCHAR(50) NOT NULL,
    `hash` VARCHAR(50) NOT NULL,
    `stored` TINYINT(1) DEFAULT 1,
    `garage` VARCHAR(50) DEFAULT 'pillboxhill',
    `state` INT(11) DEFAULT 1000,
    `fuel` INT(11) DEFAULT 100,
    `engine` FLOAT DEFAULT 1000,
    `body` FLOAT DEFAULT 1000,
    `mods` LONGTEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `plate` (`plate`),
    KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Colonnes** :

- `owner` : Identifier du propriétaire
- `plate` : Plaque d'immatriculation (unique)
- `vehicle` : Nom du modèle (ex: "adder")
- `hash` : Hash du modèle
- `stored` : 1 = en garage, 0 = sorti
- `state` : État général (0-1000)
- `mods` : JSON des modifications

---

### 6. `ama_transactions`

Historique de toutes les transactions financières.

```sql
CREATE TABLE `ama_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `type` VARCHAR(20) NOT NULL,
    `account` VARCHAR(20) NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    `reason` VARCHAR(255),
    `balance_after` DECIMAL(15,2),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_identifier` (`identifier`),
    KEY `idx_type` (`type`),
    KEY `idx_account` (`account`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Types de transactions** :

- `add` : Ajout d'argent
- `remove` : Retrait d'argent

**Comptes** :

- `money` : Argent liquide
- `bank` : Compte bancaire
- `bitcoin` : AMACoin

---

### 7. `ama_bitcoin_transactions`

Historique des transactions AMACoin.

```sql
CREATE TABLE `ama_bitcoin_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `sender_uuid` VARCHAR(36),
    `receiver_uuid` VARCHAR(36),
    `amount` DECIMAL(15,8) NOT NULL,
    `type` VARCHAR(20) NOT NULL,
    `reason` VARCHAR(255),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_sender` (`sender_uuid`),
    KEY `idx_receiver` (`receiver_uuid`),
    KEY `idx_type` (`type`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Types** :

- `send` : Envoi à un autre joueur
- `receive` : Réception d'un autre joueur
- `convert` : Conversion vers/depuis argent

---

### 8. `ama_crew_logs`

Logs des actions dans les crews.

```sql
CREATE TABLE `ama_crew_logs` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `crew_name` VARCHAR(50) NOT NULL,
    `player_identifier` VARCHAR(60) NOT NULL,
    `action` VARCHAR(50) NOT NULL,
    `details` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_crew` (`crew_name`),
    KEY `idx_player` (`player_identifier`),
    KEY `idx_action` (`action`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Actions** :

- `join` : Rejoindre un crew
- `leave` : Quitter un crew
- `promote` : Promotion
- `demote` : Rétrogradation
- `kick` : Exclusion
- `deposit` : Dépôt au coffre
- `withdraw` : Retrait du coffre

---

## Relations

### Diagramme des relations

```
┌─────────────────┐
│   ama_players   │
├─────────────────┤
│ * identifier    │───┐
│ * uuid          │   │
│ * wallet_uuid   │   │    ┌─────────────────────┐
│   job ──────────┼───┼───►│     ama_jobs        │
│   crew          │   │    ├─────────────────────┤
└─────────────────┘   │    │ * name              │
         │            │    └─────────────────────┘
         │            │              │
         │            │              ▼
         │            │    ┌─────────────────────┐
         │            │    │  ama_job_grades     │
         │            │    ├─────────────────────┤
         │            │    │   job_name (FK)     │
         │            │    │   grade             │
         │            │    └─────────────────────┘
         │            │
         │            │    ┌─────────────────────┐
         │            └───►│  ama_transactions   │
         │                 ├─────────────────────┤
         │                 │   identifier (FK)   │
         │                 └─────────────────────┘
         │
         │                 ┌─────────────────────┐
         └────────────────►│   ama_vehicles      │
                           ├─────────────────────┤
                           │   owner (FK)        │
                           └─────────────────────┘

┌─────────────────┐         ┌─────────────────────────┐
│   ama_crews     │◄────────│  ama_crew_logs          │
├─────────────────┤         ├─────────────────────────┤
│ * name          │         │   crew_name (FK)        │
└─────────────────┘         │   player_identifier (FK)│
                            └─────────────────────────┘

┌─────────────────┐         ┌─────────────────────────────┐
│   ama_players   │◄────────│  ama_bitcoin_transactions   │
├─────────────────┤         ├─────────────────────────────┤
│ * wallet_uuid   │         │   sender_uuid (FK)          │
└─────────────────┘         │   receiver_uuid (FK)        │
                            └─────────────────────────────┘
```

### Foreign Keys

```sql
-- ama_job_grades -> ama_jobs
ALTER TABLE `ama_job_grades`
ADD CONSTRAINT `fk_job_name`
FOREIGN KEY (`job_name`)
REFERENCES `ama_jobs`(`name`)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- ama_vehicles -> ama_players
ALTER TABLE `ama_vehicles`
ADD CONSTRAINT `fk_vehicle_owner`
FOREIGN KEY (`owner`)
REFERENCES `ama_players`(`identifier`)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- ama_transactions -> ama_players
ALTER TABLE `ama_transactions`
ADD CONSTRAINT `fk_transaction_player`
FOREIGN KEY (`identifier`)
REFERENCES `ama_players`(`identifier`)
ON UPDATE CASCADE
ON DELETE CASCADE;
```

---

## Requêtes utiles

### Statistiques générales

```sql
-- Nombre total de joueurs
SELECT COUNT(*) as total_players FROM ama_players;

-- Joueurs actifs (dernières 24h)
SELECT COUNT(*) as active_players
FROM ama_players
WHERE last_seen > NOW() - INTERVAL 24 HOUR;

-- Argent total en circulation
SELECT
    SUM(money) as total_cash,
    SUM(bank) as total_bank,
    SUM(money + bank) as total_money,
    AVG(money + bank) as avg_per_player
FROM ama_players;

-- AMACoin en circulation
SELECT
    SUM(bitcoin) as total_bitcoin,
    SUM(bitcoin * 100) as total_value_usd
FROM ama_players;
```

### Joueurs

```sql
-- Top 10 joueurs les plus riches
SELECT
    firstname,
    lastname,
    money,
    bank,
    (money + bank) as total,
    job,
    crew
FROM ama_players
ORDER BY total DESC
LIMIT 10;

-- Rechercher un joueur par nom
SELECT *
FROM ama_players
WHERE firstname LIKE '%John%'
   OR lastname LIKE '%Doe%';

-- Joueurs par métier
SELECT
    job,
    COUNT(*) as count,
    AVG(money + bank) as avg_money
FROM ama_players
GROUP BY job
ORDER BY count DESC;

-- Joueurs par crew
SELECT
    c.label as crew_name,
    COUNT(p.id) as member_count,
    c.bank as crew_bank
FROM ama_players p
JOIN ama_crews c ON p.crew = c.name
WHERE p.crew != 'none'
GROUP BY p.crew, c.label, c.bank
ORDER BY member_count DESC;
```

### Transactions

```sql
-- Dernières transactions
SELECT
    p.firstname,
    p.lastname,
    t.type,
    t.account,
    t.amount,
    t.reason,
    t.created_at
FROM ama_transactions t
JOIN ama_players p ON t.identifier = p.identifier
ORDER BY t.created_at DESC
LIMIT 50;

-- Transactions d'un joueur
SELECT *
FROM ama_transactions
WHERE identifier = 'license:abc123'
ORDER BY created_at DESC;

-- Total des transactions par jour
SELECT
    DATE(created_at) as date,
    COUNT(*) as total_transactions,
    SUM(CASE WHEN type = 'add' THEN amount ELSE 0 END) as total_added,
    SUM(CASE WHEN type = 'remove' THEN amount ELSE 0 END) as total_removed
FROM ama_transactions
GROUP BY DATE(created_at)
ORDER BY date DESC
LIMIT 30;

-- Grosses transactions (> $10000)
SELECT
    p.firstname,
    p.lastname,
    t.type,
    t.account,
    t.amount,
    t.reason,
    t.created_at
FROM ama_transactions t
JOIN ama_players p ON t.identifier = p.identifier
WHERE t.amount > 10000
ORDER BY t.amount DESC, t.created_at DESC;
```

### AMACoin

```sql
-- Transactions AMACoin aujourd'hui
SELECT
    sender.firstname as sender_name,
    receiver.firstname as receiver_name,
    bt.amount,
    bt.type,
    bt.created_at
FROM ama_bitcoin_transactions bt
LEFT JOIN ama_players sender ON bt.sender_uuid = sender.wallet_uuid
LEFT JOIN ama_players receiver ON bt.receiver_uuid = receiver.wallet_uuid
WHERE DATE(bt.created_at) = CURDATE()
ORDER BY bt.created_at DESC;

-- Top détenteurs d'AMACoin
SELECT
    firstname,
    lastname,
    bitcoin,
    (bitcoin * 100) as value_usd,
    wallet_uuid
FROM ama_players
WHERE bitcoin > 0
ORDER BY bitcoin DESC
LIMIT 20;

-- Volume de transactions AMACoin
SELECT
    DATE(created_at) as date,
    COUNT(*) as transaction_count,
    SUM(amount) as total_volume
FROM ama_bitcoin_transactions
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### Jobs

```sql
-- Salaires par job et grade
SELECT
    j.label as job,
    jg.label as grade_name,
    jg.grade,
    jg.salary
FROM ama_job_grades jg
JOIN ama_jobs j ON jg.job_name = j.name
ORDER BY j.label, jg.grade;

-- Joueurs par grade
SELECT
    j.label as job,
    p.job_grade,
    COUNT(*) as player_count
FROM ama_players p
JOIN ama_jobs j ON p.job = j.name
GROUP BY p.job, p.job_grade, j.label
ORDER BY j.label, p.job_grade;
```

### Crews

```sql
-- Info complète d'un crew
SELECT
    c.label as crew_name,
    c.bank as crew_bank,
    COUNT(p.id) as member_count,
    AVG(p.money + p.bank) as avg_member_money
FROM ama_crews c
LEFT JOIN ama_players p ON p.crew = c.name
WHERE c.name = 'mafia'
GROUP BY c.name, c.label, c.bank;

-- Logs d'un crew
SELECT
    cl.action,
    p.firstname,
    p.lastname,
    cl.details,
    cl.created_at
FROM ama_crew_logs cl
JOIN ama_players p ON cl.player_identifier = p.identifier
WHERE cl.crew_name = 'mafia'
ORDER BY cl.created_at DESC
LIMIT 50;
```

---

## Maintenance

### Nettoyage automatique

Le framework inclut une procédure pour nettoyer les anciennes transactions :

```sql
CALL cleanup_old_transactions();
```

Cette procédure :
- Supprime les transactions de plus de 90 jours
- Archive les données importantes
- Optimise les tables

### Optimisation des tables

```sql
-- Optimiser toutes les tables AMA
OPTIMIZE TABLE ama_players;
OPTIMIZE TABLE ama_transactions;
OPTIMIZE TABLE ama_bitcoin_transactions;
OPTIMIZE TABLE ama_vehicles;
OPTIMIZE TABLE ama_crew_logs;
OPTIMIZE TABLE ama_jobs;
OPTIMIZE TABLE ama_job_grades;
OPTIMIZE TABLE ama_crews;
```

### Analyse des tables

```sql
-- Analyser toutes les tables
ANALYZE TABLE ama_players;
ANALYZE TABLE ama_transactions;
-- ...
```

### Vérifier l'intégrité

```sql
CHECK TABLE ama_players;
CHECK TABLE ama_transactions;
-- ...
```

### Réparer une table

```sql
REPAIR TABLE ama_players;
```

---

## Optimisation

### Index recommandés

Les index sont déjà créés lors de l'installation, mais si vous en avez besoin :

```sql
-- Index sur ama_players
CREATE INDEX idx_identifier ON ama_players(identifier);
CREATE INDEX idx_uuid ON ama_players(uuid);
CREATE INDEX idx_wallet_uuid ON ama_players(wallet_uuid);
CREATE INDEX idx_job ON ama_players(job);
CREATE INDEX idx_crew ON ama_players(crew);
CREATE INDEX idx_last_seen ON ama_players(last_seen);

-- Index sur ama_transactions
CREATE INDEX idx_identifier ON ama_transactions(identifier);
CREATE INDEX idx_type ON ama_transactions(type);
CREATE INDEX idx_created_at ON ama_transactions(created_at);

-- Index sur ama_bitcoin_transactions
CREATE INDEX idx_sender ON ama_bitcoin_transactions(sender_uuid);
CREATE INDEX idx_receiver ON ama_bitcoin_transactions(receiver_uuid);
CREATE INDEX idx_created_at ON ama_bitcoin_transactions(created_at);
```

### Statistiques de taille

```sql
-- Taille de chaque table
SELECT
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb,
    table_rows
FROM information_schema.TABLES
WHERE table_schema = 'nombase'
  AND table_name LIKE 'ama_%'
ORDER BY (data_length + index_length) DESC;
```

---

## Sauvegarde et restauration

### Sauvegarde complète

```bash
# Toute la base
mysqldump -u utilisateur -p nombase > backup_full_$(date +%Y%m%d).sql

# Uniquement les tables AMA
mysqldump -u utilisateur -p nombase \
    ama_players ama_jobs ama_job_grades ama_crews \
    ama_vehicles ama_transactions ama_bitcoin_transactions ama_crew_logs \
    > backup_ama_$(date +%Y%m%d).sql
```

### Sauvegarde avec compression

```bash
mysqldump -u utilisateur -p nombase | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Restauration

```bash
# Depuis un fichier SQL
mysql -u utilisateur -p nombase < backup_20241209.sql

# Depuis un fichier compressé
gunzip < backup_20241209.sql.gz | mysql -u utilisateur -p nombase
```

### Sauvegarde automatique (cron)

```bash
# Éditer le crontab
crontab -e

# Ajouter cette ligne (backup tous les jours à 3h)
0 3 * * * mysqldump -u utilisateur -p'motdepasse' nombase | gzip > /backups/ama_$(date +\%Y\%m\%d).sql.gz
```

### Script de backup

`backup.sh` :
```bash
#!/bin/bash

# Configuration
DB_USER="utilisateur"
DB_PASS="motdepasse"
DB_NAME="nombase"
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Créer le backup
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/backup_$DATE.sql.gz

# Garder uniquement les 30 derniers backups
cd $BACKUP_DIR
ls -t backup_*.sql.gz | tail -n +31 | xargs rm -f

echo "Backup créé: backup_$DATE.sql.gz"
```

---

## 📚 Voir aussi

- [Guide complet](GUIDE_COMPLET.md) - Installation et configuration
- [Troubleshooting](TROUBLESHOOTING.md) - Résolution de problèmes
- [API Serveur](API_SERVEUR.md) - Utilisation de l'API

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2025
