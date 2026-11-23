#!/bin/sh

while true; do
    WIFI=$(iwctl station wlan0 show 2>/dev/null | awk '/Connected network/ {print $3}')
    MEM=$(free | awk '/Mem:/ {printf "%.2f GiB", $3/1024/1024}')
    WP_OUT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    VOL=$(echo "$WP_OUT" | awk '{printf "%d", $2 * 100}')
    if echo "$WP_OUT" | grep -q "MUTED"; then
        VOL="0"
    fi
    BAT=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
    DATE_TIME=$(date '+%d.%m.%y %H:%M')
    echo "$WIFI | $MEM | $VOL% | $BAT% | $DATE_TIME"
    sleep 1
done
