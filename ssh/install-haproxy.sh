#!/bin/bash
# ============================================================
# HAProxy Installer
# Menggantikan stunnel4 dengan HAProxy + optimasi koneksi
# Mendukung port Cloudflare-compatible
# ============================================================

export DEBIAN_FRONTEND=noninteractive
source /etc/os-release 2>/dev/null

# Color
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
NC='\e[0m'

domain=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)

echo -e "[ ${green}INFO${NC} ] Installing HAProxy..."
apt update -y >/dev/null 2>&1
apt install -y haproxy
if ! command -v haproxy &>/dev/null; then
    echo -e "[ ${red}ERROR${NC} ] HAProxy gagal diinstall!"
    echo -e "[ ${yell}INFO${NC} ] Coba manual: apt install -y haproxy"
    exit 1
fi
echo -e "[ ${green}OK${NC} ] HAProxy terinstall"

# ============================================================
# 1. PREPARE SSL CERTIFICATE
# ============================================================
echo -e "[ ${green}INFO${NC} ] Preparing SSL certificate for HAProxy..."

mkdir -p /etc/haproxy/certs

# Gunakan cert Let's Encrypt dari xray jika ada
if [ -f /etc/xray/xray.crt ] && [ -f /etc/xray/xray.key ]; then
    cat /etc/xray/xray.crt /etc/xray/xray.key > /etc/haproxy/certs/cert.pem
    echo -e "[ ${green}OK${NC} ] Using Let's Encrypt certificate"
# Fallback ke stunnel cert jika ada
elif [ -f /etc/stunnel/stunnel.pem ]; then
    cp /etc/stunnel/stunnel.pem /etc/haproxy/certs/cert.pem
    echo -e "[ ${yell}WARN${NC} ] Using stunnel certificate (self-signed)"
# Generate self-signed jika tidak ada
else
    openssl req -new -x509 -days 3650 -nodes \
        -out /etc/haproxy/certs/cert.pem \
        -keyout /etc/haproxy/certs/cert.pem \
        -subj "/C=ID/ST=Indonesia/L=Jakarta/O=VPN/CN=${domain}" 2>/dev/null
    echo -e "[ ${yell}WARN${NC} ] Generated self-signed certificate"
fi

chmod 600 /etc/haproxy/certs/cert.pem

# ============================================================
# 2. MIGRATE NGINX TO INTERNAL PORT
# ============================================================
echo -e "[ ${green}INFO${NC} ] Migrating nginx to internal port 81..."

# Backup nginx config
cp /etc/nginx/conf.d/xray.conf /etc/nginx/conf.d/xray.conf.bak 2>/dev/null

# Ubah nginx listen ke internal port (HAProxy yang handle external)
if [ -f /etc/nginx/conf.d/xray.conf ]; then
    # Ganti listen directives
    sed -i 's/listen 80;/listen 127.0.0.1:81;/g' /etc/nginx/conf.d/xray.conf
    sed -i 's/listen \[::\]:80;/# listen [::]:80; # disabled, HAProxy handles IPv6/g' /etc/nginx/conf.d/xray.conf
    sed -i 's/listen 443.*/listen 127.0.0.1:81;/g' /etc/nginx/conf.d/xray.conf
    sed -i 's/listen \[::\]:443.*/# listen [::]:443; # disabled, HAProxy handles TLS/g' /etc/nginx/conf.d/xray.conf

    # Hapus SSL directives (HAProxy yang handle TLS)
    sed -i '/ssl_certificate /d' /etc/nginx/conf.d/xray.conf
    sed -i '/ssl_certificate_key /d' /etc/nginx/conf.d/xray.conf
    sed -i '/ssl_ciphers /d' /etc/nginx/conf.d/xray.conf
    sed -i '/ssl_protocols /d' /etc/nginx/conf.d/xray.conf

    # Hapus http2 dari listen (tidak perlu di internal)
    sed -i 's/ http2//g' /etc/nginx/conf.d/xray.conf

    echo -e "[ ${green}OK${NC} ] Nginx migrated to 127.0.0.1:81"
fi

# ============================================================
# 3. GENERATE HAPROXY CONFIG
# ============================================================
echo -e "[ ${green}INFO${NC} ] Generating HAProxy configuration..."

cat > /etc/haproxy/haproxy.cfg << 'HAPROXY_EOF'
# ============================================================
# HAProxy Config
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
    ssl-default-server-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
    ssl-default-server-options ssl-min-ver TLSv1.2

    # Performance Tuning
    maxconn 100000
    tune.bufsize 32768
    tune.maxrewrite 2048
    tune.ssl.force-private-cache

    # Multi-threading (gunakan semua CPU core)
    nbthread auto

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    option  tcp-check
    log-format "%ci:%cp [%t] %ft %b/%s %Tw/%Tc/%Tt %B %ts %ac/%fc/%bc/%sc/%rc %sq/%bq"

    # Timeout Optimization
    timeout connect 5s
    timeout client  300s
    timeout server  300s
    timeout tunnel  3600s
    timeout http-request 10s
    timeout http-keep-alive 10s
    timeout queue 30s
    timeout check 5s

    # Connection Optimization
    retries 3
    option  redispatch
    default-server inter 3s fall 3 rise 2

    # TCP Optimization
    option  clitcpka
    option  srvtcpka

