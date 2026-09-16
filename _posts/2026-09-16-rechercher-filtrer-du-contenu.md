[[Command Prompt Basics]]

Être capable de chercher, trouver et filtrer le contenu que nous recherchons est une nécessité absolue pour tout utilisateur qui utilise l'interface de ligne de commande (CLI, Command-Line Interface), quel que soit le shell ou le système d'exploitation (OS). Néanmoins, comment faire cela dans PowerShell ? Pour répondre à cette question, cette section abordera en détail la manière dont PowerShell utilise les `Objets`, comment nous pouvons `filtrer` en fonction des `Propriétés` et du `contenu`, et décrira plus en détail des composants comme le `Pipeline` PowerShell.

---

## Explication de la Sortie PowerShell (Explication des Objets)

Avec PowerShell, tout n'est pas une chaîne de texte générique comme dans Bash ou cmd. Dans PowerShell, tout est un `Objet`. Cependant, qu'est-ce qu'un objet ? Examinons ce concept plus en détail :

`Qu'est-ce qu'un Objet ?` Un `objet` est une instance `individuelle` d'une `classe` au sein de PowerShell. Prenons l'exemple d'un ordinateur comme notre objet. L'ensemble de tout (pièces, temps, conception, logiciels, etc.) fait d'un ordinateur un ordinateur.

`Qu'est-ce qu'une Classe ?` Une classe est le `schéma` ou la « représentation unique d'une chose (objet) et la manière dont la somme de ses `propriétés` la définit. Le `plan` utilisé pour définir comment cet ordinateur doit être assemblé et tout ce qu'il contient peut être considéré comme une Classe.

`Que sont les Propriétés ?` Les propriétés sont simplement les `données` associées à un objet dans PowerShell. Pour notre exemple d'un ordinateur, les `pièces` individuelles que nous assemblons pour fabriquer l'ordinateur sont ses propriétés. Chaque pièce a un but et une utilisation unique au sein de l'objet.

`Que sont les Méthodes ?` En termes simples, les méthodes sont toutes les fonctions que notre objet possède. Notre ordinateur nous permet de traiter des données, de surfer sur Internet, d'acquérir de nouvelles compétences, etc. Tout cela constitue les méthodes de notre objet.

Maintenant, nous avons défini ces termes afin de comprendre toutes les différentes propriétés que nous examinerons plus tard et les méthodes d'interaction que nous avons avec les objets. En comprenant comment PowerShell interprète les objets et utilise les Classes, nous pouvons définir nos propres types d'objets. Passons maintenant à la manière dont nous pouvons filtrer et trouver des objets via la CLI de PowerShell.

### Trouver et Filtrer des Objets

Examinons cela dans le contexte d'un `objet utilisateur`. Un utilisateur peut faire des choses comme accéder à des fichiers, exécuter des applications et entrer/sortir des données. Mais qu'est-ce qu'un utilisateur ? De quoi est-il composé ?

#### Obtenir un Objet (Utilisateur) et ses Propriétés/Méthodes

        powershell
`PS C:\htb> Get-LocalUser administrator | get-member     TypeName: Microsoft.PowerShell.Commands.LocalUser  Name                   MemberType Definition ----                   ---------- ---------- Clone                  Method     Microsoft.PowerShell.Commands.LocalUser Clone() Equals                 Method     bool Equals(System.Object obj) GetHashCode            Method     int GetHashCode() GetType                Method     type GetType() ToString               Method     string ToString() AccountExpires         Property   System.Nullable[datetime] AccountExpires {get;set;} Description            Property   string Description {get;set;} Enabled                Property   bool Enabled {get;set;} FullName               Property   string FullName {get;set;} LastLogon              Property   System.Nullable[datetime] LastLogon {get;set;} Name                   Property   string Name {get;set;} ObjectClass            Property   string ObjectClass {get;set;} PasswordChangeableDate Property   System.Nullable[datetime] PasswordChangeableDate {get;set;} PasswordExpires        Property   System.Nullable[datetime] PasswordExpires {get;set;} PasswordLastSet        Property   System.Nullable[datetime] PasswordLastSet {get;set;} PasswordRequired       Property   bool PasswordRequired {get;set;} PrincipalSource        Property   System.Nullable[Microsoft.PowerShell.Commands.PrincipalSource] PrincipalSource {ge... SID                    Property   System.Security.Principal.SecurityIdentifier SID {get;set;} UserMayChangePassword  Property   bool UserMayChangePassword {get;set;}`

