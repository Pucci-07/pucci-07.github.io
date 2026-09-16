[[HTB ACADEMY]]
# Introduction

---

L'interpréteur de commandes intégré CMD.exe et PowerShell sont deux implémentations incluses dans tous les hôtes Windows. Ces outils fournissent un accès direct au système d'exploitation, automatisent les tâches de routine et offrent à l'utilisateur un contrôle granulaire de chaque aspect de l'ordinateur et des applications installées. Ce module nous apportera les connaissances, les compétences et les capacités pour administrer efficacement les hôtes Windows via la ligne de commande.

Du point de vue du test d'intrusion (penetration testing), nous apprendrons à utiliser les outils et commandes Windows intégrés ainsi que les scripts et applications tiers pour nous aider dans la reconnaissance, l'exploitation et l'exfiltration de données au sein d'un environnement Windows, à mesure que nous progresserons vers des modules plus avancés de HTB Academy.

---

## Invite de commandes vs. PowerShell

Il existe quelques différences clés entre l'Invite de commandes Windows et PowerShell, que nous verrons tout au long de ce module. Une différence clé est que vous pouvez exécuter des commandes de l'Invite de commandes depuis une console PowerShell, mais pour exécuter des commandes PowerShell depuis une Invite de commandes, vous devez préfixer la commande avec `powershell` (par exemple, `powershell get-alias`). Le tableau suivant présente quelques autres différences clés.

|PowerShell|Invite de commandes|
|---|---|
|Lancé en 2006|Lancé en 1981|
|Peut exécuter à la fois des commandes batch et des cmdlets PowerShell|Ne peut exécuter que des commandes batch|
|Prend en charge l'utilisation d'alias de commandes|Ne prend pas en charge les alias de commandes|
|La sortie des cmdlets peut être transmise à d'autres cmdlets|La sortie des commandes ne peut pas être transmise à d'autres commandes|
|Toute sortie est sous forme d'objet|La sortie des commandes est du texte|
|Capable d'exécuter une séquence de cmdlets dans un script|Une commande doit se terminer avant que la suivante puisse s'exécuter|
|Possède un Environnement de script intégré (ISE)|Ne possède pas d'ISE|
|Peut accéder aux bibliothèques de programmation car il est basé sur le .NET framework|Ne peut pas accéder à ces bibliothèques|
|Peut être exécuté sur des systèmes Linux|Ne peut être exécuté que sur des systèmes Windows|

Comme nous pouvons le voir, l'Invite de commandes est une manière beaucoup plus statique d'interagir avec le système d'exploitation, tandis que PowerShell est un langage de script puissant qui peut être utilisé pour une grande variété de tâches et pour créer des scripts simples ou très complexes.

---

## Scénario

Nous utiliserons un scénario tout au long de ce module pour nous aider à rester dans le périmètre des sujets abordés et pour donner un aperçu de la manière dont ces outils et commandes peuvent nous aider dans notre mission.

Considérez le scénario suivant :

Nous sommes un administrateur système cherchant à élargir nos horizons et à faire nos premiers pas dans le pentesting. Avant de contacter notre manager et le Responsable de l'équipe Red Team interne pour envisager un apprentissage, nous devons d'abord nous entraîner et acquérir une compréhension fondamentale des principales interfaces de ligne de commande de Windows : `PowerShell` et `Command Prompt`. Bientôt, ils n'auront d'autre choix que de nous accepter en tant que `Command Line Ninja` certifié et de nous accorder une place à la table.

---

## Instructions de connexion

Pour ce module, vous aurez accès à plusieurs hôtes Windows à partir desquels vous pourrez effectuer toutes les actions nécessaires pour compléter les exercices du laboratoire. Comme nous travaillons dans un module purement basé sur le CLI, ce défi utilisera uniquement `SSH` pour se connecter aux cibles.

Pour vous connecter aux hôtes cibles en tant qu'utilisateur via SSH, utilisez le format suivant :

        shellsession
`ssh htb-student@<IP-Address>` 

Une fois connecté, il vous sera demandé d'accepter le certificat de l'hôte et de fournir le mot de passe de l'utilisateur pour vous connecter complètement. Une fois authentifié, vous êtes libre de vous lancer.