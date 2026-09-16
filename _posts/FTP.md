[[Footprinting HTB]]

# FTP

---

Le `Protocole de Transfert de Fichiers` (`FTP`, pour `File Transfer Protocol`) est l'un des plus anciens protocoles sur Internet. Le FTP fonctionne au sein de la couche application de la pile de protocoles TCP/IP. Il se situe donc au même niveau que `HTTP` ou `POP`. Ces protocoles travaillent également avec le support des navigateurs ou des clients de messagerie pour exécuter leurs services. Il existe aussi des programmes FTP spéciaux pour le Protocole de Transfert de Fichiers.

Imaginons que nous souhaitions téléverser des fichiers locaux sur un serveur et télécharger d'autres fichiers en utilisant le protocole [FTP](https://datatracker.ietf.org/doc/html/rfc959). Dans une connexion FTP, deux canaux sont ouverts. Premièrement, le client et le serveur établissent un canal de contrôle via le `port TCP 21`. Le client envoie des commandes au serveur, et le serveur renvoie des codes de statut. Ensuite, les deux participants à la communication peuvent établir le canal de données via le `port TCP 20`. Ce canal est utilisé exclusivement pour la transmission de données, et le protocole surveille les erreurs durant ce processus. Si une connexion est interrompue pendant la transmission, le transport peut être repris après avoir rétabli le contact.

On distingue le FTP `actif` et le FTP `passif`. Dans la variante active, le client établit la connexion comme décrit via le port TCP 21 et informe ainsi le serveur via quel port côté client le serveur peut transmettre ses réponses. Cependant, si un pare-feu (firewall) protège le client, le serveur ne peut pas répondre car toutes les connexions externes sont bloquées. C'est à cette fin que le `mode passif` a été développé. Ici, le serveur annonce un port par lequel le client peut établir le canal de données. Comme c'est le client qui initie la connexion dans cette méthode, le pare-feu ne bloque pas le transfert.

