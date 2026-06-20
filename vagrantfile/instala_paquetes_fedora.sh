#!/bin/bash

echo "Actualizo la lista de paquetes"
sudo dnf update -y > /dev/null 2>&1

echo "Instalo paquetes necesarios"
sudo dnf install -y tree ansible curl htop tmux speedtest-cli lvm2 sshpass git wget net-tools > /dev/null 2>&1

#----- INSTALACION DE DOCKER SEGUN DOCUMENTACION OFICIAL -----#
# https://docs.docker.com/engine/install/fedora/

echo "Remuevo paquetes de docker previos"
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine podman 2>/dev/null

echo "Agrego repository de Docker"
sudo dnf -y install dnf-plugins-core > /dev/null 2>&1
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo > /dev/null 2>&1

echo "Instalo Docker"
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1

echo "Agrego grupo docker al usuario vagrant"
sudo usermod -a -G docker vagrant

echo "Habilito y starteo docker"
sudo systemctl enable --now docker > /dev/null 2>&1

echo "Instalación completada"
