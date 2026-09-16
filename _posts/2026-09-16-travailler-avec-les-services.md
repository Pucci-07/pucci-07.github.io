[[Command Prompt Basics]]

Dans notre section précédente, nous avons abordé le filtrage et le pipeline en utilisant un exemple de recherche de services sur l'hôte du point de vue d'un pentester. Dans cette section, nous allons approfondir ce sujet et inverser la perspective. Nous allons l'examiner du point de vue d'un administrateur.

**Scénario :** M. Tanaka a contacté le Helpdesk pour signaler qu'une fenêtre était apparue plus tôt dans la journée. Il pensait qu'il s'agissait simplement de mises à jour Windows, car de nombreuses informations défilaient rapidement dans la fenêtre. Cependant, il signale maintenant que des alertes indiquant que Defender est désactivé sont également apparues et que son hôte est lent. Nous devons examiner cela, déterminer quels services liés à Defender sont désactivés et les réactiver si possible. Plus tard, nous examinerons les journaux d'événements pour voir ce qui s'est passé.

L'administration des services est cruciale pour la gestion des hôtes et pour garantir que notre posture de sécurité reste inchangée. Cette section expliquera comment interroger, démarrer, arrêter et modifier les services et leurs autorisations selon les besoins. Nous aborderons également les moyens d'interagir avec eux localement et à distance. Il est temps de plonger dans le vif du sujet et d'obtenir notre prochaine ceinture de Kung-Fu en CLI.

---

## Que sont les services et comment interagissons-nous avec eux en utilisant PowerShell ?

