#!/bin/bash


if [ "$EUID" -ne 0 ]; then 
    echo "Este script necesita ejecutarse como root"
    exit 1
fi

echo "Instalando Wireguard..."
apt update
apt install -y wireguard resolvconf

cat > /etc/resolv.conf << EOF
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF


chattr +i /etc/resolv.conf

mkdir -p /etc/wireguard
chmod 700 /etc/wireguard


echo "Habilitando IP forwarding..."
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-wireguard.conf
sysctl -p /etc/sysctl.d/99-wireguard.conf



echo "Habilitando y iniciando el servicio de WireGuard..."
systemctl enable wg-quick@wg0
#systemctl start wg-quick@wg0 




echo "Habilitando y iniciando el servicio resolvconf..."
systemctl enable resolvconf
systemctl start resolvconf



echo "Instalación básica completada."
echo "Wireguard está instalado y el DNS está configurado."
echo "Para configurar una conexión, necesitarás crear el archivo /etc/wireguard/wg0.conf manualmente."
echo -e "\e[1;33mPara iniciar el servicio, ejecutar: systemctl start wg-quick@wg0\e[0m"
