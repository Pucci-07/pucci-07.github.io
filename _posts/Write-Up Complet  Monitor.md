### Contexte

Fichier `monitor` fourni — capture réseau d'une attaque réelle simulée. Objectif : **trouver l'IP de l'attaquant**.

---

### Étape 1 : Identifier le fichier

bash

```bash
file monitor
# → pcap-ng capture file
```

---

### Étape 2 : Lister tout le trafic

bash

```bash
tshark -r monitor
```

---

### Étape 3 : Filtrer les requêtes POST

bash

```bash
tshark -r monitor -Y "http.request.method == POST" \
       -T fields -e ip.src -e ip.dst -e http.request.uri -e http.file_data
```

**Résultat trouvé :**

```
POST /session_login.cgi
Host: 172.16.88.154:10000
Body: user=admin&pass=password6543
```

---

### Étape 4 : Identifier les rôles

| Rôle          | IP                      | Indice                         |
| ------------- | ----------------------- | ------------------------------ |
| **Victime**   | `172.16.88.154`         | C'est le serveur Webmin (dst)  |
| **Attaquant** | `ip.src` du paquet POST | C'est lui qui envoie l'attaque |

bash

```bash
# Extraire l'IP source exacte
tshark -r monitor -Y "http.request.method == POST" -T fields -e ip.src
```