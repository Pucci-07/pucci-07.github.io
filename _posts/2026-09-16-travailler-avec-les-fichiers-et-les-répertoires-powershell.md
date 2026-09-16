[[Command Prompt Basics]]
#### Créer plus de répertoires

        powershell
`PS C:\Users\MTanaka\Documents> cd SOPs   PS C:\Users\MTanaka\Documents\SOPs> mkdir "Physical Sec"      Directory: C:\Users\MTanaka\Documents\SOPs   Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- d-----         10/5/2022   4:30 PM                Physical Sec  PS C:\Users\MTanaka\Documents\SOPs> mkdir "Cyber Sec"      Directory: C:\Users\MTanaka\Documents\SOPs   Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- d-----         10/5/2022   4:30 PM                Cyber Sec  PS C:\Users\MTanaka\Documents\SOPs> mkdir "Training"      Directory: C:\Users\MTanaka\Documents\SOPs   Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- d-----         10/5/2022   4:31 PM                Training    PS C:\Users\MTanaka\Documents\SOPs> Get-ChildItem   Directory: C:\Users\MTanaka\Documents\SOPs   Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- d-----        10/5/2022   9:08 AM                Cyber Sec d-----        11/5/2022   9:09 AM                Physical Sec d-----        11/5/2022   9:08 AM                Training`

Maintenant que notre structure de répertoires est en place. Il est temps de commencer à remplir les fichiers requis. M. Tanaka a demandé un fichier Markdown dans chaque dossier comme suit :

- `SOPs` > ReadMe.md
    - `Physical Sec` > Physical-Sec-draft.md
    - `Cyber Sec` > Cyber-Sec-draft.md
    - `Training` > Employee-Training-draft.md

Dans chaque fichier, il a demandé cet en-tête en haut :

- Title: Insert Document Title Here
- Date: x/x/202x
- Author: MTanaka
- Version: 0.1 (Draft)

Nous devrions pouvoir accomplir cela rapidement en utilisant la cmdlet `New-Item` et la cmdlet `Add-Content`.

#### Créer des fichiers

        powershell
`PS C:\htb> PS C:\Users\MTanaka\Documents\SOPs> new-Item "Readme.md" -ItemType File      Directory: C:\Users\MTanaka\Documents\SOPs  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a----        11/10/2022   9:12 AM              0 Readme.md  PS C:\Users\MTanaka\Documents\SOPs> cd '.\Physical Sec\' PS C:\Users\MTanaka\Documents\SOPs\Physical Sec> ls PS C:\Users\MTanaka\Documents\SOPs\Physical Sec> new-Item "Physical-Sec-draft.md" -ItemType File      Directory: C:\Users\MTanaka\Documents\SOPs\Physical Sec  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a----        11/10/2022   9:14 AM              0 Physical-Sec-draft.md  PS C:\Users\MTanaka\Documents\SOPs\Physical Sec> cd .. PS C:\Users\MTanaka\Documents\SOPs> cd '.\Cyber Sec\'  PS C:\Users\MTanaka\Documents\SOPs\Cyber Sec> new-Item "Cyber-Sec-draft.md" -ItemType File      Directory: C:\Users\MTanaka\Documents\SOPs\Cyber Sec  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a----        11/10/2022   9:14 AM              0 Cyber-Sec-draft.md  PS C:\Users\MTanaka\Documents\SOPs\Cyber Sec> cd .. PS C:\Users\MTanaka\Documents\SOPs> cd .\Training\ PS C:\Users\MTanaka\Documents\SOPs\Training> ls PS C:\Users\MTanaka\Documents\SOPs\Training> new-Item "Employee-Training-draft.md" -ItemType File      Directory: C:\Users\MTanaka\Documents\SOPs\Training  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a----        11/10/2022   9:15 AM              0 Employee-Training-draft.md  PS C:\Users\MTanaka\Documents\SOPs\Training> cd .. PS C:\Users\MTanaka\Documents\SOPs> tree /F Folder PATH listing Volume serial number is F684-763E C:. │   Readme.md │ ├───Cyber Sec │       Cyber-Sec-draft.md │ ├───Physical Sec │       Physical-Sec-draft.md │ └───Training         Employee-Training-draft.md`

Maintenant que nous avons nos fichiers, nous devons y ajouter du contenu. Nous pouvons le faire avec la cmdlet `Add-Content`.

#### Ajouter du contenu

        powershell
`PS C:\htb> Add-Content .\Readme.md "Title: Insert Document Title Here >> Date: x/x/202x >> Author: MTanaka >> Version: 0.1 (Draft)"      PS C:\Users\MTanaka\Documents\SOPs> cat .\Readme.md Title: Insert Document Title Here Date: x/x/202x Author: MTanaka Version: 0.1 (Draft)`

