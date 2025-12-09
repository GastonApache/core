-- Script SQL d'installation pour AMA Framework
-- Base de données MySQL/MariaDB

-- ================================================
-- Création de la base de données
-- ================================================
-- IMPORTANT: Créez la base de données "framework" avant d'importer ce fichier
-- Ou décommentez les lignes suivantes pour créer automatiquement la base:

-- CREATE DATABASE IF NOT EXISTS `framework` 
--     DEFAULT CHARACTER SET utf8mb4 
--     COLLATE utf8mb4_unicode_ci;
-- USE `framework`;

-- Note: Si vous utilisez un autre nom de base de données, 
-- modifiez Config.Database.Name dans shared/config.lua

-- ================================================
-- Table des joueurs
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_players` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Identifiant Steam/License',
    `firstname` VARCHAR(50) DEFAULT 'John' COMMENT 'Prénom du joueur',
    `lastname` VARCHAR(50) DEFAULT 'Doe' COMMENT 'Nom du joueur',
    `money` INT(11) DEFAULT 5000 COMMENT 'Argent liquide',
    `bank` INT(11) DEFAULT 0 COMMENT 'Argent en banque',
    `job` VARCHAR(50) DEFAULT 'unemployed' COMMENT 'Métier actuel',
    `job_grade` INT(11) DEFAULT 0 COMMENT 'Grade du métier',
    `group` VARCHAR(50) DEFAULT 'user' COMMENT 'Groupe (user, admin, superadmin)',
    `position` TEXT DEFAULT NULL COMMENT 'Dernière position (JSON)',
    `inventory` LONGTEXT DEFAULT NULL COMMENT 'Inventaire (JSON)',
    `accounts` LONGTEXT DEFAULT NULL COMMENT 'Comptes supplémentaires (JSON)',
    `skin` LONGTEXT DEFAULT NULL COMMENT 'Apparence du personnage (JSON)',
    `last_seen` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière connexion',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de création',
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`),
    KEY `idx_identifier` (`identifier`),
    KEY `idx_job` (`job`),
    KEY `idx_group` (`group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table principale des joueurs';

-- ================================================
-- Table des métiers
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_jobs` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL COMMENT 'Nom du métier',
    `label` VARCHAR(100) NOT NULL COMMENT 'Label affiché',
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Liste des métiers disponibles';

-- ================================================
-- Table des grades de métiers
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_job_grades` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `job_name` VARCHAR(50) NOT NULL COMMENT 'Nom du métier',
    `grade` INT(11) NOT NULL COMMENT 'Niveau du grade',
    `name` VARCHAR(50) NOT NULL COMMENT 'Nom du grade',
    `label` VARCHAR(100) NOT NULL COMMENT 'Label affiché',
    `salary` INT(11) NOT NULL DEFAULT 0 COMMENT 'Salaire',
    PRIMARY KEY (`id`),
    UNIQUE KEY `job_grade` (`job_name`, `grade`),
    KEY `job_name` (`job_name`),
    CONSTRAINT `fk_job_grades_job` FOREIGN KEY (`job_name`) REFERENCES `ama_jobs` (`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Grades des métiers';

-- ================================================
-- Table des véhicules
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_vehicles` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `owner` VARCHAR(60) NOT NULL COMMENT 'Identifiant du propriétaire',
    `plate` VARCHAR(12) NOT NULL COMMENT 'Plaque du véhicule',
    `vehicle` VARCHAR(50) NOT NULL COMMENT 'Modèle du véhicule',
    `stored` TINYINT(1) DEFAULT 1 COMMENT 'Véhicule en garage (1) ou sorti (0)',
    `garage` VARCHAR(50) DEFAULT 'pillbox' COMMENT 'Garage actuel',
    `mods` LONGTEXT DEFAULT NULL COMMENT 'Modifications (JSON)',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `plate` (`plate`),
    KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Véhicules des joueurs';

-- ================================================
-- Table des transactions
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Identifiant du joueur',
    `type` VARCHAR(20) NOT NULL COMMENT 'Type de transaction (add, remove)',
    `account` VARCHAR(20) NOT NULL COMMENT 'Compte (money, bank)',
    `amount` INT(11) NOT NULL COMMENT 'Montant',
    `reason` VARCHAR(255) DEFAULT NULL COMMENT 'Raison',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`),
    KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historique des transactions';