Maintenant que nous pouvons voir toutes les propriétés d'un utilisateur, regardons à quoi ressemblent ces propriétés lorsqu'elles sont affichées par PowerShell. La cmdlet [Select-Object](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object?view=powershell-7.2) nous aidera à y parvenir. De cette manière, nous comprenons maintenant ce qui constitue un objet utilisateur.

#### Sortie des Propriétés (Toutes)

        powershell
`PS C:\htb> Get-LocalUser administrator | Select-Object -Property *   AccountExpires         : Description            : Built-in account for administering the computer/domain Enabled                : False FullName               : PasswordChangeableDate : PasswordExpires        : UserMayChangePassword  : True PasswordRequired       : True PasswordLastSet        : LastLogon              : 1/20/2021 5:39:14 PM Name                   : Administrator SID                    : S-1-5-21-3916821513-3027319641-390562114-500 PrincipalSource        : Local ObjectClass            : User`

Un utilisateur est un petit objet en réalité, mais il peut y avoir beaucoup de choses à regarder dans la sortie de cette manière, surtout pour des éléments comme de grandes `listes` ou des `tableaux`. Et si nous voulions filtrer ce contenu ou nous le montrer de manière plus précise ? Nous pourrions filtrer les propriétés d'un objet que nous ne voulons pas voir en sélectionnant les quelques-unes qui nous intéressent. Regardons nos utilisateurs et voyons lesquels ont défini un mot de passe récemment.

#### Filtrage sur les Propriétés

        powershell
`PS C:\htb> Get-LocalUser * | Select-Object -Property Name,PasswordLastSet  Name               PasswordLastSet ----               --------------- Administrator DefaultAccount Guest MTanaka              1/27/2021 2:39:55 PM WDAGUtilityAccount 1/18/2021 7:40:22 AM`

Nous pouvons également `trier` et `regrouper` nos objets sur ces propriétés.

#### Tri et Groupement

        powershell
`PS C:\htb> Get-LocalUser * | Sort-Object -Property Name | Group-Object -property Enabled  Count Name                      Group ----- ----                      -----     4 False                     {Administrator, DefaultAccount, Guest, WDAGUtilityAccount}     1 True                      {MTanaka}`

Nous avons utilisé les cmdlets `Sort-Object` et `Group-Object` pour trouver tous les utilisateurs, les `trier` par `nom`, puis les `regrouper` en fonction de leur propriété `Enabled`. D'après la sortie, nous pouvons voir que plusieurs utilisateurs sont désactivés et ne sont pas utilisés pour la connexion interactive. Ce n'est qu'un exemple rapide de ce qui peut être fait avec les objets PowerShell et de la quantité d'informations stockées dans chaque objet. À mesure que nous approfondirons PowerShell et que nous explorerons le système d'exploitation Windows, nous remarquerons que les classes derrière de nombreux objets sont étendues et souvent partagées. Gardez ces choses à l'esprit à mesure que nous travaillerons de plus en plus avec elles.

---

## Pourquoi avons-nous besoin de filtrer nos résultats ?

Nous changeons de sujet et utilisons un exemple de get-service pour cette démonstration. L'examen des utilisateurs et des informations de base ne produit pas beaucoup de résultats, mais d'autres objets contiennent une quantité extraordinaire de données. Vous trouverez ci-dessous un exemple d'un simple fragment de la sortie de Get-Service :

#### Trop de Sortie

        powershell