Le FTP connaît différentes [commandes](https://web.archive.org/web/20230326204635/https://www.smartfile.com/blog/the-ultimate-ftp-commands-list/) et codes de statut. Toutes ces commandes ne sont pas implémentées de manière cohérente sur le serveur. Par exemple, le côté client demande au côté serveur de téléverser ou de télécharger des fichiers, d'organiser des répertoires ou de supprimer des fichiers. Le serveur répond dans chaque cas avec un code de statut qui indique si la commande a été exécutée avec succès. Une liste des codes de statut possibles peut être trouvée [ici](https://en.wikipedia.org/wiki/List_of_FTP_server_return_codes).

Habituellement, nous avons besoin d'identifiants pour utiliser le FTP sur un serveur. Nous devons également savoir que le FTP est un protocole `en texte clair` (`clear-text`) qui peut parfois être intercepté si les conditions sur le réseau le permettent. Cependant, il existe aussi la possibilité qu'un serveur propose un `FTP anonyme`. L'opérateur du serveur autorise alors tout utilisateur à téléverser ou télécharger des fichiers via FTP sans utiliser de mot de passe. Étant donné les risques de sécurité associés à un tel serveur FTP public, les options pour les utilisateurs sont généralement limitées.

---

## TFTP

Le `Protocole Trivial de Transfert de Fichiers` (`TFTP`, pour `Trivial File Transfer Protocol`) est plus simple que le FTP et effectue des transferts de fichiers entre les processus client et serveur. Cependant, il `ne fournit pas` l'authentification des utilisateurs et d'autres fonctionnalités utiles prises en charge par le FTP. De plus, alors que le FTP utilise TCP, le TFTP utilise `UDP`, ce qui en fait un protocole non fiable et l'oblige à utiliser une récupération au niveau de la couche application assistée par UDP.

Cela se reflète, par exemple, dans le fait que le TFTP, contrairement au FTP, ne requiert pas l'authentification de l'utilisateur. Il ne prend pas en charge la connexion protégée par mots de passe et fixe des limites d'accès basées uniquement sur les permissions de lecture et d'écriture d'un fichier dans le système d'exploitation. En pratique, cela conduit le TFTP à opérer exclusivement dans des répertoires et avec des fichiers qui ont été partagés avec tous les utilisateurs et qui peuvent être lus et écrits globalement. En raison du manque de sécurité, le TFTP, contrairement au FTP, ne doit être utilisé que dans des réseaux locaux et protégés.

Jetons un œil à quelques commandes de `TFTP` :

|**Commandes**|**Description**|
|---|---|
|`connect`|Définit l'hôte distant, et optionnellement le port, pour les transferts de fichiers.|
|`get`|Transfère un fichier ou un ensemble de fichiers de l'hôte distant vers l'hôte local.|
|`put`|Transfère un fichier ou un ensemble de fichiers de l'hôte local vers l'hôte distant.|
|`quit`|Quitte tftp.|
|`status`|Affiche l'état actuel de tftp, y compris le mode de transfert actuel (ascii ou binaire), l'état de la connexion, la valeur du délai d'attente, etc.|
|`verbose`|Active ou désactive le mode verbeux, qui affiche des informations supplémentaires pendant le transfert de fichiers.|

Contrairement au client FTP, `TFTP` n'a pas de fonctionnalité de listage de répertoire.

---

## Configuration par Défaut

L'un des serveurs FTP les plus utilisés sur les distributions basées sur Linux est [vsFTPd](https://security.appspot.com/vsftpd.html). La configuration par défaut de vsFTPd se trouve dans `/etc/vsftpd.conf`, et certains paramètres sont déjà prédéfinis par défaut. Il est fortement recommandé d'installer le serveur vsFTPd sur une VM et d'examiner de plus près cette configuration.

#### Installer vsFTPd

        shellsession
`ppporrkkky@htb[/htb]$ sudo apt install vsftpd` 

Le serveur vsFTPd n'est qu'un des quelques serveurs FTP à notre disposition. Il existe de nombreuses alternatives, qui apportent, entre autres, beaucoup plus de fonctions et d'options de configuration. Nous utiliserons le serveur vsFTPd car c'est un excellent moyen de montrer les possibilités de configuration d'un serveur FTP de manière simple et facile à comprendre sans entrer dans les détails des pages de manuel. Si nous examinons le fichier de configuration de vsFTPd, nous verrons de nombreuses options et paramètres qui sont soit commentés, soit commentés. Cependant, le fichier de configuration ne contient pas tous les paramètres possibles qui peuvent être faits. Ceux qui existent et ceux qui manquent peuvent être trouvés sur la [page de manuel](http://vsftpd.beasts.org/vsftpd_conf.html).

#### Fichier de Configuration de vsFTPd

        shellsession
`ppporrkkky@htb[/htb]$ cat /etc/vsftpd.conf | grep -v "#"`

|**Paramètre**|**Description**|
|---|---|
|`listen=NO`|Exécuter depuis inetd ou en tant que démon autonome ?|
|`listen_ipv6=YES`|Écouter sur IPv6 ?|
|`anonymous_enable=NO`|Activer l'accès anonyme ?|
|`local_enable=YES`|Autoriser les utilisateurs locaux à se connecter ?|
|`dirmessage_enable=YES`|Afficher les messages de répertoire actif lorsque les utilisateurs entrent dans certains répertoires ?|
|`use_localtime=YES`|Utiliser l'heure locale ?|
|`xferlog_enable=YES`|Activer la journalisation des téléversements/téléchargements ?|
|`connect_from_port_20=YES`|Se connecter depuis le port 20 ?|
|`secure_chroot_dir=/var/run/vsftpd/empty`|Nom d'un répertoire vide|
|`pam_service_name=vsftpd`|Cette chaîne est le nom du service PAM que vsftpd utilisera.|
|`rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem`|Les trois dernières options spécifient l'emplacement du certificat RSA à utiliser pour les connexions chiffrées SSL.|
|`rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key`||
|`ssl_enable=NO`||

De plus, il existe un fichier appelé `/etc/ftpusers` auquel nous devons également prêter attention, car ce fichier est utilisé pour refuser à certains utilisateurs l'accès au service FTP. Dans l'exemple suivant, les utilisateurs `guest`, `john` et `kevin` ne sont pas autorisés à se connecter au service FTP, même s'ils existent sur le système Linux.

#### FTPUSERS

        shellsession
`ppporrkkky@htb[/htb]$ cat /etc/ftpusers  guest john kevin`

---

## Paramètres Dangereux

Il existe de nombreux paramètres liés à la sécurité que nous pouvons configurer sur chaque serveur FTP. Ceux-ci peuvent avoir divers objectifs, tels que tester les connexions à travers les pare-feu, tester les routes et les mécanismes d'authentification. L'un de ces mécanismes d'authentification est l'utilisateur `anonyme`. Il est souvent utilisé pour permettre à tout le monde sur le réseau interne de partager des fichiers et des données sans accéder aux ordinateurs des autres. Avec vsFTPd, les [paramètres optionnels](http://vsftpd.beasts.org/vsftpd_conf.html) qui peuvent être ajoutés au fichier de configuration pour la connexion anonyme ressemblent à ceci :

|**Paramètre**|**Description**|
|---|---|
|`anonymous_enable=YES`|Autoriser la connexion anonyme ?|
|`anon_upload_enable=YES`|Autoriser les anonymes à téléverser des fichiers ?|
|`anon_mkdir_write_enable=YES`|Autoriser les anonymes à créer de nouveaux répertoires ?|
|`no_anon_password=YES`|Ne pas demander de mot de passe à l'anonyme ?|
|`anon_root=/home/username/ftp`|Répertoire pour l'anonyme.|
|`write_enable=YES`|Autoriser l'utilisation des commandes FTP : STOR, DELE, RNFR, RNTO, MKD, RMD, APPE, et SITE ?|

Avec le client FTP standard (`ftp`), nous pouvons accéder au serveur FTP en conséquence et nous connecter avec l'utilisateur anonyme si les paramètres ci-dessus ont été utilisés. L'utilisation du compte anonyme peut se produire dans des environnements et infrastructures internes où les participants sont tous connus. L'accès à ce type de service peut être défini temporairement ou avec le paramètre pour accélérer l'échange de fichiers.

Dès que nous nous connectons au serveur vsFTPd, le `code de réponse 220` s'affiche avec la bannière du serveur FTP. Souvent, cette bannière contient la description du `service` et même sa `version`. Elle nous indique également le type de système sur lequel se trouve le serveur FTP. L'une des configurations les plus courantes des serveurs FTP est d'autoriser l'accès `anonyme`, qui ne nécessite pas d'identifiants légitimes mais donne accès à certains fichiers. Même si nous ne pouvons pas les télécharger, le simple fait de lister le contenu suffit parfois à générer d'autres idées et à noter des informations qui nous aideront dans une autre approche.

#### Connexion Anonyme

        shellsession
`ppporrkkky@htb[/htb]$ ftp 10.129.14.136  Connected to 10.129.14.136. 220 "Welcome to the HTB Academy vsFTP service." Name (10.129.14.136:cry0l1t3): anonymous  230 Login successful. Remote system type is UNIX. Using binary mode to transfer files.   ftp> ls  200 PORT command successful. Consider using PASV. 150 Here comes the directory listing. -rw-rw-r--    1 1002     1002      8138592 Sep 14 16:54 Calender.pptx drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Clients drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Documents drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Employees -rw-rw-r--    1 1002     1002           41 Sep 14 16:45 Important Notes.txt 226 Directory send OK.`

Cependant, pour avoir un premier aperçu des paramètres du serveur, nous pouvons utiliser la commande suivante :

#### Statut de vsFTPd

        shellsession
`ftp> status  Connected to 10.129.14.136. No proxy connection. Connecting using address family: any. Mode: stream; Type: binary; Form: non-print; Structure: file Verbose: on; Bell: off; Prompting: on; Globbing: on Store unique: off; Receive unique: off Case: off; CR stripping: on Quote control characters: on Ntrans: off Nmap: off Hash mark printing: off; Use of PORT cmds: on Tick counter printing: off`

Certaines commandes doivent être utilisées occasionnellement, car elles amèneront le serveur à nous montrer plus d'informations que nous pouvons utiliser à nos fins. Ces commandes incluent `debug` et `trace`.

#### Sortie Détaillée de vsFTPd

        shellsession
`ftp> debug  Debugging on (debug=1).   ftp> trace  Packet tracing on.   ftp> ls  ---> PORT 10,10,14,4,188,195 200 PORT command successful. Consider using PASV. ---> LIST 150 Here comes the directory listing. -rw-rw-r--    1 1002     1002      8138592 Sep 14 16:54 Calender.pptx drwxrwxr-x    2 1002     1002         4096 Sep 14 17:03 Clients drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Documents drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Employees -rw-rw-r--    1 1002     1002           41 Sep 14 16:45 Important Notes.txt 226 Directory send OK.`

|**Paramètre**|**Description**|
|---|---|
|`dirmessage_enable=YES`|Afficher un message lorsqu'ils entrent pour la première fois dans un nouveau répertoire ?|
|`chown_uploads=YES`|Changer le propriétaire des fichiers téléversés anonymement ?|
|`chown_username=username`|Utilisateur qui devient propriétaire des fichiers téléversés anonymement.|
|`local_enable=YES`|Autoriser les utilisateurs locaux à se connecter ?|
|`chroot_local_user=YES`|Placer les utilisateurs locaux dans leur répertoire personnel ?|
|`chroot_list_enable=YES`|Utiliser une liste d'utilisateurs locaux qui seront placés dans leur répertoire personnel ?|

|**Paramètre**|**Description**|
|---|---|
|`hide_ids=YES`|Toutes les informations sur les utilisateurs et les groupes dans les listages de répertoires seront affichées comme "ftp".|
|`ls_recurse_enable=YES`|Autorise l'utilisation des listages récursifs.|

Dans l'exemple suivant, nous pouvons voir que si le paramètre `hide_ids=YES` est présent, la représentation de l'UID et du GUID du service sera écrasée, ce qui nous rendra plus difficile l'identification des droits avec lesquels ces fichiers sont écrits et téléversés.

#### Cacher les ID - YES

        shellsession
`ftp> ls  ---> TYPE A 200 Switching to ASCII mode. ftp: setsockopt (ignored): Permission denied ---> PORT 10,10,14,4,223,101 200 PORT command successful. Consider using PASV. ---> LIST 150 Here comes the directory listing. -rw-rw-r--    1 ftp     ftp      8138592 Sep 14 16:54 Calender.pptx drwxrwxr-x    2 ftp     ftp         4096 Sep 14 17:03 Clients drwxrwxr-x    2 ftp     ftp         4096 Sep 14 16:50 Documents drwxrwxr-x    2 ftp     ftp         4096 Sep 14 16:50 Employees -rw-rw-r--    1 ftp     ftp           41 Sep 14 16:45 Important Notes.txt -rw-------    1 ftp     ftp            0 Sep 15 14:57 testupload.txt 226 Directory send OK.`

Ce paramètre est une fonctionnalité de sécurité pour empêcher la divulgation des noms d'utilisateurs locaux. Avec les noms d'utilisateurs, nous pourrions théoriquement attaquer les services comme FTP et SSH et bien d'autres avec une attaque par force brute. Cependant, en réalité, les solutions [fail2ban](https://en.wikipedia.org/wiki/Fail2ban) sont maintenant une implémentation standard de toute infrastructure qui journalise l'adresse IP et bloque tout accès à l'infrastructure après un certain nombre de tentatives de connexion échouées.

Un autre paramètre utile que nous pouvons utiliser à nos fins est `ls_recurse_enable=YES`. Il est souvent défini sur le serveur vsFTPd pour avoir une meilleure vue d'ensemble de la structure des répertoires FTP, car il nous permet de voir tout le contenu visible en une seule fois.

#### Listage Récursif

        shellsession
`ftp> ls -R  ---> PORT 10,10,14,4,222,149 200 PORT command successful. Consider using PASV. ---> LIST -R 150 Here comes the directory listing. .: -rw-rw-r--    1 ftp      ftp      8138592 Sep 14 16:54 Calender.pptx drwxrwxr-x    2 ftp      ftp         4096 Sep 14 17:03 Clients drwxrwxr-x    2 ftp      ftp         4096 Sep 14 16:50 Documents drwxrwxr-x    2 ftp      ftp         4096 Sep 14 16:50 Employees -rw-rw-r--    1 ftp      ftp           41 Sep 14 16:45 Important Notes.txt -rw-------    1 ftp      ftp            0 Sep 15 14:57 testupload.txt  ./Clients: drwx------    2 ftp      ftp          4096 Sep 16 18:04 HackTheBox drwxrwxrwx    2 ftp      ftp          4096 Sep 16 18:00 Inlanefreight  ./Clients/HackTheBox: -rw-r--r--    1 ftp      ftp         34872 Sep 16 18:04 appointments.xlsx -rw-r--r--    1 ftp      ftp        498123 Sep 16 18:04 contract.docx -rw-r--r--    1 ftp      ftp        478237 Sep 16 18:04 contract.pdf -rw-r--r--    1 ftp      ftp           348 Sep 16 18:04 meetings.txt  ./Clients/Inlanefreight: -rw-r--r--    1 ftp      ftp         14211 Sep 16 18:00 appointments.xlsx -rw-r--r--    1 ftp      ftp         37882 Sep 16 17:58 contract.docx -rw-r--r--    1 ftp      ftp            89 Sep 16 17:58 meetings.txt -rw-r--r--    1 ftp      ftp        483293 Sep 16 17:59 proposal.pptx  ./Documents: -rw-r--r--    1 ftp      ftp         23211 Sep 16 18:05 appointments-template.xlsx -rw-r--r--    1 ftp      ftp         32521 Sep 16 18:05 contract-template.docx -rw-r--r--    1 ftp      ftp        453312 Sep 16 18:05 contract-template.pdf  ./Employees: 226 Directory send OK.`

`Télécharger` (`Downloading`) des fichiers depuis un tel serveur FTP est l'une des fonctionnalités principales, tout comme `téléverser` (`uploading`) des fichiers que nous avons créés. Cela nous permet, par exemple, d'utiliser des vulnérabilités LFI pour faire exécuter des commandes système à l'hôte. Outre les fichiers que nous pouvons visualiser, télécharger et inspecter. Des attaques sont également possibles avec les journaux FTP, menant à une `Exécution de Commandes à Distance` (`RCE`, pour `Remote Command Execution`). Cela s'applique aux services FTP et à tous ceux que nous pouvons détecter pendant notre phase d'énumération.

#### Télécharger un Fichier

        shellsession
`ftp> ls  200 PORT command successful. Consider using PASV. 150 Here comes the directory listing. -rwxrwxrwx    1 ftp      ftp             0 Sep 16 17:24 Calendar.pptx drwxrwxrwx    4 ftp      ftp          4096 Sep 16 17:57 Clients drwxrwxrwx    2 ftp      ftp          4096 Sep 16 18:05 Documents drwxrwxrwx    2 ftp      ftp          4096 Sep 16 17:24 Employees -rwxrwxrwx    1 ftp      ftp            41 Sep 18 15:58 Important Notes.txt 226 Directory send OK.   ftp> get Important\ Notes.txt  local: Important Notes.txt remote: Important Notes.txt 200 PORT command successful. Consider using PASV. 150 Opening BINARY mode data connection for Important Notes.txt (41 bytes). 226 Transfer complete. 41 bytes received in 0.00 secs (606.6525 kB/s)   ftp> exit  221 Goodbye.`

        shellsession
`ppporrkkky@htb[/htb]$ ls | grep Notes.txt  'Important Notes.txt'`

Nous pouvons également télécharger tous les fichiers et dossiers auxquels nous avons accès en une seule fois. C'est particulièrement utile si le serveur FTP contient de nombreux fichiers différents dans une grande structure de dossiers. Cependant, cela peut déclencher des alarmes car personne de l'entreprise ne souhaite généralement télécharger tous les fichiers et contenus en même temps.

#### Télécharger Tous les Fichiers Disponibles

        shellsession
`ppporrkkky@htb[/htb]$ wget -m --no-passive ftp://anonymous:anonymous@10.129.14.136  --2021-09-19 14:45:58--  ftp://anonymous:*password*@10.129.14.136/                                                     => ‘10.129.14.136/.listing’                                                                      Connecting to 10.129.14.136:21... connected.                                                                Logging in as anonymous ... Logged in! ==> SYST ... done.    ==> PWD ... done. ==> TYPE I ... done.  ==> CWD not needed. ==> PORT ... done.    ==> LIST ... done.                                                                  12.12.1.136/.listing           [ <=>                                  ]     466  --.-KB/s    in 0s                                                                                                                  2021-09-19 14:45:58 (65,8 MB/s) - ‘10.129.14.136/.listing’ saved [466]                                      --2021-09-19 14:45:58--  ftp://anonymous:*password*@10.129.14.136/Calendar.pptx               => ‘10.129.14.136/Calendar.pptx’                                        ==> CWD not required.                                                            ==> SIZE Calendar.pptx ... done.                                                                                                                             ==> PORT ... done.    ==> RETR Calendar.pptx ... done.         ...SNIP...  2021-09-19 14:45:58 (48,3 MB/s) - ‘10.129.14.136/Employees/.listing’ saved [119]  FINISHED --2021-09-19 14:45:58-- Total wall clock time: 0,03s Downloaded: 15 files, 1,7K in 0,001s (3,02 MB/s)`

Une fois que nous avons téléchargé tous les fichiers, `wget` créera un répertoire avec le nom de l'adresse IP de notre cible. Tous les fichiers téléchargés y sont stockés, que nous pouvons ensuite inspecter localement.

        shellsession
`ppporrkkky@htb[/htb]$ tree .  . └── 10.129.14.136     ├── Calendar.pptx     ├── Clients     │   └── Inlanefreight     │       ├── appointments.xlsx     │       ├── contract.docx     │       ├── meetings.txt     │       └── proposal.pptx     ├── Documents     │   ├── appointments-template.xlsx     │   ├── contract-template.docx     │   └── contract-template.pdf     ├── Employees     └── Important Notes.txt  5 directories, 9 files`

Ensuite, nous pouvons vérifier si nous avons les permissions de téléverser des fichiers sur le serveur FTP. Surtout avec les serveurs web, il est courant que les fichiers soient synchronisés et que les développeurs aient un accès rapide aux fichiers. Le FTP est souvent utilisé à cette fin, et la plupart du temps, des erreurs de configuration se trouvent sur des serveurs que les administrateurs pensent ne pas être découvrables. L'attitude selon laquelle les composants du réseau interne ne peuvent pas être accessibles de l'extérieur signifie que le durcissement des systèmes internes est souvent négligé et conduit à des erreurs de configuration.

La capacité de téléverser des fichiers sur le serveur FTP connecté à un serveur web augmente la probabilité d'obtenir un accès direct au serveur web et même un reverse shell qui nous permet d'exécuter des commandes système internes et peut-être même d'élever nos privilèges.

#### Téléverser un Fichier

        shellsession
`ppporrkkky@htb[/htb]$ touch testupload.txt`

Avec la commande `PUT`, nous pouvons téléverser des fichiers du dossier courant vers le serveur FTP.

        shellsession
`ftp> put testupload.txt   local: testupload.txt remote: testupload.txt ---> PORT 10,10,14,4,184,33 200 PORT command successful. Consider using PASV. ---> STOR testupload.txt 150 Ok to send data. 226 Transfer complete.   ftp> ls  ---> TYPE A 200 Switching to ASCII mode. ---> PORT 10,10,14,4,223,101 200 PORT command successful. Consider using PASV. ---> LIST 150 Here comes the directory listing. -rw-rw-r--    1 1002     1002      8138592 Sep 14 16:54 Calender.pptx drwxrwxr-x    2 1002     1002         4096 Sep 14 17:03 Clients drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Documents drwxrwxr-x    2 1002     1002         4096 Sep 14 16:50 Employees -rw-rw-r--    1 1002     1002           41 Sep 14 16:45 Important Notes.txt -rw-------    1 1002     133             0 Sep 15 14:57 testupload.txt 226 Directory send OK.`

---

## Prise d'empreinte du service (Footprinting)

La prise d'empreinte (footprinting) à l'aide de divers scanners de réseau est également une approche pratique et répandue. Ces outils nous facilitent l'identification de différents services, même s'ils ne sont pas accessibles sur des ports standards. L'un des outils les plus utilisés à cette fin est Nmap. Nmap apporte également le `Nmap Scripting Engine` (`NSE`), un ensemble de nombreux scripts différents écrits pour des services spécifiques. Plus d'informations sur les capacités de Nmap et NSE peuvent être trouvées dans le module [Network Enumeration with Nmap](https://academy.hackthebox.com/course/preview/network-enumeration-with-nmap). Nous pouvons mettre à jour cette base de données de scripts NSE avec la commande montrée.

#### Scripts FTP de Nmap

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap --script-updatedb  Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-19 13:49 CEST NSE: Updating rule database. NSE: Script Database updated successfully. Nmap done: 0 IP addresses (0 hosts up) scanned in 0.28 seconds`

Tous les scripts NSE sont situés sur la Pwnbox dans `/usr/share/nmap/scripts/`, mais sur nos systèmes, nous pouvons les trouver en utilisant une simple commande.

        shellsession
`ppporrkkky@htb[/htb]$ find / -type f -name ftp* 2>/dev/null | grep scripts  /usr/share/nmap/scripts/ftp-syst.nse /usr/share/nmap/scripts/ftp-vsftpd-backdoor.nse /usr/share/nmap/scripts/ftp-vuln-cve2010-4221.nse /usr/share/nmap/scripts/ftp-proftpd-backdoor.nse /usr/share/nmap/scripts/ftp-bounce.nse /usr/share/nmap/scripts/ftp-libopie.nse /usr/share/nmap/scripts/ftp-anon.nse /usr/share/nmap/scripts/ftp-brute.nse`

Comme nous le savons déjà, le serveur FTP fonctionne généralement sur le port TCP standard 21, que nous pouvons scanner en utilisant Nmap. Nous utilisons également le scan de version (`-sV`), le scan agressif (`-A`), et le scan de script par défaut (`-sC`) contre notre cible `10.129.14.136`.

#### Nmap

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap -sV -p21 -sC -A 10.129.14.136  Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-16 18:12 CEST Nmap scan report for 10.129.14.136 Host is up (0.00013s latency).  PORT   STATE SERVICE VERSION 21/tcp open  ftp     vsftpd 2.0.8 or later | ftp-anon: Anonymous FTP login allowed (FTP code 230) | -rwxrwxrwx    1 ftp      ftp       8138592 Sep 16 17:24 Calendar.pptx [NSE: writeable] | drwxrwxrwx    4 ftp      ftp          4096 Sep 16 17:57 Clients [NSE: writeable] | drwxrwxrwx    2 ftp      ftp          4096 Sep 16 18:05 Documents [NSE: writeable] | drwxrwxrwx    2 ftp      ftp          4096 Sep 16 17:24 Employees [NSE: writeable] | -rwxrwxrwx    1 ftp      ftp            41 Sep 16 17:24 Important Notes.txt [NSE: writeable] |_-rwxrwxrwx    1 ftp      ftp             0 Sep 15 14:57 testupload.txt [NSE: writeable] | ftp-syst:  |   STAT:  | FTP server status: |      Connected to 10.10.14.4 |      Logged in as ftp |      TYPE: ASCII |      No session bandwidth limit |      Session timeout in seconds is 300 |      Control connection is plain text |      Data connections will be plain text |      At session startup, client count was 2 |      vsFTPd 3.0.3 - secure, fast, stable |_End of status`

Le scan de script par défaut est basé sur les empreintes (fingerprints) des services, les réponses et les ports standards. Une fois que Nmap a détecté le service, il exécute les scripts marqués les uns après les autres, fournissant différentes informations. Par exemple, le script NSE [ftp-anon](https://nmap.org/nsedoc/scripts/ftp-anon.html) vérifie si le serveur FTP autorise l'accès anonyme. Si c'est le cas, le contenu du répertoire racine FTP est affiché pour l'utilisateur anonyme.

Le `ftp-syst`, par exemple, exécute la commande `STAT`, qui affiche des informations sur l'état du serveur FTP. Cela inclut les configurations ainsi que la version du serveur FTP. Nmap offre également la possibilité de suivre la progression des scripts NSE au niveau du réseau si nous utilisons l'option `--script-trace` dans nos scans. Cela nous permet de voir quelles commandes Nmap envoie, quels ports sont utilisés, et quelles réponses nous recevons du serveur scanné.

#### Trace de Script Nmap

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap -sV -p21 -sC -A 10.129.14.136 --script-trace  Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-19 13:54 CEST                                                                                                                                                    NSOCK INFO [11.4640s] nsock_trace_handler_callback(): Callback: CONNECT SUCCESS for EID 8 [10.129.14.136:21]                                    NSOCK INFO [11.4640s] nsock_trace_handler_callback(): Callback: CONNECT SUCCESS for EID 16 [10.129.14.136:21]              NSOCK INFO [11.4640s] nsock_trace_handler_callback(): Callback: CONNECT SUCCESS for EID 24 [10.129.14.136:21] NSOCK INFO [11.4640s] nsock_trace_handler_callback(): Callback: CONNECT SUCCESS for EID 32 [10.129.14.136:21] NSOCK INFO [11.4640s] nsock_read(): Read request from IOD #1 [10.129.14.136:21] (timeout: 7000ms) EID 42 NSOCK INFO [11.4640s] nsock_read(): Read request from IOD #2 [10.129.14.136:21] (timeout: 9000ms) EID 50 NSOCK INFO [11.4640s] nsock_read(): Read request from IOD #3 [10.129.14.136:21] (timeout: 7000ms) EID 58 NSOCK INFO [11.4640s] nsock_read(): Read request from IOD #4 [10.129.14.136:21] (timeout: 11000ms) EID 66 NSE: TCP 10.10.14.4:54226 > 10.129.14.136:21 | CONNECT NSE: TCP 10.10.14.4:54228 > 10.129.14.136:21 | CONNECT NSE: TCP 10.10.14.4:54230 > 10.129.14.136:21 | CONNECT NSE: TCP 10.10.14.4:54232 > 10.129.14.136:21 | CONNECT NSOCK INFO [11.4660s] nsock_trace_handler_callback(): Callback: READ SUCCESS for EID 50 [10.129.14.136:21] (41 bytes): 220 Welcome to HTB-Academy FTP service... NSOCK INFO [11.4660s] nsock_trace_handler_callback(): Callback: READ SUCCESS for EID 58 [10.129.14.136:21] (41 bytes): 220 Welcome to HTB-Academy FTP service... NSE: TCP 10.10.14.4:54228 < 10.129.14.136:21 | 220 Welcome to HTB-Academy FTP service.`

L'historique du scan montre que quatre scans parallèles différents sont exécutés contre le service, avec divers délais d'attente. Pour les scripts NSE, nous voyons que notre machine locale utilise différents ports de sortie (`54226`, `54228`, `54230`, `54232`) et initie d'abord la connexion avec la commande `CONNECT`. Dès la première réponse du serveur, nous pouvons voir que nous recevons la bannière du serveur pour notre deuxième script NSE (`54228`) depuis le serveur FTP cible. Si nécessaire, nous pouvons, bien sûr, utiliser d'autres applications comme `netcat` ou `telnet` pour interagir avec le serveur FTP.

#### Interaction avec le Service

        shellsession
`ppporrkkky@htb[/htb]$ nc -nv 10.129.14.136 21`

        shellsession
`ppporrkkky@htb[/htb]$ telnet 10.129.14.136 21`

La situation est légèrement différente si le serveur FTP fonctionne avec un chiffrement TLS/SSL. Car alors, nous avons besoin d'un client qui peut gérer TLS/SSL. Pour cela, nous pouvons utiliser le client `openssl` et communiquer avec le serveur FTP. L'avantage d'utiliser `openssl` est que nous pouvons voir le certificat SSL, ce qui peut également être utile.

        shellsession
`ppporrkkky@htb[/htb]$ openssl s_client -connect 10.129.14.136:21 -starttls ftp  CONNECTED(00000003)                                                                                       Can't use SSL_get_servername                         depth=0 C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Dev, CN = master.inlanefreight.htb, emailAddress = admin@inlanefreight.htb verify error:num=18:self signed certificate verify return:1  depth=0 C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Dev, CN = master.inlanefreight.htb, emailAddress = admin@inlanefreight.htb verify return:1 ---                                                  Certificate chain  0 s:C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Dev, CN = master.inlanefreight.htb, emailAddress = admin@inlanefreight.htb    i:C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Dev, CN = master.inlanefreight.htb, emailAddress = admin@inlanefreight.htb ---   Server certificate  -----BEGIN CERTIFICATE-----  MIIENTCCAx2gAwIBAgIUD+SlFZAWzX5yLs2q3ZcfdsRQqMYwDQYJKoZIhvcNAQEL ...SNIP...`

C'est parce que le certificat SSL nous permet de reconnaître le `nom d'hôte` (`hostname`), par exemple, et dans la plupart des cas aussi une `adresse e-mail` pour l'organisation ou l'entreprise. De plus, si l'entreprise a plusieurs sites dans le monde, des certificats peuvent également être créés pour des emplacements spécifiques, qui peuvent également être identifiés à l'aide du certificat SSL.