Aussi incroyable que soit PowerShell, son efficacité dépend de la manière dont nous l'utilisons. Une grande partie du langage et des fonctionnalités de PowerShell se prête à une utilisation automatisée. Avoir la capacité de créer des scripts et des modules pour nous dans PowerShell (peu importe leur simplicité ou leur complexité) peut alléger notre charge de travail administrative ou nous décharger de certaines tâches faciles en tant que pentesters. Ce module abordera les éléments qui composent un script et un module PowerShell. À la fin, nous aurons créé notre propre module facile à utiliser et personnalisable.

---

## Comprendre les scripts PowerShell

PowerShell, par nature, est modulaire et permet un contrôle considérable sur son utilisation. L'idée traditionnelle en matière de scripts est que nous écrivons une sorte d'exécutable qui effectue des tâches pour nous dans le langage dans lequel il a été créé. Avec PowerShell, cela reste vrai, à l'exception qu'il peut gérer des entrées provenant de plusieurs langages et types de fichiers différents et peut gérer de nombreux types d'objets différents. Nous pouvons utiliser des scripts uniques de la manière habituelle en les appelant avec la syntaxe `.\script` et en important des modules avec le cmdlet (applet de commande) `Import-Module`. Parlons maintenant un peu des scripts et des modules.

### Scripts vs Modules

La façon la plus simple de voir les choses est qu'un script est un fichier texte exécutable contenant des cmdlets et des fonctions PowerShell, tandis qu'un module peut être un simple script, ou un ensemble de plusieurs fichiers de script, manifestes et fonctions regroupés. L'autre différence principale réside dans leur utilisation. Vous appelleriez généralement un script en l'exécutant directement, tandis que vous pouvez importer un module et tous les scripts et fonctions associés pour les appeler à votre guise. Pour les besoins de cette section, nous les désignerons par le même terme, et tout ce dont nous parlerons dans un fichier de module fonctionne dans un script PowerShell standard. Commençons par les `extensions de fichier` et ce qu'elles signifient pour nous.

### Extensions de fichier

Pour nous familiariser avec certaines extensions de fichier que nous rencontrerons en travaillant avec des scripts et des modules PowerShell, nous avons préparé un petit tableau avec les extensions et leurs descriptions.

#### Extensions PowerShell

|**Extension**|**Description**|
|---|---|
|ps1|L'extension de fichier `*.ps1` représente les scripts PowerShell exécutables.|
|psm1|L'extension de fichier `*.psm1` représente un fichier de module PowerShell. Il définit ce qu'est le module et ce qu'il contient.|
|psd1|Le `*.psd1` est un fichier de données PowerShell qui détaille le contenu d'un module PowerShell dans un tableau de paires clé/valeur.|

