#!/bin/bash
# ============================================================
# Update Script - Migrasi dari repo gg ke ggv2
# Jalankan sebagai root di VPS yang sudah install dari repo gg
# ============================================================

export DEBIAN_FRONTEND=noninteractive
REPO="https://raw.githubusercontent.com/Linkershark/ggv2/aio"

red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
cyan='\e[1;36m'
NC='\e[0m'

clear
echo -e "${cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${cyan}       Script Update - gg to ggv2${NC}"
echo -e "${cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Cek root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${red}Jalankan sebagai root!${NC}"
    exit 1
fi

echo -e "[ ${green}INFO${NC} ] Memulai update script..."
echo ""

# ============================================================
# 1. UPDATE SEMUA URL DI SCRIPT YANG SUDAH ADA
# ============================================================
echo -e "[ ${green}1/7${NC} ] Update URL dari gg ke ggv2..."

# Update semua file di /usr/bin yang mengandung Linkershark/gg
for f in /usr/bin/menu /usr/bin/m-vmess /usr/bin/m-vless /usr/bin/m-ssws /usr/bin/m-trojan \
         /usr/bin/m-sshovpn /usr/bin/m-system /usr/bin/m-domain /usr/bin/running \
         /usr/bin/clearcache /usr/bin/usernew /usr/bin/trial /usr/bin/renew \
         /usr/bin/hapus /usr/bin/cek /usr/bin/member /usr/bin/delete \
         /usr/bin/autokill /usr/bin/ceklim /usr/bin/tendang /usr/bin/sshws \
         /usr/bin/add-host /usr/bin/certv2ray /usr/bin/speedtest \
         /usr/bin/auto-reboot /usr/bin/restart /usr/bin/bw /usr/bin/xp \
         /usr/bin/add-ws /usr/bin/add-vless /usr/bin/add-tr /usr/bin/add-ssws \
         /usr/bin/trialvmess /usr/bin/trialvless /usr/bin/trialtrojan /usr/bin/trialssws \
         /usr/bin/del-ws /usr/bin/del-vless /usr/bin/del-tr /usr/bin/del-ssws \
         /usr/bin/renew-ws /usr/bin/renew-vless /usr/bin/renew-tr /usr/bin/renew-ssws \
         /usr/bin/cek-ws /usr/bin/cek-vless /usr/bin/cek-tr; do
    if [ -f "$f" ]; then
        sed -i 's|Linkershark/gg|Linkershark/ggv2|g' "$f" 2>/dev/null
    fi
done

# Update setup.sh di root jika ada
if [ -f /root/setup.sh ]; then
    sed -i 's|Linkershark/gg|Linkershark/ggv2|g' /root/setup.sh 2>/dev/null
fi

echo -e "[ ${green}OK${NC} ] URL sudah diupdate"

# ============================================================
# 2. DOWNLOAD SCRIPT BARU DARI GGV2
# ============================================================
echo -e "[ ${green}2/7${NC} ] Download script terbaru dari ggv2..."

cd /usr/bin

# Menu scripts
wget -q -O menu "${REPO}/menu/menu.sh" && chmod +x menu
wget -q -O m-vmess "${REPO}/menu/m-vmess.sh" && chmod +x m-vmess
wget -q -O m-vless "${REPO}/menu/m-vless.sh" && chmod +x m-vless
wget -q -O m-ssws "${REPO}/menu/m-ssws.sh" && chmod +x m-ssws
wget -q -O m-trojan "${REPO}/menu/m-trojan.sh" && chmod +x m-trojan
wget -q -O m-sshovpn "${REPO}/menu/m-sshovpn.sh" && chmod +x m-sshovpn
wget -q -O m-system "${REPO}/menu/m-system.sh" && chmod +x m-system
wget -q -O m-domain "${REPO}/menu/m-domain.sh" && chmod +x m-domain
wget -q -O running "${REPO}/menu/running.sh" && chmod +x running
wget -q -O clearcache "${REPO}/menu/clearcache.sh" && chmod +x clearcache
wget -q -O auto-reboot "${REPO}/menu/auto-reboot.sh" && chmod +x auto-reboot
wget -q -O restart "${REPO}/menu/restart.sh" && chmod +x restart
wget -q -O bw "${REPO}/menu/bw.sh" && chmod +x bw

