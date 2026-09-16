[[Metasploitable HTB]]

Dans `msfconsole`, les `Databases` (bases de données) sont utilisées pour suivre vos résultats. Ce n'est un secret pour personne que lors d'évaluations de machines, même les plus complexes, et encore plus de réseaux entiers, les choses peuvent devenir un peu floues et compliquées en raison de la quantité considérable de résultats de recherche, de points d'entrée (entry points), de problèmes détectés, d'identifiants (credentials) découverts, etc.

C'est là que les bases de données entrent en jeu. `Msfconsole` intègre la prise en charge du système de base de données PostgreSQL. Grâce à lui, nous avons un accès direct, rapide et facile aux résultats de scan, avec la possibilité supplémentaire d'importer et d'exporter des résultats conjointement avec des outils tiers. Les entrées de la base de données peuvent également être utilisées pour configurer directement les paramètres des modules d'exploit avec les découvertes déjà existantes.

---

## Mise en place de la base de données

Tout d'abord, nous devons nous assurer que le serveur PostgreSQL est opérationnel sur notre machine hôte. Pour ce faire, saisissez la commande suivante :

#### État de PostgreSQL

        shellsession
`ppporrkkky@htb[/htb]$ sudo service postgresql status  ● postgresql.service - PostgreSQL RDBMS      Loaded: loaded (/lib/systemd/system/postgresql.service; disabled; vendor preset: disabled)      Active: active (exited) since Fri 2022-05-06 14:51:30 BST; 3min 51s ago     Process: 2147 ExecStart=/bin/true (code=exited, status=0/SUCCESS)    Main PID: 2147 (code=exited, status=0/SUCCESS)         CPU: 1ms  May 06 14:51:30 pwnbox-base systemd[1]: Starting PostgreSQL RDBMS... May 06 14:51:30 pwnbox-base systemd[1]: Finished PostgreSQL RDBMS.`

#### Démarrer PostgreSQL

        shellsession
`ppporrkkky@htb[/htb]$ sudo systemctl start postgresql`

Après avoir démarré PostgreSQL, nous devons créer et initialiser la base de données MSF avec `msfdb init`.

#### MSF - Initialiser une base de données

        shellsession
