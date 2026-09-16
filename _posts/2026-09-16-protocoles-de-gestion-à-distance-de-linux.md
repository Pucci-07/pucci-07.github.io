[[Footprinting HTB]]

 Dans le monde des distributions Linux, il existe de nombreuses façons de gérer les serveurs à distance. Par exemple, imaginons que nous nous trouvions dans l'un de nos nombreux sites et que l'un de nos employés, qui vient de se rendre chez un client dans une autre ville, ait besoin de notre aide en raison d'une erreur qu'il ne peut résoudre. Un dépannage efficace s'avérera difficile par téléphone dans la plupart des cas, il est donc avantageux de savoir comment se connecter au système distant pour le gérer.

Ces applications et services se trouvent sur presque tous les serveurs du réseau public. C'est un gain de temps puisque nous n'avons pas besoin d'être physiquement présents devant le serveur, et l'environnement de travail reste le même. Pour ces raisons, ces protocoles et applications de gestion de systèmes à distance constituent une cible intéressante. Si la configuration est incorrecte, nous, en tant que testeurs d'intrusion (penetration testers), pouvons même rapidement obtenir un accès au système distant. Par conséquent, nous devrions nous familiariser avec les protocoles, serveurs et applications les plus importants à cette fin.

---

## SSH

Le [Secure Shell](https://en.wikipedia.org/wiki/Secure_Shell) (`SSH`) permet à deux ordinateurs d'établir une connexion chiffrée et directe au sein d'un réseau potentiellement non sécurisé sur le port standard `TCP 22`. Ceci est nécessaire pour empêcher des tiers d'intercepter le flux de données et donc d'intercepter des données sensibles. Le serveur SSH peut également être configuré pour n'autoriser que les connexions provenant de clients spécifiques. Un avantage de SSH est que le protocole fonctionne sur tous les systèmes d'exploitation courants. Comme il s'agit à l'origine d'une application Unix, elle est également implémentée nativement sur toutes les distributions Linux et sur macOS. SSH peut également être utilisé sur Windows, à condition d'installer un programme approprié. Le célèbre serveur [OpenBSD SSH](https://www.openssh.com/) (`OpenSSH`) sur les distributions Linux est un fork open source du serveur `SSH` original et commercial de SSH Communication Security. Par conséquent, il existe deux protocoles concurrents : `SSH-1` et `SSH-2`.

`SSH-2`, également connu sous le nom de SSH version 2, est un protocole plus avancé que la version 1 de SSH en matière de chiffrement, de vitesse, de stabilité et de sécurité. Par exemple, `SSH-1` est vulnérable aux attaques de type `MITM` (Man-In-The-Middle), alors que SSH-2 ne l'est pas.

Imaginons que nous voulions gérer un hôte distant. Cela peut se faire via la ligne de commande ou une interface graphique (GUI). En outre, nous pouvons également utiliser le protocole SSH pour envoyer des commandes au système souhaité, transférer des fichiers ou effectuer une redirection de port (port forwarding). Pour ce faire, nous devons nous y connecter en utilisant le protocole SSH et nous y authentifier. Au total, OpenSSH dispose de six méthodes d'authentification différentes :

1. Authentification par mot de passe
2. Authentification par clé publique
3. Authentification basée sur l'hôte
4. Authentification par clavier
5. Authentification par défi-réponse
6. Authentification GSSAPI

Nous allons examiner de plus près et discuter de l'une des méthodes d'authentification les plus couramment utilisées. De plus, vous pouvez en apprendre davantage sur les autres méthodes d'authentification [ici](https://www.golinuxcloud.com/openssh-authentication-methods-sshd-config/), entre autres.

#### Authentification par clé publique

Dans un premier temps, le serveur et le client SSH s'authentifient mutuellement. Le serveur envoie sa `public host key` (clé d'hôte publique) au client, que ce dernier utilise pour vérifier l'identité du serveur. Ce n'est que lors de la première prise de contact qu'il existe un risque qu'un tiers s'interpose entre les deux participants et intercepte ainsi la connexion. Une `host key` (clé d'hôte) ne peut pas être imitée car il s'agit d'une `key pair` (paire de clés) publique-privée unique, et un attaquant ne peut pas falsifier la signature de la clé privée sans y avoir accès, en supposant que le client vérifie correctement la clé publique par rapport à une source de confiance.

