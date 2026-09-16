
# Lab Session 2 — Filtrage, Segmentation, Cloud & OT

### Guide pas-à-pas — un poste par participant, niveau débutant

---

## Note formateur — préparation de l'infrastructure (avant J2)

Puisque c'est vous qui détenez les VMs, l'accès Cloud sandbox et Docker, chaque participant doit recevoir un **environnement isolé**, pas un accès partagé — sinon les manipulations des uns cassent les résultats des autres.

|Ressource|Comment l'isoler par participant|
|---|---|
|**VM Linux**|Cloner un template une fois préparé (Debian/Ubuntu à jour, `nmap`, `docker`, `trivy` déjà installés) → une VM par participant, IP différente. Nommez-les `lab-p01`, `lab-p02`, etc.|
|**Sandbox Cloud (AWS/Azure)**|Ne donnez jamais les identifiants root/administrateur globaux. Créez un utilisateur IAM (AWS) ou un compte invité (Azure) par participant, avec des droits volontairement limités au périmètre du lab. C'est aussi le premier exemple concret du principe du moindre privilège.|
|**Docker**|Si un seul hôte Docker est disponible : un réseau Docker (`docker network create labpXX`) et un préfixe de nommage par participant pour éviter les collisions de conteneurs/ports.|

**Checklist avant de démarrer la session :**

- [ ] Chaque participant a reçu : IP de sa VM + identifiants SSH, identifiants IAM/Cloud individuels, accès Docker fonctionnel (`docker ps` sans erreur)
- [ ] Une VM "attaquant" partagée (ou une par participant si les ressources le permettent) avec `nmap` installé
- [ ] Un snapshot propre de chaque VM pris **avant** le lab (pour pouvoir revenir en arrière en cas de blocage)

---

## Atelier 1 — Zero Trust & Default Deny (45 min)

### 1.1 — Cartographier l'état initial (5 min)