`PS C:\htb> Get-Service | Select-Object -Property *  Name                : AarSvc_1ca8ea RequiredServices    : {} CanPauseAndContinue : False CanShutdown         : False CanStop             : False DisplayName         : Agent Activation Runtime_1ca8ea DependentServices   : {} MachineName         : . ServiceName         : AarSvc_1ca8ea ServicesDependedOn  : {} ServiceHandle       : Status              : Stopped ServiceType         : 224 StartType           : Manual Site                : Container           :  Name                : AdobeARMservice RequiredServices    : {} CanPauseAndContinue : False CanShutdown         : False CanStop             : True DisplayName         : Adobe Acrobat Update Service DependentServices   : {} MachineName         : . ServiceName         : AdobeARMservice ServicesDependedOn  : {} ServiceHandle       : Status              : Running ServiceType         : Win32OwnProcess StartType           : Automatic Site                : Container           :  Name                : agent_ovpnconnect RequiredServices    : {} CanPauseAndContinue : False CanShutdown         : False CanStop             : True DisplayName         : OpenVPN Agent agent_ovpnconnect DependentServices   : {} MachineName         : . ServiceName         : agent_ovpnconnect ServicesDependedOn  : {} ServiceHandle       : Status              : Running ServiceType         : Win32OwnProcess StartType           : Automatic Site                : Container           :  <SNIP>`

C'est beaucoup trop de données à passer au crible, n'est-ce pas ? Détaillons davantage et formatons ces données sous forme de liste. Nous pouvons utiliser la chaîne de commande `get-service | Select-Object -Property DisplayName,Name,Status | Sort-Object DisplayName | fl` pour modifier notre sortie comme suit :

        powershell
`PS C:\htb> get-service | Select-Object -Property DisplayName,Name,Status | Sort-Object DisplayName | fl   <SNIP> DisplayName : ActiveX Installer (AxInstSV) Name        : AxInstSV Status      : Stopped  DisplayName : Adobe Acrobat Update Service Name        : AdobeARMservice Status      : Running  DisplayName : Adobe Genuine Monitor Service Name        : AGMService Status      : Running <SNIP>`

Cela représente toujours une tonne de sortie, mais c'est un peu plus lisible. C'est ici que nous commençons à nous poser des questions comme : avons-nous besoin de toute cette sortie ? Nous soucions-nous de tous ces objets ou seulement d'un sous-ensemble spécifique d'entre eux ? Et si nous voulions déterminer si un service spécifique était en cours d'exécution, mais que nous devions trouver son nom spécifique ? [Where-Object](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/where-object?view=powershell-7.2) peut évaluer les objets qui lui sont transmis et les valeurs de leurs propriétés spécifiques pour rechercher les informations dont nous avons besoin. Considérez ce `scénario` :

**Scénario : Nous venons d'obtenir un shell initial sur un hôte via un protocole non sécurisé exposant l'hôte au monde entier. Avant d'aller plus loin, nous devons évaluer l'hôte et déterminer si des services ou des applications de défense sont en cours d'exécution. D'abord, nous recherchons toute instance de services `Windows Defender` en cours d'exécution.**

L'utilisation de `Where-Object` (avec l'alias `where`) et de la correspondance de paramètres avec `-like` nous permettra de déterminer si nous pouvons continuer en toute sécurité en recherchant tout ce qui contient « `Defender` » dans la propriété. Dans ce cas, nous vérifions la propriété `DisplayName` de tous les objets récupérés par `Get-Service`.

#### À la recherche de Windows Defender

        powershell
`PS C:\htb>  Get-Service | where DisplayName -like '*Defender*'  Status   Name               DisplayName ------   ----               ----------- Running  mpssvc             Windows Defender Firewall Stopped  Sense              Windows Defender Advanced Threat Pr... Running  WdNisSvc           Microsoft Defender Antivirus Networ... Running  WinDefend          Microsoft Defender Antivirus Service`

Comme nous pouvons le voir, nos résultats ont renvoyé `plusieurs services en cours d'exécution`, y compris le pare-feu Defender, la protection avancée contre les menaces, et plus encore. C'est à la fois une bonne et une mauvaise nouvelle pour nous. Nous ne pouvons pas simplement nous lancer et commencer à faire des choses car nous risquons d'être repérés par les services de défense, mais il est bon que nous les ayons repérés et que nous puissions maintenant nous regrouper et élaborer un plan d'actions d'évasion défensive à entreprendre. Bien qu'il s'agisse d'un scénario d'exemple rapide, c'est quelque chose que nous, en tant que pentesters, rencontrerons souvent, et nous devrions être capables de repérer et d'identifier quand des mesures défensives sont en place. Cet exemple soulève cependant une manière intéressante de modifier nos recherches. Les valeurs d'évaluation peuvent être très utiles à notre cause. Examinons-les de plus près.

### L'évaluation des valeurs

