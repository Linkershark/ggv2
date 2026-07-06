#!/bin/bash
# ============================================
# Xray Limit Checker - Cron Job
# Jalankan setiap 1-2 menit via cron
# Cek quota, IP limit, dan trial expiry
# ============================================

source /etc/xray/limit/xray-limit.sh

LIMIT_DIR="/etc/xray/limit"
LOG_FILE="/var/log/xray-limit.log"

# Pastikan direktori ada
init_limit_dir

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Scan semua file limit
for limit_file in "${LIMIT_DIR}"/*.limit; do
    [ -f "$limit_file" ] || continue
    
    user=$(grep "^USER=" "$limit_file" | cut -d= -f2)
    [ -z "$user" ] && continue
    
    disabled=$(grep "^DISABLED=" "$limit_file" | cut -d= -f2)
    [ "$disabled" = "1" ] && continue
    
    is_trial=$(grep "^IS_TRIAL=" "$limit_file" | cut -d= -f2)
    
    # === CEK TRIAL EXPIRED ===
    if [ "$is_trial" = "1" ]; then
        expired=$(check_trial_expired "$user")
        if [ "$expired" = "1" ]; then
            log_msg "TRIAL EXPIRED: $user - removing from xray"
            remove_user_from_xray "$user"
            disable_user "$user" "expired"
            notify_trial_expired "$user"
            continue
        fi
    fi
    
    # === CEK QUOTA ===
    quota_exceeded=$(check_quota_exceeded "$user")
    if [ "$quota_exceeded" = "1" ]; then
        quota_gb=$(get_user_limit "$user" "QUOTA_GB")
        used_bytes=$(get_user_limit "$user" "USED_BYTES")
        used_fmt=$(format_bytes "$used_bytes")
        log_msg "QUOTA EXCEEDED: $user (${quota_gb}GB) - removing from xray"
        remove_user_from_xray "$user"
        disable_user "$user" "quota"
        notify_limit_hit "$user" "Quota Habis" "${used_fmt} / ${quota_gb}GB"
        continue
    fi
    
    # === CEK IP LIMIT ===
    ip_exceeded=$(check_ip_exceeded "$user")
    if [ "$ip_exceeded" = "1" ]; then
        ip_limit=$(get_user_limit "$user" "IP_LIMIT")
        ip_count=$(get_user_ip_count "$user")
        log_msg "IP LIMIT EXCEEDED: $user (max ${ip_limit} IP) - removing from xray"
        remove_user_from_xray "$user"
        disable_user "$user" "ip_limit"
        notify_limit_hit "$user" "IP Limit Terlampaui" "${ip_count} / ${ip_limit} IP"
        continue
    fi
done

# Cleanup log jika terlalu besar (>10MB)
if [ -f "$LOG_FILE" ]; then
    log_size=$(stat -c%s "$LOG_FILE" 2>/dev/null)
    if [ "$log_size" -gt 10485760 ]; then
        tail -1000 "$LOG_FILE" > "${LOG_FILE}.tmp"
        mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi
fi
