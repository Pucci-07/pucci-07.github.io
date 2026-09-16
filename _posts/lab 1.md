# Lab Session 2 — Filtrage, Segmentation, Cloud & OT
### Guide pas-à-pas — votre poste individuel

---

## Atelier 1 — Zero Trust & Default Deny (30 min)

**1.1 — État initial**
```bash
nmap -sV <IP_VM>
```
Notez les ports ouverts.

**1.2 — UFW en Default Deny**
```bash
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp        # avant d'activer, sous peine de vous couper l'accès
sudo ufw enable
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw delete allow 22/tcp
sudo ufw allow from 192.168.10.0/24 to any port 22
sudo ufw status verbose
```

**1.3 — Re-scan et comparaison**
```bash
nmap -sV <IP_VM>
```
Seuls 80/443 doivent apparaître ouverts depuis l'extérieur de la plage autorisée.

**1.4 — Le piège Docker**
```bash
docker run -d --name test-nginx -p 8080:80 nginx
```
Depuis la VM attaquant :
```bash
nmap -p 8080 <IP_VM>
```
**Résultat attendu (délibérément contre-intuitif) :** le port 8080 est ouvert malgré UFW — Docker écrit directement dans les chaînes `iptables` (`DOCKER`, `PREROUTING`), en amont d'UFW, qui ne voit jamais ce trafic.

**Correctif :**
```bash
git clone https://github.com/chaifeng/ufw-docker.git && cd ufw-docker
sudo ./ufw-docker install
sudo systemctl restart ufw
sudo ufw route allow proto tcp from any to any port 8080
```
Nettoyage : `docker rm -f test-nginx`

---

## Atelier 2 — Responsabilité partagée & IAM Cloud (45 min)

**2.1 — Sur-privilégier volontairement**
Console AWS → **IAM → Users → votre utilisateur → Add permissions → `AdministratorAccess`**.

**2.2 — Corriger avec une politique scoping fine**
Retirez `AdministratorAccess`, puis créez une politique JSON restreinte à un seul bucket :
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:ListBucket"],
    "Resource": [
      "arn:aws:s3:::lab-p01-bucket",
      "arn:aws:s3:::lab-p01-bucket/*"
    ]
  }]
}
```
Attachez-la à votre utilisateur, puis testez les limites (essayez une action hors périmètre — doit échouer avec `AccessDenied`).

**2.3 — MFA**
**IAM → Security credentials → Assign MFA device** (virtuel, via Authenticator/Authy). Vérifiez qu'une reconnexion l'exige.

**2.4 — Bucket public : créer, exploiter, refermer**
Créez `lab-p01-public-test`, désactivez le blocage d'accès public, ajoutez une bucket policy `s3:GetObject` pour `Principal: "*"`, uploadez un fichier, accédez-y par URL publique — puis refermez (réactivez le blocage, supprimez la policy).

---

## Atelier 3 — Sécurité Docker & conteneurs (30 min)

**3.1 — Conteneur non durci vs durci**
```bash
docker run -it --rm alpine sh -c "whoami; id"   # root
```
```dockerfile
FROM debian:stable-slim
RUN useradd -m appuser
USER appuser
CMD ["sleep", "3600"]
```
```bash
docker build -t image-durcie .
docker run -d --name test-durci image-durcie
docker exec test-durci whoami   # appuser
```

**3.2 — Scan et capabilities**
```bash
trivy image image-durcie
docker run -d --name test-capdrop --cap-drop ALL --cap-add NET_BIND_SERVICE nginx
docker exec test-capdrop cat /proc/1/status | grep CapEff
```

**3.3 — Le piège du secret figé dans les layers**
```bash
printf 'FROM alpine\nENV DB_PASSWORD=motdepasse123\nRUN echo build\nRUN unset DB_PASSWORD\n' > Dockerfile
docker build -t image-avec-secret .
docker history image-avec-secret
```
Le secret reste visible dans l'historique malgré le `unset`.

Nettoyage :
```bash
docker rm -f test-nginx test-durci test-capdrop 2>/dev/null
docker rmi image-durcie image-avec-secret 2>/dev/null
```

---

## Atelier 4 — Segmentation IT/OT & sécurité SCADA (60 min)

**4.1 — Démarrer le simulateur Modbus**
```bash
sudo apt install default-jre -y
wget https://sourceforge.net/projects/modbuspal/files/latest/download -O modbuspal.jar
java -jar modbuspal.jar
```
Créez un slave `PLC-Simulé`, ajoutez 2 holding registers (`Temperature`, `Pressure`), **Enable all → Run**.

**4.2 — Absence totale d'authentification**
```bash
sudo apt install mbpoll -y
mbpoll -a 1 -r 1 -c 2 -t 4 <IP_VM_PLC>
```
Lecture réussie sans aucun identifiant — Modbus TCP n'authentifie rien nativement.

**4.3 — Écriture non autorisée**
```bash
mbpoll -a 1 -r 1 -t 4 <IP_VM_PLC> 999
```
La valeur change instantanément depuis un poste quelconque. Sur un vrai automate, ceci pilote un actionneur physique.

**4.4 — Segmentation stricte**
```bash
sudo ufw default deny incoming
sudo ufw allow from <IP_VM_HMI> to any port 502
sudo ufw enable
```
Revérifiez 4.2 depuis la VM attaquante (doit timeout) et depuis la VM HMI (doit fonctionner).

**4.5 — Supervision passive uniquement**
```bash
sudo tcpdump -i eth0 port 502 -w capture_ot.pcap
```
**Règle à retenir :** on ne scanne/interroge jamais activement un automate en production — la détection reste strictement passive.

---

## Pour aller plus loin — Hack The Box

Si vous voulez continuer à pratiquer après la session, voici des ressources HTB qui prolongent directement chaque atelier. Le catalogue HTB évolue régulièrement — vérifiez la disponibilité au moment où vous vous y mettez.

- **Atelier 1 (Zero Trust / pare-feu)** — HTB Academy, module **"Network Enumeration with Nmap"** : reprend et approfondit exactement la logique de cartographie utilisée en 1.1/1.3, avec des techniques de contournement de pare-feu (scans furtifs, fragmentation de paquets) qui vont plus loin que ce qu'on a eu le temps de voir.
- **Atelier 2 & 3 (Cloud IAM + Docker)** — Machine HTB **"Zeek"** : scénario réaliste qui enchaîne énumération de ressources AWS, investigation de services LocalStack, exploitation d'une fonction Lambda vulnérable, puis pivot vers un hôte via Docker — c'est littéralement l'atelier 2 et l'atelier 3 mis bout à bout dans un seul scénario d'attaque continu.
- **Atelier 3 (Docker, en complément)** — filtrez les machines HTB par tag **"Docker"** dans le catalogue (Machines → Filters) pour trouver d'autres scénarios d'évasion de conteneurs au fil des sorties.
- **Atelier 4 (OT/SCADA)** — HTB ne propose pas, à ce jour, de contenu dédié à l'OT/SCADA (ce n'est pas son terrain). Pour continuer sur ce sujet, restez plutôt sur GRFICS ou ModbusPal en autonomie, évoqués pendant la session.

---

## Synthèse (10 min)

| Atelier | Ce qui a changé | Ce qui vous a surpris |
|---|---|---|
| 1 — Zero Trust | | |
| 2 — Cloud IAM | | |
| 3 — Docker | | |
| 4 — OT/SCADA | | |
