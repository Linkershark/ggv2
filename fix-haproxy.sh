#!/bin/bash
# ============================================================
# Fix Script - Hapus stunnel4 & Setup HAProxy
# Jalankan sebagai root
# ============================================================

red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
NC='\e[0m'

clear
echo -e "${yell}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${green}    Fix: Hapus stunnel4 & Setup HAProxy${NC}"
echo -e "${yell}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================================
# 1. BACA KONFIGURASI STUNNEL4 YANG ADA
# ============================================================
echo -e "[ ${green}1/6${NC} ] Membaca konfigurasi stunnel4..."

STUNNEL_CONF="/etc/stunnel/stunnel.conf"
HAS_STUNNEL=false

if [ -f "$STUNNEL_CONF" ]; then
    HAS_STUNNEL=true
    echo -e "[ ${green}OK${NC} ] Konfigurasi stunnel4 ditemukan"
    echo ""
    echo -e "  Isi config:"
    cat "$STUNNEL_CONF" | grep -v "^#" | grep -v "^$" | while read line; do
        echo -e "    $line"
    done
    echo ""
else
    echo -e "[ ${yell}INFO${NC} ] Konfigurasi stunnel4 tidak ditemukan"
fi

# ============================================================
# 2. HAPUS STUNNEL4
# ============================================================
echo -e "[ ${green}2/6${NC} ] Menghapus stunnel4..."

# Stop service
systemctl stop stunnel4 2>/dev/null
/etc/init.d/stunnel4 stop 2>/dev/null

# Disable service
systemctl disable stunnel4 2>/dev/null

# Remove package
apt remove --purge stunnel4 -y 2>/dev/null

# Remove config
rm -rf /etc/stunnel 2>/dev/null

# Verify removal
if ! command -v stunnel4 &>/dev/null && ! dpkg -l | grep -q stunnel4; then
    echo -e "[ ${green}OK${NC} ] stunnel4 berhasil dihapus"
else
    echo -e "[ ${yell}WARN${NC} ] stunnel4 mungkin masih ada, cek: dpkg -l | grep stunnel"
fi

# ============================================================
# 3. INSTALL HAPROXY (JIKA BELUM)
# ============================================================
echo -e "[ ${green}3/6${NC} ] Cek HAProxy..."

if ! command -v haproxy &>/dev/null; then
    echo -e "[ ${green}INFO${NC} ] Installing HAProxy..."
    apt update -y >/dev/null 2>&1
    apt install -y haproxy
    
    if command -v haproxy &>/dev/null; then
        echo -e "[ ${green}OK${NC} ] HAProxy berhasil diinstall"
    else
        echo -e "[ ${red}ERROR${NC} ] HAProxy gagal diinstall!"
        echo -e "[ ${yell}INFO${NC} ] Coba manual: apt install -y haproxy"
        exit 1
    fi
else
    echo -e "[ ${green}OK${NC} ] HAProxy sudah terinstall"
fi

# ============================================================
# 4. PREPARE SSL CERTIFICATE
# ============================================================
echo -e "[ ${green}4/6${NC} ] Menyiapkan SSL certificate..."

mkdir -p /etc/haproxy/certs

domain=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)

# Gunakan cert Let's Encrypt jika ada
if [ -f /etc/xray/xray.crt ] && [ -f /etc/xray/xray.key ]; then
    cat /etc/xray/xray.crt /etc/xray/xray.key > /etc/haproxy/certs/cert.pem
    echo -e "[ ${green}OK${NC} ] Menggunakan Let's Encrypt certificate"
# Gunakan cert stunnel jika ada
elif [ -f /etc/stunnel/stunnel.pem ]; then
    cp /etc/stunnel/stunnel.pem /etc/haproxy/certs/cert.pem
    echo -e "[ ${green}OK${NC} ] Menggunakan stunnel certificate"
# Generate self-signed
else
    openssl req -new -x509 -days 3650 -nodes \
        -out /etc/haproxy/certs/cert.pem \
        -keyout /etc/haproxy/certs/cert.pem \
        -subj "/C=ID/ST=Indonesia/L=Jakarta/O=VPN/CN=${domain}" 2>/dev/null
    echo -e "[ ${green}OK${NC} ] Generated self-signed certificate"
