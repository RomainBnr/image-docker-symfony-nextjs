# 🚀 Guide de Déploiement sur VPS Ubuntu

## ✅ Checklist Pré-Déploiement

### 1. **Prérequis sur le VPS Ubuntu**
```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation de Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installation de Docker Compose
sudo apt install docker-compose-plugin

# Installation d'autres outils
sudo apt install git nginx certbot python3-certbot-nginx -y
```

### 2. **Sécurité à configurer AVANT le déploiement**

#### A. Générer des secrets sécurisés
```bash
# Générer un mot de passe MySQL root (32 caractères)
openssl rand -base64 32

# Générer un mot de passe MySQL utilisateur (32 caractères)
openssl rand -base64 32

# Générer une clé secrète Symfony (32 caractères)
openssl rand -hex 32
```

#### B. Certificat SSL/HTTPS (obligatoire pour la production)
```bash
# Option 1: Let's Encrypt (gratuit, recommandé)
sudo certbot --nginx -d votre-domaine.com

# Option 2: Certificat auto-signé (pour les tests uniquement)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/server.key \
  -out /etc/ssl/certs/server.crt
```

### 3. **Configuration des fichiers**

#### A. Créer `.env.production` sur le serveur
```bash
# Copiez .env.production.example vers .env.production
cp .env.production.example .env.production

# Éditez avec vos vraies valeurs
nano .env.production
```

**⚠️ IMPORTANT**: Remplacez TOUTES les valeurs par défaut !

#### B. Configurer le pare-feu
```bash
# Autoriser uniquement les ports nécessaires
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable
```

## 🚀 Déploiement

### 1. **Cloner le projet**
```bash
git clone https://github.com/votre-repo/votre-projet.git
cd votre-projet
```

### 2. **Configurer les fichiers de production**
```bash
# Créer le fichier .env.production avec vos vraies valeurs
cp .env.production.example .env.production
nano .env.production  # Modifier avec vos valeurs

# Donner les permissions d'exécution
chmod +x deploy.sh
```

### 3. **Déployer**
```bash
# Déploiement complet
docker-compose -f docker-compose.production.yml up -d --build

# Attendre que les services démarrent
sleep 30

# Installation des dépendances Symfony
docker-compose -f docker-compose.production.yml exec php composer install --no-dev --optimize-autoloader

# Migrations de base de données
docker-compose -f docker-compose.production.yml exec php php bin/console doctrine:migrations:migrate --no-interaction

# Nettoyage du cache
docker-compose -f docker-compose.production.yml exec php php bin/console cache:clear --env=prod
```

## 🔒 Post-Déploiement

### 1. **Tests de sécurité**
```bash
# Test du site
curl -I https://votre-domaine.com

# Vérifier les headers de sécurité
curl -I https://votre-domaine.com | grep -E "(Strict-Transport|X-Frame|X-Content)"

# Test des APIs
curl https://votre-domaine.com/api/health
```

### 2. **Monitoring**
```bash
# Voir les logs
docker-compose -f docker-compose.production.yml logs -f

# Voir l'état des conteneurs
docker-compose -f docker-compose.production.yml ps

# Voir l'utilisation des ressources
docker stats
```

### 3. **Sauvegardes automatiques**
```bash
# Créer un script de sauvegarde
sudo nano /etc/cron.daily/backup-app

# Contenu du script:
#!/bin/bash
docker-compose -f /path/to/your/app/docker-compose.production.yml exec mysql mysqldump -u root -p\$MYSQL_ROOT_PASSWORD symfony_prod > /backup/db-$(date +%Y%m%d).sql
tar -czf /backup/app-$(date +%Y%m%d).tar.gz /path/to/your/app
```

## ⚠️ PROBLÈMES CRITIQUES À RÉSOUDRE

### 1. **Certificats SSL manquants**
- Configurez Let's Encrypt ou ajoutez vos certificats SSL
- Modifiez `SSL_CERT_PATH` et `SSL_KEY_PATH` dans `.env.production`

### 2. **Domaine non configuré**
- Remplacez `votre-domaine.com` par votre vrai domaine
- Configurez vos DNS pour pointer vers votre VPS

### 3. **Secrets non sécurisés**
- Changez TOUS les mots de passe par défaut
- Utilisez des secrets de 32+ caractères

## 🆘 Dépannage

### Problèmes courants:
```bash
# Si nginx ne démarre pas
sudo nginx -t  # Tester la configuration

# Si la base de données ne se connecte pas
docker-compose -f docker-compose.production.yml logs mysql

# Si le frontend ne charge pas
docker-compose -f docker-compose.production.yml logs frontend

# Redémarrer tous les services
docker-compose -f docker-compose.production.yml restart
```

## 📋 Résumé

**✅ Votre application SERA prête pour la production quand :**
1. ✅ Certificats SSL configurés
2. ✅ Fichier `.env.production` avec de vrais secrets
3. ✅ Domaine configuré
4. ✅ Pare-feu configuré
5. ✅ Sauvegardes configurées

**❌ Actuellement PAS prête car :**
- ❌ Pas de certificats SSL
- ❌ Secrets par défaut non sécurisés
- ❌ Configuration de domaine manquante
