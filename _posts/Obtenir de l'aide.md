[[Command Prompt Basics]]

Dans la section précédente, nous avons découvert les concepts généraux de l'Invite de commandes et comment y accéder. Cette section développera la précédente en présentant la fonctionnalité `help` de l'Invite de commandes, un exemple de sortie, ainsi que des ressources et concepts supplémentaires.

L'Invite de commandes dispose d'une fonction `help` intégrée qui peut nous fournir des informations détaillées sur les commandes disponibles sur notre système et sur la manière d'utiliser ces fonctions. Dans cette section, nous allons aborder plus en détail les points suivants :

- Comment utiliser la fonctionnalité d'aide dans l'Invite de commandes ?
- Pourquoi l'utilisation de la fonctionnalité d'aide est-elle essentielle ?
- Où pouvons-nous trouver des ressources externes supplémentaires pour obtenir de l'aide ?
- Comment utiliser des astuces et conseils supplémentaires dans l'Invite de commandes ?

---

## Comment obtenir de l'aide

Lorsque l'on regarde pour la première fois l'interface de l'Invite de commandes, il peut être intimidant de fixer une invite vide. Quelques questions initiales peuvent surgir, telles que :

- À quelles commandes ai-je accès ?
- Comment utiliser ces commandes ?

Commençons par répondre à la première question. Lors de l'utilisation de l'Invite de commandes, trouver de l'aide est aussi simple que de taper `help`. Sans aucun paramètre supplémentaire, cette commande fournit une liste des commandes intégrées et des informations de base sur l'utilisation de chaque commande affichée. Jetons-y un œil ci-dessous.

#### Utilisation par défaut de Help

        cmd
`C:\htb> help  Pour plus d'informations sur une commande spécifique, tapez HELP nom-de-commande ASSOC          Affiche ou modifie les associations d'extensions de fichiers. ATTRIB         Affiche ou modifie les attributs d'un fichier. BREAK          Active ou désactive le contrôle étendu de CTRL+C. BCDEDIT        Définit les propriétés dans la base de données de démarrage pour contrôler le chargement du démarrage. CACLS          Affiche ou modifie les listes de contrôle d'accès (ACL) des fichiers. CALL           Appelle un programme de commandes (batch) à partir d'un autre. CD             Affiche le nom du répertoire actif ou le modifie. CHCP           Affiche ou définit le numéro de la page de codes active. CHDIR          Affiche le nom du répertoire actif ou le modifie. CHKDSK         Vérifie un disque et affiche un rapport d'état.  <snip>`

À partir de cette sortie, nous pouvons voir qu'elle affiche une liste de commandes système (`intégrées`) et fournit une description de base de leur fonctionnalité. C'est important car nous pouvons rapidement et efficacement parcourir la liste des fonctions intégrées fournies par l'invite de commandes pour trouver celle qui correspond à nos besoins. À partir de là, nous pouvons passer à la deuxième question sur la manière d'utiliser ces commandes. Pour afficher des informations détaillées sur une commande particulière, nous pouvons saisir ce qui suit : `help <nom de la commande>`.

#### Aide sur les commandes

        cmd
`C:\htb> help time  Affiche ou définit l'heure système.  TIME [/T | time]  Tapez TIME sans paramètres pour afficher l'heure actuelle et une invite pour en entrer une nouvelle. Appuyez sur ENTRÉE pour conserver la même heure.  Si les extensions de commandes sont activées, la commande TIME prend en charge le commutateur /T qui indique à la commande de simplement afficher l'heure actuelle, sans demander une nouvelle heure.`

Comme nous pouvons le voir dans la sortie ci-dessus, lorsque nous avons saisi la commande `help time`, elle a affiché les détails de l'aide pour time. Cela fonctionnera pour n'importe quelle commande système intégrée, mais pas pour toutes les commandes accessibles sur le système. Certaines commandes n'ont pas de page d'aide associée. Cependant, elles vous redirigeront vers l'exécution de la commande appropriée pour récupérer les informations souhaitées. Par exemple, l'exécution de `help ipconfig` nous donnera la sortie suivante.

#### Sortie détaillée

        cmd