``ppporrkkky@htb[/htb]$ sudo msfdb init  [i] Database already started [+] Creating database user 'msf' [+] Creating databases 'msf' [+] Creating databases 'msf_test' [+] Creating configuration file '/usr/share/metasploit-framework/config/database.yml' [+] Creating initial database schema rake aborted! NoMethodError: undefined method `without' for #<Bundler::Settings:0x000055dddcf8cba8> Did you mean? with_options  <SNIP>``

Parfois, une erreur peut se produire si Metasploit n'est pas à jour. Cette différence qui cause l'erreur peut survenir pour plusieurs raisons. Souvent, il est utile de mettre à jour Metasploit à nouveau (`apt update`) pour résoudre ce problème. Ensuite, nous pouvons essayer de réinitialiser la base de données MSF.

        shellsession
`ppporrkkky@htb[/htb]$ sudo msfdb init  [i] Database already started [i] The database appears to be already configured, skipping initialization`

Si l'initialisation est ignorée et que Metasploit nous indique que la base de données est déjà configurée, nous pouvons revérifier l'état de la base de données.

        shellsession
`ppporrkkky@htb[/htb]$ sudo msfdb status  ● postgresql.service - PostgreSQL RDBMS      Loaded: loaded (/lib/systemd/system/postgresql.service; disabled; vendor preset: disabled)      Active: active (exited) since Mon 2022-05-09 15:19:57 BST; 35min ago     Process: 2476 ExecStart=/bin/true (code=exited, status=0/SUCCESS)    Main PID: 2476 (code=exited, status=0/SUCCESS)         CPU: 1ms  May 09 15:19:57 pwnbox-base systemd[1]: Starting PostgreSQL RDBMS... May 09 15:19:57 pwnbox-base systemd[1]: Finished PostgreSQL RDBMS.  COMMAND   PID     USER   FD   TYPE DEVICE SIZE/OFF NODE NAME postgres 2458 postgres    5u  IPv6  34336      0t0  TCP localhost:5432 (LISTEN) postgres 2458 postgres    6u  IPv4  34337      0t0  TCP localhost:5432 (LISTEN)  UID          PID    PPID  C STIME TTY      STAT   TIME CMD postgres    2458       1  0 15:19 ?        Ss     0:00 /usr/lib/postgresql/13/bin/postgres -D /var/lib/postgresql/13/main -c con  [+] Detected configuration file (/usr/share/metasploit-framework/config/database.yml)`

Si cette erreur n'apparaît pas, ce qui arrive souvent après une nouvelle installation de Metasploit, nous verrons ce qui suit lors de l'initialisation de la base de données :

        shellsession
`ppporrkkky@htb[/htb]$ sudo msfdb init  [+] Starting database [+] Creating database user 'msf' [+] Creating databases 'msf' [+] Creating databases 'msf_test' [+] Creating configuration file '/usr/share/metasploit-framework/config/database.yml' [+] Creating initial database schema`

Une fois la base de données initialisée, nous pouvons démarrer `msfconsole` et nous connecter simultanément à la base de données créée.

#### MSF - Se connecter à la base de données initialisée

        shellsession
`ppporrkkky@htb[/htb]$ sudo msfdb run  [i] Database already started                                                             .                                         .  .        dBBBBBBb  dBBBP dBBBBBBP dBBBBBb  .                       o        '   dB'                     BBP     dB'dB'dB' dBBP     dBP     dBP BB    dB'dB'dB' dBP      dBP     dBP  BB   dB'dB'dB' dBBBBP   dBP     dBBBBBBB                                     dBBBBBP  dBBBBBb  dBP    dBBBBP dBP dBBBBBBP           .                  .                  dB' dBP    dB'.BP                              |       dBP    dBBBB' dBP    dB'.BP dBP    dBP                            --o--    dBP    dBP    dBP    dB'.BP dBP    dBP                              |     dBBBBP dBP    dBBBBP dBBBBP dBP    dBP                                                                      .                 .         o                  To boldly go where no                             shell has gone before          =[ metasploit v6.1.39-dev                          ] + -- --=[ 2214 exploits - 1171 auxiliary - 396 post       ] + -- --=[ 616 payloads - 45 encoders - 11 nops            ] + -- --=[ 9 evasion                                       ]  msf6>`

Si, cependant, nous avons déjà la base de données configurée et ne pouvons pas changer le mot de passe du nom d'utilisateur MSF, procédez avec ces commandes :

#### MSF - Réinitialiser la base de données

        shellsession
`ppporrkkky@htb[/htb]$ msfdb reinit ppporrkkky@htb[/htb]$ cp /usr/share/metasploit-framework/config/database.yml ~/.msf4/ ppporrkkky@htb[/htb]$ sudo service postgresql restart ppporrkkky@htb[/htb]$ msfconsole -q  msf6 > db_status  [*] Connected to msf. Connection type: PostgreSQL.`

Maintenant, nous sommes prêts. `msfconsole` offre également une aide intégrée pour la base de données. Cela nous donne un bon aperçu de la manière d'interagir avec la base de données et de l'utiliser.

#### MSF - Options de la base de données

        shellsession
`msf6 > help database  Database Backend Commands =========================      Command           Description     -------           -----------     db_connect        Se connecter à une base de données existante     db_disconnect     Se déconnecter de l'instance de base de données actuelle     db_export         Exporter un fichier contenant le contenu de la base de données     db_import         Importer un fichier de résultats de scan (le type de fichier sera auto-détecté)     db_nmap           Exécute nmap et enregistre automatiquement la sortie     db_rebuild_cache  Reconstruit le cache des modules stocké dans la base de données     db_status         Afficher l'état actuel de la base de données     hosts             Lister tous les hôtes dans la base de données     loot              Lister tout le butin dans la base de données     notes             Lister toutes les notes dans la base de données     services          Lister tous les services dans la base de données     vulns             Lister toutes les vulnérabilités dans la base de données     workspace         Changer d'espace de travail de base de données       msf6 > db_status  [*] Connected to msf. Connection type: postgresql.`

---

## Utilisation de la base de données

Avec l'aide de la base de données, nous pouvons gérer de nombreuses catégories et hôtes différents que nous avons analysés. Alternativement, les informations les concernant avec lesquelles nous avons interagi en utilisant Metasploit. Ces bases de données peuvent être exportées et importées. C'est particulièrement utile lorsque nous avons de longues listes d'hôtes, de butin (loot), de notes et de vulnérabilités stockées pour ces hôtes. Après avoir confirmé que la base de données est connectée avec succès, nous pouvons organiser nos `Workspaces` (espaces de travail).

