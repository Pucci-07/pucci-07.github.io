[[Footprinting HTB]]

# SMB

---

Le `Server Message Block` (`SMB`) est un protocole client-serveur qui régule l'accès aux fichiers, à des répertoires entiers et à d'autres ressources réseau telles que des imprimantes, des routeurs ou des interfaces partagées sur le réseau. L'échange d'informations entre les différents processus du système peut également être géré sur la base du protocole SMB. [SMB](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-smb/f210069c-7086-4dc2-885e-861d837df688) a été rendu disponible pour la première fois à un public plus large, par exemple, dans le cadre du système d'exploitation réseau OS/2 LAN Manager et LAN Server. Depuis lors, le principal domaine d'application du protocole a été en particulier la série de systèmes d'exploitation Windows, dont les services réseau prennent en charge SMB de manière rétrocompatible - ce qui signifie que les appareils avec des éditions plus récentes peuvent facilement communiquer avec des appareils sur lesquels un ancien système d'exploitation Microsoft est installé. Avec le projet de logiciel libre Samba, il existe également une solution qui permet l'utilisation de SMB dans les distributions Linux et Unix et donc la communication multiplateforme via SMB.

Le protocole SMB permet au client de communiquer avec d'autres participants du même réseau pour accéder aux fichiers ou aux services partagés avec lui sur le réseau. L'autre système doit également avoir implémenté le protocole réseau et avoir reçu et traité la requête du client à l'aide d'une application serveur SMB. Avant cela, cependant, les deux parties doivent établir une connexion, c'est pourquoi elles échangent d'abord les messages correspondants.

Dans les réseaux IP, SMB utilise le protocole TCP à cette fin, qui prévoit un établissement de liaison en trois temps (three-way handshake) entre le client et le serveur avant qu'une connexion ne soit finalement établie. Les spécifications du protocole TCP régissent également le transport ultérieur des données. Nous pouvons consulter quelques exemples [ici](https://web.archive.org/web/20240815212710/https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SMB2/%5BMS-SMB2%5D.pdf#%5B%7B%22num%22%3A920%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C69%2C738%2C0%5D).

Un serveur SMB peut fournir des parties arbitraires de son système de fichiers local en tant que partages. Par conséquent, la hiérarchie visible pour un client est partiellement indépendante de la structure sur le serveur. Les droits d'accès sont définis par des `Listes de Contrôle d'Accès` (`ACL`). Ils peuvent être contrôlés de manière fine sur la base d'attributs tels que `execute`, `read` et `full access` pour des utilisateurs ou des groupes d'utilisateurs individuels. Les ACL sont définies en fonction des partages et ne correspondent donc pas aux droits attribués localement sur le serveur.

---

## Samba

Comme mentionné précédemment, il existe une implémentation alternative du serveur SMB appelée Samba, qui est développée pour les systèmes d'exploitation basés sur Unix. Samba implémente le protocole réseau `Common Internet File System` (`CIFS`). [CIFS](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-cifs/934c2faa-54af-4526-ac74-6a24d126724e) est un dialecte de SMB, ce qui signifie qu'il s'agit d'une implémentation spécifique du protocole SMB créée à l'origine par Microsoft. Cela permet à Samba de communiquer efficacement avec les systèmes Windows plus récents. Par conséquent, on l'appelle souvent SMB/CIFS.

Cependant, `CIFS` est considéré comme une version spécifique du protocole SMB, s'alignant principalement sur la `version 1 de SMB`. Lorsque les commandes SMB sont transmises via Samba à un ancien service NetBIOS, les connexions se produisent généralement sur les ports TCP `137`, `138` et `139`. En revanche, CIFS fonctionne exclusivement sur le port TCP `445`. Il existe plusieurs versions de SMB, y compris des versions plus récentes comme `SMB 2` et `SMB 3`, qui offrent des améliorations et sont préférées dans les infrastructures modernes, tandis que les anciennes versions comme `SMB 1` (`CIFS`) sont considérées comme obsolètes mais peuvent encore être utilisées dans des environnements spécifiques.

|**Version SMB**|**Pris en charge**|**Fonctionnalités**|
|---|---|---|
|CIFS|Windows NT 4.0|Communication via l'interface NetBIOS|
|SMB 1.0|Windows 2000|Connexion directe via TCP|
|SMB 2.0|Windows Vista, Windows Server 2008|Améliorations des performances, signature de message améliorée, fonctionnalité de mise en cache|
|SMB 2.1|Windows 7, Windows Server 2008 R2|Mécanismes de verrouillage|
|SMB 3.0|Windows 8, Windows Server 2012|Connexions multicanaux, chiffrement de bout en bout, accès au stockage à distance|
|SMB 3.0.2|Windows 8.1, Windows Server 2012 R2||
|SMB 3.1.1|Windows 10, Windows Server 2016|Vérification de l'intégrité, chiffrement AES-128|

Avec la version 3, le serveur Samba a acquis la capacité d'être un membre à part entière d'un domaine Active Directory. Avec la version 4, Samba fournit même un contrôleur de domaine Active Directory. Il contient à cet effet plusieurs programmes appelés démons (daemons) - qui sont des programmes d'arrière-plan Unix. Le démon du serveur SMB (`smbd`) appartenant à Samba fournit les deux premières fonctionnalités, tandis que le démon de bloc de messages NetBIOS (`nmbd`) implémente les deux dernières fonctionnalités. Le service SMB contrôle ces deux programmes d'arrière-plan.

Nous savons que Samba convient aux systèmes Linux et Windows. Dans un réseau, chaque hôte participe au même `workgroup`. Un groupe de travail est un nom de groupe qui identifie un ensemble arbitraire d'ordinateurs et de leurs ressources sur un réseau SMB. Il peut y avoir plusieurs groupes de travail sur le réseau à un moment donné. IBM a développé une `interface de programmation d'application` (`API`) pour la mise en réseau d'ordinateurs appelée `Network Basic Input/Output System` (`NetBIOS`). L'API NetBIOS a fourni un modèle pour qu'une application se connecte et partage des données avec d'autres ordinateurs. Dans un environnement NetBIOS, lorsqu'une machine se met en ligne, elle a besoin d'un nom, ce qui se fait par la procédure dite d'enregistrement de nom (`name registration`). Soit chaque hôte réserve son nom d'hôte sur le réseau, soit le [NetBIOS Name Server](https://networkencyclopedia.com/netbios-name-server-nbns/) (`NBNS`) est utilisé à cette fin. Il a également été amélioré pour devenir le [Windows Internet Name Service](https://networkencyclopedia.com/windows-internet-name-service-wins/) (`WINS`).

