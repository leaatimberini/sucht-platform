#!/bin/bash

# =================================================================
# SCRIPT DE DESPLIEGUE AUTOMATIZADO PARA EL PROYECTO SUCHT (v4)
# =================================================================
#
# Este script realiza las siguientes acciones:
# 1. Se detiene inmediatamente si cualquier comando falla.
# 2. Corrige los permisos de la carpeta para el usuario actual.
# 3. Despliega el backend: actualiza Git, instala dependencias, compila y recrea el proceso.
# 4. Despliega el frontend: actualiza Git, limpia caché, instala dependencias, compila y recrea el proceso.
# 5. Guarda la configuración final de PM2.
#
# =================================================================

# Termina el script si cualquier comando falla
set -e

# --- 1. ESTABLECER PERMISOS ---
echo " "
echo ">>> [PASO 1/5] Estableciendo permisos de la carpeta del proyecto..."
# Cambia la propiedad al usuario 'ubuntu' (el que ejecuta el script) y al grupo 'www-data' (el del servidor web).
# Esto permite que el script modifique los archivos y que Nginx los pueda leer.
sudo chown -R ubuntu:www-data /var/www/sucht/
# Otorga permisos de lectura/escritura/ejecución al dueño y al grupo.
sudo chmod -R 775 /var/www/sucht/

# --- 2. DESPLEGAR BACKEND ---
echo " "
echo ">>> [PASO 2/5] Desplegando el Backend..."
cd /var/www/sucht/backend
echo "    - Actualizando código desde Git..."
sudo git pull origin main # O la rama que uses
echo "    - Instalando dependencias del backend (npm install)..."
sudo npm install
echo "    - Compilando el backend (npm run build)..."
sudo npm run build
echo "    - Recreando el proceso del backend con PM2..."
# IMPORTANTE: Usamos 'reload' para Zero-Downtime. Si el proceso no existe, fallara el reload y ejecutara el start.
pm2 reload sucht-api --update-env || pm2 start npm --name "sucht-api" -- run start:prod

# --- 3. DESPLEGAR FRONTEND ---
echo " "
echo ">>> [PASO 3/5] Desplegando el Frontend..."
cd /var/www/sucht/frontend
echo "    - Actualizando código desde Git..."
sudo git pull origin main # O la rama que uses
echo "    - Borrando caché anterior (.next)..."
sudo rm -rf .next
echo "    - Instalando dependencias del frontend (npm install)..."
sudo npm install
echo "    - Compilando el frontend para producción (npm run build)..."
sudo npm run build
echo "    - Recargando el proceso del frontend con PM2..."
# IMPORTANTE: Usamos 'reload' para Zero-Downtime
pm2 reload sucht-web --update-env || pm2 start npm --name "sucht-web" -- run start

# --- 4. GUARDAR PROCESOS PM2 ---
echo " "
echo ">>> [PASO 4/5] Guardando la lista de procesos de PM2..."
pm2 save

# --- 5. FINALIZACIÓN ---
echo " "
echo ">>> [PASO 5/5] ¡Despliegue completado con éxito!"
echo " "
pm2 status
