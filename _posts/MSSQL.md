[[Footprinting HTB]]

[Microsoft SQL](https://www.microsoft.com/en-us/sql-server/sql-server-2019) (`MSSQL`) est le système de gestion de base de données relationnelle (SGBDR) de Microsoft, basé sur SQL. Contrairement à MySQL, que nous avons abordé dans la section précédente, MSSQL est un logiciel propriétaire (closed source) et a été initialement développé pour fonctionner sur les systèmes d'exploitation Windows. Il est populaire auprès des administrateurs de bases de données et des développeurs qui créent des applications fonctionnant sur le framework .NET de Microsoft, en raison de son solide support natif pour .NET. Il existe des versions de MSSQL qui fonctionnent sur Linux et MacOS, mais nous rencontrerons plus probablement des instances MSSQL sur des cibles exécutant Windows.

#### Clients MSSQL

[SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15) (`SSMS`) est une fonctionnalité qui peut être installée avec le package d'installation de MSSQL, ou peut être téléchargée et installée séparément. Il est couramment installé sur le serveur pour la configuration initiale et la gestion à long terme des bases de données par les administrateurs. Gardez à l'esprit que, comme SSMS est une application côté client, il peut être installé et utilisé sur n'importe quel système à partir duquel un administrateur ou un développeur prévoit de gérer la base de données. Il n'est pas uniquement présent sur le serveur qui héberge la base de données. Cela signifie que nous pourrions tomber sur un système vulnérable avec SSMS contenant des identifiants de connexion enregistrés qui nous permettraient de nous connecter à la base de données. L'image ci-dessous montre SSMS en action.

![SQL Server Management Studio montrant l'Explorateur d'objets avec la base de données 'Employees' développée, affichant les tables, les vues et d'autres objets de la base de données.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/112/ssms.png)

De nombreux autres clients peuvent être utilisés pour accéder à une base de données fonctionnant sur MSSQL. En voici une liste non exhaustive :

||||||
|---|---|---|---|---|
|[mssql-cli](https://docs.microsoft.com/en-us/sql/tools/mssql-cli?view=sql-server-ver15)|[SQL Server PowerShell](https://docs.microsoft.com/en-us/sql/powershell/sql-server-powershell?view=sql-server-ver15)|[HeidiSQL](https://www.heidisql.com)|[SQLPro](https://www.macsqlclient.com)|[Impacket's mssqlclient.py](https://github.com/SecureAuthCorp/impacket/blob/master/examples/mssqlclient.py)|

Parmi les clients MSSQL listés ci-dessus, les pentesters (testeurs d'intrusion) trouveront probablement `Impacket's mssqlclient.py` comme étant le plus utile, car le projet Impacket de SecureAuthCorp est présent sur de nombreuses distributions de pentesting dès l'installation. Pour savoir si le client est présent sur notre hôte et où il se trouve, nous pouvons utiliser la commande suivante :

        shellsession
`ppporrkkky@htb[/htb]$ locate mssqlclient  /usr/bin/impacket-mssqlclient /usr/share/doc/python3-impacket/examples/mssqlclient.py`

#### Bases de données MSSQL

MSSQL possède des bases de données système par défaut qui peuvent nous aider à comprendre la structure de toutes les bases de données susceptibles d'être hébergées sur un serveur cible. Voici les bases de données par défaut et une brève description de chacune :

|Base de données système par défaut|Description|
|---|---|
|`master`|Suit toutes les informations système pour une instance de serveur SQL|
|`model`|Base de données modèle qui sert de structure pour chaque nouvelle base de données créée. Tout paramètre modifié dans la base de données modèle sera répercuté dans toute nouvelle base de données créée après les modifications apportées à la base de données modèle|
|`msdb`|L'Agent SQL Server utilise cette base de données pour planifier des tâches et des alertes|
|`tempdb`|Stocke les objets temporaires|
|`resource`|Base de données en lecture seule contenant les objets système inclus avec SQL Server|

Source du tableau : [Documentation Microsoft sur les bases de données système](https://docs.microsoft.com/en-us/sql/relational-databases/databases/system-databases?view=sql-server-ver15)

---

## Configuration par défaut

Lorsqu'un administrateur installe et configure initialement MSSQL pour qu'il soit accessible sur le réseau, le service SQL s'exécutera probablement en tant que `NT SERVICE\MSSQLSERVER`. La connexion côté client est possible via l'authentification Windows, et par défaut, le chiffrement n'est pas appliqué lors de la tentative de connexion.

![Fenêtre de connexion à SQL Server montrant les options pour le type de serveur, le nom du serveur 'ILF-SQL-01', et l'authentification Windows.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/112/auth.png)

Le fait que l'authentification soit définie sur `Windows Authentication` signifie que le système d'exploitation Windows sous-jacent traitera la demande de connexion et utilisera soit la base de données SAM locale, soit le contrôleur de domaine (hébergeant Active Directory) avant d'autoriser la connectivité au système de gestion de base de données. L'utilisation d'Active Directory peut être idéale pour auditer l'activité et contrôler l'accès dans un environnement Windows, mais si un compte est compromis, cela pourrait conduire à une élévation de privilèges (privilege escalation) et à un mouvement latéral (lateral movement) au sein d'un environnement de domaine Windows. Comme pour tout SE, service, rôle de serveur ou application, il peut être bénéfique de le configurer dans une VM, de l'installation à la configuration, pour comprendre toutes les configurations par défaut et les erreurs potentielles que l'administrateur pourrait commettre.

---

## Paramètres dangereux

Il peut être bénéfique de se mettre dans la peau d'un administrateur informatique lorsque nous sommes en mission (engagement). Cet état d'esprit peut nous aider à nous souvenir de rechercher divers paramètres qui pourraient avoir été mal configurés ou configurés de manière dangereuse par un administrateur. Une journée de travail en informatique peut être assez chargée, avec de nombreux projets différents se déroulant simultanément et la pression de performer avec rapidité et précision étant une réalité dans de nombreuses organisations, des erreurs peuvent être facilement commises. Il suffit d'une seule petite erreur de configuration pour compromettre un serveur ou un service critique sur le réseau. Cela s'applique à presque tous les services réseau et rôles de serveur qui peuvent être configurés, y compris MSSQL.

Cette liste n'est pas exhaustive, car il existe d'innombrables façons de configurer les bases de données MSSQL par les administrateurs en fonction des besoins de leurs organisations respectives. Il peut être avantageux d'examiner les points suivants :

- Clients MSSQL n'utilisant pas le chiffrement pour se connecter au serveur MSSQL
- L'utilisation de certificats auto-signés lorsque le chiffrement est utilisé. Il est possible d'usurper (spoof) des certificats auto-signés
- L'utilisation de [canaux nommés (named pipes)](https://docs.microsoft.com/en-us/sql/tools/configuration-manager/named-pipes-properties?view=sql-server-ver15)
- Identifiants `sa` faibles et par défaut. Les administrateurs peuvent oublier de désactiver ce compte

---

## Prise d'empreinte du service

Il existe de nombreuses façons d'aborder la prise d'empreinte du service MSSQL ; plus nos scans seront spécifiques, plus les informations que nous pourrons recueillir seront utiles. NMAP dispose de scripts mssql par défaut qui peuvent être utilisés pour cibler le port TCP par défaut `1433` sur lequel MSSQL écoute.

Le scan NMAP scripté ci-dessous nous fournit des informations utiles. Nous pouvons voir le nom d'hôte, le nom de l'instance de la base de données, la version du logiciel MSSQL et que les canaux nommés sont activés. Nous aurons avantage à ajouter ces découvertes à nos notes.

#### Scan par script NMAP pour MSSQL

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap --script ms-sql-info,ms-sql-empty-password,ms-sql-xp-cmdshell,ms-sql-config,ms-sql-ntlm-info,ms-sql-tables,ms-sql-hasdbaccess,ms-sql-dac,ms-sql-dump-hashes --script-args mssql.instance-port=1433,mssql.username=sa,mssql.password=,mssql.instance-name=MSSQLSERVER -sV -p 1433 10.129.201.248  Starting Nmap 7.91 ( https://nmap.org ) at 2021-11-08 09:40 EST Nmap scan report for 10.129.201.248 Host is up (0.15s latency).  PORT     STATE SERVICE  VERSION 1433/tcp open  ms-sql-s Microsoft SQL Server 2019 15.00.2000.00; RTM | ms-sql-ntlm-info:  |   Target_Name: SQL-01 |   NetBIOS_Domain_Name: SQL-01 |   NetBIOS_Computer_Name: SQL-01 |   DNS_Domain_Name: SQL-01 |   DNS_Computer_Name: SQL-01 |_  Product_Version: 10.0.17763  Host script results: | ms-sql-dac:  |_  Instance: MSSQLSERVER; DAC port: 1434 (connection failed) | ms-sql-info:  |   Windows server name: SQL-01 |   10.129.201.248\MSSQLSERVER:  |     Instance name: MSSQLSERVER |     Version:  |       name: Microsoft SQL Server 2019 RTM |       number: 15.00.2000.00 |       Product: Microsoft SQL Server 2019 |       Service pack level: RTM |       Post-SP patches applied: false |     TCP port: 1433 |     Named pipe: \\10.129.201.248\pipe\sql\query |_    Clustered: false  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 8.52 seconds`

Nous pouvons également utiliser Metasploit pour exécuter un scanner auxiliaire appelé `mssql_ping` qui scannera le service MSSQL et fournira des informations utiles dans notre processus de prise d'empreinte.

#### Ping MSSQL dans Metasploit

        shellsession
`msf6 auxiliary(scanner/mssql/mssql_ping) > set rhosts 10.129.201.248  rhosts => 10.129.201.248   msf6 auxiliary(scanner/mssql/mssql_ping) > run  [*] 10.129.201.248:       - SQL Server information for 10.129.201.248: [+] 10.129.201.248:       -    ServerName      = SQL-01 [+] 10.129.201.248:       -    InstanceName    = MSSQLSERVER [+] 10.129.201.248:       -    IsClustered     = No [+] 10.129.201.248:       -    Version         = 15.0.2000.5 [+] 10.129.201.248:       -    tcp             = 1433 [+] 10.129.201.248:       -    np              = \\SQL-01\pipe\sql\query [*] 10.129.201.248:       - Scanned 1 of 1 hosts (100% complete) [*] Auxiliary module execution completed`

#### Connexion avec Mssqlclient.py

Si nous pouvons deviner ou obtenir des identifiants de connexion, cela nous permet de nous connecter à distance au serveur MSSQL et de commencer à interagir avec les bases de données en utilisant T-SQL (`Transact-SQL`). L'authentification auprès de MSSQL nous permettra d'interagir directement avec les bases de données via le moteur de base de données SQL (SQL Database Engine). Depuis Pwnbox ou un hôte d'attaque personnel, nous pouvons utiliser `Impacket's mssqlclient.py` pour nous connecter comme le montre la sortie ci-dessous. Une fois connecté au serveur, il peut être bon de se faire une idée générale et de lister les bases de données présentes sur le système.

        shellsession
`ppporrkkky@htb[/htb]$ python3 mssqlclient.py Administrator@10.129.201.248 -windows-auth  Impacket v0.9.22 - Copyright 2020 SecureAuth Corporation  Password: [*] Encryption required, switching to TLS [*] ENVCHANGE(DATABASE): Old Value: master, New Value: master [*] ENVCHANGE(LANGUAGE): Old Value: , New Value: us_english [*] ENVCHANGE(PACKETSIZE): Old Value: 4096, New Value: 16192 [*] INFO(SQL-01): Line 1: Changed database context to 'master'. [*] INFO(SQL-01): Line 1: Changed language setting to us_english. [*] ACK: Result: 1 - Microsoft SQL Server (150 7208)  [!] Press help for extra shell commands  SQL> select name from sys.databases  name                                                                                                                                 --------------------------------------------------------------------------------------  master                                                                                                                               tempdb                                                                                                                               model                                                                                                                                msdb                                                                                                                                 Transactions`

![[Pasted image 20260908235108.png]]

![[Pasted image 20260908235146.png]]

on peut utiliser un module de msfconsole pour  cette partie vue que le scan ne marche pas bien 
le chemin du module dans msfconsole  : scanner/mssql/mssql_ping) 

![[Pasted image 20260908235401.png]]

initiation de la connection avec impacket 

![[Pasted image 20260908235723.png]]


donc on nous demande de lister la base de donnée pas par défaut du système 

![[Pasted image 20260909090632.png]]
avec help on voit la commande qui  peut nous permettre de faire de l'enum de bases de donnés qui est   : 
enum_db 
![[Pasted image 20260909090750.png]]

une fois lancé on vois la liste des bases de données et maintenant on a juste à chercher la base de donnée qui n'est pas par défaut  sur les serveurs MSSQL
