#!/bin/bash
# ============================================
# Xray Quota & IP Limit Library
# Source this file: source /etc/xray/limit/xray-limit.sh
# ============================================

LIMIT_DIR="/etc/xray/limit"
XRAY_API="127.0.0.1:10085"
TELEGRAM_CONF="${LIMIT_DIR}/telegram.conf"

# Load Telegram config jika ada
load_telegram_config() {
    if [ -f "$TELEGRAM_CONF" ]; then
        source "$TELEGRAM_CONF"
    fi
}

# Kirim notifikasi Telegram
# Args: $1=message
send_telegram() {
    local msg="$1"
    load_telegram_config
    
    if [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ]; then
        return 1
    fi
    
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" \
        -d "text=${msg}" \
        -d "parse_mode=HTML" \
        >/dev/null 2>&1 &
}

# Kirim notifikasi limit exceeded
# Args: $1=username $2=reason $3=detail
notify_limit_hit() {
    local user="$1"
    local reason="$2"
    local detail="$3"
    local hostname=$(hostname)
    local now=$(date '+%Y-%m-%d %H:%M:%S')
    
    local msg="🚨 <b>LIMIT XRAY - ${hostname}</b>

👤 User: <code>${user}</code>
⚠️ Alasan: ${reason}
📊 Detail: ${detail}
🕐 Waktu: ${now}

User telah di-nonaktifkan otomatis."
    
    send_telegram "$msg"
}

# Kirim notifikasi trial expired
# Args: $1=username
notify_trial_expired() {
    local user="$1"
    local hostname=$(hostname)
    local now=$(date '+%Y-%m-%d %H:%M:%S')
    
    local msg="⏰ <b>TRIAL EXPIRED - ${hostname}</b>

👤 User: <code>${user}</code>
🕐 Waktu: ${now}

Akun trial telah habis masa aktifnya."
    
    send_telegram "$msg"
}

# Pastikan direktori limit ada
init_limit_dir() {
    mkdir -p "$LIMIT_DIR"
}

# Simpan limit user ke file JSON-like
# Args: $1=username $2=quota_gb $3=ip_limit $4=is_trial $5=expire_hours (trial only)
save_user_limit() {
    local user="$1"
    local quota_gb="$2"
    local ip_limit="$3"
    local is_trial="${4:-0}"
    local expire_hours="${5:-0}"
    
    init_limit_dir
    
    local quota_bytes=$((quota_gb * 1024 * 1024 * 1024))
    local created_ts=$(date +%s)
    local expire_ts=0
    
    if [ "$is_trial" = "1" ] && [ "$expire_hours" -gt 0 ]; then
        expire_ts=$((created_ts + expire_hours * 3600))
    fi
    
    cat > "${LIMIT_DIR}/${user}.limit" <<-EOL
USER=${user}
QUOTA_GB=${quota_gb}
QUOTA_BYTES=${quota_bytes}
IP_LIMIT=${ip_limit}
IS_TRIAL=${is_trial}
CREATED_TS=${created_ts}
EXPIRE_TS=${expire_ts}
USED_BYTES=0
DISABLED=0
EOL
}

# Baca limit user
# Args: $1=username $2=field (QUOTA_BYTES, IP_LIMIT, dll)
get_user_limit() {
    local user="$1"
    local field="$2"
    local limit_file="${LIMIT_DIR}/${user}.limit"
    
    if [ -f "$limit_file" ]; then
        grep "^${field}=" "$limit_file" | cut -d= -f2
    else
        echo ""
    fi
}

# Update used bytes
# Args: $1=username $2=used_bytes
update_used_bytes() {
    local user="$1"
    local used_bytes="$2"
    local limit_file="${LIMIT_DIR}/${user}.limit"
    
    if [ -f "$limit_file" ]; then
        sed -i "s/^USED_BYTES=.*/USED_BYTES=${used_bytes}/" "$limit_file"
    fi
}

# Tandai user sebagai disabled
# Args: $1=username $2=reason (quota/ip_limit/expired)
disable_user() {
    local user="$1"
    local reason="$2"
    local limit_file="${LIMIT_DIR}/${user}.limit"
    
    if [ -f "$limit_file" ]; then
        sed -i "s/^DISABLED=.*/DISABLED=1/" "$limit_file"
        echo "DISABLED_REASON=${reason}" >> "$limit_file"
    fi
}

# Cek apakah user disabled
# Args: $1=username
is_user_disabled() {
    local user="$1"
    get_user_limit "$user" "DISABLED"
}

# Ambil total bandwidth user dari Xray stats API
# Args: $1=username
get_user_bandwidth() {
    local user="$1"
    local uplink=0
    local downlink=0
    
    if command -v xray &>/dev/null; then
        # Query uplink
        local up_result=$(xray api statsquery --server="$XRAY_API" --pattern="user>>>${user}>>>traffic>>>uplink" 2>/dev/null)
        if [ -n "$up_result" ]; then
            uplink=$(echo "$up_result" | grep -oP '"value":\s*"\K[0-9]+' | head -1)
        fi
        
        # Query downlink
        local down_result=$(xray api statsquery --server="$XRAY_API" --pattern="user>>>${user}>>>traffic>>>downlink" 2>/dev/null)
        if [ -n "$down_result" ]; then
            downlink=$(echo "$down_result" | grep -oP '"value":\s*"\K[0-9]+' | head -1)
        fi
    fi
    
    uplink=${uplink:-0}
    downlink=${downlink:-0}
    echo $((uplink + downlink))
}

