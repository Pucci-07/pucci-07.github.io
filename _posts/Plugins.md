[[Metasploitable HTB]]

Les plugins sont des logiciels prêts à l'emploi qui ont déjà été publiés par des tiers et qui ont donné leur accord aux créateurs de Metasploit pour intégrer leurs logiciels au sein du framework. Il peut s'agir de produits commerciaux qui ont une `Community Edition` pour une utilisation gratuite mais avec des fonctionnalités limitées, ou de projets individuels développés par des particuliers.

L'utilisation de plugins facilite encore plus la vie d'un pentester, en intégrant les fonctionnalités de logiciels bien connus dans les environnements `msfconsole` ou Metasploit Pro. Alors qu'auparavant, nous devions passer d'un logiciel à l'autre pour importer et exporter des résultats, en configurant sans cesse les options et les paramètres, maintenant, grâce aux plugins, tout est automatiquement documenté par msfconsole dans la base de données que nous utilisons, et les hôtes, les services et les vulnérabilités sont disponibles en un coup d'œil pour l'utilisateur. Les [Plugins](https://web.archive.org/web/20240302133153/https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Plugin) interagissent directement avec l'API et peuvent être utilisés pour manipuler l'ensemble du framework. Ils peuvent être utiles pour automatiser des tâches répétitives, ajouter de nouvelles commandes à `msfconsole` et étendre ce framework déjà puissant.

---

## Utiliser les plugins

Pour commencer à utiliser un plugin, nous devons nous assurer qu'il est installé dans le bon répertoire sur notre machine. En naviguant vers `/usr/share/metasploit-framework/plugins`, qui est le répertoire par défaut pour chaque nouvelle installation de `msfconsole`, nous devrions voir les plugins dont nous disposons :

        shellsession
`ppporrkkky@htb[/htb]$ ls /usr/share/metasploit-framework/plugins  aggregator.rb      beholder.rb        event_tester.rb  komand.rb     msfd.rb    nexpose.rb   request.rb  session_notifier.rb  sounds.rb  token_adduser.rb  wmap.rb alias.rb           db_credcollect.rb  ffautoregen.rb   lab.rb        msgrpc.rb  openvas.rb   rssfeed.rb  session_tagger.rb    sqlmap.rb  token_hunter.rb auto_add_route.rb  db_tracker.rb      ips_filter.rb    libnotify.rb  nessus.rb  pcap_log.rb  sample.rb   socket_logger.rb     thread.rb  wiki.rb`

Si le plugin s'y trouve, nous pouvons le lancer dans `msfconsole` et nous verrons le message d'accueil de ce plugin spécifique, signalant qu'il a été chargé avec succès et qu'il est maintenant prêt à être utilisé :

#### MSF - Charger Nessus

        shellsession
`msf6 > load nessus  [*] Nessus Bridge for Metasploit [*] Type nessus_help for a command listing [*] Successfully loaded Plugin: Nessus   msf6 > nessus_help  Command                     Help Text -------                     --------- Generic Commands             -----------------           ----------------- nessus_connect              Connect to a Nessus server nessus_logout               Logout from the Nessus server nessus_login                Login into the connected Nessus server with a different username and   <SNIP>  nessus_user_del             Delete a Nessus User nessus_user_passwd          Change Nessus Users Password                              Policy Commands              -----------------           ----------------- nessus_policy_list          List all polciies nessus_policy_del           Delete a policy`

Si le plugin n'est pas installé correctement, nous recevrons l'erreur suivante en essayant de le charger.

        shellsession
`msf6 > load Plugin_That_Does_Not_Exist  [-] Failed to load plugin from /usr/share/metasploit-framework/plugins/Plugin_That_Does_Not_Exist.rb: cannot load such file -- /usr/share/metasploit-framework/plugins/Plugin_That_Does_Not_Exist.rb`

Pour commencer à utiliser le plugin, lancez les commandes qui nous sont proposées dans le menu d'aide de ce plugin spécifique. Chaque intégration multiplateforme nous offre un ensemble unique d'interactions que nous pouvons utiliser lors de nos évaluations (assessments), il est donc utile de se documenter sur chacune d'entre elles avant de les employer pour en tirer le meilleur parti.

---

## Installer de nouveaux plugins

De nouveaux plugins, plus populaires, sont installés à chaque mise à jour de la distribution Parrot OS, au fur et à mesure qu'ils sont rendus publics par leurs créateurs et collectés dans le dépôt de mise à jour de Parrot. Pour installer de nouveaux plugins personnalisés non inclus dans les nouvelles mises à jour de la distribution, nous pouvons prendre le fichier .rb fourni sur la page du créateur et le placer dans le dossier `/usr/share/metasploit-framework/plugins` avec les permissions appropriées.

Par exemple, essayons d'installer les [Metasploit-Plugins de DarkOperator](https://github.com/darkoperator/Metasploit-Plugins.git). Ensuite, en suivant le lien ci-dessus, nous obtenons quelques fichiers Ruby (`.rb`) que nous pouvons placer directement dans le dossier mentionné précédemment.

#### Téléchargement des plugins MSF

        shellsession
`ppporrkkky@htb[/htb]$ git clone https://github.com/darkoperator/Metasploit-Plugins ppporrkkky@htb[/htb]$ ls Metasploit-Plugins  aggregator.rb      ips_filter.rb  pcap_log.rb          sqlmap.rb alias.rb           komand.rb      pentest.rb           thread.rb auto_add_route.rb  lab.rb         request.rb           token_adduser.rb beholder.rb        libnotify.rb   rssfeed.rb           token_hunter.rb db_credcollect.rb  msfd.rb        sample.rb            twitt.rb db_tracker.rb      msgrpc.rb      session_notifier.rb  wiki.rb event_tester.rb    nessus.rb      session_tagger.rb    wmap.rb ffautoregen.rb     nexpose.rb     socket_logger.rb growl.rb           openvas.rb     sounds.rb`