#### Espaces de travail

Nous pouvons considérer les `Workspaces` (espaces de travail) de la même manière que nous considérerions des dossiers dans un projet. Nous pouvons séparer les différents résultats de scan, les hôtes et les informations extraites par IP, sous-réseau, réseau ou domaine.

Pour afficher la liste actuelle des espaces de travail, utilisez la commande `workspace`. L'ajout d'une option `-a` ou `-d` après la commande, suivie du nom de l'espace de travail, `ajoutera` ou `supprimera` cet espace de travail de la base de données.

        shellsession
`msf6 > workspace  * default`

Remarquez que l'espace de travail par défaut est nommé `default` et est actuellement utilisé, comme l'indique le symbole `*`. Tapez la commande `workspace [nom]` pour changer l'espace de travail actuellement utilisé. En revenant à notre exemple, créons un espace de travail pour cette évaluation et sélectionnons-le.

        shellsession
`msf6 > workspace -a Target_1  [*] Added workspace: Target_1 [*] Workspace: Target_1   msf6 > workspace Target_1   [*] Workspace: Target_1   msf6 > workspace    default * Target_1`

Pour voir ce que nous pouvons faire d'autre avec les espaces de travail, nous pouvons utiliser la commande `workspace -h` pour le menu d'aide relatif aux espaces de travail.

        shellsession
`msf6 > workspace -h  Usage:     workspace                  Lister les espaces de travail     workspace -v               Lister les espaces de travail de manière détaillée     workspace [name]           Changer d'espace de travail     workspace -a [name] ...    Ajouter un ou plusieurs espaces de travail     workspace -d [name] ...    Supprimer un ou plusieurs espaces de travail     workspace -D               Supprimer tous les espaces de travail     workspace -r     Renommer l'espace de travail     workspace -h               Afficher ces informations d'aide`

---

## Importation des résultats de scan

Ensuite, supposons que nous voulons importer un `scan Nmap` d'un hôte dans l'espace de travail de notre base de données pour mieux comprendre la cible. Nous pouvons utiliser la commande `db_import` pour cela. Une fois l'importation terminée, nous pouvons vérifier la présence des informations de l'hôte dans notre base de données en utilisant les commandes `hosts` et `services`. Notez que le type de fichier `.xml` est préféré pour `db_import`.

#### Scan Nmap stocké

        shellsession
`ppporrkkky@htb[/htb]$ cat Target.nmap  Starting Nmap 7.80 ( https://nmap.org ) at 2020-08-17 20:54 UTC Nmap scan report for 10.10.10.40 Host is up (0.017s latency). Not shown: 991 closed ports PORT      STATE SERVICE      VERSION 135/tcp   open  msrpc        Microsoft Windows RPC 139/tcp   open  netbios-ssn  Microsoft Windows netbios-ssn 445/tcp   open  microsoft-ds Microsoft Windows 7 - 10 microsoft-ds (workgroup: WORKGROUP) 49152/tcp open  msrpc        Microsoft Windows RPC 49153/tcp open  msrpc        Microsoft Windows RPC 49154/tcp open  msrpc        Microsoft Windows RPC 49155/tcp open  msrpc        Microsoft Windows RPC 49156/tcp open  msrpc        Microsoft Windows RPC 49157/tcp open  msrpc        Microsoft Windows RPC Service Info: Host: HARIS-PC; OS: Windows; CPE: cpe:/o:microsoft:windows  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 60.81 seconds`

#### Importation des résultats de scan

        shellsession
`msf6 > db_import Target.xml  [*] Importing 'Nmap XML' data [*] Import: Parsing with 'Nokogiri v1.10.9' [*] Importing host 10.10.10.40 [*] Successfully imported ~/Target.xml   msf6 > hosts  Hosts =====  address      mac  name  os_name  os_flavor  os_sp  purpose  info  comments -------      ---  ----  -------  ---------  -----  -------  ----  -------- 10.10.10.40             Unknown                    device            msf6 > services  Services ========  host         port   proto  name          state  info ----         ----   -----  ----          -----  ---- 10.10.10.40  135    tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  139    tcp    netbios-ssn   open   Microsoft Windows netbios-ssn 10.10.10.40  445    tcp    microsoft-ds  open   Microsoft Windows 7 - 10 microsoft-ds workgroup: WORKGROUP 10.10.10.40  49152  tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  49153  tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  49154  tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  49155  tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  49156  tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  49157  tcp    msrpc         open   Microsoft Windows RPC`

