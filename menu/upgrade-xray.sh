#!/bin/bash
# ============================================================
# Upgrade Xray Version
# ============================================================

green='\e[0;32m'
red='\e[1;31m'
yell='\e[1;33m'
NC='\e[0m'

clear
echo -e "${yell}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${green}       Upgrade Xray Version         ${NC}"
echo -e "${yell}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Cek versi saat ini
CURRENT_VER=$(xray version 2>/dev/null | head -1 | awk '{print $2}')
echo -e "[ ${green}INFO${NC} ] Xray versi saat ini: ${CURRENT_VER}"
echo ""

# Pilih versi
echo -e "  Pilih versi yang ingin diinstall:"
echo -e "  [${green}1${NC}] v26.3.27 (Stable - Rekomendasi)"
echo -e "  [${green}2${NC}] v26.2.6  (Stable)"
echo -e "  [${green}3${NC}] v25.12.8 (Stable)"
echo -e "  [${green}4${NC}] Custom version"
echo -e "  [${red}0${NC}] Batal"
echo ""
read -p "  Pilih [1-4]: " choice

case $choice in
    1) TARGET_VER="26.3.27" ;;
    2) TARGET_VER="26.2.6" ;;
    3) TARGET_VER="25.12.8" ;;
    4) 
        read -p "  Masukkan versi (contoh: 26.3.27): " TARGET_VER
        ;;
    0) 
        echo -e "\n  ${yell}Batal.${NC}"
        sleep 1
        m-system
        exit 0
        ;;
    *)
        echo -e "\n  ${red}Pilihan tidak valid!${NC}"
        sleep 1
        m-system
        exit 1
        ;;
esac

echo ""
echo -e "[ ${green}INFO${NC} ] Target: Xray v${TARGET_VER}"
echo -e "[ ${green}INFO${NC} ] Backup config..."
cp /etc/xray/config.json /etc/xray/config.json.bak.$(date +%Y%m%d%H%M%S)

echo -e "[ ${green}INFO${NC} ] Downloading Xray v${TARGET_VER}..."

# Download dan install
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version ${TARGET_VER}

if [ $? -eq 0 ]; then
    echo ""
    echo -e "[ ${green}OK${NC} ] Xray v${TARGET_VER} berhasil diinstall!"
    
    # Restart xray
    systemctl restart xray
    sleep 2
    
    # Verify
    NEW_VER=$(xray version 2>/dev/null | head -1 | awk '{print $2}')
    if systemctl is-active --quiet xray; then
        echo -e "[ ${green}OK${NC} ] Xray running: v${NEW_VER}"
        echo ""
        echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${green}  Upgrade berhasil!${NC}"
        echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "  Sebelum: v${CURRENT_VER}"
        echo -e "  Sesudah: v${NEW_VER}"
        echo ""
        echo -e "  Per-user stats sekarang AKTIF!"
        echo -e "  Command: cek-limit"
        echo ""
    else
        echo -e "[ ${red}ERROR${NC} ] Xray gagal start!"
        echo -e "[ ${yell}INFO${NC} ] Restore backup: cp /etc/xray/config.json.bak.* /etc/xray/config.json"
        echo -e "[ ${yell}INFO${NC} ] Cek log: journalctl -u xray --no-pager -n 20"
    fi
else
    echo -e "[ ${red}ERROR${NC} ] Gagal download/install Xray v${TARGET_VER}"
fi

echo ""
read -n 1 -s -r -p "  Press any key to back..."
m-system
