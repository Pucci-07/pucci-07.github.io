[[Command Prompt Basics]]
PowerShell a étendu nos capacités au sein du `Windows OS` en ce qui concerne les paramètres réseau, les applications, et plus encore. Cette section expliquera comment vérifier vos paramètres réseau, tels que les adresses IP, les paramètres de la carte réseau et les paramètres DNS. Nous aborderons également la manière d'activer et de gérer l'accès à un hôte distant en utilisant `WinRM` et `SSH`.

**Scénario : Pour s'assurer que l'hôte de M. Tanaka fonctionne correctement et que nous pouvons le gérer à distance depuis le bureau informatique, nous allons effectuer une vérification rapide, valider les paramètres de son hôte et activer la gestion à distance de l'hôte.**

---

## Qu'est-ce que la mise en réseau au sein d'un réseau Windows ?

La mise en réseau avec des hôtes Windows fonctionne de la même manière que pour tout autre hôte basé sur Linux ou Unix. La pile TCP/IP, les protocoles sans fil et d'autres applications traitent la plupart des appareils de la même manière, il n'y a donc pas grand-chose de nouveau à apprendre à ce sujet. Ce module suppose que vous connaissez les protocoles réseau de base et la manière dont le trafic réseau typique traverse Internet. Si vous souhaitez une introduction à la mise en réseau, consultez le module [Introduction to Networking](https://academy.hackthebox.com/course/preview/introduction-to-networking), ou pour une analyse plus approfondie du trafic réseau, vous pouvez suivre le module [Introduction to Network Traffic Analysis](https://academy.hackthebox.com/course/preview/intro-to-network-traffic-analysis). Là où les choses diffèrent un peu, c'est dans la manière dont les hôtes Windows communiquent entre eux, avec les domaines et avec d'autres hôtes Linux. Ci-dessous, nous aborderons rapidement certains protocoles standard que vous pourriez rencontrer lors de l'administration ou du pentesting d'hôtes Windows.

|**Protocole**|**Description**|
|---|---|
|`SMB`|[SMB](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/4287490c-602c-41c0-a23e-140a1f137832) offre aux hôtes Windows la capacité de partager des ressources, des fichiers et une méthode standard d'authentification entre les hôtes pour déterminer si l'accès aux ressources est autorisé. Pour les autres distributions, SAMBA est l'option open-source.|
|`Netbios`|[NetBios](https://www.ietf.org/rfc/rfc1001.txt) n'est pas directement un service ou un protocole en soi, mais un mécanisme de connexion et de conversation largement utilisé dans les réseaux. C'était le mécanisme de transport original pour SMB, mais cela a changé depuis. Il sert maintenant de mécanisme d'identification alternatif lorsque le DNS échoue. Peut aussi être connu sous le nom de NBT-NS (service de noms NetBIOS).|
|`LDAP`|[LDAP](https://www.rfc-editor.org/rfc/rfc4511) est un protocole `open-source` multiplateforme utilisé pour l'`authentification` et l'`autorisation` avec divers services d'annuaire. C'est ainsi que de nombreux appareils différents dans les réseaux modernes peuvent communiquer avec de grands services de structure d'annuaire tels qu'`Active Directory`.|
|`LLMNR`|[LLMNR](https://www.rfc-editor.org/rfc/rfc4795) fournit un service de résolution de noms basé sur le DNS et fonctionne si le DNS n'est pas disponible ou ne fonctionne pas. Ce protocole est un protocole de multidiffusion (multicast) et, en tant que tel, ne fonctionne que sur des liens locaux (au sein d'un domaine de diffusion normal, pas à travers des liens de couche 3).|
|`DNS`|[DNS](https://datatracker.ietf.org/doc/html/rfc1034) est un standard de nommage commun utilisé sur Internet et dans la plupart des types de réseaux modernes. Le DNS nous permet de référencer les hôtes par un nom unique au lieu de leur adresse IP. C'est ainsi que nous pouvons référencer un site web par "[WWW.google.com](http://WWW.google.com)" au lieu de "8.8.8.8". En interne, c'est ainsi que nous demandons des ressources et un accès à partir d'un réseau.|
|`HTTP/HTTPS`|[HTTP/S](https://www.rfc-editor.org/rfc/rfc2818) HTTP et HTTPS sont la manière non sécurisée et sécurisée dont nous demandons et utilisons des ressources sur Internet. Ces protocoles sont utilisés pour accéder et utiliser des ressources telles que des serveurs web, envoyer et recevoir des données de sources distantes, et bien plus encore.|
|`Kerberos`|[Kerberos](https://web.mit.edu/kerberos/) est un protocole d'authentification au niveau du réseau. De nos jours, nous sommes plus susceptibles de le voir lors de l'authentification Active Directory lorsque les clients demandent des tickets d'autorisation pour utiliser les ressources du domaine.|
|`WinRM`|[WinRM](https://learn.microsoft.com/en-us/windows/win32/winrm/portal) est une implémentation du protocole WS-Management. Il peut être utilisé pour gérer les fonctionnalités matérielles et logicielles des hôtes. Il est principalement utilisé dans l'administration informatique mais peut également être utilisé pour l'énumération d'hôtes et comme moteur de script.|
|`RDP`|[RDP](https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds-plan-access-from-anywhere) est une implémentation Windows d'un protocole de services d'interface utilisateur réseau qui fournit aux utilisateurs une interface graphique pour accéder aux hôtes via une connexion réseau. Cela permet une utilisation complète de l'interface utilisateur, y compris la transmission des entrées clavier et souris à l'hôte distant.|
|`SSH`|[SSH](https://datatracker.ietf.org/doc/html/rfc4251) est un protocole sécurisé qui peut être utilisé pour un accès sécurisé à l'hôte, le transfert de fichiers et la communication générale entre les hôtes du réseau. Il fournit un moyen d'accéder en toute sécurité aux hôtes et aux services sur des réseaux non sécurisés.|

Bien sûr, cette liste n'est pas exhaustive, mais c'est un excellent point de départ général sur ce que nous verrions généralement en communiquant avec des hôtes Windows. Parlons maintenant de l'accès local par rapport à l'accès à distance.

---

## Accès Local ou Accès à Distance ?

### Accès Local

L'accès à l'hôte local se produit lorsque nous sommes directement au terminal en utilisant ses ressources, comme vous le faites en ce moment depuis votre PC. Habituellement, cela ne nous obligera pas à utiliser de protocoles d'accès spécifiques, sauf lorsque nous demandons des ressources à des hôtes en réseau ou tentons d'accéder à Internet. Ci-dessous, nous présenterons quelques cmdlets et d'autres moyens de vérifier et de valider les paramètres réseau sur nos hôtes.

### Interrogation des Paramètres Réseau

Avant toute autre chose, validons les paramètres réseau sur l'hôte de M. Tanaka. Nous commencerons par exécuter la commande `IPConfig`. Ce n'est pas une commande native de PowerShell, mais elle est compatible.

#### IPConfig

        powershell
`PS C:\htb> ipconfig   Windows IP Configuration  Ethernet adapter Ethernet0:     Connection-specific DNS Suffix  . : .htb    Link-local IPv6 Address . . . . . : fe80::c5ca:594d:759d:e0c1%11    IPv4 Address. . . . . . . . . . . : 10.129.203.105    Subnet Mask . . . . . . . . . . . : 255.255.0.0    Default Gateway . . . . . . . . . : fe80::250:56ff:feb9:b9fc%11                                        10.129.0.1`

Comme nous pouvons le voir, `ipconfig` nous montrera les paramètres de base de votre interface réseau. Nous avons en sortie les adresses IPv4/6, notre passerelle, les masques de sous-réseau et le suffixe DNS si un est défini. Nous pouvons afficher tous les paramètres réseau en ajoutant le modificateur `/all` à la commande ipconfig comme suit :

        powershell
`PS C:\htb> ipconfig /all   Windows IP Configuration     Host Name . . . . . . . . . . . . : ICL-WIN11    Primary Dns Suffix  . . . . . . . : greenhorn.corp    Node Type . . . . . . . . . . . . : Hybrid    IP Routing Enabled. . . . . . . . : No    WINS Proxy Enabled. . . . . . . . : No    DNS Suffix Search List. . . . . . : greenhorn.corp                                        htb  Ethernet adapter Ethernet0:     Connection-specific DNS Suffix  . : .htb    Description . . . . . . . . . . . : vmxnet3 Ethernet Adapter    Physical Address. . . . . . . . . : 00-50-56-B9-4F-CB    DHCP Enabled. . . . . . . . . . . : Yes    Autoconfiguration Enabled . . . . : Yes    IPv6 Address. . . . . . . . . . . : dead:beef::222(Preferred)    Lease Obtained. . . . . . . . . . : Monday, October 17, 2022 9:40:14 AM    Lease Expires . . . . . . . . . . : Tuesday, October 25, 2022 9:59:17 AM    <SNIP>    IPv4 Address. . . . . . . . . . . : 10.129.203.105(Preferred)    Subnet Mask . . . . . . . . . . . : 255.255.0.0    Lease Obtained. . . . . . . . . . : Monday, October 17, 2022 9:40:13 AM    Lease Expires . . . . . . . . . . : Tuesday, October 25, 2022 10:10:16 AM    Default Gateway . . . . . . . . . : fe80::250:56ff:feb9:b9fc%11                                        10.129.0.1    DHCP Server . . . . . . . . . . . : 10.129.0.1    DHCPv6 IAID . . . . . . . . . . . : 335564886    DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-2A-3D-00-D6-00-50-56-B9-4F-CB    DNS Servers . . . . . . . . . . . : 1.1.1.1                                        8.8.8.8    NetBIOS over Tcpip. . . . . . . . : Enabled    Connection-specific DNS Suffix Search List :                                        htb  Ethernet adapter Ethernet2:     Connection-specific DNS Suffix  . :    Description . . . . . . . . . . . : vmxnet3 Ethernet Adapter #2    Physical Address. . . . . . . . . : 00-50-56-B9-F5-7E    DHCP Enabled. . . . . . . . . . . : No    Autoconfiguration Enabled . . . . : Yes    Link-local IPv6 Address . . . . . : fe80::d1fb:79d5:6d0b:41de%14(Preferred)    IPv4 Address. . . . . . . . . . . : 172.16.5.100(Preferred)    Subnet Mask . . . . . . . . . . . : 255.255.255.0    Default Gateway . . . . . . . . . : 172.16.5.1    DHCPv6 IAID . . . . . . . . . . . : 318787670    DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-2A-3D-00-D6-00-50-56-B9-4F-CB    DNS Servers . . . . . . . . . . . : 172.16.5.155    NetBIOS over Tcpip. . . . . . . . : Enabled`

Maintenant, nous pouvons voir beaucoup plus d'informations qu'auparavant. On nous présente une sortie contenant plusieurs cartes, les `paramètres de l'hôte`, plus de détails sur si nos adresses IP ont été définies `manuellement` ou sont des `baux DHCP`, la durée de ces baux, et plus encore. Il semble donc que l'hôte de M. Tanaka ait une configuration d'adresse IP correcte. Fait à noter, et particulièrement intéressant pour nous en tant que pentesters, est que cet hôte est à double interface réseau (dual-homed). Nous voulons dire qu'il a plusieurs interfaces réseau connectées à des réseaux distincts. Cela fait de l'hôte de M. Tanaka une excellente cible si nous cherchons un point d'appui dans le réseau et souhaitons avoir un moyen de migrer entre les réseaux.

Jetons un œil aux paramètres `Arp` et voyons si son hôte a communiqué avec d'autres sur le réseau. Pour rappel, ARP est un protocole utilisé pour `traduire les adresses IP en adresses physiques`. L'adresse physique est utilisée aux niveaux inférieurs des modèles `OSI/TCP-IP` pour la communication. Pour afficher les entrées ARP actuelles de l'hôte, nous utiliserons le commutateur `-a`.

#### ARP

        powershell
`PS C:\htb> arp -a  Interface: 10.129.203.105 --- 0xb   Internet Address      Physical Address      Type   10.129.0.1            00-50-56-b9-b9-fc     dynamic   10.129.204.58         00-50-56-b9-5f-41     dynamic   10.129.255.255        ff-ff-ff-ff-ff-ff     static   224.0.0.22            01-00-5e-00-00-16     static   224.0.0.251           01-00-5e-00-00-fb     static   224.0.0.252           01-00-5e-00-00-fc     static   239.255.255.250       01-00-5e-7f-ff-fa     static   255.255.255.255       ff-ff-ff-ff-ff-ff     static  Interface: 172.16.5.100 --- 0xe   Internet Address      Physical Address      Type   172.16.5.155          00-50-56-b9-e2-30     dynamic   172.16.5.255          ff-ff-ff-ff-ff-ff     static   224.0.0.22            01-00-5e-00-00-16     static   224.0.0.251           01-00-5e-00-00-fb     static   224.0.0.252           01-00-5e-00-00-fc     static   239.255.255.250       01-00-5e-7f-ff-fa     static`

La sortie de `Arp -a` est assez simple. On nous fournit des entrées de nos cartes réseau concernant les hôtes qu'il connaît ou avec lesquels il a communiqué récemment. Sans surprise, comme cet hôte est assez récent, il n'a pas encore communiqué avec beaucoup d'hôtes. Juste les passerelles, notre hôte distant, et l'hôte 172.16.5.155, le `Contrôleur de Domaine` (Domain Controller) pour `Greenhorn.corp`. Rien de fou à voir ici. Maintenant, validons que notre configuration DNS fonctionne correctement. Nous utiliserons `nslookup`, un outil de requête DNS intégré, pour tenter de résoudre l'adresse IP / le nom DNS du contrôleur de domaine Greenhorn.

#### Nslookup

        powershell
`PS C:\htb> nslookup ACADEMY-ICL-DC  DNS request timed out.     timeout was 2 seconds. Server:  UnKnown Address:  172.16.5.155  Name:    ACADEMY-ICL-DC.greenhorn.corp Address:  172.16.5.155`

Maintenant que nous avons validé les paramètres DNS de M. Tanaka, vérifions les ports ouverts sur l'hôte. Nous pouvons le faire en utilisant `netstat -an`. Netstat affichera les connexions réseau actuelles vers notre hôte. Le commutateur `-an` affichera toutes les connexions et les ports d'écoute et les mettra sous forme numérique.

#### Netstat

        powershell
`PS C:\htb> netstat -an   netstat -an  Active Connections    Proto  Local Address          Foreign Address        State   TCP    0.0.0.0:22             0.0.0.0:0              LISTENING   TCP    0.0.0.0:135            0.0.0.0:0              LISTENING   TCP    0.0.0.0:445            0.0.0.0:0              LISTENING   TCP    0.0.0.0:3389           0.0.0.0:0              LISTENING   TCP    0.0.0.0:5040           0.0.0.0:0              LISTENING   TCP    0.0.0.0:5985           0.0.0.0:0              LISTENING   TCP    0.0.0.0:47001          0.0.0.0:0              LISTENING   TCP    0.0.0.0:49664          0.0.0.0:0              LISTENING   TCP    0.0.0.0:49665          0.0.0.0:0              LISTENING   TCP    0.0.0.0:49666          0.0.0.0:0              LISTENING   TCP    0.0.0.0:49667          0.0.0.0:0              LISTENING   TCP    0.0.0.0:49668          0.0.0.0:0              LISTENING   TCP    0.0.0.0:49671          0.0.0.0:0              LISTENING   TCP    0.0.0.0:49673          0.0.0.0:0              LISTENING   TCP    0.0.0.0:49674          0.0.0.0:0              LISTENING   TCP    10.129.203.105:22      10.10.14.19:32557      ESTABLISHED   TCP    172.16.5.100:139       0.0.0.0:0              LISTENING   TCP    [::]:22                [::]:0                 LISTENING   TCP    [::]:135               [::]:0                 LISTENING   TCP    [::]:445               [::]:0                 LISTENING   TCP    [::]:3389              [::]:0                 LISTENING   TCP    [::]:5985              [::]:0                 LISTENING   TCP    [::]:47001             [::]:0                 LISTENING   TCP    [::]:49664             [::]:0                 LISTENING   TCP    [::]:49665             [::]:0                 LISTENING   TCP    [::]:49666             [::]:0                 LISTENING   TCP    [::]:49667             [::]:0                 LISTENING   TCP    [::]:49668             [::]:0                 LISTENING   TCP    [::]:49671             [::]:0                 LISTENING   TCP    [::]:49673             [::]:0                 LISTENING   TCP    [::]:49674             [::]:0                 LISTENING   UDP    0.0.0.0:123            *:* <SNIP>   UDP    172.16.5.100:137       *:*   UDP    172.16.5.100:138       *:*   UDP    172.16.5.100:1900      *:*   UDP    172.16.5.100:54453     *:*`

Maintenant, vous pourriez avoir besoin d'acquérir une expérience dans l'analyse du trafic réseau ou une compréhension des ports et protocoles standard, sinon ce qui précède pourrait ressembler à du charabia. Mais ce n'est pas grave. En regardant ci-dessus, nous pouvons voir quels ports sont ouverts et si nous avons des connexions actives. D'après la sortie ci-dessus, les ports ouverts sont tous couramment utilisés dans les environnements Windows et sont attendus. La plupart concernent les services Active Directory et SSH. En regardant les connexions, nous ne voyons qu'une seule session actuellement active : notre propre connexion `SSH` sur le port TCP 22.

La plupart des commandes avec lesquelles nous nous sommes entraînés jusqu'à présent sont des exécutables intégrés à Windows et sont utiles pour un aperçu rapide d'un hôte, mais pas pour beaucoup plus. Ci-dessous, nous aborderons plusieurs cmdlets qui sont des ajouts de PowerShell et qui nous permettent de gérer nos connexions réseau de manière granulaire.

### Cmdlets Réseau PowerShell

PowerShell dispose de plusieurs cmdlets intégrées puissantes conçues pour gérer les services et l'administration réseau. Les modules NetAdapter, NetConnection et NetTCPIP ne sont que quelques-uns avec lesquels nous nous exercerons aujourd'hui.

#### Cmdlets Réseau

|**Cmdlet**|**Description**|
|---|---|
|`Get-NetIPInterface`|Récupère toutes les `propriétés` `visibles` des cartes réseau.|
|`Get-NetIPAddress`|Récupère les `configurations IP` de chaque carte. Similaire à `IPConfig`.|
|`Get-NetNeighbor`|Récupère les `entrées de voisins` du cache. Similaire à `arp -a`.|
|`Get-Netroute`|Affiche la `table de routage` actuelle. Similaire à `IPRoute`.|
|`Set-NetAdapter`|Définit les propriétés de base de la carte au niveau de la `Couche 2` telles que l'ID de VLAN, la description et l'adresse MAC.|
|`Set-NetIPInterface`|Modifie les `paramètres` d'une `interface` pour inclure le statut DHCP, le MTU et d'autres métriques.|
|`New-NetIPAddress`|Crée et configure une `adresse IP`.|
|`Set-NetIPAddress`|Modifie la `configuration` d'une carte réseau.|
|`Disable-NetAdapter`|Utilisé pour `désactiver` les interfaces de carte réseau.|
|`Enable-NetAdapter`|Utilisé pour réactiver les cartes réseau et `autoriser` les connexions réseau.|
|`Restart-NetAdapter`|Utilisé pour redémarrer une carte. Cela peut être utile pour appliquer les `changements` apportés aux `paramètres` de la carte.|
|`test-NetConnection`|Permet d'exécuter des vérifications de `diagnostic` sur une connexion. Il prend en charge le ping, le tcp, le traçage de route, et plus encore.|

Nous n'allons pas montrer chaque cmdlet en action, mais il serait prudent de fournir une référence rapide pour votre usage. D'abord, nous commencerons avec Get-NetIPInterface.

#### Get-NetIPInterface

        powershell
`PS C:\htb> get-netIPInterface  ifIndex InterfaceAlias                  AddressFamily NlMtu(Bytes) InterfaceMetric Dhcp     ConnectionState PolicyStore ------- --------------                  ------------- ------------ --------------- ----     --------------- ----------- 20      Ethernet 3                      IPv6                  1500              25 Enabled  Disconnected    ActiveStore 14      VMware Network Adapter VMnet8   IPv6                  1500              35 Enabled  Connected       ActiveStore 8       VMware Network Adapter VMnet2   IPv6                  1500              35 Enabled  Connected       ActiveStore 10      VMware Network Adapter VMnet1   IPv6                  1500              35 Enabled  Connected       ActiveStore 17      Local Area Connection* 2        IPv6                  1500              25 Enabled  Disconnected    ActiveStore 21      Bluetooth Network Connection    IPv6                  1500              65 Disabled Disconnected    ActiveStore 15      Local Area Connection* 1        IPv6                  1500              25 Disabled Disconnected    ActiveStore 25      Wi-Fi                           IPv6                  1500              40 Enabled  Connected       ActiveStore 7       Local Area Connection           IPv6                  1500              25 Enabled  Disconnected    ActiveStore 1       Loopback Pseudo-Interface 1     IPv6            4294967295              75 Disabled Connected       ActiveStore 20      Ethernet 3                      IPv4                  1500              25 Enabled  Disconnected    ActiveStore 14      VMware Network Adapter VMnet8   IPv4                  1500              35 Disabled Connected       ActiveStore 8       VMware Network Adapter VMnet2   IPv4                  1500              35 Disabled Connected       ActiveStore 10      VMware Network Adapter VMnet1   IPv4                  1500              35 Disabled Connected       ActiveStore 17      Local Area Connection* 2        IPv4                  1500              25 Disabled Disconnected    ActiveStore 21      Bluetooth Network Connection    IPv4                  1500              65 Enabled  Disconnected    ActiveStore 15      Local Area Connection* 1        IPv4                  1500              25 Enabled  Disconnected    ActiveStore 25      Wi-Fi                           IPv4                  1500              40 Enabled  Connected       ActiveStore 7       Local Area Connection           IPv4                  1500               1 Disabled Disconnected    ActiveStore 1       Loopback Pseudo-Interface 1     IPv4            4294967295              75 Disabled Connected       ActiveStore`

Cette liste nous montre nos interfaces disponibles sur l'hôte d'une manière un peu alambiquée. On nous fournit de nombreuses métriques, mais les cartes sont réparties par `AddressFamily`. Nous voyons donc des entrées pour chaque carte deux fois si IPv4 et IPv6 sont activés sur cette interface particulière. Les propriétés `ifindex` et `InterfaceAlias` sont particulièrement utiles. Ces propriétés nous facilitent l'utilisation des autres cmdlets fournies par le module `NetTCPIP`. Obtenons les informations de la carte pour notre connexion Wi-Fi à `ifIndex 25` en utilisant la cmdlet [Get-NetIPAddress](https://learn.microsoft.com/en-us/powershell/module/nettcpip/get-netipaddress?view=windowsserver2022-ps).

#### Get-NetIPAddress

        powershell
`PS C:\htb> Get-NetIPAddress -ifIndex 25  IPAddress         : fe80::a0fc:2e3d:c92a:48df%25 InterfaceIndex    : 25 InterfaceAlias    : Wi-Fi AddressFamily     : IPv6 Type              : Unicast PrefixLength      : 64 PrefixOrigin      : WellKnown SuffixOrigin      : Link AddressState      : Preferred ValidLifetime     : Infinite ([TimeSpan]::MaxValue) PreferredLifetime : Infinite ([TimeSpan]::MaxValue) SkipAsSource      : False PolicyStore       : ActiveStore  IPAddress         : 192.168.86.211 InterfaceIndex    : 25 InterfaceAlias    : Wi-Fi AddressFamily     : IPv4 Type              : Unicast PrefixLength      : 24 PrefixOrigin      : Dhcp SuffixOrigin      : Dhcp AddressState      : Preferred ValidLifetime     : 21:35:36 PreferredLifetime : 21:35:36 SkipAsSource      : False PolicyStore       : ActiveStore`

Cette cmdlet a également renvoyé pas mal d'informations. Remarquez comment nous avons utilisé le numéro ifIndex pour demander les informations ? Nous pouvons faire de même avec l'InterfaceAlias. Cette cmdlet renvoie de nombreuses informations, telles que l'index, l'alias, l'état DHCP, le type d'interface et d'autres métriques. Cela reflète la plupart de ce que nous verrions si nous exécutions l'exécutable `IPconfig` depuis l'invite de commande. Maintenant, que faire si nous voulons modifier un paramètre sur l'interface ? Nous pouvons le faire avec les cmdlets [Set-NetIPInterface](https://learn.microsoft.com/en-us/powershell/module/nettcpip/set-netipinterface?view=windowsserver2022-ps) et [Set-NetIPAddress](https://learn.microsoft.com/en-us/powershell/module/nettcpip/set-netipaddress?view=windowsserver2022-ps). Dans cet exemple, disons que nous voulons changer le statut DHCP de l'interface de `enabled` à `disabled`, et changer l'IP assignée automatiquement par DHCP à une que nous choisissons manuellement. Nous accomplirions cela comme suit :

#### Set-NetIPInterface

        powershell
`PS C:\htb> Set-NetIPInterface -InterfaceIndex 25 -Dhcp Disabled`

En désactivant la propriété DHCP avec la cmdlet Set-NetIPInterface, nous pouvons maintenant définir notre adresse IP manuelle. Nous le faisons avec la cmdlet `Set-NetIPAddress`.

#### Set-NetIPAddress

        powershell
`PS C:\htb> Set-NetIPAddress -InterfaceIndex 25 -IPAddress 10.10.100.54 -PrefixLength 24  PS C:\htb> Get-NetIPAddress -ifindex 20 | ft InterfaceIndex,InterfaceAlias,IPAddress,PrefixLength  InterfaceIndex InterfaceAlias IPAddress                   PrefixLength -------------- -------------- ---------                   ------------             20 Ethernet 3     fe80::7408:bbf:954a:6ae5%20           64             20 Ethernet 3     10.10.100.54                          24  PS C:\htb> Get-NetIPinterface -ifindex 20 | ft ifIndex,InterfaceAlias,Dhcp  ifIndex InterfaceAlias     Dhcp ------- --------------     ----      20 Ethernet 3     Disabled      20 Ethernet 3     Disabled`

La commande ci-dessus définit maintenant notre adresse IP à `10.10.100.54` et la PrefixLength (également connue sous le nom de masque de sous-réseau) à `24`. En regardant nos vérifications, nous pouvons voir que ces paramètres sont en place. Par sécurité, redémarrons notre carte réseau et testons notre connexion pour voir si elle tient.

#### Restart-NetAdapter

        powershell
`PS C:\htb> Restart-NetAdapter -Name 'Ethernet 3'`

Tant que rien ne va de travers, vous ne recevrez aucune sortie. Donc, en ce qui concerne `Restart-NetAdapter`, pas de nouvelles, bonnes nouvelles. Le moyen le plus simple d'indiquer à la cmdlet quelle interface redémarrer est avec la propriété `Name`, qui est la même que l'`InterfaceAlias` des commandes précédentes que nous avons exécutées. Maintenant, pour nous assurer que nous avons toujours une connexion, nous pouvons utiliser la cmdlet Test-NetConnection.

#### Test-NetConnection

        powershell
`PS C:\htb> Test-NetConnection  ComputerName           : <snip>msedge.net RemoteAddress          : 13.107.4.52 InterfaceAlias         : Ethernet 3 SourceAddress          : 10.10.100.54 PingSucceeded          : True PingReplyDetails (RTT) : 44 ms`

La cmdlet Test-NetConnection est puissante, capable de tester au-delà de la connectivité réseau de base pour déterminer si nous pouvons atteindre un autre hôte. Elle peut nous renseigner sur nos résultats TCP, des métriques détaillées, des diagnostics de route et plus encore. Il serait utile de consulter cet article de Microsoft sur [Test-NetConnection](https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection?view=windowsserver2022-ps). Maintenant que nous avons terminé notre tâche et validé les paramètres réseau de l'hôte de M. Tanaka, discutons un peu de la connectivité d'accès à distance.

### Accès à Distance

Lorsque nous ne pouvons pas accéder aux systèmes Windows ou que nous devons gérer des hôtes à distance, nous pouvons utiliser PowerShell, SSH et RDP, entre autres outils, pour effectuer notre travail. Voyons les principales façons dont nous pouvons activer et utiliser l'accès à distance. D'abord, nous discuterons de `SSH`.

---

## Comment Activer l'Accès à Distance ? (SSH, PSSessions, etc.)

### Activation de l'Accès SSH

Nous pouvons utiliser `SSH` pour accéder à `PowerShell` sur un système Windows via le réseau. Depuis 2018, SSH via le client et le serveur [OpenSSH](https://www.openssh.com/) est accessible et inclus dans toutes les versions de Windows Server et Client. C'est un mécanisme de communication facile à utiliser et extensible pour notre usage administratif. La configuration d'OpenSSH sur nos hôtes est simple. Essayons. Nous devons installer le composant Serveur SSH et l'application client pour accéder à un hôte à distance via SSH.

#### Configuration de SSH sur une Cible Windows

Nous pouvons configurer un serveur SSH sur une cible Windows en utilisant la cmdlet [Add-WindowsCapability](https://docs.microsoft.com/en-us/powershell/module/dism/add-windowscapability?view=windowsserver2022-ps) et confirmer qu'il est bien installé en utilisant la cmdlet [Get-WindowsCapability](https://docs.microsoft.com/en-us/powershell/module/dism/get-windowscapability?view=windowsserver2022-ps).

        powershell
`PS C:\Users\htb-student> Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'  Name  : OpenSSH.Client~~~~0.0.1.0 State : Installed  Name  : OpenSSH.Server~~~~0.0.1.0 State : NotPresent  PS C:\Users\htb-student> Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0  Path          : Online        : True RestartNeeded : False  PS C:\Users\htb-student> Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'  Name  : OpenSSH.Client~~~~0.0.1.0 State : Installed  Name  : OpenSSH.Server~~~~0.0.1.0 State : NotPresent  PS C:\Users\htb-student> Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0  Path          : Online        : True RestartNeeded : False  PS C:\Users\htb-student> Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'  Name  : OpenSSH.Client~~~~0.0.1.0 State : Installed  Name  : OpenSSH.Server~~~~0.0.1.0 State : Installed`

#### Démarrage du Service SSH & Définition du Type de Démarrage

Une fois que nous avons confirmé que SSH est installé, nous pouvons utiliser la cmdlet [Start-Service](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-service?view=powershell-7.2) pour démarrer le service SSH. Nous pouvons également utiliser la cmdlet [Set-Service](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service?view=powershell-7.2) pour configurer les paramètres de démarrage du service SSH si nous le souhaitons.

        powershell
`PS C:\Users\htb-student> Start-Service sshd      PS C:\Users\htb-student> Set-Service -Name sshd -StartupType 'Automatic'`  

Note : La configuration initiale des services d'accès à distance ne sera pas une exigence dans ce module pour répondre aux questions des défis. Dans chacun des défis de ce module, l'accès à distance est déjà installé et configuré. Cependant, la compréhension de la manière de se connecter et d'appliquer les concepts abordés tout au long du module sera requise. Les étapes d'installation et de configuration sont fournies pour aider à développer une compréhension des erreurs de configuration courantes et, dans certains cas, des meilleures pratiques de sécurité. N'hésitez pas à essayer certaines étapes de configuration sur votre propre VM personnelle.

#### Accéder à PowerShell via SSH

Avec SSH installé et en cours d'exécution sur une cible Windows, nous pouvons nous connecter via le réseau avec un client SSH.

#### Connexion depuis Windows

        powershell
`PS C:\Users\administrator> ssh htb-student@10.129.224.248  htb-student@10.129.224.248 password:`

Par défaut, cela nous connectera à une session CMD, mais nous pouvons taper `powershell` pour entrer dans une session PowerShell, comme mentionné plus tôt dans cette section.

        powershell
`WS01\htb-student@WS01 C:\Users\htb-student> powershell  Windows PowerShell Copyright (C) Microsoft Corporation. All rights reserved.   PS C:\Users\htb-student>`

Nous remarquerons que les étapes pour se connecter à une cible Windows via SSH en utilisant Linux sont identiques à celles pour se connecter depuis Windows.

#### Connexion depuis Linux

        shellsession
`PS C:\Users\administrator> ssh htb-student@10.129.224.248  htb-student@10.129.224.248 password:  WS01\htb-student@WS01 C:\Users\htb-student> powershell  Windows PowerShell Copyright (C) Microsoft Corporation. All rights reserved.   PS C:\Users\htb-student>`

Maintenant que nous avons abordé SSH, passons un peu de temps à couvrir l'activation et l'utilisation de `WinRM` pour l'accès et la gestion à distance.

### Activation de WinRM

[Windows Remote Management (WinRM)](https://docs.microsoft.com/en-us/windows/win32/winrm/portal) peut être configuré à l'aide de cmdlets PowerShell dédiées et nous pouvons entrer dans une session interactive PowerShell ainsi qu'exécuter des commandes sur une ou plusieurs cibles Windows distantes. Nous remarquerons que WinRM est plus couramment activé sur les systèmes d'exploitation Windows Server, afin que les administrateurs informatiques puissent effectuer des tâches sur un ou plusieurs hôtes. Il est activé par défaut dans Windows Server.

En raison de la demande croissante pour la capacité de gérer à distance et d'automatiser les tâches sur les systèmes Windows, nous verrons probablement WinRM activé sur de plus en plus de systèmes d'exploitation de bureau Windows (Windows 10 & Windows 11) également. Lorsque WinRM est activé sur une cible Windows, il écoute sur les ports logiques `5985` & `5986`.

#### Activation & Configuration de WinRM

WinRM peut être activé sur une cible Windows en utilisant les commandes suivantes :

        powershell
`PS C:\WINDOWS\system32> winrm quickconfig  WinRM service is already running on this machine. WinRM is not set up to allow remote access to this machine for management. The following changes must be made:  Enable the WinRM firewall exception. Configure LocalAccountTokenFilterPolicy to grant administrative rights remotely to local users.  Make these changes [y/n]? y  WinRM has been updated for remote management.  WinRM firewall exception enabled. Configured LocalAccountTokenFilterPolicy to grant administrative rights remotely to local users.`

Comme on peut le voir dans la sortie ci-dessus, l'exécution de cette commande garantira automatiquement que toutes les configurations nécessaires sont en place pour :

- Activer le service WinRM
- Autoriser WinRM à travers le pare-feu Windows Defender (entrant et sortant)
- Accorder des droits d'administration à distance aux utilisateurs locaux

Tant que les identifiants pour accéder au système sont connus, toute personne pouvant atteindre la cible sur le réseau peut se connecter après l'exécution de cette commande. Les administrateurs informatiques devraient prendre des mesures supplémentaires pour renforcer ces configurations WinRM, surtout si le système sera accessible à distance via Internet. Parmi certaines de ces options de renforcement, on trouve :

- Configurer TrustedHosts pour n'inclure que les adresses IP/noms d'hôte qui seront utilisés pour la gestion à distance
- Configurer HTTPS pour le transport
- Joindre les systèmes Windows à un environnement de domaine Active Directory et imposer l'authentification Kerberos

#### Test de l'Accès à Distance PowerShell

Une fois que nous avons activé et configuré WinRM, nous pouvons tester l'accès à distance en utilisant la cmdlet PowerShell [Test-WSMan](https://docs.microsoft.com/en-us/powershell/module/microsoft.wsman.management/test-wsman?view=powershell-7.2).

#### Test de l'Accès Non Authentifié

        powershell
`PS C:\Users\administrator> Test-WSMan -ComputerName "10.129.224.248"  wsmid           : http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd ProtocolVersion : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd ProductVendor   : Microsoft Corporation ProductVersion  : OS: 0.0.0 SP: 0.0 Stack: 3.0`

L'exécution de cette cmdlet envoie une requête qui vérifie si le service WinRM est en cours d'exécution. Gardez à l'esprit que ceci n'est pas authentifié, donc aucun identifiant n'est utilisé, c'est pourquoi aucune version de l'`OS` n'est détectée. Cela nous montre que le service WinRM est en cours d'exécution sur la cible.

#### Test de l'Accès Authentifié

        powershell
`PS C:\Users\administrator> Test-WSMan -ComputerName "10.129.224.248" -Authentication Negotiate   wsmid           : http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd ProtocolVersion : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd ProductVendor   : Microsoft Corporation ProductVersion  : OS: 10.0.17763 SP: 0.0 Stack: 3.0`

Nous pouvons exécuter la même commande avec l'option `-Authentication Negotiate` pour tester si WinRM est authentifié, et nous recevrons la version de l'OS (`10.0.11764`).

### Sessions à Distance PowerShell

Nous avons également la possibilité d'utiliser la cmdlet [Enter-PSSession](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enter-pssession?view=powershell-7.2) pour établir une session PowerShell avec une cible Windows.

#### Établissement d'une Session PowerShell

        powershell
`PS C:\Users\administrator> Enter-PSSession -ComputerName 10.129.224.248 -Credential htb-student -Authentication Negotiate [10.129.5.129]: PS C:\Users\htb-student\Documents> $PSVersionTable     Name                           Value ----                           ----- PSVersion                      5.1.17763.592 PSEdition                      Desktop PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...} BuildVersion                   10.0.17763.592 CLRVersion                     4.0.30319.42000 WSManStackVersion              3.0 PSRemotingProtocolVersion      2.3 SerializationVersion           1.1.0.1`

Nous pouvons effectuer cette même action depuis un hôte d'attaque basé sur Linux avec PowerShell Core installé (comme dans Pwnbox). N'oubliez pas que PowerShell n'est pas exclusif à Windows et fonctionne désormais sur d'autres systèmes d'exploitation.

#### Utilisation de Enter-PSSession depuis Linux

        shellsession
`ppporrkkky@htb[/htb]$ [PS]> Enter-PSSession -ComputerName 10.129.224.248 -Credential htb-student -Authentication Negotiate  PowerShell credential request Enter your credentials. Password for user htb-student: ***************  [10.129.224.248]: PS C:\Users\htb-student\Documents> $PSVersionTable  Name                           Value                                            ----                           -----                                            PSVersion                      5.1.19041.1                                      PSEdition                      Desktop                                          PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}                          BuildVersion                   10.0.19041.1                                     CLRVersion                     4.0.30319.42000                                  WSManStackVersion              3.0                                              PSRemotingProtocolVersion      2.3                                              SerializationVersion           1.1.0.1`

En plus d'être indépendant du système d'exploitation, il existe maintenant des tonnes d'outils différents que nous pouvons utiliser pour interagir à distance avec les hôtes. Le choix d'un moyen pour administrer à distance nos hôtes dépend principalement de ce avec quoi vous êtes à l'aise et de ce que vous pouvez utiliser en fonction de l'engagement ou des paramètres de sécurité de votre environnement.

---

La gestion du réseau est une tâche assez simple sur les hôtes Windows. À mesure que vos environnements deviennent plus complexes avec des serveurs cloud, plusieurs domaines et plusieurs sites sur de grandes distances géographiques, la gestion du réseau à ce niveau peut devenir fastidieuse. Heureusement, nous nous concentrons uniquement sur notre hôte local et sur la manière de gérer un seul hôte. Par la suite, nous verrons comment nous pouvons interagir avec le web en utilisant PowerShell.

LAB de fin 

![[Pasted image 20260904021517.png]]

Rep ; DNS

![[Pasted image 20260904021538.png]]

Rep : Net-GetIpAdress

![[Pasted image 20260904021603.png]]

Rep : winrm-quickconfig 