Dans le système d'exploitation Windows, les services sont essentiellement des instances uniques d'un composant s'exécutant en arrière-plan qui gère et maintient les processus et autres composants nécessaires aux applications utilisées sur l'hôte. Les services ne nécessitent généralement aucune interaction de la part de l'utilisateur et n'ont pas d'interface tangible avec laquelle il peut interagir. Ils existent également en tant qu'instance unique du service sur l'hôte, tandis qu'un service peut gérer plusieurs instances d'un processus. Un processus peut être considéré comme un conteneur temporaire permettant à un utilisateur ou à une application d'effectuer des tâches. Windows dispose de trois catégories de services : les services locaux, les services réseau et les services système. De nombreux services différents (y compris les composants principaux du système d'exploitation Windows) gèrent simultanément plusieurs instances de processus. PowerShell nous fournit le module `Microsoft.PowerShell.Management`, qui contient plusieurs cmdlets pour interagir avec les services. Comme pour tout dans PowerShell, si vous ne savez pas par où commencer ou de quelle cmdlet vous avez besoin, profitez de l'aide intégrée pour vous aider à démarrer.

#### Obtenir de l'aide (Services)

        powershell
`PS C:\htb> Get-Help *-Service    Name                              Category  Module                    Synopsis ----                              --------  ------                    -------- Get-Service                       Cmdlet    Microsoft.PowerShell.Man… … New-Service                       Cmdlet    Microsoft.PowerShell.Man… … Remove-Service                    Cmdlet    Microsoft.PowerShell.Man… … Restart-Service                   Cmdlet    Microsoft.PowerShell.Man… … Resume-Service                    Cmdlet    Microsoft.PowerShell.Man… … Set-Service                       Cmdlet    Microsoft.PowerShell.Man… … Start-Service                     Cmdlet    Microsoft.PowerShell.Man… … Stop-Service                      Cmdlet    Microsoft.PowerShell.Man… … Suspend-Service                   Cmdlet    Microsoft.PowerShell.Man… …`

Maintenant, commençons notre triage de l'hôte de M. Tanaka pour voir ce qui se passe.

**Note :** Gardez à l'esprit que pour gérer ou modifier des services au-delà de l'exécution de requêtes, nous devrons disposer des autorisations nécessaires. Cela signifie que notre utilisateur doit idéalement être un administrateur local sur l'hôte ou avoir reçu les autorisations des groupes de domaine dont il est membre. Ouvrir PowerShell dans un contexte administratif fonctionnerait également.

---

### Examiner les services en cours d'exécution

Nous devons d'abord obtenir une liste rapide des services en cours d'exécution sur notre hôte cible. Les services peuvent avoir un statut défini sur `Running`, `Stopped` ou `Paused` et peuvent être configurés pour démarrer manuellement (interaction de l'utilisateur), automatiquement (au démarrage du système) ou avec un délai après le démarrage du système. Les utilisateurs disposant de privilèges administratifs peuvent généralement créer, modifier et supprimer des services. Les mauvaises configurations des autorisations de service sont un vecteur courant d'escalade de privilèges (privilege escalation) sur les systèmes Windows.

#### Get-Service

        powershell
`PS C:\htb> Get-Service | ft DisplayName,Status   DisplayName                                                                         Status -----------                                                                         ------  Adobe Acrobat Update Service                                                       Running OpenVPN Agent agent_ovpnconnect                                                    Running Adobe Genuine Monitor Service                                                      Running Adobe Genuine Software Integrity Service                                           Running Application Layer Gateway Service                                                  Stopped Application Identity                                                               Stopped Application Information                                                            Running Application Management                                                             Stopped App Readiness                                                                      Stopped Microsoft App-V Client                                                             Stopped AppX Deployment Service (AppXSVC)                                                  Running AssignedAccessManager Service                                                      Stopped Windows Audio Endpoint Builder                                                     Running Windows Audio                                                                      Running ActiveX Installer (AxInstSV)                                                       Stopped GameDVR and Broadcast User Service_172433                                          Stopped BitLocker Drive Encryption Service                                                 Running Base Filtering Engine                                                              Running <SNIP>   PS C:\htb> Get-Service | measure    Count             : 321`

Pour rendre l'exécution un peu plus claire, nous avons redirigé notre liste de services vers `format-table` et choisi les propriétés `DisplayName` et `Status` à afficher dans notre console. Lors de la deuxième commande exécutée, nous avons mesuré le nombre de services qui apparaissent dans la liste juste pour avoir une idée du nombre avec lequel nous travaillons. `321` services, c'est beaucoup à parcourir et à gérer en une seule fois, nous devons donc réduire un peu plus la liste. D'après la demande de M. Tanaka, il a mentionné un problème potentiel avec Windows Defender, alors filtrons tous les services qui n'y sont pas liés.

#### Examen précis de Defender

        powershell
`PS C:\htb> Get-Service | where DisplayName -like '*Defender*' | ft DisplayName,ServiceName,Status  DisplayName                                             ServiceName  Status -----------                                             -----------  ------ Windows Defender Firewall                               mpssvc      Running Windows Defender Advanced Threat Protection Service     Sense       Stopped Microsoft Defender Antivirus Network Inspection Service WdNisSvc    Running Microsoft Defender Antivirus Service                    WinDefend   Stopped`

Nous pouvons maintenant voir uniquement les services liés à `Defender`, et nous constatons que pour une raison quelconque, le service Antivirus Microsoft Defender (`WinDefend`) est bien désactivé. Pour l'instant, afin d'assurer la protection de l'hôte de M. Tanaka, essayons de le réactiver à l'aide de la cmdlet Start-Service.

#### Reprendre / Démarrer / Redémarrer un service

        powershell
`PS C:\htb> Start-Service WinDefend`

Puisque nous avons exécuté la cmdlet `Start-Service`, tant que nous n'avons pas reçu de message d'erreur comme `"ParserError: This script contains malicious content and has been blocked by your antivirus software."` ou autres, la commande s'est exécutée avec succès. Nous pouvons vérifier à nouveau en interrogeant le service.

#### Vérification de notre travail

        powershell
`PS C:\htb>  get-service WinDefend  Status   Name               DisplayName ------   ----               ----------- Running  WinDefend          Microsoft Defender Antivirus Service`

Notez comment nous avons utilisé le `Name` du service pour démarrer et interroger le service au lieu de quoi que ce soit dans le DisplayName. Pour l'instant, Defender est de nouveau opérationnel, la première mission est donc accomplie. Pendant que nous sommes ici, jetons un coup d'œil pour voir ce qui se passe d'autre. En parcourant un peu plus les services pour voir ce qui s'y trouve, nous remarquons un service avec un DisplayName étrange.

        powershell
`PS C:\htb> get-service   Stopped  SmsRouter          Microsoft Windows SMS Router Service. Stopped  SNMPTrap           SNMP Trap Stopped  spectrum           Windows Perception Service Running  Spooler            Totally still used for Print Spooli... Stopped  sppsvc             Software Protection Running  SSDPSRV            SSDP Discovery`

Nous ne trouvons aucune information sur ce service particulier, et le fait que son DisplayName ait été modifié est étrange. Par mesure de sécurité, nous allons donc arrêter le service pour le moment et laisser un membre de notre équipe de sécurité l'examiner.

#### Arrêter un service

        powershell
`PS C:\htb> Stop-Service Spooler   PS C:\htb> Get-Service Spooler   Status   Name               DisplayName ------   ----               ----------- Stopped  spooler            Totally still used for Print Spooli...`

Nous pouvons maintenant voir qu'en utilisant Stop-Service, nous avons arrêté l'état de fonctionnement du service `Spooler`. Maintenant que nous avons arrêté le service, définissons son type de démarrage de Automatique à Désactivé jusqu'à ce qu'une enquête plus approfondie puisse être menée.

#### Set-Service

        powershell
`PS C:\htb> get-service spooler | Select-Object -Property Name, StartType, Status, DisplayName  Name    StartType  Status DisplayName ----    ---------  ------ ----------- spooler Automatic Stopped Totally still used for Print Spooling...   PS C:\htb> Set-Service -Name Spooler -StartType Disabled  PS C:\htb> Get-Service -Name Spooler | Select-Object -Property StartType   StartType ---------  Disabled`

Ok, maintenant notre service Spooler a été arrêté et son démarrage est passé à Désactivé pour le moment. La modification d'un service en cours d'exécution est raisonnablement simple. Assurez-vous que si vous tentez d'apporter des modifications, vous êtes un administrateur de l'hôte ou du domaine. La suppression de services dans PowerShell est actuellement difficile. La cmdlet `Remove-Service` ne fonctionne que si vous utilisez PowerShell version 7. Par défaut, nos hôtes ouvriront et exécuteront PowerShell version 5.1. Pour l'instant, si vous souhaitez supprimer un service et ses entrées, utilisez l'outil `sc.exe`.

---

## Comment interagir avec les services distants en utilisant PowerShell ?

Maintenant que nous savons comment travailler avec les services, voyons comment nous pouvons interagir avec les hôtes distants. Puisque l'hôte de M. Tanaka est dans un domaine, nous pouvons facilement interroger et vérifier les services en cours d'exécution sur d'autres hôtes. Le paramètre `-ComputerName` nous permet de spécifier que nous voulons interroger un hôte distant.

#### Interroger les services à distance

        powershell
`PS C:\htb> get-service -ComputerName ACADEMY-ICL-DC  Status   Name               DisplayName ------   ----               ----------- Running  ADWS               Active Directory Web Services Stopped  AppIDSvc           Application Identity Stopped  AppMgmt            Application Management Stopped  AppReadiness       App Readiness Stopped  AppXSvc            AppX Deployment Service (AppXSVC) Running  BFE                Base Filtering Engine Stopped  BITS               Background Intelligent Transfer Ser... <SNIP>`  

#### Filtrer notre sortie

        powershell
`PS C:\htb> Get-Service -ComputerName ACADEMY-ICL-DC | Where-Object {$_.Status -eq "Running"}  Status   Name               DisplayName ------   ----               ----------- Running  ADWS               Active Directory Web Services Running  BFE                Base Filtering Engine Running  COMSysApp          COM+ System Application Running  CoreMessagingRe... CoreMessaging Running  CryptSvc           Cryptographic Services Running  DcomLaunch         DCOM Server Process Launcher Running  Dfs                DFS Namespace Running  DFSR               DFS Replication`

Une chose intéressante à noter ici est que, puisque PowerShell traite tout comme un `objet`, même la sortie d'une commande distante, nous pouvons utiliser le pipeline PowerShell pour disséquer les propriétés d'un objet avec `Where-Object`. Nos résultats n'ont renvoyé que les services dont le statut était `Running` au moment de l'exécution. Nous pouvons utiliser ces combinaisons pour un grand nombre de choses. Un excellent exemple serait d'interroger nos hôtes pour une propriété spécifique, comme si le statut était `Running`, si un `DisplayName` est défini sur quelque chose de spécifique, etc. En ce qui concerne les interactions à distance, nous pouvons également utiliser la cmdlet `Invoke-Command`. Essayons d'interroger plusieurs hôtes et de voir le statut du service `UserManager`.

### Invoke-Command

        powershell
`PS C:\htb> invoke-command -ComputerName ACADEMY-ICL-DC,LOCALHOST -ScriptBlock {Get-Service -Name 'windefend'}  Status   Name               DisplayName                            PSComputerName ------   ----               -----------                            -------------- Running  windefend          Microsoft Defender Antivirus Service   LOCALHOST Running  windefend          Windows Defender Antivirus Service     ACADEMY-ICL-DC`

Décortiquons cela maintenant :

- `Invoke-Command` : Nous indiquons à PowerShell que nous voulons exécuter une commande sur un ordinateur local ou distant.
- `Computername` : Nous fournissons une liste de noms d'ordinateurs à interroger, séparés par des virgules.
- `ScriptBlock {commandes à exécuter}` : Cette partie est la commande encapsulée que nous voulons exécuter sur l'ordinateur. Pour qu'elle s'exécute, elle doit être enclose entre {}.

Interagir avec les hôtes de cette manière peut accélérer considérablement notre travail.

**Scénario :** Plus tôt dans cette section, nous avons vu un service (Spooler) dont le DisplayName avait été modifié. Cela pourrait potentiellement nous indiquer un problème dans notre environnement. Utiliser le paramètre `-ComputerName` ou la cmdlet Invoke-Command pour interroger tous les hôtes de notre environnement et vérifier les propriétés DisplayName pour voir si un autre hôte a été affecté. En tant qu'administrateur, avoir accès à ce genre de puissance est inestimable et peut souvent aider à réduire le temps qu'une menace passe sur l'hôte, à anticiper le problème et à œuvrer pour expulser la menace.

---

Comprendre les services et les gérer sur un hôte est essentiel du point de vue de l'administrateur et du pentester. Nous pouvons faire beaucoup de choses avec eux, de l'escalade de privilèges à la persistance, et plus encore. En passant à notre section suivante, nous présenterons le Registre Windows et comment interagir avec lui sur un hôte Windows.

LAB de fin 

![Pasted image 20260903155352.png](/assets/img/writeups/Pasted image 20260903155352.png)
rep : get-service 

![Pasted image 20260903155627.png](/assets/img/writeups/Pasted image 20260903155627.png)
rep : start service windefender

![Pasted image 20260903155710.png](/assets/img/writeups/Pasted image 20260903155710.png)
Rep : Invoke-Command


