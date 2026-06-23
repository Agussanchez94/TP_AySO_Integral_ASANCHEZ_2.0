#!/bin/bash

echo "=== Configurando LVM ==="

# Detectar discos
DISCO_5G=$(lsblk -d -n -o NAME,SIZE | grep "5G" | awk '{print "/dev/" $1}' | head -1)
DISCO_3G=$(lsblk -d -n -o NAME,SIZE | grep "3G" | awk '{print "/dev/" $1}' | head -1)

echo "Disco 5G: $DISCO_5G"
echo "Disco 3G: $DISCO_3G"

# ===== VG_DATOS (5G) =====
if ! sudo pvs ${DISCO_5G}1 &>/dev/null; then
    sudo pvcreate ${DISCO_5G}1
fi

if ! sudo vgs vg_datos &>/dev/null; then
    sudo vgcreate vg_datos ${DISCO_5G}1
fi

if ! sudo lvs vg_datos/lv_docker &>/dev/null; then
    sudo lvcreate -L 10M -n lv_docker vg_datos
fi

if ! sudo lvs vg_datos/lv_workareas &>/dev/null; then
    sudo lvcreate -L 2.5G -n lv_workareas vg_datos
fi

# Formatear
sudo mkfs.ext4 -F /dev/mapper/vg_datos-lv_docker 2>/dev/null || true
sudo mkfs.ext4 -F /dev/mapper/vg_datos-lv_workareas 2>/dev/null || true

# Montar
sudo mkdir -p /var/lib/docker /work
sudo mount /dev/mapper/vg_datos-lv_docker /var/lib/docker 2>/dev/null || true
sudo mount /dev/mapper/vg_datos-lv_workareas /work 2>/dev/null || true

# ===== VG_TEMP (3G) =====
if ! sudo pvs ${DISCO_3G}1 &>/dev/null; then
    sudo pvcreate ${DISCO_3G}1
fi

if ! sudo vgs vg_temp &>/dev/null; then
    sudo vgcreate vg_temp ${DISCO_3G}1
fi

if ! sudo lvs vg_temp/lv_swap &>/dev/null; then
    sudo lvcreate -L 2.5G -n lv_swap vg_temp
fi

sudo mkswap -f /dev/mapper/vg_temp-lv_swap 2>/dev/null || true
sudo swapon /dev/mapper/vg_temp-lv_swap 2>/dev/null || true

# ===== FSTAB =====
sudo grep -q "lv_docker" /etc/fstab || sudo bash -c 'echo "/dev/mapper/vg_datos-lv_docker /var/lib/docker ext4 defaults 0 0" >> /etc/fstab'
sudo grep -q "lv_workareas" /etc/fstab || sudo bash -c 'echo "/dev/mapper/vg_datos-lv_workareas /work ext4 defaults 0 0" >> /etc/fstab'
sudo grep -q "lv_swap" /etc/fstab || sudo bash -c 'echo "/dev/mapper/vg_temp-lv_swap none swap sw 0 0" >> /etc/fstab'

echo "=== LVM configurado ==="
