#!/bin/bash

# Script de test pour vérifier l'état des containers
echo "=== État des containers ==="
docker compose ps

echo ""
echo "=== Logs des containers ==="
echo "--- Logs MySQL ---"
docker compose logs mysql --tail=10

echo ""
echo "--- Logs PHP ---"
docker compose logs php --tail=20

echo ""
echo "--- Logs Nginx ---"
docker compose logs nginx --tail=10

echo ""
echo "=== Test de connectivité ==="
echo "Test connexion à MySQL depuis PHP container:"
docker compose exec php nc -z mysql 3306 && echo "MySQL accessible" || echo "MySQL inaccessible"

echo ""
echo "Test PHP-FPM dans le container:"
docker compose exec php pgrep php-fpm && echo "PHP-FPM en cours d'exécution" || echo "PHP-FPM non trouvé"

echo ""
echo "Test des processus dans le container PHP:"
docker compose exec php ps aux | grep php