`Where` et de nombreuses autres cmdlets peuvent `évaluer` des objets et des données en fonction des valeurs que ces objets et leurs propriétés contiennent. La sortie ci-dessus en est un excellent exemple, utilisant l'opérateur de comparaison `-like`. Il recherchera tout ce qui correspond aux valeurs exprimées et peut inclure des caractères génériques tels que `*`. Vous trouverez ci-dessous une liste rapide (non exhaustive) d'autres expressions utiles que nous pouvons utiliser :

#### Opérateurs de comparaison

|**Expression**|**Description**|
|---|---|
|`Like`|Like utilise des expressions avec des caractères génériques pour effectuer des correspondances. Par exemple, `'*Defender*'` correspondra à tout ce qui contient le mot Defender quelque part dans la valeur.|
|`Contains`|Contains trouvera l'objet si un élément de la valeur de la propriété correspond exactement à ce qui est spécifié.|
|`Equal to`|Spécifie une correspondance exacte (sensible à la casse) avec la valeur de la propriété fournie.|
|`Match`|Correspondance par expression régulière avec la valeur fournie.|
|`Not`|Spécifie une correspondance si la propriété est `vide` ou n'existe pas. Correspondra également à `$False`.|

Bien sûr, il existe de nombreux autres [opérateurs de comparaison](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7.2) que nous pouvons utiliser, comme supérieur à, inférieur à, et des négations comme NotEqual, mais dans ce type de recherche, ils ne sont peut-être pas aussi largement utilisés. Maintenant, avec une compréhension `-GTE` (supérieure ou égale à) de la façon dont ces opérateurs peuvent nous aider plus qu'avant (vous avez vu ce que j'ai fait là ?), revenons à l'exploration des services Defender. Nous allons maintenant rechercher des objets de service avec un `DisplayName` comme Defender.

#### Spécificités de Defender

        powershell
`PS C:\htb> Get-Service | where DisplayName -like '*Defender*' | Select-Object -Property *  Name                : mpssvc RequiredServices    : {mpsdrv, bfe} CanPauseAndContinue : False CanShutdown         : False CanStop             : False DisplayName         : Windows Defender Firewall DependentServices   : MachineName         : . ServiceName         : mpssvc ServicesDependedOn  : {mpsdrv, bfe} ServiceHandle       : Status              : Running ServiceType         : Win32ShareProcess StartType           : Automatic Site                : Container           :  Name                : Sense RequiredServices    : {} CanPauseAndContinue : False CanShutdown         : False CanStop             : False DisplayName         : Windows Defender Advanced Threat Protection Service <SNIP>`

Nos résultats ci-dessus filtrent maintenant tous les services associés à `Windows Defender` et affichent la liste complète des propriétés de chaque correspondance. Nous pouvons maintenant examiner les services, déterminer s'ils sont en cours d'exécution, et même si nous pouvons, à notre niveau de permission actuel, affecter le statut de ces services (les arrêter, les désactiver, etc.). Au cours de nombreuses commandes que nous avons passées dans les dernières sections, nous avons utilisé le symbole `|` pour concaténer plusieurs commandes que nous aurions normalement passées séparément. Ci-dessous, nous discuterons de ce que c'est et de comment cela fonctionne pour nous.

---

## Qu'est-ce que le Pipeline PowerShell ? ( | )

Dans sa forme la plus simple, le [Pipeline](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.2) (canal de traitement) dans PowerShell fournit à l'utilisateur final un moyen d'enchaîner des commandes. Cette chaîne est appelée un Pipeline et est également désignée par les termes « pipe » ou « piping » (enchaînement de commandes). Avec la manière dont PowerShell gère les objets, nous pouvons émettre une commande puis envoyer (`|`) la sortie de l'objet résultant à une autre commande pour action. Le Pipeline interprétera et exécutera les commandes une par une, de gauche à droite. Nous l'avons fait dans quelques exemples des sections précédentes, nous allons donc l'approfondir ici. À titre d'exemple, l'utilisation du Pipeline pour enchaîner des commandes peut ressembler à ceci :

#### Enchaîner des commandes (Piping)

        powershell
`PS C:\htb> Command-1 | Command-2 | Command-3  Output from the result of 1+2+3`  

`OU`

        powershell
