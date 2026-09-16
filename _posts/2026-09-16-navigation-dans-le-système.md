[[Command Prompt Basics]]
Jusqu'à présent, la plupart de ce que nous avons abordé sont des informations d'introduction pour nous aider à obtenir une compréhension et une sensation de base de l'Invite de commandes (Command Prompt). En poursuivant sur cette lancée, notre prochain objectif devrait être d'utiliser notre Invite de commandes pour `naviguer` et nous déplacer avec succès dans le système. Dans cette section, nous tenterons de maîtriser notre environnement en :

- Listant le contenu d'un répertoire
- Se situant dans le système
- Se déplaçant avec CD
- Explorant le système de fichiers

De plus, à la fin de la section, nous examinerons brièvement certains répertoires sur un hôte Windows qui pourraient sembler intéressants du point de vue de l'adversaire. En gardant tout cela à l'esprit, plongeons-nous dans le vif du sujet et explorons le système ensemble.

---

## Lister le contenu d'un répertoire

L'une des choses les plus simples que nous puissions faire lorsque nous explorons initialement un hôte Windows est d'obtenir la liste du contenu du répertoire dans lequel nous travaillons actuellement. Nous le faisons avec la commande `dir`.

        cmd
`C:\Users\htb\Desktop> dir     Volume in drive C has no label.  Volume Serial Number is DAE9-5896   Directory of C:\Users\htb\Desktop  06/11/2021  11:59 PM    <DIR>          . 06/11/2021  11:59 PM    <DIR>          .. 06/11/2021  11:57 PM                 0 file1.txt 06/11/2021  11:57 PM                 0 file2.txt 06/11/2021  11:57 PM                 0 file3.txt 04/13/2021  11:24 AM             2,391 Microsoft Teams.lnk 06/11/2021  11:57 PM                 0 super-secret-sauce.txt 06/11/2021  11:59 PM                 0 write-secrets.ps1                6 File(s)          2,391 bytes                2 Dir(s)  35,102,117,888 bytes free`

