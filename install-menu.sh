#!/bin/bash
# ============================================================
# Install/Reinstall Semua Menu Script dari ggv2
# Jalankan sebagai root
# ============================================================

green='\e[0;32m'
red='\e[1;31m'
NC='\e[0m'
REPO="https://raw.githubusercontent.com/Linkershark/ggv2/aio"

clear
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${green}    Install Semua Menu Script dari ggv2${NC}"
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd /usr/bin

# ============================================================
# MENU UTAMA
# ============================================================
echo -e "[ ${green}1/6${NC} ] Download menu utama..."

wget -q -O menu "${REPO}/menu/menu.sh" && chmod +x menu && echo -e "  [${green}✓${NC}] menu" || echo -e "  [${red}✗${NC}] menu"
wget -q -O running "${REPO}/menu/running.sh" && chmod +x running && echo -e "  [${green}✓${NC}] running" || echo -e "  [${red}✗${NC}] running"
wget -q -O clearcache "${REPO}/menu/clearcache.sh" && chmod +x clearcache && echo -e "  [${green}✓${NC}] clearcache" || echo -e "  [${red}✗${NC}] clearcache"
wget -q -O restart "${REPO}/menu/restart.sh" && chmod +x restart && echo -e "  [${green}✓${NC}] restart" || echo -e "  [${red}✗${NC}] restart"
wget -q -O auto-reboot "${REPO}/menu/auto-reboot.sh" && chmod +x auto-reboot && echo -e "  [${green}✓${NC}] auto-reboot" || echo -e "  [${red}✗${NC}] auto-reboot"
wget -q -O bw "${REPO}/menu/bw.sh" && chmod +x bw && echo -e "  [${green}✓${NC}] bw" || echo -e "  [${red}✗${NC}] bw"

# ============================================================
# MENU PROTOCOL
# ============================================================
echo -e "[ ${green}2/6${NC} ] Download menu protocol..."

wget -q -O m-sshovpn "${REPO}/menu/m-sshovpn.sh" && chmod +x m-sshovpn && echo -e "  [${green}✓${NC}] m-sshovpn" || echo -e "  [${red}✗${NC}] m-sshovpn"
wget -q -O m-vmess "${REPO}/menu/m-vmess.sh" && chmod +x m-vmess && echo -e "  [${green}✓${NC}] m-vmess" || echo -e "  [${red}✗${NC}] m-vmess"
wget -q -O m-vless "${REPO}/menu/m-vless.sh" && chmod +x m-vless && echo -e "  [${green}✓${NC}] m-vless" || echo -e "  [${red}✗${NC}] m-vless"
wget -q -O m-ssws "${REPO}/menu/m-ssws.sh" && chmod +x m-ssws && echo -e "  [${green}✓${NC}] m-ssws" || echo -e "  [${red}✗${NC}] m-ssws"
wget -q -O m-trojan "${REPO}/menu/m-trojan.sh" && chmod +x m-trojan && echo -e "  [${green}✓${NC}] m-trojan" || echo -e "  [${red}✗${NC}] m-trojan"
wget -q -O m-system "${REPO}/menu/m-system.sh" && chmod +x m-system && echo -e "  [${green}✓${NC}] m-system" || echo -e "  [${red}✗${NC}] m-system"
wget -q -O m-domain "${REPO}/menu/m-domain.sh" && chmod +x m-domain && echo -e "  [${green}✓${NC}] m-domain" || echo -e "  [${red}✗${NC}] m-domain"

# ============================================================
# SSH SCRIPTS
# ============================================================
echo -e "[ ${green}3/6${NC} ] Download SSH scripts..."

