#!/bin/bash
set -euo pipefail

echo "🚀 Starting optimized PHP container setup..."

# Variables d'environnement avec valeurs par défaut
DB_HOST=${DB_HOST:-mysql}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-symfony}
APP_ENV=${APP_ENV:-dev}
MAX_RETRIES=${MAX_RETRIES:-30}

# Fonction pour attendre MySQL avec timeout amélioré
wait_for_mysql() {
    echo "⏳ Waiting for MySQL ($DB_HOST:$DB_PORT)..."
    
    local retry_count=0
    while ! nc -z "$DB_HOST" "$DB_PORT"; do
        retry_count=$((retry_count + 1))
        
        if [ $retry_count -ge $MAX_RETRIES ]; then
            echo "❌ MySQL connection timeout after $MAX_RETRIES attempts"
            exit 1
        fi
        
        echo "🔄 MySQL unavailable, retrying ($retry_count/$MAX_RETRIES)..."
        sleep 2
    done
    
    echo "✅ MySQL is ready!"
}

# Fonction pour installer/mettre à jour les dépendances
setup_dependencies() {
    echo "📦 Setting up dependencies..."
    
    if [ ! -f composer.json ]; then
        echo "🆕 Creating new Symfony project..."
        composer create-project symfony/skeleton . --no-interaction --prefer-dist
        composer require webapp doctrine/orm doctrine/doctrine-bundle doctrine/doctrine-migrations-bundle --no-interaction
        echo "✅ Symfony project created successfully"
    else
        echo "🔄 Installing/updating dependencies..."
        if [ "$APP_ENV" = "prod" ]; then
            composer install --no-dev --optimize-autoloader --no-interaction --no-ansi
        else
            composer install --optimize-autoloader --no-interaction
        fi
        echo "✅ Dependencies installed"
    fi
}

# Fonction pour configurer les permissions
setup_permissions() {
    echo "🔐 Setting up permissions..."
    
    # Créer les répertoires nécessaires
    mkdir -p var/{cache,log} public/uploads
    
    # Créer les fichiers de log s'ils n'existent pas
    touch var/log/{dev,prod,test}.log 2>/dev/null || true
    
    # Permissions optimisées
    if [ "$APP_ENV" = "prod" ]; then
        # En production, permissions restrictives
        chown -R www-data:www-data .
        chmod -R 750 .
        chmod -R 770 var public/uploads
    else
        # En développement, permissions plus souples
        chown -R www-data:www-data .
        chmod -R 775 .
        chmod -R 777 var public/uploads
    fi
    
    echo "✅ Permissions configured"
}

# Fonction pour configurer la base de données
setup_database() {
    echo "🗄️ Setting up database..."
    
    # Attendre que MySQL soit complètement prêt
    sleep 2
    
    # Créer la base de données
    if php bin/console doctrine:database:create --if-not-exists --no-interaction 2>/dev/null; then
        echo "✅ Database created or already exists"
    else
        echo "⚠️ Database creation failed, continuing..."
    fi
    
    # Exécuter les migrations
    if php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration 2>/dev/null; then
        echo "✅ Migrations executed successfully"
    else
        echo "⚠️ Migration failed, continuing..."
    fi
}

# Fonction pour optimiser le cache
setup_cache() {
    echo "🚀 Setting up cache..."
    
    if [ "$APP_ENV" = "prod" ]; then
        # En production, warmup du cache
        php bin/console cache:clear --env=prod --no-debug --no-warmup
        php bin/console cache:warmup --env=prod --no-debug
        echo "✅ Production cache warmed up"
    else
        # En développement, clear simple
        php bin/console cache:clear --no-warmup
        echo "✅ Development cache cleared"
    fi
}

# Fonction pour vérifier PHP-FPM
check_php_fpm() {
    echo "🔧 Checking PHP-FPM configuration..."
    
    if php-fpm -t; then
        echo "✅ PHP-FPM configuration is valid"
    else
        echo "❌ PHP-FPM configuration test failed!"
        exit 1
    fi
    
    # Nettoyer les anciens sockets
    rm -f /var/run/php-fpm.sock
}

# Fonction pour afficher les informations système
show_system_info() {
    echo "📊 System Information:"
    echo "   • PHP Version: $(php -v | head -n1)"
    echo "   • Environment: $APP_ENV"
    echo "   • Memory Limit: $(php -r 'echo ini_get("memory_limit");')"
    echo "   • OPcache Status: $(php -r 'echo extension_loaded("opcache") ? "Enabled" : "Disabled";')"
    echo "   • Database: $DB_HOST:$DB_PORT/$DB_NAME"
}

# Exécution principale
main() {
    wait_for_mysql
    setup_dependencies
    setup_permissions
    setup_database
    setup_cache
    check_php_fpm
    show_system_info
    
    echo "🎉 Container initialization completed successfully!"
    echo "🚀 Starting PHP-FPM daemon..."
    
    # Démarrer PHP-FPM en mode foreground
    exec php-fpm -F --nodaemonize
}

# Gestion des signaux pour un arrêt propre
trap 'echo "🛑 Received signal, shutting down..."; exit 0' SIGTERM SIGINT

# Exécuter la fonction principale
main "$@"