# Hitung jumlah IP unik yang terhubung untuk user tertentu
# Args: $1=username $2=port_pattern
get_user_ip_count() {
    local user="$1"
    local port_pattern="$2"
    local ip_file="${LIMIT_DIR}/${user}.ips"
    local count=0
    
    if [ -f "$ip_file" ]; then
        # Hapus IP yang expired (lebih dari 5 menit tidak ada koneksi)
        local now=$(date +%s)
        local tmp_file=$(mktemp)
        while IFS='|' read -r ip ts; do
            if [ $((now - ts)) -lt 300 ]; then
                echo "${ip}|${ts}" >> "$tmp_file"
            fi
        done < "$ip_file"
        mv "$tmp_file" "$ip_file"
        
        # Hitung IP unik
        count=$(cut -d'|' -f1 "$ip_file" | sort -u | wc -l)
    fi
    
    echo "$count"
}

# Tambah IP ke tracking user
# Args: $1=username $2=ip_address
add_user_ip() {
    local user="$1"
    local ip="$2"
    local ip_file="${LIMIT_DIR}/${user}.ips"
    local now=$(date +%s)
    
    # Hapus IP lama dari user yang sama, tambah yang baru
    if [ -f "$ip_file" ]; then
        grep -v "^${ip}|" "$ip_file" > "${ip_file}.tmp" 2>/dev/null
        mv "${ip_file}.tmp" "$ip_file"
    fi
    
    echo "${ip}|${now}" >> "$ip_file"
}

# Cek apakah quota terlampaui
# Args: $1=username
check_quota_exceeded() {
    local user="$1"
    local quota_bytes=$(get_user_limit "$user" "QUOTA_BYTES")
    local used_bytes=$(get_user_bandwidth "$user")
    
    update_used_bytes "$user" "$used_bytes"
    
    if [ "$quota_bytes" -gt 0 ] && [ "$used_bytes" -gt "$quota_bytes" ]; then
        echo "1"
    else
        echo "0"
    fi
}

# Cek apakah IP limit terlampaui
# Args: $1=username
check_ip_exceeded() {
    local user="$1"
    local ip_limit=$(get_user_limit "$user" "IP_LIMIT")
    local ip_count=$(get_user_ip_count "$user")
    
    if [ "$ip_limit" -gt 0 ] && [ "$ip_count" -gt "$ip_limit" ]; then
        echo "1"
    else
        echo "0"
    fi
}

# Cek apakah trial expired
# Args: $1=username
check_trial_expired() {
    local user="$1"
    local is_trial=$(get_user_limit "$user" "IS_TRIAL")
    local expire_ts=$(get_user_limit "$user" "EXPIRE_TS")
    
    if [ "$is_trial" = "1" ] && [ "$expire_ts" -gt 0 ]; then
        local now=$(date +%s)
        if [ "$now" -gt "$expire_ts" ]; then
            echo "1"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# Hapus user dari config.json (disable tanpa hapus data limit)
# Args: $1=username
remove_user_from_xray() {
    local user="$1"
    
    # Rename email/password field agar user tidak bisa connect
    # Tapi pertahankan struktur JSON agar tidak corrupt
    # Gunakan marker REMOVED_ pada email field
    sed -i "s/\"email\": \"${user}\"/\"email\": \"REMOVED_${user}\"/g" /etc/xray/config.json
    
    systemctl restart xray >/dev/null 2>&1
}

# Format bytes ke human readable (tanpa bc, pakai awk)
# Args: $1=bytes
format_bytes() {
    local bytes=$1
    if [ "$bytes" -ge 1073741824 ]; then
        awk "BEGIN {printf \"%.2f GB\", $bytes/1073741824}"
    elif [ "$bytes" -ge 1048576 ]; then
        awk "BEGIN {printf \"%.2f MB\", $bytes/1048576}"
    elif [ "$bytes" -ge 1024 ]; then
        awk "BEGIN {printf \"%.2f KB\", $bytes/1024}"
    else
        echo "${bytes} B"
    fi
}

# Hitung sisa waktu trial dalam format human readable
# Args: $1=username
get_trial_remaining() {
    local user="$1"
    local expire_ts=$(get_user_limit "$user" "EXPIRE_TS")
    
    if [ "$expire_ts" -gt 0 ]; then
        local now=$(date +%s)
        local remaining=$((expire_ts - now))
        
        if [ "$remaining" -le 0 ]; then
            echo "EXPIRED"
        else
            local hours=$((remaining / 3600))
            local mins=$(((remaining % 3600) / 60))
            echo "${hours}j ${mins}m"
        fi
    else
        echo "N/A"
    fi
}
