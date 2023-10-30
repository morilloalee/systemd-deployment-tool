#!/bin/bash

# Directorios de slots
SLOT_ACTIVO="/home/slot1/"
SLOT_INACTIVO="/home/slot2/"

# Variables
SERVICIO1="Levantar-web.service"
SERVICIO2="Levantar-web2.service"
COMANDO_INICIAR1="systemctl start $SERVICIO1"
COMANDO_DETENER1="systemctl stop $SERVICIO1"
COMANDO_INICIAR2="systemctl start $SERVICIO2"
COMANDO_DETENER2="systemctl stop $SERVICIO2"

# Función para realizar el deploy
deploy_service() {
    # Detener el servicio en el slot activo
    echo "Deteniendo el servicio..."
    $COMANDO_DETENER1

    # Eliminar el contenido del slot inactivo
    echo "Limpiando el slot inactivo..."
    rm -rf $SLOT_INACTIVO/*

    # Copiar los archivos de la nueva versión al slot inactivo
    echo "Copiando la nueva versión al slot inactivo..."
    cp -r /home/update/* $SLOT_INACTIVO/

    # Iniciar el servicio en el slot inactivo
    echo "Iniciando el servicio en el slot inactivo..."
    $COMANDO_INICIAR2

    # Comprobar si el nuevo servicio está funcionando
    sleep 5  # Espera un tiempo para que el servicio arranque
    if systemctl is-active --quiet $SERVICIO2; then
        echo "Deploy exitoso en el slot inactivo."
        
    else
        echo "Error: El nuevo servicio no se inició correctamente."
        echo "Revertir el deploy..."
        # Detener el servicio en el slot inactivo
        $COMANDO_DETENER2

        # Copiar los archivos del slot activo al slot inactivo para restaurar la versión original
        echo "Restaurando la versión original del servicio..."
        

        # Iniciar el servicio original en el slot activo
        $COMANDO_INICIAR1

        echo "Revertido con éxito al slot original."
    fi
}

# Llamada a la función para realizar el deploy
deploy_service
