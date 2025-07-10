#!/bin/bash

echo "Deshabilitando Wayland para forzar Xorg..."

# Realiza backup del archivo original
sudo cp /etc/gdm3/custom.conf /etc/gdm3/custom.conf.bak

# Descomenta o agrega la línea WaylandEnable=false
sudo sed -i '/^#WaylandEnable=false/s/^#//' /etc/gdm3/custom.conf
if ! grep -q '^WaylandEnable=false' /etc/gdm3/custom.conf; then
  echo 'WaylandEnable=false' | sudo tee -a /etc/gdm3/custom.conf > /dev/null
fi

echo "Reiniciando GDM (se cerrarán sesiones gráficas)..."
sudo systemctl restart gdm3

sleep 5

# Verifica el estado
SESSION_TYPE=$(loginctl show-session $(loginctl | grep $USER | awk '{print $1}') -p Type | cut -d= -f2)

echo "Tipo de sesión después del cambio: $SESSION_TYPE"
if [[ "$SESSION_TYPE" == "x11" ]]; then
  echo "Cambio exitoso: Ahora usa Xorg."
else
  echo "Advertencia: El cambio podría no haberse aplicado. Verifica manualmente."
fi