-- ================================================
-- Insertion des données par défaut
-- ================================================

-- Métiers par défaut
INSERT INTO `ama_jobs` (`name`, `label`) VALUES
    ('unemployed', 'Sans emploi'),
    ('police', 'Police'),
    ('ambulance', 'Ambulance'),
    ('mechanic', 'Mécanicien'),
    ('taxi', 'Taxi')
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`);

-- Grades pour Sans emploi
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('unemployed', 0, 'unemployed', 'Sans emploi', 200)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `salary` = VALUES(`salary`);

-- Grades pour Police
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('police', 0, 'recruit', 'Recrue', 500),
    ('police', 1, 'officer', 'Officier', 750),
    ('police', 2, 'sergeant', 'Sergent', 1000),
    ('police', 3, 'lieutenant', 'Lieutenant', 1250),
    ('police', 4, 'boss', 'Commandant', 1500)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `salary` = VALUES(`salary`);

-- Grades pour Ambulance
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('ambulance', 0, 'ambulance', 'Ambulancier', 500),
    ('ambulance', 1, 'doctor', 'Médecin', 750),
    ('ambulance', 2, 'chief_doctor', 'Médecin-chef', 1000),
    ('ambulance', 3, 'boss', 'Directeur', 1250)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `salary` = VALUES(`salary`);

-- Grades pour Mécanicien
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('mechanic', 0, 'recrue', 'Recrue', 400),
    ('mechanic', 1, 'novice', 'Novice', 600),
    ('mechanic', 2, 'experimente', 'Expérimenté', 800),
    ('mechanic', 3, 'chief', 'Chef d\'équipe', 1000),
    ('mechanic', 4, 'boss', 'Patron', 1200)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `salary` = VALUES(`salary`);

-- Grades pour Taxi
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('taxi', 0, 'recrue', 'Recrue', 300),
    ('taxi', 1, 'novice', 'Novice', 450),
    ('taxi', 2, 'experimente', 'Expérimenté', 600),
    ('taxi', 3, 'uber', 'Uber', 750),
    ('taxi', 4, 'boss', 'Patron', 900)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `salary` = VALUES(`salary`);

-- ================================================
-- Fin du script d'installation
-- ================================================

-- Script SQL d'installation pour AMA Framework
-- Base de données MySQL/MariaDB

-- ================================================
-- Table des joueurs
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_players` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Identifiant Steam/License',
    `uuid` VARCHAR(36) NOT NULL COMMENT 'UUID unique du joueur',
    `wallet_uuid` VARCHAR(36) NOT NULL COMMENT 'UUID unique du wallet AMACoin',
    `firstname` VARCHAR(50) DEFAULT 'John' COMMENT 'Prénom du joueur',
    `lastname` VARCHAR(50) DEFAULT 'Doe' COMMENT 'Nom du joueur',
    `money` INT(11) DEFAULT 5000 COMMENT 'Argent liquide',
    `bank` INT(11) DEFAULT 0 COMMENT 'Argent en banque',
    `bitcoin` DECIMAL(15,8) DEFAULT 0.00000000 COMMENT 'AMACoins (Bitcoin)',
    `job` VARCHAR(50) DEFAULT 'unemployed' COMMENT 'Métier actuel',
    `job_grade` INT(11) DEFAULT 0 COMMENT 'Grade du métier',
    `crew` VARCHAR(50) DEFAULT 'none' COMMENT 'Crew/Organisation illégale',
    `crew_grade` INT(11) DEFAULT 0 COMMENT 'Grade dans le crew',
    `group` VARCHAR(50) DEFAULT 'user' COMMENT 'Groupe (user, admin, superadmin)',
    `position` TEXT DEFAULT NULL COMMENT 'Dernière position (JSON)',
    `inventory` LONGTEXT DEFAULT NULL COMMENT 'Inventaire (JSON)',
    `accounts` LONGTEXT DEFAULT NULL COMMENT 'Comptes supplémentaires (JSON)',
    `skin` LONGTEXT DEFAULT NULL COMMENT 'Apparence du personnage (JSON)',
    `last_seen` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière connexion',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de création',
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`),
    UNIQUE KEY `uuid` (`uuid`),
    UNIQUE KEY `wallet_uuid` (`wallet_uuid`),
    KEY `idx_identifier` (`identifier`),
    KEY `idx_uuid` (`uuid`),
    KEY `idx_job` (`job`),
    KEY `idx_crew` (`crew`),
    KEY `idx_group` (`group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table principale des joueurs';