fi

chmod 600 /etc/haproxy/certs/cert.pem

# ============================================================
# 5. GENERATE HAPROXY CONFIG
# ============================================================
echo -e "[ ${green}5/6${NC} ] Generate konfigurasi HAProxy..."

# Backup config lama jika ada
if [ -f /etc/haproxy/haproxy.cfg ]; then
    cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak.$(date +%Y%m%d%H%M)
fi

cat > /etc/haproxy/haproxy.cfg << 'HAPROXY_EOF'
# ============================================================
# HAProxy Config - Replace stunnel4
# ============================================================

global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

    # SSL Optimization
    tune.ssl.default-dh-param 2048
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

    # Performance
    maxconn 100000
    tune.bufsize 32768
    nbthread auto

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    option  tcp-check

    # Timeout
    timeout connect 5s
    timeout client  300s
    timeout server  300s
    timeout tunnel  3600s

    # Connection
    retries 3
    option  redispatch
    option  clitcpka
    option  srvtcpka

# ============================================================
# HTTPS FRONTEND - TLS Termination
# Port: 443, 2053, 2083, 2087, 2096, 8443, 222, 777
# ============================================================
frontend ft_https
    bind *:443  ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:2053 ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:2083 ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:2087 ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:2096 ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:8443 ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:222  ssl crt /etc/haproxy/certs/cert.pem
    bind *:777  ssl crt /etc/haproxy/certs/cert.pem

    mode tcp
    option  clitcpka
    tcp-request inspect-delay 5s
    tcp-request content accept if HTTP

    # Rate Limit
    stick-table type ip size 100k expire 30s store conn_cur
    tcp-request connection track-sc0 src
    tcp-request connection reject if { sc_conn_cur gt 50 }

    # HTTP -> nginx
    use_backend be_nginx if HTTP

    # Non-HTTP -> Dropbear SSH TLS
    default_backend be_dropbear_tls

# ============================================================
# HTTP FRONTEND - Non-TLS
# Port: 80, 8080, 8880, 2052, 2082, 2086
# ============================================================
frontend ft_http
    bind *:80
    bind *:8080
    bind *:8880
    bind *:2052
    bind *:2082
    bind *:2086

    mode http
    option  clitcpka
    option  http-server-close

    # Rate Limit
    stick-table type ip size 100k expire 30s store conn_cur,http_req_rate(10s)
    tcp-request connection track-sc0 src
    http-request deny deny_status 429 if { sc_http_req_rate gt 200 }

    # Xray WS paths
    use_backend be_xray_vmess_ws if { path_beg /vmess }
    use_backend be_xray_vless_ws if { path_beg /vless }
    use_backend be_xray_trojan_ws if { path_beg /trojan-ws }
    use_backend be_xray_ss_ws if { path_beg /ss-ws }

    # Default -> nginx
    default_backend be_nginx

# ============================================================
# WS-DROPBEAR FRONTEND
# Port: 2095
# ============================================================
frontend ft_ws_dropbear
    bind *:2095
    mode tcp
    option  clitcpka
    default_backend be_ws_dropbear

# ============================================================
# BACKENDS
# ============================================================

backend be_nginx
    mode http
    server nginx 127.0.0.1:81

backend be_xray_vmess_ws
    mode http
    server xray 127.0.0.1:23456

backend be_xray_vless_ws
    mode http
    server xray 127.0.0.1:14016

backend be_xray_trojan_ws
    mode http
    server xray 127.0.0.1:25432

backend be_xray_ss_ws
    mode http
    server xray 127.0.0.1:30300

backend be_dropbear_tls
    mode tcp
    server dropbear 127.0.0.1:143

backend be_ssh
    mode tcp
    server ssh 127.0.0.1:22

backend be_dropbear
    mode tcp
    server dropbear 127.0.0.1:109

backend be_ws_dropbear
    mode tcp
    server wsdropbear 127.0.0.1:6969