# ============================================================
# HTTPS FRONTEND - TLS Termination (Cloudflare HTTPS Ports)
# Port: 443, 2053, 2083, 2087, 2096, 8443
# ============================================================
frontend ft_https
    # Cloudflare HTTPS ports
    bind *:443  ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:2053 ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:2083 ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:2087 ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:2096 ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1
    bind *:8443 ssl crt /etc/haproxy/certs/cert.pem alpn h2,http/1.1

    mode tcp

    # TCP Optimization
    option  clitcpka
    tcp-request inspect-delay 5s
    tcp-request content accept if HTTP

    # Rate Limiting: max 50 koneksi per IP
    stick-table type ip size 100k expire 30s store conn_cur
    tcp-request connection track-sc0 src
    tcp-request connection reject if { sc_conn_cur gt 50 }

    # HTTP traffic -> nginx (Xray WS + gRPC + web)
    use_backend be_nginx if HTTP

    # Non-HTTP traffic -> Dropbear SSH TLS
    default_backend be_dropbear_tls

# ============================================================
# HTTPS LEGACY FRONTEND - TLS (Stunnel replacement)
# Port: 222, 777
# ============================================================
frontend ft_https_legacy
    bind *:222 ssl crt /etc/haproxy/certs/cert.pem
    bind *:777 ssl crt /etc/haproxy/certs/cert.pem

    mode tcp
    option  clitcpka

    # Port 222 -> SSH (port 22)
    use_backend be_ssh if { dst_port 222 }

    # Port 777 -> Dropbear (port 109)
    default_backend be_dropbear

# ============================================================
# HTTP FRONTEND - Non-TLS (Cloudflare HTTP Ports)
# Port: 80, 8080, 8880, 2052, 2082, 2086
# (2095 handled by ft_ws_dropbear for SSH WebSocket)
# ============================================================
frontend ft_http
    bind *:80
    bind *:8080
    bind *:8880
    bind *:2052
    bind *:2082
    bind *:2086

    mode http

    # TCP & HTTP Optimization
    option  clitcpka
    option  http-server-close
    option  forwardfor except 127.0.0.0/8

    # Rate Limiting: max 100 koneksi per IP
    stick-table type ip size 100k expire 30s store conn_cur,http_req_rate(10s)
    tcp-request connection track-sc0 src
    http-request deny deny_status 429 if { sc_http_req_rate gt 200 }

    # Xray WS Path Routing
    use_backend be_xray_vmess_ws if { path_beg /vmess }
    use_backend be_xray_vless_ws if { path_beg /vless }
    use_backend be_xray_trojan_ws if { path_beg /trojan-ws }
    use_backend be_xray_ss_ws if { path_beg /ss-ws }

    # Default -> nginx (public_html + gRPC + other)
    default_backend be_nginx

# ============================================================
# WS-DROPBEAR FRONTEND - WebSocket SSH
# Port: 2095 (Cloudflare HTTP port for SSH WebSocket)
# ============================================================
frontend ft_ws_dropbear
    bind *:2095
    mode tcp
    option  clitcpka
    default_backend be_ws_dropbear

# ============================================================
# BACKENDS
# ============================================================

# Nginx (HTTP internal)
backend be_nginx
    mode http
    option  httpchk GET /
    http-check expect status 200
    server nginx 127.0.0.1:81 check inter 10s fall 3 rise 2

# Xray VMess WS
backend be_xray_vmess_ws
    mode http
    server xray 127.0.0.1:23456

# Xray Vless WS
backend be_xray_vless_ws
    mode http
    server xray 127.0.0.1:14016

# Xray Trojan WS
backend be_xray_trojan_ws
    mode http
    server xray 127.0.0.1:25432

# Xray Shadowsocks WS
backend be_xray_ss_ws
    mode http
    server xray 127.0.0.1:30300

# Dropbear SSH TLS (port 143)
backend be_dropbear_tls
    mode tcp
    option  srvtcpka
    server dropbear 127.0.0.1:143

# SSH (port 22)
backend be_ssh
    mode tcp
    option  srvtcpka
    server ssh 127.0.0.1:22

# Dropbear (port 109)
backend be_dropbear
    mode tcp
    option  srvtcpka
    server dropbear 127.0.0.1:109

# WS-Dropbear (internal port 6969)
backend be_ws_dropbear
    mode tcp
    option  srvtcpka
    server wsdropbear 127.0.0.1:6969

# ============================================================
# STATS PAGE (admin only, localhost)
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