# SSH scripts
wget -q -O usernew "${REPO}/ssh/usernew.sh" && chmod +x usernew
wget -q -O trial "${REPO}/ssh/trial.sh" && chmod +x trial
wget -q -O renew "${REPO}/ssh/renew.sh" && chmod +x renew
wget -q -O hapus "${REPO}/ssh/hapus.sh" && chmod +x hapus
wget -q -O cek "${REPO}/ssh/cek.sh" && chmod +x cek
wget -q -O member "${REPO}/ssh/member.sh" && chmod +x member
wget -q -O delete "${REPO}/ssh/delete.sh" && chmod +x delete
wget -q -O autokill "${REPO}/ssh/autokill.sh" && chmod +x autokill
wget -q -O ceklim "${REPO}/ssh/ceklim.sh" && chmod +x ceklim
wget -q -O tendang "${REPO}/ssh/tendang.sh" && chmod +x tendang
wget -q -O sshws "${REPO}/ssh/sshws.sh" && chmod +x sshws
wget -q -O add-host "${REPO}/ssh/add-host.sh" && chmod +x add-host
wget -q -O xp "${REPO}/ssh/xp.sh" && chmod +x xp
wget -q -O speedtest "${REPO}/ssh/speedtest_cli.py" && chmod +x speedtest

# Xray scripts
wget -q -O add-ws "${REPO}/xray/add-ws.sh" && chmod +x add-ws
wget -q -O add-vless "${REPO}/xray/add-vless.sh" && chmod +x add-vless
wget -q -O add-tr "${REPO}/xray/add-tr.sh" && chmod +x add-tr
wget -q -O add-ssws "${REPO}/xray/add-ssws.sh" && chmod +x add-ssws
wget -q -O trialvmess "${REPO}/xray/trialvmess.sh" && chmod +x trialvmess
wget -q -O trialvless "${REPO}/xray/trialvless.sh" && chmod +x trialvless
wget -q -O trialtrojan "${REPO}/xray/trialtrojan.sh" && chmod +x trialtrojan
wget -q -O trialssws "${REPO}/xray/trialssws.sh" && chmod +x trialssws
wget -q -O del-ws "${REPO}/xray/del-ws.sh" && chmod +x del-ws
wget -q -O del-vless "${REPO}/xray/del-vless.sh" && chmod +x del-vless
wget -q -O del-tr "${REPO}/xray/del-tr.sh" && chmod +x del-tr
wget -q -O del-ssws "${REPO}/xray/del-ssws.sh" && chmod +x del-ssws
wget -q -O renew-ws "${REPO}/xray/renew-ws.sh" && chmod +x renew-ws
wget -q -O renew-vless "${REPO}/xray/renew-vless.sh" && chmod +x renew-vless
wget -q -O renew-tr "${REPO}/xray/renew-tr.sh" && chmod +x renew-tr
wget -q -O renew-ssws "${REPO}/xray/renew-ssws.sh" && chmod +x renew-ssws
wget -q -O cek-ws "${REPO}/xray/cek-ws.sh" && chmod +x cek-ws
wget -q -O cek-vless "${REPO}/xray/cek-vless.sh" && chmod +x cek-vless
wget -q -O cek-tr "${REPO}/xray/cek-tr.sh" && chmod +x cek-tr
wget -q -O certv2ray "${REPO}/xray/certv2ray.sh" && chmod +x certv2ray

echo -e "[ ${green}OK${NC} ] Script terbaru sudah didownload"

# ============================================================
# 3. INSTALL WEBSOCKET PYTHON 3
# ============================================================
echo -e "[ ${green}3/7${NC} ] Update WebSocket ke Python 3..."

# Install python3 jika belum ada
if ! command -v python3 &>/dev/null; then
    apt install -y python3 >/dev/null 2>&1
fi

# Buat symlink python -> python3 jika perlu
if ! command -v python &>/dev/null && command -v python3 &>/dev/null; then
    ln -sf $(command -v python3) /usr/local/bin/python