`PS C:\htb>  Command-1 |   Command-2 |     Command-3    Output result from Pipeline`

`OU`

        powershell
`PS C:\htb> Get-Process | Where-Object CPU | Where-Object Path |      Get-Item     Output result from Pipeline`  

Chaque manière est parfaitement acceptable pour concaténer les commandes. PowerShell peut interpréter ce que vous voulez en fonction de la position du (`|`) dans la chaîne. Voyons un exemple d'utilisation du pipeline pour nous fournir des données exploitables. Ci-dessous, nous allons exécuter la cmdlet `Get-Process`, `trier` les données résultantes, puis mesurer combien de processus `uniques` nous avons en cours d'exécution sur notre hôte.

#### Utiliser le Pipeline pour Compter les Instances Uniques

        powershell
`PS C:\htb> get-process | sort | unique | measure-object  Count             : 113`  

En conséquence, le pipeline a affiché le nombre total (`113`) de processus uniques en cours d'exécution à ce moment-là. Si nous décomposons le pipeline à un point particulier, nous pourrions voir la sortie des processus triée, filtrée pour les instances uniques (pas de noms en double), ou simplement un nombre affiché par la cmdlet `Measure-Object`. La tâche que nous avons effectuée était relativement simple. Cependant, et si nous pouvions exploiter cela pour quelque chose de plus complexe, comme trier de nouvelles entrées de journal, filtrer pour des codes d'événements spécifiques, ou traiter de grandes quantités de données (une base de données et toutes ses entrées, par exemple) à la recherche de chaînes spécifiques ? C'est là que le Pipeline peut augmenter notre productivité et rationaliser la sortie que nous recevons, ce qui en fait un outil vital pour tout administrateur système ou pentester.

### Opérateurs de chaîne de Pipeline ( `&&` et `||` )

Actuellement, Windows PowerShell 5.1 et les versions antérieures ne prennent pas en charge les opérateurs de chaîne de Pipeline utilisés de cette manière. Si vous voyez des erreurs, vous devez installer PowerShell 7 en parallèle de Windows PowerShell. Ce ne sont pas les mêmes choses.

Vous pouvez trouver un excellent exemple d'installation de PowerShell 7 [ici](https://www.thomasmaurer.ch/2019/07/how-to-install-and-update-powershell-7/) afin de pouvoir utiliser de nombreuses fonctionnalités nouvelles et mises à jour. PowerShell nous permet d'avoir une exécution conditionnelle des pipelines grâce à l'utilisation des `opérateurs de chaîne`. Ces opérateurs ( `&&` et `||` ) ont deux fonctions principales :

- `&&` : Définit une condition dans laquelle PowerShell exécutera la prochaine commande en ligne `si` la commande actuelle `s'exécute correctement`.
- `||` : Définit une condition dans laquelle PowerShell exécutera la commande suivante en ligne `si` la commande actuelle `échoue`.

Ces opérateurs peuvent être utiles pour nous aider à définir des conditions pour des scripts qui s'exécutent si un objectif ou une condition est atteint. Par exemple :

**Scénario :** Disons que nous écrivons une chaîne de commandes où nous voulons obtenir le contenu d'un fichier, puis envoyer un ping à un hôte. Nous pouvons configurer cela pour envoyer un ping à l'hôte si la commande initiale réussit avec `&&` ou pour ne s'exécuter que si la commande échoue avec `||`. Voyons les deux cas.

Dans cette sortie, nous pouvons voir que les deux commandes ont été `exécutées avec succès` car nous obtenons la sortie du fichier `test.txt` imprimée sur la console ainsi que les résultats de notre commande `ping`.

#### Pipeline réussi

        powershell
`PS C:\htb> Get-Content '.\test.txt' && ping 8.8.8.8 pass or fail  Pinging 8.8.8.8 with 32 bytes of data: Reply from 8.8.8.8: bytes=32 time=23ms TTL=118 Reply from 8.8.8.8: bytes=32 time=28ms TTL=118 Reply from 8.8.8.8: bytes=32 time=28ms TTL=118 Reply from 8.8.8.8: bytes=32 time=21ms TTL=118  Ping statistics for 8.8.8.8:     Packets: Sent = 4, Received = 4, Lost = 0 (0% loss), Approximate round trip times in milli-seconds:     Minimum = 21ms, Maximum = 28ms, Average = 25ms`

