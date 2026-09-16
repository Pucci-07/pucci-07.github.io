# CMD vs PowerShell

---

Jusqu'à présent, nous avons abordé l'interpréteur de ligne de commande Windows intégré `cmd.exe`. À partir de maintenant, nous allons nous pencher sur le successeur moderne de CMD sous Windows, [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.2). Cette section expliquera ce qu'est PowerShell, les différences entre PowerShell et CMD, comment obtenir de l'aide dans le CLI (interface en ligne de commande), et la navigation de base dans le CLI.

---

## Différences

PowerShell et CMD sont inclus nativement sur tout hôte Windows, on peut donc se demander : « Pourquoi utiliser l'un plutôt que l'autre ? ». Répondons rapidement à cette question. Vous trouverez ci-dessous un tableau présentant quelques différences entre PowerShell et CMD.

#### Comparaison de PowerShell et CMD

|**Caractéristique**|**CMD**|**PowerShell**|
|---|---|---|
|Langage|Uniquement les commandes Batch et CMD de base.|PowerShell peut interpréter les commandes Batch, CMD, les cmdlets PS et les alias.|
|Utilisation des commandes|La sortie d'une commande ne peut pas être transmise directement à une autre en tant qu'objet structuré, en raison de la limitation du traitement de la sortie texte.|La sortie d'une commande peut être transmise directement à une autre en tant qu'objet structuré, ce qui permet des commandes plus sophistiquées.|
|Sortie de la commande|Texte uniquement.|PowerShell produit des sorties au format objet.|
|Exécution parallèle|CMD doit terminer une commande avant d'en exécuter une autre.|PowerShell peut exécuter des commandes en parallèle grâce au multithreading.|