fi

# Download ws scripts (Python 3 version)
wget -q -O /usr/local/bin/ws-dropbear "${REPO}/sshws/ws-dropbear" && chmod +x /usr/local/bin/ws-dropbear
wget -q -O /usr/local/bin/ws-stunnel "${REPO}/sshws/ws-stunnel" && chmod +x /usr/local/bin/ws-stunnel

# Update service files
wget -q -O /etc/systemd/system/ws-dropbear.service "${REPO}/sshws/ws-dropbear.service"
wget -q -O /etc/systemd/system/ws-stunnel.service "${REPO}/sshws/ws-stunnel.service"

# Jika HAProxy sudah terinstall, ws-dropbear harus di port internal
if systemctl is-active --quiet haproxy 2>/dev/null; then
    sed -i 's/ws-dropbear 2095/ws-dropbear 6969/g' /etc/systemd/system/ws-dropbear.service
fi

systemctl daemon-reload
systemctl restart ws-dropbear.service 2>/dev/null
systemctl restart ws-stunnel.service 2>/dev/null

echo -e "[ ${green}OK${NC} ] WebSocket sudah diupdate ke Python 3"

# ============================================================
# 4. INSTALL LIMIT SYSTEM
# ============================================================
echo -e "[ ${green}4/7${NC} ] Install quota & IP limit system..."

mkdir -p /etc/xray/limit

wget -q -O /etc/xray/limit/xray-limit.sh "${REPO}/xray/xray-limit.sh" && chmod +x /etc/xray/limit/xray-limit.sh
wget -q -O /usr/local/bin/xray-limit-checker "${REPO}/xray/xray-limit-checker.sh" && chmod +x /usr/local/bin/xray-limit-checker
wget -q -O /usr/local/bin/cek-limit "${REPO}/xray/cek-limit.sh" && chmod +x /usr/local/bin/cek-limit

# Setup Telegram config jika belum ada
if [ ! -f /etc/xray/limit/telegram.conf ]; then
    echo ""
    echo -e "${yell}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${green}  Setup Notifikasi Telegram Limit  ${NC}"
    echo -e "${yell}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "[ ${green}INFO${NC} ] Kosongkan jika tidak ingin notifikasi Telegram"
    read -rp "Telegram Bot Token: " tg_bot_token
    read -rp "Telegram Chat ID (admin/group): " tg_chat_id

    if [ -n "$tg_bot_token" ] && [ -n "$tg_chat_id" ]; then
        cat > /etc/xray/limit/telegram.conf <<-TGEOF
BOT_TOKEN=${tg_bot_token}
CHAT_ID=${tg_chat_id}
TGEOF
        echo -e "[ ${green}OK${NC} ] Notifikasi Telegram aktif"
    else
        cat > /etc/xray/limit/telegram.conf <<-TGEOF
# Uncomment dan isi untuk mengaktifkan notifikasi
# BOT_TOKEN=your_bot_token_here
# CHAT_ID=your_chat_id_here
TGEOF
        echo -e "[ ${yell}SKIP${NC} ] Notifikasi Telegram tidak diaktifkan"
    fi
fi

# Setup cron job jika belum ada
if [ ! -f /etc/cron.d/xray-limit-check ]; then
    cat > /etc/cron.d/xray-limit-check <<-LCEOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
* * * * * root /usr/local/bin/xray-limit-checker >/dev/null 2>&1
LCEOF
fi

echo -e "[ ${green}OK${NC} ] Limit system sudah terinstall"

# ============================================================
# 5. INSTALL HAPROXY (GANTI STUNNEL4)
# ============================================================
echo -e "[ ${green}5/7${NC} ] Install HAProxy (ganti stunnel4)..."

if ! command -v haproxy &>/dev/null; then
    # Download dan jalankan installer HAProxy
    wget -q -O /tmp/install-haproxy.sh "${REPO}/ssh/install-haproxy.sh"
    chmod +x /tmp/install-haproxy.sh
    bash /tmp/install-haproxy.sh
    rm -f /tmp/install-haproxy.sh
    echo -e "[ ${green}OK${NC} ] HAProxy sudah terinstall"
