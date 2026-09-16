[[Command Prompt Basics]]
de désactiver des services est une compétence recherchée lorsqu'on atterrit sur un hôte. Dans cette section, nous examinerons l'utilisation de `sc`, l'utilitaire de contrôle des services en ligne de commande de Windows, mais nous l'aborderons d'une manière un peu différente. Examinons cela du point de vue d'un attaquant. Nous venons d'atterrir sur l'hôte d'une victime et nous devons :

- Déterminer quels services sont en cours d'exécution.
- Tenter de désactiver l'antivirus.
- Modifier les services existants sur un système.

---

## Contrôleur de Service

[SC](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc754599\(v=ws.11\)) est un utilitaire exécutable de Windows qui nous permet d'interroger, de modifier et de gérer les services d'un hôte localement et sur le réseau. Pour la majeure partie de cette section, nous utiliserons `SC` comme notre méthode de prédilection pour gérer les services. Nous disposons d'autres outils, comme Windows Management Instrumentation (`WMIC`) et `Tasklist`, qui peuvent également interroger et gérer les services pour les hôtes locaux et distants. Plongeons dans le vif du sujet et essayons `sc`.

#### SC sans paramètres

        cmd
`C:\htb> sc  DESCRIPTION:         SC is a command line program used for communicating with the         Service Control Manager and services. USAGE:         sc <server> [command] [service name] <option1> <option2>...           The option <server> has the form "\\ServerName"         Further help on commands can be obtained by typing: "sc [command]"         Commands:           query-----------Queries the status for a service, or                           enumerates the status for types of services.           queryex---------Queries the extended status for a service, or                           enumerates the status for types of services.           start-----------Starts a service.           pause-----------Sends a PAUSE control request to a service.  <SNIP>  SYNTAX EXAMPLES sc query                - Enumerates status for active services & drivers sc query eventlog       - Displays status for the eventlog service sc queryex eventlog     - Displays extended status for the eventlog service sc query type= driver   - Enumerates only active drivers sc query type= service  - Enumerates only Win32 services sc query state= all     - Enumerates all services & drivers sc query bufsize= 50    - Enumerates with a 50 byte buffer sc query ri= 14         - Enumerates with resume index = 14 sc queryex group= ""    - Enumerates active services not in a group sc query type= interact - Enumerates all interactive services sc query type= driver group= NDIS     - Enumerates all NDIS drivers`

Comme nous pouvons le voir, `SC` sans paramètres fonctionne comme la plupart des commandes et nous fournit le contexte d'aide ainsi que quelques excellents exemples pour commencer, affichés dans la sortie du terminal.

---

## Interroger les Services

Pouvoir interroger (`query`) les services pour obtenir des informations telles que l'état du processus (`process state`), l'identifiant du processus (`process id` ou PID) et le type de service (`service type`) est un outil précieux à avoir dans notre arsenal en tant qu'attaquant. Nous pouvons l'utiliser pour vérifier si certains services sont en cours d'exécution ou pour examiner tous les services et pilotes existants sur le système afin d'obtenir plus d'informations. Avant de nous pencher spécifiquement sur la vérification du service Windows Defender, voyons quels services sont actuellement en cours d'exécution sur le système. Nous pouvons le faire en exécutant la commande suivante : `sc query type= service`.

**Note :** L'espacement des paramètres de requête optionnels est crucial. Par exemple, `type= service`, `type=service` et `type =service` sont des manières complètement différentes d'espacer ce paramètre. Cependant, seul `type= service` est correct dans ce cas.

#### Interroger tous les services actifs

        cmd