---

## Configuration par Défaut

Comme nous pouvons l'imaginer, Samba offre un large éventail de [paramètres](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html) que nous pouvons configurer. Encore une fois, nous définissons les paramètres via un fichier texte où nous pouvons obtenir un aperçu de certains des paramètres. Ces paramètres ressemblent à ce qui suit une fois filtrés :

#### Configuration par Défaut

        shellsession
`ppporrkkky@htb[/htb]$ cat /etc/samba/smb.conf | grep -v "#\|\;"   [global]    workgroup = DEV.INFREIGHT.HTB    server string = DEVSMB    log file = /var/log/samba/log.%m    max log size = 1000    logging = file    panic action = /usr/share/samba/panic-action %d     server role = standalone server    obey pam restrictions = yes    unix password sync = yes     passwd program = /usr/bin/passwd %u    passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .     pam password change = yes    map to guest = bad user    usershare allow guests = yes  [printers]    comment = All Printers    browseable = no    path = /var/spool/samba    printable = yes    guest ok = no    read only = yes    create mask = 0700  [print$]    comment = Printer Drivers    path = /var/lib/samba/printers    browseable = yes    read only = yes    guest ok = no`

Nous voyons les paramètres globaux et deux partages destinés aux imprimantes. Les paramètres globaux sont la configuration du serveur SMB disponible qui est utilisée pour tous les partages. Dans les partages individuels, cependant, les paramètres globaux peuvent être écrasés, ce qui peut être configuré avec une forte probabilité même de manière incorrecte. Examinons certains des paramètres pour comprendre comment les partages sont configurés dans Samba.

|**Paramètre**|**Description**|
|---|---|
|`[sharename]`|Le nom du partage réseau.|
|`workgroup = WORKGROUP/DOMAIN`|Le groupe de travail qui apparaîtra lorsque les clients effectueront des requêtes.|
|`path = /path/here/`|Le répertoire auquel l'utilisateur doit avoir accès.|
|`server string = STRING`|La chaîne qui s'affichera lorsqu'une connexion est initiée.|
|`unix password sync = yes`|Synchroniser le mot de passe UNIX avec le mot de passe SMB ?|
|`usershare allow guests = yes`|Autoriser les utilisateurs non authentifiés à accéder au partage défini ?|
|`map to guest = bad user`|Que faire lorsqu'une demande de connexion d'un utilisateur ne correspond à aucun utilisateur UNIX valide ?|
|`browseable = yes`|Ce partage doit-il être affiché dans la liste des partages disponibles ?|
|`guest ok = yes`|Autoriser la connexion au service sans utiliser de mot de passe ?|
|`read only = yes`|Autoriser les utilisateurs à lire les fichiers uniquement ?|
|`create mask = 0700`|Quelles permissions doivent être définies pour les fichiers nouvellement créés ?|

---

## Paramètres Dangereux

