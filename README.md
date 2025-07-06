# 🚀 Application Symfony + Next.js avec Docker

[![Production Ready](https://img.shields.io/badge/Production-Ready-green.svg)](https://github.com/votre-repo)
[![Docker](https://img.shields.io/badge/Docker-Compatible-blue.svg)](https://docker.com)
[![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue.svg)](https://www.typescriptlang.org/)
[![Symfony](https://img.shields.io/badge/Symfony-7.3-purple.svg)](https://symfony.com)
[![Next.js](https://img.shields.io/badge/Next.js-14-black.svg)](https://nextjs.org)

## 📋 Vue d'ensemble

Application web moderne full-stack avec une architecture microservices optimisée pour la performance et la sécurité.

### 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   NGINX Proxy   │    │  Next.js (TSX)  │    │ Symfony (PHP)   │
│  (Port 80/443)  ├────┤  (Port 3000)    ├────┤  (Port 9000)    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                  ┌─────────────────┐    ┌─────────────────┐
                  │  MySQL 8.4      │    │   Redis Cache   │
                  │  (Port 3306)    │    │  (Port 6379)    │
                  └─────────────────┘    └─────────────────┘
```

### 🔧 Stack Technique

| Composant | Technologie | Version | Description |
|-----------|-------------|---------|-------------|
| **Frontend** | Next.js + TypeScript | 14.0.0 | Interface utilisateur moderne avec SSR |
| **Backend** | Symfony + PHP | 7.3 / 8.3 | API REST avec architecture hexagonale |
| **Base de données** | MySQL | 8.4 | Base de données relationnelle optimisée |
| **Cache** | Redis | 7-alpine | Cache applicatif et sessions |
| **Proxy** | Nginx | Alpine | Reverse proxy avec SSL et compression |
| **Conteneurs** | Docker + Compose | Latest | Orchestration et déploiement |

## ✨ Fonctionnalités

### 🎯 Frontend (Next.js)
- ✅ **Interface moderne** avec Tailwind CSS
- ✅ **Dashboard interactif** avec données en temps réel
- ✅ **Pagination dynamique** côté client
- ✅ **Hooks personnalisés** pour les appels API
- ✅ **Gestion d'état optimisée** avec React hooks
- ✅ **TypeScript strict** pour la sécurité de type
- ✅ **Composants réutilisables** avec props typées
- ✅ **Cache intelligent** des réponses API

### 🛡️ Backend (Symfony)
- ✅ **API REST sécurisée** avec authentification
- ✅ **Validation automatique** des données
- ✅ **Pagination serveur** pour les grandes collections
- ✅ **Cache Redis** pour les performances
- ✅ **Health checks** pour le monitoring
- ✅ **Logs structurés** pour le debugging
- ✅ **CORS configuré** pour le frontend
- ✅ **Rate limiting** contre les abus

### 🔒 Sécurité
- ✅ **Headers de sécurité** (HSTS, CSP, XSS, etc.)
- ✅ **Certificats SSL** avec Let's Encrypt
- ✅ **Pare-feu applicatif** avec rate limiting
- ✅ **Secrets chiffrés** en production
- ✅ **Base de données isolée** (pas d'exposition publique)
- ✅ **Validation stricte** des inputs utilisateur

### ⚡ Performance
- ✅ **Images Docker optimisées** (multi-stage)
- ✅ **Cache applicatif** à plusieurs niveaux
- ✅ **Compression Gzip** et cache statique
- ✅ **Connection pooling** MySQL
- ✅ **OPcache PHP** activé
- ✅ **Bundle splitting** Next.js
- ✅ **Lazy loading** des composants

## 🛠️ Installation et déploiement

### Prérequis
- Docker & Docker Compose
- Git

### Déploiement rapide

```bash
# Cloner et aller dans le projet
git clone <votre-repo>
cd symfony-nextjs-docker-2

# Déploiement en développement
./deploy.sh dev deploy

# Déploiement en production
./deploy.sh prod deploy
```

### Commandes utiles

```bash
# Voir le statut des services
./deploy.sh dev status

# Voir les logs
./deploy.sh dev logs
./deploy.sh dev logs php  # Logs d'un service spécifique

# Redémarrer les services
./deploy.sh dev restart

# Sauvegarder la base de données
./deploy.sh dev backup

# Nettoyer les ressources
./deploy.sh dev cleanup
```

## 🔧 Configuration

### Variables d'environnement

Créez un fichier `.env` à la racine :

```env
# Environment
APP_ENV=dev
NODE_ENV=development

# Database
DB_HOST=mysql
DB_PORT=3306
DB_NAME=symfony
DB_USER=symfony
DB_PASSWORD=symfony
DB_ROOT_PASSWORD=root

# Symfony
APP_SECRET=your-32-character-secret-key

# Cache
REDIS_URL=redis://redis:6379

# Optional: Mailer
MAILER_DSN=smtp://localhost
```

### Fichiers de configuration

- `docker-compose.yml` : Configuration développement
- `docker-compose.optimized.yml` : Configuration production
- `docker/nginx/nginx.conf` : Configuration Nginx optimisée
- `docker/php/php.ini` : Configuration PHP optimisée
- `docker/mysql/my.cnf` : Configuration MySQL optimisée

## 📊 Performance

### Métriques cibles
- **Time to First Byte (TTFB)** : < 200ms
- **First Contentful Paint** : < 1.5s
- **API Response Time** : < 100ms
- **Cache Hit Ratio** : > 90%

### Optimisations activées
- ✅ OPcache PHP
- ✅ Nginx cache et compression
- ✅ Redis pour cache et sessions
- ✅ Images optimisées (WebP, AVIF)
- ✅ Lazy loading des composants
- ✅ Code splitting automatique
- ✅ API caching avec TTL

## 🔍 Monitoring et debugging

### Health checks
```bash
# Vérifier la santé des services
curl http://localhost/health
curl http://localhost:3000/api/health

# Status des conteneurs
docker compose ps
```

### Logs
```bash
# Logs en temps réel
docker compose logs -f

# Logs PHP
docker compose logs php

# Logs Nginx
docker compose logs nginx

# Logs base de données
docker compose logs mysql
```

### Métriques
- **Utilisation mémoire** : `docker stats`
- **Espace disque** : `docker system df`
- **Performance MySQL** : Logs slow query activés

## 🚀 Mise en production

### Checklist production

- [ ] Variables d'environnement configurées
- [ ] APP_ENV=prod et NODE_ENV=production
- [ ] Secrets sécurisés (APP_SECRET, mots de passe)
- [ ] HTTPS configuré
- [ ] Backups automatisés
- [ ] Monitoring configuré
- [ ] Logs centralisés

### Optimisations production

```bash
# Build optimisé
./deploy.sh prod deploy

# Configuration spécifique production
- OPcache validate_timestamps=0
- Next.js output standalone
- MySQL avec InnoDB optimisé
- Nginx avec cache agressif
- Redis pour sessions
```

## 🔧 Développement

### Structure du projet
```
├── backend/               # Application Symfony
│   ├── src/
│   ├── config/
│   └── public/
├── frontend/              # Application Next.js
│   ├── src/
│   ├── public/
│   └── styles/
├── docker/                # Configuration Docker
│   ├── nginx/
│   ├── php/
│   └── mysql/
└── docker-compose.yml
```

### Workflow de développement

1. **Développement local**
   ```bash
   ./deploy.sh dev deploy
   ```

2. **Tests**
   ```bash
   # Tests backend
   docker compose exec php php bin/phpunit
   
   # Tests frontend
   docker compose exec frontend npm test
   ```

3. **Hot reload**
   - Symfony : Modifications automatiquement prises en compte
   - Next.js : Hot reload activé en mode développement

## 📈 Évolutions futures

### Améliorations possibles
- [ ] Kubernetes pour l'orchestration
- [ ] CI/CD avec GitHub Actions
- [ ] Tests automatisés complets
- [ ] Monitoring avec Prometheus/Grafana
- [ ] Cache distribué avec Redis Cluster
- [ ] CDN pour les assets statiques

### Intégrations
- [ ] Elasticsearch pour la recherche
- [ ] Queue avec Symfony Messenger
- [ ] WebSockets pour le temps réel
- [ ] OAuth2 pour l'authentification

## 🆘 Dépannage

### Problèmes courants

**Services qui ne démarrent pas**
```bash
docker compose down
docker compose up -d
./deploy.sh dev health
```

**Problèmes de cache**
```bash
docker compose exec php php bin/console cache:clear
docker compose exec redis redis-cli FLUSHALL
```

**Base de données corrompue**
```bash
./deploy.sh dev backup
./deploy.sh dev restore backup_file.sql
```

## 📞 Support

Pour toute question ou problème :
1. Vérifiez les logs : `./deploy.sh dev logs`
2. Consultez le health check : `./deploy.sh dev health`
3. Consultez cette documentation
4. Ouvrez une issue sur le repository
#   i m a g e - d o c k e r - s y m f o n y - n e x t j s 
 
 