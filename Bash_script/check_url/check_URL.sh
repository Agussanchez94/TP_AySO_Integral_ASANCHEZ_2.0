i#!/bin/bash
clear

###############################
#
# Parametros:
#  - Lista Dominios y URL
#
#  Tareas:
#  - Se debera generar la estructura de directorio pedida con 1 solo comando con las tecnicas enseñadas en clases
#  - Generar los archivos de logs requeridos.
#i
###############################
LISTA=$1

LOG_FILE="/var/log/status_url.log"

ANT_IFS=$IFS
IFS=$'\n'

for LINEA in `cat $LISTA|grep -v ^#`
do
#---- Dentro del bucle ----#
  # Obtener el código de estado HTTP
  URL=$(echo $LINEA | awk '{print $2}')
  STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}\n' -s "$URL")
  DOMINIO=$(echo $LINEA | awk '{print $1}')
  # Fecha y hora actual en formato yyyymmdd_hhmmss
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

 # Registrar en el archivo /var/log/status_url.log
  echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" |sudo tee -a  "$LOG_FILE"

case $STATUS_CODE in
        200)
                echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" | sudo tee -a /tmp/head-check/ok/$DOMINIO.log
                ;;
        4[0-9][0-9]|000)
            echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" | sudo tee -a /tmp/head-check/Error/cliente/$DOMINIO.log
	    echo"noexiste"
            ;;
    5[0-9][0-9])
            echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" | sudo tee -a /tmp/head-check/Error/servidor/$DOMINIO.log
            ;;
    esac


#-------------------------#
done
IFS=$ANT_IFS
