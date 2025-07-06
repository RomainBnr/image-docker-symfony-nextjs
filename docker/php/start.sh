#!/bin/bash
set -e

echo "Starting PHP container setup..."

# Attendre que MySQL soit prêt
echo "Waiting for MySQL..."
until nc -z mysql 3306; do
    echo "MySQL is unavailable - sleeping"
    sleep 2
done
echo "MySQL is up - executing command"

# Si le projet Symfony n'existe pas, le créer
if [ ! -f composer.json ]; then
    echo "Creating Symfony project..."
    composer create-project symfony/skeleton . --no-interaction
    composer require webapp doctrine/orm doctrine/doctrine-bundle doctrine/doctrine-migrations-bundle --no-interaction
    echo "Symfony project created successfully"
else
    echo "Symfony project exists, installing dependencies..."
    composer install --no-interaction --optimize-autoloader
fi

# Configuration des permissions
echo "Setting up permissions..."
mkdir -p var/cache var/log public
echo "Directories created successfully"

# Créer les fichiers nécessaires s'ils n'existent pas
touch var/log/dev.log 2>/dev/null || true
touch var/log/prod.log 2>/dev/null || true

chown -R www-data:www-data .
echo "Ownership changed to www-data"

chmod -R 775 .
echo "Permissions set to 775"

chmod -R 777 var
echo "Var directory permissions set to 777"

# Configuration de la base de données avec plus de debug
echo "Setting up database..."
echo "Creating database if not exists..."
if php bin/console doctrine:database:create --if-not-exists --no-interaction; then
    echo "Database created or already exists"
else
    echo "Database creation failed, continuing..."
fi

echo "Running migrations..."
if php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration; then
    echo "Migrations completed successfully"
else
    echo "Migration failed, continuing..."
fi

# Vérifier que PHP-FPM peut démarrer
echo "Testing PHP-FPM configuration..."
if php-fpm -t; then
    echo "PHP-FPM configuration is valid"
else
    echo "PHP-FPM configuration test failed!"
    exit 1
fi

# Nettoyer les anciens sockets si ils existent
rm -f /var/run/php-fpm.sock

echo "PHP-FPM configuration OK, starting PHP-FPM daemon..."
echo "Container initialization completed successfully!"

# Démarrer PHP-FPM en mode foreground
exec php-fpm -F --nodaemonize
