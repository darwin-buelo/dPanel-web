#!/bin/bash

# dPanel Installation Script
# This script automates the setup of the dPanel application on a fresh Debian/Ubuntu server.
# It installs necessary dependencies, clones the application, and configures Nginx.
#
# USAGE:
# 1. Make the script executable: chmod +x install.sh
# 2. Run with sudo: sudo ./install.sh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# !!! IMPORTANT: Change this to your actual private or public repository URL !!!
REPO_URL="https://github.com/username/repository.git"
PROJECT_DIR="/www/dpanel"
NGINX_PORT="3245"
PHP_VERSION="8.4"
NODE_VERSION="24"
NGINX_CONFIG_PATH="/etc/nginx/sites-available/dpanel"

# --- Helper Functions ---
function command_exists() {
    command -v "$@" >/dev/null 2>&1
}

function silent() {
    "$@" > /dev/null 2>&1
}

function rollback() {
    echo ""
    echo "!!! An error occurred. Rolling back changes..."

    if [ -d "$PROJECT_DIR" ]; then
        echo "Removing project directory..."
        rm -rf "$PROJECT_DIR"
    fi

    if [ -f "$NGINX_CONFIG_PATH" ]; then
        echo "Removing Nginx configuration..."
        rm -f "$NGINX_CONFIG_PATH"
    fi

    if [ -L "/etc/nginx/sites-enabled/dpanel" ]; then
        rm -f "/etc/nginx/sites-enabled/dpanel"
    fi

    echo "Rollback complete."
    exit 1
}

trap 'rollback' ERR

echo "--- dPanel Installation Script ---"

# --- 1. Dependency Installation ---
echo ">>> Step 1: Installing dependencies..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Update package lists and install prerequisite tools
silent apt-get update
silent apt-get install -y ca-certificates apt-transport-https software-properties-common curl

# Install Nginx, Git, and Unzip
silent apt-get install -y nginx git unzip

# Install Node.js and npm (using NodeSource for a recent version)
if ! command_exists node; then
    echo "Installing Node.js v${NODE_VERSION} and npm..."
    silent bash -c "curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -"
    silent apt-get install -y nodejs
else
    echo "Node.js is already installed."
fi

# Install PHP and required extensions using the ondrej/php PPA
echo "Installing PHP ${PHP_VERSION} and required extensions..."
silent add-apt-repository ppa:ondrej/php -y
silent apt-get update
silent apt-get install -y php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-mysql php${PHP_VERSION}-curl php${PHP_VERSION}-zip php${PHP_VERSION}-gd php${PHP_VERSION}-bcmath

# Install Composer
if ! command_exists composer; then
    echo "Installing Composer..."
    silent curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
    silent php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm /tmp/composer-setup.php
else
    echo "Composer is already installed."
fi

echo ">>> Dependency installation complete."

# --- 2. Create Project Directory ---
echo ">>> Step 2: Setting up project directory..."
mkdir -p "$PROJECT_DIR"
echo "Created directory ${PROJECT_DIR}."

# --- 3. Clone Repository and Install Application ---
echo ">>> Step 3: Cloning repository and installing application..."

echo "Cloning from ${REPO_URL}..."
silent git clone "$REPO_URL" "$PROJECT_DIR"

cd "$PROJECT_DIR"

echo "Installing Composer dependencies..."
silent composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

echo "Setting up .env file..."
cp .env.example .env

echo "Generating application key..."
silent php artisan key:generate

echo "Setting up storage and cache permissions..."
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

echo "Installing NPM dependencies and building assets..."
silent npm install
silent npm run build

echo ">>> Application setup complete."

# --- 4. Configure Nginx ---
echo ">>> Step 4: Configuring Nginx..."

echo "Creating Nginx server block configuration..."
cat > "$NGINX_CONFIG_PATH" <<EOF
server {
    listen ${NGINX_PORT};
    server_name _;
    root ${PROJECT_DIR}/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

ln -sf "$NGINX_CONFIG_PATH" /etc/nginx/sites-enabled/

echo "Testing Nginx configuration and restarting service..."
silent nginx -t
silent systemctl restart nginx

echo "--- Installation Complete! ---"
echo "dPanel should now be accessible at http://<your-server-ip>:${NGINX_PORT}"