---

## Utilisation de Nmap à l'intérieur de MSFconsole

Alternativement, nous pouvons utiliser Nmap directement depuis msfconsole ! Pour scanner directement depuis la console sans avoir à mettre le processus en arrière-plan ou à le quitter, utilisez la commande `db_nmap`.

#### MSF - Nmap

        shellsession
`msf6 > db_nmap -sV -sS 10.10.10.8  [*] Nmap: Starting Nmap 7.80 ( https://nmap.org ) at 2020-08-17 21:04 UTC [*] Nmap: Nmap scan report for 10.10.10.8 [*] Nmap: Host is up (0.016s latency). [*] Nmap: Not shown: 999 filtered ports [*] Nmap: PORT   STATE SERVICE VERSION [*] Nmap: 80/TCP open  http    HttpFileServer httpd 2.3 [*] Nmap: Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows [*] Nmap: Service detection performed. Please report any incorrect results at https://nmap.org/submit/  [*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 11.12 seconds   msf6 > hosts  Hosts =====  address      mac  name  os_name  os_flavor  os_sp  purpose  info  comments -------      ---  ----  -------  ---------  -----  -------  ----  -------- 10.10.10.8              Unknown                    device          10.10.10.40             Unknown                    device            msf6 > services  Services ========  host         port   proto  name          state  info ----         ----   -----  ----          -----  ---- 10.10.10.8   80     tcp    http          open   HttpFileServer httpd 2.3 10.10.10.40  135    tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  139    tcp    netbios-ssn   open   Microsoft Windows netbios-ssn 10.10.10.40  445    tcp    microsoft-ds  open   Microsoft Windows 7 - 10 microsoft-ds workgroup: WORKGROUP 10.10.10.40  49152  tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  49153  tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  49154  tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  49155  tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  49156  tcp    msrpc         open   Microsoft Windows RPC 10.10.10.40  49157  tcp    msrpc         open   Microsoft Windows RPC`

---

## Sauvegarde des données

Après avoir terminé la session, assurez-vous de sauvegarder vos données au cas où quelque chose arriverait au service PostgreSQL. Pour ce faire, utilisez la commande `db_export`.

#### MSF - Exportation de la base de données

        shellsession
`msf6 > db_export -h  Usage:     db_export -f <format> [filename]     Le format peut être l'un des suivants : xml, pwdump [-] Aucun fichier de sortie n'a été spécifié   msf6 > db_export -f xml backup.xml  [*] Starting export of workspace default to backup.xml [ xml ]... [*] Finished export of workspace default to backup.xml [ xml ]...`

Ces données peuvent être réimportées dans msfconsole plus tard si nécessaire. D'autres commandes liées à la conservation des données sont l'utilisation étendue de `hosts`, `services`, et les commandes `creds` et `loot`.

---

## Hôtes

La commande `hosts` affiche un tableau de base de données automatiquement rempli avec les adresses des hôtes, leurs noms d'hôte et d'autres informations que nous trouvons à leur sujet lors de nos scans et interactions. Par exemple, si `msfconsole` est lié à des plugins de scanner qui peuvent effectuer une détection de service et de système d'exploitation, ces informations devraient apparaître automatiquement dans le tableau une fois les scans terminés via msfconsole. Encore une fois, des outils comme Nessus, NexPose ou Nmap nous aideront dans ces cas.

Les hôtes peuvent également être ajoutés manuellement comme des entrées séparées dans ce tableau. Après avoir ajouté nos hôtes personnalisés, nous pouvons également organiser le format et la structure du tableau, ajouter des commentaires, modifier les informations existantes, et plus encore.

#### MSF - Hôtes stockés

        shellsession
