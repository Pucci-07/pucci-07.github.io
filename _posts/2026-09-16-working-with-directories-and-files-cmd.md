[[Command Prompt Basics]]

Maintenant que nous pouvons naviguer en toute sécurité via la ligne de commande, il est temps de maîtriser l'art des fichiers et des répertoires. Ce sujet peut être complexe ; nous disposons de plusieurs manières d'accomplir les mêmes tâches avec Windows. Nous en aborderons quelques-unes, mais gardez à l'esprit qu'il existe de nombreuses autres façons de travailler avec les fichiers et les répertoires. Allons-y.

---

## Répertoires

Qu'est-ce qu'un répertoire ? Dans ce cas, il s'agit d'une structure de dossiers globale au sein du système de fichiers (filesystem) de Windows. Nos fichiers sont imbriqués dans cette structure de dossiers, et nous pouvons nous y déplacer en utilisant des commandes courantes que nous avons pratiquées dans la section précédente, telles que `cd` et `dir`.

Reprenons un instant notre concept de couloir de la section précédente pour penser aux répertoires, nous pouvons le décomposer comme suit :

- Le lecteur lui-même est un disque, mais c'est aussi le répertoire racine (root directory). Pensez donc au lecteur `C:` comme à notre hôtel.
- Cet hôtel a de nombreux étages remplis de couloirs. Ce niveau inclurait des répertoires comme `Windows`, `Users`, `Program Files`, et tout autre répertoire créé par le système d'exploitation ou les utilisateurs.
- Ces étages ont plusieurs couloirs. Pensez à chaque couloir comme à un dossier imbriqué dans nos répertoires précédents. Ainsi, dans le cas de Users, nous aurions alors un dossier pour chaque utilisateur connecté à l'hôte. À ce stade, nous sommes à plusieurs niveaux de profondeur dans le système de fichiers. (`C:\Users\htb\` par exemple).
- Cela continue avec d'autres couloirs (répertoires) à mesure que l'utilisation de l'hôte s'étend et que davantage de logiciels sont installés.
- Finalement, nous trouvons la chambre que nous cherchions et nous y jetons un coup d'œil. Pensez à la porte comme à un fichier au sein de cette ruche de répertoires.

### Afficher et lister les répertoires

Comme nous l'avons dit dans la section précédente, nous pouvons utiliser la commande `cd` pour voir dans quel répertoire nous nous trouvons actuellement. Pour obtenir une liste des fichiers contenus dans un répertoire, nous pouvons utiliser la commande `dir`, et `tree` fournit une liste complète de tous les fichiers et dossiers dans le chemin spécifié. Il est donc agréable de voir que nous avons déjà une longueur d'avance.