Ici, nous pouvons prendre le plugin `pentest.rb` comme exemple et le copier dans `/usr/share/metasploit-framework/plugins`.

#### MSF - Copie du plugin vers MSF

        shellsession
`ppporrkkky@htb[/htb]$ sudo cp ./Metasploit-Plugins/pentest.rb /usr/share/metasploit-framework/plugins/pentest.rb`

Ensuite, lancez `msfconsole` et vérifiez l'installation du plugin en exécutant la commande `load`. Une fois le plugin chargé, le menu d'aide (`help menu`) de `msfconsole` est automatiquement enrichi de fonctions supplémentaires.

#### MSF - Charger le plugin

        shellsession
``ppporrkkky@htb[/htb]$ msfconsole -q  msf6 > load pentest         ___         _          _     ___ _           _       | _ \___ _ _| |_ ___ __| |_  | _ \ |_  _ __ _(_)_ _       |  _/ -_) ' \  _/ -_|_-<  _| |  _/ | || / _` | | ' \        |_| \___|_||_\__\___/__/\__| |_| |_|\_,_\__, |_|_||_|                                               |___/        Version 1.6 Pentest Plugin loaded. by Carlos Perez (carlos_perez[at]darkoperator.com) [*] Successfully loaded plugin: pentest   msf6 > help  Tradecraft Commands ===================      Command          Description     -------          -----------     check_footprint  Checks the possible footprint of a post module on a target system.   auto_exploit Commands =====================      Command           Description     -------           -----------     show_client_side  Show matched client side exploits from data imported from vuln scanners.     vuln_exploit      Runs exploits based on data imported from vuln scanners.   Discovery Commands ==================      Command                 Description     -------                 -----------     discover_db             Run discovery modules against current hosts in the database.     network_discover        Performs a port-scan and enumeration of services found for non pivot networks.     pivot_network_discover  Performs enumeration of networks available to a specified Meterpreter session.     show_session_networks   Enumerate the networks one could pivot thru Meterpreter in the active sessions.   Project Commands ================      Command       Description     -------       -----------     project       Command for managing projects.   Postauto Commands =================      Command             Description     -------             -----------     app_creds           Run application password collection modules against specified sessions.     get_lhost           List local IP addresses that can be used for LHOST.     multi_cmd           Run shell command against several sessions     multi_meter_cmd     Run a Meterpreter Console Command against specified sessions.     multi_meter_cmd_rc  Run resource file with Meterpreter Console Commands against specified sessions.     multi_post          Run a post module against specified sessions.     multi_post_rc       Run resource file with post modules and options against specified sessions.     sys_creds           Run system password collection modules against specified sessions.  <SNIP>``

De nombreuses personnes écrivent de nombreux plugins différents pour le framework Metasploit. Ils ont tous un objectif spécifique et peuvent être d'une grande aide pour gagner du temps une fois que nous nous sommes familiarisés avec eux. Consultez la liste des plugins populaires ci-dessous :

||||
|---|---|---|
|[nMap (pré-installé)](https://nmap.org)|[NexPose (pré-installé)](https://sectools.org/tool/nexpose/)|[Nessus (pré-installé)](https://www.tenable.com/products/nessus)|
|[Mimikatz (pré-installé V.1)](http://blog.gentilkiwi.com/mimikatz)|[Stdapi (pré-installé)](https://www.rubydoc.info/github/rapid7/metasploit-framework/Rex/Post/Meterpreter/Extensions/Stdapi/Stdapi)|[Railgun](https://github.com/rapid7/metasploit-framework/wiki/How-to-use-Railgun-for-Windows-post-exploitation)|
|[Priv](https://github.com/rapid7/metasploit-framework/blob/master/lib/rex/post/meterpreter/extensions/priv/priv.rb)|[Incognito (pré-installé)](https://www.offensive-security.com/metasploit-unleashed/fun-incognito/)|[Darkoperator's](https://github.com/darkoperator/Metasploit-Plugins)|

---

## Mixins

Le Metasploit Framework est écrit en Ruby, un langage de programmation orienté objet. C'est en grande partie ce qui rend `msfconsole` si excellent à utiliser. Les mixins font partie de ces fonctionnalités qui, une fois implémentées, offrent une grande flexibilité tant au créateur du script qu'à l'utilisateur.

Les mixins sont des classes qui agissent comme des méthodes pouvant être utilisées par d'autres classes sans avoir à être la classe parente de ces autres classes. Ainsi, il serait inapproprié de parler d'héritage, mais plutôt d'inclusion. Ils sont principalement utilisés lorsque nous :

1. Voulons fournir de nombreuses fonctionnalités optionnelles pour une classe.
2. Voulons utiliser une fonctionnalité particulière pour une multitude de classes.

La majeure partie du langage de programmation Ruby s'articule autour des Mixins en tant que Modules. Le concept de Mixin est implémenté à l'aide du mot `include`, auquel nous passons le nom du module en tant que paramètre (`parameter`). Nous pouvons en apprendre plus sur les mixins [ici](https://en.wikibooks.org/wiki/Metasploit/UsingMixins).

Si nous débutons avec Metasploit, nous ne devrions pas nous soucier de l'utilisation des Mixins ou de leur impact sur notre évaluation (assessment). Cependant, ils sont mentionnés ici pour souligner à quel point la personnalisation de Metasploit peut devenir complexe.