Certains des paramètres ci-dessus apportent déjà des options sensibles. Cependant, si nous remettons en question les paramètres listés ci-dessous et que nous nous demandons ce que les employés pourraient en tirer, ainsi que les attaquants, nous verrons quels avantages et inconvénients ces paramètres apportent. Prenons le paramètre `browseable = yes` comme exemple. Si nous, en tant qu'administrateurs, adoptons ce paramètre, les employés de l'entreprise auront le confort de pouvoir consulter les dossiers individuels avec leur contenu. De nombreux dossiers sont finalement utilisés pour une meilleure organisation et structure. Si l'employé peut naviguer dans les partages, l'attaquant pourra également le faire après un accès réussi.

|**Paramètre**|**Description**|
|---|---|
|`browseable = yes`|Autoriser le listage des partages disponibles dans le partage actuel ?|
|`read only = no`|Interdire la création et la modification de fichiers ?|
|`writable = yes`|Autoriser les utilisateurs à créer et modifier des fichiers ?|
|`guest ok = yes`|Autoriser la connexion au service sans utiliser de mot de passe ?|
|`enable privileges = yes`|Respecter les privilèges attribués à un SID spécifique ?|
|`create mask = 0777`|Quelles permissions doivent être attribuées aux fichiers nouvellement créés ?|
|`directory mask = 0777`|Quelles permissions doivent être attribuées aux répertoires nouvellement créés ?|
|`logon script = script.sh`|Quel script doit être exécuté lors de la connexion de l'utilisateur ?|
|`magic script = script.sh`|Quel script doit être exécuté lorsque le script est fermé ?|
|`magic output = script.out`|Où la sortie du script magique doit-elle être stockée ?|

Créons un partage appelé `[notes]` et quelques autres et voyons comment les paramètres affectent notre processus d'énumération. Nous utiliserons tous les paramètres ci-dessus et les appliquerons à ce partage. Par exemple, ce paramètre est souvent appliqué, ne serait-ce qu'à des fins de test. S'il s'agit ensuite d'un sous-réseau interne d'une petite équipe dans un grand département, ce paramètre est souvent conservé ou on oublie de le réinitialiser. Cela nous permet de parcourir tous les partages et, avec une forte probabilité, même de les télécharger et de les inspecter.

#### Exemple de Partage

        shellsession
`...SNIP...  [notes]     comment = CheckIT     path = /mnt/notes/      browseable = yes     read only = no     writable = yes     guest ok = yes      enable privileges = yes     create mask = 0777     directory mask = 0777`

Il est fortement recommandé de consulter les pages de manuel de Samba, de le configurer nous-mêmes et d'expérimenter avec les paramètres. Nous découvrirons alors des aspects potentiels qui seront intéressants pour nous en tant que testeur d'intrusion. De plus, plus nous nous familiariserons avec le serveur Samba et SMB, plus il sera facile de nous repérer dans l'environnement et de l'utiliser à nos fins. Une fois que nous avons ajusté `/etc/samba/smb.conf` à nos besoins, nous devons redémarrer le service sur le serveur.

#### Redémarrer Samba

        shellsession
`root@samba:~# sudo systemctl restart smbd`

Nous pouvons maintenant afficher une liste (`-L`) des partages du serveur avec la commande `smbclient` depuis notre hôte. Nous utilisons ce qu'on appelle une session nulle (null session) (`-N`), qui est un accès `anonyme` sans la saisie d'utilisateurs existants ou de mots de passe valides.

#### SMBclient - Connexion au Partage

        shellsession
`ppporrkkky@htb[/htb]$ smbclient -N -L //10.129.14.128          Sharename       Type      Comment         ---------       ----      -------         print$          Disk      Printer Drivers         home            Disk      INFREIGHT Samba         dev             Disk      DEVenv         notes           Disk      CheckIT         IPC$            IPC       IPC Service (DEVSM) SMB1 disabled -- no workgroup available`

Nous pouvons voir d'après le résultat que nous avons maintenant cinq partages différents sur le serveur Samba. Ainsi, `print$` et un `IPC$` sont déjà inclus par défaut dans le paramétrage de base, comme nous l'avons déjà vu. Comme nous nous occupons du partage `[notes]`, connectons-nous et inspectons-le en utilisant le même programme client. Si nous ne sommes pas familiers avec le programme client, nous pouvons utiliser la commande `help` après une connexion réussie, qui listera toutes les commandes possibles que nous pouvons exécuter.

        shellsession