Nous effectuerions ensuite le même processus que pour `Readme.md` dans tous les autres fichiers que nous avons créés pour M. Tanaka. Ce scénario a semblé un peu fastidieux, n'est-ce pas ? Créer des fichiers encore et encore à la main peut devenir lassant. C'est là que l'automatisation et le scripting entrent en jeu. C'est un peu hors de notre portée pour le moment, mais dans une section ultérieure de ce module, nous verrons comment créer un module PowerShell rapide, en utilisant des variables et en écrivant des scripts pour faciliter les choses.

**Suite du scénario : M. Tanaka nous a demandé de changer le nom du fichier `Cyber-Sec-draft.md` en `Infosec-SOP-draft.md`.**

Nous pouvons rapidement accomplir cette tâche en utilisant la cmdlet `Rename-Item`. Essayons :

#### Renommer un objet

        powershell
`PS C:\Users\MTanaka\Documents\SOPs\Cyber Sec> ls      Directory: C:\Users\MTanaka\Documents\SOPs\Cyber Sec  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a----        11/10/2022   9:14 AM              0 Cyber-Sec-draft.md  PS C:\Users\MTanaka\Documents\SOPs\Cyber Sec> Rename-Item .\Cyber-Sec-draft.md -NewName Infosec-SOP-draft.md PS C:\Users\MTanaka\Documents\SOPs\Cyber Sec> ls      Directory: C:\Users\MTanaka\Documents\SOPs\Cyber Sec  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a----        11/10/2022   9:14 AM              0 Infosec-SOP-draft.md`

Tout ce que nous avions à faire ci-dessus était d'exécuter la cmdlet `Rename-Item`, de lui donner le nom de fichier original que nous voulons changer (`Cyber-Sec-draft.md`), puis de lui indiquer notre nouveau nom avec le paramètre `-NewName` (`Infosec-SOP-draft.md`). Cela semble simple, n'est-ce pas ? Nous pourrions aller plus loin et renommer tous les fichiers d'un répertoire, changer le type de fichier ou effectuer plusieurs actions différentes. Dans notre exemple ci-dessous, nous allons changer les noms de tous les fichiers texte sur le bureau de M. Tanaka de `file.txt` à `file.md`.

#### Files1-5.txt sont sur le bureau de MTanaka

        powershell
`PS C:\Users\MTanaka\Desktop> ls      Directory: C:\Users\MTanaka\Desktop  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a----        10/13/2022   1:05 PM              0 file-1.txt -a----        10/13/2022   1:05 PM              0 file-2.txt -a----        10/13/2022   1:06 PM              0 file-3.txt -a----        10/13/2022   1:06 PM              0 file-4.txt -a----        10/13/2022   1:06 PM              0 file-5.txt  PS C:\Users\MTanaka\Desktop> get-childitem -Path *.txt | rename-item -NewName {$_.name -replace ".txt",".md"} PS C:\Users\MTanaka\Desktop> ls      Directory: C:\Users\MTanaka\Desktop  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a----        10/13/2022   1:05 PM              0 file-1.md -a----        10/13/2022   1:05 PM              0 file-2.md -a----        10/13/2022   1:06 PM              0 file-3.md -a----        10/13/2022   1:06 PM              0 file-4.md -a----        10/13/2022   1:06 PM              0 file-5.md`

Comme nous pouvons le voir ci-dessus, nous avions cinq fichiers texte sur le bureau. Nous les avons changés en fichiers `.md` en utilisant `get-childitem -Path *.txt` pour sélectionner les objets et avons utilisé `|` pour envoyer ces objets à la cmdlet `rename-item -NewName {$_.name -replace ".txt",".md"}` qui renomme tout à partir de son nom d'origine ($_.name) et remplace le `.txt` du nom par `.md`. C'est une manière beaucoup plus rapide d'interagir avec les fichiers et d'effectuer des actions en masse. Maintenant que nous avons terminé toutes les demandes de M. Tanaka, parlons un instant des autorisations de fichiers et de répertoires.

---

## Que sont les autorisations de fichiers et de répertoires ?

Les autorisations, de manière simplifiée, sont la façon dont notre hôte détermine qui a accès à un objet spécifique et ce qu'il peut en faire. Ces autorisations nous permettent d'appliquer un contrôle de sécurité granulaire sur nos objets pour maintenir une posture de sécurité adéquate. Dans des environnements comme les grandes organisations avec plusieurs départements (comme les RH, l'informatique, les ventes, etc.), on veut s'assurer de maintenir l'accès à l'information sur la base du « besoin d'en connaître ». Cela garantit qu'un intrus ne peut pas corrompre ou utiliser les données à mauvais escient. Le système de fichiers Windows dispose de nombreuses autorisations de base et avancées. Certains des types d'autorisation clés sont :

#### Explication des types d'autorisation

- `Full Control` (Contrôle total) : Le contrôle total permet à l'utilisateur ou au groupe spécifié d'interagir avec le fichier comme il l'entend. Cela inclut tout ce qui suit, la modification des autorisations et la prise de possession du fichier.
- `Modify` (Modifier) : Permet de lire, d'écrire et de supprimer des fichiers et des dossiers.
- `List Folder Contents` (Lister le contenu du dossier) : Permet de voir et de lister les dossiers et sous-dossiers ainsi que d'exécuter des fichiers. Cela ne s'applique qu'aux `dossiers`.
- `Read and Execute` (Lecture et exécution) : Permet aux utilisateurs de voir le contenu des fichiers et d'exécuter des exécutables (.ps1, .exe, .bat, etc.)
- `Write` (Écriture) : L'écriture permet à un utilisateur de créer de nouveaux fichiers et sous-dossiers ainsi que d'ajouter du contenu aux fichiers.
- `Read` (Lecture) : Permet de voir et de lister les dossiers et sous-dossiers et de voir le contenu d'un fichier.
- `Traverse Folder` (Parcourir le dossier) : Parcourir nous permet de donner à un utilisateur la possibilité d'accéder à des fichiers ou sous-dossiers dans une arborescence sans avoir accès au contenu des dossiers de niveau supérieur. C'est un moyen de fournir un accès sélectif du point de vue de la sécurité.

Windows (NTFS, en général) nous permet de définir des autorisations sur un répertoire parent et de faire en sorte que ces autorisations se propagent à chaque fichier et dossier situé dans ce répertoire. Cela nous fait gagner énormément de temps par rapport à la définition manuelle des autorisations sur chaque objet contenu. Cet héritage peut être désactivé si nécessaire pour des fichiers, dossiers et sous-dossiers spécifiques. Si cela est fait, nous devrons définir manuellement les autorisations que nous souhaitons sur les fichiers concernés. Travailler avec les autorisations peut être une tâche complexe et un peu lourde à faire uniquement depuis la CLI, nous laisserons donc la manipulation des autorisations au `Module sur les fondamentaux de Windows`.

---

Travailler avec des fichiers et des répertoires est simple, même si c'est parfois un peu fastidieux. Par la suite, nous ajouterons une nouvelle couche à nos bases de la CLI et nous verrons comment nous pouvons `trouver` et `filtrer` le contenu des fichiers sur l'hôte.

LAB de fin 

![Pasted image 20260902005154.png](/assets/img/writeups/Pasted image 20260902005154.png)

Rep : get-content

![Pasted image 20260902005236.png](/assets/img/writeups/Pasted image 20260902005236.png)

Rep : new-item 

**Contexte :** Exercice de familiarisation avec les commandes de création, édition et suppression de fichiers/dossiers sur un hôte Windows cible, dans le cadre d'un module de cours.

**Machine :** MTanaka (poste Windows), session PowerShell  
**Répertoire de travail initial :** `C:\Users\MTanaka\Documents`

---

**1. Création de l'arborescence**

new-item "ProjetPhenix" -type Directory
New-Item ".\ProjetPhenix\Documents" -type Directory
New-Item ".\ProjetPhenix\Logs" -type Directory
New-Item ".\ProjetPhenix\Scripts" -type Directory

Résultat : dossiers créés avec succès (`Directory: ...ProjetPhenix`). Note : une erreur de frappe (`Los` au lieu de `Logs`) a créé un dossier superflu, corrigé plus tard en fin d'exercice.

 Création des fichiers
new-item ".\ProjetPhenix\Documents\notes.txt" -type file
new-item ".\ProjetPhenix\Logs\audit.log" -type file
new-item ".\ProjetPhenix\Scripts\setup.ps1"

Résultat : trois fichiers vides créés (0 byte chacun), confirmés par `tree /F`.

**3. Édition de contenu**

Add-Content ".\Documents\notes.txt" "Projet initialisé le [date du jour]"
Get-Content .\Documents\notes.txt

Résultat : contenu ajouté et vérifié — `Projet initialisé le [date du jour]` affiché correctement.

**4. Renommage**
Rename-Item .\Logs\audit.log -NewName access_audit.log

Résultat : fichier renommé, confirmé via `tree /F`.

**5. Copie**
Copy-Item .\Documents\notes.txt -Destination .\Documents\notes_backup.txt
Résultat : copie créée, `notes.txt` et `notes_backup.txt` coexistent dans `Documents\`.

 Suppression
remove-item .\Scripts\setup.ps1
remove-item .\Scripts\

Résultat : fichier puis dossier `Scripts` supprimés avec succès.

**7. Nettoyage final**  
Suppression du dossier résiduel `Los` (créé par erreur de frappe à l'étape 1).

ProjetPhenix\
├── Documents\
│   ├── notes.txt
│   └── notes_backup.txt
└── Logs\
    └── access_audit.log
    
**Conclusion :** Toutes les opérations de base (création, édition, renommage, copie, suppression de fichiers et dossiers) ont été réalisées avec succès via PowerShell (`New-Item`, `Add-Content`, `Get-Content`, `Rename-Item`, `Copy-Item`, `Remove-Item`). Une erreur de frappe mineure a été identifiée et corrigée, illustrant l'importance de vérifier régulièrement l'état de l'arborescence avec `tree /F`.