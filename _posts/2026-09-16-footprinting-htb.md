# Méthodologie d'énumération

---

Les processus complexes doivent reposer sur une méthodologie standardisée qui nous aide à garder le cap et à ne rien omettre par erreur. Compte tenu de la diversité des cas que les systèmes cibles peuvent nous présenter, il est presque impossible de prédire comment notre approche devrait être conçue. Par conséquent, la plupart des testeurs d'intrusion (penetration testers) suivent leurs habitudes et les étapes avec lesquelles ils se sentent le plus à l'aise et familiers. Cependant, il ne s'agit pas d'une méthodologie standardisée, mais plutôt d'une approche basée sur l'expérience.

Nous savons que les tests d'intrusion, et donc l'énumération, sont un processus dynamique. Par conséquent, nous avons développé une méthodologie d'énumération statique pour les tests d'intrusion externes et internes qui inclut une dynamique libre et permet un large éventail de modifications et d'adaptations à l'environnement donné. Cette méthodologie est imbriquée en 6 couches et représente, métaphoriquement parlant, des frontières que nous essayons de franchir avec le processus d'énumération. L'ensemble du processus d'énumération est divisé en trois niveaux différents :

|`Infrastructure-based enumeration`|`Host-based enumeration`|`OS-based enumeration`|
|---|---|---|