Après l'authentification du serveur, le client doit cependant prouver au serveur qu'il dispose d'une autorisation d'accès. Cependant, le serveur SSH est déjà en possession de la valeur de hachage chiffrée du mot de passe défini pour l'utilisateur souhaité. Par conséquent, les utilisateurs doivent saisir le mot de passe chaque fois qu'ils se connectent à un autre serveur au cours de la même session. Pour cette raison, une option alternative pour l'authentification côté client est l'utilisation d'une paire de clés publique et privée.

La clé privée est créée individuellement pour l'ordinateur de l'utilisateur et sécurisée par une passphrase qui devrait être plus longue qu'un mot de passe classique. La clé privée est stockée exclusivement sur notre propre ordinateur et reste toujours secrète. Si nous voulons établir une connexion SSH, nous saisissons d'abord la passphrase et ouvrons ainsi l'accès à la clé privée.

Les clés publiques sont également stockées sur le serveur. Le serveur crée un problème cryptographique avec la clé publique du client et l'envoie au client. Le client, à son tour, déchiffre le problème avec sa propre clé privée, renvoie la solution, et informe ainsi le serveur qu'il peut établir une connexion légitime. Pendant une session, les utilisateurs n'ont besoin de saisir la passphrase qu'une seule fois pour se connecter à un nombre illimité de serveurs. À la fin de la session, les utilisateurs se déconnectent de leurs machines locales, s'assurant qu'aucun tiers qui obtiendrait un accès physique à la machine locale ne puisse se connecter au serveur.

---

## Configuration par défaut

