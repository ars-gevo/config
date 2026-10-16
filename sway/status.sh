#!/bin/sh

while true; do
  DATE_TIME=$(date +'%d.%m.%y %H:%M')
  BAT=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
  BAT_STAT=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)
  BNOW=$(cat /sys/class/backlight/intel_backlight/brightness)
  BMAX=$(cat /sys/class/backlight/intel_backlight/max_brightness)
  BRT=$((BNOW * 100 / BMAX))
  WP_OUT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
  VOL=$(echo "$WP_OUT" | awk '{printf "%d", $2 * 100}')
  MUTE=$(echo "$WP_OUT" | grep -c MUTED)
  MEM=$(free | awk '/Mem:/ {printf "%.2f GiB/%.2f GiB\n", $3/1024/1024, $2/1024/1024}')
  ROUTE_DEV=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')
  IP_ADDR=$(ip -o -4 addr show dev "$ROUTE_DEV" 2>/dev/null | awk '{split($4,a,"/"); print a[1]}')
  WIFI=$(iwctl station wlan0 show | awk '/Connected network/ {print $3}')
  CPU_TEMP=$(( $(cat /sys/class/hwmon/hwmon4/temp1_input) / 1000 ))

  if [ "$BAT_STAT" = "Charging" ]; then
    BAT_ICON="󰁹"
  else
    BAT_ICON="󰂎"
  fi

  BRT_ICON=" "

  if [ "$MUTE" -gt 0 ]; then
    VOL_ICON=" "
  else
    VOL_ICON=" "
  fi

  MEM_ICON=" "

  CPU_ICON=" "

  if [ -z "$WIFI" ]; then
    WIFI_ICON=" "
    WIFI="Disconnected"
  else
    WIFI_ICON=" "
    if [ -n "$IP_ADDR" ]; then
      WIFI="$WIFI ($IP_ADDR)"
    fi
  fi

  echo "$WIFI_ICON $WIFI | $CPU_ICON $CPU_TEMP°C | $MEM_ICON $MEM | $VOL_ICON $VOL% | $BRT_ICON $BRT% | $BAT_ICON $BAT% | $DATE_TIME"

  sleep 1
done