`C:\htb> sc query type= service  SERVICE_NAME: Appinfo DISPLAY_NAME: Application Information         TYPE               : 30  WIN32         STATE              : 4  RUNNING                                 (STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0  SERVICE_NAME: AppXSvc DISPLAY_NAME: AppX Deployment Service (AppXSVC)         TYPE               : 30  WIN32         STATE              : 4  RUNNING                                 (STOPPABLE, NOT_PAUSABLE, ACCEPTS_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0  SERVICE_NAME: AudioEndpointBuilder DISPLAY_NAME: Windows Audio Endpoint Builder         TYPE               : 30  WIN32         STATE              : 4  RUNNING                                 (STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0  SERVICE_NAME: Audiosrv DISPLAY_NAME: Windows Audio         TYPE               : 10  WIN32_OWN_PROCESS         STATE              : 4  RUNNING                                 (STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0  SERVICE_NAME: BFE DISPLAY_NAME: Base Filtering Engine         TYPE               : 20  WIN32_SHARE_PROCESS         STATE              : 4  RUNNING                                 (STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0  SERVICE_NAME: BITS DISPLAY_NAME: Background Intelligent Transfer Service         TYPE               : 30  WIN32         STATE              : 4  RUNNING                                 (STOPPABLE, NOT_PAUSABLE, ACCEPTS_PRESHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0  <SNIP>`

Nous pouvons voir une liste complète des services en cours d'exécution sur ce système. En utilisant ces informations, nous pouvons examiner en détail ce qui s'exécute sur le système et rechercher tout ce que nous souhaitons désactiver ou, dans certains cas, des services que nous pouvons tenter de détourner à nos propres fins, que ce soit pour l'élévation de privilèges (`escalation`) ou la persistance (`persistence`).

Revenons à notre scénario : nous avons récemment atterri sur un hôte et devons l'interroger (`query`) pour déterminer si Windows Defender est actif. Essayons `sc query`.

#### Interroger Windows Defender

        cmd
`C:\htb> sc query windefend  SERVICE_NAME: windefend         TYPE               : 10  WIN32_OWN_PROCESS         STATE              : 4  RUNNING                                 (NOT_STOPPABLE, NOT_PAUSABLE, ACCEPTS_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0`

Que voyons-nous ci-dessus ? Nous pouvons dire que Windows Defender est en cours d'exécution et que, avec notre ensemble de permissions actuel (celui que nous avons utilisé pour la requête), nous n'avons pas la permission d'arrêter ou de mettre en pause le service (probablement parce que notre utilisateur est un utilisateur standard et non un administrateur). Nous pouvons tester cela en essayant d'arrêter le service.

---

## Arrêter et démarrer des Services

#### Arrêter un service avec des privilèges élevés

        cmd
`C:\htb> sc stop windefend  Access is denied.`

Comme nous pouvons le voir dans la sortie ci-dessus, notre utilisateur actuel ne dispose pas des permissions appropriées pourarrêter ou mettre en pause ce service particulier. Pour effectuer cette action, nous aurions probablement besoin des permissions d'un compte Administrateur et, dans certains cas, certains services ne peuvent être gérés que par le système lui-même. Idéalement, tenter d'arrêter un service avec des privilèges élevés comme celui-ci n'est pas la meilleure façon de tester les permissions, car cela nous fera probablement repérer en raison du trafic qui sera généré par l'exécution d'une telle commande.

Maintenant que nous avons tenté et échoué à arrêter le service `windefend` avec un utilisateur aux permissions standard, montrons ce qui se passerait si nous obtenions effectivement l'accès à un compte disposant des privilèges d'administrateur local de la machine. Nous pouvons tenter d'arrêter les services via la commande `sc stop <service name>`. Essayons à nouveau l'exemple précédent avec des permissions élevées en tant qu'utilisateur `Administrator`.

#### Arrêter un service avec des privilèges élevés en tant qu'Administrateur

        cmd
`C:\WINDOWS\system32> sc stop windefend  Access is denied.`

Il semble que nous n'ayons toujours pas l'accès approprié pour arrêter ce service en particulier. C'est une bonne leçon à apprendre, car certains processus sont protégés par des exigences d'accès plus strictes que celles des comptes d'administrateur local. Dans ce scénario, la seule entité qui peut arrêter et démarrer le service Defender est le compte machine [SYSTEM](https://learn.microsoft.com/en-us/windows/security/identity-protection/access-control/local-accounts#default-local-system-accounts).

En tant qu'attaquant, il est très important d'apprendre les restrictions derrière ce à quoi certains comptes ont ou n'ont pas accès, car essayer aveuglément d'arrêter des services remplira les journaux d'erreurs et déclenchera toutes les alertes indiquant qu'un utilisateur aux privilèges insuffisants tente d'accéder à un processus protégé sur le système. Cela attirera l'attention de l'équipe bleue (`blue team`) sur nos activités, qui entamera une tentative de triage pour nous expulser du système et nous bloquer définitivement.

