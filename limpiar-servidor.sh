#!/bin/bash

echo "==============================="
echo " 🧹 Limpieza de servidor AWS"
echo "==============================="

# 1. Limpiar cache de memoria
echo "[1/7] Limpiando cache de memoria..."
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

# 2. Limpiar paquetes temporales
echo "[2/7] Eliminando paquetes innecesarios..."
sudo apt-get clean -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# 3. Limpiar logs grandes
echo "[3/7] Limpiando logs..."
sudo truncate -s 0 /var/log/syslog
sudo truncate -s 0 /var/log/auth.log
sudo truncate -s 0 /var/log/kern.log

# 4. Limpiar Nginx cache (si existe)
if [ -d "/var/cache/nginx" ]; then
  echo "[4/7] Limpiando cache de Nginx..."
  sudo rm -rf /var/cache/nginx/*
  sudo systemctl restart nginx
fi

# 5. Reiniciar Apache si está en uso
if systemctl is-active --quiet apache2; then
  echo "[5/7] Reiniciando Apache..."
  sudo systemctl restart apache2
fi

# 6. Limpiar PM2 logs (si usás Node.js con PM2)
if command -v pm2 &> /dev/null; then
  echo "[6/7] Flusheando logs de PM2..."
  pm2 flush
  pm2 restart all
fi

# 7. Limpiar Docker (si está instalado)
if command -v docker &> /dev/null; then
  echo "[7/7] Limpiando Docker..."
  docker system prune -af --volumes
fi

echo "==============================="
echo " ✅ Limpieza completada"
echo "==============================="
