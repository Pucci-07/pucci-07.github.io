
[[Metasploitable HTB]]

Les `Cibles` (Targets) sont des identifiants uniques de systèmes d'exploitation, tirés des versions de ces systèmes d'exploitation spécifiques, qui adaptent le module d'exploitation sélectionné pour qu'il s'exécute sur cette version particulière du système d'exploitation. La commande `show targets` exécutée dans la vue d'un module d'exploitation affichera toutes les cibles vulnérables disponibles pour cet exploit spécifique, tandis que l'exécution de la même commande dans le menu racine, en dehors de tout module d'exploitation sélectionné, nous indiquera que nous devons d'abord sélectionner un module d'exploitation.

#### MSF - Afficher les Cibles

        shellsession
`msf6 > show targets  [-] No exploit module selected.`

En examinant notre module d'exploitation précédent, voici ce que nous verrions :

        shellsession
`msf6 exploit(windows/smb/ms17_010_psexec) > options     Nom                   Paramètre Actuel                         Requis  Description    ----                  ----------------                          --------  -----------    DBGTRACE              false                                    oui       Afficher des informations de trace de débogage supplémentaires    LEAKATTEMPTS          99                                       oui       Nombre de tentatives pour fuiter la transaction    NAMEDPIPE                                                      non       Un canal nommé (named pipe) auquel se connecter (laisser vide pour auto)    NAMED_PIPES           /usr/share/metasploit-framework/data/wo  oui       Liste des canaux nommés à vérifier                          rdlists/named_pipes.txt    RHOSTS                10.10.10.40                              oui       L'hôte ou les hôtes cibles, voir https://github.com/rapid7/metasploit-framework                                                                             /wiki/Using-Metasploit    RPORT                 445                                      oui       Le port cible (TCP)    SERVICE_DESCRIPTION                                            non       Description du service à utiliser sur la cible pour un affichage clair    SERVICE_DISPLAY_NAME                                           non       Le nom d'affichage du service    SERVICE_NAME                                                   non       Le nom du service    SHARE                 ADMIN$                                   oui       Le partage auquel se connecter, peut être un partage administratif (ADMIN$,C$,...) ou un partage de dossier normal en lecture/écriture    SMBDomain             .                                        non       Le domaine Windows à utiliser pour l'authentification    SMBPass                                                        non       Le mot de passe pour le nom d'utilisateur spécifié    SMBUser                                                        non       Le nom d'utilisateur pour s'authentifier   Options du payload (windows/meterpreter/reverse_tcp):     Nom       Paramètre Actuel  Requis  Description    ----      ---------------  --------  -----------    EXITFUNC  thread           oui       Technique de sortie (Accepté : '', seh, thread, process, none)    LHOST                      oui       L'adresse d'écoute (une interface peut être spécifiée)    LPORT     4444             oui       Le port d'écoute   Cible de l'exploit :     Id  Nom    --  ----    0   Automatique`

---

## Sélectionner une Cible

Nous pouvons voir qu'il n'y a qu'un seul type de cible général défini pour ce type d'exploit. Et si nous passions à un module d'exploitation qui nécessite des plages de cibles plus spécifiques ? L'exploit suivant vise :

- `MS12-063 Microsoft Internet Explorer execCommand Use-After-Free Vulnerability`.

Si nous voulons en savoir plus sur ce module spécifique et sur le fonctionnement de la vulnérabilité sous-jacente, nous pouvons utiliser la commande `info`. Cette commande peut nous aider lorsque nous ne sommes pas sûrs des origines ou des fonctionnalités des différents exploits ou modules auxiliaires. En gardant à l'esprit qu'il est toujours considéré comme une bonne pratique d'auditer notre code pour toute génération d'artefacts ou de « fonctionnalités supplémentaires », la commande `info` devrait être l'une des premières étapes que nous suivons lors de l'utilisation d'un nouveau module. De cette manière, nous pouvons nous familiariser avec les fonctionnalités de l'exploit tout en garantissant un environnement de travail sûr et propre pour nos clients et pour nous-mêmes.

#### MSF - Sélection de Cible

        shellsession