#### Arrêter des services

Passons à autre chose, trouvons un service que nous pouvons arrêter en tant qu'Administrateur. La bonne nouvelle est que nous pouvons arrêter le service Spouleur d'impression. Essayons de le faire.

#### Trouver le service Spouleur d'impression

        cmd
`C:\WINDOWS\system32> sc query Spooler  SERVICE_NAME: Spooler         TYPE               : 110  WIN32_OWN_PROCESS  (interactive)         STATE              : 4  RUNNING                                 (STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0`

Comme nous pouvons le voir dans la sortie ci-dessus, le service `Spooler` est en cours d'exécution sur notre système actuel.

#### Arrêter le service Spouleur d'impression

        cmd
`C:\WINDOWS\system32> sc stop Spooler  SERVICE_NAME: Spooler         TYPE               : 110  WIN32_OWN_PROCESS  (interactive)         STATE              : 3  STOP_PENDING                                 (NOT_STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x3         WAIT_HINT          : 0x4e20  C:\WINDOWS\system32> sc query Spooler  SERVICE_NAME: Spooler         TYPE               : 110  WIN32_OWN_PROCESS  (interactive)         STATE              : 1  STOPPED         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0`

Comme indiqué ci-dessus, nous pouvons exécuter la commande `sc stop Spooler` pour que Windows envoie une requête de contrôle `STOP` au service. Il est important de noter que tous les services ne répondront pas à ces requêtes, quelles que soient nos permissions, surtout si d'autres programmes et services en cours d'exécution dépendent du service que nous tentons d'arrêter.

#### Démarrer des services

Tout comme pour l'arrêt des services, nous sommes également capables de démarrer des services. Bien que l'arrêt des services semble offrir un peu plus d'aspect pratique au premier abord à l'équipe rouge (`red team`), être capable de démarrer des services peut s'avérer particulièrement utile en conjonction avec la capacité de modifier les services existants.

En partant de notre exemple précédent, nous travaillons toujours avec le service `Spooler` qui a été arrêté précédemment. Nous pouvons redémarrer ce service en exécutant la commande `sc start Spooler`. Essayons maintenant.

#### Démarrer le service Spouleur d'impression

        cmd
`C:\WINDOWS\system32> sc start Spooler  SERVICE_NAME: Spooler         TYPE               : 110  WIN32_OWN_PROCESS  (interactive)         STATE              : 2  START_PENDING                                 (NOT_STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x7d0         PID                : 34908         FLAGS              :  C:\WINDOWS\system32> sc query Spooler  SERVICE_NAME: Spooler         TYPE               : 110  WIN32_OWN_PROCESS  (interactive)         STATE              : 4  RUNNING                                 (STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0`

Nous pouvons voir ici qu'après avoir envoyé une requête de démarrage au service `Spooler`, il commence dans un état `START_PENDING` et, après une autre requête, il est entièrement opérationnel. Généralement, les services mettent quelques secondes à s'initialiser après qu'une requête de démarrage a été émise.

---

## Modifier les Services

En plus de pouvoir démarrer et arrêter des services, nous pouvons également tenter de modifier des services existants. C'est là que les attaquants peuvent prospérer en essayant de modifier les services existants pour servir n'importe quel objectif dont ils ont besoin. Dans certains cas, nous pouvons les modifier pour qu'ils soient désactivés au démarrage ou modifier le chemin d'accès du service vers le binaire lui-même. Sachez que ces exemples ne sont que quelques-unes des possibilités d'actions que nous pouvons entreprendre. Avec une commande aussi polyvalente, nous avons de nombreuses options pour manipuler les services afin qu'ils fassent tout ce dont nous avons besoin. Voyons si nous pouvons modifier certains services pour empêcher Windows de se mettre à jour.

#### Désactiver les mises à jour Windows avec SC