wget -q -O usernew "${REPO}/ssh/usernew.sh" && chmod +x usernew && echo -e "  [${green}✓${NC}] usernew" || echo -e "  [${red}✗${NC}] usernew"
wget -q -O trial "${REPO}/ssh/trial.sh" && chmod +x trial && echo -e "  [${green}✓${NC}] trial" || echo -e "  [${red}✗${NC}] trial"
wget -q -O renew "${REPO}/ssh/renew.sh" && chmod +x renew && echo -e "  [${green}✓${NC}] renew" || echo -e "  [${red}✗${NC}] renew"
wget -q -O hapus "${REPO}/ssh/hapus.sh" && chmod +x hapus && echo -e "  [${green}✓${NC}] hapus" || echo -e "  [${red}✗${NC}] hapus"
wget -q -O cek "${REPO}/ssh/cek.sh" && chmod +x cek && echo -e "  [${green}✓${NC}] cek" || echo -e "  [${red}✗${NC}] cek"
wget -q -O member "${REPO}/ssh/member.sh" && chmod +x member && echo -e "  [${green}✓${NC}] member" || echo -e "  [${red}✗${NC}] member"
wget -q -O delete "${REPO}/ssh/delete.sh" && chmod +x delete && echo -e "  [${green}✓${NC}] delete" || echo -e "  [${red}✗${NC}] delete"
wget -q -O autokill "${REPO}/ssh/autokill.sh" && chmod +x autokill && echo -e "  [${green}✓${NC}] autokill" || echo -e "  [${red}✗${NC}] autokill"
wget -q -O ceklim "${REPO}/ssh/ceklim.sh" && chmod +x ceklim && echo -e "  [${green}✓${NC}] ceklim" || echo -e "  [${red}✗${NC}] ceklim"
wget -q -O tendang "${REPO}/ssh/tendang.sh" && chmod +x tendang && echo -e "  [${green}✓${NC}] tendang" || echo -e "  [${red}✗${NC}] tendang"
wget -q -O sshws "${REPO}/ssh/sshws.sh" && chmod +x sshws && echo -e "  [${green}✓${NC}] sshws" || echo -e "  [${red}✗${NC}] sshws"
wget -q -O add-host "${REPO}/ssh/add-host.sh" && chmod +x add-host && echo -e "  [${green}✓${NC}] add-host" || echo -e "  [${red}✗${NC}] add-host"
wget -q -O xp "${REPO}/ssh/xp.sh" && chmod +x xp && echo -e "  [${green}✓${NC}] xp" || echo -e "  [${red}✗${NC}] xp"
wget -q -O speedtest "${REPO}/ssh/speedtest_cli.py" && chmod +x speedtest && echo -e "  [${green}✓${NC}] speedtest" || echo -e "  [${red}✗${NC}] speedtest"

# ============================================================
# XRAY CREATE
# ============================================================
echo -e "[ ${green}4/6${NC} ] Download Xray create scripts..."

wget -q -O add-ws "${REPO}/xray/add-ws.sh" && chmod +x add-ws && echo -e "  [${green}✓${NC}] add-ws (vmess)" || echo -e "  [${red}✗${NC}] add-ws"
wget -q -O add-vless "${REPO}/xray/add-vless.sh" && chmod +x add-vless && echo -e "  [${green}✓${NC}] add-vless" || echo -e "  [${red}✗${NC}] add-vless"
wget -q -O add-tr "${REPO}/xray/add-tr.sh" && chmod +x add-tr && echo -e "  [${green}✓${NC}] add-tr (trojan)" || echo -e "  [${red}✗${NC}] add-tr"
wget -q -O add-ssws "${REPO}/xray/add-ssws.sh" && chmod +x add-ssws && echo -e "  [${green}✓${NC}] add-ssws (shadowsocks)" || echo -e "  [${red}✗${NC}] add-ssws"

# ============================================================
# XRAY TRIAL
# ============================================================
echo -e "[ ${green}5/6${NC} ] Download Xray trial scripts..."

wget -q -O trialvmess "${REPO}/xray/trialvmess.sh" && chmod +x trialvmess && echo -e "  [${green}✓${NC}] trialvmess" || echo -e "  [${red}✗${NC}] trialvmess"
wget -q -O trialvless "${REPO}/xray/trialvless.sh" && chmod +x trialvless && echo -e "  [${green}✓${NC}] trialvless" || echo -e "  [${red}✗${NC}] trialvless"
wget -q -O trialtrojan "${REPO}/xray/trialtrojan.sh" && chmod +x trialtrojan && echo -e "  [${green}✓${NC}] trialtrojan" || echo -e "  [${red}✗${NC}] trialtrojan"
wget -q -O trialssws "${REPO}/xray/trialssws.sh" && chmod +x trialssws && echo -e "  [${green}✓${NC}] trialssws" || echo -e "  [${red}✗${NC}] trialssws"