![Organigramme illustrant les processus d'énumération : basés sur le SE, sur l'hôte et sur l'infrastructure. Il inclut la configuration du SE, les privilèges, les processus, les services accessibles, la passerelle et la présence sur Internet, avec des sous-catégories détaillées comme le type de SE, la configuration réseau, les utilisateurs, les tâches, le type de service, les pare-feu et les domaines.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/112/enum-method33.png)

Note : Les composants de chaque couche présentés ici représentent les catégories principales et non une liste exhaustive de tous les composants à rechercher. De plus, il convient de mentionner ici que la première et la deuxième couche (Présence sur Internet, Passerelle) ne s'appliquent pas tout à fait à l'intranet, comme une infrastructure Active Directory. Les couches pour l'infrastructure interne seront abordées dans d'autres modules.

Considérez ces lignes comme une sorte d'obstacle, un mur par exemple. Ce que nous faisons ici, c'est regarder autour de nous pour trouver où se trouve l'entrée, ou la brèche par laquelle nous pouvons passer, ou que nous pouvons escalader pour nous rapprocher de notre objectif. Théoriquement, il est aussi possible de traverser le mur la tête la première, mais il arrive très souvent que l'endroit où nous avons ouvert une brèche avec force, beaucoup d'efforts et de temps ne nous apporte pas grand-chose, car il n'y a pas d'entrée à ce point du mur pour passer au mur suivant.

Ces couches sont conçues comme suit :

|**Couche**|**Description**|**Catégories d'informations**|
|---|---|---|
|`1. Internet Presence`|Identification de la présence sur Internet et de l'infrastructure accessible de l'extérieur.|Domaines, Sous-domaines, vHosts, ASN, Blocs réseau, Adresses IP, Instances Cloud, Mesures de sécurité|
|`2. Gateway`|Identifier les mesures de sécurité possibles pour protéger l'infrastructure externe et interne de l'entreprise.|Pare-feu, DMZ, IPS/IDS, EDR, Proxys, NAC, Segmentation du réseau, VPN, Cloudflare|
|`3. Accessible Services`|Identifier les interfaces et les services accessibles qui sont hébergés en externe ou en interne.|Type de service, Fonctionnalité, Configuration, Port, Version, Interface|
|`4. Processes`|Identifier les processus internes, les sources et les destinations associés aux services.|PID, Données traitées, Tâches, Source, Destination|
|`5. Privileges`|Identification des permissions internes et des privilèges pour les services accessibles.|Groupes, Utilisateurs, Permissions, Restrictions, Environnement|
|`6. OS Setup`|Identification des composants internes et de la configuration des systèmes.|Type de SE, Niveau de correctif, Configuration réseau, Environnement du SE, Fichiers de configuration, fichiers privés sensibles|

Note importante : L'aspect humain et les informations qui peuvent être obtenues auprès des employés en utilisant l'OSINT ont été retirés de la couche « Présence sur Internet » par souci de simplicité.

Nous pouvons enfin imaginer l'ensemble du test d'intrusion sous la forme d'un labyrinthe où nous devons identifier les brèches et trouver le chemin pour pénétrer à l'intérieur aussi rapidement et efficacement que possible. Ce type de labyrinthe peut ressembler à ceci :

![Cercles concentriques codés par couleur avec des lignes de connexion et des carrés, étiquetés 'Point de départ', représentant un organigramme ou un diagramme de processus.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/112/pentest-labyrinth.png)

Les carrés représentent les brèches/vulnérabilités.

Comme nous l'avons probablement déjà remarqué, nous pouvons voir que nous rencontrerons une brèche et très probablement plusieurs. Le fait intéressant et très courant est que toutes les brèches que nous trouvons ne peuvent pas nous mener à l'intérieur. Tous les tests d'intrusion sont limités dans le temps, mais nous devons toujours garder à l'esprit la conviction qu'il y a presque toujours un moyen d'entrer. Même après un test d'intrusion de quatre semaines, nous ne pouvons pas affirmer à 100 % qu'il n'y a plus de vulnérabilités. Quelqu'un qui a étudié l'entreprise pendant des mois et l'a analysée aura très probablement une bien meilleure compréhension des applications et de la structure que celle que nous avons pu acquérir pendant les quelques semaines que nous avons passées sur l'évaluation. Un excellent exemple récent est la [cyberattaque contre SolarWinds](https://www.rpc.senate.gov/policy-papers/the-solarwinds-cyberattack), qui s'est produite il n'y a pas si longtemps. C'est une autre excellente raison d'avoir une méthodologie qui doit exclure de tels cas.

Supposons que l'on nous ait demandé de réaliser un test d'intrusion externe en « boîte noire » (black box). Une fois que tous les points nécessaires du contrat ont été entièrement remplis, notre test d'intrusion commencera à l'heure spécifiée.

---

## Couche n°1 : Présence sur Internet

La première couche que nous devons franchir est la couche « Présence sur Internet », où nous nous concentrons sur la recherche des cibles que nous pouvons investiguer. Si le périmètre (scope) du contrat nous autorise à rechercher des hôtes supplémentaires, cette couche est encore plus critique que pour des cibles fixes uniquement. Dans cette couche, nous utilisons différentes techniques pour trouver des domaines, des sous-domaines, des blocs réseau (netblocks), et de nombreux autres composants et informations qui présentent la présence de l'entreprise et de son infrastructure sur Internet.

`L'objectif de cette couche est d'identifier tous les systèmes et interfaces cibles possibles qui peuvent être testés.`

---

## Couche n°2 : Passerelle

Ici, nous essayons de comprendre l'interface de la cible accessible, comment elle est protégée et où elle se trouve dans le réseau. En raison de la diversité, des différentes fonctionnalités et de certaines procédures particulières, nous aborderons cette couche plus en détail dans d'autres modules.

`L'objectif est de comprendre à quoi nous avons affaire et à quoi nous devons faire attention.`

---

## Couche n°3 : Services accessibles

Dans le cas des services accessibles, nous examinons chaque destination pour tous les services qu'elle propose. Chacun de ces services a un but spécifique qui a été installé pour une raison particulière par l'administrateur. Chaque service a certaines fonctions, qui conduisent donc également à des résultats spécifiques. Pour travailler efficacement avec eux, nous devons savoir comment ils fonctionnent. Sinon, nous devons apprendre à les comprendre.

`Cette couche vise à comprendre la raison et la fonctionnalité du système cible et à acquérir les connaissances nécessaires pour communiquer avec lui et l'exploiter efficacement à nos fins.`

C'est la partie de l'énumération que nous traiterons principalement dans ce module.

---

## Couche n°4 : Processus

Chaque fois qu'une commande ou une fonction est exécutée, des données sont traitées, qu'elles soient saisies par l'utilisateur ou générées par le système. Cela démarre un processus qui doit effectuer des tâches spécifiques, et de telles tâches ont au moins une source et une cible.

`L'objectif ici est de comprendre ces facteurs et d'identifier les dépendances entre eux.`

---

## Couche n°5 : Privilèges

Chaque service s'exécute via un utilisateur spécifique dans un groupe particulier avec des permissions et des privilèges définis par l'administrateur ou le système. Ces privilèges nous fournissent souvent des fonctions que les administrateurs négligent. Cela se produit souvent dans les infrastructures Active Directory et dans de nombreux autres environnements d'administration et serveurs spécifiques où les utilisateurs sont responsables de plusieurs domaines d'administration.

`Il est crucial de les identifier et de comprendre ce qui est possible et ce qui ne l'est pas avec ces privilèges.`

---

## Couche n°6 : Configuration du SE

Ici, nous collectons des informations sur le système d'exploitation réel et sa configuration en utilisant un accès interne. Cela nous donne un bon aperçu de la sécurité interne des systèmes et reflète les compétences et les capacités des équipes administratives de l'entreprise.

`L'objectif ici est de voir comment les administrateurs gèrent les systèmes et quelles informations internes sensibles nous pouvons en tirer.`

---

## La méthodologie d'énumération en pratique

Une méthodologie résume toutes les procédures systématiques permettant d'obtenir des connaissances dans les limites d'un objectif donné. Il est important de noter qu'une méthodologie n'est pas un guide étape par étape mais, comme l'implique la définition, un résumé de procédures systématiques. Dans notre cas, la méthodologie d'énumération est l'approche systématique pour explorer une cible donnée.

La manière dont les composants individuels sont identifiés et les informations obtenues dans cette méthodologie est un aspect dynamique et évolutif qui change constamment et peut donc différer. Un excellent exemple est l'utilisation d'outils de collecte d'informations à partir de serveurs web. Il existe d'innombrables outils différents pour cela, et chacun d'entre eux a un objectif spécifique et fournit donc des résultats individuels qui diffèrent des autres applications. L'objectif, cependant, est le même. Ainsi, la collection d'outils et de commandes ne fait pas partie de la méthodologie réelle, mais plutôt d'un aide-mémoire auquel nous pouvons nous référer en utilisant les commandes et les outils listés dans des cas donnés.