Pour configurer les services, nous devons utiliser le paramètre [config](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sc-config) dans `sc`. Cela nous permettra de modifier les valeurs des services existants, qu'ils soient en cours d'exécution ou non. Toutes les modifications effectuées avec cette commande sont répercutées dans le registre Windows ainsi que dans la base de données du Gestionnaire de Contrôle des Services (Service Control Manager, `SCM`). N'oubliez pas que toutes les modifications apportées aux services existants ne seront entièrement prises en compte qu'après le redémarrage du service.

**Note :** Il est important de savoir que la modification de services existants peut les désactiver de manière permanente, car toutes les modifications effectuées sont enregistrées dans le registre, ce qui peut persister au redémarrage. Veuillez faire preuve de prudence lorsque vous modifiez des services de cette manière.

Maintenant que nous avons toutes ces informations, essayons de désactiver les mises à jour Windows pour notre hôte compromis actuel.

Malheureusement, la fonctionnalité Windows Update (`Version 10 et supérieures`) ne repose pas sur un seul service pour fonctionner. Les mises à jour Windows dépendent des services suivants :

|Service|Nom d'affichage|
|---|---|
|`wuauserv`|Service Windows Update|
|`bits`|Service de transfert intelligent en arrière-plan|

Interrogeons tous les services requis et voyons ce qui est actuellement en cours d'exécution et doit être arrêté avant d'apporter les modifications nécessaires.

#### Vérifier l'état des services requis

        cmd
`C:\WINDOWS\system32> sc query wuauserv  SERVICE_NAME: wuauserv         TYPE               : 30  WIN32         STATE              : 1  STOPPED         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0  C:\WINDOWS\system32> sc query bits  SERVICE_NAME: bits         TYPE               : 30  WIN32         STATE              : 4  RUNNING                                 (STOPPABLE, NOT_PAUSABLE, ACCEPTS_PRESHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x0         WAIT_HINT          : 0x0`

D'après les informations fournies ci-dessus, nous pouvons voir que le service `wuauserv` n'est pas actuellement actif, car le système n'est pas en train de se mettre à jour. Cependant, le service `bits` (nécessaire pour télécharger les mises à jour) est en cours d'exécution sur notre système. Nous pouvons envoyer un ordre d'arrêt à ce service en utilisant nos connaissances de la section précédente en procédant comme suit :

#### Arrêter BITS

        cmd
`C:\WINDOWS\system32> sc stop bits  SERVICE_NAME: bits         TYPE               : 30  WIN32         STATE              : 3  STOP_PENDING                                 (NOT_STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)         WIN32_EXIT_CODE    : 0  (0x0)         SERVICE_EXIT_CODE  : 0  (0x0)         CHECKPOINT         : 0x1         WAIT_HINT          : 0x0`

Après nous être assurés que les deux services sont actuellement arrêtés, nous pouvons modifier le type de démarrage (`start type`) des deux services. Nous pouvons effectuer ce changement en procédant comme suit :

#### Désactiver le service Windows Update

        cmd
`C:\WINDOWS\system32> sc config wuauserv start= disabled  [SC] ChangeServiceConfig SUCCESS`

#### Désactiver le service de transfert intelligent en arrière-plan

        cmd
`C:\WINDOWS\system32> sc config bits start= disabled  [SC] ChangeServiceConfig SUCCESS`

Nous pouvons voir la confirmation que les deux services ont été modifiés avec succès. Cela signifie que lorsque les deux services tenteront de démarrer, ils ne le pourront pas car ils sont actuellement désactivés. Comme mentionné précédemment, ce changement persistera au redémarrage, ce qui signifie que lorsque le système tentera de rechercher des mises à jour ou de se mettre à jour, il ne pourra pas le faire car les deux services resteront désactivés. Nous pouvons vérifier que les deux services sont bien désactivés en essayant de les démarrer.

#### Vérifier que les services sont désactivés

        cmd
`C:\WINDOWS\system32> sc start wuauserv  [SC] StartService FAILED 1058:  The service cannot be started, either because it is disabled or because it has no enabled devices associated with it.  C:\WINDOWS\system32> sc start bits  [SC] StartService FAILED 1058:  The service cannot be started, either because it is disabled or because it has no enabled devices associated with it.`