# ============================================================
# XRAY OTHER
# ============================================================
echo -e "[ ${green}6/6${NC} ] Download Xray other scripts..."

wget -q -O del-ws "${REPO}/xray/del-ws.sh" && chmod +x del-ws && echo -e "  [${green}✓${NC}] del-ws" || echo -e "  [${red}✗${NC}] del-ws"
wget -q -O del-vless "${REPO}/xray/del-vless.sh" && chmod +x del-vless && echo -e "  [${green}✓${NC}] del-vless" || echo -e "  [${red}✗${NC}] del-vless"
wget -q -O del-tr "${REPO}/xray/del-tr.sh" && chmod +x del-tr && echo -e "  [${green}✓${NC}] del-tr" || echo -e "  [${red}✗${NC}] del-tr"
wget -q -O del-ssws "${REPO}/xray/del-ssws.sh" && chmod +x del-ssws && echo -e "  [${green}✓${NC}] del-ssws" || echo -e "  [${red}✗${NC}] del-ssws"
wget -q -O renew-ws "${REPO}/xray/renew-ws.sh" && chmod +x renew-ws && echo -e "  [${green}✓${NC}] renew-ws" || echo -e "  [${red}✗${NC}] renew-ws"
wget -q -O renew-vless "${REPO}/xray/renew-vless.sh" && chmod +x renew-vless && echo -e "  [${green}✓${NC}] renew-vless" || echo -e "  [${red}✗${NC}] renew-vless"
wget -q -O renew-tr "${REPO}/xray/renew-tr.sh" && chmod +x renew-tr && echo -e "  [${green}✓${NC}] renew-tr" || echo -e "  [${red}✗${NC}] renew-tr"
wget -q -O renew-ssws "${REPO}/xray/renew-ssws.sh" && chmod +x renew-ssws && echo -e "  [${green}✓${NC}] renew-ssws" || echo -e "  [${red}✗${NC}] renew-ssws"
wget -q -O cek-ws "${REPO}/xray/cek-ws.sh" && chmod +x cek-ws && echo -e "  [${green}✓${NC}] cek-ws" || echo -e "  [${red}✗${NC}] cek-ws"
wget -q -O cek-vless "${REPO}/xray/cek-vless.sh" && chmod +x cek-vless && echo -e "  [${green}✓${NC}] cek-vless" || echo -e "  [${red}✗${NC}] cek-vless"
wget -q -O cek-tr "${REPO}/xray/cek-tr.sh" && chmod +x cek-tr && echo -e "  [${green}✓${NC}] cek-tr" || echo -e "  [${red}✗${NC}] cek-tr"
wget -q -O certv2ray "${REPO}/xray/certv2ray.sh" && chmod +x certv2ray && echo -e "  [${green}✓${NC}] certv2ray" || echo -e "  [${red}✗${NC}] certv2ray"

# ============================================================
# LIMIT SYSTEM
# ============================================================
echo -e "[ ${green}INFO${NC} ] Install limit system..."

mkdir -p /etc/xray/limit
wget -q -O /etc/xray/limit/xray-limit.sh "${REPO}/xray/xray-limit.sh" && chmod +x /etc/xray/limit/xray-limit.sh && echo -e "  [${green}✓${NC}] xray-limit.sh" || echo -e "  [${red}✗${NC}] xray-limit.sh"
wget -q -O /usr/local/bin/xray-limit-checker "${REPO}/xray/xray-limit-checker.sh" && chmod +x /usr/local/bin/xray-limit-checker && echo -e "  [${green}✓${NC}] xray-limit-checker" || echo -e "  [${red}✗${NC}] xray-limit-checker"
wget -q -O /usr/local/bin/cek-limit "${REPO}/xray/cek-limit.sh" && chmod +x /usr/local/bin/cek-limit && echo -e "  [${green}✓${NC}] cek-limit" || echo -e "  [${red}✗${NC}] cek-limit"

# ============================================================
# DONE
# ============================================================
echo ""
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${green}    Semua script berhasil diinstall!${NC}"
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Ketik ${green}menu${NC} untuk ke menu utama"
echo ""