Comme le montre l'exemple ci-dessus, `dir` est une commande facile à utiliser et étonnamment polyvalente. Le simple fait d'appeler la commande sans aucun argument nous donnera une liste de notre répertoire actuel et de son contenu. Comme indiqué dans la section [Obtenir de l'aide](https://academy.hackthebox.com/app/module/167/section/1607), nous pouvons également utiliser l'argument `/?` pour nous fournir une liste complète des fonctionnalités de dir et de tous les arguments supplémentaires que nous pouvons fournir pour utiliser ses capacités de recherche avancées. Dans une section ultérieure, nous discuterons plus en détail de la signification de la sortie ci-dessus et de la manière dont nous pouvons utiliser `dir` pour nous aider dans notre recherche de fichiers et de répertoires importants. Pour l'instant, comprendre l'utilisation de base de `dir` nous fournira une utilité plus que suffisante pour nous déplacer efficacement dans le système.

---

## Se situer dans le système

Avant de faire quoi que ce soit sur un hôte, il est utile de savoir où nous nous trouvons dans le système de fichiers. Nous pouvons le déterminer en utilisant les commandes `cd` ou `chdir`.

        cmd
`C:\htb> cd   C:\htb`  

Comme le montre l'exemple ci-dessus, l'exécution de la commande sans arguments nous donne notre `répertoire de travail courant` (current working directory). Notre répertoire de travail courant est notre point de départ initial. Il décrit notre répertoire actuel comme celui dans lequel nous travaillons. Toute(s) commande(s) exécutée(s) ici sans spécifier le chemin d'un autre répertoire ou fichier fera référence à ce point initial. C'est très important, étant donné que tout ce que nous ferons à l'avenir fera référence à notre répertoire de travail courant, sauf indication contraire.

---

## Se déplacer avec CD/CHDIR

Alors que nous étions occupés à nous situer dans le système, nous avons introduit les commandes `cd` et `chdir`. Cependant, nous n'avons exploré la fonctionnalité complète d'aucune d'entre elles. En plus de lister notre répertoire actuel, toutes deux ont une fonction supplémentaire. Ces commandes nous déplaceront vers le répertoire que nous spécifions après la commande. Le répertoire spécifié peut être soit un répertoire relatif à notre répertoire de travail courant, soit un répertoire absolu partant de la racine du système de fichiers.

Ceux qui sont familiers avec `Linux` devraient commencer à reconnaître cette structure et être familiers avec la différence entre les `chemins relatifs` (relative paths) et les `chemins absolus` (absolute paths). Cependant, en supposant que nous n'ayons pas encore rencontré l'un de ces termes, montrons rapidement la différence à l'aide des exemples suivants :

#### Répertoire de travail courant

        cmd
`C:\htb> cd   C:\htb`  

Cela devrait vous sembler familier, n'est-ce pas ? C'est le même exemple que celui utilisé dans la section précédente. Développons un peu cela. Premièrement, nous devons définir notre répertoire `racine` (root). Pour faire simple, pensez au répertoire `racine` comme le répertoire le plus haut dans la structure, car il contient tout le reste. Dans cet exemple, notre répertoire `racine` est `C:\`.

**Note :** `C:\` est le répertoire racine de toutes les machines Windows et a été déterminé ainsi depuis sa création à l'époque de MS-DOS et Windows 3.0. La désignation "C:\" était couramment utilisée car "A:\" et "B:\" étaient généralement reconnus comme des lecteurs de disquettes, tandis que "C:\" était reconnu comme le premier disque dur interne de la machine.

#### Chemin absolu

        cmd
`C:\htb> cd C:\Users\htb\Pictures  C:\Users\htb\Pictures>` 

Dans cet exemple, nous pouvons voir que notre répertoire de travail initial est situé dans `C:\htb`. Nous avons utilisé `cd` et fourni le chemin comme argument pour nous déplacer vers le répertoire `C:\Users\htb\Pictures`. Comme nous pouvons le voir, le chemin fourni commence par `C:\` car c'est le répertoire racine et suit la structure jusqu'à ce qu'il atteigne sa destination, qui est le répertoire `\Pictures`. En assemblant les pièces, nous pouvons conclure que `C:\Users\htb\Pictures` serait considéré comme le `chemin absolu` dans ce cas, car il suit la structure complète du système de fichiers en partant du répertoire `racine` et en se terminant au répertoire de destination.

#### Chemin relatif

        cmd
`C:\htb> cd .\Pictures  C:\Users\htb\Pictures>` 

D'un autre côté, en suivant cet exemple, nous pouvons voir que quelque chose est légèrement différent dans la manière dont notre chemin est spécifié dans la commande `cd`. Au lieu de commencer par le répertoire `racine`, nous sommes accueillis par un `.` suivi du répertoire de destination (`\Pictures`). Le caractère `.` pointe vers un répertoire en dessous de notre répertoire de travail courant (`C:\htb`). Utiliser notre répertoire de travail comme point de départ pour référencer des répertoires soit au-dessus, soit en dessous dans la hiérarchie du système de fichiers est considéré comme un `chemin relatif`, car sa position est relative au répertoire de travail courant.

Comprendre ces deux termes est impératif car nous pouvons utiliser efficacement cette connaissance de la hiérarchie du système de fichiers pour monter et descendre facilement dans la structure de fichiers. Nous pouvons tout assembler avec un dernier exemple pour montrer à quelle vitesse nous pouvons utiliser ce que nous avons appris jusqu'à présent pour nous déplacer dans le système.

Nous sommes actuellement dans le répertoire `C:\Users\htb\Pictures` fourni dans notre exemple précédent. Cependant, nous souhaitons revenir rapidement à la racine du système de fichiers en une seule commande. Pour ce faire, nous pouvons effectuer ce qui suit :

        cmd
`C:\Users\htb\Pictures>  cd ..\..\..\  C:\>`

Cette seule commande nous permet de remonter dans la structure des répertoires, en partant du répertoire `\Pictures` et en remontant jusqu'au répertoire `racine` d'un seul coup. Plutôt chouette, non ? Comprendre ce concept fondamental sera très important pour la suite, nous devrions donc nous entraîner et nous familiariser dès maintenant pendant que nous en avons l'occasion.

---

## Explorer le système de fichiers

En utilisant nos nouvelles compétences, nous devrions nous aventurer et explorer le système sérieusement. Une exploration approfondie est essentielle, car elle peut nous aider à obtenir un avantage considérable dans la compréhension de l'organisation du système avec lequel nous interagissons et des fichiers qu'il contient. Cependant, lorsque l'on parcourt le système de fichiers d'un hôte Windows, il peut devenir fastidieux de changer de répertoire constamment ou d'exécuter la commande `dir` pour chaque sous-répertoire. Pour nous faire gagner un peu de temps et gagner en efficacité, nous pouvons obtenir un affichage de l'ensemble du chemin que nous spécifions et de ses sous-répertoires en utilisant la commande `tree`.

#### Lister le contenu du système de fichiers

        cmd
`C:\htb\student\> tree  Folder PATH listing Volume serial number is 26E7-9EE4 C:. ├───3D Objects ├───Contacts ├───Desktop ├───Documents ├───Downloads ├───Favorites │   └───Links ├───Links ├───Music ├───OneDrive ├───Pictures │   ├───Camera Roll │   └───Saved Pictures ├───Saved Games ├───Searches └───Videos     └───Captures`

Du point de vue d'un hacker, cela peut être super utile lors de la recherche de fichiers et de dossiers contenant des informations intéressantes que nous pourrions vouloir, comme des configurations, des fichiers et des dossiers de projet, et peut-être même le Saint Graal, un fichier ou un dossier contenant des mots de passe. Nous pouvons utiliser le paramètre `/F` avec la commande tree pour voir une liste de chaque fichier et des répertoires ainsi que l'arborescence des répertoires du chemin.

#### Tree /F

        cmd
`C:\htb\student\> tree /F  Folder PATH listing Volume serial number is 26E7-9EE4 C:. ├───3D Objects ├───Contacts ├───Desktop │       passwords.txt.txt │       Project plans.txt │       secrets.txt │ ├───Documents ├───Downloads ├───Favorites │   │   Bing.URL │   │ │   └───Links ├───Links │       Desktop.lnk │       Downloads.lnk │ ├───Music ├───OneDrive ├───Pictures │   ├───Camera Roll │   └───Saved Pictures ├───Saved Games ├───Searches │       winrt--{S-1-5-21-1588464669-3682530959-1994202445-1000}-.searchconnector-ms │ └───Videos     └───Captures      <SNIP>`

À partir de cet exemple, nous pouvons rapidement nous faire une idée du système et voir des fichiers intéressants tels que `passwords.txt.txt` et `secrets.txt`. Bien sûr, comme cela effectue une liste complète de chaque fichier et répertoire sur un système, nous devons être conscients de la quantité de sortie que cette commande va générer. Plus tard dans le module, nous apprendrons une manière plus gérable de gérer la sortie et de travailler avec d'autres applications en ligne de commande pour la manipuler dans un format beaucoup plus souhaitable. Pour l'instant, sachez qu'après avoir tenté d'exécuter cette commande, nous devrions probablement interrompre son exécution en utilisant `Ctrl-C` après avoir récupéré les informations souhaitées.

---

## Répertoires intéressants

Comme promis, nous avons presque atteint la fin de cette section. Avec nos compétences actuelles, la navigation dans le système devrait être beaucoup plus accessible qu'il n'y paraissait au départ. Prenons une minute pour discuter de certains répertoires qui peuvent s'avérer utiles du point de vue d'un attaquant sur un système. Vous trouverez ci-dessous un tableau des répertoires courants qu'un attaquant peut abuser pour déposer des fichiers sur le disque, effectuer de la reconnaissance et aider à faciliter la cartographie de la surface d'attaque sur un hôte cible.

|Nom :|Emplacement :|Description :|
|---|---|---|
|%SYSTEMROOT%\Temp|`C:\Windows\Temp`|Répertoire global contenant les fichiers système temporaires accessibles à tous les utilisateurs du système. Tous les utilisateurs, quel que soit leur niveau d'autorité, disposent des autorisations complètes de lecture, d'écriture et d'exécution dans ce répertoire. Utile pour déposer des fichiers en tant qu'utilisateur à faibles privilèges sur le système.|
|%TEMP%|`C:\Users\<user>\AppData\Local\Temp`|Répertoire local contenant les fichiers temporaires d'un utilisateur, accessible uniquement au compte utilisateur auquel il est rattaché. Fournit la pleine propriété à l'utilisateur qui possède ce dossier. Utile lorsque l'attaquant prend le contrôle d'un compte utilisateur local ou joint à un domaine.|
|%PUBLIC%|`C:\Users\Public`|Répertoire accessible publiquement permettant à tout compte de connexion interactive un accès complet pour lire, écrire, modifier, exécuter, etc., les fichiers et sous-dossiers dans le répertoire. Alternative au répertoire Temp global de Windows car il est moins susceptible d'être surveillé pour une activité suspecte.|
|%ProgramFiles%|`C:\Program Files`|Dossier contenant toutes les applications 64 bits installées sur le système. Utile pour voir quel type d'applications sont installées sur le système cible.|
|%ProgramFiles(x86)%|`C:\Program Files (x86)`|Dossier contenant toutes les applications 32 bits installées sur le système. Utile pour voir quel type d'applications sont installées sur le système cible.|

Le tableau fourni ci-dessus n'est en aucun cas une liste exhaustive de tous les répertoires intéressants sur un hôte Windows. Cependant, ceux-ci seront probablement ciblés car ils sont utiles aux attaquants.

À la fin de cette section, nous sommes devenus compétents pour nous déplacer dans le système de fichiers Windows et comprendre où nous nous trouvons par rapport aux autres répertoires et fichiers du système. Dans la section suivante, nous discuterons de la collecte d'informations sur le système pour nous fournir une solide compréhension de notre environnement.
LAB de fin 

![Pasted image 20260830231058.png](/assets/img/writeups/Pasted image 20260830231058.png) 
rep : tree /f  ou  tree /F 

![Pasted image 20260830231136.png](/assets/img/writeups/Pasted image 20260830231136.png)
rep : cd 