else
    echo -e "[ ${green}OK${NC} ] HAProxy sudah ada, skip install"
    # Update config saja
    wget -q -O /tmp/install-haproxy.sh "${REPO}/ssh/install-haproxy.sh"
    # Backup config lama
    cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak.$(date +%Y%m%d) 2>/dev/null
    chmod +x /tmp/install-haproxy.sh
    bash /tmp/install-haproxy.sh
    rm -f /tmp/install-haproxy.sh
fi

# ============================================================
# 6. UPDATE DROPBEAR (JIKA PERLU)
# ============================================================
echo -e "[ ${green}6/7${NC} ] Cek dropbear compatibility..."

# Cek apakah dropbear 2019 sudah terinstall
DROPBEAR_2019_EXISTS=false
DROPBEAR_VERSION_OK=false

# Cek binary dropbear 2019 di lokasi custom
if [ -f "/usr/local/dropbear-2019/sbin/dropbear" ]; then
    DROPBEAR_2019_EXISTS=true
    DROPBEAR_VERSION_OK=true
    echo -e "[ ${green}OK${NC} ] Dropbear 2019 sudah terinstall di /usr/local/dropbear-2019/"
fi

# Cek versi dropbear yang sedang running
if [ "$DROPBEAR_VERSION_OK" = false ]; then
    DROPBEAR_BIN_PATH=$(which dropbear 2>/dev/null || echo "")
    if [ -n "$DROPBEAR_BIN_PATH" ]; then
        DROPBEAR_VER=$($DROPBEAR_BIN_PATH -V 2>&1 | head -1 | grep -oP '20\d{2}\.\d+' || echo "")
        if [ -n "$DROPBEAR_VER" ]; then
            DROPBEAR_MAJOR=$(echo "$DROPBEAR_VER" | cut -d. -f1)
            if [ "$DROPBEAR_MAJOR" -ge 2019 ] 2>/dev/null; then
                DROPBEAR_VERSION_OK=true
                echo -e "[ ${green}OK${NC} ] Dropbear versi $DROPBEAR_VER sudah compatible"
            else
                echo -e "[ ${yell}INFO${NC} ] Dropbear versi $DROPBEAR_VER terlalu lama"
            fi
        fi
    fi
fi

# Cek OpenSSL version
OPENSSL_VER=$(openssl version 2>/dev/null | awk '{print $2}')
OPENSSL_MAJOR=$(echo "$OPENSSL_VER" | cut -d. -f1)

# Build hanya jika perlu
if [ "$DROPBEAR_VERSION_OK" = true ]; then
    echo -e "[ ${green}OK${NC} ] Dropbear sudah compatible, skip build"
    
    # Pastikan symlink ada jika binary custom
    if [ "$DROPBEAR_2019_EXISTS" = true ]; then
        ln -sf /usr/local/dropbear-2019/sbin/dropbear /usr/local/sbin/dropbear 2>/dev/null
        ln -sf /usr/local/dropbear-2019/bin/dropbearkey /usr/local/bin/dropbearkey 2>/dev/null
    fi
