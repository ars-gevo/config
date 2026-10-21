#!/bin/sh

COUNTER=0

WIFI=""
IP_ADDR=""

while true; do
    
    BMAX=$(cat /sys/class/backlight/intel_backlight/max_brightness 2>/dev/null)
    BNOW=$(cat /sys/class/backlight/intel_backlight/brightness 2>/dev/null)
    if [ -n "$BMAX" ] && [ "$BMAX" -gt 0 ]; then
        BRT=$((BNOW * 100 / BMAX))
    else
        BRT=0
    fi

    BAT=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)

    CPU_RAW=$(cat /sys/class/hwmon/hwmon4/temp1_input 2>/dev/null)
    CPU_TEMP=$((CPU_RAW / 1000))

    MEM=$(free | awk '/Mem:/ {printf "%.2f GiB", $3/1024/1024}')

    WP_OUT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    VOL=$(echo "$WP_OUT" | awk '{printf "%d", $2 * 100}')
    if echo "$WP_OUT" | grep -q "MUTED"; then
        VOL="0"
    fi

    DATE_TIME=$(date '+%d.%m.%y %H:%M')

    if [ $((COUNTER % 5)) -eq 0 ]; then
        ROUTE_DEV=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')
        IP_ADDR=$(ip -o -4 addr show dev "$ROUTE_DEV" 2>/dev/null | awk '{split($4,a,"/"); print a[1]}')
        WIFI=$(iwctl station wlan0 show 2>/dev/null | awk '/Connected network/ {print $3}')
    fi

    echo "$WIFI | $IP_ADDR | ${CPU_TEMP}°C | $MEM | $VOL% | $BRT% | $BAT% | $DATE_TIME"

    COUNTER=$((COUNTER + 1))
    sleep 1
done
