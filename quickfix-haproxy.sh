#!/bin/bash
# ============================================================
# Quick Fix - HAProxy Config Error
# Jalankan langsung di VPS
# ============================================================

green='\e[0;32m'
red='\e[1;31m'
NC='\e[0m'

echo -e "[ ${green}INFO${NC} ] Fix HAProxy config..."

CONFIG="/etc/haproxy/haproxy.cfg"

if [ ! -f "$CONFIG" ]; then
    echo -e "[ ${red}ERROR${NC} ] Config tidak ditemukan: $CONFIG"
    exit 1
fi

# Backup
cp "$CONFIG" "${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

# Fix 1: nbthread auto -> nbthread 4
sed -i 's/nbthread auto/nbthread 4/g' "$CONFIG"

# Fix 2: sc_conn_cur -> sc0_conn_cur
sed -i 's/sc_conn_cur/sc0_conn_cur/g' "$CONFIG"

# Fix 3: sc_http_req_rate -> sc0_http_req_rate(10s)
sed -i 's/sc_http_req_rate/sc0_http_req_rate(10s)/g' "$CONFIG"

# Fix 4: Fix tcp-request order (move rate limit before HTTP detect)
# Hapus baris lama dan tambah yang benar
sed -i '/tcp-request content accept if HTTP/d' "$CONFIG"
sed -i '/tcp-request connection reject/d' "$CONFIG"

# Tambahkan rate limit dan HTTP detect yang benar setelah track-sc
sed -i '/tcp-request connection track-sc0 src/a\    tcp-request content reject if { sc0_conn_cur gt 50 }\n\n    # Detect HTTP\n    tcp-request content accept if HTTP' "$CONFIG"

# Test config
echo -e "[ ${green}INFO${NC} ] Testing config..."
if haproxy -c -f "$CONFIG" 2>&1; then
    echo -e "[ ${green}OK${NC} ] Config valid!"
    
    # Restart HAProxy
    systemctl restart haproxy
    
    if systemctl is-active --quiet haproxy; then
        echo -e "[ ${green}OK${NC} ] HAProxy berhasil start!"
    else
        echo -e "[ ${red}ERROR${NC} ] HAProxy masih gagal, cek: systemctl status haproxy"
    fi
else
    echo -e "[ ${red}ERROR${NC} ] Config masih error!"
    echo -e "[ ${green}INFO${NC} ] Restore backup: cp ${CONFIG}.bak.* $CONFIG"
fi