Avec cette sortie, nous pouvons voir que notre pipeline s'est `fermé` après la `première` commande puisqu'elle s'est exécutée correctement, imprimant la sortie du fichier sur la console.

#### Arrêter sauf en cas d'échec

        powershell
`PS C:\htb>  Get-Content '.\test.txt' || ping 8.8.8.8  pass or fail`

Ici, nous pouvons voir que notre pipeline s'est exécuté `complètement`. Notre première commande a `échoué` car le nom de fichier a été mal tapé, et PowerShell considère que le fichier que nous avons demandé n'existe pas. Comme la première commande a échoué, notre deuxième commande a été exécutée.

#### Succès dans l'échec

        powershell
`PS C:\htb> Get-Content '.\testss.txt' || ping 8.8.8.8  Get-Content: Cannot find path 'C:\Users\MTanaka\Desktop\testss.txt' because it does not exist.  Pinging 8.8.8.8 with 32 bytes of data: Reply from 8.8.8.8: bytes=32 time=20ms TTL=118 Reply from 8.8.8.8: bytes=32 time=37ms TTL=118 Reply from 8.8.8.8: bytes=32 time=19ms TTL=118  <SNIP>`

Le `pipeline` et les `opérateurs` que nous avons utilisés nous sont très utiles du point de vue du gain de temps, ainsi que pour pouvoir rapidement transmettre des objets et des données d'une tâche à une autre. Lancer plusieurs commandes en ligne est beaucoup plus efficace que de lancer manuellement chaque commande. Et si nous voulions rechercher des `chaînes de caractères` ou des `données` dans le contenu de fichiers et de répertoires ? C'est une tâche courante que de nombreux pentesters effectueront lors de l'énumération d'un hôte auquel ils ont obtenu l'accès. La recherche avec ce qui est nativement sur l'hôte est un excellent moyen de maintenir notre furtivité et de nous assurer que nous n'introduisons pas de nouveaux risques en important des outils dans l'environnement utilisateur.

---

## Trouver des données dans le contenu

Il existe des outils, comme `Snaffler`, `Winpeas`, et d'autres, qui peuvent rechercher des fichiers et des chaînes de caractères intéressants, mais que se passe-t-il si nous ne `pouvons pas` importer un nouvel outil sur l'hôte ? Comment pouvons-nous chasser des informations sensibles comme des identifiants, des clés, etc. ? Combiner les cmdlets que nous avons pratiquées dans les sections précédentes avec de nouvelles cmdlets comme `Select-String` et `where` est une excellente façon pour nous de fouiller dans un système de fichiers.