Ce sont les principales extensions qui nous intéressent pour le moment. En réalité, les modules PowerShell peuvent avoir de nombreux fichiers d'accompagnement différents avec diverses extensions, mais ils ne sont pas nécessaires pour ce que nous essayons de faire. Si vous souhaitez approfondir vos connaissances sur les fichiers de script PowerShell et les fichiers d'aide, consultez cet [article](https://learn.microsoft.com/en-us/powershell/scripting/developer/module/writing-a-windows-powershell-module?view=powershell-7.2).

---

## Créer un module

Alors, mettons-nous au travail. À partir de maintenant, nous allons couvrir les composants d'un module PowerShell, ce qu'ils contiennent et comment les créer. Ce processus est simple. Il demande juste un peu de planification préalable. Considérez ce scénario :

**Scénario** : Nous nous sommes retrouvés à effectuer les mêmes vérifications encore et encore lors de l'administration des hôtes. Pour accélérer nos tâches, nous allons créer un module PowerShell pour exécuter ces vérifications à notre place, puis afficher les informations que nous demandons. Notre module, une fois utilisé, devrait afficher le `nom de l'ordinateur` de l'hôte, son `adresse IP`, et des `informations de base sur le domaine`, et nous fournir le contenu du répertoire `C:\Users\` afin que nous puissions voir quels utilisateurs se sont connectés de manière interactive à cet hôte.

Maintenant que nous savons ce que contiendra notre module, il est temps de commencer à le construire.

---

## Composants d'un module

Un module est composé de `quatre` composants essentiels :

1. Un `répertoire` contenant tous les fichiers et le contenu requis, enregistré quelque part dans `$env:PSModulePath`.
    - Ceci est fait pour que, lorsque vous tentez de l'importer dans votre session PowerShell ou votre profil, il puisse être trouvé automatiquement sans avoir à spécifier son emplacement.
2. Un fichier `manifeste` listant tous les fichiers et les informations pertinentes sur le module et sa fonction.
    - Cela peut inclure les scripts associés, les dépendances, l'auteur, des exemples d'utilisation, etc.
3. Un fichier de code - généralement un script PowerShell (`.ps1`) ou un fichier de module (`.psm1`) qui contient nos fonctions de script et d'autres informations.
4. D'autres ressources dont le module a besoin, comme des fichiers d'aide, des scripts et d'autres documents de support.

Cette configuration est une pratique standard mais n'est pas strictement nécessaire. Notre module pourrait être simplement un fichier `*.psm1` contenant nos scripts et notre contexte, en omettant le manifeste et les autres fichiers d'aide. PowerShell serait capable d'interpréter et de comprendre quoi faire dans les deux cas. Par souci de conformité, nous allons travailler à la construction d'un module PowerShell standard, incluant le fichier manifeste et quelques fonctionnalités d'aide intégrées.

### Créer un répertoire pour notre module

Créer un répertoire est très simple, comme nous l'avons vu dans les sections précédentes. Avant d'aller plus loin, nous devons créer le répertoire qui contiendra notre module. Ce répertoire doit se trouver dans l'un des chemins de `$env:PSModulePath`. Si vous n'êtes pas sûr de ces chemins, vous pouvez appeler la variable pour voir quel serait le meilleur emplacement. Nous allons donc créer un dossier nommé `quick-recon`.

#### Mkdir

        powershell
`PS C:\htb> mkdir quick-recon        Directory: C:\Users\MTanaka\Documents\WindowsPowerShell\Modules   Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- d-----        10/31/2022   7:38 AM                quick-recon`

Maintenant que nous avons notre répertoire, nous pouvons créer le module. Parlons un instant d'un fichier `manifeste de module`.

### Manifeste de module

Un manifeste de module est un simple fichier `.psd1` qui contient une table de hachage (hash table). Les clés et les valeurs de la table de hachage remplissent les fonctions suivantes :

- Décrivent le `contenu` et les `attributs` du module.
- Définissent les `prérequis`. (modules spécifiques externes au module lui-même, variables, fonctions, etc.)
- Déterminent comment les `composants` sont `traités`.

Si vous ajoutez un fichier manifeste au dossier du module, vous pouvez référencer plusieurs fichiers comme une seule unité en vous référant au manifeste. Le `manifeste` décrit les informations suivantes :

- Les `métadonnées` sur le module, telles que le numéro de version du module, l'auteur et la description.
- Les `prérequis` nécessaires pour importer le module, tels que la version de Windows PowerShell, la version du Common Language Runtime (CLR), et les modules requis.
- Les directives de `traitement`, telles que les scripts, les formats et les types à traiter.
- Les `restrictions` sur les membres du module à exporter, tels que les alias, les fonctions, les variables et les cmdlets à exporter.

Nous pouvons rapidement créer un fichier manifeste en utilisant `New-ModuleManifest` et en spécifiant où nous voulons le placer.

#### New-ModuleManifest

        powershell
`PS C:\htb> New-ModuleManifest -Path C:\Users\MTanaka\Documents\WindowsPowerShell\Modules\quick-recon\quick-recon.psd1 -PassThru  # Module manifest for module 'quick-recon' # # Generated by: MTanaka # # Generated on: 10/31/2022 #  @{  # Script module or binary module file associated with this manifest. # RootModule = ''  # Version number of this module. ModuleVersion = '1.0'  <SNIP>`

En exécutant la commande ci-dessus, nous avons provisionné un `nouveau` fichier manifeste rempli avec les considérations par défaut. Le modificateur `-PassThru` nous permet de voir ce qui est imprimé dans le fichier et sur la console. Nous pouvons maintenant y entrer et remplir les sections que nous voulons avec les informations pertinentes. Rappelez-vous que toutes les lignes dans les fichiers manifestes sont facultatives, à l'exception de la ligne `ModuleVersion`. La modification du manifeste sera plus facile depuis une interface graphique où vous pouvez utiliser un éditeur de texte ou un IDE tel que VSCode. Si nous devions compléter notre fichier manifeste maintenant pour ce module, il ressemblerait à quelque chose comme ceci :

#### Exemple de manifeste

        PowerShell
`# Manifeste de module pour le module 'quick-recon' # # Généré par : MTanaka # # Généré le : 31/10/2022 #  @{  # Fichier de module de script ou de module binaire associé à ce manifeste. # RootModule = 'C:\Users\MTanaka\WindowsPowerShell\Modules\quick-recon\quick-recon.psm1'  # Numéro de version de ce module. ModuleVersion = '1.0'  # ID utilisé pour identifier ce module de manière unique GUID = '0a062bb1-8a1b-4bdb-86ed-5adbe1071d2f'  # Auteur de ce module Author = 'MTanaka'  # Entreprise ou fournisseur de ce module CompanyName = 'Greenhorn.Corp.'  # Déclaration de copyright pour ce module Copyright = '(c) 2022 Greenhorn.Corp. All rights reserved.'  # Description des fonctionnalités fournies par ce module Description = 'Ce module effectuera plusieurs vérifications rapides sur l'hôte pour la reconnaissance d'informations clés.'  # Fonctions à exporter depuis ce module. Pour de meilleures performances, n'utilisez pas de caractères génériques et ne supprimez pas l'entrée. Utilisez un tableau vide s'il n'y a aucune fonction à exporter. FunctionsToExport = @()  # Cmdlets à exporter depuis ce module. Pour de meilleures performances, n'utilisez pas de caractères génériques et ne supprimez pas l'entrée. Utilisez un tableau vide s'il n'y a aucun cmdlet à exporter. CmdletsToExport = @()  # Variables à exporter depuis ce module VariablesToExport = '*'  # Alias à exporter depuis ce module. Pour de meilleures performances, n'utilisez pas de caractères génériques et ne supprimez pas l'entrée. Utilisez un tableau vide s'il n'y a aucun alias à exporter. AliasesToExport = @()  # Liste de tous les modules empaquetés avec ce module # ModuleList = @()  # Liste de tous les fichiers empaquetés avec ce module # FileList = @()   }`

Nous pourrons revenir au manifeste plus tard et ajouter les `fonctions, cmdlets et variables` que nous voulons autoriser à l'exportation. Nous devons d'abord construire et terminer le script.

### Créer notre fichier de script

Nous pouvons utiliser le cmdlet `New-Item` (ni) pour créer notre fichier.

#### New-Item

        powershell
`PS C:\htb>  ni quick-recon.psm1 -ItemType File       Directory: C:\Users\MTanaka\Documents\WindowsPowerShell\Modules\quick-recon   Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a----        10/31/2022   9:07 AM              0 quick-recon.psm1`

Assez facile, non ? Maintenant, il faut remplir cette bête.

### Importer les modules dont vous avez besoin

Si notre nouveau PowerShell nécessite d'autres modules ou cmdlets pour fonctionner correctement, nous placerons une chaîne `Import-Module` au début de notre fichier de script. L'utilisation de `Import-Module` de cette manière fonctionne de la même façon que si nous l'exécutions depuis le shell ; il appelle et charge les modules dont nous avons besoin avant d'exécuter notre script. Pour atteindre les objectifs de ce module, de nombreux cmdlets et fonctions sont déjà intégrés à PowerShell. Nous avons cependant besoin d'un cmdlet du module PowerShell ActiveDirectory. Ajoutons donc une ligne d'importation pour le module `ActiveDirectory`.

#### Importer dans notre module

        powershell
`Import-Module ActiveDirectory` 

Assez simple, non ? Nous avons maintenant notre fichier de script de module `quick-recon.psm1`, et nous y avons ajouté une instruction `import-module`. Nous pouvons maintenant passer au cœur du fichier, nos `fonctions`.

### Fonctions et travail avec PowerShell

Nous devons faire quatre choses principales avec ce module :

- Récupérer le `ComputerName` de l'hôte
- Récupérer la configuration IP de l'hôte
- Récupérer les informations de base du domaine
- Récupérer le contenu du répertoire `C:\Users\`

Pour commencer, concentrons-nous sur la sortie du `ComputerName`. Nous pouvons l'obtenir de plusieurs manières avec divers cmdlets, modules et commandes DOS. Notre script utilisera la variable d'environnement (`$env:ComputerName`) pour acquérir le nom d'hôte pour la sortie. Pour faciliter la lecture de notre sortie plus tard, nous utiliserons une autre variable nommée `$hostname` pour stocker la sortie de la variable d'environnement. Pour capturer l'adresse IP des adaptateurs hôtes actifs, nous utiliserons `IPConfig` et stockerons cette information dans la variable `$IP`. Pour les informations de base sur le domaine, nous utiliserons `Get-ADDomain` et stockerons la sortie dans `$Domain`. Enfin, nous obtiendrons une liste des dossiers utilisateur dans `C:\Users\` avec `Get-ChildItem` et la stockerons dans `$Users`. Pour créer nos variables, nous devons d'abord spécifier un nom comme (`$Hostname`), ajouter le symbole `=` et le faire suivre de l'action ou des valeurs que nous voulons qu'il contienne. Par exemple, la première variable dont nous avons besoin, `$Hostname`, apparaîtrait comme suit : (`$Hostname = $env:ComputerName`). Maintenant, plongeons-nous dans la création du reste de nos variables.

#### Variables

        powershell
`Import-Module ActiveDirectory   $Hostname = $env:ComputerName $IP = ipconfig  $Domain = Get-ADDomain   $Users = Get-ChildItem C:\Users\` 
  

Nos variables sont maintenant configurées pour exécuter des commandes ou des fonctions uniques, récupérant la sortie nécessaire. Maintenant, formatons ces données et créons une belle sortie. Nous pouvons le faire en écrivant le résultat dans un `fichier` à l'aide de `New-Item` et `Add-Content`. Pour faciliter les choses, nous allons transformer ce processus de sortie en une fonction appelable nommée `Get-Recon`.

#### Afficher nos informations

        powershell
`Import-Module ActiveDirectory  function Get-Recon {        $Hostname = $env:ComputerName        $IP = ipconfig      $Domain = Get-ADDomain       $Users = Get-ChildItem C:\Users\      new-Item ~\Desktop\recon.txt -ItemType File       $Vars = "***---Hostname info---***", $Hostname, "***---Domain Info---***", $Domain, "***---IP INFO---***",  $IP, "***---USERS---***", $Users      Add-Content ~\Desktop\recon.txt $Vars   }` 

`New-Item` crée d'abord notre fichier de sortie, puis remarquez comment nous avons utilisé une variable de plus (`$Vars`) pour formater notre sortie. Nous appelons chaque variable et insérons une ligne descriptive entre chacune. Enfin, le cmdlet `Add-Content` ajoute les données que nous collectons dans un fichier appelé `recon.txt` en y écrivant les résultats de `$Vars`. Notre fonction prend forme maintenant. Ensuite, nous devons ajouter quelques commentaires à notre fichier pour que d'autres puissent comprendre ce que nous essayons d'accomplir et pourquoi nous l'avons fait de cette manière.

### Commentaires dans le script

Le (`#`) indiquera à PowerShell que la ligne contient un commentaire dans votre fichier de script ou de module. Si vos commentaires doivent s'étendre sur plusieurs lignes, vous pouvez utiliser `<#` et `#>` pour envelopper plusieurs lignes en un seul grand commentaire, comme illustré ci-dessous :

#### Blocs de commentaires

        powershell
`# Ceci est un commentaire sur une seule ligne.    <# Cette ligne et les lignes suivantes sont toutes enveloppées dans le spécificateur de commentaire.  Rien dans cette fenêtre ne sera lu par le script comme faisant partie d'une fonction. Ce texte existe uniquement pour que le créateur et nous puissions transmettre des informations pertinentes.  #>`  

#### Commentaires ajoutés

        powershell
`Import-Module ActiveDirectory  function Get-Recon {       # Collecte le nom d'hôte de notre PC.     $Hostname = $env:ComputerName       # Collecte la configuration IP.     $IP = ipconfig     # Collecte les informations de base du domaine.     $Domain = Get-ADDomain      # Affiche les utilisateurs qui se sont connectés et ont créé une structure de répertoires de base dans "C:\Users\".     $Users = Get-ChildItem C:\Users\     # Crée un nouveau fichier pour y placer nos résultats de reconnaissance.     new-Item ~\Desktop\recon.txt -ItemType File      # Une variable pour contenir les résultats de nos autres variables.      $Vars = "***---Hostname info---***", $Hostname, "***---Domain Info---***", $Domain, "***---IP INFO---***",  $IP, "***---USERS---***", $Users     # Effectue l'action.     Add-Content ~\Desktop\recon.txt $Vars   }` 

C'est aussi simple que ça. Rien de bien sorcier avec les commentaires. Maintenant, nous devons inclure un peu de syntaxe d'`aide` pour que les autres puissent comprendre comment utiliser notre module.

### Inclure de l'aide

PowerShell utilise une forme d'`aide basée sur les commentaires` pour intégrer tout ce dont vous avez besoin pour le script ou le module. Nous pouvons utiliser des `blocs de commentaires` comme ceux que nous avons vus plus haut, ainsi que des `mots-clés` reconnus pour construire la section d'aide et même l'appeler ensuite avec `Get-Help`. En ce qui concerne l'emplacement, nous avons `deux` options ici. Nous pouvons placer l'aide à l'intérieur de la fonction elle-même ou à l'extérieur de la fonction dans le script. Si nous souhaitons la placer à l'intérieur de la fonction, elle doit se trouver au début de la fonction, juste après la ligne d'ouverture de la fonction, ou à la fin de la fonction, une ligne après la dernière action de la fonction. Si nous la plaçons dans le script mais à l'extérieur de la fonction elle-même, nous devons la placer au-dessus de notre fonction avec pas plus d'une ligne entre l'aide et la fonction. Pour une étude plus approfondie de l'aide dans PowerShell, consultez cet [article](https://learn.microsoft.com/en-us/powershell/scripting/developer/help/writing-help-for-windows-powershell-scripts-and-functions?view=powershell-7.2). Définissons maintenant notre section d'aide. Nous la placerons pour l'instant à l'extérieur de la fonction, en haut du script.

#### Aide du module

        powershell
`Import-Module ActiveDirectory  <#  .Description   Cette fonction effectue quelques tâches de reconnaissance simples pour l'utilisateur. Nous importons le module et exécutons la commande 'Get-Recon' pour récupérer notre sortie. Chaque variable et ligne dans la fonction et le script sont commentées pour votre compréhension. Pour l'instant, ce module ne fonctionne que sur l'hôte local à partir duquel vous l'exécutez, et la sortie sera envoyée à un fichier nommé 'recon.txt' sur le bureau de l'utilisateur qui a ouvert le shell. Des fonctions de reconnaissance à distance arrivent bientôt !  .Example   Après avoir importé le module, exécutez "Get-Recon" 'Get-Recon       Directory: C:\Users\MTanaka\Desktop   Mode                 LastWriteTime         Length Name                                                                                                                                         ----                 -------------         ------ ----                                                                                                                                         -a----         11/3/2022  12:46 PM              0 recon.txt '  .Notes   Des fonctions de reconnaissance à distance arrivent bientôt ! Ce script sert d'introduction à l'écriture de fonctions et de scripts et à la création de modules PowerShell.    #>  function Get-Recon {   <SNIP>`  

Remarquez notre utilisation des `mots-clés`. Pour spécifier un mot-clé dans le bloc de commentaires, nous utilisons la syntaxe `.<mot-clé>` et plaçons ensuite le texte descriptif en dessous. Nous n'avons spécifié que `Description, Example, et Notes`, mais plusieurs autres mots-clés peuvent être placés dans le bloc d'aide. Pour voir tous les mots-clés disponibles, consultez cet article sur les [mots-clés de l'aide basée sur les commentaires](https://learn.microsoft.com/en-us/powershell/scripting/developer/help/comment-based-help-keywords?view=powershell-7.2). La dernière partie à aborder avant de tout regrouper dans notre joli fichier de module PowerShell est l'exportation et la protection des fonctions.

### Protéger les fonctions

Nous pouvons ajouter à nos scripts des fonctions que nous ne voulons pas voir être accédées, exportées ou utilisées par d'autres scripts ou processus dans PowerShell. Pour protéger une fonction de l'exportation ou pour la définir explicitement pour l'exportation, `Export-ModuleMember` est le cmdlet approprié. Le contenu est exportable si nous omettons cela de nos modules de script. Si nous le plaçons dans le fichier mais le laissons vide comme ceci :

#### Exclure de l'exportation

        Powershell
`Export-ModuleMember`  

Cela garantit que les variables, alias et fonctions du module ne peuvent pas être `exportés`. Si nous souhaitons spécifier ce qu'il faut exporter, nous pouvons les ajouter à la chaîne de commande comme ceci :

#### Exporter des fonctions et des variables spécifiques

        Powershell
`Export-ModuleMember -Function Get-Recon -Variable Hostname` 

Alternativement, si vous ne vouliez exporter que toutes les fonctions et une variable spécifique, par exemple, vous pourriez utiliser `*` après `-Function`, puis spécifier explicitement les variables à exporter. Ajoutons donc le cmdlet `Export-ModuleMember` à notre script et spécifions que nous voulons autoriser l'exportation de notre fonction `Get-Recon` et de notre variable `Hostname`.

#### Ajout de la ligne d'exportation

        Powershell
`<SNIP>   function Get-Recon {       # Collecte le nom d'hôte de notre PC     $Hostname = $env:ComputerName       # Collecte la configuration IP     $IP = ipconfig     # Collecte les informations de base du domaine     $Domain = Get-ADDomain      # Affiche les utilisateurs qui se sont connectés et ont créé une structure de répertoires de base dans "C:\Users"     $Users = Get-ChildItem C:\Users\     # Crée un nouveau fichier pour y placer nos résultats de reconnaissance     new-Item ~\Desktop\recon.txt -ItemType File      # Une variable pour contenir les résultats de nos autres variables      $Vars = "***---Hostname info---***", $Hostname, "***---Domain Info---***", $Domain, "***---IP INFO---***",  $IP, "***---USERS---***", $Users     # Effectue l'action      Add-Content ~\Desktop\recon.txt $Vars   }   Export-ModuleMember -Function Get-Recon -Variable Hostname`  

### Portée (Scope)

Lorsque l'on traite des scripts, de la session PowerShell et de la manière dont les éléments sont reconnus sur la ligne de commande, le concept de portée (Scope) entre en jeu. La portée, en substance, est la manière dont PowerShell reconnaît et protège les objets au sein de la session contre l'accès ou la modification non autorisés. PowerShell utilise actuellement `trois` niveaux de portée différents :

#### Niveaux de portée

|**Portée**|**Description**|
|---|---|
|Globale|C'est le niveau de portée par défaut de PowerShell. Il affecte tous les objets qui existent au démarrage de PowerShell ou à l'ouverture d'une nouvelle session. Toutes les variables, alias, fonctions et tout ce que vous spécifiez dans votre profil PowerShell seront créés dans la portée globale.|
|Locale|C'est la portée actuelle dans laquelle vous opérez. Il peut s'agir de l'une des portées par défaut ou des portées enfants qui sont créées.|
|Script|C'est une portée temporaire qui s'applique à tous les scripts en cours d'exécution. Elle ne s'applique qu'au script et à son contenu. Les autres scripts et tout ce qui se trouve en dehors ne sauront pas qu'elle existe. Pour le script, sa portée est la portée locale.|

Ceci est important pour nous si nous ne voulons pas que quoi que ce soit en dehors de la portée dans laquelle nous exécutons le script puisse accéder à son contenu. De plus, nous pouvons avoir des portées enfants créées au sein des portées principales. Par exemple, lorsque vous exécutez un script, la portée du script est instanciée, puis toute fonction appelée peut également créer une portée enfant entourant cette fonction et ses variables incluses. Si nous voulions nous assurer que le contenu de cette fonction spécifique n'était pas accessible au reste du script ou à la session PowerShell elle-même, nous pourrions modifier sa portée. C'est un sujet complexe et qui dépasse le niveau de ce module actuellement, mais nous avons jugé utile de le mentionner. Pour en savoir plus sur la portée dans PowerShell, consultez la documentation [ici](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.2).

### Assembler le tout

Maintenant que nous avons examiné et créé nos différentes parties, voyons le tout assemblé.

#### Produit final

        PowerShell
`import-module ActiveDirectory  <#  .Description   Cette fonction effectue quelques tâches de reconnaissance simples pour l'utilisateur. Nous importons le module et exécutons la commande 'Get-Recon' pour récupérer notre sortie. Chaque variable et ligne dans la fonction et le script sont commentées pour votre compréhension. Pour l'instant, ce module ne fonctionne que sur l'hôte local à partir duquel vous l'exécutez, et la sortie sera envoyée à un fichier nommé 'recon.txt' sur le bureau de l'utilisateur qui a ouvert le shell. Des fonctions de reconnaissance à distance arrivent bientôt !  .Example   Après avoir importé le module, exécutez "Get-Recon" 'Get-Recon       Directory: C:\Users\MTanaka\Desktop   Mode                 LastWriteTime         Length Name                                                                                                                                         ----                 -------------         ------ ----                                                                                                                                         -a----         11/3/2022  12:46 PM              0 recon.txt '  .Notes   Des fonctions de reconnaissance à distance arrivent bientôt ! Ce script sert d'introduction à l'écriture de fonctions et de scripts et à la création de modules PowerShell.    #> function Get-Recon {       # Collecte le nom d'hôte de notre PC     $Hostname = $env:ComputerName       # Collecte la configuration IP     $IP = ipconfig     # Collecte les informations de base du domaine     $Domain = Get-ADDomain      # Affiche les utilisateurs qui se sont connectés et ont créé une structure de répertoires de base dans "C:\Users"     $Users = Get-ChildItem C:\Users\     # Crée un nouveau fichier pour y placer nos résultats de reconnaissance     new-Item ~\Desktop\recon.txt -ItemType File      # Une variable pour contenir les résultats de nos autres variables      $Vars = "***---Hostname info---***", $Hostname, "***---Domain Info---***", $Domain, "***---IP INFO---***",  $IP, "***---USERS---***", $Users     # Effectue l'action      Add-Content ~\Desktop\recon.txt $Vars   }   Export-ModuleMember -Function Get-Recon -Variable Hostname` 

Et voilà, notre fichier de module complet. Notre utilisation de l'aide basée sur les commentaires, des fonctions, des variables et de la protection du contenu crée un script dynamique et facile à lire. À partir de là, nous pouvons enregistrer ce fichier dans notre répertoire de modules que nous avons créé et l'importer depuis PowerShell pour l'utiliser.

#### Importer le module pour l'utiliser

        powershell
``PS C:\htb> Import-Module 'C:\Users\MTanaka\Documents\WindowsPowerShell\Modules\quick-recon.psm1`  PS C:\Users\MTanaka\Documents\WindowsPowerShell\Modules\quick-recon> get-module  ModuleType Version    Name                                ExportedCommands ---------- -------    ----                                ---------------- Manifest   3.1.0.0    Microsoft.PowerShell.Management     {Add-Computer, Add-Content, Checkpoint-Computer, Clear-Con... Script     2.0.0      PSReadline                          {Get-PSReadLineKeyHandler, Get-PSReadLineOption, Remove-PS... Script     0.0        quick-recon                         Get-Recon``

Parfait. Nous pouvons voir que notre module a été importé à l'aide du cmdlet `Import-Module`, et pour nous assurer qu'il était chargé dans notre session, nous avons exécuté le cmdlet `Get-Module`. Il nous a montré que notre module `quick-recon` a été importé et qu'il possède la commande `Get-Recon` qui pourrait être exportée. Nous pouvons également tester l'aide basée sur les commentaires en essayant d'exécuter `Get-Help` sur notre module.

#### Validation de l'aide

        powershell
`PS C:\htb> get-help get-recon  NOM     Get-Recon  SYNOPSIS   SYNTAXE     Get-Recon [<CommonParameters>]   DESCRIPTION     Cette fonction effectue quelques tâches de reconnaissance simples pour l'utilisateur. Nous importons simplement le module, puis nous     exécutons la commande 'Get-Recon' pour récupérer notre sortie. Chaque variable et chaque ligne de la fonction et du     script sont commentées pour votre compréhension. Pour l'instant, cela ne fonctionne que sur l'hôte local à partir duquel     vous l'exécutez, et la sortie sera envoyée à un fichier nommé 'recon.txt' sur le bureau de l'utilisateur qui a ouvert le     shell. Des fonctions de reconnaissance à distance arrivent bientôt !   LIENS ASSOCIÉS  REMARQUES     Pour voir les exemples, tapez : "get-help Get-Recon -examples."     Pour plus d'informations, tapez : "get-help Get-Recon -detailed."     Pour des informations techniques, tapez : "get-help Get-Recon -full."`

Notre aide fonctionne également. Nous avons donc maintenant un module entièrement fonctionnel à notre disposition. Nous pouvons l'utiliser comme base pour tout ce que nous construirons par la suite et nous pourrions même le modifier pour y inclure d'autres fonctions de reconnaissance à l'avenir.

---

C'était un exemple simple de ce qui peut être fait du point de vue de l'automatisation avec PowerShell, mais une excellente façon de le voir construit et utilisé. Nous pouvons utiliser la création de modules et les scripts à notre avantage et simplifier nos processus au fur et à mesure. Gagner du temps nous permet finalement de faire plus en tant qu'opérateurs et de consacrer du temps à d'autres tâches qui requièrent notre attention. Si vous souhaitez une copie du module `quick-recon` pour votre usage, une copie est enregistrée dans les `Ressources` de ce module en haut à droite de n'importe quelle page de section.