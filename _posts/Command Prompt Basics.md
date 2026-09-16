[[Introduction to Windows Command Line]]

Le premier pas dans le terrier du lapin pour développer notre kung-fu de la ligne de commande est de plonger dans `cmd.exe` (l'application Invite de commandes). Commençons notre entraînement de niveau ceinture blanche en examinant ce qu'est cmd.exe, comment y accéder et comment le shell fonctionne.

---

## CMD.exe

L'invite de commandes, également connue sous le nom de [cmd.exe](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cmd) ou CMD, est l'interpréteur de ligne de commande par défaut du système d'exploitation Windows. Initialement basé sur l'interpréteur `COMMAND.COM` de DOS, l'invite de commandes est omniprésente sur presque tous les systèmes d'exploitation Windows. Elle permet aux utilisateurs de saisir des commandes qui sont directement interprétées puis exécutées par le système d'exploitation. Une seule commande peut accomplir des tâches telles que la modification du mot de passe d'un utilisateur ou la vérification de l'état des interfaces réseau. Cela réduit également les ressources système, car les programmes basés sur une interface graphique nécessitent plus de CPU et de mémoire.

Bien que souvent éclipsée par son homologue élégant [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.2), la connaissance de cmd.exe et de ses commandes continue de porter ses fruits, même à l'heure actuelle.

**`Petite histoire :`** Plusieurs fois, lors d'un test d'intrusion (pentest), j'ai rencontré des hôtes sur lesquels PowerShell était assez bien verrouillé ou rendu complètement inaccessible par un contrôle d'application tel qu'AppLocker. En utilisant l'invite de commandes, j'ai quand même pu tirer parti de l'hôte pour obtenir un accès supplémentaire et élever mes privilèges afin de poursuivre l'évaluation. Les systèmes d'exploitation modernes ont encore de nombreux logiciels hérités intégrés dans les hôtes. En tant qu'administrateurs et évaluateurs, nous devons en être conscients et comprendre comment les utiliser à notre avantage.

---

## Accéder à CMD

Avant de pouvoir nous plonger dans l'utilisation de base de l'invite de commandes, nous devons d'abord et avant tout répondre à une question fondamentale.

`Comment accéder à l'invite de commandes ?`

Il existe plusieurs façons d'accéder à l'invite de commandes sur un système Windows. La manière dont vous souhaitez y accéder est une question de préférence personnelle et dépend également de critères spécifiques en fonction des ressources disponibles à ce moment-là. Avant d'expliquer ces critères, il y a quelques concepts essentiels à expliquer en premier.

#### Accès local vs. Accès à distance

Pour mieux expliquer ces concepts, prenons un peu de recul et souvenons-nous de notre scénario précédent :

**Scénario :** Nous sommes l'administrateur système de notre entreprise. Dans le cadre de nos tâches et attentes quotidiennes, nous devons accéder à des machines depuis le siège principal de notre entreprise et une succursale située dans une autre région pour effectuer la maintenance générale et résoudre les problèmes techniques. Imaginons qu'un utilisateur rencontre un problème avec sa machine et que l'on vous appelle pour l'aider. `Quelle est la meilleure façon d'accéder à sa machine pour résoudre son problème le plus efficacement possible ?`

Plusieurs scénarios sont ici possibles en fonction des questions que nous nous posons. L'utilisateur se trouve-t-il dans la même région que nous ? L'utilisateur est-il dans le même bâtiment ? Le bureau de l'utilisateur est-il à une distance de marche raisonnable ? L'utilisateur est-il activement connecté et en train de travailler sur sa machine ? Ces questions entreront généralement en ligne de compte dans notre décision, du point de vue d'un administrateur système, sur la manière dont nous tenterons d'accéder à la machine en question. Cependant, nous nous avançons un peu, alors décrivons ce qu'implique l'accès à une machine et les types d'accès disponibles.

De manière générale, l'accès à un ordinateur peut être classé en deux catégories principales :

#### Accès local

L'accès local est synonyme d'un accès physique direct (ou virtuel dans le cas d'une Machine Virtuelle (VM)) à la machine elle-même. Ce niveau d'accès ne nécessite pas que la machine soit connectée à un réseau, car on peut y accéder directement via les périphériques (moniteur, souris, clavier, etc.) connectés à la machine. Depuis le bureau, nous pouvons ouvrir l'invite de commandes en :

- Utilisant la touche Windows + `r` pour ouvrir la fenêtre Exécuter, puis en tapant `cmd`. OU
- Accédant à l'exécutable depuis le chemin `C:\Windows\System32\cmd.exe`.

#### Accès initial à cmd.exe

        cmd
`Microsoft Windows [Version 10.0.19044.2006] (c) Microsoft Corporation. All rights reserved.  C:\Users\htb>`

Nous pouvons exécuter nos commandes, scripts ou autres actions selon les besoins.

#### Accès à distance :

D'un autre côté, l'accès à distance est l'équivalent de l'accès à la machine en utilisant des périphériques virtuels sur le réseau. Ce niveau d'accès ne nécessite pas d'accès physique direct à la machine, mais exige que l'utilisateur soit connecté au même réseau ou qu'il dispose d'une route vers la machine à laquelle il a l'intention d'accéder à distance. Nous pouvons le faire en utilisant `telnet` (non sécurisé et non recommandé), Secure Shell (`SSH`), `PsExec`, `WinRM`, `RDP` ou d'autres protocoles selon les besoins. Pour un administrateur système, la gestion et l'accès à distance sont une aubaine pour notre flux de travail. Nous n'aurions pas à nous rendre au bureau de l'utilisateur et à accéder physiquement à l'hôte pour effectuer nos tâches. Cette commodité pour les administrateurs système peut également introduire une menace de sécurité dans notre réseau. Si ces outils d'accès à distance ne sont pas configurés correctement, ou si une menace obtient l'accès à des informations d'identification valides, un attaquant peut alors avoir un accès étendu à nos environnements. Nous devons maintenir le juste équilibre entre la disponibilité et l'intégrité de nos réseaux pour une posture de sécurité adéquate.

---

## Utilisation de base

En regardant l'invite de commandes, ce que nous voyons maintenant est similaire à ce qu'elle était il y a des décennies. De plus, la navigation dans l'invite de commandes est également restée pratiquement inchangée. Naviguer dans le système de fichiers, c'est comme parcourir un couloir rempli de portes. Lorsque nous entrons dans un couloir (`répertoire`), nous pouvons regarder ce qui s'y trouve (en utilisant la commande `dir`), puis soit lancer d'autres commandes, soit continuer à avancer. Ci-dessous, nous allons couvrir la disposition de base du shell, comment parcourir les couloirs et comment acquérir une carte pour se repérer.

#### Utilisation de la commande dir

### Invite CMD

        cmd
`C:\Users\htb\Desktop> dir     Volume in drive C has no label.  Volume Serial Number is DAE9-5896   Directory of C:\Users\htb\Desktop  06/11/2021  11:59 PM    <DIR>          . 06/11/2021  11:59 PM    <DIR>          .. 06/11/2021  11:57 PM                 0 file1.txt 06/11/2021  11:57 PM                 0 file2.txt 06/11/2021  11:57 PM                 0 file3.txt 04/13/2021  11:24 AM             2,391 Microsoft Teams.lnk 06/11/2021  11:57 PM                 0 super-secret-sauce.txt 06/11/2021  11:59 PM                 0 write-secrets.ps1                6 File(s)          2,391 bytes                2 Dir(s)  35,102,117,888 bytes free`

1. L'emplacement du chemin actuel (`C:\Users\htb\Desktop`)
2. La commande que nous avons lancée (`dir`)
3. Les résultats de la commande (`sortie sous la ligne où la commande a été lancée`)

Lorsque l'on regarde l'invite de commandes, il s'agit d'une conversation de type requête-réponse. Nous avons demandé une liste du contenu du répertoire de travail actuel, et le système a répondu avec la sortie appropriée.

#### Étude de cas : Récupération de Windows

En cas de verrouillage d'un utilisateur ou d'un problème technique empêchant/inhibant l'utilisation normale de la machine, le démarrage à partir d'un disque d'installation de Windows nous donne la possibilité de démarrer en `Mode de réparation`. À partir de là, l'utilisateur a accès à une invite de commandes, ce qui permet de dépanner l'appareil en ligne de commande.

![Accéder à l'invite de commandes via le mode de récupération](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/RecoveryMode.gif)

Bien qu'utile, cela présente également un risque potentiel. Par exemple, sur cette machine Windows 7, nous pouvons utiliser l'invite de commandes de récupération pour altérer le système de fichiers. Plus précisément, en remplaçant le binaire des `Touches rémanentes` (`sethc.exe`) par une autre copie de `cmd.exe`.

Une fois la machine redémarrée, nous pouvons appuyer cinq fois sur la touche `Maj` sur l'écran de connexion de Windows pour invoquer les `Touches rémanentes`. Comme l'exécutable a été écrasé, nous obtenons à la place une autre invite de commandes - cette fois avec les permissions `NT AUTHORITY\SYSTEM`. Nous avons contourné toute authentification et avons maintenant accès à la machine en tant que super utilisateur.

Maintenant que nous avons une compréhension de base de l'invite de commandes et de la manière d'y accéder, passons à autre chose. Notre prochaine section portera sur la manière dont nous pouvons utiliser les fonctionnalités d'`aide` intégrées de cmd.exe.


LAB de fin 

![[Pasted image 20260830220429.png]]

la réponse est le system32