`C:\htb> help ipconfig  Cette commande n'est pas prise en charge par l'utilitaire d'aide. Essayez "ipconfig /?".`

Dans l'exemple précédent, la fonction d'aide nous a fait savoir qu'elle ne pouvait pas fournir plus d'informations car l'utilitaire d'aide ne la prend pas directement en charge. Cependant, l'utilisation de la commande suggérée `ipconfig /?` nous fournira les informations dont nous avons besoin pour utiliser la commande correctement. Sachez que plusieurs commandes utilisent le modificateur `/?` de manière interchangeable avec help.

---

## Pourquoi avons-nous besoin de l'utilitaire d'aide ?

Dans la dernière section, nous avons discuté des aspects fondamentaux de l'utilisation de la fonctionnalité d'aide depuis l'Invite de commandes et de l'interprétation de certaines de ses sorties. Bien que la compréhension des détails techniques sur la manière d'utiliser la fonction `help` soit importante, un autre concept fondamental ici est le suivant :

`Pourquoi l'utilitaire d'aide existe-t-il, et à quoi sert-il aujourd'hui alors que l'accès à Internet est si répandu ?`

Cette question est complexe, alors commençons à la décomposer morceau par morceau. Pour mieux répondre à cette question et fournir une explication plus approfondie, commençons par travailler sur le scénario suivant :

**Exemple :** Imaginez que vous êtes chargé d'assister à une mission interne sur site pour votre entreprise `GreenHorn`. Vous êtes immédiatement placé dans une session d'Invite de commandes sur une machine du réseau interne et avez pour mission d'énumérer le système. Conformément aux règles d'engagement, vous avez été dépouillé de tous les appareils que vous aviez sur vous et on vous a dit que le pare-feu (firewall) bloque tout le trafic réseau sortant. Vous commencez votre énumération sur le système mais avez besoin d'aide pour vous souvenir de la syntaxe d'une commande spécifique que vous avez en tête. Vous réalisez que vous ne pouvez accéder à Internet par aucun moyen. `Où pouvez-vous la trouver ?`

Bien que ce scénario puisse sembler légèrement exagéré, il y aura des scénarios similaires à celui-ci en tant qu'`attaquant` où notre accès au réseau sera fortement limité, surveillé ou strictement indisponible. Parfois, nous n'avons pas toutes les commandes, tous les paramètres et toute la syntaxe mémorisés ; cependant, on s'attendra toujours à ce que nous soyons performants même avec ces limitations. Dans les cas où l'on attend de nous que nous soyons performants, nous aurons besoin de moyens alternatifs pour recueillir les informations dont nous avons besoin au lieu de compter sur Internet comme solution rapide à nos problèmes. Maintenant que nous avons notre scénario, revenons en arrière et décomposons notre question originale :

`Pourquoi l'utilitaire d'aide existe-t-il ?`

