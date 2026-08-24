domain=$(cat /etc/xray/domain)
tls="$(cat ~/log-install.txt | grep -w "Vmess WS TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "Vmess WS none TLS" | cut -d: -f2|sed 's/ //g')"
TRIAL_HOURS=3
TRIAL_QUOTA_GB=1
user=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
source /etc/xray/limit/xray-limit.sh
save_user_limit "$user" "$TRIAL_QUOTA_GB" "0" "1" "$TRIAL_HOURS"
sed -i '/#vmess$/a\### '"$user $exp"'\\n},{"id": "'"$uuid"'","alterId": '"0"',"email": "'"$user"'"}' /etc/xray/config.json
sed -i '/#vmessgrpc$/a\### '"$user $exp"'\\n},{"id": "'"$uuid"'","alterId": '"0"',"email": "'"$user"'"}' /etc/xray/config.json

# Fixed ports for links: 443 TLS, 80 non-TLS
tls_port="443"
ntls_port="80"

# Complete Vmess links with all parameters (base64 encoded JSON)
vmess_json1='{"v":"2","ps":"'"${user}"'","add":"'"${domain}"'","port":"'"${tls_port}"'","id":"'"${uuid}"'","aid":"0","net":"ws","path":"/vmess","type":"none","host":"'"${domain}"'","tls":"tls","sni":"'"${domain}"'"}'
vmess_json2='{"v":"2","ps":"'"${user}"'","add":"'"${domain}"'","port":"'"${ntls_port}"'","id":"'"${uuid}"'","aid":"0","net":"ws","path":"/vmess","type":"none","host":"'"${domain}"'","tls":"none"}'
vmess_json3='{"v":"2","ps":"'"${user}"'","add":"'"${domain}"'","port":"'"${tls_port}"'","id":"'"${uuid}"'","aid":"0","net":"grpc","path":"vmess-grpc","type":"none","host":"'"${domain}"'","tls":"tls","sni":"'"${domain}"'"}'

vmesslink1="vmess://$(echo "$vmess_json1" | base64 -w 0)"
vmesslink2="vmess://$(echo "$vmess_json2" | base64 -w 0)"
vmesslink3="vmess://$(echo "$vmess_json3" | base64 -w 0)"

systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1
clear

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m       Trial Vmess        \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "Wildcard       : (bug.com).${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${none}"
echo -e "Port gRPC      : ${tls}"
echo -e "id             : ${uuid}"
echo -e "alterId        : 0"
echo -e "Security       : auto"
echo -e "Network        : ws"
echo -e "Path           : /vmess"
echo -e "ServiceName    : vmess-grpc"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS       : ${vmesslink1}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link none TLS  : ${vmesslink2}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link gRPC      : ${vmesslink3}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On     : $exp"
echo -e "Trial Duration : ${TRIAL_HOURS} jam"
echo -e "Quota Limit    : ${TRIAL_QUOTA_GB} GB"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu