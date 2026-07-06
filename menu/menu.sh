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
# Color Validation
DF='\e[39m'
Bold='\e[1m'
Blink='\e[5m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
cyan='\e[36m'
Lred='\e[91m'
Lgreen='\e[92m'
Lyellow='\e[93m'
NC='\e[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LIGHT='\033[0;37m'
# VPS Information
#Domain
domain=$(cat /etc/xray/domain)
#Status certificate
modifyTime=$(stat $HOME/.acme.sh/${domain}_ecc/${domain}.key | sed -n '7,6p' | awk '{print $2" "$3" "$4" "$5}')
modifyTime1=$(date +%s -d "${modifyTime}")
currentTime=$(date +%s)
stampDiff=$(expr ${currentTime} - ${modifyTime1})
days=$(expr ${stampDiff} / 86400)
remainingDays=$(expr 90 - ${days})
tlsStatus=${remainingDays}
if [[ ${remainingDays} -le 0 ]]; then
	tlsStatus="expired"
fi
# OS Uptime
uptime="$(uptime -p | cut -d " " -f 2-10)"
# Download
#Download/Upload today
dtoday="$(vnstat -i eth0 | grep "today" | awk '{print $2" "substr ($3, 1, 1)}')"
utoday="$(vnstat -i eth0 | grep "today" | awk '{print $5" "substr ($6, 1, 1)}')"
ttoday="$(vnstat -i eth0 | grep "today" | awk '{print $8" "substr ($9, 1, 1)}')"
#Download/Upload yesterday
dyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $2" "substr ($3, 1, 1)}')"
uyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $5" "substr ($6, 1, 1)}')"
tyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $8" "substr ($9, 1, 1)}')"
#Download/Upload current month
dmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $3" "substr ($4, 1, 1)}')"
umon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $6" "substr ($7, 1, 1)}')"
tmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $9" "substr ($10, 1, 1)}')"
# Getting CPU Information
cpu_usage1="$(ps aux | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}')"
cpu_usage="$((${cpu_usage1/\.*} / ${corediilik:-1}))"
cpu_usage+=" %"
ISP=$(curl -s ipinfo.io/org?token=192c6d2ef7a236 | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city?token=192c6d2ef7a236 )
WKT=$(curl -s ipinfo.io/timezone?token=192c6d2ef7a236 )
DAY=$(date +%A)
DATE=$(date +%m/%d/%Y)
DATE2=$(date -R | cut -d " " -f -5)
IPVPS=$(curl -s ipinfo.io/ip?token=192c6d2ef7a236 )
cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
tram=$( free -m | awk 'NR==2 {print $2}' )
uram=$( free -m | awk 'NR==2 {print $3}' )
fram=$( free -m | awk 'NR==2 {print $4}' )
nginx=$( systemctl status nginx | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $nginx == "running" ]]; then
    status_nginx="${GREEN}ON ${NC} "
else
    status_nginx="${RED}OFF ${NC} "
fi

##xray
xxray=$( systemctl status nginx | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $xxray == "running" ]]; then
    status_xray="${GREEN}ON ${NC} "
else
    status_xray="${RED}OFF ${NC} "
fi

clear 
echo -e "\e[33m ┌─────────────────────────────────────────────────┐"
echo -e "${cyan} │                 LINKERSHARK                     │"
echo -e "${cyan} └─────────────────────────────────────────────────┘"
echo -e "\e[33m | OS            \e[0m:  "`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
echo -e "\e[33m | IP            \e[0m:  $IPVPS"
echo -e "\e[33m | ASN           \e[0m:  $ISP"
echo -e "\e[33m | CITY          \e[0m:  $CITY"
echo -e "\e[33m | DOMAIN        \e[0m:  $domain"
echo -e "\e[33m | DATE & TIME   \e[0m:  $DATE2"
echo -e "\e[33m └─────────────────────────────────────────────────┘\033[0m"
echo -e "\e[33m                       STATUS                              "
echo -e ""
echo -e "${cyan}          [ NGINX : $status_nginx   XRAY : $status_xray ]      \033[0m"
echo -e "\e[33m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "                 • SCRIPT MENU •                 "
echo -e "\e[33m ┌─────────────────────────────────────────────────┐\033[0m"
echo -e ""
echo -e "    [\e[36m01\e[0m] SSH Menu"
echo -e "    [\e[36m02\e[0m] VMESS Menu"
echo -e "    [\e[36m03\e[0m] VLESS Menu"
echo -e "    [\e[36m04\e[0m] SHADOWSOCKS Menu"
echo -e "    [\e[36m05\e[0m] TROJAN Menu"
echo -e "    [\e[36m06\e[0m] SYSTEM Menu"
echo -e "    [\e[36m07\e[0m] STATUS Service"
echo -e "    [\e[36m08\e[0m] CLEAR RAM Cache"
echo -e   ""
echo -e "\e[33m └─────────────────────────────────────────────────┘\033[0m"
echo -e "${cyan} ┌─────────────────────────────────────────────────┐"
echo -e " \e[33m  Client Name \E[0m: $Name"
echo -e " \e[33m  Expired     \E[0m: $Exp2"
echo -e "\e[33m └─────────────────────────────────────────────────┘\033[0m"
echo -e ""
echo -e " Press x or [ Ctrl+C ] • To-Exit-Script "
echo -e ""
read -p " Select menu :  "  opt
echo -e   ""
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