elif [ "$OPENSSL_MAJOR" -ge 3 ] 2>/dev/null; then
    echo -e "[ ${yell}INFO${NC} ] OpenSSL $OPENSSL_VER terdeteksi, build dropbear 2019..."
    
    BUILD_DIR="/tmp/dropbear-build"
    OPENSSL_PREFIX="/usr/local/openssl-1.1"
    DROPBEAR_PREFIX="/usr/local/dropbear-2019"
    
    apt install -y zlib1g-dev libz-dev >/dev/null 2>&1
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Build OpenSSL 1.1.1 jika belum ada
    if [ ! -f "${OPENSSL_PREFIX}/lib/libssl.so" ]; then
        echo -e "[ ${green}INFO${NC} ] Building OpenSSL 1.1.1w..."
        wget -q https://www.openssl.org/source/openssl-1.1.1w.tar.gz
        tar xzf openssl-1.1.1w.tar.gz
        cd openssl-1.1.1w
        ./config --prefix="${OPENSSL_PREFIX}" --openssldir="${OPENSSL_PREFIX}/ssl" no-shared no-tests >/dev/null 2>&1
        make -j$(nproc) >/dev/null 2>&1
        make install_sw >/dev/null 2>&1
        cd "$BUILD_DIR"
        echo -e "[ ${green}OK${NC} ] OpenSSL 1.1.1w terinstall"
    fi
    
    # Build dropbear 2019.78
    echo -e "[ ${green}INFO${NC} ] Building dropbear 2019.78..."
    wget -q https://matt.ucc.asn.au/dropbear/releases/dropbear-2019.78.tar.bz2
    tar xjf dropbear-2019.78.tar.bz2
    cd dropbear-2019.78
    ./configure --prefix="${DROPBEAR_PREFIX}" --with-ssl="${OPENSSL_PREFIX}" --disable-zlib >/dev/null 2>&1
    make -j$(nproc) PROGRAMS="dropbear dropbearkey dbclient scp" >/dev/null 2>&1
    make install PROGRAMS="dropbear dropbearkey dbclient scp" >/dev/null 2>&1
    
    # Symlink
    ln -sf "${DROPBEAR_PREFIX}/sbin/dropbear" /usr/local/sbin/dropbear
    ln -sf "${DROPBEAR_PREFIX}/bin/dropbearkey" /usr/local/bin/dropbearkey
    echo "${OPENSSL_PREFIX}/lib" > /etc/ld.so.conf.d/openssl-1.1.conf
    ldconfig
    
    # Cleanup
    cd /root
    rm -rf "$BUILD_DIR"
    
    # Buat systemd service
    cat > /etc/systemd/system/dropbear.service <<-DEND
[Unit]
Description=Dropbear SSH Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/dropbear -F -E -p 143 -p 50000 -p 109 -p 110 -p 69
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
DEND
    systemctl daemon-reload
    systemctl enable dropbear
    systemctl restart dropbear
    
    echo -e "[ ${green}OK${NC} ] Dropbear 2019.78 + OpenSSL 1.1.1 terinstall"
else
    echo -e "[ ${green}OK${NC} ] System dropbear compatible, skip build"
fi

# ============================================================
# 7. RESTART SEMUA SERVICE
# ============================================================
echo -e "[ ${green}7/7${NC} ] Restart semua service..."

systemctl daemon-reload
service cron restart >/dev/null 2>&1

# Restart services yang aktif
for svc in xray nginx haproxy dropbear ws-dropbear ws-stunnel fail2ban; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        systemctl restart "$svc" 2>/dev/null
        echo -e "  [ ${green}ok${NC} ] $svc"
    fi
done

# Restart SSH
/etc/init.d/ssh restart >/dev/null 2>&1
echo -e "  [ ${green}ok${NC} ] ssh"

# ============================================================
# SELESAI
# ============================================================
clear
echo -e ""
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${green}       Update Selesai!${NC}"
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "  Script berhasil diupdate dari repo gg ke ggv2"
echo -e ""
echo -e "  Yang diupdate:"
echo -e "    ✓ Semua URL repo (gg -> ggv2)"
echo -e "    ✓ Menu & script (terbaru)"
echo -e "    ✓ WebSocket (Python 3)"
echo -e "    ✓ Quota & IP limit system"
echo -e "    ✓ Telegram notifikasi"
echo -e "    ✓ HAProxy (ganti stunnel4)"
echo -e "    ✓ Dropbear 2019 (jika perlu)"
echo -e ""
echo -e "  Command baru:"
echo -e "    menu         - Menu utama (tampilan baru)"
echo -e "    cek-limit    - Cek status limit user"
echo -e "    haproxy      - Cek status HAProxy"
echo -e ""
echo -e "  Port yang didukung:"
echo -e "    HTTPS: 443, 2053, 2083, 2087, 2096, 8443"
echo -e "    HTTP : 80, 8080, 8880, 2052, 2082, 2086, 2095"
echo -e ""
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "  Ketik ${cyan}menu${NC} untuk melihat tampilan baru"
echo -e ""
