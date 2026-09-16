[[Footprinting HTB]]

Le `Simple Network Management Protocol` ([SNMP](https://datatracker.ietf.org/doc/html/rfc1157)) a été créé pour surveiller les équipements réseau. De plus, ce protocole peut également être utilisé pour gérer des tâches de configuration et modifier des paramètres à distance. Le matériel compatible SNMP inclut les routeurs, les commutateurs (switches), les serveurs, les appareils IoT et de nombreux autres appareils qui peuvent également être interrogés et contrôlés à l'aide de ce protocole standard. Il s'agit donc d'un protocole de surveillance et de gestion des équipements réseau. De plus, des tâches de configuration peuvent être gérées et des réglages peuvent être effectués à distance à l'aide de cette norme. La version actuelle est `SNMPv3`, qui augmente notamment la sécurité de SNMP, mais aussi la complexité d'utilisation de ce protocole.

En plus du pur échange d'informations, SNMP transmet également des commandes de contrôle via des agents sur le port UDP `161`. Le client peut définir des valeurs spécifiques dans l'appareil et modifier des options et des paramètres avec ces commandes. Alors que dans la communication classique, c'est toujours le client qui demande activement des informations au serveur, SNMP permet également l'utilisation de ce que l'on appelle des `traps` (interruptions) sur le port UDP `162`. Ce sont des paquets de données envoyés du serveur SNMP au client sans avoir été explicitement demandés. Si un appareil est configuré en conséquence, un trap SNMP est envoyé au client dès qu'un événement spécifique se produit côté serveur.

Pour que le client et le serveur SNMP puissent échanger les valeurs respectives, les objets SNMP disponibles doivent avoir des adresses uniques connues des deux côtés. Ce mécanisme d'adressage est une condition préalable absolue pour une transmission de données et une surveillance réseau réussies à l'aide de SNMP.

#### MIB

Pour garantir que l'accès SNMP fonctionne entre les fabricants et avec différentes combinaisons client-serveur, la `Management Information Base` (`MIB`, base d'informations de gestion) a été créée. La MIB est un format indépendant pour stocker les informations sur les appareils. Une MIB est un fichier texte dans lequel tous les objets SNMP interrogeables d'un appareil sont répertoriés dans une hiérarchie arborescente normalisée. Elle contient au moins un `Object Identifier` (`OID`, identifiant d'objet), qui, en plus de l'adresse unique nécessaire et d'un nom, fournit également des informations sur le type, les droits d'accès et une description de l'objet respectif. Les fichiers MIB sont écrits au format texte ASCII basé sur l'`Abstract Syntax Notation One` (`ASN.1`). Les MIB ne contiennent pas de données, mais elles expliquent où trouver quelle information et à quoi elle ressemble, quelles valeurs sont renvoyées pour l'OID spécifique, ou quel type de données est utilisé.

#### OID

