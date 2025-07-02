# Script de Instalación de PrestaShop en DDEV

Este script automatiza completamente la instalación de PrestaShop en un entorno de desarrollo DDEV, basado en la guía de [Mister Digital](https://misterdigital.es/instalar-prestashop-en-ddev/).

## Requisitos Previos

- **DDEV** instalado y funcionando en tu sistema
- **Bash** (disponible en Linux, macOS, y Windows con WSL o Git Bash)
- **Conexión a Internet** para descargar PrestaShop

## Instalación Rápida

### Uso Básico

```bash
# Descargar el script
wget https://raw.githubusercontent.com/eltictacdicta/install-prestashop/refs/heads/master/install_prestashop_ddev.sh
# Hacer el script ejecutable (solo la primera vez)
chmod +x install_prestashop_ddev.sh

# Ejecutar con configuración por defecto
./install_prestashop_ddev.sh
```

### Uso Personalizado

```bash
# Instalación personalizada
./install_prestashop_ddev.sh \
  --name mi-tienda \
  --email admin@mitienda.com \
  --password mipassword123 \
  --install-phpmyadmin
```

## Opciones Disponibles

| Opción | Descripción | Valor por defecto |
|--------|-------------|------------------|
| `-n, --name` | Nombre del proyecto | `prestashop-project` |
| `-v, --version` | Versión de PrestaShop | `8.2.1` |
| `-p, --php-version` | Versión de PHP | `8.1` |
| `-e, --email` | Email del administrador | `admin@example.com` |
| `-w, --password` | Contraseña del administrador | `admin123` |
| `-l, --language` | Idioma de instalación | `es` |
| `-t, --timezone` | Zona horaria | `Europe/Madrid` |
| `--no-ssl` | Deshabilitar SSL | SSL habilitado por defecto |
| `--install-phpmyadmin` | Instalar PHPMyAdmin | No instalado por defecto |
| `-h, --help` | Mostrar ayuda | - |

## Ejemplos de Uso

### Instalación Básica
```bash
./install_prestashop_ddev.sh
```

### Instalación con Nombre Personalizado
```bash
./install_prestashop_ddev.sh --name mi-ecommerce
```

### Instalación Completa con PHPMyAdmin
```bash
./install_prestashop_ddev.sh \
  --name mi-tienda-online \
  --email admin@midominio.com \
  --password segura123 \
  --install-phpmyadmin
```

### Instalación con Versión Específica
```bash
./install_prestashop_ddev.sh \
  --name prestashop-test \
  --version 8.1.7 \
  --php-version 8.0
```

## Qué Hace el Script

1. **Verificación**: Comprueba que DDEV esté instalado
2. **Configuración**: Crea y configura el proyecto DDEV con PHP 8.1 y Apache FPM
3. **Descarga**: Descarga la versión especificada de PrestaShop desde GitHub
4. **Descompresión**: Extrae los archivos de PrestaShop
5. **Instalación**: Ejecuta la instalación automática via línea de comandos
6. **Limpieza**: Elimina archivos temporales y la carpeta de instalación
7. **PHPMyAdmin** (opcional): Instala PHPMyAdmin si se solicita

## Información Post-Instalación

Después de la instalación exitosa, el script te proporcionará:

- **URL del sitio**: `https://nombre-proyecto.ddev.site`
- **URL de administración**: `https://nombre-proyecto.ddev.site/adminXXXXXX` (URL aleatoria por seguridad)
- **Credenciales de acceso**: Email y contraseña especificados
- **PHPMyAdmin** (si se instaló): `https://nombre-proyecto.ddev.site:8036`

## Comandos Útiles de DDEV

```bash
# Ver información del proyecto
ddev describe

# Iniciar el proyecto
ddev start

# Detener el proyecto
ddev stop

# Reiniciar el proyecto
ddev restart

# Ejecutar comandos en el contenedor
ddev exec [comando]

# Acceder al contenedor
ddev ssh
```

## Configuración de Base de Datos

El script configura automáticamente la conexión a la base de datos con estos parámetros:

- **Servidor**: `db`
- **Base de datos**: `db`
- **Usuario**: `db`
- **Contraseña**: `db`
- **Prefijo de tablas**: `ps_`

## Solución de Problemas

### Error: "DDEV no está instalado"
Instala DDEV siguiendo la [documentación oficial](https://ddev.readthedocs.io/en/stable/#installation).

### Error al descargar PrestaShop
Verifica tu conexión a Internet y que la versión especificada existe en GitHub.

### El sitio no carga
1. Verifica que DDEV esté funcionando: `ddev describe`
2. Reinicia el proyecto: `ddev restart`
3. Verifica los logs: `ddev logs`

### No puedo acceder al admin
La URL de administración cambia por seguridad. Busca la carpeta `admin` en tu proyecto:
```bash
ddev exec find . -name "admin*" -type d
```

## Características del Script

- ✅ **Instalación completamente automatizada**
- ✅ **Configuración optimizada para PrestaShop**
- ✅ **Mensajes informativos con colores**
- ✅ **Manejo de errores**
- ✅ **Opciones personalizables**
- ✅ **Instalación opcional de PHPMyAdmin**
- ✅ **Limpieza automática de archivos temporales**
- ✅ **Información completa post-instalación**

## Contribuciones

Si encuentras algún problema o tienes sugerencias de mejora, siéntete libre de crear un issue o pull request.

## Licencia

Este script está basado en la guía de [Mister Digital](https://misterdigital.es/instalar-prestashop-en-ddev/) y se distribuye bajo licencia MIT. 