# ============================================================
# 4. UPDATE WS-DROPBEAR TO INTERNAL PORT
# ============================================================
echo -e "[ ${green}INFO${NC} ] Updating ws-dropbear to internal port..."

# Ubah ws-dropbear service ke port internal
if [ -f /etc/systemd/system/ws-dropbear.service ]; then
    sed -i 's/ws-dropbear 2095/ws-dropbear 6969/g' /etc/systemd/system/ws-dropbear.service
    systemctl daemon-reload
    systemctl restart ws-dropbear.service 2>/dev/null
    echo -e "[ ${green}OK${NC} ] ws-dropbear moved to port 6969"
fi

# ============================================================
# 5. KERNEL TCP OPTIMIZATION
# ============================================================
echo -e "[ ${green}INFO${NC} ] Applying TCP kernel optimizations..."

# Hapus config lama jika ada, lalu tulis yang baru
sed -i '/# === HAProxy TCP Optimization ===/,/# File Descriptor Limit/d' /etc/sysctl.conf 2>/dev/null

cat >> /etc/sysctl.conf << 'SYSCTL_EOF'

# === HAProxy TCP Optimization ===
# TCP Fast Open
net.ipv4.tcp_fastopen = 3

# TCP Keepalive (lebih agresif)
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6

# TCP Buffer Size (throughput lebih besar)
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 87380 16777216

# TCP Congestion Control (BBR jika tersedia)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Connection Backlog
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535

# TCP Window Scaling
net.ipv4.tcp_window_scaling = 1

# TCP Timestamps
net.ipv4.tcp_timestamps = 1

# TCP SACK
net.ipv4.tcp_sack = 1

# File Descriptor Limit
fs.file-max = 2097152
SYSCTL_EOF

sysctl -p >/dev/null 2>&1

# Set ulimit untuk HAProxy
cat > /etc/security/limits.d/haproxy.conf << 'LIMITS_EOF'
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
LIMITS_EOF

# Update systemd service limit
mkdir -p /etc/systemd/system/haproxy.service.d
cat > /etc/systemd/system/haproxy.service.d/limits.conf << 'SDEOF'
[Service]
LimitNOFILE=1048576
LimitNPROC=65535
SDEOF

echo -e "[ ${green}OK${NC} ] TCP optimizations applied"

# ============================================================
# 6. REMOVE STUNNEL4
# ============================================================
echo -e "[ ${green}INFO${NC} ] Removing stunnel4..."
systemctl stop stunnel4 2>/dev/null
systemctl disable stunnel4 2>/dev/null
apt remove --purge stunnel4 -y >/dev/null 2>&1
echo -e "[ ${green}OK${NC} ] stunnel4 removed"

# ============================================================
# 7. OPEN FIREWALL PORTS
# ============================================================
echo -e "[ ${green}INFO${NC} ] Opening firewall ports..."

# HTTPS ports (cek dulu sebelum tambah, hindari duplikat)
for port in 443 2053 2083 2087 2096 8443 222 777; do
    iptables -C INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null || \
    iptables -I INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null
done

# HTTP ports
for port in 80 8080 8880 2052 2082 2086 2095; do
    iptables -C INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null || \
    iptables -I INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null
done

netfilter-persistent save >/dev/null 2>&1

echo -e "[ ${green}OK${NC} ] Firewall ports opened"

# ============================================================
# 8. START SERVICES
# ============================================================
echo -e "[ ${green}INFO${NC} ] Starting services..."

systemctl daemon-reload
systemctl enable haproxy
systemctl restart haproxy
systemctl restart nginx

# Verify HAProxy is running
if systemctl is-active --quiet haproxy; then
    echo -e "[ ${green}OK${NC} ] HAProxy is running"
else
    echo -e "[ ${red}ERROR${NC} ] HAProxy failed to start!"
    echo -e "[ ${yell}INFO${NC} ] Check: systemctl status haproxy"
    echo -e "[ ${yell}INFO${NC} ] Check: haproxy -c -f /etc/haproxy/haproxy.cfg"
fi

# ============================================================
# 9. CLEANUP
# ============================================================
rm -f /root/install-haproxy.sh 2>/dev/null

# ============================================================
# DONE
# ============================================================
clear
echo -e ""
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${green}       HAProxy Installation Complete!${NC}"
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "  HTTPS Ports (TLS):"
echo -e "    443, 2053, 2083, 2087, 2096, 8443"
echo -e "    222 (SSH TLS), 777 (Dropbear TLS)"
echo -e ""
echo -e "  HTTP Ports:"
echo -e "    80, 8080, 8880, 2052, 2082, 2086, 2095"
echo -e ""
echo -e "  Internal Services:"
echo -e "    Nginx     : 127.0.0.1:81"
echo -e "    WS-Dropbear: 127.0.0.1:6969 -> 127.0.0.1:2095"
echo -e ""
echo -e "  Stats Page: http://127.0.0.1:8404/stats"
echo -e "  Auth: admin / haproxy2024"
echo -e ""
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
