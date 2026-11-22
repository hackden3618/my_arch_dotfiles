#!/usr/bin/env bash
# Prints key=value lines for Sys.qml to parse. Sampled every 2 seconds.
# Everything here is read-only and cheap; missing tools just omit their keys.

read -r _ u n s idle iow irq sirq st _ < /proc/stat
echo "cpu_total=$((u + n + s + idle + iow + irq + sirq + st))"
echo "cpu_idle=$((idle + iow))"

awk '/^MemTotal/{t=$2} /^MemAvailable/{a=$2} END{print "mem_total=" t; print "mem_avail=" a}' /proc/meminfo

df -k --output=size,used / 2>/dev/null | awk 'NR==2{print "disk_total=" $1; print "disk_used=" $2}'

awk -F'[: ]+' 'NR>2 && $2!="lo"{rx+=$3; tx+=$11} END{print "rx=" rx+0; print "tx=" tx+0}' /proc/net/dev

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
