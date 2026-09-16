[[Command Prompt Basics]]

Maintenant que nous sommes plus à l'aise avec l'invite de commandes, abordons l'un des sujets les plus critiques pour comprendre le fonctionnement des applications et des scripts sous Windows : les `variables d'environnement`. Dans cette section, nous verrons ce qu'elles sont, leurs utilités et comment nous pouvons les gérer sur notre système.

---

## Qu'est-ce qu'une variable d'environnement

Les variables d'environnement sont des paramètres qui sont souvent appliqués de manière globale à nos hôtes. On les trouve sur les hôtes Windows, Linux et macOS. Ce concept n'est pas spécifique à un type de système d'exploitation, mais leur fonctionnement diffère sur chacun d'eux. Les variables d'environnement sont accessibles par la plupart des utilisateurs et des applications sur l'hôte et sont utilisées pour exécuter des scripts et pour accélérer le fonctionnement des applications et leur référencement des données. Sur un hôte Windows, les variables d'environnement ne sont `pas` sensibles à la casse et peuvent contenir des espaces et des chiffres dans leur nom. La seule véritable contrainte est qu'elles ne peuvent pas avoir un nom qui commence par un chiffre ou qui inclut un signe égal. Lorsqu'on y fait référence, ces variables sont appelées comme suit :

        cmd
`%SUPER_IMPORTANT_VARIABLE%`

Il est courant de voir ces variables (en particulier celles déjà intégrées au système) affichées en majuscules et utilisant un tiret bas pour lier les mots de leur nom. Avant de continuer, nous devons mentionner un concept crucial concernant les variables d'environnement, connu sous le nom de portée (`Scope`).

#### Portée des variables

Dans ce contexte, la `portée` (`Scope`) est un concept de programmation qui définit où les variables peuvent être accédées ou référencées. La « portée » peut être globalement divisée en deux catégories :

- **Globale :**
    - Les variables globales sont accessibles de manière `globale`. Dans ce contexte, la portée globale nous indique que nous pouvons accéder et référencer les données stockées dans la variable depuis n'importe où dans un programme.
- **Locale :**
    - Les variables locales ne sont accessibles que dans un contexte `local`. `Local` signifie que les données stockées dans ces variables ne peuvent être accédées et référencées qu'au sein de la fonction ou du contexte dans lequel elles ont été déclarées.

Prenons un scénario d'exemple pour mieux comprendre les différences. Dans ce scénario, nous avons deux utilisateurs, `Alice` et `Bob`. Les deux utilisateurs ont une session d'invite de commandes par défaut et sont connectés simultanément à la même machine. De plus, les deux utilisateurs exécutent une commande pour afficher les données stockées dans la variable `%WINDIR%`, comme le montrent les exemples ci-dessous.

#### Illustration des variables globales

#### Exemple 1 :

        cmd
`C:\Users\alice> echo %WINDIR%  C:\Windows`

#### Exemple 2 :

        cmd
`C:\Users\bob> echo %WINDIR%  C:\Windows`

Nous pouvons voir que cette variable est accessible aux deux utilisateurs. Par conséquent, les deux utilisateurs peuvent afficher les données qu'elle contient. C'est parce que la variable `%WINDIR%` est une `variable globale` telle que définie par le système d'exploitation Windows. Cependant, que se passerait-il si Alice voulait créer une variable secrète que Bob ne pourrait ni voir ni accéder ; comment s'y prendrait-elle ?

#### Illustration des variables locales

#### Exemple 1 :

        cmd
`C:\Users\alice> set SECRET=HTB{5UP3r_53Cr37_V4r14813}  C:\Users\alice> echo %SECRET% HTB{5UP3r_53Cr37_V4r14813}`

#### Exemple 2 :

        cmd
`C:\Users\bob> echo %SECRET% %SECRET%  C:\Users\bob> set %SECRET% Environment variable %SECRET% not defined`

Dans le premier exemple, Alice crée une variable nommée `SECRET` et y stocke la valeur `HTB{5UP3r_53Cr37_V4r14813}`. Après avoir défini la valeur de la variable, Alice la récupère en utilisant la commande `echo` pour afficher la valeur stockée à l'intérieur. Cependant, lorsque Bob tente de récupérer la même variable, il n'y parvient pas, car elle n'est pas définie dans son environnement actuel. Ce qu'Alice a créé est une `variable locale` à laquelle elle seule pouvait accéder, car elle n'était définie que dans le contexte de son environnement local.

Remarque : Cette explication de la portée globale par rapport à la portée locale n'est en aucun cas un guide exhaustif de leurs différences et n'inclura pas de concepts plus avancés. Cette section a pour but de fournir les informations de base nécessaires pour la suite.

Maintenant que nous avons une compréhension de base des variables et une idée générale des principes fondamentaux des `portées` définies, examinons comment Windows interagit avec les variables d'environnement, les stocke et comment nous pouvons interagir avec elles. Comme auparavant, Windows, comme tout autre programme, contient son propre ensemble de variables appelées `variables d'environnement`. Ces variables peuvent être séparées en fonction de leurs portées définies, appelées portées `Système` (`System`) et `Utilisateur` (`User`). De plus, il existe une autre portée définie, appelée portée `Processus` (`Process`), mais elle est volatile par nature et est considérée comme une sous-portée des portées `Système` et `Utilisateur`. En gardant cela à l'esprit, explorons leurs différences et leurs fonctionnalités prévues.

