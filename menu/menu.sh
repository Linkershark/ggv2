#!/bin/bash
MYIP=$(curl -sS ipv4.icanhazip.com)
echo "Checking VPS"
#########################
IZIN=$(curl -sS https://raw.githubusercontent.com/Linkershark/ggv2/aio/permission/ip | awk '{print $4}' | grep $MYIP)
if [ $MYIP = $IZIN ]; then
echo -e "\e[32mPermission Accepted...\e[0m"
else
echo -e "\e[31mPermission Denied!\e[0m";
exit 0
fi
#EXPIRED
expired=$(curl -sS https://raw.githubusercontent.com/Linkershark/ggv2/aio/permission/ip | grep $MYIP | awk '{print $3}')
echo $expired > /root/expired.txt
today=$(date -d +1day +%Y-%m-%d)
while read expired
do
	exp=$(echo $expired | curl -sS https://raw.githubusercontent.com/Linkershark/ggv2/aio/permission/ip | grep $MYIP | awk '{print $3}')
	if [[ $exp < $today ]]; then
		Exp2="\033[1;31mExpired\033[0m"
        else
        Exp2=$(curl -sS https://raw.githubusercontent.com/Linkershark/ggv2/aio/permission/ip | grep $MYIP | awk '{print $3}')
	fi
done < /root/expired.txt
rm /root/expired.txt
Name=$(curl -sS https://raw.githubusercontent.com/Linkershark/ggv2/aio/permission/ip | grep $MYIP | awk '{print $2}')

# Color
DF='\e[39m'
Bold='\e[1m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
cyan='\e[36m'
NC='\e[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE='\033[0;33m'

# VPS Information
domain=$(cat /etc/xray/domain)
uptime="$(uptime -p | cut -d " " -f 2-10)"

# Bandwidth
dtoday="$(vnstat -i eth0 | grep "today" | awk '{print $2" "substr ($3, 1, 1)}')"
utoday="$(vnstat -i eth0 | grep "today" | awk '{print $5" "substr ($6, 1, 1)}')"
ttoday="$(vnstat -i eth0 | grep "today" | awk '{print $8" "substr ($9, 1, 1)}')"
dmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $3" "substr ($4, 1, 1)}')"
umon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $6" "substr ($7, 1, 1)}')"
tmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $9" "substr ($10, 1, 1)}')"

# CPU & RAM
cpu_usage="$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
tram=$( free -m | awk 'NR==2 {print $2}' )
uram=$( free -m | awk 'NR==2 {print $3}' )
fram=$( free -m | awk 'NR==2 {print $4}' )

# OS Info
ISP=$(curl -s ipinfo.io/org?token=192c6d2ef7a236 | cut -d " " -f 2-10)
CITY=$(curl -s ipinfo.io/city?token=192c6d2ef7a236)
IPVPS=$(curl -s ipinfo.io/ip?token=192c6d2ef7a236)
DATE2=$(date -R | cut -d " " -f -5)

# ─── Service Status ───
check_service() {
    local svc="$1"
    local status=$(systemctl is-active "$svc" 2>/dev/null)
    if [ "$status" = "active" ]; then
        echo -e "${GREEN}ON${NC}"
    else
        echo -e "${RED}OFF${NC}"
    fi
}

status_xray=$(check_service xray)
status_nginx=$(check_service nginx)
status_haproxy=$(check_service haproxy)
status_dropbear=$(check_service dropbear)
status_ws=$(check_service ws-dropbear)
status_fail2ban=$(check_service fail2ban)

# ─── Account Count ───
# Xray accounts (count by comment markers, each user has 1 WS + 1 gRPC entry)
if [ -f /etc/xray/config.json ]; then
    # Count WS entries only (each user has exactly 1 WS entry)
    acc_vmess=$(grep -c '#vmess$' /etc/xray/config.json 2>/dev/null || echo 0)
    acc_vless=$(grep -c '#vless$' /etc/xray/config.json 2>/dev/null || echo 0)
    acc_trojan=$(grep -c '#trojanws$' /etc/xray/config.json 2>/dev/null || echo 0)
    acc_ss=$(grep -c '#ssws$' /etc/xray/config.json 2>/dev/null || echo 0)
    # Total unique users (exclude REMOVED_)
    acc_total=$(grep -oP '"email":\s*"\K[^"]+' /etc/xray/config.json 2>/dev/null | grep -v "^REMOVED_" | sort -u | wc -l)
else
    acc_vmess=0; acc_vless=0; acc_trojan=0; acc_ss=0; acc_total=0
fi

# SSH accounts (count users with /bin/bash or /bin/sh, exclude system users)
acc_ssh=$(awk -F: '$7 ~ /(bash|sh|nologin|false)/ && $3 >= 1000 {count++} END {print count+0}' /etc/passwd)

# ─── DISPLAY ───
clear
echo -e "${yell} ┌─────────────────────────────────────────────────┐${NC}"
echo -e "${cyan} │                 LINKERSHARK                     │${NC}"
echo -e "${yell} └─────────────────────────────────────────────────┘${NC}"
echo -e "${yell} │${NC} OS            :  $(hostnamectl | grep "Operating System" | cut -d ' ' -f5-)"
echo -e "${yell} │${NC} IP            :  $IPVPS"
echo -e "${yell} │${NC} ASN           :  $ISP"
echo -e "${yell} │${NC} CITY          :  $CITY"
echo -e "${yell} │${NC} DOMAIN        :  $domain"
echo -e "${yell} │${NC} DATE & TIME   :  $DATE2"
echo -e "${yell} │${NC} UPTIME        :  $uptime"
echo -e "${yell} │${NC} CPU           :  ${cpu_usage} (${cores} Core)"
echo -e "${yell} │${NC} RAM           :  ${uram} MB / ${tram} MB"
echo -e "${yell} └─────────────────────────────────────────────────┘${NC}"

echo -e "${yell} ┌────────────────── SERVICE ──────────────────────┐${NC}"
echo -e "${yell} │${NC}  Xray     [${status_xray}]   Nginx    [${status_nginx}]   HAProxy  [${status_haproxy}]"
echo -e "${yell} │${NC}  Dropbear [${status_dropbear}]   WS-SSH   [${status_ws}]   Fail2ban [${status_fail2ban}]"
echo -e "${yell} └─────────────────────────────────────────────────┘${NC}"

echo -e "${yell} ┌────────────────── BANDWIDTH ────────────────────┐${NC}"
echo -e "${yell} │${NC}  Today    :  ▼ ${dtoday}  ▲ ${utoday}  = ${ttoday}"
echo -e "${yell} │${NC}  Monthly  :  ▼ ${dmon}  ▲ ${umon}  = ${tmon}"
echo -e "${yell} └─────────────────────────────────────────────────┘${NC}"

echo -e "${yell} ┌────────────────── ACCOUNTS ─────────────────────┐${NC}"
printf "${yell} │${NC}  SSH : %-4s  Vmess : %-4s  Vless : %-4s\n" "$acc_ssh" "$acc_vmess" "$acc_vless"
printf "${yell} │${NC}  SS  : %-4s  Trojan: %-4s  Total : ${Bold}%s${NC}\n" "$acc_ss" "$acc_trojan" "$acc_total"
echo -e "${yell} └─────────────────────────────────────────────────┘${NC}"

echo -e "${yell} ┌────────────────── MENU ─────────────────────────┐${NC}"
echo -e "${yell} │${NC}"
echo -e "${yell} │${NC}   [${cyan}01${NC}] SSH Menu        [${cyan}05${NC}] TROJAN Menu"
echo -e "${yell} │${NC}   [${cyan}02${NC}] VMESS Menu      [${cyan}06${NC}] SYSTEM Menu"
echo -e "${yell} │${NC}   [${cyan}03${NC}] VLESS Menu      [${cyan}07${NC}] Running Status"
echo -e "${yell} │${NC}   [${cyan}04${NC}] SHADOWSOCKS     [${cyan}08${NC}] Clear RAM"
echo -e "${yell} │${NC}"
echo -e "${yell} └─────────────────────────────────────────────────┘${NC}"

echo -e "${cyan} ┌─────────────────────────────────────────────────┐${NC}"
echo -e " ${yell}  Client Name${NC} : $Name"
echo -e " ${yell}  Expired     ${NC} : $Exp2"
echo -e "${cyan} └─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e " Press x or [ Ctrl+C ] • To-Exit-Script"
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
1) clear ; m-sshovpn ;;
2) clear ; m-vmess ;;
3) clear ; m-vless ;;
4) clear ; m-ssws ;;
5) clear ; m-trojan ;;
6) clear ; m-system ;;
7) clear ; running ;;
8) clear ; clearcache ;;
x) exit ;;
*) echo "Anda salah tekan " ; sleep 1 ; menu ;;
esac