L'utilitaire `help` sert de manuel `hors ligne` (offline) pour les commandes des systèmes d'exploitation Windows compatibles `CMD` et `DOS`. `Hors ligne` fait référence au fait que cet utilitaire peut être utilisé sur un système sans accès au réseau. Pour ceux qui sont familiers avec le module [Linux Fundamentals](https://academy.hackthebox.com/module/18/section/67), cet utilitaire est très similaire aux pages `man` sur les systèmes basés sur `Linux`. Maintenant que nous comprenons pourquoi l'utilitaire d'aide existe, nous pouvons aborder la deuxième partie de la question originale :

`À quoi sert-il aujourd'hui alors que l'accès à Internet est si répandu ?`

Comme le montre notre scénario, il y aura des moments où nous n'aurons peut-être pas d'accès direct à Internet. L'utilitaire `help` est destiné à combler cette lacune lorsque nous avons besoin d'aide avec des commandes ou une syntaxe spécifique pour lesdites commandes sur notre système et que nous n'avons peut-être pas les ressources externes disponibles pour demander de l'aide. Cela n'implique pas qu'`Internet` n'est pas un outil précieux à utiliser lors des missions. Cependant, si nous n'avons pas le luxe de chercher des réponses à nos questions, nous avons besoin d'un moyen de récupérer lesdites informations.

---

## Où trouver de l'aide supplémentaire ?

Dans la section précédente, nous avons discuté de l'importance d'utiliser le système d'aide intégré à l'Invite de commandes, en particulier dans un environnement où le trafic réseau externe est inexistant ou limité. Cependant, en supposant que nous ayons accès à Internet, il existe des dizaines de `ressources en ligne` à notre disposition pour obtenir de l'aide supplémentaire concernant l'Invite de commandes. Comme indiqué précédemment, Internet est un outil extrêmement précieux et doit être utilisé au maximum de ses capacités, surtout si l'accès est illimité. Pour nous aider à améliorer notre compréhension de CMD et à réduire une partie du temps perdu à chercher de la documentation, voici quelques références de commandes `CMD.exe` où nous pouvons en apprendre davantage sur ce qui peut être fait avec notre shell de commande.

La [documentation Microsoft](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands) propose une liste complète des commandes pouvant être exécutées dans l'interpréteur de ligne de commande ainsi que des descriptions détaillées sur la manière de les utiliser. Considérez-la comme une version en ligne des pages man.

[ss64](https://ss64.com/nt/) est une référence rapide pratique pour tout ce qui concerne la ligne de commande, y compris cmd, PowerShell, Bash, et plus encore.

Il s'agit d'une liste partielle de ressources ; cependant, celles-ci devraient fournir une bonne base pour travailler avec l'Invite de commandes.

---

## Astuces et conseils de base

Maintenant que nous avons une compréhension générale de la manière dont nous pouvons obtenir de l'aide à partir de ressources externes, terminons en beauté en présentant quelques astuces et conseils essentiels pour interagir avec l'Invite de commandes.

#### Effacer votre écran

Il y a des moments lors de notre interaction avec l'`invite de commandes` où la quantité de `sortie` qui nous est fournie par de multiples commandes surcharge l'écran et devient un fouillis d'informations inutilisable. Dans ce cas, nous avons besoin d'un moyen d'`effacer` l'écran et de nous fournir une invite vide. Nous pouvons utiliser la commande `cls` pour effacer la fenêtre de notre terminal de nos résultats précédents. C'est pratique lorsque nous devons rafraîchir notre écran et voulons éviter de nous battre pour lire le terminal et de déterminer où commence notre sortie actuelle et où se termine l'ancienne entrée.

![GIF montrant l'utilisation de la commande 'cls' dans un terminal d'invite de commandes.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/clear_screen.gif)

Nous pouvons voir dans le GIF ci-dessus que notre terminal était plein, et nous avons exécuté la commande `cls`, nous offrant une `ardoise vierge`.

#### Historique

Précédemment, nous avons développé la manière d'effacer la sortie de la session de l'Invite de commandes en utilisant `cls`. Bien que ces informations aient été effacées de la sortie de l'écran, nous pouvons toujours récupérer les commandes qui ont été exécutées jusqu'à ce point. Cela est dû à une fonctionnalité astucieuse intégrée à l'Invite de commandes connue sous le nom d'`Historique des commandes`.

L'historique des commandes est une chose dynamique. Il nous permet de `visualiser les commandes précédemment exécutées` dans la `session active actuelle` de notre Invite de commandes. Pour ce faire, CMD nous fournit plusieurs méthodes différentes pour interagir avec notre historique de commandes. Par exemple, nous pouvons utiliser les touches fléchées pour monter et descendre dans notre historique, les touches `page up` et `page down`, et si vous travaillez sur un hôte Windows physique, vous pouvez utiliser les touches de `fonction` pour interagir avec l'historique de votre session. La dernière façon de visualiser notre historique est d'utiliser la commande `doskey /history`. [Doskey](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/doskey) est un utilitaire MS-DOS qui conserve un historique des commandes exécutées et permet de les référencer à nouveau.

#### doskey /history

        cmd
`C:\htb> doskey /history  systeminfo ipconfig /all cls ipconfig /all systeminfo cls history help doskey /history ping 8.8.8.8 doskey /history`

À partir de la sortie fournie ci-dessus, nous pouvons voir une liste de `commandes` qui ont été exécutées avant notre commande originale. C'est important et incroyablement utile, surtout si vous effacez constamment votre écran et avez besoin de réexécuter une commande précédente pour collecter sa `sortie`. Interagir avec et visualiser toutes les commandes précédemment exécutées vous fera économiser du temps, de l'énergie et des maux de tête.

#### Touches et commandes utiles pour l'historique du terminal

Il serait utile d'avoir un moyen de se souvenir de certaines des fonctionnalités clés fournies par l'historique de notre terminal. Dans cette optique, le tableau ci-dessous présente une liste de certaines des fonctions et commandes les plus utiles qui peuvent être exécutées pour interagir avec l'historique de notre session. Cette liste n'est pas exhaustive. Par exemple, les touches de fonction F1 à F9 ont toutes un but lorsque l'on travaille avec l'historique.

|**Touche/Commande**|**Description**|
|:-:|---|
|doskey /history|doskey /history affichera l'historique des commandes de la session dans le terminal ou le sortira dans un fichier si spécifié.|
|page up|Place la première commande de l'historique de notre session dans l'invite.|
|page down|Place la dernière commande de l'historique dans l'invite.|
|⇧|Nous permet de faire défiler vers le haut notre historique de commandes pour voir les commandes précédemment exécutées.|
|⇩|Nous permet de faire défiler vers le bas jusqu'à nos commandes les plus récentes.|
|⇨|Tape la commande précédente dans l'invite, un caractère à la fois.|
|⇦|S/O|
|F3|Retape l'entrée précédente complète dans notre invite.|
|F5|Appuyer plusieurs fois sur F5 vous permettra de parcourir les commandes précédentes.|
|F7|Ouvre une liste interactive des commandes précédentes.|
|F9|Saisit une commande dans notre invite en fonction du numéro spécifié. Le numéro correspond à la place de la commande dans notre historique.|

Une chose à retenir est que, contrairement à Bash ou à d'autres shells, CMD ne conserve pas un enregistrement persistant des commandes que vous exécutez entre les sessions. Donc, une fois que vous fermez cette instance, cet historique est perdu. Pour sauvegarder une copie de nos commandes exécutées, nous pouvons utiliser `doskey` à nouveau pour sortir l'historique dans un fichier, l'afficher à l'écran, puis le copier.

#### Quitter un processus en cours d'exécution

À un moment donné de notre parcours avec l'`Invite de commandes`, il y aura des moments où nous devrons être capables d'`interrompre` un processus en cours d'exécution, le tuant efficacement. Cela peut être dû à de nombreux facteurs différents. Cependant, la plupart du temps, nous pourrions avoir les informations dont nous avons besoin d'une commande en cours d'exécution ou nous trouver face à une application qui se bloque de manière inattendue. Ainsi, nous avons besoin d'un moyen d'interrompre notre session actuelle et tout processus qui s'y exécute. Prenez l'exemple suivant :

        cmd
`C:\htb> ping 8.8.8.8  Envoi d’une requête 'Ping' sur 8.8.8.8 avec 32 octets de données : Réponse de 8.8.8.8 : octets=32 temps=22 ms TTL=114 Réponse de 8.8.8.8 : octets=32 temps=25 ms TTL=114  Statistiques Ping pour 8.8.8.8:     Paquets : envoyés = 2, reçus = 2, perdus = 0 (perte 0%), Durée approximative des boucles en millisecondes :     Minimum = 22ms, Maximum = 25ms, Moyenne = 23ms Control-C ^C`

Lorsque nous exécutons une commande ou un processus que nous voulons interrompre, nous pouvons le faire en appuyant sur la combinaison de touches `ctrl+c`. Comme indiqué précédemment, c'est utile pour arrêter un processus en cours d'exécution qui peut ne pas répondre ou simplement quelque chose que nous voulons terminer immédiatement. N'oubliez pas que tout ce qui était en cours d'exécution sera incomplet et pourrait nécessiter plus de temps pour se fermer correctement, alors soyez toujours prudent avec ce que vous interrompez.

Maintenant que nous comprenons comment utiliser l'invite de commandes et sa fonctionnalité d'aide de base, continuons d'avancer et voyons comment nous pouvons commencer à naviguer dans notre système via l'Invite de commandes.