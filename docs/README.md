# 📚 Documentation du Framework AMA

Bienvenue dans la documentation complète du Framework AMA pour FiveM.

## 📖 Guides disponibles

### 1. [Guide Complet](GUIDE_COMPLET.md)
**Le point de départ pour tous**

Contient tout ce dont vous avez besoin pour démarrer avec le framework :
- Vue d'ensemble du framework
- Architecture détaillée
- Installation pas à pas
- Configuration complète
- Structure des fichiers
- Système de modules
- Hooks et événements
- Optimisations

👉 **Commencez ici si vous installez le framework pour la première fois**

---

### 2. [API Serveur](API_SERVEUR.md)
**Documentation technique serveur**

Documentation complète de l'API côté serveur :
- Fonctions globales (AMA.GetPlayer, AMA.GetPlayers, etc.)
- Classe Player (propriétés et méthodes)
- Gestion de l'argent (money, bank)
- Système de jobs
- Système de crews
- Bitcoin/AMACoin
- Callbacks serveur
- Exports

👉 **Pour les développeurs créant des ressources serveur**

---

### 3. [API Client](API_CLIENT.md)
**Documentation technique client**

Documentation complète de l'API côté client :
- Fonctions client (GetPlayerData, IsPlayerLoaded, etc.)
- Événements (connexion, spawn, mise à jour argent, etc.)
- Callbacks
- Notifications
- Données du joueur
- Exemples pratiques

👉 **Pour les développeurs créant des interfaces et scripts client**

---

### 4. [Commandes](COMMANDES.md)
**Liste de toutes les commandes**

Référence complète des commandes disponibles :
- Commandes joueur (/me, /save, /pos, /fps)
- Commandes administrateur (/givemoney, /tp, /setjob, /setcrew)
- Commandes AMACoin (/wallet, /sendcoin, /cashout, /buycoin)
- Commandes crew (/crew)
- Commandes de debug
- Créer des commandes personnalisées

👉 **Pour les joueurs et administrateurs**

---

### 5. [Exemples de Code](EXEMPLES_CODE.md)
**Exemples pratiques**

Exemples de code complets et fonctionnels :
- Créer un nouveau job (exemple complet du job taxi)
- Ajouter une commande personnalisée
- Système de paiement (ATM, distributeurs)
- Intégration Discord (logs personnalisés)
- Système de missions
- Menu NUI personnalisé
- Système de véhicules
- Système d'inventaire

👉 **Pour apprendre par l'exemple et démarrer rapidement**

---

### 6. [Troubleshooting](TROUBLESHOOTING.md)
**Guide de dépannage**

Solutions aux problèmes courants :
- Erreurs courantes (tables non trouvées, MySQL, oxmysql, etc.)
- Problèmes de base de données
- Problèmes de connexion
- Problèmes Discord
- Problèmes de performance
- Mode debug
- Logs et diagnostics
- FAQ technique

👉 **Consultez ce guide en cas de problème**

---

### 7. [Base de Données](BASE_DONNEES.md)
**Structure et requêtes**

Documentation complète de la base de données :
- Vue d'ensemble
- Structure de toutes les tables
- Relations entre tables
- Requêtes SQL utiles
- Maintenance
- Optimisation
- Sauvegarde et restauration

👉 **Pour comprendre et gérer la base de données**

---

### 8. [Foire Aux Questions (FAQ)](FOIRE_AUX_QUESTIONS.md)
**Questions fréquentes**

Réponses aux questions les plus courantes :
- Questions générales
- Installation et configuration
- Utilisation
- Développement
- Performance
- Sécurité
- Économie
- Compatibilité

👉 **Trouvez rapidement des réponses à vos questions**

---

## 🚀 Par où commencer ?

### Vous êtes un administrateur ?

1. 📖 Lisez le [Guide Complet](GUIDE_COMPLET.md)
2. ⚙️ Suivez l'installation pas à pas
3. 📋 Consultez les [Commandes](COMMANDES.md)
4. ❓ Parcourez la [FAQ](FOIRE_AUX_QUESTIONS.md)
5. 🔧 Gardez le [Troubleshooting](TROUBLESHOOTING.md) sous la main

### Vous êtes un développeur ?

1. 📖 Lisez le [Guide Complet](GUIDE_COMPLET.md) (Vue d'ensemble et Architecture)
2. 🖥️ Consultez l'[API Serveur](API_SERVEUR.md)
3. 💻 Consultez l'[API Client](API_CLIENT.md)
4. 💡 Explorez les [Exemples de Code](EXEMPLES_CODE.md)
5. 🗄️ Comprenez la [Base de Données](BASE_DONNEES.md)

### Vous êtes un joueur ?

1. 📋 Consultez les [Commandes](COMMANDES.md)
2. ❓ Lisez la [FAQ](FOIRE_AUX_QUESTIONS.md)

---

## 📊 Statistiques de la documentation

- **8 guides** complets
- **~7000 lignes** de documentation
- **~155 Ko** de contenu
- **100% en français**
- **Nombreux exemples de code**
- **Liens croisés** entre documents

---

## 🔍 Index rapide

### Installation
- [Guide d'installation](GUIDE_COMPLET.md#installation-détaillée)
- [Configuration](GUIDE_COMPLET.md#configuration)
- [Problèmes d'installation](TROUBLESHOOTING.md#installation-et-configuration)

### Développement
- [Créer un job](EXEMPLES_CODE.md#créer-un-nouveau-job)
- [Créer une commande](EXEMPLES_CODE.md#ajouter-une-commande-personnalisée)
- [API Serveur complète](API_SERVEUR.md)
- [API Client complète](API_CLIENT.md)
- [Hooks et événements](GUIDE_COMPLET.md#hooks-et-événements)

### Base de données
- [Structure des tables](BASE_DONNEES.md#structure-des-tables)
- [Requêtes utiles](BASE_DONNEES.md#requêtes-utiles)
- [Maintenance](BASE_DONNEES.md#maintenance)
- [Sauvegarde](BASE_DONNEES.md#sauvegarde-et-restauration)

### Administration
- [Commandes admin](COMMANDES.md#commandes-administrateur)
- [Gestion des joueurs](API_SERVEUR.md#classe-player)
- [Économie](FOIRE_AUX_QUESTIONS.md#économie)
- [Sécurité](FOIRE_AUX_QUESTIONS.md#sécurité)

### Dépannage
- [Erreurs courantes](TROUBLESHOOTING.md#erreurs-courantes)
- [Problèmes de BDD](TROUBLESHOOTING.md#problèmes-de-base-de-données)
- [Problèmes de performance](TROUBLESHOOTING.md#problèmes-de-performance)
- [Mode debug](TROUBLESHOOTING.md#mode-debug)

---

## 🆘 Besoin d'aide ?

1. ✅ Consultez la [FAQ](FOIRE_AUX_QUESTIONS.md)
2. ✅ Lisez le [Troubleshooting](TROUBLESHOOTING.md)
3. ✅ Activez le mode debug
4. ✅ Vérifiez les logs
5. ✅ Contactez le support sur Discord

---

## 📝 Contribution

Cette documentation est maintenue par la communauté AMA Framework.

Pour signaler une erreur ou suggérer une amélioration :
- Ouvrez une issue sur GitHub
- Contactez-nous sur Discord
- Proposez une pull request

---

## 📄 Licence

Cette documentation est fournie avec le Framework AMA.

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2025  
**Auteurs** : AMA Framework Team