Plus particulièrement, PowerShell a été conçu pour être `extensible` et pour s'intégrer à de nombreux autres outils et fonctionnalités selon les besoins. La plupart le considèrent comme un simple CLI, mais c'est bien plus que cela. Saviez-vous que c'est aussi un `langage de script` ? Alors que CMD a été l'interpréteur de ligne de commande par défaut uniquement pour les hôtes Windows, PowerShell a été publié en tant que [projet open-source](https://github.com/PowerShell/PowerShell) et dispose d'une vaste gamme de capacités qui permettent également son utilisation avec des systèmes basés sur Linux. L'utilisation du framework `.NET` a également permis à PowerShell d'utiliser un modèle d'interaction et de sortie basé sur des objets au lieu d'un modèle basé uniquement sur du texte.

### Pourquoi choisir PowerShell plutôt que cmd.exe ?

`Pourquoi PowerShell est-il important pour les administrateurs informatiques, les professionnels de l'infosec offensif et défensif ?`

[PowerShell](https://docs.microsoft.com/en-us/powershell/) est devenu de plus en plus important parmi les professionnels de l'informatique et de l'infosec. Il est largement utilisé par les Administrateurs Système, les Pentesters, les Analystes SOC, et dans de nombreuses autres disciplines techniques où des systèmes Windows sont administrés. Pensez aux administrateurs informatiques et aux administrateurs système Windows qui gèrent des environnements informatiques composés de serveurs Windows, de postes de travail (Windows 10 & 11), d'Azure et d'applications cloud Microsoft 365. Beaucoup d'entre eux utilisent PowerShell pour automatiser les tâches qu'ils doivent accomplir quotidiennement. Parmi ces tâches, on trouve :

- Provisionnement de serveurs et installation de rôles de serveur
- Création de comptes d'utilisateurs Active Directory pour les nouveaux employés
- Gestion des permissions des groupes Active Directory
- Désactivation et suppression de comptes d'utilisateurs Active Directory
- Gestion des permissions de partage de fichiers
- Interaction avec [Azure](https://azure.microsoft.com/en-us/) AD et les VM Azure
- Création, suppression et surveillance de répertoires et de fichiers
- Collecte d'informations sur les postes de travail et les serveurs
- Configuration des boîtes de réception e-mail Microsoft Exchange pour les utilisateurs (dans le cloud et/ou sur site)

Il existe d'innombrables façons d'utiliser PowerShell dans un contexte d'administration informatique, et être conscient de ce contexte peut être utile pour nous en tant que `pentesters` et même en tant que `défenseurs`. En tant qu'administrateur système, PowerShell peut nous offrir beaucoup plus de capacités que `CMD`. Il est `extensible`, conçu pour l'`automatisation` et le scripting, dispose d'une implémentation de sécurité beaucoup plus robuste et peut gérer de nombreuses tâches différentes que CMD ne peut tout simplement pas accomplir. En tant que pentester, de nombreuses fonctionnalités bien connues sont intégrées à PowerShell. La capacité d'importation de modules de PowerShell facilite l'introduction de nos outils dans l'environnement et garantit leur bon fonctionnement. Cependant, d'un point de vue de la furtivité, la capacité de `journalisation` et d'`historique` de PowerShell est puissante et enregistrera davantage de nos interactions avec l'hôte. Donc, si nous n'avons pas besoin des capacités de PowerShell et que nous souhaitons être plus furtifs, nous devrions utiliser CMD.

---

## Appeler PowerShell

Nous pouvons accéder à PowerShell directement sur un hôte via les périphériques connectés à la machine locale ou via RDP sur le réseau par diverses méthodes.

1. Utiliser la `Recherche` Windows

Nous pouvons taper `PowerShell` dans la recherche Windows pour trouver et lancer l'application PowerShell et la console de commande.

![GIF montrant la fonctionnalité de recherche et l'ouverture de PowerShell.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/SearchingForPowerShell.gif)

2. Utiliser l'application `Terminal` Windows

[Windows Terminal](https://github.com/Microsoft/Terminal) est une application d'émulateur de terminal plus récente développée par Microsoft pour permettre à quiconque utilisant la ligne de commande Windows d'accéder à plusieurs interfaces de ligne de commande, systèmes et sous-systèmes différents via une seule application. Cette application deviendra probablement l'émulateur de terminal par défaut sur les systèmes d'exploitation Windows. ![GIF montrant le terminal et le basculement entre PowerShell et l'Invite de commandes.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/PowerShellinWindowsTerminal.gif)

3. Utiliser `Windows PowerShell ISE`

L'[Environnement de script intégré (ISE) Windows PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/introducing-the-windows-powershell-ise?view=powershell-7.2) est comme un IDE pour PowerShell. Il peut faciliter le développement, le débogage et le test des scripts PowerShell que nous créons. L'utilisation de PowerShell ISE peut être incroyablement utile lors de l'apprentissage de PowerShell.

![GIF montrant le démarrage de Windows PowerShell ISE via la fonctionnalité de recherche.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/PowerShellISE.gif)

4. Utiliser PowerShell dans `CMD`

Nous pouvons également lancer PowerShell depuis CMD. Cette action peut sembler anodine, mais il arrivera sans aucun doute un moment où nous pourrons obtenir un shell sur le CLI d'une cible Windows vulnérable via CMD et où il sera avantageux d'essayer d'utiliser PowerShell pour étendre notre accès sur l'hôte et sur le réseau.

![GIF montrant l'Invite de commandes et le lancement de PowerShell à l'intérieur avec la commande powershell.exe.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/LaunchingPowerShellfromCMD.gif)

### Un coup d'œil au Shell

L'une des premières choses que nous pouvons examiner en accédant à PowerShell sur un système local ou distant est l'invite de commandes.

## Invite de commandes PowerShell

        powershell
`PS C:\Users\htb-student> ipconfig   Ethernet adapter VMware Network Adapter VMnet8:     Connection-specific DNS Suffix  . :    Link-local IPv6 Address . . . . . : fe80::adb8:3c9:a8af:114%25    IPv4 Address. . . . . . . . . . . : 172.16.110.1    Subnet Mask . . . . . . . . . . . : 255.255.255.0    Default Gateway . . . . . . . . . :`

L'invite de commandes est presque identique à ce que nous voyons dans CMD.

- `PS` est l'abréviation de PowerShell, suivi du répertoire de travail actuel `C:\Users\htb-student>`.
- Ceci est suivi par le cmdlet ou la chaîne que nous voulons exécuter, `ipconfig`.
- Enfin, en dessous, nous voyons les résultats de notre commande.

Tout comme CMD, PowerShell nous offre de nombreuses commandes et cmdlets à utiliser. Presque toutes les commandes qui fonctionnent dans CMD fonctionneront dans PowerShell. Nous ne couvrirons que quelques commandes possibles dans ce module. Il est essentiel de comprendre qu'il y a très peu d'utilité à mémoriser les commandes. Concentrez-vous plutôt sur la compréhension du contexte, des concepts et de ce qui est possible. La mémorisation viendra naturellement avec le temps passé à pratiquer et à répéter.

---

## Get-Help

- Utiliser la fonction d'aide. Si nous voulons voir les options et les fonctionnalités qui nous sont offertes avec un cmdlet spécifique, nous pouvons utiliser le cmdlet [Get-Help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help?view=powershell-7.2).

#### Utiliser Get-Help

        powershell
`PS C:\Users\htb-student> Get-Help Test-Wsman  NAME     Test-WSMan  SYNTAX     Test-WSMan [[-ComputerName] <string>] [-Authentication {None | Default | Digest | Negotiate | Basic | Kerberos |     ClientCertificate | Credssp}] [-Port <int>] [-UseSSL] [-ApplicationName <string>] [-Credential <pscredential>]     [-CertificateThumbprint <string>]  [<CommonParameters>]   ALIASES     None   REMARKS     Get-Help cannot find the Help files for this cmdlet on this computer. It is displaying only partial help.         -- To download and install Help files for the module that includes this cmdlet, use Update-Help.         -- To view the Help topic for this cmdlet online, type: "Get-Help Test-WSMan -Online" or            go to https://go.microsoft.com/fwlink/?LinkId=141464.`

Get-Help peut donner des informations utiles sur un cmdlet. Remarquez que la sortie `Syntax` nous montre plusieurs options disponibles et des mots-clés supplémentaires qui peuvent être utilisés avec chaque option. Les `Aliases` sont également mentionnés, ce sont essentiellement des noms plus courts pour nos commandes. Nous discuterons des alias plus en détail plus loin dans cette section. La sortie `Remarks` nous fournit des informations supplémentaires sur le cmdlet et même des options additionnelles que nous pouvons utiliser pour en apprendre davantage sur le cmdlet. L'une de ces options supplémentaires est `-online`, qui ouvrira une page web de la documentation Microsoft pour le cmdlet correspondant si l'hôte a accès à Internet.

![GIF montrant un terminal PowerShell et l'utilisation de la commande Get-Help Online.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/GetHelpOnline.gif)

Nous pouvons également utiliser un cmdlet utile appelé [Update-Help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/update-help?view=powershell-7.2) pour nous assurer que nous disposons des informations les plus à jour pour chaque cmdlet sur le système Windows.

#### Utiliser Update-Help

        powershell
`PS C:\Windows\system32> Update-Help`

Remarquez combien plus d'informations ont été ajoutées concernant `Test-Wsman` après avoir exécuté `Update-Help`. N'hésitez pas à comparer cette sortie à celle montrée plus tôt lorsque nous avons abordé Get-Help pour la première fois.

#### Utiliser Get-Help après avoir exécuté Update-Help

        powershell
``PS C:\Windows\system32> Get-Help  Test-Wsman  NAME     Test-WSMan  SYNOPSIS     Tests whether the WinRM service is running on a local or remote computer.   SYNTAX     Test-WSMan [[-ComputerName] <System.String>] [-ApplicationName <System.String>]     [-Authentication {None | Default | Digest | Negotiate | Basic | Kerberos |     ClientCertificate | Credssp}] [-CertificateThumbprint <System.String>]     [-Credential <System.Management.Automation.PSCredential>] [-Port <System.Int32>]     [-UseSSL] [<CommonParameters>]   DESCRIPTION     The `Test-WSMan` cmdlet submits an identification request that determines     whether the WinRM service is running on a local or remote computer. If the     tested computer is running the service, the cmdlet displays the WS-Management     identity schema, the protocol version, the product vendor, and the product     version of the tested service.   RELATED LINKS     Online Version: https://docs.microsoft.com/powershell/module/microsoft.wsman.mana     gement/test-wsman?view=powershell-5.1&WT.mc_id=ps-gethelp     Connect-WSMan     Disable-WSManCredSSP     Disconnect-WSMan     Enable-WSManCredSSP     Get-WSManCredSSP     Get-WSManInstance     Invoke-WSManAction     New-WSManInstance     New-WSManSessionOption     Remove-WSManInstance     Set-WSManInstance     Set-WSManQuickConfig  REMARKS     To see the examples, type: "get-help Test-WSMan -examples".     For more information, type: "get-help Test-WSMan -detailed".     For technical information, type: "get-help Test-WSMan -full".     For online help, type: "get-help Test-WSMan -online"``

---

## Se déplacer dans PowerShell

Maintenant que nous avons vu ce qu'est PowerShell et les bases des fonctionnalités d'aide intégrées, passons à la navigation et à l'utilisation de base de PowerShell.

### Où sommes-nous ?

On ne peut se déplacer que si l'on sait déjà où l'on est, n'est-ce pas ? Nous pouvons déterminer notre répertoire de travail actuel (par rapport au système hôte) en utilisant le cmdlet `Get-Location`.

#### Get-Location

        powershell
`PS C:\Users\DLarusso> Get-Location  Path ---- C:\Users\DLarusso`

Nous pouvons voir qu'il a affiché le chemin complet du répertoire à partir duquel nous travaillons actuellement ; dans ce cas, il s'agit de `C:\Users\DLarusso`. Maintenant que nous avons nos repères, voyons quels objets et fichiers existent dans ce répertoire.

### Lister le répertoire

Le cmdlet `Get-ChildItem` peut afficher le contenu de notre répertoire actuel ou de celui que nous spécifions.

#### Get-ChildItem

        powershell
`PS C:\htb> Get-ChildItem   Directory: C:\Users\DLarusso   Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- d-----        10/26/2021  10:26 PM                .ssh d-----         1/28/2021   7:05 PM                .vscode d-r---         1/27/2021   2:44 PM                3D Objects d-r---         1/27/2021   2:44 PM                Contacts d-r---         9/18/2022  12:35 PM                Desktop d-r---         9/18/2022   1:01 PM                Documents d-r---         9/26/2022  12:27 PM                Downloads d-r---         1/27/2021   2:44 PM                Favorites d-r---         1/27/2021   2:44 PM                Music dar--l         9/26/2022  12:03 PM                OneDrive d-r---         5/22/2022   2:00 PM                Pictures`

Nous pouvons voir plusieurs autres répertoires dans notre répertoire de travail actuel. Explorons-en un.

### Se déplacer vers un nouveau répertoire

Changer notre emplacement est simple ; nous pouvons le faire en utilisant le cmdlet `Set-Location`.

#### Set-Location

        powershell
`PS C:\htb>  Set-Location .\Documents\  PS C:\Users\tru7h\Documents> Get-Location  Path ---- C:\Users\DLarusso\Documents`

Nous avons fourni les paramètres `.\Documents\` au cmdlet Set-Location, indiquant à PowerShell que nous voulons nous déplacer dans le répertoire Documents, qui se trouve dans notre répertoire de travail actuel. Nous aurions également pu lui donner le chemin complet du fichier comme ceci :

        powershell
`Set-Location C:\Users\DLarusso\Documents`  

### Afficher le contenu d'un fichier

Maintenant, si nous souhaitons voir le contenu d'un fichier, nous pouvons utiliser `Get-Content`. En regardant dans le répertoire Documents, nous remarquons un fichier appelé `Readme.md`. Allons voir.

#### Get-Content

        powershell
`PS C:\htb> Get-Content Readme.md    # ![logo][] PowerShell  Welcome to the PowerShell GitHub Community! PowerShell Core is a cross-platform (Windows, Linux, and macOS) automation and configuration tool/framework that works well with your existing tools and is optimized for dealing with structured data (e.g., JSON, CSV, XML, etc.), REST APIs, and object models. It includes a command-line shell, an associated scripting language and a framework for processing cmdlets.   <SNIP>` 

Il semble que le fichier Readme provenait de la page GitHub de PowerShell. L'utilisation du cmdlet `Get-Content` est aussi simple que cela. Naviguer dans le CLI de PowerShell est assez simple. Maintenant que nous maîtrisons cette compétence, examinons quelques trucs et astuces utiles qui peuvent rendre l'utilisation du CLI encore plus fluide.

## Trucs & astuces pour l'utilisation de PowerShell

### Get-Command

`Get-Command` est un excellent moyen de trouver une commande récalcitrante qui pourrait nous échapper de la mémoire juste au moment où nous en avons besoin. Comme PowerShell utilise la convention `verbe-nom` pour les cmdlets, nous pouvons effectuer une recherche sur l'un ou l'autre.

#### Utilisation de Get-Command

        powershell
`PS C:\htb> Get-Command  CommandType     Name                                               Version    Source -----------     ----                                               -------    ------ Alias           Add-AppPackage                                     2.0.1.0    Appx Alias           Add-AppPackageVolume                               2.0.1.0    Appx Alias           Add-AppProvisionedPackage                          3.0        Dism Alias           Add-ProvisionedAppPackage                          3.0        Dism Alias           Add-ProvisionedAppxPackage                         3.0        Dism Alias           Add-ProvisioningPackage                            3.0        Provisioning Alias           Add-TrustedProvisioningCertificate                 3.0        Provisioning Alias           Apply-WindowsUnattend                              3.0        Dism Alias           Disable-PhysicalDiskIndication                     2.0.0.0    Storage Alias           Disable-StorageDiagnosticLog                       2.0.0.0    Storage Alias           Dismount-AppPackageVolume                          2.0.1.0    Appx Alias           Enable-PhysicalDiskIndication                      2.0.0.0    Storage Alias           Enable-StorageDiagnosticLog                        2.0.0.0    Storage Alias           Flush-Volume                                       2.0.0.0    Storage Alias           Get-AppPackage                                     2.0.1.0    Appx  <SNIP>`  

La sortie ci-dessus a été coupée pour économiser de l'espace à l'écran. L'utilisation de `Get-Command` sans modificateurs supplémentaires effectuera une sortie complète de chaque cmdlet actuellement chargé dans la session PowerShell. Nous pouvons réduire cela davantage en filtrant sur la partie `verbe` ou `nom` du cmdlet.

#### Get-Command (verbe)

        powershell
`PS C:\htb> Get-Command -verb get  <SNIP> Cmdlet          Get-Acl                                            3.0.0.0    Microsoft.Pow... Cmdlet          Get-Alias                                          3.1.0.0    Microsoft.Pow... Cmdlet          Get-AppLockerFileInformation                       2.0.0.0    AppLocker Cmdlet          Get-AppLockerPolicy                                2.0.0.0    AppLocker Cmdlet          Get-AppvClientApplication                          1.0.0.0    AppvClient   <SNIP>`  

En utilisant le modificateur `-verb` et en recherchant tout cmdlet, alias ou fonction avec le terme get dans le nom, nous obtenons une liste détaillée de tout ce que PowerShell connaît actuellement. Nous pouvons également effectuer la même recherche en utilisant le filtre `get*` au lieu de `-verb` `get`. Le cmdlet Get-Command reconnaît le `*` comme un caractère générique et affiche chaque variante de `get`(quelque chose). Nous pouvons faire quelque chose de similaire en effectuant une recherche sur le nom également.

#### Get-Command (nom)

        powershell
`PS C:\htb> Get-Command -noun windows*    CommandType     Name                                               Version    Source -----------     ----                                               -------    ------ Alias           Apply-WindowsUnattend                              3.0        Dism Function        Get-WindowsUpdateLog                               1.0.0.0    WindowsUpdate Cmdlet          Add-WindowsCapability                              3.0        Dism Cmdlet          Add-WindowsDriver                                  3.0        Dism Cmdlet          Add-WindowsImage                                   3.0        Dism Cmdlet          Add-WindowsPackage                                 3.0        Dism Cmdlet          Clear-WindowsCorruptMountPoint                     3.0        Dism Cmdlet          Disable-WindowsErrorReporting                      1.0        WindowsErrorR... Cmdlet          Disable-WindowsOptionalFeature                     3.0        Dism Cmdlet          Dismount-WindowsImage                              3.0        Dism Cmdlet          Enable-WindowsErrorReporting                       1.0        WindowsErrorR... Cmdlet          Enable-WindowsOptionalFeature                      3.0        Dism`

Dans la sortie ci-dessus, nous avons utilisé le modificateur `-noun`, poussé le filtre un peu plus loin, et cherché toute partie du nom qui contenait `windows*`, nos résultats sont donc assez spécifiques. `Tout` ce qui commence par windows dans la partie nom et qui est suivi par autre chose `correspondra` à ce filtre. Ce n'étaient là que quelques démonstrations de la puissance du cmdlet `Get-Command`. Associées au cmdlet `Get-Help`, ce sont des fonctions d'aide puissantes qui nous sont fournies directement par PowerShell. Notre prochaine astuce plonge dans l'historique de notre session PowerShell.

### Historique

PowerShell conserve un historique des commandes exécutées de deux manières différentes. La première est l'historique de session intégré qui est mis en œuvre et supprimé au début et à la fin de chaque session de console. L'autre se fait via le module `PSReadLine`. Le module `PSReadLine` suit l'historique de toutes les commandes PowerShell utilisées dans toutes les sessions sur l'hôte, parmi de nombreuses autres fonctionnalités. Par défaut, PowerShell conserve les 4096 dernières commandes saisies, mais ce paramètre peut être modifié en changeant la variable `$MaximumHistoryCount`.

#### Get-History

        powershell
`PS C:\htb> Get-History   Id CommandLine   -- -----------    1 Get-Command    2 clear    3 get-command -verb set    4 get-command set*    5 clear    6 get-command -verb get    7 get-command -noun windows    8 get-command -noun windows*    9 get-module   10 clear   11 get-history   12 clear   13 ipconfig /all   14 arp -a   15 get-help   16 get-help get-module`

Par défaut, `Get-History` n'affichera que les commandes qui ont été exécutées pendant cette session active. Remarquez comment les commandes sont numérotées ; nous pouvons rappeler ces commandes en utilisant l'alias `r` suivi du numéro pour réexécuter cette commande. Par exemple, si nous voulions réexécuter la commande `arp -a`, nous pourrions saisir `r 14`, et PowerShell l'exécutera. Gardez à l'esprit que si nous fermons la fenêtre du shell, ou dans le cas d'un shell distant via un canal de commande et de contrôle (command and control), une fois que nous terminons cette session ou le processus que nous exécutons, notre historique PowerShell disparaîtra. Avec `PSReadLine`, cependant, ce n'est pas le cas. `PSReadLine` stocke tout dans un fichier nommé `$($host.Name)_history.txt` situé à `$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine`.

#### Afficher l'historique de PSReadLine

        powershell
`PS C:\htb> get-content C:\Users\DLarusso\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt  get-module Get-ChildItem Env: | ft Key,Value Get-ExecutionPolicy clear ssh administrator@10.172.16.110.55 powershell -nop -c "iex(New-Object Net.WebClient).DownloadString('https://download.sysinternals.com/files/PSTools.zip')" Get-ExecutionPolicy  <SNIP>`

Si nous exécutions la commande ci-dessus et que nous étions un utilisateur fréquent du CLI, nous aurions un fichier d'historique très volumineux à parcourir. La sortie ci-dessus a été coupée pour gagner du temps et de l'espace à l'écran. Une excellente fonctionnalité de `PSReadline` du point de vue de l'administrateur est qu'il tentera automatiquement de filtrer toutes les entrées qui incluent les chaînes de caractères :

- `password`
- `asplaintext`
- `token`
- `apikey`
- `secret`

Ce comportement est excellent pour nous en tant qu'administrateurs car il aidera à effacer du fichier d'historique `PSReadLine` toutes les entrées contenant des clés, des informations d'identification ou d'autres informations sensibles. L'historique de session intégré ne fait pas cela.

### Effacer l'écran

Cette astuce est une question de commodité. Si cela nous dérange d'avoir une tonne de texte sur notre écran en permanence, nous pouvons effacer le texte de notre fenêtre de console en utilisant la commande `Clear-Host`. Cela n'affectera que notre affichage actuel et ne supprimera aucune variable ou autre objet que nous aurions pu définir ou créer pendant la session. Nous pouvons également utiliser `clear` ou `cls` si nous préférons utiliser des commandes courtes ou des alias.

### Raccourcis clavier

À moins de travailler dans le CLI depuis un environnement graphique (GUI), notre souris ne fonctionnera `pas` souvent. Par exemple, disons que nous avons obtenu un `shell` sur un hôte lors d'un pentest. Nous aurons accès à CMD ou PowerShell depuis ce shell, mais nous ne pourrons pas utiliser l'`interface graphique`. Nous devons donc être à l'aise avec l'utilisation du clavier uniquement. Les `Raccourcis clavier` peuvent nous permettre d'effectuer des actions plus complexes qui nécessitent généralement une souris, avec seulement nos touches. Ci-dessous se trouve une liste rapide de certains des raccourcis clavier les plus utiles.

#### Raccourcis clavier

|**Raccourci**|**Description**|
|---|---|
|`CTRL+R`|Permet une recherche dans l'historique. Nous pouvons commencer à taper après, et il nous montrera les résultats qui correspondent aux commandes précédentes.|
|`CTRL+L`|Effacement rapide de l'écran.|
|`CTRL+ALT+Shift+?`|Affiche la liste complète des raccourcis clavier que PowerShell reconnaîtra.|
|`Échap`|Lorsque vous tapez dans le CLI, si vous souhaitez effacer toute la ligne, au lieu de maintenir la touche retour arrière, vous pouvez simplement appuyer sur `Échap`, ce qui effacera la ligne.|
|`↑`|Fait défiler l'historique vers le haut.|
|`↓`|Fait défiler l'historique vers le bas.|
|`F7`|Affiche une interface utilisateur textuelle (TUI) avec un historique interactif et déroulant de notre session.|

Cette liste ne représente pas toutes les fonctionnalités que nous pouvons utiliser dans PowerShell, mais celles que nous utilisons le plus souvent.

### Complétion par tabulation

L'une des meilleures fonctionnalités de PowerShell doit être la complétion des commandes par tabulation. Nous pouvons utiliser `Tab` et `MAJ+Tab` pour parcourir les options qui peuvent compléter la commande que nous tapons.

#### Exemple d'auto-complétion

![GIF montrant la fonctionnalité d'auto-complétion dans une fenêtre PowerShell.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/tab.gif)

### Alias

Notre dernière astuce à mentionner concerne les `Alias`. Un alias PowerShell est un autre nom pour un cmdlet, une commande ou un fichier exécutable. Nous pouvons voir une liste des alias par défaut en utilisant le cmdlet [Get-Alias](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-alias?view=powershell-7.2). La plupart des alias intégrés sont des versions raccourcies du cmdlet, ce qui les rend plus faciles à mémoriser et rapides à utiliser.

#### Utiliser Get-Alias

        powershell
`PS C:\Windows\system32> Get-Alias  CommandType     Name                                               Version    Source                                                                                -----------     ----                                               -------    ----- Alias           % -> ForEach-Object Alias           ? -> Where-Object Alias           ac -> Add-Content Alias           asnp -> Add-PSSnapin Alias           cat -> Get-Content Alias           cd -> Set-Location Alias           CFS -> ConvertFrom-String                          3.1.0.0    Mi... Alias           chdir -> Set-Location Alias           clc -> Clear-Content Alias           clear -> Clear-Host Alias           clhy -> Clear-History Alias           cli -> Clear-Item Alias           clp -> Clear-ItemProperty Alias           cls -> Clear-Host Alias           clv -> Clear-Variable Alias           cnsn -> Connect-PSSession Alias           compare -> Compare-Object Alias           copy -> Copy-Item Alias           cp -> Copy-Item Alias           cpi -> Copy-Item Alias           cpp -> Copy-ItemProperty Alias           curl -> Invoke-WebRequest Alias           cvpa -> Convert-Path Alias           dbp -> Disable-PSBreakpoint Alias           del -> Remove-Item Alias           diff -> Compare-Object Alias           dir -> Get-ChildItem  <SNIP>`

C'est une excellente pratique de créer des alias plus courts que le nom du cmdlet, de la commande ou de l'exécutable réel. Même le cmdlet `Get-Alias` a un alias par défaut, `gal`, comme on le voit dans le clip ci-dessous.

![GIF montrant l'alias Gal (gal) dans une fenêtre PowerShell.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/GalAlias.gif)

Nous pouvons également définir un alias pour un cmdlet spécifique en utilisant [Set-Alias](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/set-alias?view=powershell-7.2). Entraînons-nous en créant un alias pour le cmdlet `Get-Help`.

#### Utiliser Set-Alias

        powershell
`PS C:\Windows\system32> Set-Alias -Name gh -Value Get-Help`

Lorsque nous utilisons `Set-Alias`, nous devons spécifier le nom de l'alias (`-Name gh`) et le cmdlet correspondant (`-Value Get-Help`).

![GIF montrant la commande Set-Alias dans une fenêtre PowerShell.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/SetAlias.gif)

Ci-dessous, nous incluons également une liste de plusieurs alias que nous trouvons les plus utiles. Certaines commandes ont également plus d'un alias. Assurez-vous de consulter la liste complète pour d'autres alias que vous pourriez trouver utiles.

#### Alias utiles

|**Alias**|**Description**|
|---|---|
|`pwd`|gl peut également être utilisé. Cet alias peut être utilisé à la place de Get-Location.|
|`ls`|dir et gci peuvent également être utilisés à la place de ls. C'est un alias pour Get-ChildItem.|
|`cd`|sl et chdir peuvent être utilisés à la place de cd. C'est un alias pour Set-Location.|
|`cat`|type et gc peuvent également être utilisés. C'est un alias pour Get-Content.|
|`clear`|Peut être utilisé à la place de Clear-Host.|
|`curl`|Curl est un alias pour Invoke-WebRequest, qui peut être utilisé pour télécharger des fichiers. wget peut également être utilisé.|
|`fl et ft`|Ces alias peuvent être utilisés pour formater la sortie en listes et en tableaux.|
|`man`|Peut être utilisé à la place de help.|

Pour ceux qui sont familiers avec `BASH`, vous avez peut-être remarqué que de nombreux alias correspondent à des commandes largement utilisées dans les distributions Linux. Cette connaissance peut être utile et aider à faciliter la courbe d'apprentissage.

---

Cette section a été un peu longue, et pour une bonne raison. Nous avons couvert tous les éléments essentiels pour nous faire progresser sur notre chemin vers la maîtrise de PowerShell. À partir d'ici, nous allons plonger en profondeur dans les modules et les cmdlets de PowerShell.

Lab de fin 

![Pasted image 20260901101234.png](/assets/img/writeups/Pasted image 20260901101234.png)
rep : get-help  Get-Location

![Pasted image 20260901101342.png](/assets/img/writeups/Pasted image 20260901101342.png)

Rep : get-Location

![Pasted image 20260901101534.png](/assets/img/writeups/Pasted image 20260901101534.png)

Rep : `Escape`