`ppporrkkky@htb[/htb]$ smbclient //10.129.14.128/notes  Enter WORKGROUP\<username>'s password:  Anonymous login successful Try "help" to get a list of possible commands.   smb: \> help  ?              allinfo        altname        archive        backup          blocksize      cancel         case_sensitive cd             chmod           chown          close          del            deltree        dir             du             echo           exit           get            getfacl         geteas         hardlink       help           history        iosize          lcd            link           lock           lowercase      ls              l              mask           md             mget           mkdir           more           mput           newer          notify         open            posix          posix_encrypt  posix_open     posix_mkdir    posix_rmdir     posix_unlink   posix_whoami   print          prompt         put             pwd            q              queue          quit           readlink        rd             recurse        reget          rename         reput           rm             rmdir          showacls       setea          setmode         scopy          stat           symlink        tar            tarmode         timeout        translate      unlock         volume         vuid            wdel           logon          listconnect    showconnect    tcon            tdis           tid            utimes         logoff         ..              !               smb: \> ls    .                                   D        0  Wed Sep 22 18:17:51 2021   ..                                  D        0  Wed Sep 22 12:03:59 2021   prep-prod.txt                       N       71  Sun Sep 19 15:45:21 2021                  30313412 blocks of size 1024. 16480084 blocks available`

Une fois que nous avons découvert des fichiers ou des dossiers intéressants, nous pouvons les télécharger en utilisant la commande `get`. Smbclient nous permet également d'exécuter des commandes système locales en utilisant un point d'exclamation au début (`!<cmd>`) sans interrompre la connexion.

#### Télécharger des Fichiers depuis SMB

        shellsession
`smb: \> get prep-prod.txt   getting file \prep-prod.txt of size 71 as prep-prod.txt (8,7 KiloBytes/sec)  (average 8,7 KiloBytes/sec)   smb: \> !ls  prep-prod.txt   smb: \> !cat prep-prod.txt  [] check your code with the templates [] run code-assessment.py [] …`    

Du point de vue de l'administration, nous pouvons vérifier ces connexions en utilisant `smbstatus`. Outre la version de Samba, nous pouvons également voir qui, depuis quel hôte, et à quel partage le client est connecté. C'est particulièrement important une fois que nous sommes entrés dans un sous-réseau (peut-être même isolé) auquel les autres peuvent encore accéder.

Par exemple, avec la sécurité au niveau du domaine, le serveur samba agit en tant que membre d'un domaine Windows. Chaque domaine a au moins un contrôleur de domaine, généralement un serveur Windows NT fournissant l'authentification par mot de passe. Ce contrôleur de domaine fournit au groupe de travail un serveur de mots de passe définitif. Les contrôleurs de domaine gardent une trace des utilisateurs et des mots de passe dans leurs propres `NTDS.dit` et `Security Authentication Module` (`SAM`) et authentifient chaque utilisateur lorsqu'il se connecte pour la première fois et souhaite accéder au partage d'une autre machine.

#### Statut Samba

        shellsession
`root@samba:~# smbstatus  Samba version 4.11.6-Ubuntu PID     Username     Group        Machine                                   Protocol Version  Encryption           Signing               ---------------------------------------------------------------------------------------------------------------------------------------- 75691   sambauser    samba        10.10.14.4 (ipv4:10.10.14.4:45564)      SMB3_11           -                    -                      Service      pid     Machine       Connected at                     Encryption   Signing      --------------------------------------------------------------------------------------------- notes        75691   10.10.14.4   Do Sep 23 00:12:06 2021 CEST     -            -             No locked files`

---

## Prise d'Empreinte du Service

Revenons à l'un de nos outils d'énumération. Nmap dispose également de nombreuses options et de scripts NSE qui peuvent nous aider à examiner plus en détail le service SMB de la cible et à obtenir plus d'informations. L'inconvénient, cependant, est que ces scans peuvent prendre beaucoup de temps. Il est donc également recommandé d'examiner le service manuellement, principalement parce que nous pouvons trouver beaucoup plus de détails que Nmap ne pourrait nous en montrer. D'abord, cependant, voyons ce que Nmap peut trouver sur notre serveur Samba cible, où nous avons créé le partage `[notes]` à des fins de test.

#### Nmap

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap 10.129.14.128 -sV -sC -p139,445  Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-19 15:15 CEST Nmap scan report for sharing.inlanefreight.htb (10.129.14.128) Host is up (0.00024s latency).  PORT    STATE SERVICE     VERSION 139/tcp open  netbios-ssn Samba smbd 4.6.2 445/tcp open  netbios-ssn Samba smbd 4.6.2 MAC Address: 00:00:00:00:00:00 (VMware)  Host script results: |_nbstat: NetBIOS name: HTB, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown) | smb2-security-mode:  |   2.02:  |_    Message signing enabled but not required | smb2-time:  |   date: 2021-09-19T13:16:04 |_  start_date: N/A  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 11.35 seconds`

Nous pouvons voir d'après les résultats que Nmap ne nous a pas fourni grand-chose ici. Par conséquent, nous devrions recourir à d'autres outils qui nous permettent d'interagir manuellement avec le SMB et d'envoyer des requêtes spécifiques pour obtenir des informations. L'un des outils pratiques pour cela est `rpcclient`. C'est un outil pour effectuer des fonctions MS-RPC.

L'Appel de Procédure à Distance ([Remote Procedure Call](https://www.geeksforgeeks.org/remote-procedure-call-rpc-in-operating-system/), `RPC`) est un concept et, par conséquent, un outil central pour réaliser des structures opérationnelles et de partage de travail dans les réseaux et les architectures client-serveur. Le processus de communication via RPC comprend le passage de paramètres et le retour d'une valeur de fonction.

#### RPCclient

        shellsession
`ppporrkkky@htb[/htb]$ rpcclient -U "" 10.129.14.128  Enter WORKGROUP\'s password: rpcclient $>` 

