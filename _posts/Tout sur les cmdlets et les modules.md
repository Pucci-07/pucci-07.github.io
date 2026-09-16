[[Command Prompt Basics]]

Dans cette section, nous aborderons les points suivants :

- Que sont les cmdlets et les modules ?
- Comment interagissons-nous avec eux ?
- Comment installons-nous et chargeons-nous de nouveaux modules depuis le web ?

Comprendre ces questions est essentiel pour utiliser PowerShell en tant qu'administrateur système et que pentester. La nature modulaire et extensible de PowerShell en fait un outil surpuissant à avoir dans notre boîte à outils. Voyons plus en détail ce que sont les cmdlets et les modules.

---

## Cmdlets

Une [cmdlet](https://docs.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-13?view=powershell-7.2), telle que définie par Microsoft, est :

"`une commande à fonctionnalité unique qui manipule des objets dans PowerShell.`"

Les cmdlets suivent une structure Verbe-Nom, ce qui facilite souvent la compréhension de ce que fait une cmdlet donnée. Avec Test-WSMan, nous pouvons voir que le `verbe` est `Test` et le `Nom` est `Wsman`. Le verbe et le nom sont séparés par un tiret (`-`). Après le verbe et le nom, nous utiliserions les options qui nous sont offertes avec une cmdlet donnée pour effectuer l'action souhaitée. Les cmdlets sont similaires aux fonctions utilisées dans le code PowerShell ou d'autres langages de programmation, mais avec une différence significative. Les cmdlets ne sont `pas` écrites en PowerShell. Elles sont écrites en C# ou dans un autre langage, puis compilées pour être utilisées. Comme nous l'avons vu dans la section précédente, nous pouvons utiliser la cmdlet `Get-Command` pour voir les applications, cmdlets et fonctions disponibles, ainsi qu'une caractéristique intitulée "CommandType" qui peut nous aider à identifier leur type.

Si nous voulons voir les options et les fonctionnalités qui nous sont offertes avec une cmdlet spécifique, nous pouvons utiliser la cmdlet [Get-Help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help?view=powershell-7.2) ainsi que la cmdlet `Get-Member`.

---

## Modules PowerShell

Un [module PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/understanding-a-windows-powershell-module?view=powershell-7.2) est du code PowerShell structuré, facile à utiliser et à partager. Comme mentionné dans la documentation officielle de Microsoft, un module peut être composé des éléments suivants :

- Cmdlets
- Fichiers de script
- Fonctions
- Assemblies
- Ressources associées (fichiers de manifeste et d'aide)

Tout au long de cette section, nous allons utiliser le projet PowerView pour examiner ce qui compose un module et comment interagir avec. `PowerView.ps1` fait partie d'une collection de modules PowerShell organisés dans un projet appelé [PowerSploit](https://github.com/PowerShellMafia/PowerSploit), créé par la [PowerShellMafia](https://github.com/PowerShellMafia/PowerSploit) pour fournir aux testeurs d'intrusion de nombreux outils précieux à utiliser lors des tests d'environnements de domaine Windows/Active Directory. Bien que nous puissions remarquer que ce projet a été archivé, bon nombre des outils inclus sont toujours pertinents et utiles pour les tests d'intrusion aujourd'hui (rédigé en août 2022). Nous ne couvrirons pas en détail l'utilisation et la mise en œuvre de PowerSploit dans ce module. Nous l'utiliserons simplement comme référence pour mieux comprendre PowerShell. L'utilisation de PowerSploit pour énumérer et attaquer les environnements de domaine Windows est traitée en profondeur dans le module [Active Directory Enumeration & Attacks](https://academy.hackthebox.com/course/preview/active-directory-enumeration--attacks).

![Page du dépôt GitHub pour PowerSploit, montrant la liste des fichiers avec descriptions, l'historique des commits et les détails du projet. Fichiers mis en évidence : PowerSploit.psd1 et PowerSploit.psm1, liés à Invoke-PrivescAudit. Note : Le projet n'est plus maintenu.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/ImportModulePowerSploit.png)

### PowerSploit.psd1

Un fichier de données PowerShell (`.psd1`) est un [fichier de manifeste de module](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_module_manifests?view=powershell-7.2). Un fichier de manifeste contient souvent :

- Une référence au module qui sera traité
- Des numéros de version pour suivre les changements majeurs
- Le GUID
- L'auteur du module
- Le Copyright
- Des informations de compatibilité PowerShell
- Les modules et cmdlets inclus
- Des métadonnées

#### PowerSploit.psd1

![GIF montrant le fichier PowerSploit.psd1 dans le dépôt Github.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/PowerSploitpsd1.gif)

### PowerSploit.psm1

Un fichier de module de script PowerShell (`.psm1`) est simplement un script contenant du code PowerShell. Considérez-le comme le cœur d'un module.

#### Contenu de PowerSploit.psm1

        powershell
`Get-ChildItem $PSScriptRoot | ? { $_.PSIsContainer -and !('Tests','docs' -contains $_.Name) } | % { Import-Module $_.FullName -DisableNameChecking }`

La cmdlet Get-ChildItem récupère les éléments dans le répertoire courant (représenté par la variable automatique $PSScriptRoot), et la cmdlet Where-Object (qui a pour alias le caractère "?") les filtre pour ne garder que les éléments qui sont des dossiers et qui n'ont pas les noms "Tests" ou "docs". Enfin, la cmdlet ForEach-Object (qui a pour alias le caractère "%") exécute la cmdlet Import-Module sur chacun de ces éléments restants, en passant le paramètre DisableNameChecking pour éviter les erreurs si le module contient des cmdlets ou des fonctions portant les mêmes noms que des cmdlets ou des fonctions de la session active.

---

## Utilisation des modules PowerShell

Une fois que nous avons décidé quel module PowerShell nous voulons utiliser, nous devrons déterminer comment et d'où nous allons l'exécuter. Nous devons également nous demander si le module et les scripts choisis sont déjà sur l'hôte ou si nous devons les y transférer. `Get-Module` peut nous aider à déterminer quels modules sont déjà chargés.

#### Get-Module

        powershell
`PS C:\htb> Get-Module   ModuleType Version    Name                                ExportedCommands ---------- -------    ----                                ---------------- Script     0.0        chocolateyProfile                   {TabExpansion, Update-SessionEnvironment, refreshenv} Manifest   3.1.0.0    Microsoft.PowerShell.Management     {Add-Computer, Add-Content, Checkpoint-Computer, Clear-Con... Manifest   3.1.0.0    Microsoft.PowerShell.Utility        {Add-Member, Add-Type, Clear-Variable, Compare-Object...} Script     0.7.3.1    posh-git                            {Add-PoshGitToProfile, Add-SshKey, Enable-GitColors, Expan... Script     2.0.0      PSReadline                          {Get-PSReadLineKeyHandler, Get-PSReadLineOption, Remove-PS...`

#### List-Available

        powershell
`PS C:\htb> Get-Module -ListAvailable    Directory: C:\Users\tru7h\Documents\WindowsPowerShell\Modules   ModuleType Version    Name                                ExportedCommands ---------- -------    ----                                ---------------- Script     1.1.0      PSSQLite                            {Invoke-SqliteBulkCopy, Invoke-SqliteQuery, New-SqliteConn...       Directory: C:\Program Files\WindowsPowerShell\Modules   ModuleType Version    Name                                ExportedCommands ---------- -------    ----                                ---------------- Script     1.0.1      Microsoft.PowerShell.Operation.V... {Get-OperationValidation, Invoke-OperationValidation} Binary     1.0.0.1    PackageManagement                   {Find-Package, Get-Package, Get-PackageProvider, Get-Packa... Script     3.4.0      Pester                              {Describe, Context, It, Should...} Script     1.0.0.1    PowerShellGet                       {Install-Module, Find-Module, Save-Module, Update-Module...} Script     2.0.0      PSReadline                          {Get-PSReadLineKeyHandler, Set-PSReadLineKeyHandler, Remov...`

Le modificateur `-ListAvailable` nous montrera tous les modules que nous avons installés mais qui ne sont pas chargés dans notre session.

Nous avons déjà transféré le module ou les scripts souhaités sur un hôte Windows cible. Nous devrons ensuite les exécuter. Nous pouvons le faire en utilisant la cmdlet `Import-Module`.

#### Utilisation de Import-Module

La cmdlet [Import-Module](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/import-module?view=powershell-7.2) nous permet d'ajouter un module à la session PowerShell active.

        powershell
`PS C:\Users\htb-student> Get-Help Import-Module  NAME     Import-Module  SYNOPSIS     Adds modules to the current session.   SYNTAX     Import-Module [-Assembly] <System.Reflection.Assembly[]> [-Alias <System.String[]>] [-ArgumentList     <System.Object[]>] [-AsCustomObject] [-Cmdlet <System.String[]>] [-DisableNameChecking] [-Force] [-Function     <System.String[]>] [-Global] [-NoClobber] [-PassThru] [-Prefix <System.String>] [-Scope {Local | Global}]     [-Variable <System.String[]>] [<CommonParameters>]      Import-Module [-Name] <System.String[]> [-Alias <System.String[]>] [-ArgumentList <System.Object[]>]     [-AsCustomObject] [-CimNamespace <System.String>] [-CimResourceUri <System.Uri>] -CimSession     <Microsoft.Management.Infrastructure.CimSession> [-Cmdlet <System.String[]>] [-DisableNameChecking] [-Force]     [-Function <System.String[]>] [-Global] [-MaximumVersion <System.String>] [-MinimumVersion <System.Version>]     [-NoClobber] [-PassThru] [-Prefix <System.String>] [-RequiredVersion <System.Version>] [-Scope {Local | Global}]     [-Variable <System.String[]>] [<CommonParameters>]  <SNIP>`

Pour comprendre l'idée d'importer le module dans notre session PowerShell active, nous pouvons essayer d'exécuter une cmdlet (`Get-NetLocalgroup`) qui fait partie de PowerSploit. Nous obtiendrons un message d'erreur en essayant de le faire sans importer de module. Une fois que nous aurons importé avec succès le module PowerSploit (il a été placé sur le bureau de l'hôte cible pour notre utilisation), de nombreuses cmdlets seront à notre disposition, y compris Get-NetLocalgroup. Voyez cela en action dans le clip ci-dessous :

#### Importation de PowerSploit.psd1

        powershell
`PS C:\Users\htb-student\Desktop\PowerSploit> Import-Module .\PowerSploit.psd1 PS C:\Users\htb-student\Desktop\PowerSploit> Get-NetLocalgroup  ComputerName GroupName                           Comment ------------ ---------                           ------- WS01         Access Control Assistance Operators Members of this group can remotely query authorization attributes a... WS01         Administrators                      Administrators have complete and unrestricted access to the compute... WS01         Backup Operators                    Backup Operators can override security restrictions for the sole pu... WS01         Cryptographic Operators             Members are authorized to perform cryptographic operations. WS01         Distributed COM Users               Members are allowed to launch, activate and use Distributed COM obj... WS01         Event Log Readers                   Members of this group can read event logs from local machine WS01         Guests                              Guests have the same access as members of the Users group by defaul... WS01         Hyper-V Administrators              Members of this group have complete and unrestricted access to all ... WS01         IIS_IUSRS                           Built-in group used by Internet Information Services. WS01         Network Configuration Operators     Members in this group can have some administrative privileges to ma... WS01         Performance Log Users               Members of this group may schedule logging of performance counters,... WS01         Performance Monitor Users           Members of this group can access performance counter data locally a... WS01         Power Users                         Power Users are included for backwards compatibility and possess li... WS01         Remote Desktop Users                Members in this group are granted the right to logon remotely WS01         Remote Management Users             Members of this group can access WMI resources over management prot... WS01         Replicator                          Supports file replication in a domain WS01         System Managed Accounts Group       Members of this group are managed by the system. WS01         Users                               Users are prevented from making accidental or intentional system-wi...`

![GIF montrant la commande Import-Module dans une fenêtre PowerShell et l'importation du module PowerSploit.psd1.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/Import-Module.gif)

Remarquez qu'au début du clip, `Get-NetLocalgroup` n'a pas été reconnu. Cela s'est produit car il n'est pas inclus dans le chemin par défaut des modules. Nous pouvons voir où se trouve le chemin par défaut des modules en listant la variable d'environnement `PSModulePath`.

#### Affichage de PSModulePath

        powershell
`PS C:\Users\htb-student> $env:PSModulePath  C:\Users\htb-student\Documents\WindowsPowerShell\Modules;C:\Program Files\WindowsPowerShell\Modules;C:\Windows\system32\WindowsPowerShell\v1.0\Modules`

Lorsque le module PowerSploit.psd1 est importé, la fonction `Get-NetLocalgroup` est reconnue. Cela se produit car plusieurs modules sont inclus lorsque nous chargeons PowerSploit.psd1. Il est possible d'ajouter de manière permanente un ou plusieurs modules en ajoutant les fichiers aux répertoires référencés dans le PSModulePath. Cette action est logique si nous utilisions un système d'exploitation Windows comme hôte d'attaque principal, mais lors d'une mission, il serait plus judicieux de simplement transférer des scripts spécifiques sur l'hôte d'attaque et de les importer au besoin.

---

## Stratégie d'exécution

Un facteur essentiel à prendre en compte lorsque l'on tente d'utiliser des scripts et des modules PowerShell est la [stratégie d'exécution (execution policy) de PowerShell](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.2). Comme le souligne la documentation officielle de Microsoft, une stratégie d'exécution n'est pas un contrôle de sécurité. Elle est conçue pour donner aux administrateurs informatiques un outil pour définir des paramètres et des garde-fous pour eux-mêmes.

#### Impact de la stratégie d'exécution

        Powershell-session
`PS C:\Users\htb-student\Desktop\PowerSploit> Import-Module .\PowerSploit.psd1  Import-Module : File C:\Users\Users\htb-student\PowerSploit.psm1 cannot be loaded because running scripts is disabled on this system. For more information, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170. At line:1 char:1 + Import-Module .\PowerSploit.psd1 + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     + CategoryInfo          : SecurityError: (:) [Import-Module], PSSecurityException     + FullyQualifiedErrorId : UnauthorizedAccess,Microsoft.PowerShell.Commands.ImportModuleCommand`

La stratégie d'exécution de l'hôte nous empêche d'exécuter notre script. Nous pouvons cependant contourner cela. Tout d'abord, vérifions nos paramètres de stratégie d'exécution.

#### Vérification de l'état de la stratégie d'exécution

        powershell
`PS C:\htb> Get-ExecutionPolicy   Restricted`  

Notre paramètre actuel restreint ce que l'utilisateur peut faire. Si nous voulons changer ce paramètre, nous pouvons le faire avec la cmdlet `Set-ExecutionPolicy`.

#### Définition de la stratégie d'exécution

        powershell
`PS C:\htb> Set-ExecutionPolicy undefined` 

En définissant la stratégie sur "undefined", nous indiquons à PowerShell que nous ne souhaitons pas limiter nos interactions. Nous devrions maintenant être en mesure d'importer et d'exécuter notre script.

#### Testons-le

        powershell
`PS C:\htb> Import-Module .\PowerSploit.psd1  Import-Module .\PowerSploit.psd1 PS C:\Users\htb> get-module  ModuleType Version    Name                                ExportedCommands ---------- -------    ----                                ---------------- Manifest   3.1.0.0    Microsoft.PowerShell.Management     {Add-Computer, Add-Content, Check... Manifest   3.0.0.0    Microsoft.PowerShell.Security       {ConvertFrom-SecureString, Conver... Manifest   3.1.0.0    Microsoft.PowerShell.Utility        {Add-Member, Add-Type, Clear-Vari... Script     3.0.0.0    PowerSploit                         {Add-Persistence, Add-ServiceDacl... Script     2.0.0      PSReadline                          {Get-PSReadLineKeyHandler, Get-PS...`

En regardant nos modules chargés, nous pouvons voir que nous avons chargé PowerSploit avec succès. Nous pouvons maintenant utiliser les outils selon nos besoins.

**Note : En tant qu'administrateur système, ce genre de changements est courant et devrait toujours être annulé une fois le travail terminé. En tant que pentester, si nous effectuons un tel changement sans l'annuler, cela pourrait indiquer à un défenseur que l'hôte a été compromis. Assurez-vous de nettoyer après vos actions. Une autre façon de contourner la stratégie d'exécution sans laisser de changement persistant est de la modifier au niveau du processus en utilisant -scope.**

#### Changer la stratégie d'exécution par portée (Scope)

        powershell
`PS C:\htb> Set-ExecutionPolicy -scope Process  PS C:\htb> Get-ExecutionPolicy -list  Scope ExecutionPolicy         ----- --------------- MachinePolicy       Undefined    UserPolicy       Undefined       Process          Bypass   CurrentUser       Undefined  LocalMachine          Bypass`  

En la changeant au niveau du processus (Process), notre modification sera annulée une fois que nous fermerons la session PowerShell. Gardez la stratégie d'exécution à l'esprit lorsque vous travaillez avec des scripts et de nouveaux modules. Bien sûr, nous voulons d'abord examiner les scripts que nous essayons de charger pour nous assurer qu'ils sont sûrs à utiliser. En tant que testeurs d'intrusion, nous pourrions rencontrer des moments où nous devons être créatifs sur la façon de contourner la stratégie d'exécution sur un hôte. Ce [billet de blog](https://www.netspi.com/blog/technical/network-penetration-testing/15-ways-to-bypass-the-powershell-execution-policy/) présente des moyens créatifs que nous avons utilisés avec beaucoup de succès lors de missions réelles.

### Appeler des cmdlets et des fonctions depuis un module

Si nous souhaitons voir quels alias, cmdlets et fonctions un module importé a apporté à la session, nous pouvons utiliser `Get-Command -Module <nomdumodule>` pour nous éclairer.

#### Utilisation de Get-Command

        powershell
`PS C:\htb> Get-Command -Module PowerSploit  CommandType     Name                                               Version    Source -----------     ----                                               -------    ------ Alias           Invoke-ProcessHunter                               3.0.0.0    PowerSploit Alias           Invoke-ShareFinder                                 3.0.0.0    PowerSploit Alias           Invoke-ThreadedFunction                            3.0.0.0    PowerSploit Alias           Invoke-UserHunter                                  3.0.0.0    PowerSploit Alias           Request-SPNTicket                                  3.0.0.0    PowerSploit Alias           Set-ADObject                                       3.0.0.0    PowerSploit Function        Add-Persistence                                    3.0.0.0    PowerSploit Function        Add-ServiceDacl                                    3.0.0.0    PowerSploit Function        Find-AVSignature                                   3.0.0.0    PowerSploit Function        Find-InterestingFile                               3.0.0.0    PowerSploit Function        Find-LocalAdminAccess                              3.0.0.0    PowerSploit Function        Find-PathDLLHijack                                 3.0.0.0    PowerSploit Function        Find-ProcessDLLHijack                              3.0.0.0    PowerSploit Function        Get-ApplicationHost                                3.0.0.0    PowerSploit Function        Get-GPPPassword                                    3.0.0.0    PowerSploit`

Nous pouvons maintenant voir ce qui a été chargé par PowerSploit. À partir de là, nous pouvons utiliser les scripts et les fonctions selon nos besoins. C'est la partie facile, choisir la fonction et la laisser s'exécuter.

### Plongée en profondeur : Trouver et installer des modules depuis PowerShell Gallery et GitHub

À notre époque, le partage d'informations est extrêmement facile. Cela vaut aussi pour les solutions et les nouvelles créations. En ce qui concerne les modules PowerShell, la [PowerShell Gallery](https://www.powershellgallery.com/) est le meilleur endroit pour cela. C'est un dépôt qui contient des scripts PowerShell, des modules et plus encore, créés par Microsoft et d'autres utilisateurs. Ils peuvent aller de quelque chose d'aussi simple que la gestion des attributs d'utilisateur à la résolution de problèmes complexes de stockage dans le cloud.

#### PowerShell Gallery

![Page d'accueil de la PowerShell Gallery montrant une barre de recherche, des statistiques sur les paquets uniques, les téléchargements totaux et le nombre total de paquets. Comprend des sections pour en savoir plus sur la galerie et les téléchargements de paquets les plus populaires comme NetworkingDsc et PSWindowsUpdate.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/powershellg.png)

Heureusement pour nous, il existe déjà un module intégré à PowerShell destiné à nous aider à interagir avec la PowerShell Gallery, appelé `PowerShellGet`. Jetons-y un coup d'œil :

#### PowerShellGet

        powershell
`PS C:\htb> Get-Command -Module PowerShellGet   CommandType     Name                                               Version    Source -----------     ----                                               -------    ------ Function        Find-Command                                       1.0.0.1    PowerShellGet Function        Find-DscResource                                   1.0.0.1    PowerShellGet Function        Find-Module                                        1.0.0.1    PowerShellGet Function        Find-RoleCapability                                1.0.0.1    PowerShellGet Function        Find-Script                                        1.0.0.1    PowerSploit Function        Get-InstalledModule                                1.0.0.1    PowerShellGet Function        Get-InstalledScript                                1.0.0.1    PowerShellGet Function        Get-PSRepository                                   1.0.0.1    PowerShellGet Function        Install-Module                                     1.0.0.1    PowerShellGet Function        Install-Script                                     1.0.0.1    PowerShellGet Function        New-ScriptFileInfo                                 1.0.0.1    PowerShellGet Function        Publish-Module                                     1.0.0.1    PowerShellGet Function        Publish-Script                                     1.0.0.1    PowerShellGet Function        Register-PSRepository                              1.0.0.1    PowerShellGet Function        Save-Module                                        1.0.0.1    PowerShellGet Function        Save-Script                                        1.0.0.1    PowerShellGet Function        Set-PSRepository                                   1.0.0.1    PowerShellGet Function        Test-ScriptFileInfo                                1.0.0.1    PowerShellGet Function        Uninstall-Module                                   1.0.0.1    PowerShellGet Function        Uninstall-Script                                   1.0.0.1    PowerShellGet Function        Unregister-PSRepository                            1.0.0.1    PowerShellGet Function        Update-Module                                      1.0.0.1    PowerShellGet Function        Update-ModuleManifest                              1.0.0.1    PowerShellGet Function        Update-Script                                      1.0.0.1    PowerShellGet Function        Update-ScriptFileInfo                              1.0.0.1    PowerShellGet`

Ce module possède de nombreuses fonctions différentes pour nous aider à travailler avec et à télécharger des modules existants de la galerie, ainsi qu'à créer et téléverser les nôtres. À partir de notre liste de fonctions, essayons Find-Module. Un module qui se révélera extrêmement utile pour les administrateurs système est le module [AdminToolbox](https://www.powershellgallery.com/packages/AdminToolbox/11.0.8). Il s'agit d'une collection de plusieurs autres modules avec des outils destinés à la gestion d'Active Directory, de Microsoft Exchange, de la virtualisation, et de nombreuses autres tâches dont un administrateur aurait besoin au quotidien.

#### Find-Module

        powershell
`PS C:\htb> Find-Module -Name AdminToolbox   Version    Name                                Repository           Description -------    ----                                ----------           ----------- 11.0.8     AdminToolbox                        PSGallery            Master module for a col...`

Comme avec de nombreuses autres cmdlets PowerShell, nous pouvons également effectuer une recherche en utilisant des caractères génériques. Une fois que nous avons trouvé un module que nous souhaitons utiliser, l'installer est aussi simple que `Install-Module`. N'oubliez pas qu'il faut des droits administratifs pour installer des modules de cette manière.

#### Install-Module

![GIF montrant la commande Install-Module redirigée depuis la commande Find-Module dans une fenêtre PowerShell.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/admintoolbox.gif)

Dans l'image ci-dessus, nous avons enchaîné `Find-Module` avec `Install-Module` pour effectuer les deux actions simultanément. Cet exemple tire parti de la fonctionnalité de pipeline de PowerShell. Nous aborderons ce sujet plus en profondeur dans une autre section, mais pour l'instant, cela nous a permis de trouver et d'installer le module avec une seule chaîne de commande. N'oubliez pas que les instances modernes de PowerShell importeront automatiquement un module installé la première fois que nous exécuterons une cmdlet ou une fonction de celui-ci, il n'est donc pas nécessaire d'importer le module après l'avoir installé. Cela diffère des modules personnalisés ou des modules que nous apportons sur l'hôte (depuis GitHub, par exemple). Nous devrons l'importer manuellement à chaque fois que nous voudrons l'utiliser, à moins de modifier notre profil PowerShell. Vous pouvez trouver les emplacements de chaque profil PowerShell spécifique [ici](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.2). Outre la création de nos propres modules et scripts ou leur importation depuis la PowerShell Gallery, nous pouvons également tirer parti de [Github](https://github.com/) et de tout le contenu incroyable que la communauté informatique a créé de manière externe. L'utilisation de `Git` et `Github` nécessite pour l'instant l'installation d'autres applications et la connaissance d'autres concepts que nous n'avons pas encore abordés, nous garderons donc cela pour plus tard dans le module.

### Outils à connaître

Ci-dessous, nous listerons rapidement quelques modules et projets PowerShell que nous, en tant que testeurs d'intrusion et administrateurs système, devrions connaître. Chacun de ces outils apporte une nouvelle capacité à utiliser dans PowerShell. Bien sûr, il y en a beaucoup plus que notre liste ; ce sont juste quelques-uns vers lesquels nous nous tournons à chaque mission.

- [AdminToolbox](https://www.powershellgallery.com/packages/AdminToolbox/11.0.8) : AdminToolbox est une collection de modules utiles qui permettent aux administrateurs système d'effectuer un grand nombre d'actions liées à des choses comme Active Directory, Exchange, la gestion de réseau, les problèmes de fichiers et de stockage, et plus encore.
- [ActiveDirectory](https://learn.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2022-ps) : Ce module est une collection d'outils d'administration locale et à distance pour tout ce qui concerne Active Directory. Nous pouvons gérer les utilisateurs, les groupes, les autorisations, et bien plus encore avec lui.
- [Empire / Situational Awareness](https://github.com/BC-SECURITY/Empire/tree/master/empire/server/data/module_source/situational_awareness) : Est une collection de modules et de scripts PowerShell qui peuvent nous fournir une connaissance de la situation sur un hôte et le domaine dont il fait partie. Ce projet est maintenu par [BC Security](https://github.com/BC-SECURITY) dans le cadre de leur Empire Framework.
- [Inveigh](https://github.com/Kevin-Robertson/Inveigh) : Inveigh est un outil conçu pour effectuer des attaques de spoofing réseau et des attaques de l'homme du milieu (Man-in-the-middle).
- [BloodHound / SharpHound](https://github.com/BloodHoundAD/BloodHound/tree/master/Collectors) : Bloodhound/Sharphound nous permet de cartographier visuellement un environnement Active Directory en utilisant des outils d'analyse graphique et des collecteurs de données écrits en C# et PowerShell.

---

Travailler avec les modules et les cmdlets PowerShell est intuitif et facile à maîtriser rapidement. Cette compétence sera utile pour le reste de ce module, car nous traiterons de divers outils et sujets au sein de PowerShell qui pourraient nous obliger à installer, importer ou examiner des modules et des cmdlets. Si vous êtes bloqué, n'hésitez pas à vous référer à cette section. Il est maintenant temps de passer à la gestion des utilisateurs et des groupes.


Lab de fin 

![[Pasted image 20260901184623.png]]

rep : get-module 

![[Pasted image 20260901184854.png]]

Rep : `PowerShellGet`

![[Pasted image 20260901222838.png]]

ici pour facilietre les choses ont pourrait configurer un proxy sur notre machine hote pour que la box HTB passe par celle si pour l'accès à internet 

$env:HTTP_PROXY = "http://10.10.15.166:3128"
[$env:HTTPS_PROXY = "http://10.10.15.166:3128"](https://cdn.powershellgallery.com/packages/admintoolbox.activedirectory.1.14.0.22.nupkg)

une fois config on envoyer des cmdlet weblet pour télécharger des fichiers (des modules dans notre cas ) 

la cmd : invoke web-request -Uri https://cdn.powershellgallery.com/packages/7zip4powershell.2.12.0.nupkg -o  7zipPowModule.zip 

ensuite on dézipe le fichier zip eut 
et on navigue vers le fichier .ps1 contunu dans l'extrait  fichier .zip cible et on le charge avec 
import-module .\chemin\vers\le\fichier\ps1\cible

