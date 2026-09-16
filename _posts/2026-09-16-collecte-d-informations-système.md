[[Working with Directories and Files - CMD]]

Maintenant que nous savons comment naviguer sur notre hôte Windows en utilisant uniquement l'invite de commandes, passons à un concept fondamental accessible à la fois aux `Administrateurs Systèmes` et aux `Testeurs d'Intrusion` : la `Collecte d'informations système`.

La collecte d'`informations système` (également appelée `énumération d'hôte`) peut sembler intimidante au premier abord ; cependant, c'est une étape cruciale pour jeter de bonnes bases afin de connaître notre environnement. Apprendre à connaître l'environnement et se faire une idée générale de ce qui nous entoure est bénéfique pour les deux camps, profitant à l'`équipe rouge (red team)` et à l'`équipe bleue (blue team)`. Ceux qui font partie de l'`équipe rouge` (Testeurs d'Intrusion, Opérateurs Red Team, hackers, etc.) trouveront utile de pouvoir analyser leurs hôtes et l'environnement pour savoir quels services et machines vulnérables peuvent être exploités. Tandis que l'`équipe bleue` (Administrateurs Systèmes, Analystes SOC, etc.) peut utiliser ces informations pour diagnostiquer des problèmes, sécuriser les hôtes et les services, et garantir l'intégrité sur l'ensemble du réseau. Quelle que soit l'équipe qui nous intéresse le plus ou dans laquelle nous sommes actuellement impliqués, cette section vise à fournir les informations suivantes :

- Quelles informations pouvons-nous collecter sur le système (`hôte`) ?
- Pourquoi avons-nous besoin de ces informations, et quelle est l'importance d'une énumération approfondie ?
- Comment obtenir ces informations via l'invite de commandes, et quelle méthodologie générale devrions-nous suivre ?

---

## Quels types d'informations pouvons-nous collecter sur le système ?

Une fois que nous avons un accès initial au système via un `shell de commande`, il peut être difficile de savoir par où commencer à chercher des informations sur le système. `Énumérer` manuellement le système sans avoir un plan en tête sur la façon de procéder peut entraîner de nombreuses heures perdues à fouiller dans des trésors d'informations qui semblent importantes, avec peu ou pas de résultats pour tout ce temps passé. Le but de l'`énumération d'hôte` est de fournir une image globale de l'hôte cible, de son environnement et de la manière dont il interagit avec d'autres systèmes sur le réseau. En gardant cela à l'esprit, la première question que nous pourrions nous poser est :

`Comment savoir ce qu'il faut chercher ?`

Pour répondre à cette question, nous devons avoir une compréhension de base de tous les différents types d'informations qui nous sont accessibles sur un système. Vous trouverez ci-dessous un tableau que nous pouvons utiliser comme référence pour nous donner un aperçu général des principaux types d'informations dont nous devons être conscients lors de l'énumération d'hôte.

