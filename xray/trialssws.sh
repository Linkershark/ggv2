domain=$(cat /etc/xray/domain)
tls="$(cat ~/log-install.txt | grep -w "Shadowsocks WS TLS" | cut -d: -f2|sed 's/ //g')"
ntls="$(cat ~/log-install.txt | grep -w "Shadowsocks WS none TLS" | cut -d: -f2|sed 's/ //g')"
user=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
cipher="aes-128-gcm"
TRIAL_HOURS=3
TRIAL_QUOTA_GB=1
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
source /etc/xray/limit/xray-limit.sh
save_user_limit "$user" "$TRIAL_QUOTA_GB" "0" "1" "$TRIAL_HOURS"
sed -i '/#ssws$/a\### '"$user $exp"'\\n},{"password": "'"$uuid"'","method": "'"$cipher"'","email": "'"$user"'"}' /etc/xray/config.json
sed -i '/#ssgrpc$/a\### '"$user $exp"'\\n},{"password": "'"$uuid"'","method": "'"$cipher"'","email": "'"$user"'"}' /etc/xray/config.json

# Fixed ports for links: 443 TLS, 80 non-TLS
tls_port="443"
ntls_port="80"

# Complete Shadowsocks links with all parameters
echo -n "${cipher}:${uuid}" | base64 -w 0 > /tmp/ss_base64
ss_base64=$(cat /tmp/ss_base64)

shadowsockslink="ss://${ss_base64}@${domain}:${tls_port}?path=%2Fss-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
shadowsockslink1="ss://${ss_base64}@${domain}:${ntls_port}?path=%2Fss-ws&security=none&host=${domain}&type=ws#${user}"
shadowsockslink2="ss://${ss_base64}@${domain}:${tls_port}?mode=gun&security=tls&type=grpc&serviceName=ss-grpc&sni=${domain}#${user}"

systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m        Shadowsocks Account      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "Wildcard       : (bug.com).${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${ntls}"
echo -e "Port gRPC      : ${tls}"
echo -e "Password       : ${uuid}"
echo -e "Ciphers        : ${cipher}"
echo -e "Network        : ws/grpc"
echo -e "Path           : /ss-ws"
echo -e "ServiceName    : ss-grpc"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS       : ${shadowsockslink}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link none TLS  : ${shadowsockslink1}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link gRPC      : ${shadowsockslink2}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On     : $exp"
echo -e "Trial Duration : ${TRIAL_HOURS} jam"
echo -e "Quota Limit    : ${TRIAL_QUOTA_GB} GB"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "" | tee -a /etc/log-create-user.log
read -n 1 -s -r -p "Press any key to back on menu"
menu