Le `rpcclient` nous offre de nombreuses requêtes différentes avec lesquelles nous pouvons exécuter des fonctions spécifiques sur le serveur SMB pour obtenir des informations. Une liste complète de toutes ces fonctions peut être trouvée sur la [page de manuel](https://www.samba.org/samba/docs/current/man-html/rpcclient.1.html) du rpcclient.

|**Requête**|**Description**|
|---|---|
|`srvinfo`|Informations sur le serveur.|
|`enumdomains`|Énumère tous les domaines qui sont déployés sur le réseau.|
|`querydominfo`|Fournit des informations sur le domaine, le serveur et les utilisateurs des domaines déployés.|
|`netshareenumall`|Énumère tous les partages disponibles.|
|`netsharegetinfo <share>`|Fournit des informations sur un partage spécifique.|
|`enumdomusers`|Énumère tous les utilisateurs du domaine.|
|`queryuser <RID>`|Fournit des informations sur un utilisateur spécifique.|

#### RPCclient - Énumération

        shellsession
`rpcclient $> srvinfo          DEVSMB         Wk Sv PrQ Unx NT SNT DEVSM         platform_id     :       500         os version      :       6.1         server type     :       0x809a03                   rpcclient $> enumdomains  name:[DEVSMB] idx:[0x0] name:[Builtin] idx:[0x1]   rpcclient $> querydominfo  Domain:         DEVOPS Server:         DEVSMB Comment:        DEVSM Total Users:    2 Total Groups:   0 Total Aliases:  0 Sequence No:    1632361158 Force Logoff:   -1 Domain Server State:    0x1 Server Role:    ROLE_DOMAIN_PDC Unknown 3:      0x1   rpcclient $> netshareenumall  netname: print$         remark: Printer Drivers         path:   C:\var\lib\samba\printers         password: netname: home         remark: INFREIGHT Samba         path:   C:\home\         password: netname: dev         remark: DEVenv         path:   C:\home\sambauser\dev\         password: netname: notes         remark: CheckIT         path:   C:\mnt\notes\         password: netname: IPC$         remark: IPC Service (DEVSM)         path:   C:\tmp         password:                   rpcclient $> netsharegetinfo notes  netname: notes         remark: CheckIT         path:   C:\mnt\notes\         password:         type:   0x0         perms:  0         max_uses:       -1         num_uses:       1 revision: 1 type: 0x8004: SEC_DESC_DACL_PRESENT SEC_DESC_SELF_RELATIVE  DACL         ACL     Num ACEs:       1       revision:       2         ---         ACE                 type: ACCESS ALLOWED (0) flags: 0x00                  Specific bits: 0x1ff                 Permissions: 0x101f01ff: Generic all access SYNCHRONIZE_ACCESS WRITE_OWNER_ACCESS WRITE_DAC_ACCESS READ_CONTROL_ACCESS DELETE_ACCESS                  SID: S-1-1-0`

Ces exemples nous montrent quelles informations peuvent être divulguées à des utilisateurs anonymes. Une fois qu'un utilisateur `anonyme` a accès à un service réseau, il suffit d'une seule erreur pour lui donner trop de permissions ou trop de visibilité pour mettre l'ensemble du réseau en grand danger.

Plus important encore, l'accès anonyme à de tels services peut également conduire à la découverte d'autres utilisateurs, qui peuvent être attaqués par force brute dans le cas le plus agressif. Les humains sont plus sujets aux erreurs que les processus informatiques correctement configurés, et le manque de sensibilisation à la sécurité et la paresse conduisent souvent à des mots de passe faibles qui peuvent être facilement cassés. Voyons comment nous pouvons énumérer les utilisateurs en utilisant le `rpcclient`.

#### Rpcclient - Énumération d'Utilisateurs

        shellsession
`rpcclient $> enumdomusers  user:[mrb3n] rid:[0x3e8] user:[cry0l1t3] rid:[0x3e9]   rpcclient $> queryuser 0x3e9          User Name   :   cry0l1t3         Full Name   :   cry0l1t3         Home Drive  :   \\devsmb\cry0l1t3         Dir Drive   :         Profile Path:   \\devsmb\cry0l1t3\profile         Logon Script:         Description :         Workstations:         Comment     :         Remote Dial :         Logon Time               :      Do, 01 Jan 1970 01:00:00 CET         Logoff Time              :      Mi, 06 Feb 2036 16:06:39 CET         Kickoff Time             :      Mi, 06 Feb 2036 16:06:39 CET         Password last set Time   :      Mi, 22 Sep 2021 17:50:56 CEST         Password can change Time :      Mi, 22 Sep 2021 17:50:56 CEST         Password must change Time:      Do, 14 Sep 30828 04:48:05 CEST         unknown_2[0..31]...         user_rid :      0x3e9         group_rid:      0x201         acb_info :      0x00000014         fields_present: 0x00ffffff         logon_divs:     168         bad_password_count:     0x00000000         logon_count:    0x00000000         padding1[0..7]...         logon_hrs[0..21]...   rpcclient $> queryuser 0x3e8          User Name   :   mrb3n         Full Name   :         Home Drive  :   \\devsmb\mrb3n         Dir Drive   :         Profile Path:   \\devsmb\mrb3n\profile         Logon Script:         Description :         Workstations:         Comment     :         Remote Dial :         Logon Time               :      Do, 01 Jan 1970 01:00:00 CET         Logoff Time              :      Mi, 06 Feb 2036 16:06:39 CET         Kickoff Time             :      Mi, 06 Feb 2036 16:06:39 CET         Password last set Time   :      Mi, 22 Sep 2021 17:47:59 CEST         Password can change Time :      Mi, 22 Sep 2021 17:47:59 CEST         Password must change Time:      Do, 14 Sep 30828 04:48:05 CEST         unknown_2[0..31]...         user_rid :      0x3e8         group_rid:      0x201         acb_info :      0x00000010         fields_present: 0x00ffffff         logon_divs:     168         bad_password_count:     0x00000000         logon_count:    0x00000000         padding1[0..7]...         logon_hrs[0..21]...`

Nous pouvons ensuite utiliser les résultats pour identifier le RID du groupe, que nous pouvons ensuite utiliser pour récupérer des informations sur l'ensemble du groupe.

#### Rpcclient - Informations sur le Groupe

        shellsession
`rpcclient $> querygroup 0x201          Group Name:     None         Description:    Ordinary Users         Group Attribute:7         Num Members:2`

Cependant, il peut aussi arriver que toutes les commandes ne nous soient pas disponibles et que nous ayons certaines restrictions basées sur l'utilisateur. Cependant, la requête `queryuser <RID>` est principalement autorisée en fonction du RID. Nous pouvons donc utiliser le rpcclient pour forcer les RID par force brute afin d'obtenir des informations. Parce que nous ne savons peut-être pas à qui a été attribué quel RID, nous savons que nous obtiendrons des informations à ce sujet dès que nous interrogerons un RID attribué. Il existe plusieurs façons et outils que nous pouvons utiliser pour cela. Pour rester avec l'outil, nous pouvons créer une `boucle For` en utilisant `Bash` où nous envoyons une commande au service en utilisant rpcclient et filtrons les résultats.

#### Forcer les RID Utilisateurs par Force Brute

        shellsession
`ppporrkkky@htb[/htb]$ for i in $(seq 500 1100);do rpcclient -N -U "" 10.129.14.128 -c "queryuser 0x$(printf '%x\n' $i)" | grep "User Name\|user_rid\|group_rid" && echo "";done          User Name   :   sambauser         user_rid :      0x1f5         group_rid:      0x201                  User Name   :   mrb3n         user_rid :      0x3e8         group_rid:      0x201                  User Name   :   cry0l1t3         user_rid :      0x3e9         group_rid:      0x201`

Une alternative à cela serait un script Python de [Impacket](https://github.com/SecureAuthCorp/impacket) appelé [samrdump.py](https://github.com/SecureAuthCorp/impacket/blob/master/examples/samrdump.py).

#### Impacket - Samrdump.py

        shellsession
`ppporrkkky@htb[/htb]$ samrdump.py 10.129.14.128  Impacket v0.9.22 - Copyright 2020 SecureAuth Corporation  [*] Retrieving endpoint list from 10.129.14.128 Found domain(s):  . DEVSMB  . Builtin [*] Looking up users in domain DEVSMB Found user: mrb3n, uid = 1000 Found user: cry0l1t3, uid = 1001 mrb3n (1000)/FullName:  mrb3n (1000)/UserComment:  mrb3n (1000)/PrimaryGroupId: 513 mrb3n (1000)/BadPasswordCount: 0 mrb3n (1000)/LogonCount: 0 mrb3n (1000)/PasswordLastSet: 2021-09-22 17:47:59 mrb3n (1000)/PasswordDoesNotExpire: False mrb3n (1000)/AccountIsDisabled: False mrb3n (1000)/ScriptPath:  cry0l1t3 (1001)/FullName: cry0l1t3 cry0l1t3 (1001)/UserComment:  cry0l1t3 (1001)/PrimaryGroupId: 513 cry0l1t3 (1001)/BadPasswordCount: 0 cry0l1t3 (1001)/LogonCount: 0 cry0l1t3 (1001)/PasswordLastSet: 2021-09-22 17:50:56 cry0l1t3 (1001)/PasswordDoesNotExpire: False cry0l1t3 (1001)/AccountIsDisabled: False cry0l1t3 (1001)/ScriptPath:  [*] Received 2 entries.`

Les informations que nous avons déjà obtenues avec `rpcclient` peuvent également être obtenues à l'aide d'autres outils. Par exemple, les outils [SMBMap](https://github.com/ShawnDEvans/smbmap) et [CrackMapExec](https://github.com/byt3bl33d3r/CrackMapExec) sont également largement utilisés et utiles pour l'énumération des services SMB.

#### SMBmap

        shellsession
`ppporrkkky@htb[/htb]$ smbmap -H 10.129.14.128  [+] Finding open SMB ports.... [+] User SMB session established on 10.129.14.128... [+] IP: 10.129.14.128:445       Name: 10.129.14.128                                              Disk                                                    Permissions     Comment         ----                                                    -----------     -------         print$                                                  NO ACCESS       Printer Drivers         home                                                    NO ACCESS       INFREIGHT Samba         dev                                                     NO ACCESS       DEVenv         notes                                                   NO ACCESS       CheckIT         IPC$                                                    NO ACCESS       IPC Service (DEVSM)`

#### CrackMapExec

        shellsession
`ppporrkkky@htb[/htb]$ crackmapexec smb 10.129.14.128 --shares -u '' -p ''  SMB         10.129.14.128   445    DEVSMB           [*] Windows 6.1 Build 0 (name:DEVSMB) (domain:) (signing:False) (SMBv1:False) SMB         10.129.14.128   445    DEVSMB           [+] \:  SMB         10.129.14.128   445    DEVSMB           [+] Enumerated shares SMB         10.129.14.128   445    DEVSMB           Share           Permissions     Remark SMB         10.129.14.128   445    DEVSMB           -----           -----------     ------ SMB         10.129.14.128   445    DEVSMB           print$                          Printer Drivers SMB         10.129.14.128   445    DEVSMB           home                            INFREIGHT Samba SMB         10.129.14.128   445    DEVSMB           dev                             DEVenv SMB         10.129.14.128   445    DEVSMB           notes           READ,WRITE      CheckIT SMB         10.129.14.128   445    DEVSMB           IPC$                            IPC Service (DEVSM)`

Un autre outil qui mérite d'être mentionné est le soi-disant [enum4linux-ng](https://github.com/cddmp/enum4linux-ng), qui est basé sur un outil plus ancien, enum4linux. Cet outil automatise de nombreuses requêtes, mais pas toutes, et peut renvoyer une grande quantité d'informations.

#### Enum4Linux-ng - Installation

        shellsession
`ppporrkkky@htb[/htb]$ git clone https://github.com/cddmp/enum4linux-ng.git ppporrkkky@htb[/htb]$ cd enum4linux-ng ppporrkkky@htb[/htb]$ pip3 install -r requirements.txt`

#### Enum4Linux-ng - Énumération

        shellsession
`ppporrkkky@htb[/htb]$ ./enum4linux-ng.py 10.129.14.128 -A  ENUM4LINUX - next generation   ========================== |    Target Information    |  ========================== [*] Target ........... 10.129.14.128 [*] Username ......... '' [*] Random Username .. 'juzgtcsu' [*] Password ......... '' [*] Timeout .......... 5 second(s)   ===================================== |    Service Scan on 10.129.14.128    |  ===================================== [*] Checking LDAP [-] Could not connect to LDAP on 389/tcp: connection refused [*] Checking LDAPS [-] Could not connect to LDAPS on 636/tcp: connection refused [*] Checking SMB [+] SMB is accessible on 445/tcp [*] Checking SMB over NetBIOS [+] SMB over NetBIOS is accessible on 139/tcp   ===================================================== |    NetBIOS Names and Workgroup for 10.129.14.128    |  ===================================================== [+] Got domain/workgroup name: DEVOPS [+] Full NetBIOS names information: - DEVSMB          <00> -         H <ACTIVE>  Workstation Service - DEVSMB          <03> -         H <ACTIVE>  Messenger Service - DEVSMB          <20> -         H <ACTIVE>  File Server Service - ..__MSBROWSE__. <01> - <GROUP> H <ACTIVE>  Master Browser - DEVOPS          <00> - <GROUP> H <ACTIVE>  Domain/Workgroup Name - DEVOPS          <1d> -         H <ACTIVE>  Master Browser - DEVOPS          <1e> - <GROUP> H <ACTIVE>  Browser Service Elections - MAC Address = 00-00-00-00-00-00   ========================================== |    SMB Dialect Check on 10.129.14.128    |  ========================================== [*] Trying on 445/tcp [+] Supported dialects and settings: SMB 1.0: false SMB 2.02: true SMB 2.1: true SMB 3.0: true SMB1 only: false Preferred dialect: SMB 3.0 SMB signing required: false   ========================================== |    RPC Session Check on 10.129.14.128    |  ========================================== [*] Check for null session [+] Server allows session using username '', password '' [*] Check for random user session [+] Server allows session using username 'juzgtcsu', password '' [H] Rerunning enumeration with user 'juzgtcsu' might give more results   ==================================================== |    Domain Information via RPC for 10.129.14.128    |  ==================================================== [+] Domain: DEVOPS [+] SID: NULL SID [+] Host is part of a workgroup (not a domain)   ============================================================ |    Domain Information via SMB session for 10.129.14.128    |  ============================================================ [*] Enumerating via unauthenticated SMB session on 445/tcp [+] Found domain information via SMB NetBIOS computer name: DEVSMB NetBIOS domain name: '' DNS domain: '' FQDN: htb   ================================================ |    OS Information via RPC for 10.129.14.128    |  ================================================ [*] Enumerating via unauthenticated SMB session on 445/tcp [+] Found OS information via SMB [*] Enumerating via 'srvinfo' [+] Found OS information via 'srvinfo' [+] After merging OS information we have the following result: OS: Windows 7, Windows Server 2008 R2 OS version: '6.1' OS release: '' OS build: '0' Native OS: not supported Native LAN manager: not supported Platform id: '500' Server type: '0x809a03' Server type string: Wk Sv PrQ Unx NT SNT DEVSM   ====================================== |    Users via RPC on 10.129.14.128    |  ====================================== [*] Enumerating users via 'querydispinfo' [+] Found 2 users via 'querydispinfo' [*] Enumerating users via 'enumdomusers' [+] Found 2 users via 'enumdomusers' [+] After merging user results we have 2 users total: '1000':   username: mrb3n   name: ''   acb: '0x00000010'   description: '' '1001':   username: cry0l1t3   name: cry0l1t3   acb: '0x00000014'   description: ''   ======================================= |    Groups via RPC on 10.129.14.128    |  ======================================= [*] Enumerating local groups [+] Found 0 group(s) via 'enumalsgroups domain' [*] Enumerating builtin groups [+] Found 0 group(s) via 'enumalsgroups builtin' [*] Enumerating domain groups [+] Found 0 group(s) via 'enumdomgroups'   ======================================= |    Shares via RPC on 10.129.14.128    |  ======================================= [*] Enumerating shares [+] Found 5 share(s): IPC$:   comment: IPC Service (DEVSM)   type: IPC dev:   comment: DEVenv   type: Disk home:   comment: INFREIGHT Samba   type: Disk notes:   comment: CheckIT   type: Disk print$:   comment: Printer Drivers   type: Disk [*] Testing share IPC$ [-] Could not check share: STATUS_OBJECT_NAME_NOT_FOUND [*] Testing share dev [-] Share doesn't exist [*] Testing share home [+] Mapping: OK, Listing: OK [*] Testing share notes [+] Mapping: OK, Listing: OK [*] Testing share print$ [+] Mapping: DENIED, Listing: N/A   ========================================== |    Policies via RPC for 10.129.14.128    |  ========================================== [*] Trying port 445/tcp [+] Found policy: domain_password_information:   pw_history_length: None   min_pw_length: 5   min_pw_age: none   max_pw_age: 49710 days 6 hours 21 minutes   pw_properties:   - DOMAIN_PASSWORD_COMPLEX: false   - DOMAIN_PASSWORD_NO_ANON_CHANGE: false   - DOMAIN_PASSWORD_NO_CLEAR_CHANGE: false   - DOMAIN_PASSWORD_LOCKOUT_ADMINS: false   - DOMAIN_PASSWORD_PASSWORD_STORE_CLEARTEXT: false   - DOMAIN_PASSWORD_REFUSE_PASSWORD_CHANGE: false domain_lockout_information:   lockout_observation_window: 30 minutes   lockout_duration: 30 minutes   lockout_threshold: None domain_logoff_information:   force_logoff_time: 49710 days 6 hours 21 minutes   ========================================== |    Printers via RPC for 10.129.14.128    |  ========================================== [+] No printers returned (this is not an error)  Completed after 0.61 seconds`

Nous devons utiliser plus de deux outils pour l'énumération. Car il peut arriver qu'en raison de la programmation des outils, nous obtenions des informations différentes que nous devons vérifier manuellement. Par conséquent, nous ne devrions jamais nous fier uniquement à des outils automatisés dont nous ne savons pas précisément comment ils ont été écrits.