![Carte mentale intitulée 'Types d'informations' avec les catégories : Informations générales sur le système, Informations réseau, Informations de base sur le domaine et Informations sur l'utilisateur, détaillant des éléments tels que les détails de l'OS, l'adresse IP, les ressources réseau, le nom de domaine, les comptes d'utilisateurs et les services.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/InformationTypesChart_Updated.png)

Comme nous pouvons le voir sur le diagramme ci-dessus, les types d'informations que nous rechercherions peuvent être répartis dans les catégories suivantes :

|Type|Description|
|---|---|
|`Informations générales sur le système`|Contient des informations sur le système cible dans son ensemble. Les informations sur le système cible incluent, sans s'y limiter, le `nom d'hôte` de la machine, les détails spécifiques à l'OS (`nom`, `version`, `configuration`, etc.), et les `correctifs/patchs installés` pour le système.|
|`Informations réseau`|Contient des informations sur le réseau et la connexion pour le système cible et le(s) système(s) auquel(s) la cible est connectée sur le réseau. Les exemples d'informations réseau incluent, sans s'y limiter, les suivants : `adresse IP de l'hôte`, `interfaces réseau disponibles`, `sous-réseaux accessibles`, `serveur(s) DNS`, `hôtes connus`, et `ressources réseau`.|
|`Informations de base sur le domaine`|Contient des informations Active Directory concernant le domaine auquel le système cible est connecté.|
|`Informations sur l'utilisateur`|Contient des informations concernant les utilisateurs et groupes locaux sur le système cible. Cela peut généralement être étendu pour contenir tout ce qui est accessible à ces comptes, comme les `variables d'environnement`, les `tâches en cours d'exécution`, les `tâches planifiées`, et les `services connus`.|

Bien que ce ne soit pas une liste exhaustive de chaque information sur un système, cela nous fournira les moyens de commencer à créer une méthodologie solide pour l'énumération. En examinant à nouveau le diagramme avec nos nouvelles connaissances, nous pouvons voir un modèle émerger quant à ce que nous devrions rechercher lors de l'énumération de notre hôte cible. Pour rester concentrés pendant l'énumération, nous voulons essayer de nous poser certaines des questions suivantes :

- Quelles informations système pouvons-nous extraire de notre hôte cible ?
- Avec quel(s) autre(s) système(s) notre hôte cible interagit-il sur le réseau ?
- À quel(s) compte(s) utilisateur(s) avons-nous accès, et quelles informations sont accessibles depuis ce(s) compte(s) ?

Considérez ces questions comme un moyen de structurer notre approche pour nous aider à développer une conscience situationnelle et une méthodologie de test. Cela nous donne une idée plus claire de ce que nous recherchons et des informations qui doivent être filtrées ou priorisées lors d'un engagement réel.

---

## Pourquoi avons-nous besoin de ces informations ?

Dans la section précédente, nous avons discuté des informations qui peuvent être collectées sur un système lors de l'énumération et de ce dont nous devons être conscients pendant notre recherche. Cette section expliquera davantage le `pourquoi` de la collecte d'informations en premier lieu et l'importance d'une énumération approfondie d'une cible.

Comme indiqué précédemment, notre `objectif (goal)` avec l'`énumération d'hôte` est d'utiliser les informations obtenues de la cible pour nous fournir un point de départ et un guide sur la manière dont nous souhaitons attaquer le système. Pour mieux comprendre le concept derrière l'importance d'une bonne énumération d'hôte, suivons l'exemple suivant :

**Exemple :** Imaginez que vous êtes chargé de travailler sur un engagement de `compromission présumée (assumed breach)` et que l'on vous a fourni un accès initial via ce qui est supposé être un compte utilisateur non privilégié. Votre tâche est de vous faire une idée générale du terrain et de voir si vous pouvez `élever vos privilèges (escalate your privileges)` au-delà de l'accès initial du compte utilisateur compromis.

En suivant ce scénario d'exemple, nous voyons que nous avons un accès direct à notre hôte initial via un compte utilisateur supposé non privilégié. Cependant, notre objectif est d'élever nos privilèges vers un compte ayant accès à des privilèges plus élevés ou à des permissions administratives si nous avons de la chance. Pour ce faire, nous aurons besoin d'une compréhension approfondie de notre environnement, y compris les éléments suivants :

- À quel compte utilisateur avons-nous accès ?
- À quels groupes notre utilisateur appartient-il ?
- Quel est l'ensemble actuel de privilèges auquel notre utilisateur a accès ?
- À quelles ressources notre utilisateur peut-il accéder sur le réseau ?
- Quelles tâches et quels services s'exécutent sous notre compte utilisateur ?

N'oubliez pas que cela ne couvre que partiellement toutes les questions que nous pouvons nous poser pour atteindre notre objectif visé, mais simplement un petit sous-ensemble de possibilités. Sans réfléchir et sans suivre une structure guidée lors de l'`énumération`, nous aurons du mal à savoir si nous disposons de toutes les informations nécessaires pour atteindre notre objectif. Il peut être facile de considérer un système comme étant entièrement patché et non vulnérable aux [CVEs](https://en.wikipedia.org/wiki/Common_Vulnerabilities_and_Exposures) actuels ou aux dernières `vulnérabilités`. Cependant, si vous vous concentrez uniquement sur cet aspect, il est facile de passer à côté des nombreuses erreurs de configuration humaines qui pourraient exister dans l'environnement. C'est la raison même pour laquelle prendre notre temps et rassembler toutes les informations possibles sur un système ou un environnement devrait être prioritaire en termes d'importance par rapport à l'exploitation simple et hasardeuse d'un système.

---

## Comment obtenir ces informations ?

#### Lancer un large filet

CMD fournit un guichet unique pour les informations via la commande `systeminfo`. C'est excellent pour trouver des informations pertinentes sur l'hôte, telles que le nom d'hôte, l'adresse ou les adresses IP, s'il appartient à un domaine, quels correctifs ont été installés, et bien plus encore. Ces informations sont très précieuses pour un administrateur système lorsqu'il tente de diagnostiquer des problèmes.

Pour un hacker, c'est un excellent moyen d'obtenir rapidement une vue d'ensemble lorsque vous accédez pour la première fois à un hôte tout en laissant une empreinte minimale. Exécuter une seule commande est toujours mieux que d'en exécuter deux ou trois juste pour obtenir les mêmes informations. Nous sommes moins susceptibles d'être détectés de cette manière. Avoir un accès rapide à des éléments tels que la version de l'OS, les correctifs installés et la version de la compilation de l'OS peut nous aider à déterminer rapidement, à partir d'une recherche rapide sur Google ou [ExploitDB](https://www.exploit-db.com/), s'il existe un exploit qui peut être rapidement utilisé pour exploiter davantage cet hôte, élever les privilèges, et plus encore.

#### Sortie de Systeminfo

        cmd
`C:\htb> systeminfo   Host Name:                 DESKTOP-htb OS Name:                   Microsoft Windows 10 Pro OS Version:                10.0.19042 N/A Build 19042 OS Manufacturer:           Microsoft Corporation OS Configuration:          Standalone Workstation OS Build Type:             Multiprocessor Free  <snipped>`

Cependant, connaître une seule façon de collecter des informations est inefficace, surtout si certaines commandes sont surveillées et suivies de plus près que d'autres. C'est pourquoi nous avons besoin de plus d'une méthode établie pour collecter les informations requises et rester sous le radar de détection lorsque c'est possible.

---

#### Examiner le système

Comme montré précédemment, `systeminfo` contient beaucoup d'informations à trier ; cependant, si nous avons besoin de récupérer des informations système de base telles que le `nom d'hôte` ou la `version de l'OS`, nous pouvons utiliser les utilitaires `hostname` et `ver` intégrés à l'invite de commandes.

L'utilitaire [hostname](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/hostname) porte bien son nom et nous fournit le nom d'hôte de la machine, tandis que la commande [ver](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ver) affiche le numéro de version actuel du système d'exploitation. Les deux commandes, utilisées conjointement, nous fourniront une autre manière de récupérer des informations système de base que nous pourrons utiliser lors de l'énumération plus approfondie de l'hôte cible.

#### Sortie de Hostname

        cmd
`C:\htb> hostname  DESKTOP-htb`

#### Sortie de Ver

        cmd
`C:\htb> ver  Microsoft Windows [Version 10.0.19042.2006]`

#### Sonder le réseau

En plus des informations sur l'hôte fournies ci-dessus, jetons un coup d'œil rapide à quelques informations réseau de base pour notre cible. Une compréhension approfondie de la manière dont notre cible est connectée et des appareils auxquels elle peut accéder sur le réseau est un outil inestimable dans notre arsenal en tant qu'attaquant.

Pour rassembler ces informations rapidement et en une seule commande simple à utiliser, l'invite de commandes propose l'utilitaire `ipconfig`. L'utilitaire [ipconfig](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig) affiche toutes les configurations réseau TCP/IP actuelles de la machine. Regardons un exemple de configuration `ipconfig` sans fournir de paramètres supplémentaires.

#### Ipconfig sans paramètres

        cmd
`C:\htb> ipconfig  Windows IP Configuration  <SNIP>  Ethernet adapter Ethernet:     Connection-specific DNS Suffix  . : htb.local    Link-local IPv6 Address . . . . . : fe80::2958:39a:df51:b60%23    IPv4 Address. . . . . . . . . . . : 10.0.25.17    Subnet Mask . . . . . . . . . . . : 255.255.255.0    Default Gateway . . . . . . . . . : 10.0.25.1  Ethernet adapter Ethernet 2:     Connection-specific DNS Suffix  . : internal.htb.local    Link-local IPv6 Address . . . . . : fe80::bc3b:6f9f:68d4:3ec5%26    IPv4 Address. . . . . . . . . . . : 172.16.50.15    Subnet Mask . . . . . . . . . . . : 255.255.255.0    Default Gateway . . . . . . . . . : 172.16.50.1  <SNIP>`

Comme nous pouvons le voir dans l'exemple ci-dessus, même sans spécifier de paramètres, nous obtenons des informations réseau de base pour la machine hôte, telles que le `Nom de domaine`, l'`Adresse IPv4`, le `Masque de sous-réseau` et la `Passerelle par défaut`. Tout cela peut fournir un aperçu du ou des réseaux dont la cible fait partie et auxquels elle est connectée, ainsi que de l'environnement plus large. Si nous avons besoin d'informations supplémentaires ou si nous voulons creuser davantage dans les paramètres spécifiques appliqués à chaque adaptateur, nous pouvons utiliser la commande suivante : `ipconfig /all`. Comme l'indique le drapeau fourni, cette commande fournit une liste complète (configuration TCP/IP complète) de chaque adaptateur réseau attaché au système et des informations supplémentaires, y compris l'adresse physique de chaque adaptateur (`Adresse MAC`), les paramètres DHCP et les serveurs DNS.

`Ipconfig` est une commande très polyvalente pour recueillir des informations sur la connectivité réseau de l'hôte cible ; cependant, si nous avons besoin de voir rapidement avec quels hôtes notre cible est entrée en contact, ne cherchez pas plus loin que la commande `arp`.

L'utilitaire [arp](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/arp) affiche efficacement le contenu et les entrées contenues dans le cache du protocole de résolution d'adresses (`ARP`). Nous pouvons également utiliser cette commande pour modifier efficacement les entrées de la table. Cependant, cela dépasse le cadre de ce module. Pour mieux comprendre quel type d'informations le cache `ARP` contient, examinons rapidement l'exemple suivant :

#### Utiliser ARP pour trouver des hôtes supplémentaires

        cmd
`C:\htb> arp /a  <SNIP>  Interface: 10.0.25.17 --- 0x17   Internet Address      Physical Address      Type   10.0.25.1             00-e0-67-15-cf-43     dynamic   10.0.25.5             54-9f-35-1c-3a-e2     dynamic   10.0.25.10            00-0c-29-62-09-81     dynamic   10.0.25.255           ff-ff-ff-ff-ff-ff     static   224.0.0.22            01-00-5e-00-00-16     static   224.0.0.251           01-00-5e-00-00-fb     static   224.0.0.252           01-00-5e-00-00-fc     static   239.255.255.250       01-00-5e-7f-ff-fa     static   255.255.255.255       ff-ff-ff-ff-ff-ff     static  Interface: 172.16.50.15 --- 0x1a   Internet Address      Physical Address      Type   172.16.50.1           15-c0-6b-58-70-ed     dynamic   172.16.50.20          80-e5-53-3c-72-30     dynamic   172.16.50.32          fb-90-01-5c-1f-88     dynamic   172.16.50.65          7a-49-56-10-3b-76     dynamic   172.16.50.255         ff-ff-ff-ff-ff-ff     static   224.0.0.22            01-00-5e-00-00-16     static   224.0.0.251           01-00-5e-00-00-fb     static   224.0.0.252           01-00-5e-00-00-fc     static   239.255.255.250       01-00-5e-7f-ff-fa     static  <SNIP>`

À partir de cet exemple, nous pouvons voir tous les hôtes qui sont entrés en contact ou qui ont pu avoir une communication antérieure avec notre cible. Nous pouvons utiliser ces informations pour commencer à cartographier le réseau le long de chacune des interfaces réseau appartenant à notre cible.

---

#### Comprendre notre utilisateur actuel

Maintenant que nous avons quelques informations de base sur l'hôte pour commencer, nous devrions chercher à mieux comprendre notre compte utilisateur compromis actuel. L'un des meilleurs utilitaires de ligne de commande pour ce faire est `whoami`.

[Whoami](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/whoami) nous permet d'afficher les informations sur l'utilisateur, le groupe et les privilèges de l'utilisateur actuellement connecté. Dans ce cas, nous devrions d'abord l'exécuter sans aucun paramètre et voir quel type de sortie nous obtenons.

        cmd
`C:\htb> whoami  ACADEMY-WIN11\htb-student`

Comme nous pouvons le voir dans la sortie initiale ci-dessus, l'exécution de `whoami` sans paramètres nous fournit le domaine actuel et le nom d'utilisateur du compte connecté.

**Remarque :** Si l'utilisateur actuel n'est pas un compte joint à un domaine, le nom `NetBIOS` sera fourni à la place. Le `nom d'hôte` actuel sera utilisé dans la plupart des cas.

#### Vérifier nos privilèges

Comme mentionné précédemment, nous pouvons également utiliser `whoami` pour voir les privilèges de sécurité de notre utilisateur actuel sur le système. En comprenant quels privilèges sont activés pour notre utilisateur actuel, nous pouvons déterminer nos capacités sur notre hôte cible. Essayons d'exécuter `whoami /priv` depuis notre compte utilisateur compromis.

        cmd
`C:\htb> whoami /priv  PRIVILEGES INFORMATION ----------------------  Privilege Name                Description                          State ============================= ==================================== ======== SeShutdownPrivilege           Shut down the system                 Disabled SeChangeNotifyPrivilege       Bypass traverse checking             Enabled SeUndockPrivilege             Remove computer from docking station Disabled SeIncreaseWorkingSetPrivilege Increase a process working set       Disabled SeTimeZonePrivilege           Change the time zone                 Disabled`

D'après la sortie ci-dessus, nous ne semblons avoir accès qu'à un ensemble de permissions de base, et la plupart de nos options sont désactivées. Cela correspond aux limitations d'un compte utilisateur standard provisionné sur le domaine. Cependant, s'il y avait des erreurs de configuration dans ces paramètres ou si l'utilisateur avait des privilèges supplémentaires, nous pourrions potentiellement en tirer parti pour tenter d'élever les privilèges de notre utilisateur actuel.

#### Examiner les groupes

En plus d'avoir une compréhension approfondie des privilèges de notre utilisateur actuel, nous devrions également prendre le temps de voir de quels groupes notre compte est membre. Cela peut fournir un aperçu des autres groupes dont notre utilisateur actuel fait partie, y compris les groupes par défaut (intégrés) et, plus important encore, tous les groupes personnalisés auxquels notre utilisateur a explicitement reçu l'accès. Pour voir les groupes dont notre utilisateur actuel fait partie, nous pouvons lancer la commande suivante : `whoami /groups`.

        cmd
`C:\htb> whoami /groups  GROUP INFORMATION -----------------  Group Name                             Type             SID          Attributes ====================================== ================ ============ ================================================== Everyone                               Well-known group S-1-1-0      Mandatory group, Enabled by default, Enabled group BUILTIN\Users                          Alias            S-1-5-32-545 Mandatory group, Enabled by default, Enabled group BUILTIN\Performance Log Users          Alias            S-1-5-32-559 Mandatory group, Enabled by default, Enabled group NT AUTHORITY\INTERACTIVE               Well-known group S-1-5-4      Mandatory group, Enabled by default, Enabled group CONSOLE LOGON                          Well-known group S-1-2-1      Mandatory group, Enabled by default, Enabled group NT AUTHORITY\Authenticated Users       Well-known group S-1-5-11     Mandatory group, Enabled by default, Enabled group NT AUTHORITY\This Organization         Well-known group S-1-5-15     Mandatory group, Enabled by default, Enabled group NT AUTHORITY\Local account             Well-known group S-1-5-113    Mandatory group, Enabled by default, Enabled group LOCAL                                  Well-known group S-1-2-0      Mandatory group, Enabled by default, Enabled group NT AUTHORITY\NTLM Authentication       Well-known group S-1-5-64-10  Mandatory group, Enabled by default, Enabled group Mandatory Label\Medium Mandatory Level Label            S-1-16-8192`

Notre utilisateur n'est membre d'aucun autre groupe que les groupes intégrés ajoutés à notre compte lors de sa création. Cependant, il est essentiel de noter que dans certains cas, les utilisateurs peuvent se voir accorder un accès, des privilèges et des permissions supplémentaires en fonction des groupes auxquels ils appartiennent.

**Remarque :** Les commandes présentées ci-dessus ne contiennent que certaines sections de la sortie fournie par `whoami /all`. Selon la situation et les informations nécessaires, nous pouvons utiliser les commandes individuelles ou rassembler toutes les informations en une seule fois à l'aide du paramètre `/all`.

---

#### Examiner d'autres utilisateurs/groupes

Après avoir examiné notre compte utilisateur compromis actuel, nous devons élargir nos recherches et voir si nous pouvons accéder à d'autres comptes. Dans la plupart des environnements, les machines d'un réseau sont jointes à un domaine. En raison de la nature des réseaux joints à un domaine, n'importe qui peut se connecter à n'importe quel hôte physique sur le réseau sans nécessiter un compte local sur la machine. Nous pouvons utiliser cela à notre avantage en recherchant quels utilisateurs ont accédé à notre hôte actuel pour voir si nous pourrions accéder à d'autres comptes. C'est très bénéfique en tant que méthode de maintien de la persistance sur le réseau. Pour ce faire, nous pouvons utiliser une fonctionnalité spécifique de la commande `net`.

#### Net User

[Net User](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc771865\(v=ws.11\)) nous permet d'afficher une liste de tous les utilisateurs sur un hôte, des informations sur un utilisateur spécifique, et de créer ou de supprimer des utilisateurs.

        cmd
`C:\htb> net user  User accounts for \\ACADEMY-WIN11  ------------------------------------------------------------------------------- Administrator            DefaultAccount           Guest htb-student              WDAGUtilityAccount The command completed successfully.`

D'après la sortie fournie, seuls quelques comptes utilisateurs ont été créés pour cette machine. Cependant, si nous étions sur un réseau plus peuplé, nous pourrions trouver plus de comptes à tenter de compromettre.

#### Net Group / Localgroup

En plus des comptes utilisateurs, nous devrions également jeter un coup d'œil rapide aux groupes qui existent sur le réseau. Dans la section précédente, nous avons beaucoup discuté des groupes dont notre utilisateur est membre ; cependant, nous avons également la capacité depuis notre hôte actuel de voir tous les groupes qui existent sur notre hôte et depuis le domaine. Nous pouvons y parvenir en utilisant les commandes `net group` et `net localgroup`.

[Net Group](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc754051\(v=ws.11\)) affichera tous les groupes qui existent sur l'hôte à partir duquel nous avons lancé la commande, créera et supprimera des groupes, et ajoutera ou supprimera des utilisateurs de groupes. Il affichera également les informations sur les groupes de domaine si l'hôte est joint au domaine. Gardez à l'esprit que `net group` doit être exécuté sur un serveur de domaine tel que le DC, tandis que `net localgroup` peut être exécuté sur n'importe quel hôte pour nous montrer les groupes qu'il contient.

        cmd
`C:\htb> net group net group This command can be used only on a Windows Domain Controller.  More help is available by typing NET HELPMSG 3515.   C:\htb>net localgroup  Aliases for \\ACADEMY-WIN11  ------------------------------------------------------------------------------- *__vmware__ *Access Control Assistance Operators *Administrators *Backup Operators *Cryptographic Operators *Device Owners *Distributed COM Users *Event Log Readers *Guests *Hyper-V Administrators *IIS_IUSRS *Network Configuration Operators *Performance Log Users *Performance Monitor Users *Power Users *Remote Desktop Users *Remote Management Users *Replicator *System Managed Accounts Group *Users The command completed successfully.`

---

#### Explorer les ressources sur le réseau

Auparavant, nous nous sommes concentrés sur ce à quoi notre utilisateur actuel a accès localement sur l'hôte. Cependant, dans un environnement de domaine, les utilisateurs sont généralement tenus de stocker tout matériel lié au travail sur un `partage (share)` situé sur le réseau plutôt que de stocker des fichiers localement sur leur machine. Ces partages se trouvent généralement sur un serveur, loin de l'accès physique d'un employé lambda. En règle générale, les utilisateurs standard auront les permissions nécessaires pour lire, écrire et exécuter des fichiers à partir d'un partage, à condition qu'ils disposent d'identifiants valides. Nous pouvons, bien sûr, abuser de cela comme une méthode de persistance supplémentaire, mais comment localiser ces partages en premier lieu ?

#### Net Share

Une façon de le faire consiste à utiliser la commande `net share`. [Net Share](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/hh750728\(v=ws.11\)) nous permet d'afficher des informations sur les ressources partagées sur l'hôte et de créer de nouvelles ressources partagées également.

        cmd
`C:\htb> net share    Share name   Resource                        Remark  ------------------------------------------------------------------------------- C$           C:\                             Default share IPC$                                         Remote IPC ADMIN$       C:\Windows                      Remote Admin Records      D:\Important-Files              Mounted share for records storage   The command completed successfully.`

Comme nous pouvons le voir dans l'exemple ci-dessus, nous avons une liste de partages auxquels notre utilisateur compromis actuel a accès. En lisant les remarques, nous pouvons supposer que `Records` est un partage monté manuellement qui pourrait contenir des informations potentiellement intéressantes à énumérer. Idéalement, si nous trouvions un partage ouvert comme celui-ci lors d'un engagement, nous devrions garder une trace des éléments suivants :

- Avons-nous les permissions appropriées pour accéder à ce partage ?
- Pouvons-nous lire, écrire et exécuter des fichiers sur le partage ?
- Y a-t-il des données précieuses sur le partage ?

En plus de fournir des informations, les `partages` sont parfaits pour héberger tout ce dont nous avons besoin et pour se déplacer latéralement entre les hôtes en tant que testeur d'intrusion. Si nous ne nous soucions pas trop d'être discrets, nous pouvons déposer une charge utile ou d'autres données sur un partage pour permettre le mouvement vers d'autres hôtes sur le réseau. Bien que cela dépasse le cadre de ce module, abuser des partages de cette manière est une excellente méthode de persistance et peut potentiellement être utilisé pour élever des privilèges.

#### Net View

Si nous ne recherchons pas explicitement des partages et souhaitons explorer l'environnement de manière plus large, nous disposons d'une autre commande qui peut être extrêmement utile, également connue sous le nom de `net view`.

[Net View](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/hh875576\(v=ws.11\)) nous affichera toutes les ressources partagées que l'hôte sur lequel vous lancez la commande connaît. Cela inclut les ressources de domaine, les partages, les imprimantes, et plus encore.

        cmd
`C:\htb> net view`  

#### Assembler les pièces du puzzle

En utilisant toutes les informations et les exemples fournis ci-dessus, nous avons extrait une quantité significative d'informations de notre hôte et de ses environs. À partir de là, en fonction de notre accès, nous pouvons élever nos privilèges ou continuer à progresser vers notre objectif. L'accès au niveau système sur chaque hôte n'est pas nécessaire pour un testeur d'intrusion (sauf si l'évaluation l'exige), alors évitons de nous enliser en essayant de l'obtenir à chaque occasion.

Ceci n'est qu'un aperçu rapide de la manière dont `CMD` peut être utilisé pour obtenir un accès et poursuivre une évaluation avec des ressources limitées. Gardez à l'esprit que cette voie est assez bruyante, et nous serons finalement repérés par une équipe bleue même semi-compétente. En l'état actuel des choses, nous écrivons des tonnes de journaux, laissons des traces sur plusieurs hôtes, et n'avons que peu ou pas d'informations sur ce que leur `EDR` et `NIDS` ont pu voir.

**Remarque :** Dans un environnement standard, l'utilisation de l'invite de commandes n'est pas courante pour un utilisateur ordinaire. Les administrateurs ont parfois une raison de l'utiliser mais se méfieront activement de tout utilisateur moyen exécutant cmd.exe. Dans cette optique, l'utilisation des commandes `net *` dans un environnement n'est pas non plus une chose normale, et peut être un moyen facile d'alerter sur une infiltration potentielle d'un hôte en réseau. Avec une surveillance et une journalisation appropriées, nous devrions repérer rapidement ces actions et les utiliser pour trier un incident avant qu'il ne devienne incontrôlable.

---

## Réflexions finales et considérations

Bien que cette section ait été incroyablement longue, nous devrions avoir une idée générale de l'étendue globale des informations que l'on peut trouver sur un système, de la raison pour laquelle nous en avons besoin, et de la manière dont nous pouvons collecter ces informations rapidement et efficacement. En tant que testeur d'intrusion, avoir cet état d'esprit nous permet de faire progresser notre méthodologie et d'acquérir une compréhension approfondie de ce que nous recherchons exactement lors de l'énumération d'un système ou de son environnement plus large. Avoir une méthodologie solide pour l'énumération est une compétence très précieuse que nous devons acquérir dès le début.

Au fur et à mesure que nous avancerons dans les sections suivantes de ce module, notre état d'esprit et notre méthodologie resteront les mêmes, car nous ne ferons que construire sur les fondations qui sont en train d'être posées. Dans la section suivante, nous nous pencherons plus en détail sur la recherche de fichiers et de répertoires spécifiques sur notre système.

LAB de fin 

![Pasted image 20260831011127.png](/assets/img/writeups/Pasted image 20260831011127.png)

rep : systeminfo

![Pasted image 20260831011204.png](/assets/img/writeups/Pasted image 20260831011204.png)

rep : ICL-WIN11