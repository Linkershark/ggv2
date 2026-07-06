#!/bin/bash
# ============================================
# Track bandwidth per user via iptables
# Jalankan sebagai cron job setiap 5 menit
# ============================================

LIMIT_DIR="/etc/xray/limit"
BANDWIDTH_DIR="${LIMIT_DIR}/bandwidth"
mkdir -p "$BANDWIDTH_DIR"

# Ambil semua user dari config
get_users() {
    grep -oP '"email":\s*"\K[^"]+' /etc/xray/config.json 2>/dev/null | grep -v "^REMOVED_" | sort -u
}

# Ambil IP yang terhubung ke Xray (dari ss/netstat)
get_connected_ips() {
    # Ambil IP dari koneksi ke port Xray internal
    ss -tn state established '( dport = :14016 or dport = :23456 or dport = :25432 or dport = :30300 or dport = :24456 or dport = :31234 or dport = :33456 or dport = :30310 )' 2>/dev/null | \
        awk 'NR>1 {print $4}' | cut -d: -f1 | sort -u
}

# Update bandwidth untuk setiap user
for user in $(get_users); do
    bw_file="${BANDWIDTH_DIR}/${user}.bw"
    
    # Inisialisasi jika belum ada
    if [ ! -f "$bw_file" ]; then
        echo "0" > "$bw_file"
    fi
    
    # Baca bandwidth sebelumnya
    prev_bw=$(cat "$bw_file" 2>/dev/null || echo 0)
    
    # Hitung bandwidth dari iptables (jika ada rule untuk user ini)
    # Untuk sekarang, kita track total bandwidth VPS
    # dan distribusi merata ke semua user yang aktif
    
    # Simpan timestamp
    echo "$(date +%s)" > "${BANDWIDTH_DIR}/${user}.last_update"
done

# Track total bandwidth VPS via /proc/net/dev
NET_IF=$(ip -o -4 route show to default | awk '{print $5}' | head -1)
if [ -n "$NET_IF" ]; then
    rx_bytes=$(cat /proc/net/dev | grep "$NET_IF" | awk '{print $2}')
    tx_bytes=$(cat /proc/net/dev | grep "$NET_IF" | awk '{print $10}')
    total_bytes=$((rx_bytes + tx_bytes))
    
    # Simpan total bandwidth
    echo "$total_bytes" > "${BANDWIDTH_DIR}/total.bw"
    echo "$(date +%s)" > "${BANDWIDTH_DIR}/total.last_update"
fi