-- ================================================
-- Table des métiers
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_jobs` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL COMMENT 'Nom du métier',
    `label` VARCHAR(100) NOT NULL COMMENT 'Label affiché',
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Liste des métiers disponibles';

-- ================================================
-- Table des grades de métiers
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_job_grades` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `job_name` VARCHAR(50) NOT NULL COMMENT 'Nom du métier',
    `grade` INT(11) NOT NULL COMMENT 'Niveau du grade',
    `name` VARCHAR(50) NOT NULL COMMENT 'Nom du grade',
    `label` VARCHAR(100) NOT NULL COMMENT 'Label affiché',
    `salary` INT(11) NOT NULL DEFAULT 0 COMMENT 'Salaire',
    PRIMARY KEY (`id`),
    UNIQUE KEY `job_grade` (`job_name`, `grade`),
    KEY `job_name` (`job_name`),
    CONSTRAINT `fk_job_grades_job` FOREIGN KEY (`job_name`) REFERENCES `ama_jobs` (`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Grades des métiers';

-- ================================================
-- Table des crews (organisations illégales)
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_crews` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL COMMENT 'Nom du crew',
    `label` VARCHAR(100) NOT NULL COMMENT 'Label affiché',
    `color` VARCHAR(7) DEFAULT '#95a5a6' COMMENT 'Couleur du crew',
    `bank` INT(11) DEFAULT 0 COMMENT 'Coffre du crew',
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Liste des crews disponibles';

-- ================================================
-- Table des transactions AMACoins
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_bitcoin_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `sender_uuid` VARCHAR(36) DEFAULT NULL COMMENT 'UUID de l\'expéditeur',
    `receiver_uuid` VARCHAR(36) DEFAULT NULL COMMENT 'UUID du destinataire',
    `amount` DECIMAL(15,8) NOT NULL COMMENT 'Montant de la transaction',
    `type` VARCHAR(20) NOT NULL COMMENT 'Type (send, receive, convert)',
    `reason` VARCHAR(255) DEFAULT NULL COMMENT 'Raison de la transaction',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `sender_uuid` (`sender_uuid`),
    KEY `receiver_uuid` (`receiver_uuid`),
    KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historique des transactions AMACoins';

-- ================================================
-- Table des véhicules
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_vehicles` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `owner` VARCHAR(60) NOT NULL COMMENT 'Identifiant du propriétaire',
    `plate` VARCHAR(12) NOT NULL COMMENT 'Plaque du véhicule',
    `vehicle` VARCHAR(50) NOT NULL COMMENT 'Modèle du véhicule',
    `stored` TINYINT(1) DEFAULT 1 COMMENT 'Véhicule en garage (1) ou sorti (0)',
    `garage` VARCHAR(50) DEFAULT 'pillbox' COMMENT 'Garage actuel',
    `mods` LONGTEXT DEFAULT NULL COMMENT 'Modifications (JSON)',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `plate` (`plate`),
    KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Véhicules des joueurs';

-- ================================================
-- Table des transactions
-- ================================================
CREATE TABLE IF NOT EXISTS `ama_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Identifiant du joueur',
    `type` VARCHAR(20) NOT NULL COMMENT 'Type de transaction (add, remove)',
    `account` VARCHAR(20) NOT NULL COMMENT 'Compte (money, bank, bitcoin)',
    `amount` DECIMAL(15,2) NOT NULL COMMENT 'Montant',
    `reason` VARCHAR(255) DEFAULT NULL COMMENT 'Raison',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`),
    KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historique des transactions';

-- ================================================
-- Insertion des données par défaut
-- ================================================

-- Métiers par défaut
INSERT INTO `ama_jobs` (`name`, `label`) VALUES
    ('unemployed', 'Sans emploi'),
    ('police', 'Police'),
    ('ambulance', 'Ambulance'),
    ('mechanic', 'Mécanicien'),
    ('taxi', 'Taxi')
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`);

