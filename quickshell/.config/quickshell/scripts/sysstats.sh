#!/usr/bin/env bash
# Prints key=value lines for Sys.qml to parse. Sampled every 2 seconds.
# Everything here is read-only and cheap; missing tools just omit their keys.

read -r _ u n s idle iow irq sirq st _ < /proc/stat
echo "cpu_total=$((u + n + s + idle + iow + irq + sirq + st))"
echo "cpu_idle=$((idle + iow))"

awk '/^MemTotal/{t=$2} /^MemAvailable/{a=$2} END{print "mem_total=" t; print "mem_avail=" a}' /proc/meminfo

df -k --output=size,used / 2>/dev/null | awk 'NR==2{print "disk_total=" $1; print "disk_used=" $2}'

# Read the interface selected by the active default route. Summing every
# non-loopback interface counts the same packets again on bridges, VPNs and
# virtual interfaces.
net_if=$(ip -o route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i=="dev") {print $(i+1); exit}}')
if [ -z "$net_if" ]; then
  net_if=$(ip -6 -o route get 2606:4700:4700::1111 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i=="dev") {print $(i+1); exit}}')
fi
echo "net_if=${net_if:-none}"
if [ -n "$net_if" ] && [ -r "/sys/class/net/$net_if/statistics/rx_bytes" ]; then
  echo "rx=$(</sys/class/net/$net_if/statistics/rx_bytes)"
  echo "tx=$(</sys/class/net/$net_if/statistics/tx_bytes)"
else
  echo "rx=0"
  echo "tx=0"
fi

t=0
for f in /sys/class/thermal/thermal_zone*/temp; do
  [ -r "$f" ] || continue
  v=$(<"$f")
  [ "$v" -gt "$t" ] 2>/dev/null && t=$v
done
echo "temp=$((t / 1000))"

awk '{print "uptime=" int($1)}' /proc/uptime

if command -v nmcli >/dev/null 2>&1; then
  echo "wifi=$(nmcli radio wifi 2>/dev/null)"
  echo "ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')"
fi

if pgrep -x hyprsunset >/dev/null 2>&1; then echo "night=1"; else echo "night=0"; fi

if command -v brightnessctl >/dev/null 2>&1; then
  brightnessctl -m 2>/dev/null | awk -F, 'NR==1{gsub("%","",$4); print "bright=" $4}'
fi