# ============================================================
# STATS PAGE
# ============================================================
listen stats
    bind 127.0.0.1:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
    stats admin if TRUE
    stats auth admin:haproxy2024

HAPROXY_EOF

echo -e "[ ${green}OK${NC} ] Konfigurasi HAProxy dibuat"

# ============================================================
# 6. SETUP NGINX & START SERVICES
# ============================================================
echo -e "[ ${green}6/6${NC} ] Konfigurasi nginx & start services..."

# Migrate nginx to internal port
if [ -f /etc/nginx/conf.d/xray.conf ]; then
    # Backup
    cp /etc/nginx/conf.d/xray.conf /etc/nginx/conf.d/xray.conf.bak.$(date +%Y%m%d%H%M)
    
    # Change listen to internal port
    sed -i 's/listen 80;/listen 127.0.0.1:81;/g' /etc/nginx/conf.d/xray.conf
    sed -i 's/listen \[::\]:80;/# listen [::]:80; # disabled/g' /etc/nginx/conf.d/xray.conf
    sed -i 's/listen 443.*/listen 127.0.0.1:81;/g' /etc/nginx/conf.d/xray.conf
    sed -i 's/listen \[::\]:443.*/# listen [::]:443; # disabled/g' /etc/nginx/conf.d/xray.conf
    sed -i '/ssl_certificate /d' /etc/nginx/conf.d/xray.conf
    sed -i '/ssl_certificate_key /d' /etc/nginx/conf.d/xray.conf
    sed -i '/ssl_ciphers /d' /etc/nginx/conf.d/xray.conf
    sed -i '/ssl_protocols /d' /etc/nginx/conf.d/xray.conf
    sed -i 's/ http2//g' /etc/nginx/conf.d/xray.conf
    
    echo -e "[ ${green}OK${NC} ] Nginx migrated to 127.0.0.1:81"
else
    echo -e "[ ${yell}WARN${NC} ] Nginx config tidak ditemukan"
fi

# Update ws-dropbear to internal port
if [ -f /etc/systemd/system/ws-dropbear.service ]; then
    sed -i 's/ws-dropbear 2095/ws-dropbear 6969/g' /etc/systemd/system/ws-dropbear.service
    systemctl daemon-reload
    systemctl restart ws-dropbear.service 2>/dev/null
    echo -e "[ ${green}OK${NC} ] ws-dropbear moved to port 6969"
fi

# Open firewall ports
for port in 443 2053 2083 2087 2096 8443 222 777 80 8080 8880 2052 2082 2086 2095; do
    iptables -C INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null || \
    iptables -I INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null
done
netfilter-persistent save >/dev/null 2>&1

# Start HAProxy
systemctl daemon-reload
systemctl enable haproxy
systemctl restart haproxy

# Restart nginx
systemctl restart nginx 2>/dev/null

# Verify
echo ""
echo -e "${yell}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if systemctl is-active --quiet haproxy; then
    echo -e "${green}    HAProxy berhasil dijalankan!${NC}"
else
    echo -e "${red}    HAProxy gagal start!${NC}"
    echo -e "${yell}    Cek: systemctl status haproxy${NC}"
    echo -e "${yell}    Cek: haproxy -c -f /etc/haproxy/haproxy.cfg${NC}"
fi
echo -e "${yell}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Service Status:"
echo -e "    stunnel4  : $(systemctl is-active stunnel4 2>/dev/null || echo 'removed')"
echo -e "    HAProxy   : $(systemctl is-active haproxy 2>/dev/null)"
echo -e "    Nginx     : $(systemctl is-active nginx 2>/dev/null)"
echo -e "    Dropbear  : $(systemctl is-active dropbear 2>/dev/null)"
echo -e "    WS-Dropbear: $(systemctl is-active ws-dropbear 2>/dev/null)"
echo ""
echo -e "  HTTPS Ports: 443, 2053, 2083, 2087, 2096, 8443, 222, 777"
echo -e "  HTTP Ports : 80, 8080, 8880, 2052, 2082, 2086, 2095"
echo ""
echo -e "  Stats: http://127.0.0.1:8404/stats"
echo -e "  Auth : admin / haproxy2024"
echo ""
