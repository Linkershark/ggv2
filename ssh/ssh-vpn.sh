#!/bin/bash
#
# ==================================================

# Color definitions
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
NC='\e[0m'

# etc
apt dist-upgrade -y
apt install netfilter-persistent -y
apt-get remove --purge ufw firewalld -y
apt install -y screen curl jq bzip2 gzip vnstat coreutils rsyslog iftop zip unzip git apt-transport-https build-essential -y

# Pastikan python3 tersedia (websocket scripts sudah ported ke python3)
if ! command -v python3 &>/dev/null; then
    echo -e "[ ${green}INFO${NC} ] Installing python3..."
    apt install -y python3
fi

# initializing var
export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- ipinfo.io/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

#detail nama perusahaan
country=ID
state=Indonesia
locality=Jakarta
organization=none
organizationalunit=none
commonname=none
email=none

# simple password minimal
curl -sS https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/password | openssl aes-256-cbc -d -a -pass pass:scvps07gg -pbkdf2 > /etc/pam.d/common-password
chmod +x /etc/pam.d/common-password

# go to root
cd

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

#update
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y

#install jq
apt -y install jq

#install shc
apt -y install shc

# install wget and curl
apt -y install wget curl

#figlet
apt-get install figlet -y
apt-get install ruby -y
gem install lolcat

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config


install_ssl(){
    if [ -f "/usr/bin/apt-get" ];then
            isDebian=`cat /etc/issue|grep Debian`
            if [ "$isDebian" != "" ];then
                    apt-get install -y nginx certbot
                    apt install -y nginx certbot
                    sleep 3s
            else
                    apt-get install -y nginx certbot
                    apt install -y nginx certbot
                    sleep 3s
            fi
    else
        yum install -y nginx certbot
        sleep 3s
    fi

    systemctl stop nginx.service

    if [ -f "/usr/bin/apt-get" ];then
            isDebian=`cat /etc/issue|grep Debian`
            if [ "$isDebian" != "" ];then
                    echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
                    sleep 3s
            else
                    echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
                    sleep 3s
            fi
    else
        echo "Y" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
        sleep 3s
    fi
}

# install webserver
apt -y install nginx
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/nanotechid/supreme/aio/ssh/nginx.conf"
mkdir -p /home/vps/public_html
/etc/init.d/nginx restart

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/nanotechid/supreme/aio/ssh/newudpgw"
chmod +x /usr/bin/badvpn-udpgw
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500' /etc/rc.local
#sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500' /etc/rc.local
#sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500' /etc/rc.local
#sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500' /etc/rc.local
#sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500' /etc/rc.local
#sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500' /etc/rc.local
#sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500' /etc/rc.local
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500

# setting port ssh
cd
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 500' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 40000' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 51443' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 58080' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 200' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 22' /etc/ssh/sshd_config
/etc/init.d/ssh restart

echo "=== Install Dropbear ==="
# install dropbear
# Deteksi versi OS dan OpenSSL untuk kompatibilitas
source /etc/os-release 2>/dev/null
OS_VER="${VERSION_ID:-0}"
OPENSSL_VER=$(openssl version 2>/dev/null | awk '{print $2}')
OPENSSL_MAJOR=$(echo "$OPENSSL_VER" | cut -d. -f1)

