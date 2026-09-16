[[Command Prompt Basics]]

Du point de vue d'un Analyste SOC ou d'un Administrateur IT, la surveillance, la collecte et la catégorisation des événements se produisant sur toutes les machines du réseau constituent une source d'information inestimable pour les défenseurs qui analysent et protègent de manière proactive leur réseau contre les activités suspectes. D'un autre côté, les attaquants peuvent y voir une opportunité d'obtenir des informations sur l'environnement cible, de perturber le flux d'informations et un moyen de dissimuler leurs traces. Comme nous le verrons dans les modules ultérieurs, nous pouvons parfois trouver des informations juteuses telles que des identifiants cachés dans les journaux d'événements d'un système cible que nous compromettons lors d'un test d'intrusion (penetration test). D'autres fois, l'énumération des journaux d'événements peut nous aider à comprendre le niveau de journalisation dans l'environnement (les paramètres par défaut sont-ils simplement en place, ou l'organisation cible a-t-elle configuré une journalisation plus granulaire ?). Dans cette section, nous aborderons les points suivants :

- Qu'est-ce que le journal d'événements Windows ?
- Quelles informations enregistre-t-il, et où les stocke-t-il ?
- Interagir avec le journal d'événements via l'utilitaire de ligne de commande `wevtutil`
- Interagir avec le journal d'événements à l'aide des cmdlets PowerShell

---

## Qu'est-ce que le journal d'événements Windows ?

Une compréhension claire de la journalisation des événements est cruciale pour réussir en sécurité de l'information. Pour entamer notre parcours vers une compréhension approfondie du journal d'événements Windows, il y a quelques concepts clés que nous devons définir avant de nous lancer. Ces concepts deviendront la base sur laquelle tout le reste sera construit. Le premier qui doit être expliqué est la définition d'un `événement`. En termes simples, un `événement` est toute action ou occurrence qui peut être identifiée et classifiée par le matériel ou le logiciel d'un système. Les `événements` peuvent être générés ou déclenchés de diverses manières, y compris certaines des suivantes :

- Événements générés par l'utilisateur
    - Mouvement d'une souris, frappe au clavier, autres périphériques contrôlés par l'utilisateur, etc.
- Événements générés par les applications
    - Mises à jour d'applications, plantages, utilisation/consommation de mémoire, etc.
- Événements générés par le système
    - Temps de fonctionnement du système, mises à jour du système, chargement/déchargement de pilotes, connexion de l'utilisateur, etc.

Avec autant d'événements se produisant à différents intervalles de temps et provenant de diverses sources, comment un système Windows fait-il pour les suivre et les catégoriser tous ? C'est là que notre deuxième concept clé, connu sous le nom de `journalisation des événements` entre en jeu.

La [journalisation des événements (Event Logging)](https://learn.microsoft.com/en-us/windows/win32/eventlog/event-logging) telle que définie par Microsoft :

«`...fournit un moyen standard et centralisé pour les applications (et le système d'exploitation) d'enregistrer les événements logiciels et matériels importants.`»

Cette définition résume assez bien la question. Cependant, essayons de la décomposer un peu. Comme nous l'avons vu précédemment, de nombreux événements sont déclenchés ou générés simultanément sur un système. Chaque événement aura sa propre source qui fournit les informations et les détails derrière l'événement dans son propre format. Alors, comment gère-t-il toutes ces informations ?

Windows tente de résoudre ce problème en fournissant une approche standardisée pour l'enregistrement, le stockage et la gestion des événements et des informations sur les événements via un service connu sous le nom de `Windows Event Log` (Journal d'événements Windows). Comme son nom l'indique, l'`Event Log` gère les événements et les journaux d'événements, mais en plus de cette fonctionnalité, il ouvre également une API spéciale qui permet aux applications de maintenir et de gérer leurs propres journaux séparés. Dans le module [Fondamentaux de Windows](https://academy.hackthebox.com/app/module/49), nous avons discuté des `services` dans les journaux plus en détail dans la section [Services et processus Windows](https://academy.hackthebox.com/app/module/49/section/457), cependant, il est essentiel de comprendre que l'`Event Log` est un service Windows requis qui démarre lors de l'initialisation du système et qui s'exécute dans le contexte d'un autre exécutable et non du sien.