`msf6 > hosts -h  Usage: hosts [ options ] [addr1 addr2 ...]  OPTIONS:   -a,--add          Ajouter les hôtes au lieu de chercher   -d,--delete       Supprimer les hôtes au lieu de chercher   -c <col1,col2>    Afficher uniquement les colonnes spécifiées (voir la liste ci-dessous)   -C <col1,col2>    Afficher uniquement les colonnes spécifiées jusqu'au prochain redémarrage (voir la liste ci-dessous)   -h,--help         Afficher ces informations d'aide   -u,--up           Afficher uniquement les hôtes qui sont actifs   -o <file>         Envoyer la sortie vers un fichier au format CSV   -O <column>       Trier les lignes par le numéro de colonne spécifié   -R,--rhosts       Définir RHOSTS à partir des résultats de la recherche   -S,--search       Chaîne de recherche pour filtrer   -i,--info         Changer les informations d'un hôte   -n,--name         Changer le nom d'un hôte   -m,--comment      Changer le commentaire d'un hôte   -t,--tag          Ajouter ou spécifier une étiquette à une plage d'hôtes  Available columns: address, arch, comm, comments, created_at, cred_count, detected_arch, exploit_attempt_count, host_detail_count, info, mac, name, note_count, os_family, os_flavor, os_lang, os_name, os_sp, purpose, scope, service_count, state, updated_at, virtual_host, vuln_count, tags`

---

## Services

La commande `services` fonctionne de la même manière que la précédente. Elle contient un tableau avec des descriptions et des informations sur les services découverts lors des scans ou des interactions. De la même manière que la commande ci-dessus, les entrées ici sont hautement personnalisables.

#### MSF - Services stockés des hôtes

        shellsession
`msf6 > services -h  Usage: services [-h] [-u] [-a] [-r <proto>] [-p <port1,port2>] [-s <name1,name2>] [-o <filename>] [addr1 addr2 ...]    -a,--add          Ajouter les services au lieu de chercher   -d,--delete       Supprimer les services au lieu de chercher   -c <col1,col2>    Afficher uniquement les colonnes spécifiées   -h,--help         Afficher ces informations d'aide   -s <name>         Nom du service à ajouter   -p <port>         Rechercher une liste de ports   -r <protocol>     Type de protocole du service à ajouter [tcp|udp]   -u,--up           Afficher uniquement les services qui sont actifs   -o <file>         Envoyer la sortie vers un fichier au format csv   -O <column>       Trier les lignes par le numéro de colonne spécifié   -R,--rhosts       Définir RHOSTS à partir des résultats de la recherche   -S,--search       Chaîne de recherche pour filtrer   -U,--update       Mettre à jour les données pour un service existant  Available columns: created_at, info, name, port, proto, state, updated_at`

---

## Identifiants

La commande `creds` vous permet de visualiser les identifiants collectés lors de vos interactions avec l'hôte cible. Nous pouvons également ajouter des identifiants manuellement, faire correspondre des identifiants existants avec des spécifications de port, ajouter des descriptions, etc.

#### MSF - Identifiants stockés

        shellsession