# Fungsi: build OpenSSL 1.1.1 terisolasi + dropbear 2019 dari source
build_dropbear_isolated() {
    local BUILD_DIR="/tmp/dropbear-build"
    local OPENSSL_PREFIX="/usr/local/openssl-1.1"
    local DROPBEAR_PREFIX="/usr/local/dropbear-2019"
    
    echo -e "[ ${yell}INFO${NC} ] System dropbear tidak kompatibel, building dari source..."
    echo -e "[ ${yell}INFO${NC} ] OpenSSL ${OPENSSL_VER} terdeteksi, building OpenSSL 1.1.1 terisolasi..."
    
    apt install -y zlib1g-dev libz-dev 2>/dev/null
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Build OpenSSL 1.1.1w (isolated, tidak ganggu system OpenSSL)
    if [ ! -f "${OPENSSL_PREFIX}/lib/libssl.so" ]; then
        echo -e "[ ${green}INFO${NC} ] Downloading OpenSSL 1.1.1w..."
        wget -q https://www.openssl.org/source/openssl-1.1.1w.tar.gz
        tar xzf openssl-1.1.1w.tar.gz
        cd openssl-1.1.1w
        echo -e "[ ${green}INFO${NC} ] Building OpenSSL 1.1.1w (isolated ke ${OPENSSL_PREFIX})..."
        ./config --prefix="${OPENSSL_PREFIX}" --openssldir="${OPENSSL_PREFIX}/ssl" \
            no-shared no-tests 2>&1 | tail -3
        make -j$(nproc) 2>&1 | tail -3
        make install_sw 2>&1 | tail -3
        cd "$BUILD_DIR"
        echo -e "[ ${green}OK${NC} ] OpenSSL 1.1.1w terinstall di ${OPENSSL_PREFIX}"
    else
        echo -e "[ ${green}OK${NC} ] OpenSSL 1.1.1 sudah ada di ${OPENSSL_PREFIX}"
    fi
    
    # Build dropbear 2019.78 dengan OpenSSL 1.1.1 terisolasi
    if [ ! -f "${DROPBEAR_PREFIX}/sbin/dropbear" ]; then
        echo -e "[ ${green}INFO${NC} ] Downloading dropbear 2019.78..."
        wget -q https://matt.ucc.asn.au/dropbear/releases/dropbear-2019.78.tar.bz2
        tar xjf dropbear-2019.78.tar.bz2
        cd dropbear-2019.78
        echo -e "[ ${green}INFO${NC} ] Building dropbear 2019.78 dengan OpenSSL 1.1.1..."
        ./configure --prefix="${DROPBEAR_PREFIX}" \
            --with-ssl="${OPENSSL_PREFIX}" \
            --disable-zlib 2>&1 | tail -3
        make -j$(nproc) PROGRAMS="dropbear dropbearkey dbclient scp" 2>&1 | tail -5
        make install PROGRAMS="dropbear dropbearkey dbclient scp" 2>&1 | tail -3
        cd "$BUILD_DIR"
        echo -e "[ ${green}OK${NC} ] Dropbear 2019.78 terinstall di ${DROPBEAR_PREFIX}"
    else
        echo -e "[ ${green}OK${NC} ] Dropbear 2019 sudah ada di ${DROPBEAR_PREFIX}"
    fi
    
    # Buat symlink agar systemd service bisa jalan
    ln -sf "${DROPBEAR_PREFIX}/sbin/dropbear" /usr/local/sbin/dropbear
    ln -sf "${DROPBEAR_PREFIX}/bin/dropbearkey" /usr/local/bin/dropbearkey
    ln -sf "${DROPBEAR_PREFIX}/bin/dbclient" /usr/local/bin/dbclient
    ln -sf "${DROPBEAR_PREFIX}/bin/scp" /usr/local/bin/scp-2019
    
    # Update library path agar OpenSSL 1.1 bisa ditemukan
    echo "${OPENSSL_PREFIX}/lib" > /etc/ld.so.conf.d/openssl-1.1.conf
    ldconfig
    
    # Cleanup build dir
    cd /root
    rm -rf "$BUILD_DIR"
    
    echo -e "[ ${green}OK${NC} ] Dropbear 2019.78 + OpenSSL 1.1.1 siap digunakan"
}

# Cek apakah dropbear 2019 sudah diinstall (dari build sebelumnya)
if [ -f "/usr/local/dropbear-2019/sbin/dropbear" ]; then
    echo -e "[ ${green}INFO${NC} ] Dropbear 2019 sudah terinstall, skip build"
    ln -sf /usr/local/dropbear-2019/sbin/dropbear /usr/local/sbin/dropbear
elif [ "$OPENSSL_MAJOR" -ge 3 ] 2>/dev/null; then
    # OpenSSL 3.x (Debian 12, Ubuntu 22+) -> butuh build isolated
    build_dropbear_isolated
else
    # Coba install system dropbear dulu
    apt -y install dropbear 2>/dev/null
    if ! command -v dropbear &>/dev/null; then
        echo -e "[ ${yell}WARNING${NC} ] System dropbear gagal, building dari source..."
        build_dropbear_isolated
    fi
