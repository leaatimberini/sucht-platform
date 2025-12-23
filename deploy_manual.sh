#!/bin/bash
set -e

echo ">>> Deteniendo procesos antiguos..."
pm2 stop all || true
pm2 delete all || true

echo ">>> Desplegando Backend..."
cd /var/www/sucht/backend
sudo rm -rf dist
sudo npm run build
sudo chown -R ubuntu:ubuntu .
pm2 start dist/main.js --name sucht-backend
pm2 restart sucht-backend

echo ">>> Desplegando Frontend..."
cd /var/www/sucht/frontend
sudo rm -rf .next
sudo npm run build
sudo chown -R ubuntu:ubuntu .
sudo chown -R www-data:www-data .next
sudo chmod -R 775 .next
pm2 start npm --name sucht-frontend -- start -- -p 3000

echo ">>> Guardando PM2..."
pm2 save

echo ">>> ¡Despliegue finalizado!"
pm2 status
