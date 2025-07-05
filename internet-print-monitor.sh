#!/bin/bash

NODE_SCRIPT="/opt/turnofacil.print/server.js"  # Ruta al archivo de tu script Node.js
NODE_BIN="/home/turno/.nvm/versions/node/v22.17.0/bin/node"         # Ruta al binario de Node.js
PID_FILE="/home/turno/node_script.pid"  # Archivo para almacenar el PID del proceso

# Función que verifica si hay internet
check_internet() {
    ping -q -c1 -W1 1.1.1.1 > /dev/null 2>&1
}

# Iniciar el script Node.js
start_node_script() {
    echo "[INFO] Internet detectado. Ejecutando script de Node.js."
    $NODE_BIN $NODE_SCRIPT &
    echo $! > "$PID_FILE"
}

# Detener el script Node.js si está corriendo
stop_node_script() {
    if [[ -f "$PID_FILE" ]]; then
        pid=$(cat "$PID_FILE")
        if ps -p $pid > /dev/null 2>&1; then
            echo "[WARN] Sin internet. Deteniendo script Node.js (PID $pid)."
            kill $pid
            rm -f "$PID_FILE"
        fi
    fi
}

# Monitorizar la conexión y el estado del script
while true; do
    if check_internet; then
        # Si hay internet y el script no está corriendo, iniciar el script
        if [[ ! -f "$PID_FILE" ]]; then
            start_node_script
        elif [[ -s "$PID_FILE" ]]; then
            pid=$(cat "$PID_FILE")
            # Verificar si el proceso está corriendo
            if ! ps -p $pid > /dev/null 2>&1; then
                start_node_script
            fi
        fi
    else
        # Si no hay internet, detener el script si está corriendo
        stop_node_script
    fi
    sleep 10
done

# /usr/local/bin/internet-print-monitor.sh