-- Grades pour Sans emploi
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('unemployed', 0, 'unemployed', 'Sans emploi', 200)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `salary` = VALUES(`salary`);

-- Grades pour Police
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('police', 0, 'recruit', 'Recrue', 500),
    ('police', 1, 'officer', 'Officier', 750),
    ('police', 2, 'sergeant', 'Sergent', 1000),
    ('police', 3, 'lieutenant', 'Lieutenant', 1250),
    ('police', 4, 'boss', 'Commandant', 1500)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `salary` = VALUES(`salary`);

-- Grades pour Ambulance
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('ambulance', 0, 'ambulance', 'Ambulancier', 500),
    ('ambulance', 1, 'doctor', 'Médecin', 750),
    ('ambulance', 2, 'chief_doctor', 'Médecin-chef', 1000),
    ('ambulance', 3, 'boss', 'Directeur', 1250)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `salary` = VALUES(`salary`);

-- Grades pour Mécanicien
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('mechanic', 0, 'recrue', 'Recrue', 400),
    ('mechanic', 1, 'novice', 'Novice', 600),
    ('mechanic', 2, 'experimente', 'Expérimenté', 800),
    ('mechanic', 3, 'chief', 'Chef d\'équipe', 1000),
    ('mechanic', 4, 'boss', 'Patron', 1200)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `salary` = VALUES(`salary`);

-- Grades pour Taxi
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('taxi', 0, 'recrue', 'Recrue', 300),
    ('taxi', 1, 'novice', 'Novice', 450),
    ('taxi', 2, 'experimente', 'Expérimenté', 600),
    ('taxi', 3, 'uber', 'Uber', 750),
    ('taxi', 4, 'boss', 'Patron', 900)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `salary` = VALUES(`salary`);