`msf6 exploit(windows/browser/ie_execcommand_uaf) > info         Nom: MS12-063 Microsoft Internet Explorer execCommand Use-After-Free Vulnerability       Module: exploit/windows/browser/ie_execcommand_uaf    Plateforme: Windows        Arch:   Privilégié: Non     Licence: Metasploit Framework License (BSD)        Rang: Good   Divulgué le: 2012-09-14  Fourni par :   unknown   eromang   binjo   sinn3r <sinn3r@metasploit.com>   juan vazquez <juan.vazquez@metasploit.com>  Cibles disponibles :   Id  Nom   --  ----   0   Automatique   1   IE 7 sur Windows XP SP3   2   IE 8 sur Windows XP SP3   3   IE 7 sur Windows Vista   4   IE 8 sur Windows Vista   5   IE 8 sur Windows 7   6   IE 9 sur Windows 7  Vérification supportée :   Non  Options de base :   Nom        Paramètre Actuel  Requis  Description   ----       ---------------  --------  -----------   OBFUSCATE  false            non       Activer l'obfuscation JavaScript   SRVHOST    0.0.0.0          oui       L'hôte local sur lequel écouter. Ce doit être une adresse sur la machine locale ou 0.0.0.0   SRVPORT    8080             oui       Le port local sur lequel écouter.   SSL        false            non       Négocier SSL pour les connexions entrantes   SSLCert                     non       Chemin vers un certificat SSL personnalisé (par défaut, généré aléatoirement)   URIPATH                     non       L'URI à utiliser pour cet exploit (par défaut, aléatoire)  Informations sur le payload :  Description:   Ce module exploite une vulnérabilité trouvée dans Microsoft Internet    Explorer (MSIE). Lors du rendu d'une page HTML, l'objet CMshtmlEd    est supprimé de manière inattendue, mais la même mémoire est réutilisée    plus tard dans la fonction CMshtmlEd::Exec(), ce qui conduit à une    condition de type use-after-free. Veuillez noter que cette vulnérabilité    est exploitée depuis le 14 septembre 2012. Notez également    qu'actuellement, ce module a des dépendances de cible pour que la    chaîne ROP soit valide. Pour WinXP SP3 avec IE8, msvcrt doit être    présent (comme c'est le cas par défaut). Pour Vista ou Win7 avec IE8,    ou Win7 avec IE9, JRE 1.6.x ou une version inférieure doit être    installé (ce qui est souvent le cas).  Références :   https://cvedetails.com/cve/CVE-2012-4969/   OSVDB (85532)   https://docs.microsoft.com/en-us/security-updates/SecurityBulletins/2012/MS12-063   http://technet.microsoft.com/en-us/security/advisory/2757760   http://eromang.zataz.com/2012/09/16/zero-day-season-is-really-not-over-yet/`

En lisant la description, nous pouvons avoir une idée générale de ce que cet exploit nous permettra d'accomplir. En gardant cela à l'esprit, nous voudrons ensuite vérifier quelles versions sont vulnérables à cet exploit.

        shellsession
`msf6 exploit(windows/browser/ie_execcommand_uaf) > options  Options du module (exploit/windows/browser/ie_execcommand_uaf):     Nom        Paramètre Actuel  Requis  Description    ----       ---------------  --------  -----------    OBFUSCATE  false            non       Activer l'obfuscation JavaScript    SRVHOST    0.0.0.0          oui       L'hôte local sur lequel écouter. Ce doit être une adresse sur la machine locale ou 0.0.0.0    SRVPORT    8080             oui       Le port local sur lequel écouter.    SSL        false            non       Négocier SSL pour les connexions entrantes    SSLCert                     non       Chemin vers un certificat SSL personnalisé (par défaut, généré aléatoirement)    URIPATH                     non       L'URI à utiliser pour cet exploit (par défaut, aléatoire)   Cible de l'exploit :     Id  Nom    --  ----    0   Automatique   msf6 exploit(windows/browser/ie_execcommand_uaf) > show targets  Cibles de l'exploit :     Id  Nom    --  ----    0   Automatique    1   IE 7 sur Windows XP SP3    2   IE 8 sur Windows XP SP3    3   IE 7 sur Windows Vista    4   IE 8 sur Windows Vista    5   IE 8 sur Windows 7    6   IE 9 sur Windows 7`

Nous voyons des options pour différentes versions d'Internet Explorer et diverses versions de Windows. Laisser la sélection sur `Automatique` indiquera à msfconsole qu'il doit effectuer une détection de service sur la cible donnée avant de lancer une attaque réussie.

Cependant, si nous connaissons les versions qui s'exécutent sur notre cible, nous pouvons utiliser la commande `set target <index no.>` pour choisir une cible dans la liste.

        shellsession
`msf6 exploit(windows/browser/ie_execcommand_uaf) > show targets  Cibles de l'exploit :     Id  Nom    --  ----    0   Automatique    1   IE 7 sur Windows XP SP3    2   IE 8 sur Windows XP SP3    3   IE 7 sur Windows Vista    4   IE 8 sur Windows Vista    5   IE 8 sur Windows 7    6   IE 9 sur Windows 7   msf6 exploit(windows/browser/ie_execcommand_uaf) > set target 6  target => 6`

---

## Types de Cibles

Il existe une grande variété de types de cibles. Chaque cible peut varier d'une autre par son service pack, sa version de système d'exploitation, et même sa version linguistique. Tout dépend de l'adresse de retour et d'autres paramètres dans la cible ou dans le module d'exploitation.

L'adresse de retour peut varier parce qu'un pack de langue particulier modifie les adresses, qu'une version de logiciel différente est disponible, ou que les adresses sont décalées en raison de hooks. Tout est déterminé par le type d'adresse de retour requis pour identifier la cible. Cette adresse peut être `jmp esp`, un saut vers un registre spécifique qui identifie la cible, ou un `pop/pop/ret`. Pour en savoir plus sur le sujet des adresses de retour, consultez le module [Dépassements de tampon basés sur la pile (Stack-Based Buffer Overflows) sur Windows x86](https://academy.hackthebox.com/module/89/section/931). Les commentaires dans le code du module d'exploitation peuvent nous aider à déterminer par quoi la cible est définie.

Pour identifier correctement une cible, nous devrons :

- Obtenir une copie des binaires de la cible
- Utiliser msfpescan pour localiser une adresse de retour appropriée

Plus tard dans le module, nous approfondirons le développement d'exploits, la génération de payloads (charges utiles), et l'identification de cibles.