Depuis la VM attaquant, chaque participant scanne **sa propre VM** (remplacez `<IP_VM>` par l'IP reçue) :

```bash
nmap -sV <IP_VM>
```

**✅ Résultat attendu :** une liste de ports ouverts (probablement 22 pour SSH, et d'autres selon l'image de base). Notez cette liste sur une feuille — vous allez la comparer à la fin de l'atelier.

**Question à se poser avant de continuer :** parmi ces ports, lesquels sont réellement nécessaires à votre usage du serveur ?

---

### 1.2 — Installer et activer UFW en Default Deny (10 min)

Sur **votre VM** (pas la VM attaquant), en SSH :

```bash
sudo apt update
sudo apt install ufw -y
```

Définir la politique par défaut — tout bloquer en entrée, tout autoriser en sortie :

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

⚠️ **Avant d'activer**, autorisez impérativement le port SSH que vous utilisez pour vous connecter, sinon vous allez vous couper l'accès à votre propre VM :

```bash
sudo ufw allow 22/tcp
```

Activez le pare-feu :

```bash
sudo ufw enable
```

Tapez `y` pour confirmer.

**✅ Résultat attendu :** le message `Firewall is active and enabled on system startup`. Vérifiez avec :

```bash
sudo ufw status verbose
```

Vous devez voir une seule règle : `22/tcp ALLOW Anywhere`.

---

### 1.3 — Ouvrir uniquement les ports stratégiques (10 min)

Ajoutez HTTP et HTTPS :

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

Restreignez maintenant SSH à la seule plage IP de la salle de formation (remplacez par la plage réellement communiquée par le formateur, par exemple `192.168.10.0/24`) :

```bash
sudo ufw delete allow 22/tcp
sudo ufw allow from 192.168.10.0/24 to any port 22
```

**✅ Résultat attendu :** `sudo ufw status verbose` affiche maintenant 3 règles : SSH restreint à la plage IP, port 80 et port 443 ouverts à tous.

---

### 1.4 — Re-scanner et comparer (5 min)

Depuis la VM attaquant :

```bash
nmap -sV <IP_VM>
```

**✅ Résultat attendu :** seuls les ports 80 et 443 apparaissent ouverts publiquement (le port 22 n'apparaît plus ouvert depuis la VM attaquant si elle n'est pas dans la plage autorisée). Comparez avec la liste notée en 1.1 — combien de ports ont disparu ?

---

### 1.5 — Le piège Docker (10 min)

Sur votre VM, lancez un conteneur qui publie un port :

```bash
docker run -d --name test-nginx -p 8080:80 nginx
```

Depuis la VM attaquant, re-scannez :

```bash
nmap -p 8080 <IP_VM>
```

**✅ Résultat attendu (et surprenant) :** le port 8080 apparaît **ouvert**, alors qu'aucune règle UFW ne l'autorise. Demandez-vous pourquoi avant de continuer.

**Explication à lire après avoir cherché :** Docker insère ses propres règles directement dans les chaînes `iptables` (`DOCKER`, `PREROUTING`), **avant** que UFW ait la main. UFW ne voit donc jamais passer ce trafic.

**Correctif (démonstration formateur, ou à faire si le temps le permet) :**

```bash
git clone https://github.com/chaifeng/ufw-docker.git
cd ufw-docker
sudo ./ufw-docker install
sudo systemctl restart ufw
```

Puis autoriser explicitement le conteneur :

```bash
sudo ufw route allow proto tcp from any to any port 8080
```

**✅ Nettoyage de fin d'atelier :**

```bash
docker rm -f test-nginx
```

---

## Atelier 2 — Responsabilité partagée & IAM Cloud (50 min)

> Utilisez les identifiants individuels reçus du formateur pour vous connecter à la console AWS ou Azure — jamais les identifiants root/administrateur globaux.

### 2.1 — Créer un accès volontairement trop permissif (10 min)

**Sur AWS (IAM) :**

1. Connectez-vous à la console AWS avec votre utilisateur individuel.
2. Allez dans **IAM → Users → votre utilisateur → Add permissions**.
3. Attachez la politique `AdministratorAccess`.

**✅ Résultat attendu :** votre utilisateur peut désormais tout faire sur le compte — exactement ce qu'il ne faut jamais accorder en production.

**Question à se poser :** si ce compte était compromis maintenant, quel serait l'impact ?

---

### 2.2 — Corriger avec le principe du moindre privilège (15 min)

1. Retirez `AdministratorAccess` (**Remove** dans la même page).
2. Créez une politique personnalisée limitée à un seul bucket S3 :
    - **IAM → Policies → Create policy → JSON**, collez :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::lab-p01-bucket",
        "arn:aws:s3:::lab-p01-bucket/*"
      ]
    }
  ]
}
```

_(remplacez `lab-p01-bucket` par le nom de bucket qui vous a été attribué)_

3. Nommez la politique `lab-lecture-seule-p01`, créez-la, puis attachez-la à votre utilisateur.

**✅ Résultat attendu :** vous pouvez lister/lire le contenu de **votre** bucket uniquement, et aucune autre action (suppression, écriture, autres buckets) n'est possible.

---

### 2.3 — Activer le MFA (10 min)

1. **IAM → Users → votre utilisateur → Security credentials → Assign MFA device**.
2. Choisissez **Virtual MFA device**, scannez le QR code avec une application (Google Authenticator, Authy...).
3. Entrez deux codes consécutifs générés par l'application pour valider.

**✅ Résultat attendu :** déconnectez-vous et reconnectez-vous — la console doit désormais vous demander le code MFA en plus du mot de passe.

---

### 2.4 — Créer puis refermer un bucket public (15 min)

1. **S3 → Create bucket**, nommez-le `lab-p01-public-test`, **décochez** "Block all public access" (confirmez l'avertissement).
2. Ajoutez une politique de bucket autorisant la lecture publique :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::lab-p01-public-test/*"
    }
  ]
}
```

3. Uploadez un fichier texte de test, puis essayez d'y accéder via son URL publique dans un navigateur.