-- Crews par défaut (organisations illégales)
INSERT INTO `ama_crews` (`name`, `label`, `color`, `bank`) VALUES
    ('none', 'Aucun Crew', '#95a5a6', 0),
    ('mafia', 'La Mafia', '#e74c3c', 0),
    ('cartel', 'Le Cartel', '#f39c12', 0),
    ('yakuza', 'Yakuza', '#8e44ad', 0),
    ('gang_street', 'Gang des Rues', '#27ae60', 0),
    ('bikers', 'Club de Motards', '#34495e', 0)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`);

-- ================================================
-- Fin du script d'installation
-- ================================================

-- =====================================================
-- SCRIPT SQL D'INSTALLATION - AMA FRAMEWORK
-- =====================================================
-- Version: 1.0.0
-- Base de données: MySQL/MariaDB
-- Encodage: UTF-8
-- 
-- INSTRUCTIONS:
-- 1. Importez ce fichier dans phpMyAdmin ou votre client SQL
-- 2. Assurez-vous d'avoir sélectionné la bonne base de données
-- 3. Exécutez le script complet
-- =====================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- =====================================================
-- TABLE: ama_players (Joueurs)
-- =====================================================
CREATE TABLE IF NOT EXISTS `ama_players` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Identifiant Steam/License',
    `uuid` VARCHAR(36) NOT NULL COMMENT 'UUID unique du joueur',
    `wallet_uuid` VARCHAR(36) NOT NULL COMMENT 'UUID unique du wallet AMACoin',
    `firstname` VARCHAR(50) DEFAULT 'John' COMMENT 'Prénom du joueur',
    `lastname` VARCHAR(50) DEFAULT 'Doe' COMMENT 'Nom du joueur',
    `money` INT(11) DEFAULT 5000 COMMENT 'Argent liquide',
    `bank` INT(11) DEFAULT 0 COMMENT 'Argent en banque',
    `bitcoin` DECIMAL(15,8) DEFAULT 0.00000000 COMMENT 'AMACoins (Bitcoin)',
    `job` VARCHAR(50) DEFAULT 'unemployed' COMMENT 'Métier actuel',
    `job_grade` INT(11) DEFAULT 0 COMMENT 'Grade du métier',
    `crew` VARCHAR(50) DEFAULT 'none' COMMENT 'Crew/Organisation illégale',
    `crew_grade` INT(11) DEFAULT 0 COMMENT 'Grade dans le crew',
    `group` VARCHAR(50) DEFAULT 'user' COMMENT 'Groupe (user, admin, superadmin)',
    `position` TEXT DEFAULT NULL COMMENT 'Dernière position (JSON)',
    `inventory` LONGTEXT DEFAULT NULL COMMENT 'Inventaire (JSON)',
    `accounts` LONGTEXT DEFAULT NULL COMMENT 'Comptes supplémentaires (JSON)',
    `skin` LONGTEXT DEFAULT NULL COMMENT 'Apparence du personnage (JSON)',
    `last_seen` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière connexion',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de création',
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`),
    UNIQUE KEY `uuid` (`uuid`),
    UNIQUE KEY `wallet_uuid` (`wallet_uuid`),
    KEY `idx_identifier` (`identifier`),
    KEY `idx_uuid` (`uuid`),
    KEY `idx_job` (`job`),
    KEY `idx_crew` (`crew`),
    KEY `idx_group` (`group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table principale des joueurs';

-- =====================================================
-- TABLE: ama_jobs (Métiers)
-- =====================================================
CREATE TABLE IF NOT EXISTS `ama_jobs` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL COMMENT 'Nom du métier',
    `label` VARCHAR(100) NOT NULL COMMENT 'Label affiché',
    `whitelisted` TINYINT(1) DEFAULT 0 COMMENT 'Métier whitelist (1=oui, 0=non)',
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Liste des métiers disponibles';

-- =====================================================
-- TABLE: ama_job_grades (Grades des métiers)
-- =====================================================
CREATE TABLE IF NOT EXISTS `ama_job_grades` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `job_name` VARCHAR(50) NOT NULL COMMENT 'Nom du métier',
    `grade` INT(11) NOT NULL COMMENT 'Niveau du grade',
    `name` VARCHAR(50) NOT NULL COMMENT 'Nom du grade',
    `label` VARCHAR(100) NOT NULL COMMENT 'Label affiché',
    `salary` INT(11) NOT NULL DEFAULT 0 COMMENT 'Salaire',
    `skin_male` LONGTEXT DEFAULT NULL COMMENT 'Tenue homme (JSON)',
    `skin_female` LONGTEXT DEFAULT NULL COMMENT 'Tenue femme (JSON)',
    PRIMARY KEY (`id`),
    UNIQUE KEY `job_grade` (`job_name`, `grade`),
    KEY `job_name` (`job_name`),
    CONSTRAINT `fk_job_grades_job` FOREIGN KEY (`job_name`) REFERENCES `ama_jobs` (`name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Grades des métiers';

-- =====================================================
-- TABLE: ama_crews (Organisations illégales)
-- =====================================================
CREATE TABLE IF NOT EXISTS `ama_crews` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL COMMENT 'Nom du crew',
    `label` VARCHAR(100) NOT NULL COMMENT 'Label affiché',
    `color` VARCHAR(7) DEFAULT '#95a5a6' COMMENT 'Couleur du crew (HEX)',
    `bank` INT(11) DEFAULT 0 COMMENT 'Coffre du crew',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de création',
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Liste des crews/organisations illégales';

-- =====================================================
-- TABLE: ama_bitcoin_transactions (Transactions AMACoin)
-- =====================================================
CREATE TABLE IF NOT EXISTS `ama_bitcoin_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `sender_uuid` VARCHAR(36) DEFAULT NULL COMMENT 'UUID wallet expéditeur',
    `receiver_uuid` VARCHAR(36) DEFAULT NULL COMMENT 'UUID wallet destinataire',
    `amount` DECIMAL(15,8) NOT NULL COMMENT 'Montant de la transaction',
    `type` VARCHAR(20) NOT NULL COMMENT 'Type (send, receive, convert)',
    `reason` VARCHAR(255) DEFAULT NULL COMMENT 'Raison de la transaction',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de la transaction',
    PRIMARY KEY (`id`),
    KEY `sender_uuid` (`sender_uuid`),
    KEY `receiver_uuid` (`receiver_uuid`),
    KEY `created_at` (`created_at`),
    KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historique des transactions AMACoins';

-- =====================================================
-- TABLE: ama_vehicles (Véhicules)
-- =====================================================
CREATE TABLE IF NOT EXISTS `ama_vehicles` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `owner` VARCHAR(60) NOT NULL COMMENT 'Identifiant du propriétaire',
    `plate` VARCHAR(12) NOT NULL COMMENT 'Plaque du véhicule',
    `vehicle` VARCHAR(50) NOT NULL COMMENT 'Modèle du véhicule',
    `hash` VARCHAR(50) NOT NULL COMMENT 'Hash du véhicule',
    `stored` TINYINT(1) DEFAULT 1 COMMENT 'En garage (1) ou sorti (0)',
    `garage` VARCHAR(50) DEFAULT 'pillbox' COMMENT 'Garage actuel',
    `state` INT(11) DEFAULT 1000 COMMENT 'État du véhicule (0-1000)',
    `fuel` INT(11) DEFAULT 100 COMMENT 'Essence (0-100)',
    `engine` FLOAT DEFAULT 1000.0 COMMENT 'État moteur',
    `body` FLOAT DEFAULT 1000.0 COMMENT 'État carrosserie',
    `mods` LONGTEXT DEFAULT NULL COMMENT 'Modifications (JSON)',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Date d\'achat',
    PRIMARY KEY (`id`),
    UNIQUE KEY `plate` (`plate`),
    KEY `owner` (`owner`),
    KEY `idx_stored` (`stored`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Véhicules des joueurs';

-- =====================================================
-- TABLE: ama_transactions (Historique transactions argent)
-- =====================================================
CREATE TABLE IF NOT EXISTS `ama_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Identifiant du joueur',
    `type` VARCHAR(20) NOT NULL COMMENT 'Type (add, remove)',
    `account` VARCHAR(20) NOT NULL COMMENT 'Compte (money, bank, bitcoin)',
    `amount` DECIMAL(15,2) NOT NULL COMMENT 'Montant',
    `reason` VARCHAR(255) DEFAULT NULL COMMENT 'Raison',
    `balance_after` DECIMAL(15,2) DEFAULT NULL COMMENT 'Solde après transaction',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de la transaction',
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`),
    KEY `created_at` (`created_at`),
    KEY `idx_type` (`type`),
    KEY `idx_account` (`account`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historique des transactions financières';

-- =====================================================
-- TABLE: ama_crew_logs (Logs des crews)
-- =====================================================
CREATE TABLE IF NOT EXISTS `ama_crew_logs` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `crew_name` VARCHAR(50) NOT NULL COMMENT 'Nom du crew',
    `player_identifier` VARCHAR(60) NOT NULL COMMENT 'Identifiant du joueur',
    `action` VARCHAR(50) NOT NULL COMMENT 'Action effectuée',
    `details` TEXT DEFAULT NULL COMMENT 'Détails de l\'action',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Date de l\'action',
    PRIMARY KEY (`id`),
    KEY `crew_name` (`crew_name`),
    KEY `player_identifier` (`player_identifier`),
    KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Logs des actions dans les crews';

-- =====================================================
-- INSERTION DES DONNÉES PAR DÉFAUT
-- =====================================================

-- Métiers légaux par défaut
INSERT INTO `ama_jobs` (`name`, `label`, `whitelisted`) VALUES
('unemployed', 'Sans emploi', 0),
('police', 'Police', 1),
('ambulance', 'Ambulance', 1),
('mechanic', 'Mécanicien', 0),
('taxi', 'Taxi', 0),
('realestateagent', 'Agent Immobilier', 0),
('cardealer', 'Concessionnaire', 1),
('banker', 'Banquier', 1),
('garbage', 'Éboueur', 0),
('fisherman', 'Pêcheur', 0),
('miner', 'Mineur', 0),
('lumberjack', 'Bûcheron', 0),
('fueler', 'Raffineur', 0),
('reporter', 'Journaliste', 0),
('chef', 'Cuisinier', 0);

-- Grades: Sans emploi
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
('unemployed', 0, 'unemployed', 'Sans emploi', 200);

-- Grades: Police
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
('police', 0, 'recruit', 'Recrue', 500),
('police', 1, 'officer', 'Officier', 750),
('police', 2, 'sergeant', 'Sergent', 1000),
('police', 3, 'lieutenant', 'Lieutenant', 1250),
('police', 4, 'boss', 'Commandant', 1500);

-- Grades: Ambulance
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
('ambulance', 0, 'ambulance', 'Ambulancier', 500),
('ambulance', 1, 'doctor', 'Médecin', 750),
('ambulance', 2, 'chief_doctor', 'Médecin-chef', 1000),
('ambulance', 3, 'boss', 'Directeur', 1250);

-- Grades: Mécanicien
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
('mechanic', 0, 'recrue', 'Recrue', 400),
('mechanic', 1, 'novice', 'Novice', 600),
('mechanic', 2, 'experimente', 'Expérimenté', 800),
('mechanic', 3, 'chief', 'Chef d\'équipe', 1000),
('mechanic', 4, 'boss', 'Patron', 1200);

-- Grades: Taxi
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
('taxi', 0, 'recrue', 'Recrue', 300),
('taxi', 1, 'novice', 'Novice', 450),
('taxi', 2, 'experimente', 'Expérimenté', 600),
('taxi', 3, 'uber', 'Uber', 750),
('taxi', 4, 'boss', 'Patron', 900);

-- Grades: Agent Immobilier
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
('realestateagent', 0, 'location', 'Agent Location', 400),
('realestateagent', 1, 'vendeur', 'Agent Vendeur', 600),
('realestateagent', 2, 'gestion', 'Gestionnaire', 800),
('realestateagent', 3, 'boss', 'Patron', 1000);

-- Grades: Concessionnaire
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
('cardealer', 0, 'recruit', 'Recrue', 500),
('cardealer', 1, 'seller', 'Vendeur', 750),
('cardealer', 2, 'boss', 'Patron', 1200);

-- Grades: Banquier
INSERT INTO `ama_job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
('banker', 0, 'advisor', 'Conseiller', 700),
('banker', 1, 'banker', 'Banquier', 1000),
('banker', 2, 'boss', 'Directeur', 1500);

-- Crews/Organisations illégales par défaut
INSERT INTO `ama_crews` (`name`, `label`, `color`, `bank`) VALUES
('none', 'Aucun Crew', '#95a5a6', 0),
('mafia', 'La Mafia', '#e74c3c', 50000),
('cartel', 'Le Cartel', '#f39c12', 50000),
('yakuza', 'Yakuza', '#8e44ad', 50000),
('gang_street', 'Gang des Rues', '#27ae60', 25000),
('bikers', 'Club de Motards', '#34495e', 25000),
('triad', 'Les Triades', '#e91e63', 50000),
('bratva', 'Bratva', '#d32f2f', 50000);

-- =====================================================
-- TRIGGERS (Optionnel - pour logs automatiques)
-- =====================================================

DELIMITER $$

-- Trigger pour logger les modifications de solde
CREATE TRIGGER `log_player_money_change` 
AFTER UPDATE ON `ama_players`
FOR EACH ROW
BEGIN
    IF NEW.money != OLD.money THEN
        INSERT INTO `ama_transactions` (`identifier`, `type`, `account`, `amount`, `balance_after`)
        VALUES (NEW.identifier, 
                IF(NEW.money > OLD.money, 'add', 'remove'), 
                'money', 
                ABS(NEW.money - OLD.money),
                NEW.money);
    END IF;
    
    IF NEW.bank != OLD.bank THEN
        INSERT INTO `ama_transactions` (`identifier`, `type`, `account`, `amount`, `balance_after`)
        VALUES (NEW.identifier, 
                IF(NEW.bank > OLD.bank, 'add', 'remove'), 
                'bank', 
                ABS(NEW.bank - OLD.bank),
                NEW.bank);
    END IF;
END$$

DELIMITER ;

-- =====================================================
-- VUES (Optionnel - pour statistiques)
-- =====================================================

-- Vue: Statistiques des joueurs en ligne
CREATE OR REPLACE VIEW `v_players_stats` AS
SELECT 
    COUNT(*) as total_players,
    SUM(money) as total_money,
    SUM(bank) as total_bank,
    SUM(bitcoin) as total_bitcoin,
    AVG(money) as avg_money,
    AVG(bank) as avg_bank
FROM `ama_players`
WHERE `last_seen` > DATE_SUB(NOW(), INTERVAL 24 HOUR);

-- Vue: Top joueurs par richesse
CREATE OR REPLACE VIEW `v_richest_players` AS
SELECT 
    `identifier`,
    CONCAT(`firstname`, ' ', `lastname`) as fullname,
    `money`,
    `bank`,
    (`money` + `bank`) as total_wealth,
    `bitcoin`
FROM `ama_players`
ORDER BY total_wealth DESC
LIMIT 10;

-- Vue: Statistiques des crews
CREATE OR REPLACE VIEW `v_crew_stats` AS
SELECT 
    c.name,
    c.label,
    c.bank,
    COUNT(p.id) as member_count
FROM `ama_crews` c
LEFT JOIN `ama_players` p ON p.crew = c.name
GROUP BY c.id;

-- =====================================================
-- INDICES SUPPLÉMENTAIRES POUR PERFORMANCE
-- =====================================================

-- Index pour recherches fréquentes
ALTER TABLE `ama_players` ADD INDEX `idx_fullname` (`firstname`, `lastname`);
ALTER TABLE `ama_players` ADD INDEX `idx_last_seen` (`last_seen`);
ALTER TABLE `ama_transactions` ADD INDEX `idx_created_at_type` (`created_at`, `type`);
ALTER TABLE `ama_bitcoin_transactions` ADD INDEX `idx_created_at_type` (`created_at`, `type`);

-- =====================================================
-- PERMISSIONS ET SÉCURITÉ
-- =====================================================

-- Créer un utilisateur dédié (OPTIONNEL - à personnaliser)
-- CREATE USER IF NOT EXISTS 'ama_user'@'localhost' IDENTIFIED BY 'VotreMotDePasseSecurise123!';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON votre_base.ama_* TO 'ama_user'@'localhost';
-- FLUSH PRIVILEGES;

-- =====================================================
-- NETTOYAGE ET MAINTENANCE
-- =====================================================

-- Procédure stockée pour nettoyer les vieilles transactions
DELIMITER $$

CREATE PROCEDURE `cleanup_old_transactions`()
BEGIN
    -- Supprimer les transactions de plus de 90 jours
    DELETE FROM `ama_transactions` WHERE `created_at` < DATE_SUB(NOW(), INTERVAL 90 DAY);
    DELETE FROM `ama_bitcoin_transactions` WHERE `created_at` < DATE_SUB(NOW(), INTERVAL 90 DAY);
    DELETE FROM `ama_crew_logs` WHERE `created_at` < DATE_SUB(NOW(), INTERVAL 90 DAY);
    
    -- Optimiser les tables
    OPTIMIZE TABLE `ama_players`;
    OPTIMIZE TABLE `ama_transactions`;
    OPTIMIZE TABLE `ama_bitcoin_transactions`;
END$$

DELIMITER ;

-- Planifier le nettoyage (nécessite EVENT SCHEDULER activé)
-- SET GLOBAL event_scheduler = ON;
-- CREATE EVENT IF NOT EXISTS `monthly_cleanup`
-- ON SCHEDULE EVERY 1 MONTH
-- DO CALL cleanup_old_transactions();

COMMIT;

-- =====================================================
-- FIN DU SCRIPT D'INSTALLATION
-- =====================================================
-- Installation terminée avec succès !
-- Vérifiez que toutes les tables ont été créées correctement.
-- =====================================================