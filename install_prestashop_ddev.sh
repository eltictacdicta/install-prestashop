#!/bin/bash

# Script para instalar PrestaShop en DDEV
# Basado en: https://misterdigital.es/instalar-prestashop-en-ddev/

set -e  # Salir si hay algún error

# Colores para los mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# Función para mostrar mensajes con colores
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[ÉXITO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuración por defecto
PROJECT_NAME="prestashop-project"
PRESTASHOP_VERSION="8.2.1"
PHP_VERSION="8.1"
ADMIN_EMAIL="admin@example.com"
ADMIN_PASSWORD="admin123"
LANGUAGE="es"
TIMEZONE="Europe/Madrid"
SSL_ENABLED="1"

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  -n, --name NAME          Nombre del proyecto (por defecto: $PROJECT_NAME)"
    echo "  -v, --version VERSION    Versión de PrestaShop (por defecto: $PRESTASHOP_VERSION)"
    echo "  -p, --php-version VER    Versión de PHP (por defecto: $PHP_VERSION)"
    echo "  -e, --email EMAIL        Email del administrador (por defecto: $ADMIN_EMAIL)"
    echo "  -w, --password PASS      Contraseña del administrador (por defecto: $ADMIN_PASSWORD)"
    echo "  -l, --language LANG      Idioma (por defecto: $LANGUAGE)"
    echo "  -t, --timezone TZ        Zona horaria (por defecto: $TIMEZONE)"
    echo "  --no-ssl                 Deshabilitar SSL"
    echo "  --install-phpmyadmin     Instalar PHPMyAdmin"
    echo "  -h, --help               Mostrar esta ayuda"
    echo ""
    echo "Ejemplo:"
    echo "  $0 -n mi-tienda -e admin@mitienda.com -w mipassword123"
}

# Parsear argumentos de línea de comandos
INSTALL_PHPMYADMIN=0

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -v|--version)
            PRESTASHOP_VERSION="$2"
            shift 2
            ;;
        -p|--php-version)
            PHP_VERSION="$2"
            shift 2
            ;;
        -e|--email)
            ADMIN_EMAIL="$2"
            shift 2
            ;;
        -w|--password)
            ADMIN_PASSWORD="$2"
            shift 2
            ;;
        -l|--language)
            LANGUAGE="$2"
            shift 2
            ;;
        -t|--timezone)
            TIMEZONE="$2"
            shift 2
            ;;
        --no-ssl)
            SSL_ENABLED="0"
            shift
            ;;
        --install-phpmyadmin)
            INSTALL_PHPMYADMIN=1
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Verificar que DDEV esté instalado
if ! command -v ddev &> /dev/null; then
    print_error "DDEV no está instalado. Por favor, instala DDEV primero."
    exit 1
fi

print_message "Iniciando instalación de PrestaShop $PRESTASHOP_VERSION en DDEV"
print_message "Nombre del proyecto: $PROJECT_NAME"
print_message "Versión de PHP: $PHP_VERSION"
print_message "Email de administrador: $ADMIN_EMAIL"

# Crear directorio del proyecto si no existe
if [ ! -d "$PROJECT_NAME" ]; then
    print_message "Creando directorio del proyecto: $PROJECT_NAME"
    mkdir "$PROJECT_NAME"
fi

cd "$PROJECT_NAME"

# Configurar DDEV
print_message "Configurando DDEV con PHP $PHP_VERSION y Apache FPM..."
ddev config --php-version="$PHP_VERSION" --webserver-type=apache-fpm --project-name="$PROJECT_NAME"

# Iniciar DDEV
print_message "Iniciando DDEV..."
ddev start

# Obtener información del proyecto
DOMAIN=$(ddev describe | grep "Primary URL" | awk '{print $3}' | sed 's|https\?://||')
if [ -z "$DOMAIN" ]; then
    DOMAIN="${PROJECT_NAME}.ddev.site"
