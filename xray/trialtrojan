domain=$(cat /etc/xray/domain)
tls="$(cat ~/log-install.txt | grep -w "Trojan WS TLS" | cut -d: -f2|sed 's/ //g')"
ntls="$(cat ~/log-install.txt | grep -w "Trojan WS none TLS" | cut -d: -f2|sed 's/ //g')"
TRIAL_HOURS=3
TRIAL_QUOTA_GB=1
user=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
source /etc/xray/limit/xray-limit.sh
save_user_limit "$user" "$TRIAL_QUOTA_GB" "0" "1" "$TRIAL_HOURS"
sed -i '/#trojanws$/a\#! '"$user $exp"'\\n},{"password": "'"$uuid"'","email": "'"$user"'"}' /etc/xray/config.json
sed -i '/#trojangrpc$/a\#! '"$user $exp"'\\n},{"password": "'"$uuid"'","email": "'"$user"'"}' /etc/xray/config.json

# Fixed ports for links: 443 TLS, 80 non-TLS
tls_port="443"
ntls_port="80"

# Complete Trojan links with all parameters
trojanlink1="trojan://${uuid}@${domain}:${tls_port}?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojanlink2="trojan://${uuid}@${domain}:${ntls_port}?path=%2Ftrojan-ws&security=none&host=${domain}&type=ws#${user}"
trojanlink3="trojan://${uuid}@${domain}:${tls_port}?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}"

systemctl restart xray
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m           TRIAL TROJAN           \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Host/IP        : ${domain}"
echo -e "Wildcard       : (bug.com).${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${ntls}"
echo -e "Port gRPC      : ${tls}"
echo -e "Key            : ${uuid}"
echo -e "Path           : /trojan-ws"
echo -e "ServiceName    : trojan-grpc"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS       : ${trojanlink1}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link none TLS  : ${trojanlink2}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link gRPC      : ${trojanlink3}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On     : $exp"
echo -e "Trial Duration : ${TRIAL_HOURS} jam"
echo -e "Quota Limit    : ${TRIAL_QUOTA_GB} GB"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu