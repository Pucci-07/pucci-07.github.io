
Maintenant, nous sommes à l'aise pour créer, modifier, déplacer et supprimer des fichiers et des répertoires. Nous devrions aborder un concept bénéfique qui peut être décisif lors d'une mission ou dans nos tâches quotidiennes en tant qu'`Administrateur Système` ou `Pentester`, connu sous le nom d'`énumération` (enumeration). Cette section expliquera comment rechercher des fichiers et des répertoires particuliers à l'aide de CMD, pourquoi l'énumération des fichiers et répertoires système est vitale, et fournira une liste essentielle de ce qu'il faut rechercher lors de l'énumération du système.

---

## Recherche avec CMD

#### Utilisation de Where

        cmd
`C:\Users\student\Desktop>where calc.exe  C:\Windows\System32\calc.exe  C:\Users\student\Desktop>where bio.txt  INFO: Could not find files for the given pattern(s).`

Ci-dessus, nous pouvons voir deux essais différents utilisant la commande `where`. D'abord, nous avons cherché `calc.exe`, et la commande s'est terminée en nous montrant le chemin pour calc.exe. Cette commande a fonctionné car le dossier system32 est dans le chemin de notre variable d'environnement, donc la commande `where` peut rechercher automatiquement dans ces dossiers.

La deuxième tentative a échoué. C'est parce que nous recherchons un fichier qui n'existe pas dans ce chemin d'environnement. Il est situé dans notre répertoire utilisateur. Nous devons donc spécifier le chemin dans lequel chercher, et pour nous assurer que nous explorons tous les répertoires de ce chemin, nous pouvons utiliser l'option `/R`.

#### Where Récursif

        cmd
`C:\Users\student\Desktop>where /R C:\Users\student\ bio.txt  C:\Users\student\Downloads\bio.txt`

Ci-dessus, nous avons cherché de manière récursive, en cherchant bio.txt. Le fichier a été trouvé dans le dossier `C:\Users\student\Downloads\`. L'option `/R` a forcé la commande `where` à chercher dans chaque dossier de l'arborescence du répertoire utilisateur student. En plus de chercher des fichiers, nous pouvons aussi utiliser des caractères génériques pour rechercher des chaînes spécifiques, des types de fichiers, et plus encore. Voici un exemple de recherche du type de fichier `csv` dans le répertoire student.

#### Utilisation des Caractères Génériques

        cmd
`C:\Users\student\Desktop>where /R C:\Users\student\ *.csv  C:\Users\student\AppData\Local\live-hosts.csv`

Nous avons utilisé `where` pour nous donner une idée de la façon de rechercher des fichiers et des applications sur l'hôte. Parlons maintenant de `Find`. Find est utilisé pour rechercher des chaînes de texte ou leur absence dans un ou plusieurs fichiers. Vous pouvez également utiliser `find` sur la sortie de la console ou d'une autre commande. Là où `find` est limité, cependant, c'est dans sa capacité à utiliser des motifs de caractères génériques dans sa correspondance. L'exemple ci-dessous nous montrera une recherche simple avec Find sur le fichier not-password.txt.

#### Find de Base

        cmd
`C:\Users\student\Desktop> find "password" "C:\Users\student\not-passwords.txt"` 

Nous pouvons modifier la façon dont `find` recherche en utilisant plusieurs options. Le modificateur `/V` peut changer notre recherche d'une clause de correspondance à une clause `Not`. Ainsi, par exemple, si nous utilisons `/V` avec la chaîne de recherche password sur un fichier, il nous montrera toute ligne qui ne contient pas la chaîne spécifiée. Nous pouvons également utiliser l'option `/N` pour afficher les numéros de ligne et l'option `/I` pour ignorer la sensibilité à la casse. Dans l'exemple ci-dessous, nous utilisons tous les modificateurs pour nous montrer toutes les lignes qui ne correspondent pas à la chaîne `IP Address` tout en lui demandant d'afficher les numéros de ligne et d'ignorer la casse de la chaîne.

#### Modificateurs de Find

        cmd
`C:\Users\student\Desktop> find /N /I /V "IP Address" example.txt`  

Pour des recherches rapides, find est facile à utiliser, mais il pourrait être plus robuste dans sa manière de rechercher. Cependant, si nous avons besoin de quelque chose de plus spécifique, `findstr` est ce qu'il nous faut. La commande `findstr` est similaire à `find` en ce qu'elle recherche dans les fichiers, mais pour des motifs à la place. Elle cherchera tout ce qui correspond à un motif, une valeur regex, des caractères génériques, et plus encore. Considérez-la comme find2.0. Pour ceux qui sont familiers avec Linux, `findstr` est plus proche de `grep`.

#### Findstr

        cmd
`C:\Users\student\Desktop> findstr`  

### Évaluation et Tri des Fichiers

Nous avons vu comment travailler avec, rechercher certains fichiers et rechercher des chaînes à l'intérieur des fichiers. De plus, nous avons également appris à créer et modifier des fichiers. Discutons maintenant de quelques options pour évaluer ces fichiers et les comparer les uns aux autres. Les commandes [comp](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/comp), [fc](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/fc), et [sort](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/sort) sont les moyens par lesquels nous accomplirons cela.

`Comp` vérifiera chaque octet dans deux fichiers à la recherche de différences, puis affichera où elles commencent. Par défaut, les différences sont affichées au format décimal. Nous pouvons utiliser le modificateur `/A` si nous voulons voir les différences au format ASCII. Le modificateur `/L` peut également nous fournir les numéros de ligne.

#### Compare

        cmd
`C:\Users\student\Desktop> comp .\file-1.md .\file-2.md  Comparing .\file-1.md and .\file-2.md... Files compare OK`  

Ci-dessus, nous voyons que la comparaison est revenue OK. Les fichiers sont identiques. Nous pouvons utiliser cela comme un moyen facile de vérifier si des scripts, des exécutables ou des fichiers critiques ont été modifiés. Ci-dessous, nous avons la sortie d'un fichier qui a été modifié.

#### Comparaison de Fichiers Différents

        powershell
`PS C:\htb> echo a > .\file-1.md PS C:\Users\MTanaka\Desktop> echo a > .\file-2.md PS C:\Users\MTanaka\Desktop> comp .\file-1.md .\file-2.md /A Comparing .\file-1.md and .\file-2.md... Files compare OK <SNIP> PS C:\Users\MTanaka\Desktop> echo b > .\file-2.md PS C:\Users\MTanaka\Desktop> comp .\file-1.md .\file-2.md /A Comparing .\file-1.md and .\file-2.md... Compare error at OFFSET 2 file1 = a file2 = b`  

Nous avons utilisé echo pour nous assurer que les chaînes différaient, puis nous avons relancé la comparaison. Remarquez comment notre sortie a changé, et en utilisant le modificateur /A, nous voyons maintenant la différence de caractère entre les deux fichiers. `Comp` est un outil simple mais efficace. Regardons maintenant `FC` un instant. `FC` diffère en ce qu'il vous montrera quelles lignes sont différentes, et pas seulement un caractère individuel (`/A`) ou un octet différent sur chaque ligne. FC a beaucoup plus d'options que Comp, alors assurez-vous de consulter la sortie d'aide pour vous assurer que vous l'utilisez de la manière souhaitée.

#### Aide de FC

        cmd
`C:\htb> fc.exe /?  Compare deux fichiers ou jeux de fichiers et affiche les différences entre eux.  FC [/A] [/C] [/L] [/LBn] [/N] [/OFF[LINE]] [/T] [/U] [/W] [/nnnn]    [lecteur1:][chemin1]fichier1 [lecteur2:][chemin2]fichier2 FC /B [lecteur1:][chemin1]fichier1 [lecteur2:][chemin2]fichier2    /A         Affiche uniquement la première et la dernière ligne de chaque ensemble de différences.   /B         Effectue une comparaison binaire.   /C         Ignore la casse des lettres.   /L         Compare les fichiers en tant que texte ASCII.   /LBn       Définit le nombre maximal de discordances consécutives au nombre              de lignes spécifié.   /N         Affiche les numéros de ligne lors d'une comparaison ASCII.   /OFF[LINE] Ne pas ignorer les fichiers dont l'attribut hors connexion est défini.   /T         Ne convertit pas les tabulations en espaces.   /U         Compare les fichiers en tant que fichiers texte UNICODE.   /W         Compresse les espaces blancs (tabulations et espaces) pour la comparaison.   /nnnn      Spécifie le nombre de lignes consécutives qui doivent correspondre              après une discordance.   [lecteur1:][chemin1]fichier1              Spécifie le premier fichier ou jeu de fichiers à comparer.   [lecteur2:][chemin2]fichier2              Spécifie le second fichier ou jeu de fichiers à comparer.`

Lorsque FC effectue son inspection, il est sensible à la casse et se soucie de plus qu'une simple comparaison octet par octet. Ci-dessous, nous utiliserons quelques fichiers avec beaucoup plus de caractères et de chaînes pour tester sa fonctionnalité. Nous effectuerons une vérification de base et lui ferons imprimer les numéros de ligne et la comparaison ASCII à l'aide du modificateur `/N`.

#### FC

        cmd
`C:\Users\student\Desktop> fc passwords.txt modded.txt /N  Comparing files passwords.txt and MODDED.TXT ***** passwords.txt     1:  123456     2:  password ***** MODDED.TXT     1:  123456     2:     3:  password *****  ***** passwords.txt     5:  12345     6:  qwerty ***** MODDED.TXT     6:  12345     7:  Just something extra to show functionality. Did it see the space inserted above?     8:  qwerty *****`

La sortie de FC est beaucoup plus facile à interpréter et nous donne un peu plus de clarté sur les différences entre les fichiers. Lors de la comparaison de fichiers tels que des fichiers texte, des feuilles de calcul ou des listes, il est prudent de les trier d'abord pour s'assurer que les données sur chaque chaîne sont les mêmes. Sinon, chaque ligne sera différente et notre comparaison ne nous aidera pas. Regardons maintenant `sort` pour nous aider avec cela. Avec `Sort`, nous pouvons recevoir une entrée de la console, d'un pipeline ou d'un fichier, la trier et envoyer les résultats à la console, dans un fichier ou vers une autre commande. Il est relativement simple à utiliser et sera souvent utilisé en conjonction avec des opérateurs de pipeline tels que `|`, `<`, et `>`. Nous pouvons l'essayer maintenant en donnant le contenu du fichier `file` à sort.

#### Sort

        cmd
`C:\Users\student\Desktop> type .\file-1.md a b d h w a q h g  C:\Users\MTanaka\Desktop> sort.exe .\file-1.md /O .\sort-1.md C:\Users\MTanaka\Desktop> type .\sort-1.md  a a b d g h h q w`

Ci-dessus, nous pouvons voir en utilisant `sort` sur le fichier `file-1.md` puis en envoyant le résultat avec le modificateur `/O` au fichier sort-1.md, nous avons pris notre liste de lettres, les avons triées par ordre alphabétique, et les avons écrites dans le nouveau fichier. Cela peut devenir plus complexe lorsque l'on travaille avec des ensembles de données plus importants, mais l'utilisation de base reste la même. Si nous voulions que `sort` ne retourne que les entrées uniques, nous pourrions également utiliser le modificateur /unique. Remarquez les deux premières entrées dans le fichier `sort-1.md`. Essayons d'utiliser unique et voyons ce qui se passe.

#### unique

        cmd
`C:\htb> type .\sort-1.md  a a b d g h h q w  PS C:\Users\MTanaka\Desktop> sort.exe .\sort-1.md /unique  a b d g h q w`  

Remarquez que nous avons maintenant moins de résultats globaux. C'est parce que `sort` n'a pas écrit les entrées en double du fichier dans la console.

---

Trouver des fichiers et des répertoires, trier des ensembles de données et comparer des fichiers sont toutes des compétences essentielles que nous devrions avoir dans notre arsenal. Ensuite, nous discuterons des variables d'environnement et de ce qu'elles nous apportent en tant qu'utilisateur de l'invite de commande.

Lab de Fin 

![Pasted image 20260831014343.png](/assets/img/writeups/Pasted image 20260831014343.png)

rep : findstr 

![Pasted image 20260831014502.png](/assets/img/writeups/Pasted image 20260831014502.png)

cmd  : where /R C:\ waldo.txt 