Avant de nous plonger dans l'interrogation du journal d'événements depuis cmd.exe et PowerShell, nous devons comprendre les types d'événements possibles qui s'offrent à nous, les éléments d'un journal et divers autres éléments.

---

## Catégories et types de journaux d'événements

Les quatre principales catégories de journaux sont application, sécurité, installation et système. Un autre type de catégorie existe également, appelé `événements transférés`.

|Catégorie de journal|Description du journal|
|---|---|
|Journal Système|Le journal système contient des événements liés au système Windows et à ses composants. Un événement au niveau du système pourrait être un service qui ne démarre pas.|
|Journal de Sécurité|Explicite ; ceux-ci incluent les événements liés à la sécurité tels que les connexions échouées et réussies, et la création/suppression de fichiers. Ils peuvent être utilisés pour détecter divers types d'attaques que nous aborderons dans les modules ultérieurs.|
|Journal des Applications|Celui-ci stocke les événements liés à tout logiciel/application installé sur le système. Par exemple, si Slack a des difficultés à démarrer, cela sera enregistré dans ce journal.|
|Journal d'Installation|Ce journal contient tous les événements générés lors de l'installation du système d'exploitation Windows. Dans un environnement de domaine, les événements liés à Active Directory seront enregistrés dans ce journal sur les hôtes contrôleurs de domaine.|
|Événements transférés|Journaux qui sont transférés depuis d'autres hôtes au sein du même réseau.|

---

## Types d'événements

Il existe cinq types d'événements qui peuvent être enregistrés sur les systèmes Windows :

|Type d'événement|Description de l'événement|
|---|---|
|Erreur|Indique qu'un problème majeur s'est produit, comme un service qui ne se charge pas au démarrage.|
|Avertissement|Un journal moins significatif mais qui peut indiquer un problème possible à l'avenir. Un exemple est un espace disque faible. Un événement d'avertissement sera enregistré pour noter qu'un problème pourrait survenir plus tard. Un événement d'avertissement se produit généralement lorsqu'une application peut se remettre de l'événement sans perdre de fonctionnalité ou de données.|
|Information|Enregistré lors du fonctionnement réussi d'une application, d'un pilote ou d'un service, comme lorsqu'un pilote réseau se charge avec succès. En général, toutes les applications de bureau n'enregistrent pas un événement à chaque démarrage, car cela pourrait entraîner une quantité considérable de « bruit » supplémentaire dans les journaux.|
|Audit de succès|Enregistré lorsqu'une tentative d'accès de sécurité auditée réussit, comme lorsqu'un utilisateur se connecte à un système.|
|Audit d'échec|Enregistré lorsqu'une tentative d'accès de sécurité auditée échoue, comme lorsqu'un utilisateur tente de se connecter mais se trompe de mot de passe. De nombreux événements d'audit d'échec pourraient indiquer une attaque, telle que la pulvérisation de mots de passe (Password Spraying).|

---

## Niveaux de gravité des événements

Chaque journal peut avoir l'un des cinq niveaux de gravité qui lui sont associés, désignés par un numéro :

|Niveau de gravité|Numéro de niveau|Description|
|---|---|---|
|Détaillé|5|Messages de progression ou de succès.|
|Information|4|Un événement qui s'est produit sur le système mais n'a causé aucun problème.|
|Avertissement|3|Un problème potentiel qu'un administrateur système devrait examiner.|
|Erreur|2|Un problème lié au système ou à un service qui ne nécessite pas une attention immédiate.|
|Critique|1|Ceci indique un problème important lié à une application ou un système qui nécessite une attention urgente de la part d'un administrateur système et qui, s'il n'est pas traité, pourrait entraîner une instabilité du système ou de l'application.|

---

## Éléments d'un journal d'événements Windows

Le journal d'événements Windows fournit des informations sur les événements matériels et logiciels sur un système Windows. Tous les journaux d'événements sont stockés dans un format standard et incluent les éléments suivants :