`msf6 > creds -h  Sans sous-commande, liste les identifiants. Si une plage d'adresses est donnée, n'affiche que les identifiants avec des connexions sur des hôtes dans cette plage.  Utilisation - Lister les identifiants :   creds [options de filtrage] [plage d'adresses]  Utilisation - Ajouter des identifiants :   creds add utilise les paramètres nommés suivants.     user      :  Public, généralement un nom d'utilisateur     password  :  Privé, private_type Mot de passe.     ntlm      :  Privé, private_type Hash NTLM.     Postgres  :  Privé, private_type Postgres MD5     ssh-key   :  Privé, private_type Clé SSH, doit être un chemin de fichier.     hash      :  Privé, private_type Hash non rejouable     jtr       :  Privé, private_type Type de hash John the Ripper.     realm     :  Domaine (realm),      realm-type:  Domaine (realm), realm_type (domain db2db sid pgdb rsync wildcard), par défaut domain.  Exemples : Ajout    # Ajouter un utilisateur, un mot de passe et un domaine (realm)    creds add user:admin password:notpassword realm:workgroup    # Ajouter un utilisateur et un mot de passe    creds add user:guest password:'guest password'    # Ajouter un mot de passe    creds add password:'password without username'    # Ajouter un utilisateur avec un NTLMHash    creds add user:admin ntlm:E2FC15074BF7751DD408E6B105741864:A1074A69B1BDE45403AB680504BBDD1A    # Ajouter un NTLMHash    creds add ntlm:E2FC15074BF7751DD408E6B105741864:A1074A69B1BDE45403AB680504BBDD1A    # Ajouter un MD5 Postgres    creds add user:postgres postgres:md5be86a79bf2043622d58d5453c47d4860    # Ajouter un utilisateur avec une clé SSH    creds add user:sshadmin ssh-key:/path/to/id_rsa    # Ajouter un utilisateur et un NonReplayableHash    creds add user:other hash:d19c32489b870735b5f587d76b934283 jtr:md5    # Ajouter un NonReplayableHash    creds add hash:d19c32489b870735b5f587d76b934283  Options générales   -h,--help             Afficher ces informations d'aide   -o <file>             Envoyer la sortie vers un fichier au format csv/jtr (john the ripper).                         Si le nom du fichier se termine par '.jtr', ce format sera utilisé.                         Si le nom du fichier se termine par '.hcat', le format hashcat sera utilisé.                         CSV par défaut.   -d,--delete           Supprimer un ou plusieurs identifiants  Options de filtrage pour la liste   -P,--password <text>  Lister les mots de passe qui correspondent à ce texte   -p,--port <portspec>  Lister les identifiants avec des connexions sur des services correspondant à cette spécification de port   -s <svc names>        Lister les identifiants correspondant aux noms de service séparés par des virgules   -u,--user <text>      Lister les utilisateurs qui correspondent à ce texte   -t,--type <type>      Lister les identifiants qui correspondent aux types suivants : password,ntlm,hash   -O,--origins <IP>     Lister les identifiants qui correspondent à ces origines   -R,--rhosts           Définir RHOSTS à partir des résultats de la recherche   -v,--verbose          Ne pas tronquer les longs hachs de mot de passe  Exemples, types de hachs John the Ripper :   Systèmes d'exploitation (commence par)     Blowfish ($2a$)   : bf     BSDi     (_)      : bsdi     DES               : des,crypt     MD5      ($1$)    : md5     SHA256   ($5$)    : sha256,crypt     SHA512   ($6$)    : sha512,crypt   Bases de données     MSSQL             : mssql     MSSQL 2005        : mssql05     MSSQL 2012/2014   : mssql12     MySQL < 4.1       : mysql     MySQL >= 4.1      : mysql-sha1     Oracle            : des,oracle     Oracle 11         : raw-sha1,oracle11     Oracle 11 (H type): dynamic_1506     Oracle 12c        : oracle12c     Postgres          : postgres,raw-md5  Exemples, listage :   creds               # Par défaut, renvoie tous les identifiants   creds 1.2.3.4/24    # Renvoie les identifiants avec des connexions dans cette plage   creds -O 1.2.3.4/24 # Renvoie les identifiants avec des origines dans cette plage   creds -p 22-25,445  # Spécification de port nmap   creds -s ssh,smb    # Tous les identifiants associés à une connexion sur les services SSH ou SMB   creds -t NTLM       # Tous les identifiants NTLM   creds -j md5        # Tous les identifiants de type de hash John the Ripper MD5  Exemple, suppression :   # Supprimer tous les identifiants SMB   creds -d -s smb`

---

## Butin

La commande `loot` fonctionne conjointement avec la commande ci-dessus pour vous offrir une liste rapide des services et des utilisateurs compromis. Le butin (loot), dans ce cas, fait référence aux dumps de hachs (hash dumps) de différents types de systèmes, à savoir les hachs, passwd, shadow, et plus encore.

#### MSF - Butin stocké

        shellsession
`msf6 > loot -h  Usage: loot [options]  Info: loot [-h] [addr1 addr2 ...] [-t <type1,type2>]   Ajout: loot -f [fname] -i [info] -a [addr1 addr2 ...] -t [type]   Suppr: loot -d [addr1 addr2 ...]    -a,--add          Ajouter du butin à la liste d'adresses, au lieu de lister   -d,--delete       Supprimer *tout* le butin correspondant à l'hôte et au type   -f,--file         Fichier avec le contenu du butin à ajouter   -i,--info         Informations sur le butin à ajouter   -t <type1,type2>  Rechercher une liste de types   -h,--help         Afficher ces informations d'aide   -S,--search       Chaîne de recherche pour filtrer`