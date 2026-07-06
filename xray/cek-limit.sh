#!/bin/bash
# ============================================
# Cek Limit Xray - Admin Command
# Usage: cek-limit [username]
# Jika tanpa argumen, tampilkan semua user
# ============================================

export TERM=dumb
source /etc/xray/limit/xray-limit.sh

LIMIT_DIR="/etc/xray/limit"
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
NC='\e[0m'

init_limit_dir

if [ -n "$1" ]; then
    # Cek user tertentu
    user="$1"
    limit_file="${LIMIT_DIR}/${user}.limit"
    
    if [ ! -f "$limit_file" ]; then
        echo -e "${red}User '${user}' tidak ditemukan di database limit${NC}"
        exit 1
    fi
    
    source "$limit_file"
    
    # Hitung bandwidth
    used_bytes=$(get_user_bandwidth "$user")
    update_used_bytes "$user" "$used_bytes"
    used_fmt=$(format_bytes "$used_bytes")
    quota_fmt=$(format_bytes "$QUOTA_BYTES")
    
    # Status
    if [ "$DISABLED" = "1" ]; then
        reason=$(grep "^DISABLED_REASON=" "$limit_file" | cut -d= -f2)
        status="${red}DISABLED (${reason})${NC}"
    else
        status="${green}ACTIVE${NC}"
    fi
    
    # Trial info
    if [ "$IS_TRIAL" = "1" ]; then
        trial_info="Ya ($(get_trial_remaining "$user"))"
    else
        trial_info="Tidak"
    fi
    
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\\\E[0;41;36m      Xray Limit Status      \\E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "Username      : ${user}"
    echo -e "Status        : $(echo -e "$status")"
    echo -e "Trial         : ${trial_info}"
    echo -e "Quota         : ${used_fmt} / ${quota_fmt}"
    if [ "$QUOTA_BYTES" -gt 0 ]; then
        pct=$((used_bytes * 100 / QUOTA_BYTES))
        echo -e "Penggunaan    : ${pct}%"
    fi
    echo -e "IP Limit      : ${IP_LIMIT} device(s)"
    echo -e "IP Terhubung  : $(get_user_ip_count "$user")"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
else
    # Tampilkan semua user
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\\\E[0;41;36m                    Xray Limit Summary                    \\E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    printf "%-15s %-10s %-8s %-15s %-8s %-6s\n" "USERNAME" "STATUS" "TRIAL" "QUOTA" "IP" "USED"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    
    count=0
    for limit_file in "${LIMIT_DIR}"/*.limit; do
        [ -f "$limit_file" ] || continue
        
        user=$(grep "^USER=" "$limit_file" | cut -d= -f2)
        [ -z "$user" ] && continue
        
        source "$limit_file"
        
        # Status
        if [ "$DISABLED" = "1" ]; then
            status="DISABLED"
        else
            status="ACTIVE"
        fi
        
        # Trial
        if [ "$IS_TRIAL" = "1" ]; then
            trial="Ya"
        else
            trial="No"
        fi
        
        # Quota
        used_bytes=$(get_user_bandwidth "$user")
        update_used_bytes "$user" "$used_bytes"
        if [ "$QUOTA_BYTES" -gt 0 ]; then
            used_fmt=$(format_bytes "$used_bytes")
            quota_fmt=$(format_bytes "$QUOTA_BYTES")
            quota="${used_fmt} / ${quota_fmt}"
        else
            quota="Unlimited"
        fi
        
        # IP
        if [ "$IP_LIMIT" -gt 0 ]; then
            ip_info="${IP_LIMIT}"
        else
            ip_info="Unlim"
        fi
        
        ip_count=$(get_user_ip_count "$user")
        
        printf "%-15s %-10s %-8s %-15s %-8s %-6s\n" "$user" "$status" "$trial" "$quota" "$ip_info" "$ip_count"
        count=$((count + 1))
    done
    
    if [ "$count" -eq 0 ]; then
        echo -e "  ${yell}Belum ada user dengan limit${NC}"
    fi
    
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "Total: ${count} user(s)"
fi