**Note :** Pour revenir à la normale, vous pouvez définir `start= auto` pour vous assurer que les services peuvent être redémarrés et fonctionner correctement.

Nous avons vérifié que les deux services sont maintenant désactivés, car nous ne pouvons pas les démarrer manuellement. En raison des modifications apportées ici, Windows ne peut pas utiliser sa fonction de mise à jour pour fournir des mises à jour système ou de sécurité. Cela peut être très bénéfique pour un attaquant afin de s'assurer qu'un système reste obsolète et ne récupère aucune mise à jour qui empêcherait l'utilisation de certains exploits sur un système cible. Sachez qu'en procédant de cette manière, nous déclencherons probablement des alertes pour ce type d'action mises en place par l'équipe bleue résidente. Cette méthode n'est pas silencieuse et nécessite dans de nombreux cas des permissions élevées pour être exécutée.

---

## Autres méthodes pour interroger les services

Au cours de cette section, nous nous sommes uniquement concentrés sur l'utilisation de `sc` pour interroger, démarrer, arrêter et modifier les services. Cependant, nous avons d'autres choix pour accomplir certaines de ces mêmes tâches en utilisant des commandes différentes. Dans cette section, nous nous concentrerons strictement sur l'utilisation de certaines de ces autres commandes pour nous aider dans notre énumération en étant capables d'interroger les services et d'afficher les informations disponibles de différentes manières.

#### Utiliser Tasklist

[Tasklist](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tasklist) est un outil en ligne de commande qui nous donne une liste des processus en cours d'exécution sur un hôte local ou distant. Cependant, nous pouvons utiliser le paramètre `/svc` pour fournir une liste des services s'exécutant sous chaque processus du système. Examinons une partie de la sortie que cela peut fournir.

        cmd
`C:\htb> tasklist /svc   Image Name                     PID Services ========================= ======== ============================================ System Idle Process              0 N/A System                           4 N/A Registry                       108 N/A smss.exe                       412 N/A csrss.exe                      612 N/A wininit.exe                    684 N/A csrss.exe                      708 N/A services.exe                   768 N/A lsass.exe                      796 KeyIso, SamSs, VaultSvc winlogon.exe                   856 N/A svchost.exe                    984 BrokerInfrastructure, DcomLaunch, PlugPlay,                                    Power, SystemEventsBroker fontdrvhost.exe               1012 N/A fontdrvhost.exe               1020 N/A svchost.exe                    616 RpcEptMapper, RpcSs svchost.exe                    996 LSM dwm.exe                       1068 N/A svchost.exe                   1236 CoreMessagingRegistrar svchost.exe                   1244 lmhosts svchost.exe                   1324 NcbService svchost.exe                   1332 TimeBrokerSvc svchost.exe                   1352 Schedule <SNIP>`

Comme nous pouvons le voir, nous avons une liste complète des processus en cours d'exécution sur le système, leur `PID` respectif, et quel(s) service(s) sont hébergés sous chaque processus. Cela peut être très utile pour localiser rapidement quel processus héberge quel(s) service(s).

#### Utiliser Net Start