fi

# Tentukan path dropbear binary yang akan dipakai
if [ -f "/usr/local/sbin/dropbear" ]; then
    DROPBEAR_BIN="/usr/local/sbin/dropbear"
else
    DROPBEAR_BIN="/usr/sbin/dropbear"
fi

# Ensure dropbear directory exists and generate host keys
mkdir -p /etc/dropbear
if [ ! -f /etc/dropbear/dropbear_rsa_host_key ]; then
    echo -e "[ ${green}INFO${NC} ] Generating dropbear RSA host key..."
    dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key >/dev/null 2>&1
fi
if [ ! -f /etc/dropbear/dropbear_dss_host_key ]; then
    echo -e "[ ${green}INFO${NC} ] Generating dropbear DSS host key..."
    dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key >/dev/null 2>&1
fi
if [ ! -f /etc/dropbear/dropbear_ecdsa_host_key ]; then
    echo -e "[ ${green}INFO${NC} ] Generating dropbear ECDSA host key..."
    dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key >/dev/null 2>&1
fi

sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 50000 -p 109 -p 110 -p 69"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells

# Buat systemd service dropbear jika pakai build custom
if [ "$DROPBEAR_BIN" = "/usr/local/sbin/dropbear" ]; then
    cat > /etc/systemd/system/dropbear.service <<-DEND
[Unit]
Description=Dropbear SSH Server
After=network.target

[Service]
Type=simple
ExecStart=${DROPBEAR_BIN} -F -E -p 143 -p 50000 -p 109 -p 110 -p 69
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
DEND
    systemctl daemon-reload
    systemctl enable dropbear
    systemctl restart dropbear
else
    /etc/init.d/ssh restart
    /etc/init.d/dropbear restart
fi

cd
# stunnel4 digantikan oleh HAProxy (diinstall dari setup.sh setelah ini)
# install-haproxy.sh akan handle TLS termination + optimasi koneksi


# install fail2ban
apt -y install fail2ban

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'


echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear
cat> /etc/issue.net << END
<p style="text-align:center">

<font color="cyan"><b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</br></font><br>
<font color="red"><b>SERVER BY SHINEVPN STORE</b></font><br>
<font color="cyan"><b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</br></font><br>
=========RULES=========<br>
<br>
• Jangan digunakan untuk kegiatan illegal<br>
• Jangan Over downloading<br>
• Jangan lupa order banh :v <br>
<br>
<font color="cyan"><b>━━━━━━━━━━━━━━━━━━━━━━━━━</br></font><br>
<font color="red"><b>Contact: </b></font><br>
<br>
<font color="red"><b>Telegram   : https://t.me/ShineStores</b></font><br>
<font color="red"><b>Whatsapp   : https://wa.me/+6282190464598</b></font><br>
<br>
<font color="red"><b>Testimoni  : https://t.me/Shyneest</b></font><br>
<font color="cyan"><b>━━━━━━━━━━━━━━━━━━━━━━━━━</br></font><br>
END

#install bbr dan optimasi kernel
#wget https://raw.githubusercontent.com/nanotechid/supreme/aio/ssh/bbr.sh && chmod +x bbr.sh && ./bbr.sh

# blokir torrent
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# download script
cd /usr/bin
# menu
wget -O menu "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/menu.sh"
wget -O m-vmess "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/m-vmess.sh"
wget -O m-vless "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/m-vless.sh"
wget -O running "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/running.sh"
wget -O clearcache "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/clearcache.sh"
wget -O m-ssws "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/m-ssws.sh"
wget -O m-trojan "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/m-trojan.sh"

# menu ssh ovpn
wget -O m-sshovpn "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/m-sshovpn.sh"
wget -O usernew "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/trial.sh"
wget -O renew "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/renew.sh"
wget -O hapus "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/hapus.sh"
wget -O cek "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/cek.sh"
wget -O member "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/member.sh"
wget -O delete "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/delete.sh"
wget -O autokill "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/autokill.sh"
wget -O ceklim "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/ceklim.sh"
wget -O tendang "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/tendang.sh"
wget -O sshws "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/sshws.sh"

