#!/usr/bin/env python3
import subprocess
import re
import os
import signal
import sys

proc = None

def get_current_profile():
    res = subprocess.run(
        ['busctl', 'get-property', 'net.hadess.PowerProfiles', '/net/hadess/PowerProfiles', 'net.hadess.PowerProfiles', 'ActiveProfile'],
        capture_output=True, text=True
    )
    m = re.search(r'"([^"]+)"', res.stdout)
    return m.group(1) if m else "balanced"

def set_inhibit(profile):
    global proc
    if profile == "performance":
        if proc is None:
            proc = subprocess.Popen(['systemd-inhibit', '--what=handle-lid-switch', '--who=Performance Mode', '--why=Performance mode active', 'sleep', 'infinity'])
            subprocess.run(['notify-send', '-u', 'low', '-i', 'preferences-system-power', 'Performance Mode', 'Lid close sleep disabled'])
    else:
        if proc is not None:
            proc.terminate()
            proc.wait()
            proc = None
            subprocess.run(['notify-send', '-u', 'low', '-i', 'preferences-system-power', f'Power Profile: {profile}', 'Lid close sleep restored'])

def cleanup(signum, frame):
    global proc
    if proc is not None:
        proc.terminate()
    sys.exit(0)

signal.signal(signal.SIGTERM, cleanup)
signal.signal(signal.SIGINT, cleanup)

# Check current state on launch
set_inhibit(get_current_profile())

# Listen for real-time power profile changes over D-Bus
monitor = subprocess.Popen(
    ['gdbus', 'monitor', '--system', '--dest', 'net.hadess.PowerProfiles', '--object-path', '/net/hadess/PowerProfiles'],
    stdout=subprocess.PIPE, text=True
)

for line in monitor.stdout:
    m = re.search(r"'ActiveProfile':\s*<'([^']+)'", line)
    if m:
        set_inhibit(m.group(1))