[Net start](https://ss64.com/nt/net-service.html) est une commande très simple qui nous permettra de lister rapidement tous les services en cours d'exécution sur un système. En plus de `net start`, il y a aussi `net stop`, `net pause` et `net continue`. Celles-ci se comporteront de manière très similaire à `sc`, car nous pouvons fournir le nom du service après la commande et être en mesure d'effectuer les actions spécifiées dans la commande contre le service que nous fournissons.

        cmd
`C:\htb> net start  These Windows services are started:     Application Information    AppX Deployment Service (AppXSVC)    AVCTP service    Background Tasks Infrastructure Service    Base Filtering Engine    BcastDVRUserService_3321a    Capability Access Manager Service    cbdhsvc_3321a    CDPUserSvc_3321a    Client License Service (ClipSVC)    CNG Key Isolation    COM+ Event System    COM+ System Application    Connected Devices Platform Service    Connected User Experiences and Telemetry    CoreMessaging    Credential Manager    Cryptographic Services    Data Usage    DCOM Server Process Launcher    Delivery Optimization    Device Association Service    DHCP Client    <SNIP>`

D'après la sortie ci-dessus, nous pouvons voir que l'utilisation de `net start` sans spécifier de `service` listera tous les services actifs sur le système.

#### Utiliser WMIC

Enfin, et ce n'est pas le moindre, nous avons [WMIC](https://ss64.com/nt/wmic.html). La commande Windows Management Instrumentation (`WMIC`) nous permet de récupérer une vaste gamme d'informations depuis notre hôte local ou des hôtes sur le réseau. La polyvalence de cette commande est grande en ce qu'elle permet d'extraire un large éventail d'informations. Cependant, nous n'aborderons qu'un très petit sous-ensemble des fonctionnalités fournies par le composant `SERVICE` résidant dans cette application.

Pour lister tous les services existants sur notre système et leurs informations, nous pouvons exécuter la commande suivante : `wmic service list brief` .

        cmd
`C:\htb> wmic service list brief  ExitCode  Name                                      ProcessId  StartMode  State    Status 1077      AJRouter                                  0          Manual     Stopped  OK 1077      ALG                                       0          Manual     Stopped  OK 1077      AppIDSvc                                  0          Manual     Stopped  OK 0         Appinfo                                   5016       Manual     Running  OK 1077      AppMgmt                                   0          Manual     Stopped  OK 1077      AppReadiness                              0          Manual     Stopped  OK 1077      AppVClient                                0          Disabled   Stopped  OK 0         AppXSvc                                   9996       Manual     Running  OK 1077      AssignedAccessManagerSvc                  0          Manual     Stopped  OK 0         AudioEndpointBuilder                      2076       Auto       Running  OK 0         Audiosrv                                  2332       Auto       Running  OK 1077      autotimesvc                               0          Manual     Stopped  OK 1077      AxInstSV                                  0          Manual     Stopped  OK 1077      BDESVC                                    0          Manual     Stopped  OK 0         BFE                                       2696       Auto       Running  OK 0         BITS                                      0          Manual     Stopped  OK 0         BrokerInfrastructure                      984        Auto       Running  OK 1077      BTAGService                               0          Manual     Stopped  OK 0         BthAvctpSvc                               4448       Manual     Running  OK 1077      bthserv                                   0          Manual     Stopped  OK 0         camsvc                                    5676       Manual     Running  OK 0         CDPSvc                                    4724       Auto       Running  OK 1077      CertPropSvc                               0          Manual     Stopped  OK 0         ClipSVC                                   9156       Manual     Running  OK 1077      cloudidsvc                                0          Manual     Stopped  OK 0         COMSysApp                                 3668       Manual     Running  OK 0         CoreMessagingRegistrar                    1236       Auto       Running  OK 0         CryptSvc                                  2844       Auto       Running  OK <SNIP>`

Après cela, nous pouvons voir que nous avons une belle liste contenant des informations importantes telles que le `Name`, `ProcessID`, `StartMode`, `State` et `Status` de chaque service sur le système, qu'il soit en cours d'exécution ou non.

**Note :** Il est important de savoir que l'utilitaire en ligne de commande `WMIC` est actuellement obsolète depuis la version actuelle de Windows. En tant que tel, il est déconseillé de se fier à cet utilitaire dans la plupart des situations. Vous pouvez trouver plus d'informations concernant ce changement en suivant ce [lien](https://learn.microsoft.com/en-us/windows/win32/wmisdk/wmic).

---

## Pour aller plus loin

En tant que testeurs d'intrusion (`penetration testers`), nous interagirons constamment avec les services Windows. Comme nous n'aurons pas toujours un accès par interface graphique (GUI) à un hôte sur lequel nous essayons d'élever nos privilèges, nous devons comprendre comment travailler avec les services via la ligne de commande de diverses manières. Dans une section ultérieure, nous passerons en revue les équivalents PowerShell des commandes présentées dans cette section et montrerons une approche plus orientée équipe bleue pour travailler avec et surveiller les services. Maintenant que nous avons fini de parler de la gestion des services via cmd.exe, plongeons dans le sujet très important des Tâches Planifiées de Windows.

LAB de fin 

![[Pasted image 20260831023817.png]]

rep : sc stop red-light 


![[Pasted image 20260831023918.png]]
rep : sc 