fi

print_message "Dominio del proyecto: $DOMAIN"

# Descargar PrestaShop
print_message "Descargando PrestaShop $PRESTASHOP_VERSION..."
ddev exec wget "https://github.com/PrestaShop/PrestaShop/releases/download/$PRESTASHOP_VERSION/prestashop_$PRESTASHOP_VERSION.zip"

# Descomprimir primer archivo
print_message "Descomprimiendo archivo principal..."
ddev exec unzip "prestashop_$PRESTASHOP_VERSION.zip" -d ./

# Descomprimir PrestaShop
print_message "Descomprimiendo PrestaShop..."
ddev exec bash -c "echo 'y' | unzip prestashop.zip -d ./"

# Instalar PrestaShop desde línea de comandos
print_message "Instalando PrestaShop..."
ddev exec php ./install/index_cli.php \
    --domain="$DOMAIN" \
    --db_server=db \
    --db_name=db \
    --db_user=db \
    --db_password=db \
    --prefix=ps_ \
    --email="$ADMIN_EMAIL" \
    --password="$ADMIN_PASSWORD" \
    --ssl="$SSL_ENABLED" \
    --language="$LANGUAGE" \
    --timezone="$TIMEZONE"

# Limpiar archivos temporales
print_message "Limpiando archivos temporales..."
ddev exec rm -rf ./prestashop.zip ./prestashop_$PRESTASHOP_VERSION.zip ./install
# Instalar módulo de copias de seguridad si está disponible
print_message "Instalando módulo de copias de seguridad..."
ddev exec bash -c "cd modules && git clone https://github.com/eltictacdicta/ps_copia.git"

# Verificar si el módulo se clonó correctamente
if ddev exec test -d "./modules/ps_copia"; then
    print_message "Módulo ps_copia descargado correctamente. Instalando desde PrestaShop..."
    
    # Instalar el módulo usando el comando de PrestaShop
    ddev exec php bin/console prestashop:module install ps_copia
    
    if [ $? -eq 0 ]; then
        print_success "Módulo ps_copia instalado correctamente."
    else
        print_warning "No se pudo instalar automáticamente el módulo ps_copia. Podrás instalarlo manualmente desde el panel de administración."
    fi
else
    print_warning "No se pudo descargar el módulo ps_copia desde GitHub."
fi

# Instalar PHPMyAdmin si se solicita
if [ $INSTALL_PHPMYADMIN -eq 1 ]; then
    print_message "Instalando PHPMyAdmin..."
    ddev get ddev/ddev-phpmyadmin && ddev restart
fi

# Obtener URL de administración
ADMIN_URL=$(ddev exec find . -name "admin*" -type d | head -1)
if [ -n "$ADMIN_URL" ]; then
    ADMIN_URL=$(basename "$ADMIN_URL")
    FULL_ADMIN_URL="https://$DOMAIN/$ADMIN_URL"
else
    FULL_ADMIN_URL="https://$DOMAIN/admin"
fi

# Mostrar información final
print_success "¡Instalación completada con éxito!"
echo ""
print_message "=== INFORMACIÓN DE ACCESO ==="
print_message "URL del sitio: https://$DOMAIN"
print_message "URL de administración: $FULL_ADMIN_URL"
print_message "Email de administrador: $ADMIN_EMAIL"
print_message "Contraseña: $ADMIN_PASSWORD"

if [ $INSTALL_PHPMYADMIN -eq 1 ]; then
    print_message "PHPMyAdmin: https://$DOMAIN:8036"
fi

echo ""
print_warning "¡IMPORTANTE! Guarda la URL de administración ya que PrestaShop la cambia por seguridad."
print_message "Puedes ver la configuración de DDEV con: ddev describe"
print_message "Para detener el proyecto: ddev stop"
print_message "Para reiniciar el proyecto: ddev start"

print_success "¡Disfruta de tu nueva instalación de PrestaShop!" 