![Invite de commandes affichant le listage de répertoire et l'arborescence de 'C:\Users\student\Desktop' avec des fichiers comme 'file.txt', 'passwords.txt', et des dossiers 'Git-Pulls', 'Notes', 'Work-Policies'.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/three-cmd.png)

L'image ci-dessus montre comment les trois peuvent être utilisés conjointement. `chdir` peut également changer notre répertoire de travail actuel.

### Créer un nouveau répertoire

Créer un répertoire à ajouter à notre structure est une entreprise simple. Nous pouvons utiliser les commandes `md` et `mkdir`.

#### Utiliser MD

        cmd
`C:\Users\htb\Desktop> dir   Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop  06/15/2021  09:28 PM    <DIR>          . 06/15/2021  09:28 PM    <DIR>          .. 06/14/2021  10:37 PM                19 file.txt 06/15/2021  09:32 PM    <DIR>          Git-Pulls 06/14/2021  10:59 PM                26 normal-file.txt 06/15/2021  09:29 PM    <DIR>          Notes 06/14/2021  10:28 PM                97 passwords.txt 06/14/2021  10:34 PM                97 Project plans.txt 06/14/2021  08:38 PM               114 secrets.txt 06/15/2021  09:29 PM    <DIR>          Work-Policies                5 File(s)            353 bytes                5 Dir(s)  38,644,342,784 bytes free  C:\Users\htb\Desktop>md new-directory  C:\Users\htb\Desktop>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop  06/15/2021  10:26 PM    <DIR>          . 06/15/2021  10:26 PM    <DIR>          .. 06/14/2021  10:37 PM                19 file.txt 06/15/2021  09:32 PM    <DIR>          Git-Pulls 06/15/2021  10:26 PM    <DIR>          new-directory 06/14/2021  10:59 PM                26 normal-file.txt 06/15/2021  09:29 PM    <DIR>          Notes 06/14/2021  10:28 PM                97 passwords.txt 06/14/2021  10:34 PM                97 Project plans.txt 06/14/2021  08:38 PM               114 secrets.txt 06/15/2021  09:29 PM    <DIR>          Work-Policies                5 File(s)            353 bytes                6 Dir(s)  38,644,277,248 bytes free`

Ci-dessus, `md` est utilisé. Dans le shell suivant, nous verrons `mkdir` utilisé de la même manière. Les deux accomplissent le même objectif, donc utilisez l'une ou l'autre comme vous le souhaitez.

#### Utiliser mkdir pour créer des répertoires

        cmd
`C:\Users\htb\Desktop> mkdir yet-another-dir  C:\Users\htb\Desktop>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop  06/15/2021  10:28 PM    <DIR>          . 06/15/2021  10:28 PM    <DIR>          .. 06/14/2021  10:37 PM                19 file.txt 06/15/2021  09:32 PM    <DIR>          Git-Pulls 06/15/2021  10:26 PM    <DIR>          new-directory 06/14/2021  10:59 PM                26 normal-file.txt 06/15/2021  09:29 PM    <DIR>          Notes 06/14/2021  10:28 PM                97 passwords.txt 06/14/2021  10:34 PM                97 Project plans.txt 06/14/2021  08:38 PM               114 secrets.txt 06/15/2021  09:29 PM    <DIR>          Work-Policies 06/15/2021  10:28 PM    <DIR>          yet-another-dir                5 File(s)            353 bytes                7 Dir(s)  38,644,056,064 bytes free`

### Supprimer des répertoires

La suppression de répertoires peut être accomplie à l'aide des commandes `rd` ou `rmdir`. Les commandes rd et rmdir sont explicitement destinées à la suppression d'arborescences de répertoires et ne traitent pas de fichiers ou d'attributs spécifiques.

Regardons `rd` et `rmdir` maintenant.

#### RD & RMDIR

        cmd
`C:\Users\htb\Desktop> dir   Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop  06/15/2021  10:28 PM    <DIR>          . 06/15/2021  10:28 PM    <DIR>          .. 06/14/2021  10:37 PM                19 file.txt 06/15/2021  09:32 PM    <DIR>          Git-Pulls 06/15/2021  10:26 PM    <DIR>          new-directory 06/14/2021  10:59 PM                26 normal-file.txt 06/15/2021  09:29 PM    <DIR>          Notes 06/14/2021  10:28 PM                97 passwords.txt 06/14/2021  10:34 PM                97 Project plans.txt 06/14/2021  08:38 PM               114 secrets.txt 06/15/2021  09:29 PM    <DIR>          Work-Policies 06/15/2021  10:28 PM    <DIR>          yet-another-dir                5 File(s)            353 bytes                7 Dir(s)  38,634,733,568 bytes free  C:\Users\htb\Desktop> rd Git-Pulls The directory is not empty.`

#### RD /S

        cmd
`C:\Users\htb\Desktop> rd /S Git-Pulls Git-Pulls, Are you sure (Y/N)? Y  C:\Users\htb\Desktop>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop  06/16/2021  01:32 PM    <DIR>          . 06/16/2021  01:32 PM    <DIR>          .. 06/14/2021  10:37 PM                19 file.txt 06/15/2021  10:26 PM    <DIR>          new-directory 06/14/2021  10:59 PM                26 normal-file.txt 06/15/2021  09:29 PM    <DIR>          Notes 06/14/2021  10:28 PM                97 passwords.txt 06/14/2021  10:34 PM                97 Project plans.txt 06/14/2021  08:38 PM               114 secrets.txt 06/15/2021  09:29 PM    <DIR>          Work-Policies 06/15/2021  10:28 PM    <DIR>          yet-another-dir                5 File(s)            353 bytes                6 Dir(s)  38,634,733,568 bytes free`

Dans la session ci-dessus, nous avons listé le répertoire pour voir son contenu, puis nous avons exécuté la commande `rd Git-Pulls`. Dans la première fenêtre de session, nous pouvons voir que la commande n'a pas été exécutée car le répertoire n'était pas vide. Rd a une option `/S` que nous pouvons utiliser pour effacer le répertoire et son contenu. Puisque nous voulons faire disparaître Git-Pulls, nous l'exécuterons dans la deuxième session cmd vue ci-dessus. Les commandes que nous avons exécutées avec `rd` sont les mêmes qu'avec `rmdir`.

Supprimer des répertoires est assez simple. Si vous êtes bloqué en essayant de supprimer un répertoire et que vous recevez un avertissement indiquant que le répertoire n'est pas vide, n'oubliez pas l'option `/S`.

### Modifier

Modifier un répertoire est plus compliqué que de modifier un fichier. Le répertoire contient des données pour d'autres fichiers ou répertoires. Nous avons plusieurs options dans tous les cas. `Move`, `Robocopy` et `xcopy` peuvent copier et apporter des modifications aux répertoires et à leurs structures.

Pour utiliser `move`, nous devons suivre la syntaxe dans cet ordre. Lors du déplacement de répertoires, il prendra le répertoire et tous les fichiers qu'il contient et le déplacera du chemin `source` vers le chemin `destination` spécifié.

#### Déplacer un répertoire

        cmd
`C:\Users\htb\Desktop> tree example /F  Folder PATH listing Volume serial number is 00000032 DAE9:5896 C:\USERS\HTB\DESKTOP\EXAMPLE │   file-1 - Copy.txt │   file-1.txt │   file-2.txt │   file-3.txt │   file-5.txt │   ‎file-4.txt │ └───more stuff  C:\Users\htb\Desktop> move example C:\Users\htb\Documents\example          1 dir(s) moved.`

Nous avons exécuté la commande tree pour voir ce qui se trouvait dans le répertoire example avant de le copier. Après cela, l'exécution de `move example C:\Users\htb\Documents\example` a placé le répertoire example et tous ses fichiers dans le dossier Documents de l'utilisateur. Nous pouvons valider cela en exécutant un dir sur Documents pour voir si le répertoire existe.

#### Valider le déplacement

        cmd
`C:\Users\htb\Desktop> dir C:\Users\htb\Documents  Volume in drive C has no label.  Volume Serial Number is DAE9:5896   Directory of C:\Users\htb\Documents  06/17/2021  03:14 PM    <DIR>          . 06/17/2021  03:14 PM    <DIR>          .. 06/17/2021  02:23 PM    <DIR>          example 06/17/2021  02:01 PM    <DIR>          test 04/13/2021  12:21 PM    <DIR>          WindowsPowerShell 04/22/2021  01:11 PM           933,003 Wireshark-lab-2.pcap                1 File(s)        933,003 bytes                5 Dir(s)  36,644,110,336 bytes free`

Et voilà. Le répertoire `example` existe maintenant dans le répertoire Documents. Les deux options suivantes ont plus de capacités dans la manière dont elles peuvent interagir avec les fichiers et les répertoires. Nous allons prendre un moment pour regarder `xcopy` car il existe toujours dans les systèmes d'exploitation Windows actuels, mais il est important de savoir qu'il a été déprécié au profit de `robocopy`. L'avantage de xcopy est qu'il peut supprimer l'attribut Lecture seule des fichiers lors de leur déplacement. La syntaxe pour `xcopy` est `xcopy` `source` `destination` `options`. Comme avec move, nous pouvons utiliser des caractères génériques (wildcards) pour les fichiers source, mais pas pour les fichiers de destination.

#### Utiliser Xcopy

        cmd
`C:\Users\htb\Desktop> xcopy C:\Users\htb\Documents\example C:\Users\htb\Desktop\ /E  C:\Users\htb\Documents\example\file-1 - Copy.txt C:\Users\htb\Documents\example\file-1.txt C:\Users\htb\Documents\example\file-2.txt C:\Users\htb\Documents\example\file-3.txt C:\Users\htb\Documents\example\file-5.txt C:\Users\htb\Documents\example\‎file-4.txt 6 File(s) copied`

Xcopy nous invite pendant le processus et affiche le résultat. Dans notre cas, le répertoire et tous les fichiers qu'il contenait ont été copiés sur le Bureau. En utilisant l'option `/E`, nous avons dit à Xcopy de copier tous les fichiers et sous-répertoires, y compris les répertoires vides. Gardez à l'esprit que cela ne supprimera pas la copie dans le répertoire précédent. Lors de la duplication, xcopy réinitialisera tous les attributs que le fichier avait. Si vous souhaitez conserver les attributs du fichier (tels que lecture seule ou caché), vous pouvez utiliser l'option `/K`.

Du point de vue d'un hacker, xcopy peut être extrêmement utile. Si nous souhaitons déplacer un fichier, même un fichier système, ou quelque chose de verrouillé, xcopy peut le faire sans ajouter d'autres outils à l'hôte. En tant que défenseur, c'est un excellent moyen de récupérer une copie d'un fichier et de conserver le même état pour l'analyse. Par exemple, vous souhaitez récupérer un fichier en lecture seule qui a été transféré depuis un CD ou une clé USB, et vous le soupçonnez maintenant d'effectuer des actions suspectes.

`Robocopy` est le successeur de xcopy, doté de beaucoup plus de capacités. On peut considérer Robocopy comme la fusion des meilleures parties de copy, xcopy et move, pimentée de quelques capacités supplémentaires. Robocopy peut copier et déplacer des fichiers localement, sur différents lecteurs et même à travers un réseau tout en conservant les données et les attributs du fichier, y compris les horodatages, la propriété, les listes de contrôle d'accès (ACL) et tous les indicateurs définis comme caché ou en lecture seule. Nous devons être conscients que Robocopy a été conçu pour la synchronisation de grands répertoires et de lecteurs, il n'aime donc pas copier ou déplacer des fichiers uniques par défaut. Cela ne veut pas dire qu'il en est incapable, cependant. Nous en parlerons un peu plus bas.

#### Robocopy - Utilisation de base

        cmd
`C:\Users\htb\Desktop> robocopy C:\Users\htb\Desktop C:\Users\htb\Documents\  robocopy C:\Users\htb\Desktop C:\Users\htb\Documents  -------------------------------------------------------------------------------    ROBOCOPY     ::     Robust File Copy for Windows -------------------------------------------------------------------------------    Started : Monday, June 21, 2021 11:05:46 AM    Source : C:\Users\htb\Desktop\      Dest : C:\Users\htb\Documents\      Files : *.*    Options : *.* /DCOPY:DA /COPY:DAT /R:1000000 /W:30  ------------------------------------------------------------------------------                             7    C:\Users\htb\Desktop\         *EXTRA Dir        -1    C:\Users\htb\Documents\My Music\         *EXTRA Dir        -1    C:\Users\htb\Documents\My Pictures\         *EXTRA Dir        -1    C:\Users\htb\Documents\My Videos\ 100%        Older                    282        desktop.ini 100%        New File                  19        file.txt 100%        New File                  26        normal-file.txt 100%        New File                  97        passwords.txt 100%        New File                  97        Project plans.txt 100%        New File                 114        secrets.txt 100%        New File               38380        Windows Startup.wav  ------------------------------------------------------------------------------                 Total    Copied   Skipped  Mismatch    FAILED    Extras     Dirs :         1         0         1         0         0         3    Files :         7         7         0         0         0         0    Bytes :    38.1 k    38.1 k         0         0         0         0    Times :   0:00:00   0:00:00                       0:00:00   0:00:00      Speed :              619285 Bytes/sec.    Speed :              35.435 MegaBytes/min.    Ended : Monday, June 21, 2021 11:05:46 AM   C:\Users\htb\Desktop>dir C:\Users\htb\Documents  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Documents  06/21/2021  11:05 AM    <DIR>          . 06/21/2021  11:05 AM    <DIR>          .. 06/14/2021  10:37 PM                19 file.txt 06/14/2021  10:59 PM                26 normal-file.txt 06/14/2021  10:28 PM                97 passwords.txt 06/14/2021  10:34 PM                97 Project plans.txt 06/14/2021  08:38 PM               114 secrets.txt 12/07/2019  05:08 AM            38,380 Windows Startup.wav                6 File(s)         38,733 bytes                2 Dir(s)  38,285,684,736 bytes free`

Robocopy a pris tout ce qui se trouvait dans notre répertoire Bureau et en a fait une copie dans le répertoire Documents. Cela fonctionne sans aucun problème car nous avons actuellement la permission sur le dossier que nous essayons de copier. Comme discuté précédemment, Robocopy peut également fonctionner avec des fichiers système, en lecture seule et cachés. En tant qu'utilisateur, cela peut être problématique si nous n'avons pas les attributs `SeBackupPrivilege` et `auditing privilege`. Cela pourrait nous empêcher de dupliquer ou de déplacer des fichiers et des répertoires. Il existe cependant une solution de contournement. Nous pouvons utiliser l'option `/MIR` pour nous autoriser temporairement à copier les fichiers dont nous avons besoin.

#### Robocopy - Échec du mode sauvegarde

        cmd
`C:\Users\htb\Desktop> robocopy /E /B /L C:\Users\htb\Desktop\example C:\Users\htb\Documents\Backup\  -------------------------------------------------------------------------------    ROBOCOPY     ::     Robust File Copy for Windows                     -------------------------------------------------------------------------------    Started : Monday, June 21, 2021 10:03:56 PM    Source : C:\Users\htb\Desktop\example\      Dest : C:\Users\htb\Documents\Backup\      Files : *.*    Options : *.* /L /S /E /DCOPY:DA /COPY:DAT /B /R:1000000 /W:30  ------------------------------------------------------------------------------  ERROR : You do not have the Backup and Restore Files user rights. *****  You need these to perform Backup copies (/B or /ZB).  ERROR : Robocopy ran out of memory, exiting. ERROR : Invalid Parameter #%d : "%s"  ERROR : Invalid Job File, Line #%d :"%s"     Started : %s %s     Source %c       Dest %c        Simple Usage :: ROBOCOPY source destination /MIR               source :: Source Directory (drive:\path or \\server\share\path).         destination :: Destination Dir  (drive:\path or \\server\share\path).                /MIR :: Mirror a complete directory tree.      For more usage information run ROBOCOPY /?   ****  /MIR can DELETE files as well as copy them !`

D'après la sortie ci-dessus, nous pouvons voir que nos permissions sont insuffisantes. L'utilisation de l'option /MIR accomplira la tâche pour nous. Soyez conscient qu'il marquera les fichiers comme une sauvegarde système et les cachera de la vue. Nous pouvons effacer les attributs supplémentaires si nous ajoutons l'option `/A-:SH` à notre commande. Faites attention à l'option `/MIR`, car elle mettra en miroir le répertoire de destination par rapport à la source. Tout fichier qui existe dans la destination sera supprimé. Assurez-vous de placer la nouvelle copie dans un dossier vidé. Ci-dessus, nous avons également utilisé l'option `/L`. C'est une commande de simulation. Elle traitera la commande que vous exécutez mais ne l'exécutera pas ; elle vous montrera simplement le résultat potentiel. Essayons ci-dessous.

#### Robocopy /MIR

        cmd
`C:\Users\htb\Desktop> robocopy /E /MIR /A-:SH C:\Users\htb\Desktop\notes\ C:\Users\htb\Documents\Backup\Files-to-exfil\  -------------------------------------------------------------------------------    ROBOCOPY     ::     Robust File Copy for Windows                     -------------------------------------------------------------------------------    Started : Monday, June 21, 2021 10:45:46 PM    Source : C:\Users\htb\Desktop\notes\      Dest : C:\Users\htb\Documents\Backup\Files-to-exfil\      Files : *.*    Options : *.* /S /E /DCOPY:DA /COPY:DAT /PURGE /MIR /A-:SH /R:1000000 /W:30  ------------------------------------------------------------------------------                             2    C:\Users\htb\Desktop\notes\ 100%        New File                  16        python-notes 100%        New File                  13        vscode  ------------------------------------------------------------------------------                 Total    Copied   Skipped  Mismatch    FAILED    Extras     Dirs :         1         0         1         0         0         0    Files :         2         2         0         0         0         0    Bytes :        29        29         0         0         0         0    Times :   0:00:00   0:00:00                       0:00:00   0:00:00    Ended : Monday, June 21, 2021 10:45:46 PM   C:\Users\htb\Documents\Backup\Files-to-exfil>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Documents\Backup\Files-to-exfil  06/21/2021  10:45 PM    <DIR>          . 06/21/2021  10:45 PM    <DIR>          .. 06/15/2021  09:29 PM                16 python-notes 06/15/2021  09:28 PM                13 vscode                2 File(s)             29 bytes                2 Dir(s)  38,285,676,544 bytes free`

En exécutant notre commande puis en vérifiant le répertoire, nous voyons que les fichiers ont été copiés avec succès. Il y a tellement de façons d'utiliser Robocopy qu'il faudrait lui consacrer une section entière. Expérimentez et jouez avec l'outil pour développer vos propres manières de déplacer des répertoires, copier des fichiers, et même jouer avec les attributs.

---

## Fichiers

Beaucoup des mêmes commandes que nous avons utilisées lors de l'administration des répertoires peuvent également être utilisées avec des fichiers. Windows dispose de beaucoup plus d'outils intégrés que nous pouvons utiliser pour toutes nos manipulations magiques de fichiers. Nous en aborderons quelques-uns ici. Nous devrions d'abord discuter de la manière de visualiser les fichiers et leur contenu.

### Lister les fichiers et afficher leur contenu

Nous savons déjà que nous pouvons utiliser la commande `dir` pour voir les fichiers dans un répertoire, ainsi que des informations spécifiques à leur sujet, en fonction des options que nous utilisons. C'est souvent le moyen le plus simple de voir quels fichiers existent dans un répertoire. Nous avons également la commande `tree /F` pour nous montrer une sortie contenant tous les répertoires et fichiers de l'arborescence. Mais que faire si nous souhaitons voir le contenu d'un fichier ? Nous pouvons utiliser les commandes `more`, `openfiles` et `type`.

Le premier est `more`. Avec cet outil intégré, nous pouvons afficher le contenu d'un fichier ou les résultats d'une autre commande qui lui sont envoyés, un écran à la fois. Pensez-y comme un moyen de mettre en mémoire tampon du texte défilant qui pourrait autrement déborder le tampon du terminal.

#### More

        cmd
`C:\Users\htb\Documents\Backup> more secrets.txt  The TVA has several copies of the Infinity Stones..   Bucky is a good guy. TWS is a Bo$$   The sky isn't blue..   -- More (6%) --`

Remarquez qu'en bas de la session cmd, on nous montre le pourcentage du fichier en cours de visualisation. Lorsque nous appuyons sur `Entrée` ou la `barre d'espace`, le texte du document défile pour nous, montrant une part croissante du fichier à l'écran. Avec de gros fichiers contenant plusieurs lignes vides ou beaucoup d'espace vide entre les données, nous pouvons utiliser l'option `/S` pour réduire cet espace vide à une seule ligne à chaque point pour faciliter la visualisation. Cela ne modifiera pas le fichier, tout comme la commande `more` affiche l'espace vide.

#### More /S

        cmd
`C:\Users\htb\Documents\Backup> more /S secrets.txt  The TVA has several copies of the Infinity Stones..  Bucky is a good guy. TWS is a Bo$$  The sky isn't blue..  Windows IP Configuration     Host Name . . . . . . . . . . . . : DESKTOP-LSM3BSF    Primary Dns Suffix  . . . . . . . :    Node Type . . . . . . . . . . . . : Hybrid    IP Routing Enabled. . . . . . . . : No    WINS Proxy Enabled. . . . . . . . : No    DNS Suffix Search List. . . . . . : lan  Ethernet adapter Ethernet0:     Connection-specific DNS Suffix  . : lan    Description . . . . . . . . . . . : Intel(R) 82574L Gigabit Network Connection    Physical Address. . . . . . . . . : 00-0C-29-D7-67-BF -- More (27%) --`

Remarquez que nous avons beaucoup plus du fichier dans notre première vue de la fenêtre. More a pris une grande quantité d'espace vide en utilisant le paramètre `/S` et l'a compressé.

#### Envoyer la sortie d'une commande à More

        cmd-session
`C:\Users\htb\> ipconfig /all | more  Windows IP Configuration     Host Name . . . . . . . . . . . . : DESKTOP-LSM3BSF    Primary Dns Suffix  . . . . . . . :    Node Type . . . . . . . . . . . . : Hybrid    IP Routing Enabled. . . . . . . . : No    WINS Proxy Enabled. . . . . . . . : No    DNS Suffix Search List. . . . . . : lan  Ethernet adapter Ethernet0:     Connection-specific DNS Suffix  . : lan    Description . . . . . . . . . . . : Intel(R) 82574L Gigabit Network Connection    Physical Address. . . . . . . . . : 00-0C-29-D7-67-BF    DHCP Enabled. . . . . . . . . . . : Yes    Autoconfiguration Enabled . . . . : Yes    Link-local IPv6 Address . . . . . : fe80::59fe:9ed2:fea6:1371%5(Preferred)    IPv4 Address. . . . . . . . . . . : 172.16.146.5(Preferred) -- More  --`

Dans la sortie ci-dessus, nous avons exécuté la commande `ipconfig /all` qui génère généralement beaucoup de données, et l'avons passée à travers `more` avec un pipe (`|`) pour la ralentir. C'est particulièrement pratique lorsque l'on traite de gros fichiers ou de commandes qui génèrent beaucoup de texte, comme `systeminfo`.

Avec `openfiles`, nous pouvons voir quel fichier sur notre PC local ou un hôte distant est ouvert et par quel utilisateur. Cette commande nécessite des privilèges d'administrateur sur l'hôte que vous essayez de visualiser. Avec cet outil, nous pouvons voir les fichiers ouverts, déconnecter les fichiers ouverts, et même empêcher des utilisateurs d'accéder à des fichiers spécifiques. La capacité d'utiliser cette commande n'est pas activée par défaut sur les systèmes Windows.

`Type` peut afficher le contenu de plusieurs fichiers texte à la fois. Il est également possible d'utiliser la redirection de fichiers avec `type`. C'est un outil simple mais extrêmement pratique. Une chose intéressante à propos de `type` est qu'il ne verrouille pas les fichiers, donc il n'y a pas de risque de gâcher quelque chose.

#### Type

        cmd
`C:\Users\htb\Desktop>type bio.txt  James Buchanan "Bucky" Barnes Jr. is a fictional character appearing in American comic books published by Marvel Comics. Originally introduced as a sidekick to Captain America, the character was created by Joe Simon and Jack Kirby and first appeared in Captain America Comics #1 (cover-dated March 1941) (which was published by Marvel's predecessor, Timely Comics). Barnes' original costume (or one based on it) and the Bucky nickname have been used by other superheroes in the Marvel Universe over the years.[1] The character is brought back from supposed death as the brainwashed assassin cyborg called Winter Soldier (Russian: ╨ù╨╕╨╝╨╜╨╕╨╣ ╨í╨╛╨╗╨┤╨░╤é, translit. Zimniy Sold├ít). The character's memories and personality are later restored, leading him to become a dark hero in search of redemption. He temporarily assumes the role of "Captain America" when Steve Rogers was presumed to be dead. During the 2011 crossover Fear Itself, Barnes is injected with the Infinity Formula, which increases his natural vitality and physical traits in a way that is similar to (but less powerful than) the super-soldier serum used on Captain America.[2]`

C'est tout ce qu'il y a à faire. Type fournit une sortie de fichier simple. Nous pouvons également l'utiliser pour envoyer une sortie vers un autre fichier. Cela peut être un moyen rapide d'écrire un nouveau fichier ou d'ajouter des données à un autre fichier.

### Redirection avec Type

        cmd
`C:\Users\htb\Desktop>type passwords.txt >> secrets.txt  C:\Users\htb\Desktop>type secrets.txt  The TVA has several copies of the Infinity Stones.. Bucky is a good guy. TWS is a Bo$$ The sky isn't blue.. " so many passwords in the file.. " Password P@ssw0rd Super$ecr3t Admin @dmin123 Summer2021!`

Avec l'exemple ci-dessus, nous avons ajouté le contenu du fichier passwords.txt à la fin du fichier secrets.txt avec `>>`. Ensuite, nous avons visualisé le contenu de secrets.txt et nous pouvons voir que nos données ont été ajoutées avec succès.

Nous avons discuté d'un sujet relativement simple, mais c'est une partie cruciale du travail de tout administrateur ou hacker. Utiliser des outils intégrés tels que `type` et `more` pour fouiner dans le système de fichiers d'un hôte est un moyen rapide et raisonnablement discret de rechercher des mots de passe, des listes d'employés ou d'autres informations potentiellement sensibles.

### Créer et modifier un fichier

Créer et modifier un fichier depuis la ligne de commande est relativement facile. Nous avons plusieurs options qui incluent `echo`, `fsutil`, `ren`, `rename` et `replace`. D'abord, `echo` avec la redirection de sortie nous permet de modifier un fichier s'il existe déjà ou de créer un nouveau fichier au moment de l'appel.

#### Echo pour créer et ajouter à des fichiers

        cmd
`C:\Users\htb\Desktop>echo Check out this text > demo.txt  C:\Users\htb\Desktop>type demo.txt Check out this text  C:\Users\htb\Desktop>echo More text for our demo file >> demo.txt  C:\Users\htb\Desktop>type demo.txt Check out this text More text for our demo file`

Avec `fsutil`, nous pouvons faire beaucoup de choses, mais dans ce cas, nous l'utiliserons pour créer un fichier.

#### Fsutil pour créer un fichier

        cmd
`C:\Users\htb\Desktop>fsutil file createNew for-sure.txt 222 File C:\Users\htb\Desktop\for-sure.txt is created  C:\Users\htb\Desktop>echo " my super cool text file from fsutil "> for-sure.txt  C:\Users\htb\Desktop>type for-sure.txt " my super cool text file from fsutil "`

`Ren` nous permet de changer le nom d'un fichier.

#### Ren(ame) - Renommer un fichier

        cmd
`C:\Users\htb\Desktop> ren demo.txt superdemo.txt  C:\Users\htb\Desktop>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop  06/22/2021  04:25 PM    <DIR>          . 06/22/2021  04:25 PM    <DIR>          .. 06/22/2021  03:21 PM             1,140 bio.txt 06/16/2021  02:36 PM    <DIR>          example 06/14/2021  10:37 PM                19 file.txt 06/22/2021  04:12 PM                41 for-sure.txt 06/22/2021  03:59 PM                12 maybe.txt 06/15/2021  10:26 PM    <DIR>          new-directory 06/22/2021  03:48 PM                 9 nono.txt 06/14/2021  10:59 PM                26 normal-file.txt 06/15/2021  09:29 PM    <DIR>          Notes 06/14/2021  10:28 PM                97 passwords.txt 06/14/2021  10:34 PM                97 Project plans.txt 06/22/2021  03:24 PM               211 secrets.txt 06/22/2021  04:14 PM                52 superdemo.txt 06/22/2021  03:18 PM             2,534 type.txt 06/21/2021  11:33 AM                 0 why-tho.txt 12/07/2019  05:08 AM            38,380 Windows Startup.wav 06/15/2021  09:29 PM    <DIR>          Work-Policies 06/15/2021  10:28 PM    <DIR>          yet-another-dir               13 File(s)         42,618 bytes                7 Dir(s)  39,091,531,776 bytes free`

Nous avons utilisé `ren` pour changer le nom de demo.txt en superdemo.txt. Il peut être exécuté en tant que `ren` ou rename. Ce sont des liens vers la même commande de base.

### Entrée / Sortie

Nous l'avons déjà vu plusieurs fois, mais prenons une minute pour parler de l'E/S (Entrée/Sortie). Nous pouvons utiliser `<`, `>`, `|` et `&` pour envoyer des entrées et des sorties depuis la console et les fichiers là où nous en avons besoin. Avec `>`, nous pouvons rediriger la sortie d'une commande vers un fichier.

#### Rediriger la sortie vers un fichier

        cmd
`C:\Users\htb\Documents>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Documents  06/23/2021  02:44 PM    <DIR>          . 06/23/2021  02:44 PM    <DIR>          .. 06/21/2021  10:38 PM    <DIR>          Backup 06/14/2021  10:34 PM                97 Project plans.txt 06/14/2021  08:38 PM               114 secrets.txt                2 File(s)            211 bytes                3 Dir(s)  39,028,850,688 bytes free  C:\Users\htb\Documents>ipconfig /all > details.txt  C:\Users\htb\Documents>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Documents  06/23/2021  02:44 PM    <DIR>          . 06/23/2021  02:44 PM    <DIR>          .. 06/21/2021  10:38 PM    <DIR>          Backup 06/23/2021  02:44 PM             1,813 details.txt 06/14/2021  10:34 PM                97 Project plans.txt 06/14/2021  08:38 PM               114 secrets.txt                3 File(s)          2,024 bytes                3 Dir(s)  39,028,760,576 bytes free  C:\Users\htb\Documents>type details.txt  Windows IP Configuration     Host Name . . . . . . . . . . . . : DESKTOP-LSM3BSF    Primary Dns Suffix  . . . . . . . :    Node Type . . . . . . . . . . . . : Hybrid    IP Routing Enabled. . . . . . . . : No    WINS Proxy Enabled. . . . . . . . : No    DNS Suffix Search List. . . . . . : greenhorn.corp  Ethernet adapter Ethernet0:     Connection-specific DNS Suffix  . : greenhorn.corp    Description . . . . . . . . . . . : Intel(R) 82574L Gigabit Network Connection    Physical Address. . . . . . . . . : 00-0C-29-D7-67-BF    DHCP Enabled. . . . . . . . . . . : Yes    Autoconfiguration Enabled . . . . : Yes    Link-local IPv6 Address . . . . . : fe80::59fe:9ed2:fea6:1371%8(Preferred)    IPv4 Address. . . . . . . . . . . : 172.16.146.5(Preferred)    Subnet Mask . . . . . . . . . . . : 255.255.255.0    Lease Obtained. . . . . . . . . . : Wednesday, June 23, 2021 2:42:19 PM    Lease Expires . . . . . . . . . . : Thursday, June 24, 2021 2:27:59 PM    Default Gateway . . . . . . . . . : 172.16.146.1`

En regardant ci-dessus, nous pouvons voir que la sortie de notre commande `ipconfig /all` a été redirigée vers details.txt. Lorsque nous vérifions le fichier, nous voyons quand il a été créé, et la sortie du contenu s'y trouve avec succès. L'utilisation de `>` de cette manière créera le fichier s'il n'existe pas, ou il écrasera le contenu du fichier spécifié. Pour ajouter à un fichier déjà peuplé, nous pouvons utiliser `>>`.

#### Ajouter à un fichier

        cmd
`C:\Users\htb\Documents> echo a b c d e > test.txt  C:\Users\htb\Documents>type test.txt a b c d e  C:\Users\htb\Documents>echo f g h i j k see how this works now? >> test.txt  C:\Users\htb\Documents>type test.txt a b c d e f g h i j k see how this works now?`

Nous avons créé le fichier test.txt avec une chaîne de caractères, puis nous avons ajouté notre ligne suivante (f g h i j k see how this works now?) au fichier avec `>>`. Nous fournissions une entrée depuis la sortie d'une commande auparavant ; fournissons maintenant une entrée à une commande. Nous accomplirons cela avec `<`.

#### Passer un fichier texte en entrée d'une commande

        cmd
`C:\Users\htb\Documents>find /i "see" < test.txt  f g h i j k see how this works now?`

Dans la session ci-dessus, nous avons pris le contenu de `test.txt` et l'avons fourni à notre commande find. De cette façon, nous recherchions la chaîne de caractères `see`. Nous pouvons voir qu'elle a renvoyé les résultats en nous montrant la ligne où elle a trouvé `see`. C'étaient des commandes assez simples, mais rappelez-vous que nous pouvons utiliser `<` comme ceci pour rechercher des mots-clés ou des chaînes dans de grands fichiers texte, trier des éléments uniques, et bien plus encore. Cela peut être extrêmement utile pour nous en tant que hacker à la recherche d'informations clés. Une autre voie que nous pouvons emprunter est de fournir la sortie d'une commande directement dans une autre commande avec le `|`, appelé pipe.

#### Rediriger la sortie entre les commandes avec un pipe

        cmd
`C:\Users\htb\Documents>ipconfig /all | find /i "IPV4"     IPv4 Address. . . . . . . . . . . : 172.16.146.5(Preferred)`

Avec `pipe`, nous avons pu exécuter la commande `ipconfig /all` et l'envoyer à `find` pour rechercher une chaîne spécifique. Nous savons que cela a fonctionné car il retourne notre résultat sur la ligne suivante. Cela a effectivement pris notre sortie de console et l'a redirigée vers un nouveau pipe. Si vous comprenez bien ce concept, vous pouvez faire une infinité de choses.

Disons que nous souhaitons que deux commandes soient exécutées successivement. Nous pouvons exécuter la commande et la faire suivre de `&` puis de notre prochaine commande. Cela garantira que dans ce cas, notre commande `A` s'exécute en premier, puis la session exécutera la commande `B`. Peu importe que la commande ait réussi ou échoué. Elle les exécute simplement.

#### Exécuter A puis B

        cmd
`C:\Users\htb\Documents>ping 8.8.8.8 & type test.txt  Pinging 8.8.8.8 with 32 bytes of data: Reply from 8.8.8.8: bytes=32 time=22ms TTL=114 Reply from 8.8.8.8: bytes=32 time=19ms TTL=114 Reply from 8.8.8.8: bytes=32 time=17ms TTL=114 Reply from 8.8.8.8: bytes=32 time=16ms TTL=114  Ping statistics for 8.8.8.8:     Packets: Sent = 4, Received = 4, Lost = 0 (0% loss), Approximate round trip times in milli-seconds:     Minimum = 16ms, Maximum = 22ms, Average = 18ms a b c d e f g h i j k see how this works now?`

Si nous nous soucions du résultat ou de l'état des commandes en cours d'exécution, nous pouvons utiliser `&&` pour dire d'exécuter la commande A, et si elle réussit, d'exécuter la commande B. Cela peut être utile si vous faites quelque chose qui dépend des résultats, comme notre session cmd ci-dessous.

#### Exécution conditionnelle avec &&

        cmd
`C:\Users\student\Documents>cd C:\Users\student\Documents\Backup && echo 'did this work' > yes.txt  C:\Users\student\Documents\Backup>type yes.txt 'did this work'`

Nous pouvons voir que sur ma première ligne avec `&&`, nous avons demandé à changer notre répertoire de travail, puis à écrire une chaîne dans un fichier si cela réussissait. Nous pouvons dire que cela a réussi car notre chemin cmd a changé et quand nous affichons le contenu du fichier avec `type`, il a bien écrit notre chaîne dans le fichier. Vous pouvez également accomplir le contraire avec `||`. En utilisant (pipe pipe), nous disons d'exécuter la commande A. Si elle échoue, exécutez la commande B.

Nous avons passé beaucoup de temps à améliorer nos compétences en création et modification de fichiers. Maintenant, que faire si nous voulons supprimer des objets de l'hôte ? Regardons les commandes `del` et `erase`.

### Supprimer des fichiers

#### Utilisation dynamique de Del et Erase

        cmd
`C:\Users\htb\Desktop\example> dir   Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop\example  06/16/2021  02:00 PM    <DIR>          . 06/16/2021  02:00 PM    <DIR>          .. 06/16/2021  02:00 PM                 5 file-1 06/16/2021  02:00 PM                 5 file-2 06/16/2021  02:00 PM                 5 file-3 06/16/2021  02:00 PM                 5 file-4 06/16/2021  02:00 PM                 5 file-5 06/16/2021  02:00 PM                 5 file-6 06/16/2021  02:00 PM                 5 file-66                7 File(s)             35 bytes                2 Dir(s)  38,633,730,048 bytes free  C:\Users\htb\Desktop\example>del file-1  C:\Users\htb\Desktop\example>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop\example  06/16/2021  02:03 PM    <DIR>          . 06/16/2021  02:03 PM    <DIR>          .. 06/16/2021  02:00 PM                 5 file-2 06/16/2021  02:00 PM                 5 file-3 06/16/2021  02:00 PM                 5 file-4 06/16/2021  02:00 PM                 5 file-5 06/16/2021  02:00 PM                 5 file-6 06/16/2021  02:00 PM                 5 file-66                6 File(s)             30 bytes                2 Dir(s)  38,633,730,048 bytes free`

Lorsque vous utilisez `del` ou `erase`, rappelez-vous que nous pouvons spécifier un répertoire, un nom de fichier, une liste de noms, ou même un attribut spécifique à cibler lorsque vous essayez de supprimer des fichiers. Ci-dessus, nous avons listé le répertoire example puis supprimé `file-1`. Assez simple, non ? Maintenant, effaçons une liste de fichiers.

#### Utiliser Del et Erase pour supprimer une liste de fichiers

        cmd
`C:\Users\htb\Desktop\example> erase file-3 file-5  dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop\example  06/16/2021  02:06 PM    <DIR>          . 06/16/2021  02:06 PM    <DIR>          .. 06/16/2021  02:00 PM                 5 file-2 06/16/2021  02:00 PM                 5 file-4 06/16/2021  02:00 PM                 5 file-6 06/16/2021  02:00 PM                 5 file-66                4 File(s)             20 bytes                2 Dir(s)  38,633,218,048 bytes free`

Nous pouvons voir dans la session ci-dessus que nous avons utilisé erase au lieu de del cette fois. C'était pour montrer l'interopérabilité des deux commandes. Pensez-y comme à des liens symboliques. Les deux commandes font la même chose. Cette fois, nous avons fourni à erase une liste de deux fichiers, `file-3` et `file-5`. Il a effacé les fichiers sans problème.

Disons que nous voulons nous débarrasser d'un fichier en lecture seule ou caché. Nous pouvons le faire avec l'option `/A:`. /A peut supprimer des fichiers en fonction d'un attribut spécifique. Regardons rapidement l'aide de del pour voir quels sont ces attributs.

### Documentation d'aide de Del

        cmd
`C:\Users\htb\Desktop\example> help del  Deletes one or more files.  DEL [/P] [/F] [/S] [/Q] [/A[[:]attributes]] names ERASE [/P] [/F] [/S] [/Q] [/A[[:]attributes]] names    names         Specifies a list of one or more files or directories.                 Wildcards may be used to delete multiple files. If a                 directory is specified, all files within the directory                 will be deleted.    /P            Prompts for confirmation before deleting each file.   /F            Force deleting of read-only files.   /S            Delete specified files from all subdirectories.   /Q            Quiet mode, do not ask if ok to delete on global wildcard   /A            Selects files to delete based on attributes   attributes    R  Read-only files            S  System files                 H  Hidden files               A  Files ready for archiving                 I  Not content indexed Files  L  Reparse Points                 O  Offline files              -  Prefix meaning not`

Donc, pour supprimer un fichier en lecture seule, nous pouvons utiliser `A:R`. Cela supprimera tout ce qui se trouve dans notre chemin et qui est en lecture seule. Cependant, comment identifier si un fichier est en lecture seule, caché, ou a un autre attribut ? Dir peut encore venir à la rescousse. L'utilisation de `dir /A:R` nous montrera tout ce qui a l'attribut lecture seule. Essayons.

#### Afficher les fichiers avec l'attribut Lecture seule

        cmd
`C:\Users\htb\Desktop\example> dir /A:R    Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop\example  06/16/2021  02:00 PM                 5 file-66                1 File(s)              5 bytes                0 Dir(s)  38,632,652,800 bytes free`

Maintenant, nous savons qu'un fichier correspond à notre attribut Lecture seule dans le répertoire example. Supprimons-le.

#### Supprimer un fichier en lecture seule

        cmd
`C:\Users\htb\Desktop\example > del /A:R *  C:\Users\htb\Desktop\example\*, Are you sure (Y/N)? Y  C:\Users\htb\Desktop\example>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop\example  06/16/2021  02:22 PM    <DIR>          . 06/16/2021  02:22 PM    <DIR>          .. 06/16/2021  02:00 PM                 5 file-2 06/16/2021  02:00 PM                 5 file-4 06/16/2021  02:00 PM                 5 file-6                3 File(s)             15 bytes                2 Dir(s)  38,632,529,920 bytes free`

Notez que nous avons utilisé `*` pour spécifier n'importe quel fichier. Maintenant, lorsque nous regardons à nouveau le répertoire example, file-66 a disparu, mais les fichiers 2, 4 et 6 sont toujours là. Essayons à nouveau del avec l'attribut caché. Pour identifier s'il y a des fichiers cachés dans le répertoire, nous pouvons utiliser `dir /A:H`

#### Afficher les fichiers cachés

        cmd
`C:\Users\htb\Desktop\example> dir /A:H  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop\example  06/16/2021  02:00 PM                 5 file-99                1 File(s)              5 bytes                0 Dir(s)  38,632,202,240 bytes free`

Remarquez le nouveau fichier que nous n'avions pas vu auparavant ? Maintenant `file-99` apparaît dans notre listage de répertoire des fichiers cachés. Rappelez-vous que, tout comme sous Linux, vous pouvez cacher des fichiers à la vue des utilisateurs. Avec l'attribut caché, le fichier existe et peut être appelé, mais il ne sera pas visible dans un listage de répertoire ou depuis l'interface graphique (GUI) à moins de les rechercher spécifiquement. Pour supprimer le fichier caché, nous pouvons effectuer la même commande del que précédemment, en changeant simplement l'attribut de `R` à `H`.

#### Supprimer les fichiers cachés

        cmd
`C:\Users\htb\Desktop\example>dir /A:H  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop\example  06/16/2021  02:00 PM                 5 file-99                1 File(s)              5 bytes                0 Dir(s)  38,632,202,240 bytes free  C:\Users\htb\Desktop\example>del /A:H * C:\Users\htb\Desktop\example\*, Are you sure (Y/N)? Y  C:\Users\htb\Desktop\example>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop\example  06/16/2021  02:28 PM    <DIR>          . 06/16/2021  02:28 PM    <DIR>          .. 06/16/2021  02:00 PM                 5 file-2 06/16/2021  02:00 PM                 5 file-4 06/16/2021  02:00 PM                 5 file-6                3 File(s)             15 bytes                2 Dir(s)  38,631,997,440 bytes free  C:\Users\htb\Desktop\example>dir /A:H  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\htb\Desktop\example  File Not Found`

Nous avons maintenant supprimé avec succès un fichier avec l'attribut caché. Pour effacer le répertoire avec le reste de son contenu, nous pouvons fournir à la commande `del` le nom du répertoire pour supprimer le contenu, puis la faire suivre de la commande `rd` pour éliminer la structure du répertoire. Si un fichier réside dans le répertoire avec l'attribut Lecture seule ou un autre, l'utilisation de l'option `/F` forcera la suppression du fichier.

### Copier et déplacer des fichiers

Tout comme pour les répertoires, nous avons plusieurs options pour copier ou déplacer des fichiers. `Copy` et `move` sont les moyens les plus simples d'y parvenir. Nous pouvons les utiliser pour faire des copies d'un fichier dans le même répertoire ou le déplacer dans un autre. En tant que tâche, c'est l'une des plus simples que nous ferons.

#### copy

        cmd
`C:\Users\student\Documents\Backup>copy secrets.txt C:\Users\student\Downloads\not-secrets.txt                  1 file(s) copied. C:\Users\student\Downloads>dir  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\student\Downloads  06/23/2021  10:35 PM    <DIR>          . 06/23/2021  10:35 PM    <DIR>          .. 06/21/2021  11:58 PM             2,418 not-secrets.txt                1 File(s)          2,418 bytes                2 Dir(s)  39,021,146,112 bytes free`

Dans l'exemple ci-dessus, nous avons copié `secrets.txt` et l'avons déplacé dans le dossier Downloads, en le renommant `not-secrets.txt`. Par défaut, `copy` terminera sa tâche et se fermera. Si nous souhaitons nous assurer que les fichiers copiés sont correctement copiés, nous pouvons utiliser l'option `/V` pour activer la validation des fichiers.

#### Validation de la copie

        cmd
`C:\Windows\System32> copy calc.exe C:\Users\student\Downloads\copied-calc.exe /V Overwrite C:\Users\student\Downloads\copied-calc.exe? (Yes/No/All): A         1 file(s) copied.`

Avec `move`, nous pouvons déplacer des fichiers et des répertoires d'un endroit à un autre et les renommer. Move diffère de copy car il peut également renommer et déplacer des répertoires.

#### move

        cmd
`C:\Users\student\Desktop>move C:\Users\student\Desktop\bio.txt C:\Users\student\Downloads                  1 file(s) moved.  C:\Users\student\Desktop>dir C:\Users\student\Downloads  Volume in drive C has no label.  Volume Serial Number is 26E7-9EE4   Directory of C:\Users\student\Downloads  06/24/2021  11:10 AM    <DIR>          . 06/24/2021  11:10 AM    <DIR>          .. 06/22/2021  03:21 PM             1,140 bio.txt 12/07/2019  05:09 AM            27,648 copied-calc.exe 06/21/2021  11:58 PM             2,418 not-secrets.txt                3 File(s)         31,206 bytes                2 Dir(s)  39,122,550,784 bytes free`

Ci-dessus, nous avons pris le fichier `bio.txt` et l'avons déplacé dans le dossier Downloads. La manipulation de fichiers est aussi simple que cela.

---

Excellent travail ! Nous avons maintenant abordé la tâche de maîtriser la manipulation des fichiers et des dossiers. Prochaine étape, nous nous attaquerons à la collecte d'informations système critiques.

LAB de fin 

![Pasted image 20260831003603.png](/assets/img/writeups/Pasted image 20260831003603.png)
rep : type 

![Pasted image 20260831003633.png](/assets/img/writeups/Pasted image 20260831003633.png)
rep : mkdir apples 

