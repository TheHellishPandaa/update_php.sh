#!/bin/bash

echo "=== Actualización de PHP 7.4 a PHP 8.1 en Ubuntu ==="

# Paso 1: Agregar el repositorio de Ondřej Surý
echo "[1/6] Agregando repositorio de PHP..."
sudo apt update && sudo apt upgrade
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update

# Paso 2: Instalar PHP 8.1 y extensiones comunes
echo "[2/6] Instalando PHP 8.1 y extensiones..."
sudo apt install -y php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-curl php8.1-xml php8.1-mbstring php8.1-zip php8.1-bcmath php8.1-soap php8.1-intl

# Paso 3: Detectar servidor web
echo "[3/6] Detectando servidor web..."
if systemctl is-active --quiet apache2; then
    echo "Apache detectado. Configurando PHP 8.1 para Apache..."
    sudo a2dismod php7.4
    sudo a2enmod php8.1
    sudo update-alternatives --set php /usr/bin/php8.1
    sudo systemctl restart apache2
elif systemctl is-active --quiet nginx; then
    echo "Nginx detectado. Configurando PHP 8.1-FPM para Nginx..."
    if grep -q "php7.4-fpm.sock" /etc/nginx/sites-available/*; then
        echo "Actualizando sockets en configuración de Nginx..."
        sudo sed -i 's/php7.4-fpm.sock/php8.1-fpm.sock/g' /etc/nginx/sites-available/*
    fi
    sudo update-alternatives --set php /usr/bin/php8.1
    sudo systemctl restart php8.1-fpm
    sudo systemctl restart nginx
else
    echo "No se detectó Apache ni Nginx. Por favor, configura el servidor web manualmente."
fi

# Paso 4: Verificar la versión actual de PHP
echo "[4/6] Verificando versión actual de PHP..."
php -v

echo "[5/6] Limpiando paquetes obsoletos"
sudo apt autoremove -y

echo "[6/6] PHP 8.1 instalado y configurado correctamente "
php -v