Un OID représente un nœud dans un espace de noms hiérarchique. Une séquence de nombres identifie de manière unique chaque nœud, permettant de déterminer la position du nœud dans l'arborescence. Plus la chaîne est longue, plus l'information est spécifique. De nombreux nœuds dans l'arborescence OID ne contiennent rien d'autre que des références à ceux qui se trouvent en dessous d'eux. Les OID sont constitués d'entiers et sont généralement concaténés par une notation à points. Nous pouvons rechercher de nombreuses MIB pour les OID associés dans le [Object Identifier Registry](https://www.alvestrand.no/objectid/).

#### SNMPv1

La version 1 de SNMP (`SNMPv1`) est utilisée pour la gestion et la surveillance du réseau. SNMPv1 est la première version du protocole et est encore utilisée dans de nombreux petits réseaux. Elle prend en charge la récupération d'informations à partir des équipements réseau, permet la configuration des appareils et fournit des traps, qui sont des notifications d'événements. Cependant, SNMPv1 n'a `aucun mécanisme d'authentification intégré`, ce qui signifie que toute personne accédant au réseau peut lire et modifier les données du réseau. Un autre défaut majeur de SNMPv1 est qu'il `ne prend pas en charge le chiffrement`, ce qui signifie que toutes les données sont envoyées en texte clair et peuvent être facilement interceptées.

#### SNMPv2

SNMPv2 a existé en différentes versions. La version qui existe encore aujourd'hui est la `v2c`, et l'extension `c` signifie SNMP basé sur la communauté (community-based). En ce qui concerne la sécurité, SNMPv2 est au même niveau que SNMPv1 et a été étendu avec des fonctions supplémentaires du SNMP basé sur les parties (party-based) qui n'est plus utilisé. Cependant, un problème important avec l'exécution initiale du protocole SNMP est que la `community string` (chaîne de communauté) qui assure la sécurité est uniquement transmise en texte clair, ce qui signifie qu'elle n'a pas de chiffrement intégré.

#### SNMPv3

La sécurité a été énormément renforcée pour `SNMPv3` par des fonctionnalités de sécurité telles que l' `authentification` par nom d'utilisateur et mot de passe et le `chiffrement` de la transmission des données (via une `pre-shared key` ou clé pré-partagée). Cependant, la complexité augmente également dans la même mesure, avec beaucoup plus d'options de configuration que la `v2c`.

#### Chaînes de communauté (Community Strings)

Les chaînes de communauté peuvent être considérées comme des mots de passe utilisés pour déterminer si les informations demandées peuvent être consultées ou non. Il est important de noter que de nombreuses organisations utilisent encore `SNMPv2`, car la transition vers `SNMPv3` peut être très complexe, mais les services doivent rester actifs. Cela cause beaucoup de soucis à de nombreux administrateurs et crée certains problèmes qu'ils tiennent à éviter. Le manque de connaissances sur la manière dont les informations peuvent être obtenues et sur la façon dont nous, en tant qu'attaquants, les utilisons, rend l'approche des administrateurs inexplicable. En même temps, l'absence de chiffrement des données envoyées est également un problème. Car chaque fois que les chaînes de communauté sont envoyées sur le réseau, elles peuvent être interceptées et lues.

---

## Configuration par défaut

La configuration par défaut du démon SNMP définit les paramètres de base du service, qui incluent les adresses IP, les ports, la MIB, les OID, l'authentification et les chaînes de communauté.

#### Configuration du démon SNMP

        shellsession
`ppporrkkky@htb[/htb]$ cat /etc/snmp/snmpd.conf | grep -v "#" | sed -r '/^\s*$/d'  sysLocation    Sitting on the Dock of the Bay sysContact     Me <me@example.org> sysServices    72 master  agentx agentaddress  127.0.0.1,[::1] view   systemonly  included   .1.3.6.1.2.1.1 view   systemonly  included   .1.3.6.1.2.1.25.1 rocommunity  public default -V systemonly rocommunity6 public default -V systemonly rouser authPrivUser authpriv -V systemonly`

La configuration de ce service peut également être modifiée de nombreuses manières. Par conséquent, nous recommandons de configurer une VM pour installer et configurer nous-mêmes le serveur SNMP. Tous les paramètres qui peuvent être définis pour le démon SNMP sont définis et décrits dans la [page de manuel (manpage)](http://www.net-snmp.org/docs/man/snmpd.conf.html).

---

## Paramètres dangereux

Voici quelques paramètres dangereux que l'administrateur peut définir avec SNMP :

|**Paramètres**|**Description**|
|---|---|
|`rwuser noauth`|Fournit un accès à l'arborescence OID complète sans authentification.|
|`rwcommunity <community string> <IPv4 address>`|Fournit un accès à l'arborescence OID complète, peu importe d'où les requêtes ont été envoyées.|
|`rwcommunity6 <community string> <IPv6 address>`|Même accès qu'avec `rwcommunity` à la différence de l'utilisation d'IPv6.|

---

## Prise d'empreinte du service

Pour la prise d'empreinte (footprinting) de SNMP, nous pouvons utiliser des outils comme `snmpwalk`, `onesixtyone` et `braa`. `Snmpwalk` est utilisé pour interroger les OID avec leurs informations. `Onesixtyone` peut être utilisé pour forcer par la force brute (brute-force) les noms des chaînes de communauté, car elles peuvent être nommées arbitrairement par l'administrateur. Étant donné que ces chaînes de communauté peuvent être liées à n'importe quelle source, l'identification des chaînes de communauté existantes peut prendre un certain temps.

#### SNMPwalk

        shellsession
`ppporrkkky@htb[/htb]$ snmpwalk -v2c -c public 10.129.14.128  iso.3.6.1.2.1.1.1.0 = STRING: "Linux htb 5.11.0-34-generic #36~20.04.1-Ubuntu SMP Fri Aug 27 08:06:32 UTC 2021 x86_64" iso.3.6.1.2.1.1.2.0 = OID: iso.3.6.1.4.1.8072.3.2.10 iso.3.6.1.2.1.1.3.0 = Timeticks: (5134) 0:00:51.34 iso.3.6.1.2.1.1.4.0 = STRING: "mrb3n@inlanefreight.htb" iso.3.6.1.2.1.1.5.0 = STRING: "htb" iso.3.6.1.2.1.1.6.0 = STRING: "Sitting on the Dock of the Bay" iso.3.6.1.2.1.1.7.0 = INTEGER: 72 iso.3.6.1.2.1.1.8.0 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.1.9.1.2.1 = OID: iso.3.6.1.6.3.10.3.1.1 iso.3.6.1.2.1.1.9.1.2.2 = OID: iso.3.6.1.6.3.11.3.1.1 iso.3.6.1.2.1.1.9.1.2.3 = OID: iso.3.6.1.6.3.15.2.1.1 iso.3.6.1.2.1.1.9.1.2.4 = OID: iso.3.6.1.6.3.1 iso.3.6.1.2.1.1.9.1.2.5 = OID: iso.3.6.1.6.3.16.2.2.1 iso.3.6.1.2.1.1.9.1.2.6 = OID: iso.3.6.1.2.1.49 iso.3.6.1.2.1.1.9.1.2.7 = OID: iso.3.6.1.2.1.4 iso.3.6.1.2.1.1.9.1.2.8 = OID: iso.3.6.1.2.1.50 iso.3.6.1.2.1.1.9.1.2.9 = OID: iso.3.6.1.6.3.13.3.1.3 iso.3.6.1.2.1.1.9.1.2.10 = OID: iso.3.6.1.2.1.92 iso.3.6.1.2.1.1.9.1.3.1 = STRING: "The SNMP Management Architecture MIB." iso.3.6.1.2.1.1.9.1.3.2 = STRING: "The MIB for Message Processing and Dispatching." iso.3.6.1.2.1.1.9.1.3.3 = STRING: "The management information definitions for the SNMP User-based Security Model." iso.3.6.1.2.1.1.9.1.3.4 = STRING: "The MIB module for SNMPv2 entities" iso.3.6.1.2.1.1.9.1.3.5 = STRING: "View-based Access Control Model for SNMP." iso.3.6.1.2.1.1.9.1.3.6 = STRING: "The MIB module for managing TCP implementations" iso.3.6.1.2.1.1.9.1.3.7 = STRING: "The MIB module for managing IP and ICMP implementations" iso.3.6.1.2.1.1.9.1.3.8 = STRING: "The MIB module for managing UDP implementations" iso.3.6.1.2.1.1.9.1.3.9 = STRING: "The MIB modules for managing SNMP Notification, plus filtering." iso.3.6.1.2.1.1.9.1.3.10 = STRING: "The MIB module for logging SNMP Notifications." iso.3.6.1.2.1.1.9.1.4.1 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.1.9.1.4.2 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.1.9.1.4.3 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.1.9.1.4.4 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.1.9.1.4.5 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.1.9.1.4.6 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.1.9.1.4.7 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.1.9.1.4.8 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.1.9.1.4.9 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.1.9.1.4.10 = Timeticks: (0) 0:00:00.00 iso.3.6.1.2.1.25.1.1.0 = Timeticks: (3676678) 10:12:46.78 iso.3.6.1.2.1.25.1.2.0 = Hex-STRING: 07 E5 09 14 0E 2B 2D 00 2B 02 00  iso.3.6.1.2.1.25.1.3.0 = INTEGER: 393216 iso.3.6.1.2.1.25.1.4.0 = STRING: "BOOT_IMAGE=/boot/vmlinuz-5.11.0-34-generic root=UUID=9a6a5c52-f92a-42ea-8ddf-940d7e0f4223 ro quiet splash" iso.3.6.1.2.1.25.1.5.0 = Gauge32: 3 iso.3.6.1.2.1.25.1.6.0 = Gauge32: 411 iso.3.6.1.2.1.25.1.7.0 = INTEGER: 0 iso.3.6.1.2.1.25.1.7.0 = No more variables left in this MIB View (It is past the end of the MIB tree)  ...SNIP...  iso.3.6.1.2.1.25.6.3.1.2.1232 = STRING: "printer-driver-sag-gdi_0.1-7_all" iso.3.6.1.2.1.25.6.3.1.2.1233 = STRING: "printer-driver-splix_2.0.0+svn315-7fakesync1build1_amd64" iso.3.6.1.2.1.25.6.3.1.2.1234 = STRING: "procps_2:3.3.16-1ubuntu2.3_amd64" iso.3.6.1.2.1.25.6.3.1.2.1235 = STRING: "proftpd-basic_1.3.6c-2_amd64" iso.3.6.1.2.1.25.6.3.1.2.1236 = STRING: "proftpd-doc_1.3.6c-2_all" iso.3.6.1.2.1.25.6.3.1.2.1237 = STRING: "psmisc_23.3-1_amd64" iso.3.6.1.2.1.25.6.3.1.2.1238 = STRING: "publicsuffix_20200303.0012-1_all" iso.3.6.1.2.1.25.6.3.1.2.1239 = STRING: "pulseaudio_1:13.99.1-1ubuntu3.12_amd64" iso.3.6.1.2.1.25.6.3.1.2.1240 = STRING: "pulseaudio-module-bluetooth_1:13.99.1-1ubuntu3.12_amd64" iso.3.6.1.2.1.25.6.3.1.2.1241 = STRING: "pulseaudio-utils_1:13.99.1-1ubuntu3.12_amd64" iso.3.6.1.2.1.25.6.3.1.2.1242 = STRING: "python-apt-common_2.0.0ubuntu0.20.04.6_all" iso.3.6.1.2.1.25.6.3.1.2.1243 = STRING: "python3_3.8.2-0ubuntu2_amd64" iso.3.6.1.2.1.25.6.3.1.2.1244 = STRING: "python3-acme_1.1.0-1_all" iso.3.6.1.2.1.25.6.3.1.2.1245 = STRING: "python3-apport_2.20.11-0ubuntu27.21_all" iso.3.6.1.2.1.25.6.3.1.2.1246 = STRING: "python3-apt_2.0.0ubuntu0.20.04.6_amd64"   ...SNIP...`

En cas de mauvaise configuration, nous obtiendrions à peu près les mêmes résultats de `snmpwalk` que ceux montrés ci-dessus. Une fois que nous connaissons la chaîne de communauté et que le service SNMP ne nécessite pas d'authentification (versions 1, 2c), nous pouvons interroger les informations internes du système comme dans l'exemple précédent.

Ici, nous reconnaissons certains paquets Python qui ont été installés sur le système. Si nous ne connaissons pas la chaîne de communauté, nous pouvons utiliser `onesixtyone` et les listes de mots (wordlists) de `SecLists` pour identifier ces chaînes de communauté.

#### OneSixtyOne

        shellsession
`ppporrkkky@htb[/htb]$ sudo apt install onesixtyone ppporrkkky@htb[/htb]$ onesixtyone -c /opt/useful/seclists/Discovery/SNMP/snmp.txt 10.129.14.128  Scanning 1 hosts, 3220 communities 10.129.14.128 [public] Linux htb 5.11.0-37-generic #41~20.04.2-Ubuntu SMP Fri Sep 24 09:06:38 UTC 2021 x86_64`

Souvent, lorsque certaines chaînes de communauté sont liées à des adresses IP spécifiques, elles sont nommées avec le nom d'hôte de l'hôte, et parfois même des symboles sont ajoutés à ces noms pour les rendre plus difficiles à identifier. Cependant, si nous imaginons un vaste réseau avec plus de 100 serveurs différents gérés via SNMP, les étiquettes, dans ce cas, auront un certain motif. Par conséquent, nous pouvons utiliser différentes règles pour les deviner. Nous pouvons utiliser l'outil [crunch](https://secf00tprint.github.io/blog/passwords/crunch/advanced/en) pour créer des listes de mots personnalisées. La création de listes de mots personnalisées n'est pas une partie essentielle de ce module, mais plus de détails peuvent être trouvés dans le module [Cracking Passwords With Hashcat](https://academy.hackthebox.com/course/preview/cracking-passwords-with-hashcat).

Une fois que nous connaissons une chaîne de communauté, nous pouvons l'utiliser avec [braa](https://github.com/mteg/braa) pour forcer par la force brute les OID individuels et énumérer les informations qui se cachent derrière eux.

#### Braa

        shellsession
`ppporrkkky@htb[/htb]$ sudo apt install braa ppporrkkky@htb[/htb]$ braa <community string>@<IP>:.1.3.6.*   # Syntaxe ppporrkkky@htb[/htb]$ braa public@10.129.14.128:.1.3.6.*  10.129.14.128:20ms:.1.3.6.1.2.1.1.1.0:Linux htb 5.11.0-34-generic #36~20.04.1-Ubuntu SMP Fri Aug 27 08:06:32 UTC 2021 x86_64 10.129.14.128:20ms:.1.3.6.1.2.1.1.2.0:.1.3.6.1.4.1.8072.3.2.10 10.129.14.128:20ms:.1.3.6.1.2.1.1.3.0:548 10.129.14.128:20ms:.1.3.6.1.2.1.1.4.0:mrb3n@inlanefreight.htb 10.129.14.128:20ms:.1.3.6.1.2.1.1.5.0:htb 10.129.14.128:20ms:.1.3.6.1.2.1.1.6.0:US 10.129.14.128:20ms:.1.3.6.1.2.1.1.7.0:78 ...SNIP...`

Une fois de plus, nous tenons à souligner que la configuration indépendante du service SNMP nous apportera une grande variété d'expériences différentes qu'aucun tutoriel ne peut remplacer. Par conséquent, nous recommandons vivement de configurer une VM avec SNMP, d'expérimenter avec et d'essayer différentes configurations. SNMP peut être une aubaine pour un administrateur de systèmes informatiques ainsi qu'une malédiction pour les analystes et les responsables de la sécurité.


Lab de fin 

![[Pasted image 20260908193017.png]]

la commande d'énumération 

snmpwalk -v2c -c public $ip

NB ip sera remplacer par sa vrai valeur 

on a l'email admin 

![[Pasted image 20260908193314.png]]

![[Pasted image 20260908193354.png]]

dans la sortie du programme on a : 

![[Pasted image 20260908194457.png]]

le programme cible en  1 et la sortie du programme en 2 c'est la sortit quit est demander ici 