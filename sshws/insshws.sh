#!/bin/bash
#installer Websocket tunneling

cd

# Pastikan python3 tersedia (ws-dropbear dan ws-stunnel sudah ported ke python3)
if ! command -v python3 &>/dev/null; then
    echo "[INFO] Installing python3..."
    apt install -y python3
fi

# Pastikan symlink python -> python3 ada untuk kompatibilitas
if ! command -v python &>/dev/null && command -v python3 &>/dev/null; then
    ln -sf $(command -v python3) /usr/local/bin/python
fi

#Install Script Websocket-SSH Python
wget -O /usr/local/bin/ws-dropbear https://raw.githubusercontent.com/Linkershark/ggv2/aio/sshws/ws-dropbear
wget -O /usr/local/bin/ws-stunnel https://raw.githubusercontent.com/Linkershark/ggv2/aio/sshws/ws-stunnel

#izin permision
chmod +x /usr/local/bin/ws-dropbear
chmod +x /usr/local/bin/ws-stunnel

#System Dropbear Websocket-SSH Python
wget -O /etc/systemd/system/ws-dropbear.service https://raw.githubusercontent.com/Linkershark/ggv2/aio/sshws/ws-dropbear.service && chmod +x /etc/systemd/system/ws-dropbear.service

#System SSL/TLS Websocket-SSH Python
wget -O /etc/systemd/system/ws-stunnel.service https://raw.githubusercontent.com/Linkershark/ggv2/aio/sshws/ws-stunnel.service && chmod +x /etc/systemd/system/ws-stunnel.service


#restart service
systemctl daemon-reload

#Enable & Start & Restart ws-dropbear service
systemctl enable ws-dropbear.service
systemctl start ws-dropbear.service
systemctl restart ws-dropbear.service

#Enable & Start & Restart ws-openssh service
systemctl enable ws-stunnel.service
systemctl start ws-stunnel.service
systemctl restart ws-stunnel.service

echo "[OK] Websocket services installed and started"
