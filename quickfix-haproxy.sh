#!/bin/bash
# ============================================================
# Quick Fix v2 - HAProxy Config Error
# Jalankan langsung di VPS
# ============================================================

green='\e[0;32m'
red='\e[1;31m'
NC='\e[0m'

echo -e "[ ${green}INFO${NC} ] Fix HAProxy config v2..."

CONFIG="/etc/haproxy/haproxy.cfg"

if [ ! -f "$CONFIG" ]; then
    echo -e "[ ${red}ERROR${NC} ] Config tidak ditemukan: $CONFIG"
    exit 1
fi

# Backup
cp "$CONFIG" "${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

# Rewrite config dengan versi yang benar (tanpa rate limiting yang bermasalah)
cat > "$CONFIG" << 'HAPROXY_EOF'
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

    # SSL
    tune.ssl.default-dh-param 2048
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

    # Performance
    maxconn 100000
    tune.bufsize 32768
    nbthread 4

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    option  tcp-check

    timeout connect 5s
    timeout client  300s
    timeout server  300s
    timeout tunnel  3600s

    retries 3
    option  redispatch
    option  clitcpka
    option  srvtcpka

# ============================================================
# HTTPS FRONTEND
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

    use_backend be_nginx if HTTP
    default_backend be_dropbear_tls

# ============================================================
# HTTP FRONTEND
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

    use_backend be_xray_vmess_ws if { path_beg /vmess }
    use_backend be_xray_vless_ws if { path_beg /vless }
    use_backend be_xray_trojan_ws if { path_beg /trojan-ws }
    use_backend be_xray_ss_ws if { path_beg /ss-ws }

    default_backend be_nginx

# ============================================================
# WS-DROPBEAR FRONTEND
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

# STATS
listen stats
    bind 127.0.0.1:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
    stats admin if TRUE
    stats auth admin:haproxy2024

HAPROXY_EOF

# Test config
echo -e "[ ${green}INFO${NC} ] Testing config..."
if haproxy -c -f "$CONFIG" 2>&1; then
    echo -e "[ ${green}OK${NC} ] Config valid!"
    
    # Restart HAProxy
    systemctl restart haproxy
    
    if systemctl is-active --quiet haproxy; then
        echo -e "[ ${green}OK${NC} ] HAProxy berhasil start!"
        echo ""
        echo -e "  Service Status:"
        echo -e "    HAProxy    : $(systemctl is-active haproxy)"
        echo -e "    Nginx      : $(systemctl is-active nginx)"
        echo -e "    Dropbear   : $(systemctl is-active dropbear)"
        echo -e "    WS-Dropbear: $(systemctl is-active ws-dropbear)"
        echo ""
        echo -e "  HTTPS Ports: 443, 2053, 2083, 2087, 2096, 8443, 222, 777"
        echo -e "  HTTP Ports : 80, 8080, 8880, 2052, 2082, 2086"
        echo -e "  WS-Dropbear: 2095"
        echo ""
    else
        echo -e "[ ${red}ERROR${NC} ] HAProxy masih gagal!"
        systemctl status haproxy --no-pager
    fi
else
    echo -e "[ ${red}ERROR${NC} ] Config masih error!"
fi