|Portée|Description|Permissions requises pour l'accès|Emplacement dans le registre|
|---|---|---|---|
|`Système (Machine)`|La portée Système contient les variables d'environnement définies par le système d'exploitation (OS) et sont accessibles de manière globale par tous les utilisateurs et comptes qui se connectent au système. Le système d'exploitation a besoin de ces variables pour fonctionner correctement et elles sont chargées à l'exécution.|Administrateur local ou Administrateur de domaine|`HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment`|
|`Utilisateur`|La portée Utilisateur contient les variables d'environnement définies par l'utilisateur actuellement actif et ne sont accessibles qu'à lui, et non aux autres utilisateurs qui peuvent se connecter au même système.|Utilisateur actif actuel, Administrateur local ou Administrateur de domaine|`HKEY_CURRENT_USER\Environment`|
|`Processus`|La portée Processus contient les variables d'environnement qui sont définies et accessibles dans le contexte du processus en cours d'exécution. En raison de leur nature transitoire, leur durée de vie ne s'étend que sur celle du processus en cours d'exécution dans lequel elles ont été initialement définies. Elles héritent également des variables des portées Système/Utilisateur et du processus parent qui les a créées (uniquement s'il s'agit d'un processus enfant).|Processus enfant actuel, Processus parent ou Utilisateur actif actuel|`Aucun (Stocké dans la mémoire du processus)`|

Le tableau devrait fournir un bon aperçu général de la manière dont Windows gère les variables d'environnement et du fait que seuls certains utilisateurs peuvent accéder à certaines variables en raison des permissions. Maintenant que nous comprenons ces différences, commençons à essayer d'apporter nous-mêmes des modifications spécifiques aux variables d'environnement.

---

## Utiliser Set et Echo pour afficher les variables

Pour comprendre les modifications apportées aux variables d'environnement, nous avons besoin d'un moyen d'afficher leur contenu via l'invite de commandes. Heureusement, nous disposons de deux options : `set` et `echo`.

#### Affichage avec Set

        cmd
`C:\Users\htb\Desktop>set %SYSTEMROOT%  Environment variable C:\Windows not defined`

À l'ouverture de l'invite de commandes, vous pouvez exécuter la commande `set` pour afficher toutes les variables d'environnement disponibles sur le système. Alternativement, vous pouvez entrer la même commande suivie du nom de la variable sans lui assigner de valeur pour afficher la valeur d'une variable spécifique. Nous voyons que dans ce cas, il est mentionné que la valeur elle-même n'est pas définie ; cependant, c'est parce que nous ne définissons pas la valeur de `%SYSTEMROOT%` avec `set` dans cet exemple.

#### Affichage avec Echo

        cmd
`C:\Users\htb\>echo %PATH%  C:\Users\htb\Desktop`

Similairement à l'exemple ci-dessus, vous pouvez utiliser `echo` pour afficher la valeur d'une variable d'environnement. Contrairement à la commande précédente, `echo` est utilisé pour afficher la valeur contenue dans la variable et n'a pas de fonctionnalités intégrées supplémentaires pour modifier les variables d'environnement. Dans la section suivante, nous verrons comment créer de nouvelles variables, supprimer celles qui ne sont pas nécessaires et modifier les variables existantes à l'aide de l'invite de commandes.

---

## Gérer les variables d'environnement

Maintenant que nous avons un moyen d'afficher les variables d'environnement existantes sur notre système, nous devons être capables de les créer, de les supprimer et de les gérer depuis le confort et la sécurité de notre invite de commandes. Nous disposons de deux méthodes pour ce faire. Nous pouvons utiliser soit `set`, soit `setx` pour effectuer les actions souhaitées.

#### Quand utiliser `set` ou `setx`

Les commandes [set](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/set_1) et [setx](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/setx) sont des utilitaires de ligne de commande qui nous permettent d'afficher, de définir et de supprimer des variables d'environnement. La différence réside dans la manière dont elles atteignent ces objectifs. L'utilitaire `set` ne manipule les variables d'environnement que dans la session de ligne de commande actuelle. Cela signifie qu'une fois que nous fermons notre session actuelle, les ajouts, suppressions ou modifications ne seront pas conservés la prochaine fois que nous ouvrirons une invite de commandes. Si nous devons apporter des modifications permanentes aux variables d'environnement, nous pouvons utiliser `setx` pour effectuer les changements appropriés dans le registre, qui persisteront après le redémarrage de notre session d'invite de commandes actuelle.

**Remarque :** Avec `setx`, nous disposons également de fonctionnalités supplémentaires, comme la possibilité de créer et de modifier des variables sur les ordinateurs du domaine ainsi que sur notre machine locale.

Nous devrions maintenant être familiers avec certaines des principales différences entre les deux commandes discutées ci-dessus. Il y aura des moments et des situations où l'une devra être privilégiée par rapport à l'autre. En tant qu'attaquant, il y aura des moments où nous devrons énumérer les variables d'environnement existantes pour obtenir des informations. Passons maintenant à la création de variables réelles que nous pourrons utiliser.

#### Créer des variables

La création de variables d'environnement est une tâche assez simple. Nous pouvons utiliser soit `set`, soit `setx` en fonction de la tâche à accomplir et de notre objectif général. Les exemples suivants montreront les deux en action pour nous donner une idée de la syntaxe de chaque commande. Veuillez noter que la syntaxe entre les deux est très similaire dans certains cas ; cependant, `setx` possède quelques fonctionnalités supplémentaires que nous tenterons d'explorer ici. De plus, pour éviter que les choses ne deviennent trop répétitives, nous ne montrerons les commandes `set` et `setx` que pour la création de variables et nous utiliserons `setx` pour tous les autres exemples. Sachez simplement que la syntaxe pour créer, supprimer et modifier des variables d'environnement est identique.

Créons une variable pour stocker la valeur de l'adresse IP du contrôleur de domaine (`DC`), car nous pourrions la trouver utile pour tester la connectivité au domaine ou pour interroger des mises à jour. Nous pouvons le faire en utilisant la commande `set`.

#### Utiliser set

        cmd
`C:\htb> set DCIP=172.16.5.2`

À l'exécution de cette commande, il n'y a pas de sortie immédiate. Cependant, sachez que la variable a été définie pour notre session d'invite de commandes actuelle. Nous pouvons le vérifier en affichant sa valeur avec `echo`.

#### Valider la modification

        cmd
`C:\htb> echo %DCIP%  172.16.5.2`

Comme nous pouvons le voir, la variable d'environnement `%DCIP%` est maintenant définie et accessible. Comme indiqué précédemment, cette modification est considérée comme faisant partie de la portée `processus` (`process`), car chaque fois que nous quittons l'invite de commandes et démarrons une nouvelle session, cette variable cesse d'exister sur le système. Nous pouvons remédier à cette situation en définissant cette variable de manière permanente dans l'environnement à l'aide de `setx`.

#### Utiliser setx

        cmd
`C:\htb> setx DCIP 172.16.5.2  SUCCESS: Specified value was saved.`

Dans cet exemple, nous pouvons voir que la syntaxe entre les commandes varie légèrement. Précédemment, nous devions assigner la valeur à la variable avec un signe égal. Ici, nous devons fournir le nom de la variable suivi de la valeur. La syntaxe est la suivante : `setx <nom de la variable> <valeur> <paramètres>`. Après avoir exécuté cette commande, nous voyons que notre valeur a été enregistrée dans le registre, car le message `SUCCESS` nous a été fourni. Bien sûr, si nous sommes curieux de savoir si la valeur est vraiment définie, nous pouvons la valider exactement comme nous l'avons fait ci-dessus. N'oubliez pas que ce changement ne prendra effet qu'après l'ouverture d'une nouvelle session d'invite de commandes. Sur un système distant, les variables créées ou modifiées par cet outil seront disponibles lors de la prochaine session de connexion.

#### Modifier des variables

En plus de créer nos propres variables, nous pouvons modifier celles qui existent déjà. Puisque nous sommes déjà familiers avec leur création, la modification est tout aussi simple, sauf que nous remplacerons les valeurs existantes. Supposons que l'adresse IP de notre `DC` ait changé et que nous devions mettre à jour la valeur de notre variable d'environnement personnalisée pour refléter ce changement.

#### Utiliser setx

        cmd
`C:\htb> setx DCIP 172.16.5.5  SUCCESS: Specified value was saved.`

Dans l'exemple précédent, nous avons défini `172.16.5.2` comme valeur pour le DC sur le réseau ; cependant, en utilisant `setx`, nous pouvons mettre à jour cette valeur en redéfinissant simplement la valeur à notre nouvelle adresse, `172.16.5.5`.

#### Valider la modification

        cmd
`C:\htb> echo %DCIP%  172.16.5.5`

Nous avons réussi à modifier notre variable personnalisée initiale pour refléter le changement d'adresse IP du DC. Nous pouvons maintenant passer à la suppression des variables.

#### Supprimer des variables

Tout comme pour la création et la modification de variables, nous pouvons également supprimer des variables d'environnement de manière très similaire. Pour supprimer des variables, nous ne pouvons pas les effacer directement comme nous le ferions pour un fichier ou un répertoire ; nous devons plutôt vider leur valeur en la définissant sur rien. Cette action supprimera de fait la variable et empêchera son utilisation prévue, car sa valeur a été retirée. Dans notre premier exemple, nous avons créé la variable `%DCIP%` contenant la valeur de l'adresse IP du contrôleur de domaine sur le réseau et l'avons sauvegardée de manière permanente dans le registre. Nous pouvons essayer de la supprimer en faisant ce qui suit :

#### Utiliser setx

        cmd
`C:\htb> setx DCIP ""   SUCCESS: Specified value was saved.`

Cette commande supprimera `%DCIP%` des variables d'environnement actuelles de notre système et cela se reflétera également dans le registre une fois que nous ouvrirons une nouvelle session d'invite de commandes. Nous pouvons vérifier que c'est bien le cas en faisant ce qui suit :

#### Vérifier que la variable a été supprimée

        cmd
`C:\htb> set DCIP Environment variable DCIP not defined  C:\htb> echo %DCIP% %DCIP%`

En utilisant à la fois `set` et `echo`, nous pouvons vérifier que la variable `%DCIP%` n'est plus définie et n'existe plus dans notre environnement.

---

## Variables d'environnement importantes

Maintenant que nous sommes à l'aise pour créer, modifier et supprimer nos propres variables d'environnement, discutons de quelques variables cruciales que nous devrions connaître lors de l'énumération de l'environnement d'un hôte. N'oubliez pas que toutes les informations trouvées ici nous sont fournies en texte clair en raison de la nature des variables d'environnement. Pour un attaquant, cela peut fournir une mine d'informations sur le système actuel et le compte utilisateur qui y accède.

|Nom de la variable|Description|
|---|---|
|`%PATH%`|Spécifie un ensemble de répertoires (emplacements) où se trouvent les programmes exécutables.|
|`%OS%`|Le système d'exploitation actuel sur le poste de travail de l'utilisateur.|
|`%SYSTEMROOT%`|Se développe en `C:\Windows`. Une variable système en lecture seule contenant le dossier système de Windows. Tout ce que Windows considère comme important pour ses fonctionnalités de base s'y trouve, y compris des données importantes, des binaires système de base et des fichiers de configuration.|
|`%LOGONSERVER%`|Nous fournit le serveur de connexion de l'utilisateur actuellement actif, suivi du nom d'hôte de la machine. Nous pouvons utiliser cette information pour savoir si une machine est jointe à un domaine ou à un groupe de travail.|
|`%USERPROFILE%`|Nous fournit l'emplacement du répertoire personnel de l'utilisateur actuellement actif. Se développe en `C:\Users\{username}`.|
|`%ProgramFiles%`|Équivalent de `C:\Program Files`. C'est l'emplacement où tous les programmes sont installés sur un système `x64`.|
|`%ProgramFiles(x86)%`|Équivalent de `C:\Program Files (x86)`. C'est l'emplacement où sont installés tous les programmes 32 bits s'exécutant sous `WOW64`. Notez que cette variable n'est accessible que sur un hôte 64 bits. Elle peut être utilisée pour indiquer avec quel type d'hôte nous interagissons (architecture `x86` vs `x64`).|

Ce qui est présenté ici n'est qu'une infime partie des informations que nous pouvons obtenir en énumérant les variables d'environnement d'un système. Cependant, celles mentionnées ci-dessus apparaîtront souvent lors d'une énumération au cours d'une mission. Pour une liste complète, vous pouvez consulter le [lien](https://ss64.com/nt/syntax-variables.html) suivant. En utilisant ces informations comme guide, nous pouvons commencer à recueillir toutes les informations requises à partir de ces variables pour nous aider à connaître notre hôte et son environnement cible sur le bout des doigts.

---

## Pour la suite

À la fin de cette section, vous devriez avoir une bonne compréhension de ce que sont les variables d'environnement et de la manière de les gérer sur un système. Les variables d'environnement font partie des fonctionnalités de base du système d'exploitation Windows et sont considérées comme très utiles tant pour les attaquants que pour les défenseurs. Toute modification pouvant affecter les variables à l'échelle du système doit être effectuée avec une extrême prudence. Si vous estimez qu'il est nécessaire pour vos scripts ou outils, créez une nouvelle variable avant de modifier une variable déjà présente sur le système. Maintenant que ces informations sont claires, passons à l'utilisation de la ligne de commande pour travailler avec les services sur notre hôte.

Lab de fin 

![[Pasted image 20260831022208.png]]

rep : global 
