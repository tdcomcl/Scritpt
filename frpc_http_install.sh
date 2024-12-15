#!/bin/bash

# Colores para los mensajes
VERDE='\033[0;32m'
ROJO='\033[0;31m'
NC='\033[0m' # No Color

# Preguntar al usuario el token de GitHub (se oculta la entrada)
read -s -p "Por favor, introduce tu token de acceso personal de GitHub: " GITHUB_TOKEN
echo ""  # Nueva línea después de la entrada oculta

# Verificar si el token no está vacío
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo -e "${ROJO}Error: El token no puede estar vacío.${NC}"
    exit 1
fi

# Configura la URL del repositorio y el archivo a descargar
REPO_URL="https://raw.githubusercontent.com/tdcomcl/RepoPrivadado/refs/heads/main/"
ARCHIVOS=("Frps_domaind.py")
chmod +x Frps_domaind.py

echo -e "${VERDE}Descargando archivos desde el repositorio...${NC}"
for ARCHIVO in "${ARCHIVOS[@]}"; do
    curl -H "Authorization: token $GITHUB_TOKEN" -L "$REPO_URL/$ARCHIVO" -o "$ARCHIVO"
    if [[ $? -ne 0 || ! -s "$ARCHIVO" ]]; then
        echo -e "${ROJO}Error descargando o archivo vacío: $ARCHIVO${NC}"
        exit 1
    else
        echo -e "${VERDE}Archivo descargado: $ARCHIVO${NC}"
    fi
done

# Verificar si Python 3 está instalado
if ! command -v python3 &> /dev/null; then
    echo -e "${ROJO}Python 3 no está instalado. Instalándolo...${NC}"
    sudo apt-get update
    sudo apt-get install -y python3
fi

# Detectar si está disponible pip o pip3
if command -v pip3 &> /dev/null; then
    PIP="pip3"
elif command -v pip &> /dev/null; then
    PIP="pip"
else
    echo -e "${ROJO}pip no está instalado. Instalándolo...${NC}"
    sudo apt-get update
    sudo apt-get install -y python3-pip
    PIP="pip3"
fi

echo -e "${VERDE}Usando: $PIP${NC}"

# Crear archivo requirements.txt con las dependencias necesarias
echo -e "${VERDE}Creando archivo requirements.txt...${NC}"
cat <<EOL > requirements.txt
requests>=2.31.0
EOL

# Instalar dependencias del archivo requirements.txt con --break-system-packages
echo -e "${VERDE}Instalando dependencias...${NC}"
$PIP install --break-system-packages -r requirements.txt || {
    echo -e "${ROJO}Error instalando las dependencias${NC}"
    exit 1
}

# Verificar módulos estándar de Python
echo -e "${VERDE}Verificando módulos estándar...${NC}"
STANDARD_MODULES=("subprocess" "platform" "os" "sys" "time" "signal" "random" "string")
for MODULE in "${STANDARD_MODULES[@]}"; do
    python3 -c "import $MODULE" || {
        echo -e "${ROJO}Error: Módulo estándar $MODULE no está disponible.${NC}"
        exit 1
    }
done

# Dar permisos de ejecución a los scripts descargados
for ARCHIVO in "${ARCHIVOS[@]}"; do
    chmod +x "$ARCHIVO"
    echo -e "${VERDE}Permisos otorgados: $ARCHIVO${NC}"
done

# Ejecutar script principal
echo -e "${VERDE}Ejecutando el script principal...${NC}"
python3 script_dns_frpc.py || {
    echo -e "${ROJO}Error al ejecutar script_dns_frpc.py${NC}"
    exit 1
}

echo -e "${VERDE}¡Proceso completado con éxito!${NC}"