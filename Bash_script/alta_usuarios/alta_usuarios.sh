#!/bin/bash
clear

###############################
#
# Parametros:
#  - Lista de Usuarios a crear
#  - Usuario del cual se obtendra la clave
#
#  Tareas:
#  - Crear los usuarios segun la lista recibida en los grupos descriptos
#  - Los usuarios deberan de tener la misma clave que la del usuario pasado por parametro

###############################

LISTA=$1
USER=$2

ANT_IFS=$IFS
IFS=$'\n'
for LINEA in `cat $LISTA |  grep -v ^#`
do
	USUARIO=$(echo  $LINEA |awk -F ',' '{print $1}')
	GRUPO=$(echo  $LINEA |awk -F ',' '{print $2}')
	HOME_DIR=$(echo  $LINEA |awk -F ',' '{print $3}')
	sudo groupadd -f $GRUPO
	sudo useradd -m -b /work -s /bin/bash -g $GRUPO $USUARIO -p $(sudo cat /etc/shadow | grep "^$USER:" | awk -F ':' '{print $2}') #############=="^$USER:" -> "exactamente igual a" ^xx:
done
IFS=$ANT_IFS