# menu system
wget -O m-system "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/m-system.sh"
wget -O m-domain "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/m-domain.sh"
wget -O add-host "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/add-host.sh"
#wget -O port-change "https://raw.githubusercontent.com/Linkershark/ggv2/aio/port/port-change.sh"
wget -O certv2ray "https://raw.githubusercontent.com/Linkershark/ggv2/aio/xray/certv2ray.sh"
#wget -O m-webmin "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/m-webmin.sh"
wget -O speedtest "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/speedtest_cli.py"
#wget -O about "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/about.sh"
wget -O auto-reboot "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/auto-reboot.sh"
wget -O restart "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/restart.sh"
wget -O bw "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/bw.sh"
wget -O m-tcp "https://raw.githubusercontent.com/Linkershark/ggv2/aio/menu/tcp.sh"

# change port
#wget -O port-ssl "https://raw.githubusercontent.com/Linkershark/ggv2/aio/port/port-ssl.sh"
#wget -O port-ovpn "https://raw.githubusercontent.com/Linkershark/ggv2/aio/port/port-ovpn.sh"
#wget -O port-tr "https://raw.githubusercontent.com/Linkershark/ggv2/aio/port/port-tr.sh"


wget -O xp "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/xp.sh"
#wget -O asu "https://raw.githubusercontent.com/Linkershark/ggv2/aio/asu.sh"
wget -O sshws "https://raw.githubusercontent.com/Linkershark/ggv2/aio/ssh/sshws.sh"

chmod +x menu
chmod +x m-vmess
chmod +x m-vless
chmod +x running
chmod +x clearcache
chmod +x m-ssws
chmod +x m-trojan

chmod +x m-sshovpn
chmod +x usernew
chmod +x trial
chmod +x renew
chmod +x hapus
chmod +x cek
chmod +x member
chmod +x delete
chmod +x autokill
chmod +x ceklim
chmod +x tendang
chmod +x sshws

chmod +x m-system
chmod +x m-domain
chmod +x add-host
#chmod +x port-change
chmod +x certv2ray
#chmod +x m-webmin
chmod +x speedtest
#chmod +x about
chmod +x auto-reboot
chmod +x restart
chmod +x bw
chmod +x m-tcp

#chmod +x port-ssl
#chmod +x port-ovpn
#chmod +x port-tr
chmod +x xp
#chmod +x asu
chmod +x sshws
cd


cat > /etc/cron.d/re_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 2 * * * root /sbin/reboot
END

cat > /etc/cron.d/xp_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/xp
END

cat > /home/re_otm <<-END
7
END

service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1

# remove unnecessary files
sleep 0.5
echo -e "[ ${green}INFO$NC ] Clearing trash"
apt autoclean -y >/dev/null 2>&1

if dpkg -s unscd >/dev/null 2>&1; then
apt -y remove --purge unscd >/dev/null 2>&1
fi

apt-get -y --purge remove samba* >/dev/null 2>&1
apt-get -y --purge remove apache2* >/dev/null 2>&1
apt-get -y --purge remove bind9* >/dev/null 2>&1
apt-get -y remove sendmail* >/dev/null 2>&1
apt autoremove -y >/dev/null 2>&1
# finishing
cd
chown -R www-data:www-data /home/vps/public_html
sleep 0.5
echo -e "$yell[SERVICE]$NC Restart All service SSH & OVPN"
/etc/init.d/nginx restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${green}ok${NC} ] Restarting nginx"
/etc/init.d/openvpn restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${green}ok${NC} ] Restarting cron "
/etc/init.d/ssh restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${green}ok${NC} ] Restarting ssh "
/etc/init.d/dropbear restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${green}ok${NC} ] Restarting dropbear "
/etc/init.d/fail2ban restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${green}ok${NC} ] Restarting fail2ban "
/etc/init.d/vnstat restart >/dev/null 2>&1
sleep 0.5
echo -e "[ ${green}ok${NC} ] Restarting vnstat "
/etc/init.d/squid restart >/dev/null 2>&1

screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
#screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500
history -c
echo "unset HISTFILE" >> /etc/profile


rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/ssh-vpn.sh
rm -f /root/bbr.sh

# finihsing
clear