- `Log name` (Nom du journal) : Comme discuté ci-dessus, le nom du journal d'événements où les événements seront écrits. Par défaut, les événements sont enregistrés pour `system`, `security` et `applications`.
- `Event date/time` (Date/heure de l'événement) : Date et heure auxquelles l'événement s'est produit
- `Task Category` (Catégorie de la tâche) : Le type de journal d'événements enregistré
- `Event ID` (ID d'événement) : Un identifiant unique pour que les administrateurs système puissent identifier un événement enregistré spécifique
- `Source` : D'où provient le journal, généralement le nom d'un programme ou d'une application logicielle
- `Level` (Niveau) : Niveau de gravité de l'événement. Cela peut être information, erreur, détaillé, avertissement, critique
- `User` (Utilisateur) : Nom d'utilisateur de la personne connectée à l'hôte lorsque l'événement s'est produit
- `Computer` (Ordinateur) : Nom de l'ordinateur où l'événement est enregistré

Il existe de nombreux ID d'événements qu'une organisation peut surveiller pour détecter divers problèmes. Dans un environnement Active Directory, [cette liste](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor) inclut les événements clés qu'il est recommandé de surveiller pour rechercher des signes de compromission. [Cette](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/) base de données consultable d'ID d'événements vaut la peine d'être parcourue pour comprendre la profondeur de la journalisation possible sur un système Windows.

---

## Détails techniques du journal d'événements Windows

Le journal d'événements Windows est géré par les services `EventLog`. Sur un système Windows, le nom d'affichage du service est `Windows Event Log` (Journal d'événements Windows), et il s'exécute à l'intérieur du processus hôte de service [svchost.exe](https://en.wikipedia.org/wiki/Svchost.exe). Il est configuré pour démarrer automatiquement au démarrage du système par défaut. Il est difficile d'arrêter le service EventLog car il a plusieurs services dépendants. S'il est arrêté, cela causera probablement une instabilité système significative. Par défaut, les journaux d'événements Windows sont stockés dans `C:\Windows\System32\winevt\logs` avec l'extension de fichier `.evtx`.

        powershell
`PS C:\htb> ls C:\Windows\System32\winevt\logs      Directory: C:\Windows\System32\winevt\logs   Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a----        11/16/2022   2:19 PM        7409664 Application.evtx -a----         6/14/2022   8:20 PM          69632 HardwareEvents.evtx -a----         6/14/2022   8:20 PM          69632 Internet Explorer.evtx -a----         6/14/2022   8:20 PM          69632 Key Management Service.evtx         -a----         8/23/2022   7:01 PM          69632 Microsoft-Client-License-Flexible-P                                                   latform%4Admin.evtx -a----        11/16/2022   2:19 PM        1052672 Microsoft-Client-Licensing-Platform                                                   %4Admin.evtx   <SNIP>`

Nous pouvons interagir avec le journal d'événements Windows à l'aide de l'application graphique [Windows Event Viewer](https://en.wikipedia.org/wiki/Event_Viewer) (Observateur d'événements), via l'utilitaire de ligne de commande [wevtutil](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wevtutil), ou en utilisant le cmdlet PowerShell [Get-WinEvent](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-7.3). `wevtutil` et `Get-WinEvent` peuvent tous deux être utilisés pour interroger les journaux d'événements sur des systèmes Windows locaux et distants via cmd.exe ou PowerShell.

---

## Interagir avec le journal d'événements Windows - wevtutil

L'utilitaire de ligne de commande [wevtutil](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wevtutil) peut être utilisé pour récupérer des informations sur les journaux d'événements. Il peut également être utilisé pour exporter, archiver et effacer des journaux, entre autres commandes.

#### Wevtutil sans paramètres

        cmd
`C:\htb> wevtutil /?  Windows Events Command Line Utility.  Enables you to retrieve information about event logs and publishers, install and uninstall event manifests, run queries, and export, archive, and clear logs.  Usage:  You can use either the short (for example, ep /uni) or long (for example, enum-publishers /unicode) version of the command and option names. Commands, options and option values are not case-sensitive.  Variables are noted in all upper-case.  wevtutil COMMAND [ARGUMENT [ARGUMENT] ...] [/OPTION:VALUE [/OPTION:VALUE] ...]  Commands:  el | enum-logs          List log names. gl | get-log            Get log configuration information. sl | set-log            Modify configuration of a log. ep | enum-publishers    List event publishers. gp | get-publisher      Get publisher configuration information. im | install-manifest   Install event publishers and logs from manifest. um | uninstall-manifest Uninstall event publishers and logs from manifest. qe | query-events       Query events from a log or log file. gli | get-log-info      Get log status information. epl | export-log        Export a log. al | archive-log        Archive an exported log. cl | clear-log          Clear a log.  <SNIP>`

Nous pouvons utiliser le paramètre `el` pour énumérer les noms de tous les journaux présents sur un système Windows.

#### Énumération des sources de journaux

        cmd
`C:\htb> wevtutil el  AMSI/Debug AirSpaceChannel Analytic Application DirectShowFilterGraph DirectShowPluginControl Els_Hyphenation/Analytic EndpointMapper FirstUXPerf-Analytic ForwardedEvents General Logging HardwareEvents  <SNIP>`

Avec le paramètre `gl`, nous pouvons afficher les informations de configuration d'un journal spécifique, notamment si le journal est activé ou non, sa taille maximale, les autorisations et l'endroit où le journal est stocké sur le système.

#### Collecte d'informations sur les journaux

        cmd
`C:\htb> wevtutil gl "Windows PowerShell"  name: Windows PowerShell enabled: true type: Admin owningPublisher: isolation: Application channelAccess: O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)(A;;0x2;;;S-1-15-3-1024-3153509613-960666767-3724611135-2725662640-12138253-543910227-1950414635-4190290187)(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x7;;;SO)(A;;0x3;;;IU)(A;;0x3;;;SU)(A;;0x3;;;S-1-5-3)(A;;0x3;;;S-1-5-33)(A;;0x1;;;S-1-5-32-573) logging:   logFileName: %SystemRoot%\System32\Winevt\Logs\Windows PowerShell.evtx   retention: false   autoBackup: false   maxSize: 15728640 publishing:   fileMax: 1`

Le paramètre `gli` nous donnera des informations d'état spécifiques sur le journal ou le fichier journal, telles que l'heure de création, les dernières heures d'accès et d'écriture, la taille du fichier, le nombre d'enregistrements de journal, et plus encore.

        cmd
`C:\htb> wevtutil gli "Windows PowerShell"  creationTime: 2020-10-06T16:57:38.617Z lastAccessTime: 2022-10-26T19:05:21.533Z lastWriteTime: 2022-10-26T19:05:21.533Z fileSize: 11603968 attributes: 32 numberOfLogRecords: 9496 oldestRecordNumber: 1`

Il existe de nombreuses façons d'interroger les événements. Par exemple, disons que nous voulons afficher les 5 événements les plus récents du journal de sécurité au format texte. Un accès administrateur local est nécessaire pour cette commande.

#### Interrogation d'événements

        cmd
`C:\htb> wevtutil qe Security /c:5 /rd:true /f:text  Event[0]   Log Name: Security   Source: Microsoft-Windows-Security-Auditing   Date: 2022-11-16T14:54:13.2270000Z   Event ID: 4799   Task: Security Group Management   Level: Information   Opcode: Info   Keyword: Audit Success   User: N/A   User Name: N/A   Computer: ICL-WIN11.greenhorn.corp   Description:  A security-enabled local group membership was enumerated.  Subject:         Security ID:            S-1-5-18         Account Name:           ICL-WIN11$         Account Domain:         GREENHORN         Logon ID:               0x3E7  Group:         Security ID:            S-1-5-32-544         Group Name:             Administrators         Group Domain:           Builtin  Process Information:         Process ID:             0x56c         Process Name:           C:\Windows\System32\svchost.exe  Event[1]   Log Name: Security   Source: Microsoft-Windows-Security-Auditing   Date: 2022-11-16T14:54:13.0160000Z   Event ID: 4672   Task: Special Logon   Level: Information   Opcode: Info   Keyword: Audit Success   User: N/A   User Name: N/A   Computer: ICL-WIN11.greenhorn.corp   Description: Special privileges assigned to new logon.  Subject:         Security ID:            S-1-5-21-4125911421-2584895310-3954972028-1001                 Account Name:           htb-student         Account Domain:         ICL-WIN11         Logon ID:               0x8F211  Privileges:             SeSecurityPrivilege                         SeTakeOwnershipPrivilege                         SeLoadDriverPrivilege                         SeBackupPrivilege                         SeRestorePrivilege                         SeDebugPrivilege                         SeSystemEnvironmentPrivilege                         SeImpersonatePrivilege                         SeDelegateSessionUserImpersonatePrivilege  Event[2]   Log Name: Security   Source: Microsoft-Windows-Security-Auditing   Date: 2022-11-16T14:54:13.0160000Z   Event ID: 4624   Task: Logon   Level: Information   Opcode: Info   Keyword: Audit Success   User: N/A   User Name: N/A   Computer: ICL-WIN11.greenhorn.corp   Description: An account was successfully logged on.  Subject:         Security ID:            S-1-5-18         Account Name:           ICL-WIN11$         Account Domain:         GREENHORN         Logon ID:               0x3E7   <SNIP>`

Nous pouvons également exporter des événements d'un journal spécifique pour un traitement hors ligne. L'accès administrateur local est également nécessaire pour effectuer cette exportation.

#### Exportation d'événements

        cmd
`C:\htb> wevtutil epl System C:\system_export.evtx`

---

## Interagir avec le journal d'événements Windows - PowerShell

De même, nous pouvons interagir avec les journaux d'événements Windows en utilisant le cmdlet PowerShell [Get-WinEvent](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-7.3). Comme pour les exemples avec `wevtutil`, certaines commandes nécessitent un accès de niveau administrateur local.

Pour commencer, nous pouvons lister tous les journaux sur l'ordinateur, ce qui nous donne le nombre d'enregistrements dans chaque journal.

#### PowerShell - Lister tous les journaux

        powershell
`PS C:\htb> Get-WinEvent -ListLog *  LogMode   MaximumSizeInBytes RecordCount LogName -------   ------------------ ----------- ------- Circular            15728640         657 Windows PowerShell Circular            20971520       10713 System Circular            20971520       26060 Security Circular            20971520           0 Key Management Service Circular             1052672           0 Internet Explorer Circular            20971520           0 HardwareEvents Circular            20971520        6202 Application Circular             1052672             Windows Networking Vpn Plugin Platform/Op... Circular             1052672             Windows Networking Vpn Plugin Platform/Op...  Circular             1052672           0 SMSApi Circular             1052672          61 Setup Circular            15728640          24 PowerShellCore/Operational Circular             1052672          99 OpenSSH/Operational Circular             1052672          46 OpenSSH/Admin  <SNIP>`

Nous pouvons également lister des informations sur un journal spécifique. Ici, nous pouvons voir la taille du journal de `Sécurité`.

#### Détails du journal de sécurité

        powershell
`PS C:\htb> Get-WinEvent -ListLog Security  LogMode   MaximumSizeInBytes RecordCount LogName -------   ------------------ ----------- ------- Circular            20971520       26060 Security`

Nous pouvons rechercher les X derniers événements, en cherchant spécifiquement les cinq derniers événements à l'aide du paramètre `-MaxEvents`. Ici, nous allons lister les cinq derniers événements enregistrés dans le journal de sécurité. Par défaut, les journaux les plus récents sont listés en premier. Si nous voulons obtenir les journaux plus anciens en premier, nous pouvons inverser l'ordre pour lister les plus anciens en premier à l'aide du paramètre `-Oldest`.

#### Interroger les cinq derniers événements

        powershell
`PS C:\htb> Get-WinEvent -LogName 'Security' -MaxEvents 5 | Select-Object -ExpandProperty Message  An account was logged off.  Subject:         Security ID:            S-1-5-111-3847866527-469524349-687026318-516638107-1125189541-6052         Account Name:           sshd_6052         Account Domain:         VIRTUAL USERS         Logon ID:               0x8E787  Logon Type:                     5  This event is generated when a logon session is destroyed. It may be positively correlated with a logon event using the Logon ID value. Logon IDs are only unique between reboots on the same computer. Special privileges assigned to new logon.  Subject:         Security ID:            S-1-5-18         Account Name:           SYSTEM         Account Domain:         NT AUTHORITY         Logon ID:               0x3E7  Privileges:             SeAssignPrimaryTokenPrivilege                         SeTcbPrivilege                         SeSecurityPrivilege                         SeTakeOwnershipPrivilege                         SeLoadDriverPrivilege                         SeBackupPrivilege                         SeRestorePrivilege                         SeDebugPrivilege                         SeAuditPrivilege                         SeSystemEnvironmentPrivilege                         SeImpersonatePrivilege                         SeDelegateSessionUserImpersonatePrivilege An account was successfully logged on.  <SNIP>`

Nous pouvons approfondir et examiner des ID d'événements spécifiques dans des journaux spécifiques. Disons que nous voulons uniquement examiner les échecs de connexion dans le journal de sécurité, en vérifiant l'ID d'événement [4625 : Échec de la connexion d'un compte](https://learn.microsoft.com/fr-fr/windows/security/threat-protection/auditing/event-4625). À partir de là, nous pourrions utiliser le paramètre `-ExpandProperty` pour approfondir des événements spécifiques, lister les journaux du plus ancien au plus récent, etc.

#### Filtrage des échecs de connexion

        powershell
`PS C:\htb> Get-WinEvent -FilterHashTable @{LogName='Security';ID='4625 '}     ProviderName: Microsoft-Windows-Security-Auditing  TimeCreated                      Id LevelDisplayName Message -----------                      -- ---------------- ------- 11/16/2022 2:53:16 PM          4625 Information      An account failed to log on....   11/16/2022 2:53:16 PM          4625 Information      An account failed to log on....  11/16/2022 2:53:12 PM          4625 Information      An account failed to log on....  11/16/2022 2:50:36 PM          4625 Information      An account failed to log on....  11/16/2022 2:50:29 PM          4625 Information      An account failed to log on....  11/16/2022 2:50:21 PM          4625 Information      An account failed to log on....  <SNIP>`

Nous pouvons également ne regarder que les événements avec un niveau d'information spécifique. Vérifions tous les journaux système pour les événements `critiques` uniquement avec le niveau d'information `1`. Ici, nous ne voyons qu'une seule entrée de journal où le système n'a pas redémarré proprement.

        powershell
`PS C:\htb> Get-WinEvent -FilterHashTable @{LogName='System';Level='1'} | select-object -ExpandProperty Message  The system has rebooted without cleanly shutting down first. This error could be caused if the system stopped responding, crashed, or lost power unexpectedly.`

Entraînez-vous davantage avec `wevtutil` et `Get-WinEvent` pour vous familiariser avec la recherche dans les journaux. Microsoft fournit quelques [exemples](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-7.3) pour `Get-WinEvent`, tandis que [ce site](https://www.thewindowsclub.com/what-is-wevtutil-and-how-do-you-use-it) montre des exemples pour `wevtutil`, et [ce site](https://4sysops.com/archives/search-the-event-log-with-the-get-winevent-powershell-cmdlet/) propose quelques exemples supplémentaires pour l'utilisation de `Get-WinEvent`.

---

## Prochaine étape

Cette section a présenté le journal d'événements Windows, un vaste sujet que nous approfondirons beaucoup plus dans les modules ultérieurs. Essayez les différents exemples de cette section et familiarisez-vous avec l'utilisation des deux outils pour rechercher des informations spécifiques. Dans les modules ultérieurs, nous verrons comment nous pouvons parfois trouver des données sensibles, telles que des mots de passe, dans les journaux d'événements. La journalisation sur Windows est très puissante lorsqu'elle est correctement configurée. Chaque système génère une quantité massive de journaux et, comme nous l'avons vu avec tous les ID d'événements possibles, nous pouvons être très granulaires sur ce que nous choisissons exactement de journaliser. Toutes ces données seraient très difficiles à interroger constamment et sont plus efficaces lorsqu'elles sont transférées vers un outil SIEM qui peut être utilisé pour mettre en place des alertes sur des ID d'événements spécifiques qui peuvent être révélateurs d'une attaque, comme le Kerberoasting, la pulvérisation de mots de passe (Password Spraying) ou d'autres attaques moins courantes. En tant que testeurs d'intrusion, nous devrions être familiers avec le journal d'événements Windows, comment nous pouvons l'utiliser pour obtenir des informations sur l'environnement, et parfois même extraire des données sensibles. Pour les défenseurs (blue teamers), une connaissance approfondie du journal d'événements Windows et de la manière de l'exploiter pour une alerte et une surveillance efficaces est essentielle.

Dans la section suivante, nous aborderons les opérations réseau depuis la ligne de commande sur un système Windows.