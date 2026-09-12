#!/usr/bin/env python3
"""
HyprIpcBridge: IPC translation bridge for Waybar with Hyprland Lua configuration.

Hyprland 0.55+ in Lua configuration mode evaluates incoming `/dispatch <cmd>`
commands as Lua expressions: `return hl.dispatch(<cmd>)`.
Waybar (prior to unreleased upstream patches) sends legacy commands like
`dispatch workspace <id>`, causing syntax errors in Hyprland's Lua parser.

This bridge creates an isolated socket namespace for Waybar:
  $XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}_waybar/
It:
  1. Symlinks .socket2.sock directly to Hyprland's real event socket (zero latency).
  2. Proxies .socket.sock, translating workspace dispatches to Lua syntax:
     - `dispatch workspace <arg>` -> `/dispatch hl.dsp.focus({ workspace = "<arg>" })`
     - `dispatch focusworkspaceoncurrentmonitor <arg>` -> `/dispatch hl.dsp.focus({ workspace = "<arg>", on_current_monitor = true })`
     - `dispatch togglespecialworkspace <arg>` -> `/dispatch hl.dsp.workspace.toggle_special("<arg>")`
  3. Forwards all other requests untouched to Hyprland's real socket.
"""

import asyncio
import os
import re
import signal
import sys

WORKSPACE_RE = re.compile(r"^(\[\[.*?\]\])?\/?dispatch\s+workspace\s+(.*)$")
FOCUS_MON_RE = re.compile(r"^(\[\[.*?\]\])?\/?dispatch\s+focusworkspaceoncurrentmonitor\s+(.*)$")
SPECIAL_WS_RE = re.compile(r"^(\[\[.*?\]\])?\/?dispatch\s+togglespecialworkspace(?:\s+(.*))?$")

def translate_command(raw_data: bytes) -> bytes:
    try:
        text = raw_data.decode("utf-8")
    except UnicodeDecodeError:
        return raw_data

    line = text.strip()

    m = WORKSPACE_RE.match(line)
    if m:
        arg = m.group(2).strip().strip('"').strip("'")
        if arg.startswith("name:"):
            arg = arg[5:]
        return f"/dispatch hl.dsp.focus({{ workspace = \"{arg}\" }})\n".encode("utf-8")

    m = FOCUS_MON_RE.match(line)
    if m:
        arg = m.group(2).strip().strip('"').strip("'")
        if arg.startswith("name:"):
            arg = arg[5:]
        return f"/dispatch hl.dsp.focus({{ workspace = \"{arg}\", on_current_monitor = true }})\n".encode("utf-8")

    m = SPECIAL_WS_RE.match(line)
    if m:
        arg = (m.group(2) or "").strip().strip('"').strip("'")
        if arg:
            return f"/dispatch hl.dsp.workspace.toggle_special(\"{arg}\")\n".encode("utf-8")
        return b"/dispatch hl.dsp.workspace.toggle_special()\n"

    return raw_data


async def forward_connection(client_reader: asyncio.StreamReader, client_writer: asyncio.StreamWriter, real_sock_path: str):
    try:
        data = await client_reader.read(8192)
        if not data:
            client_writer.close()
            await client_writer.wait_closed()
            return

        translated = translate_command(data)

        real_reader, real_writer = await asyncio.open_unix_connection(real_sock_path)
        real_writer.write(translated)
        await real_writer.drain()

        # Read response from real socket and relay to client
        while True:
            resp = await real_reader.read(8192)
            if not resp:
                break
            client_writer.write(resp)
            await client_writer.drain()

        real_writer.close()
        await real_writer.wait_closed()
    except Exception:
        pass
    finally:
        try:
            client_writer.close()
            await client_writer.wait_closed()
        except Exception:
            pass


async def main():
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    xdg = os.environ.get("XDG_RUNTIME_DIR")
    if not sig or not xdg:
        print("Error: HYPRLAND_INSTANCE_SIGNATURE or XDG_RUNTIME_DIR not set", file=sys.stderr)
        sys.exit(1)

    real_dir = os.path.join(xdg, "hypr", sig)
    bridge_dir = os.path.join(xdg, "hypr", f"{sig}_waybar")
    real_sock1 = os.path.join(real_dir, ".socket.sock")
    real_sock2 = os.path.join(real_dir, ".socket2.sock")

    if not os.path.exists(real_sock1) or not os.path.exists(real_sock2):
        print(f"Error: Hyprland sockets not found in {real_dir}", file=sys.stderr)
        sys.exit(1)

    os.makedirs(bridge_dir, exist_ok=True)

    bridge_sock2 = os.path.join(bridge_dir, ".socket2.sock")
    if os.path.lexists(bridge_sock2):
        if not os.path.exists(bridge_sock2) or os.path.realpath(bridge_sock2) != real_sock2:
            os.remove(bridge_sock2)
            os.symlink(real_sock2, bridge_sock2)
    else:
        os.symlink(real_sock2, bridge_sock2)

    bridge_sock1 = os.path.join(bridge_dir, ".socket.sock")
    if os.path.exists(bridge_sock1):
        # Check if already running
        try:
            test_reader, test_writer = await asyncio.open_unix_connection(bridge_sock1)
            test_writer.close()
            await test_writer.wait_closed()
            print("HyprIpcBridge already running.")
            return
        except Exception:
            os.remove(bridge_sock1)

    server = await asyncio.start_unix_server(
        lambda r, w: forward_connection(r, w, real_sock1),
        path=bridge_sock1
    )

    pid_file = os.path.join(bridge_dir, "bridge.pid")
    with open(pid_file, "w") as f:
        f.write(str(os.getpid()))

    loop = asyncio.get_running_loop()
    stop_event = asyncio.Event()

    def handle_signal():
        stop_event.set()

    for s in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(s, handle_signal)

    try:
        await stop_event.wait()
    finally:
        server.close()
        await server.wait_closed()
        if os.path.exists(pid_file):
            try:
                os.remove(pid_file)
            except OSError:
                pass
        if os.path.exists(bridge_sock1):
            try:
                os.remove(bridge_sock1)
            except OSError:
                pass


def daemonize():
    try:
        pid = os.fork()
        if pid > 0:
            sys.exit(0)
    except OSError:
        sys.exit(1)

    os.setsid()

    try:
        pid = os.fork()
        if pid > 0:
            sys.exit(0)
    except OSError:
        sys.exit(1)

    sys.stdout.flush()
    sys.stderr.flush()
    with open(os.devnull, "rb", 0) as devnull_r, open(os.devnull, "ab", 0) as devnull_w:
        os.dup2(devnull_r.fileno(), sys.stdin.fileno())
        os.dup2(devnull_w.fileno(), sys.stdout.fileno())
        os.dup2(devnull_w.fileno(), sys.stderr.fileno())


if __name__ == "__main__":
    if "--daemon" in sys.argv:
        daemonize()
    asyncio.run(main())