**✅ Résultat attendu (l'erreur à corriger) :** le fichier est accessible par n'importe qui sans authentification.

4. Refermez le bucket : recochez **Block all public access**, supprimez la politique de bucket.

**✅ Résultat attendu :** l'URL publique renvoie désormais une erreur d'accès refusé.

---

## Atelier 3 — Sécurité Docker & conteneurs (50 min)

### 3.1 — Observer un conteneur non durci (10 min)

```bash
docker run -it --rm alpine sh
```

Dans le conteneur :

```bash
whoami
id
```

**✅ Résultat attendu :** `root`, `uid=0(root)` — le conteneur tourne avec les pleins privilèges. Tapez `exit` pour sortir.

---

### 3.2 — Construire une image durcie (15 min)

Créez un dossier de travail et un Dockerfile :

```bash
mkdir ~/lab-docker && cd ~/lab-docker
nano Dockerfile
```

Contenu du fichier :

```dockerfile
FROM debian:stable-slim
RUN useradd -m appuser
USER appuser
CMD ["sleep", "3600"]
```

Construisez et lancez :

```bash
docker build -t image-durcie .
docker run -d --name test-durci image-durcie
docker exec test-durci whoami
```

**✅ Résultat attendu :** la commande renvoie `appuser`, pas `root`.

---

### 3.3 — Scanner l'image avec Trivy (10 min)

```bash
trivy image image-durcie
```

**✅ Résultat attendu :** un rapport listant les vulnérabilités connues (CVE) de l'image, classées par sévérité. Notez le nombre de vulnérabilités `HIGH`/`CRITICAL`.

---

### 3.4 — Réduire les privilèges au lancement (10 min)

```bash
docker run -d --name test-capdrop --cap-drop ALL --cap-add NET_BIND_SERVICE nginx
docker exec test-capdrop cat /proc/1/status | grep CapEff
```

**✅ Résultat attendu :** la valeur `CapEff` est très réduite comparée à un conteneur lancé sans `--cap-drop` (à comparer en relançant la même commande sur un `docker run -d --name test-defaut nginx`).

---

### 3.5 — Le piège du secret dans l'image (5 min)

```bash
mkdir ~/lab-secret && cd ~/lab-secret
echo 'FROM alpine
ENV DB_PASSWORD=motdepasse123
RUN echo "secret utilisé"
RUN unset DB_PASSWORD' > Dockerfile
docker build -t image-avec-secret .
docker history image-avec-secret
```

**✅ Résultat attendu (le piège) :** le mot de passe apparaît toujours quelque part dans l'historique des couches, même après le `unset`.

**Nettoyage de fin d'atelier :**

```bash
docker rm -f test-nginx test-durci test-capdrop test-defaut 2>/dev/null
docker rmi image-durcie image-avec-secret 2>/dev/null
```

---

## Atelier 4 — Segmentation IT/OT & sécurité SCADA (55 min)

> Cet atelier utilise un simulateur logiciel — aucun automate réel n'est manipulé.

### 4.1 — Installer et démarrer ModbusPal (10 min)

Sur votre VM (nécessite Java) :

```bash
sudo apt install default-jre -y
wget https://sourceforge.net/projects/modbuspal/files/latest/download -O modbuspal.jar
java -jar modbuspal.jar
```

Dans l'interface ModbusPal :

1. **Modbus Slaves → Add**, nommez-le `PLC-Simulé`.
2. Onglet **Holding Registers → Add**, créez 2 registres (ex. `Temperature`, `Pressure`) avec des valeurs de test.
3. Cliquez **Enable all**, puis **Run**.

**✅ Résultat attendu :** le simulateur écoute désormais sur le port Modbus TCP (502) et répond aux requêtes.

---

### 4.2 — Observer l'absence d'authentification (10 min)

Depuis la VM attaquant, installez un client Modbus simple (ou utilisez `mbpoll` si disponible) :

```bash
sudo apt install mbpoll -y
mbpoll -a 1 -r 1 -c 2 -t 4 <IP_VM_PLC>
```

**✅ Résultat attendu :** vous lisez les valeurs des registres **sans avoir fourni le moindre identifiant**. C'est la démonstration concrète que Modbus n'a aucune authentification native.

---

### 4.3 — Écrire une valeur depuis un poste non autorisé (10 min)

```bash
mbpoll -a 1 -r 1 -t 4 <IP_VM_PLC> 999
```

**✅ Résultat attendu (l'alerte) :** la valeur du registre change instantanément, depuis n'importe quel poste ayant juste l'IP — sans droit particulier. Faites le lien avec l'impact physique évoqué en cours (un automate réel piloterait une vanne, une température, etc.).

---

### 4.4 — Segmenter avec UFW (15 min)

Sur la VM qui héberge le simulateur PLC, appliquez une politique stricte n'autorisant que l'IP de la VM "HMI/supervision" désignée par le formateur :

```bash
sudo ufw default deny incoming
sudo ufw allow from <IP_VM_HMI> to any port 502
sudo ufw enable
```

Redemandez à la VM attaquant de relire les registres (étape 4.2) :

```bash
mbpoll -a 1 -r 1 -c 2 -t 4 <IP_VM_PLC>
```

**✅ Résultat attendu :** la requête échoue désormais (timeout) depuis la VM attaquant, mais fonctionne toujours depuis la VM HMI autorisée.

---

### 4.5 — Superviser passivement (10 min)

Sur la VM HMI (jamais sur le PLC lui-même — la supervision reste passive) :

```bash
sudo tcpdump -i eth0 port 502 -w capture_ot.pcap
```

Laissez tourner pendant que la VM HMI continue de lire les registres normalement, puis ouvrez la capture dans Wireshark pour observer le trafic Modbus en clair.

**✅ Résultat attendu :** vous voyez passer les requêtes/réponses Modbus en clair — bon moment pour relier à la démo Wireshark de la Session 1 (HTTP/Telnet en clair).

---

## Synthèse de fin de lab (15 min)

Chaque participant remplit individuellement ce tableau à partir de ses propres résultats :

|Atelier|Ce qui était ouvert par défaut|Ce qui est fermé maintenant|Ce qui m'a surpris|
|---|---|---|---|
|1 — Zero Trust||||
|2 — Cloud IAM||||
|3 — Docker||||
|4 — OT/SCADA||||

**Tour de table :** chacun partage une ligne de son tableau — le formateur relie les réponses à la matrice de maturité vue en cours.