Le fichier [sshd_config](https://www.ssh.com/academy/ssh/sshd_config), responsable du serveur OpenSSH, n'a que quelques paramètres configurés par défaut. Cependant, la configuration par défaut inclut la redirection X11 (X11 forwarding), qui contenait une vulnérabilité d'injection de commande (command injection) dans la version 7.2p1 d'OpenSSH en 2016. Néanmoins, nous n'avons pas besoin d'une interface graphique pour gérer nos serveurs.

#### Configuration par défaut

        shellsession
`ppporrkkky@htb[/htb]$ cat /etc/ssh/sshd_config  | grep -v "#" | sed -r '/^\s*$/d'  Include /etc/ssh/sshd_config.d/*.conf ChallengeResponseAuthentication no UsePAM yes X11Forwarding yes PrintMotd no AcceptEnv LANG LC_* Subsystem       sftp    /usr/lib/openssh/sftp-server`

La plupart des paramètres de ce fichier de configuration sont commentés et nécessitent une configuration manuelle.

---

## Paramètres dangereux

Bien que le protocole SSH soit l'un des protocoles les plus sécurisés disponibles aujourd'hui, certaines mauvaises configurations peuvent encore rendre le serveur SSH vulnérable à des attaques faciles à exécuter. Examinons les paramètres suivants :

|**Paramètre**|**Description**|
|---|---|
|`PasswordAuthentication yes`|Permet l'authentification par mot de passe.|
|`PermitEmptyPasswords yes`|Permet l'utilisation de mots de passe vides.|
|`PermitRootLogin yes`|Permet de se connecter en tant qu'utilisateur root.|
|`Protocol 1`|Utilise une version de chiffrement obsolète.|
|`X11Forwarding yes`|Permet la redirection X11 pour les applications GUI.|
|`AllowTcpForwarding yes`|Permet la redirection des ports TCP.|
|`PermitTunnel`|Permet la tunnellisation.|
|`DebianBanner yes`|Affiche une bannière spécifique lors de la connexion.|

Autoriser l'authentification par mot de passe nous permet de forcer brutalement (brute-force) un nom d'utilisateur connu pour trouver des mots de passe possibles. De nombreuses méthodes différentes peuvent être utilisées pour deviner les mots de passe des utilisateurs. À cette fin, des `patterns` (modèles) spécifiques sont généralement utilisés pour faire muter les mots de passe les plus courants et, fait effrayant, les corriger. C'est parce que nous, les humains, sommes paresseux et ne voulons pas nous souvenir de mots de passe complexes et compliqués. Par conséquent, nous créons des mots de passe dont nous pouvons nous souvenir facilement, ce qui conduit au fait que, par exemple, des chiffres ou des caractères ne sont ajoutés qu'à la fin du mot de passe. Croyant que le mot de passe est sécurisé, les modèles mentionnés sont utilisés pour deviner précisément de tels « ajustements » de ces mots de passe. Cependant, certaines instructions et [guides de durcissement (hardening guides)](https://web.archive.org/web/20260118054132/http://ssh-audit.com/hardening_guides.html) peuvent être utilisés pour durcir nos serveurs SSH.

---

## Prise d'empreinte du service

L'un des outils que nous pouvons utiliser pour prendre l'empreinte du serveur SSH est [ssh-audit](https://github.com/jtesta/ssh-audit). Il vérifie la configuration côté client et côté serveur et affiche des informations générales ainsi que les algorithmes de chiffrement qui sont encore utilisés par le client et le serveur. Bien sûr, cela pourrait être exploité plus tard en attaquant le serveur ou le client au niveau cryptographique.

#### SSH-Audit

        shellsession
``ppporrkkky@htb[/htb]$ git clone https://github.com/jtesta/ssh-audit.git && cd ssh-audit ppporrkkky@htb[/htb]$ ./ssh-audit.py 10.129.14.132  # general (gen) banner: SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.3 (gen) software: OpenSSH 8.2p1 (gen) compatibility: OpenSSH 7.4+, Dropbear SSH 2018.76+ (gen) compression: enabled (zlib@openssh.com)                                     # key exchange algorithms (kex) curve25519-sha256                     -- [info] available since OpenSSH 7.4, Dropbear SSH 2018.76                             (kex) curve25519-sha256@libssh.org          -- [info] available since OpenSSH 6.5, Dropbear SSH 2013.62 (kex) ecdh-sha2-nistp256                    -- [fail] using weak elliptic curves                                             `- [info] available since OpenSSH 5.7, Dropbear SSH 2013.62 (kex) ecdh-sha2-nistp384                    -- [fail] using weak elliptic curves                                             `- [info] available since OpenSSH 5.7, Dropbear SSH 2013.62 (kex) ecdh-sha2-nistp521                    -- [fail] using weak elliptic curves                                             `- [info] available since OpenSSH 5.7, Dropbear SSH 2013.62 (kex) diffie-hellman-group-exchange-sha256 (2048-bit) -- [info] available since OpenSSH 4.4 (kex) diffie-hellman-group16-sha512         -- [info] available since OpenSSH 7.3, Dropbear SSH 2016.73 (kex) diffie-hellman-group18-sha512         -- [info] available since OpenSSH 7.3 (kex) diffie-hellman-group14-sha256         -- [info] available since OpenSSH 7.3, Dropbear SSH 2016.73  # host-key algorithms (key) rsa-sha2-512 (3072-bit)               -- [info] available since OpenSSH 7.2 (key) rsa-sha2-256 (3072-bit)               -- [info] available since OpenSSH 7.2 (key) ssh-rsa (3072-bit)                    -- [fail] using weak hashing algorithm                                             `- [info] available since OpenSSH 2.5.0, Dropbear SSH 0.28                                             `- [info] a future deprecation notice has been issued in OpenSSH 8.2: https://www.openssh.com/txt/release-8.2 (key) ecdsa-sha2-nistp256                   -- [fail] using weak elliptic curves                                             `- [warn] using weak random number generator could reveal the key                                             `- [info] available since OpenSSH 5.7, Dropbear SSH 2013.62 (key) ssh-ed25519                           -- [info] available since OpenSSH 6.5 ...SNIP...``

La première chose que nous pouvons voir dans les premières lignes de la sortie est la bannière qui révèle la version du serveur OpenSSH. Les versions précédentes présentaient certaines vulnérabilités, comme la [CVE-2020-14145](https://www.cvedetails.com/cve/CVE-2020-14145/), qui permettait à l'attaquant d'effectuer une attaque de l'homme du milieu (Man-In-The-Middle) et d'attaquer la tentative de connexion initiale. La sortie détaillée de l'établissement de la connexion avec le serveur OpenSSH peut également souvent fournir des informations importantes, telles que les méthodes d'authentification que le serveur peut utiliser.

#### Changer la méthode d'authentification

        shellsession
`ppporrkkky@htb[/htb]$ ssh -v cry0l1t3@10.129.14.132  OpenSSH_8.2p1 Ubuntu-4ubuntu0.3, OpenSSL 1.1.1f  31 Mar 2020 debug1: Reading configuration data /etc/ssh/ssh_config  ...SNIP... debug1: Authentications that can continue: publickey,password,keyboard-interactive`

Pour les attaques potentielles par force brute, nous pouvons spécifier la méthode d'authentification avec l'option client SSH `PreferredAuthentications`.

        shellsession
`ppporrkkky@htb[/htb]$ ssh -v cry0l1t3@10.129.14.132 -o PreferredAuthentications=password  OpenSSH_8.2p1 Ubuntu-4ubuntu0.3, OpenSSL 1.1.1f  31 Mar 2020 debug1: Reading configuration data /etc/ssh/ssh_config ...SNIP... debug1: Authentications that can continue: publickey,password,keyboard-interactive debug1: Next authentication method: password  cry0l1t3@10.129.14.132's password:`

Même avec ce service manifestement sécurisé, nous vous recommandons de configurer votre propre serveur OpenSSH sur votre VM, d'expérimenter avec lui et de vous familiariser avec les différents paramètres et options.

Nous pouvons rencontrer diverses bannières pour le serveur SSH lors de nos tests d'intrusion. Par défaut, les bannières commencent par la version du protocole qui peut être appliquée, puis la version du serveur lui-même. Par exemple, avec `SSH-1.99-OpenSSH_3.9p1`, nous savons que nous pouvons utiliser les deux versions de protocole SSH-1 et SSH-2, et que nous avons affaire à la version 3.9p1 du serveur OpenSSH. D'un autre côté, pour une bannière avec `SSH-2.0-OpenSSH_8.2p1`, nous avons affaire à une version 8.2p1 d'OpenSSH qui n'accepte que la version du protocole SSH-2.

---

## Rsync

[Rsync](https://linux.die.net/man/1/rsync) est un outil rapide et efficace pour copier des fichiers localement et à distance. Il peut être utilisé pour copier des fichiers localement sur une machine donnée et vers/depuis des hôtes distants. Il est très polyvalent et réputé pour son algorithme de transfert delta. Cet algorithme réduit la quantité de données transmises sur le réseau lorsqu'une version du fichier existe déjà sur l'hôte de destination. Pour ce faire, il n'envoie que les différences entre les fichiers source et l'ancienne version des fichiers qui se trouvent sur le serveur de destination. Il est souvent utilisé pour les sauvegardes et la mise en miroir. Il trouve les fichiers à transférer en examinant les fichiers dont la taille ou la dernière date de modification a changé. Par défaut, il utilise le port `873` et peut être configuré pour utiliser SSH pour des transferts de fichiers sécurisés en s'appuyant sur une connexion serveur SSH établie.

Ce [guide](https://hacktricks.wiki/en/network-services-pentesting/873-pentesting-rsync.html) couvre certaines des façons dont Rsync peut être détourné, notamment en listant le contenu d'un dossier partagé sur un serveur cible et en récupérant des fichiers. Cela peut parfois se faire sans authentification. D'autres fois, nous aurons besoin d'identifiants. Si vous trouvez des identifiants lors d'un pentest et que vous tombez sur Rsync sur un hôte interne (ou externe), il est toujours utile de vérifier la réutilisation des mots de passe, car vous pourriez être en mesure de récupérer des fichiers sensibles qui pourraient être utilisés pour obtenir un accès à distance à la cible.

Faisons une petite prise d'empreinte rapide. Nous pouvons voir que Rsync est utilisé avec le protocole 31.

#### Scan à la recherche de Rsync

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap -sV -p 873 127.0.0.1  Starting Nmap 7.92 ( https://nmap.org ) at 2022-09-19 09:31 EDT Nmap scan report for localhost (127.0.0.1) Host is up (0.0058s latency).  PORT    STATE SERVICE VERSION 873/tcp open  rsync   (protocol version 31)  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 1.13 seconds`

#### Sondage des partages accessibles

Nous pouvons ensuite sonder un peu le service pour voir ce à quoi nous pouvons accéder.

        shellsession
`ppporrkkky@htb[/htb]$ nc -nv 127.0.0.1 873  (UNKNOWN) [127.0.0.1] 873 (rsync) open @RSYNCD: 31.0 @RSYNCD: 31.0 #list dev             Dev Tools @RSYNCD: EXIT`

#### Énumération d'un partage ouvert

Ici, nous pouvons voir un partage appelé `dev`, et nous pouvons l'énumérer davantage.

        shellsession
`ppporrkkky@htb[/htb]$ rsync -av --list-only rsync://127.0.0.1/dev  receiving incremental file list drwxr-xr-x             48 2022/09/19 09:43:10 . -rw-r--r--              0 2022/09/19 09:34:50 build.sh -rw-r--r--              0 2022/09/19 09:36:02 secrets.yaml drwx------             54 2022/09/19 09:43:10 .ssh  sent 25 bytes  received 221 bytes  492.00 bytes/sec total size is 0  speedup is 0.00`

D'après la sortie ci-dessus, nous pouvons voir quelques fichiers intéressants qu'il pourrait être utile de télécharger pour une enquête plus approfondie. Nous pouvons également voir qu'un répertoire contenant probablement des clés SSH est accessible. À partir de là, nous pourrions synchroniser tous les fichiers sur notre hôte d'attaque avec la commande `rsync -av rsync://127.0.0.1/dev`. Si Rsync est configuré pour utiliser SSH pour transférer des fichiers, nous pourrions modifier nos commandes pour inclure l'option `-e ssh`, ou `-e "ssh -p2222"` si un port non standard est utilisé pour SSH. Ce [guide](https://phoenixnap.com/kb/how-to-rsync-over-ssh) est utile pour comprendre la syntaxe d'utilisation de Rsync sur SSH.

---

## R-Services

Les R-Services sont une suite de services hébergés pour permettre l'accès à distance ou l'émission de commandes entre des hôtes Unix sur TCP/IP. Initialement développés par le Computer Systems Research Group (`CSRG`) de l'Université de Californie à Berkeley, les `r-services` étaient la norme de facto pour l'accès à distance entre les systèmes d'exploitation Unix jusqu'à ce qu'ils soient remplacés par les protocoles et commandes Secure Shell (`SSH`) en raison de failles de sécurité inhérentes. Tout comme `telnet`, les r-services transmettent les informations du client au serveur (et vice versa) sur le réseau dans un format non chiffré, ce qui permet aux attaquants d'intercepter le trafic réseau (mots de passe, informations de connexion, etc.) en effectuant des attaques de l'homme du milieu (`MITM`).

Les `R-services` s'étendent sur les ports `512`, `513` et `514` et ne sont accessibles que par une suite de programmes connus sous le nom de `r-commands`. Ils sont le plus souvent utilisés par des systèmes d'exploitation commerciaux tels que Solaris, HP-UX et AIX. Bien que moins courants de nos jours, nous les rencontrons de temps en temps lors de nos tests d'intrusion internes, il est donc utile de comprendre comment les aborder.

La suite [R-commands](https://en.wikipedia.org/wiki/Berkeley_r-commands) se compose des programmes suivants :

- rcp (`remote copy`)
- rexec (`remote execution`)
- rlogin (`remote login`)
- rsh (`remote shell`)
- rstat
- ruptime
- rwho (`remote who`)

Chaque commande a sa propre fonctionnalité ; cependant, nous ne couvrirons que les `r-commands` les plus couramment détournées. Le tableau ci-dessous fournira un aperçu rapide des commandes les plus fréquemment détournées, y compris le démon de service avec lequel elles interagissent, le port et la méthode de transport par lesquels on peut y accéder, ainsi qu'une brève description de chacune.

|**Commande**|**Démon de service**|**Port**|**Protocole de transport**|**Description**|
|---|---|---|---|---|
|`rcp`|`rshd`|514|TCP|Copie un fichier ou un répertoire de manière bidirectionnelle du système local vers le système distant (ou vice versa) ou d'un système distant à un autre. Fonctionne comme la commande `cp` sous Linux mais ne fournit `aucun avertissement à l'utilisateur en cas d'écrasement de fichiers existants sur un système`.|
|`rsh`|`rshd`|514|TCP|Ouvre un shell sur une machine distante sans procédure de connexion. S'appuie sur les entrées de confiance dans les fichiers `/etc/hosts.equiv` et `.rhosts` pour la validation.|
|`rexec`|`rexecd`|512|TCP|Permet à un utilisateur d'exécuter des commandes shell sur une machine distante. Nécessite une authentification par l'utilisation d'un `username` et d'un `password` via un socket réseau non chiffré. L'authentification est supplantée par les entrées de confiance dans les fichiers `/etc/hosts.equiv` et `.rhosts`.|
|`rlogin`|`rlogind`|513|TCP|Permet à un utilisateur de se connecter à un hôte distant sur le réseau. Fonctionne de manière similaire à `telnet` mais ne peut se connecter qu'à des hôtes de type Unix. L'authentification est supplantée par les entrées de confiance dans les fichiers `/etc/hosts.equiv` et `.rhosts`.|

Le fichier /etc/hosts.equiv contient une liste d'hôtes de confiance et est utilisé pour accorder l'accès à d'autres systèmes sur le réseau. Lorsque les utilisateurs de l'un de ces hôtes tentent d'accéder au système, l'accès leur est automatiquement accordé sans authentification supplémentaire.

#### /etc/hosts.equiv

        shellsession
`ppporrkkky@htb[/htb]$ cat /etc/hosts.equiv  # <hostname> <local username> pwnbox cry0l1t3`

Maintenant que nous avons une compréhension de base des `r-commands`, faisons une petite prise d'empreinte rapide en utilisant `Nmap` pour déterminer si tous les ports nécessaires sont ouverts.

#### Scan à la recherche de R-Services

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap -sV -p 512,513,514 10.0.17.2  Starting Nmap 7.80 ( https://nmap.org ) at 2022-12-02 15:02 EST Nmap scan report for 10.0.17.2 Host is up (0.11s latency).  PORT    STATE SERVICE    VERSION 512/tcp open  exec? 513/tcp open  login? 514/tcp open  tcpwrapped  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 145.54 seconds`

#### Contrôle d'accès & Relations de confiance

La principale préoccupation concernant les `r-services`, et l'une des principales raisons pour lesquelles `SSH` a été introduit pour les remplacer, réside dans les problèmes inhérents au contrôle d'accès de ces protocoles. Les R-services s'appuient sur des informations de confiance envoyées par le client distant à la machine hôte sur laquelle ils tentent de s'authentifier. Par défaut, ces services utilisent les [Modules d'authentification enfichables (PAM, Pluggable Authentication Modules)](https://web.archive.org/web/20241102161436/https://debathena.mit.edu/trac/wiki/PAM) pour l'authentification de l'utilisateur sur un système distant ; cependant, ils contournent également cette authentification en utilisant les fichiers `/etc/hosts.equiv` et `.rhosts` sur le système. Les fichiers `hosts.equiv` et `.rhosts` contiennent une liste d'hôtes (`IPs` ou `Hostnames`) et d'utilisateurs qui sont `trusted` (de confiance) par l'hôte local lorsqu'une tentative de connexion est effectuée à l'aide des `r-commands`. Les entrées dans l'un ou l'autre fichier peuvent apparaître comme suit :

**Note :** Le fichier `hosts.equiv` est reconnu comme la configuration globale concernant tous les utilisateurs d'un système, tandis que `.rhosts` fournit une configuration par utilisateur.

#### Exemple de fichier .rhosts

        shellsession
`ppporrkkky@htb[/htb]$ cat .rhosts  htb-student     10.0.17.5 +               10.0.17.10 +               +`

Comme nous pouvons le voir dans cet exemple, les deux fichiers suivent la syntaxe spécifique des paires `<username> <ip address>` ou `<username> <hostname>`. De plus, le modificateur `+` peut être utilisé dans ces fichiers comme un joker pour tout spécifier. Dans cet exemple, le modificateur `+` permet à n'importe quel utilisateur externe d'accéder aux r-commands depuis le compte utilisateur `htb-student` via l'hôte avec l'adresse IP `10.0.17.10`.

Des mauvaises configurations dans l'un ou l'autre de ces fichiers peuvent permettre à un attaquant de s'authentifier en tant qu'un autre utilisateur sans identifiants, avec la possibilité d'obtenir une exécution de code. Maintenant que nous comprenons comment nous pouvons potentiellement abuser des mauvaises configurations de ces fichiers, essayons de nous connecter à un hôte cible en utilisant `rlogin`.

#### Connexion avec Rlogin

        shellsession
`ppporrkkky@htb[/htb]$ rlogin 10.0.17.2 -l htb-student  Last login: Fri Dec  2 16:11:21 from localhost  [htb-student@localhost ~]$`

Nous nous sommes connectés avec succès sous le compte `htb-student` sur l'hôte distant en raison des mauvaises configurations dans le fichier `.rhosts`. Une fois connecté avec succès, nous pouvons également abuser de la commande `rwho` pour lister toutes les sessions interactives sur le réseau local en envoyant des requêtes au port UDP 513.

#### Lister les utilisateurs authentifiés avec Rwho

        shellsession
`ppporrkkky@htb[/htb]$ rwho  root     web01:pts/0 Dec  2 21:34 htb-student     workstn01:tty1  Dec  2 19:57  2:25`       

À partir de ces informations, nous pouvons voir que l'utilisateur `htb-student` est actuellement authentifié sur l'hôte `workstn01`, tandis que l'utilisateur `root` est authentifié sur l'hôte `web01`. Nous pouvons utiliser cela à notre avantage lors de la recherche de noms d'utilisateur potentiels à utiliser lors d'attaques ultérieures sur des hôtes du réseau. Cependant, le démon `rwho` diffuse périodiquement des informations sur les utilisateurs connectés, il peut donc être avantageux de surveiller le trafic réseau.

#### Lister les utilisateurs authentifiés avec Rusers

Pour fournir des informations supplémentaires en conjonction avec `rwho`, nous pouvons lancer la commande `rusers`. Cela nous donnera un compte rendu plus détaillé de tous les utilisateurs connectés sur le réseau, y compris des informations telles que le nom d'utilisateur, le nom d'hôte de la machine accédée, le TTY sur lequel l'utilisateur est connecté, la date et l'heure de connexion de l'utilisateur, le temps écoulé depuis que l'utilisateur a tapé sur le clavier, et l'hôte distant depuis lequel il s'est connecté (le cas échéant).

        shellsession
`ppporrkkky@htb[/htb]$ rusers -al 10.0.17.5  htb-student     10.0.17.5:console          Dec 2 19:57     2:25`

Comme nous pouvons le voir, les R-services sont moins fréquemment utilisés de nos jours en raison de leurs failles de sécurité inhérentes et de la disponibilité de protocoles plus sécurisés tels que SSH. Pour être un professionnel de la sécurité de l'information complet, nous devons avoir une compréhension large et approfondie de nombreux systèmes, applications, protocoles, etc. Alors, gardez en mémoire ces connaissances sur les R-services, car on ne sait jamais quand on peut les rencontrer.

---

## Réflexions finales

Les services de gestion à distance peuvent nous fournir un trésor de données et sont souvent détournés pour un accès non autorisé par le biais d'identifiants faibles/par défaut ou de la réutilisation de mots de passe. Nous devrions toujours sonder ces services pour recueillir autant d'informations que possible et ne négliger aucune piste, surtout lorsque nous avons compilé une liste d'identifiants provenant d'autres parties du réseau cible.