#!/bin/bash

# Script de déploiement et maintenance optimisé
# Usage: ./deploy.sh [dev|prod|test] [action]

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
ENV=${1:-dev}
ACTION=${2:-deploy}

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Fonction pour vérifier les prérequis
check_requirements() {
    log "Checking requirements..."
    
    command -v docker >/dev/null 2>&1 || { error "Docker is required but not installed."; exit 1; }
    command -v docker-compose >/dev/null 2>&1 || command -v docker compose >/dev/null 2>&1 || { error "Docker Compose is required but not installed."; exit 1; }
    
    log "✅ All requirements met"
}

# Fonction pour configurer l'environnement
setup_env() {
    log "Setting up environment: $ENV"
    
    # Créer le fichier .env si il n'existe pas
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env" 2>/dev/null || {
            warn ".env.example not found, creating basic .env"
            cat > "$PROJECT_DIR/.env" << EOF
# Environment
APP_ENV=$ENV
NODE_ENV=$ENV

# Database
DB_HOST=mysql
DB_PORT=3306
DB_NAME=symfony
DB_USER=symfony
DB_PASSWORD=symfony
DB_ROOT_PASSWORD=root

# Symfony
APP_SECRET=$(openssl rand -hex 16)

# Cache
REDIS_URL=redis://redis:6379
EOF
        }
    fi
    
    # Ajuster la configuration selon l'environnement
    case $ENV in
        prod)
            sed -i 's/APP_ENV=.*/APP_ENV=prod/' "$PROJECT_DIR/.env"
            sed -i 's/NODE_ENV=.*/NODE_ENV=production/' "$PROJECT_DIR/.env"
            ;;
        dev)
            sed -i 's/APP_ENV=.*/APP_ENV=dev/' "$PROJECT_DIR/.env"
            sed -i 's/NODE_ENV=.*/NODE_ENV=development/' "$PROJECT_DIR/.env"
            ;;
        test)
            sed -i 's/APP_ENV=.*/APP_ENV=test/' "$PROJECT_DIR/.env"
            sed -i 's/NODE_ENV=.*/NODE_ENV=test/' "$PROJECT_DIR/.env"
            ;;
    esac
    
    log "✅ Environment configured for $ENV"
}

# Fonction pour construire les images
build_images() {
    log "Building Docker images for $ENV..."
    
    if [ "$ENV" = "prod" ]; then
        docker compose -f docker-compose.optimized.yml build --no-cache
    else
        docker compose build --no-cache
    fi
    
    log "✅ Images built successfully"
}

# Fonction pour démarrer les services
start_services() {
    log "Starting services for $ENV..."
    
    if [ "$ENV" = "prod" ]; then
        docker compose -f docker-compose.optimized.yml up -d
    else
        docker compose up -d
    fi
    
    # Attendre que les services soient prêts
    log "Waiting for services to be ready..."
    sleep 30
    
    # Vérifier la santé des services
    check_health
    
    log "✅ Services started successfully"
}

# Fonction pour vérifier la santé des services
check_health() {
    log "Checking service health..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker compose ps | grep -q "healthy"; then
            log "✅ Services are healthy"
            return 0
        fi
        
        info "Health check attempt $attempt/$max_attempts..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    error "Services failed health check"
    docker compose ps
    return 1
}

# Fonction pour arrêter les services
stop_services() {
    log "Stopping services..."
    
    docker compose down
    
    log "✅ Services stopped"
}

# Fonction pour nettoyer les ressources
cleanup() {
    log "Cleaning up resources..."
    
    # Arrêter et supprimer les conteneurs
    docker compose down -v --remove-orphans
    
    # Nettoyer les images non utilisées (optionnel)
    if [ "$1" = "full" ]; then
        docker system prune -f
        docker volume prune -f
    fi
    
    log "✅ Cleanup completed"
}

# Fonction pour sauvegarder la base de données
backup_database() {
    log "Creating database backup..."
    
    local backup_dir="$PROJECT_DIR/backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$backup_dir/backup_${timestamp}.sql"
    
    mkdir -p "$backup_dir"
    
    docker compose exec mysql mysqldump -u root -p"${DB_ROOT_PASSWORD:-root}" "${DB_NAME:-symfony}" > "$backup_file"
    
    log "✅ Database backup created: $backup_file"
}

# Fonction pour restaurer la base de données
restore_database() {
    local backup_file="$1"
    
    if [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
        exit 1
    fi
    
    log "Restoring database from: $backup_file"
    
    docker compose exec -T mysql mysql -u root -p"${DB_ROOT_PASSWORD:-root}" "${DB_NAME:-symfony}" < "$backup_file"
    
    log "✅ Database restored successfully"
}

# Fonction pour afficher les logs
show_logs() {
    local service=${1:-}
    
    if [ -n "$service" ]; then
        docker compose logs -f "$service"
    else
        docker compose logs -f
    fi
}

# Fonction pour afficher le statut
show_status() {
    log "Service Status:"
    docker compose ps
    
    log "\nResource Usage:"
    docker stats --no-stream
    
    log "\nDisk Usage:"
    docker system df
}

# Fonction principale
main() {
    case $ACTION in
        deploy)
            check_requirements
            setup_env
            build_images
            start_services
            ;;
        start)
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            stop_services
            start_services
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs "$3"
            ;;
        backup)
            backup_database
            ;;
        restore)
            restore_database "$3"
            ;;
        cleanup)
            cleanup "${3:-normal}"
            ;;
        health)
            check_health
            ;;
        *)
            echo "Usage: $0 [dev|prod|test] [deploy|start|stop|restart|status|logs|backup|restore|cleanup|health]"
            echo ""
            echo "Actions:"
            echo "  deploy   - Full deployment (build + start)"
            echo "  start    - Start services"
            echo "  stop     - Stop services"
            echo "  restart  - Restart services"
            echo "  status   - Show status and resource usage"
            echo "  logs     - Show logs (optionally for specific service)"
            echo "  backup   - Create database backup"
            echo "  restore  - Restore database from backup"
            echo "  cleanup  - Clean up resources (add 'full' for complete cleanup)"
            echo "  health   - Check service health"
            exit 1
            ;;
    esac
}

# Exécuter la fonction principale
main "$@"
