#!/bin/bash
echo "script ssh keygen"

# Detectar el gestor de paquetes
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt-get install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
else
    echo "Gestor de paquetes no soportado"
    exit 1
fi

# Instalar sshpass si no está
if ! command -v sshpass &> /dev/null; then
    echo "Instalando sshpass..."
    $INSTALL_CMD sshpass
fi

# Generar claves SSH si no existen
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generando claves SSH..."
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""
    
echo "copia"
fi

# Agregar hosts a known_hosts
echo "Agregando hosts a known_hosts..."
ssh-keyscan -H testing >> ~/.ssh/known_hosts 2>/dev/null
ssh-keyscan -H produccion >> ~/.ssh/known_hosts 2>/dev/null

# Copiar clave pública a la otra VM
echo "Copiando claves SSH..."
sshpass -p "vagrant" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no vagrant@testing 2>/dev/null || echo "Ya existe conexión a testing"
sshpass -p "vagrant" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no vagrant@produccion 2>/dev/null || echo "Ya existe conexión a produccion"

echo "SSH cruzado configurado"