[Select-String](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-string?view=powershell-7.2) (avec l'alias `sls`), pour ceux qui sont plus familiers avec la CLI Linux, fonctionne de la même manière que `Grep` ou `findstr.exe` dans l'invite de commandes Windows. Il effectue des évaluations de chaînes d'entrée, de contenus de fichiers, et plus encore, basées sur la correspondance de motifs d'expression régulière (`regex`). Lorsqu'une correspondance est trouvée, `Select-String` affiche par défaut la `ligne` correspondante, le `nom` du fichier et le `numéro de ligne` où elle a été trouvée. Dans l'ensemble, c'est une cmdlet flexible et utile qui devrait être dans la boîte à outils de tout le monde. Ci-dessous, nous allons tester notre nouvelle cmdlet en cherchant des informations dans certains fichiers et répertoires intéressants auxquels il faut prêter attention lors de l'énumération d'un hôte.

### Trouver des fichiers intéressants dans un répertoire

Lorsque vous recherchez des fichiers intéressants, pensez aux types de fichiers les plus courants que nous utiliserions quotidiennement et commencez par là. Un jour donné, nous pouvons écrire des fichiers texte, un peu de Markdown, du Python, du PowerShell, et bien d'autres. Nous voulons rechercher ces éléments lorsque nous explorons un hôte, car c'est là que les utilisateurs et les administrateurs interagissent le plus. Nous pouvons commencer avec `Get-ChildItem` et effectuer une recherche récursive dans un dossier. Testons cela.

#### Début de la chasse

        powershell
`PS C:\htb> Get-ChildItem -Path C:\Users\MTanaka\ -File -Recurse    Directory: C:\Users\MTanaka\Desktop\notedump\NoteDump  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a---           4/26/2022  1:47 PM           1092 demo notes.md -a---           4/22/2022  2:20 PM           1074 noteDump.py -a---           4/22/2022  2:55 PM          61440 plum.sqlite -a---           4/22/2022  2:20 PM            375 README.md <SNIP>`

Nous remarquerons qu'il renvoie rapidement beaucoup trop d'informations. Chaque fichier dans chaque dossier du chemin spécifié a été affiché dans notre console. Nous devons réduire un peu cela. Utilisons la condition de rechercher dans le `nom` des `extensions de type de fichier` spécifiques. Pour ce faire, nous allons envoyer la sortie de Get-ChildItem à travers la cmdlet `where` pour filtrer notre sortie. Testons d'abord en recherchant l'extension de type de fichier `*.txt`.

#### Affiner notre recherche

        powershell
`PS C:\htb> Get-Childitem –Path C:\Users\MTanaka\ -File -Recurse -ErrorAction SilentlyContinue | where {($_.Name -like "*.txt")}  Directory: C:\Users\MTanaka\Desktop  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a---          10/11/2022  3:32 PM            183 demo-notes.txt -a---            4/4/2022  9:37 AM            188 q2-to-do.txt -a---          10/12/2022 11:26 AM             14 test.txt -a---            1/4/2022 11:23 PM            310 Untitled-1.txt      Directory: C:\Users\MTanaka\Desktop\win-stuff  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a---           5/19/2021 10:12 PM           7831 wmic.txt      Directory: C:\Users\MTanaka\Desktop\Workshop\  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -----            1/7/2022  4:39 PM            945 info.txt`

Cela a fonctionné de manière beaucoup plus efficace. Nous n'avons renvoyé que les fichiers qui correspondaient au type de fichier `txt` en raison de l'attribut `$_.Name` de notre filtre. Maintenant que nous savons que cela fonctionne, nous pouvons ajouter le reste des types de fichiers que nous rechercherons en utilisant une instruction `-or` dans le filtre where.

#### Utiliser `Or` pour étendre notre chasse au trésor

        powershell
`PS C:\htb> Get-Childitem –Path C:\Users\MTanaka\ -File -Recurse -ErrorAction SilentlyContinue | where {($_.Name -like "*.txt" -or $_.Name -like "*.py" -or $_.Name -like "*.ps1" -or $_.Name -like "*.md" -or $_.Name -like "*.csv")}   Directory: C:\Users\MTanaka\Desktop  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a---          10/11/2022  3:32 PM            183 demo-notes.txt -a---          10/11/2022 10:22 AM           1286 github-creds.txt -a---            4/4/2022  9:37 AM            188 q2-to-do.txt -a---           9/18/2022 12:35 PM             30 notes.txt -a---          10/12/2022 11:26 AM             14 test.txt -a---           2/14/2022  3:40 PM           3824 remote-connect.ps1 -a---          10/11/2022  8:22 PM            874 treats.ps1 -a---            1/4/2022 11:23 PM            310 Untitled-1.txt      Directory: C:\Users\MTanaka\Desktop\notedump\NoteDump  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a---           4/26/2022  1:47 PM           1092 demo.md -a---           4/22/2022  2:20 PM           1074 noteDump.py -a---           4/22/2022  2:20 PM            375 README.md`

Notre chaîne de caractères a fonctionné, et nous récupérons maintenant `plusieurs types de fichiers` avec Get-ChildItem ! Maintenant que nous avons notre liste de fichiers intéressants, nous pourrions à notre tour `envoyer` ces objets à une autre cmdlet (`Select-String`) qui recherche dans leur contenu des chaînes de caractères et des mots-clés ou phrases intéressants. Voyons cela en action.

#### Requête de recherche de base

        powershell
`PS C:\htb> Get-ChildItem -Path C:\Users\MTanaka\ -Filter "*.txt" -Recurse -File | sls "Password","credential","key"  CFP-Notes.txt:99:Lazzaro, N. (2004). Why we play games: Four keys to more emotion without story. Retrieved from: notes.txt:3:- Password: F@ll2022! wmic.txt:67:  wmic netlogin get name,badpasswordcount wmic.txt:69:Are the screensavers password protected? What is the timeout? good use: see that all systems are complying with policy evil use: find systems to walk up and use (assuming physical access is an option)`

Gardez à l'esprit que Select-string n'est `pas` sensible à la casse par défaut. Si nous souhaitons qu'il le soit, nous pouvons lui fournir le modificateur -CaseSensitive. Maintenant, nous allons combiner notre recherche de fichiers originale avec notre filtre de contenu.

#### Combiner les recherches

        powershell
`PS C:\htb> Get-Childitem –Path C:\Users\MTanaka\ -File -Recurse -ErrorAction SilentlyContinue | where {($_. Name -like "*.txt" -or $_. Name -like "*.py" -or $_. Name -like "*.ps1" -or $_. Name -like "*.md" -or $_. Name -like "*.csv")} | sls "Password","credential","key","UserName"  New-PC-Setup.md:56:  - getting your vpn key CFP-Notes.txt:99:Lazzaro, N. (2004). Why we play games: Four keys to more emotion without story. Retrieved from: notes.txt:3:- Password: F@ll2022! wmic.txt:54:  wmic computersystem get username wmic.txt:67:  wmic netlogin get name,badpasswordcount wmic.txt:69:Are the screensavers password protected? What is the timeout? good use: see that all systems are complying with policy evil use: find systems to walk up and use (assuming physical access is an option) wmic.txt:83:  wmic netuse get Name,username,connectiontype,localname`

Nos commandes dans le pipeline s'allongent, mais nous pouvons facilement nettoyer notre vue pour la rendre lisible. En regardant nos résultats, cependant, c'était un processus beaucoup plus fluide de transmettre notre liste de fichiers à notre recherche de mots-clés. Remarquez qu'il y a quelques `nouveaux` ajouts dans notre chaîne de commande. Nous avons ajouté une ligne pour que la commande continue si une erreur se produit (`-ErrorAction SilentlyContinue`). Cela nous aide à garantir que l'ensemble de notre pipeline reste intact lorsqu'il rencontre un fichier ou un répertoire qu'il ne peut pas lire. Trouver et filtrer du contenu peut être un puzzle intéressant en soi. Déterminer quels mots et chaînes produiront les meilleurs résultats est une tâche en constante évolution et variera souvent en fonction du client.

### Répertoires utiles à vérifier

En cherchant des fichiers de valeur et d'autres contenus, nous pouvons vérifier de nombreux autres fichiers utiles dans de nombreux endroits différents. La liste ci-dessous contient juste quelques conseils et astuces qui peuvent être utilisés dans notre recherche de butin.

- Regarder dans le dossier `\AppData\` d'un utilisateur est un excellent point de départ. De nombreuses applications y stockent des `fichiers de configuration`, des `sauvegardes temporaires` de documents, et plus encore.
- Le dossier personnel d'un utilisateur `C:\Users\User\` est un lieu de stockage courant ; des éléments comme les clés VPN, les clés SSH, et plus encore y sont stockés. Généralement dans des dossiers `cachés`. (`Get-ChildItem -Hidden`)
- Les fichiers d'historique de la console conservés par l'hôte sont une source inépuisable d'informations, surtout si vous atterrissez sur l'hôte d'un administrateur. Vous pouvez vérifier deux points différents :
    - `C:\Users\<USERNAME>\AppData\Roaming\Microsoft\Windows\Powershell\PSReadline\ConsoleHost_history.txt`
    - `Get-Content (Get-PSReadlineOption).HistorySavePath`
- Vérifier le presse-papiers d'un utilisateur peut également fournir des informations utiles. Vous pouvez le faire avec `Get-Clipboard`
- L'examen des tâches planifiées peut également être utile.

Ce ne sont que quelques endroits intéressants à vérifier. Utilisez-le comme point de départ pour construire et maintenir votre propre liste de contrôle à mesure que vos compétences et vos expériences s'accroissent.

---

Notre Kung Fu de la CLI se développe rapidement, et il est temps de passer au prochain défi. À mesure que vous progressez, veuillez essayer les exemples montrés par vous-même pour vous faire une idée de ce qui peut être fait et de la manière dont vous pouvez les modifier. Nous allons nous plonger dans le travail avec les services et les processus pour notre prochaine leçon.