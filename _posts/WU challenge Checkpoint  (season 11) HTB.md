
![[Pasted image 20260803135725.png]]

au début on a des informations de connexions  : alex.turner / Checkpoint2024!

le scan nmap donne : 

![[Pasted image 20260808181014.png]]
on a assez de services qui  pourraient constituer une surface d'attaque mais il faut savoir filtrer ceux si

Une question à se poser pourquoi on m'a donné des credentials d'un utilisateurs juste comme sa : 
surement un service lancé à besoin de ces crédential d'aunth  , essayons de chercher les services Windows / AD qui ont besoins d'aunth  

Les principaux services Windows et composants Active Directory nécessitant une authentification se répartissent ainsi :

### 1. Les services de partage et d'infrastructure de fichiers

- **SMB (Server Message Block) :** Utilisé pour l'accès aux dossiers partagés en réseau. Chaque utilisateur ou machine doit s'authentifier pour que Windows applique les listes de contrôle d'accès (ACL NTFS et partagées).
    
- **Print Spooler (Service Spouleur d'impression) :** L'envoi de documents à une imprimante réseau ou l'administration des files d'attente à distance exige une authentification auprès du serveur d'impression.
    
- **DFS-R / DFS-N (Distributed File System) :** La réplication des fichiers entre serveurs et l'accès aux espaces de noms distribués nécessitent des accréditations de domaine valides.
    

### 2. Les services d'administration et de gestion à distance

- **WinRM (Windows Remote Management / PowerShell Remoting) :** Exige une authentification stricte (Kerberos, Negotiate ou CredSSP) pour exécuter des scripts ou des commandes d'administration à distance.
    
- **RDP avec NLA (Remote Desktop Services / Network Level Authentication) :** Force l'authentification de l'utilisateur **avant** même que l'écran de connexion du bureau à distance ne s'affiche, ce qui protège efficacement contre les attaques par force brute et par déni de service.
    
- **RPC / DCOM (Remote Procedure Call) :** Utilisé par la majorité des consoles de gestion Windows (MMC, Gestionnaire de serveur). Il requiert un niveau d'authentification et de chiffrement pour autoriser la communication inter-processus à travers le réseau.
    
- **Task Scheduler (Planificateur de tâches distant) :** La programmation ou l'exécution de tâches sur un serveur distant nécessite des droits d'authentification explicites.
    

### 3. Les services Web et d'application (rôles Windows)

- **IIS (Internet Information Services) - Authentification Windows :** Lorsqu'il héberge des applications d'entreprise (intranet, plateformes collaboratives), IIS s'appuie sur l'AD pour valider l'identité des utilisateurs via l'authentification intégrée Windows (Negotiate / Kerberos ou NTLM).
    
- **AD CS (Active Directory Certificate Services) :** L'enrôlement, la demande et le renouvellement de certificats numériques exigent que le demandeur (machine ou utilisateur) s'authentifie auprès de l'autorité de certification.
    

### 4. Les services fondamentaux de l'annuaire Active Directory

- **Kerberos KDC (Key Distribution Center) :** Le service de référence des contrôleurs de domaine qui délivre les tickets d'accès (TGT/TGS) après vérification des identités.
    
- **LDAP / LDAPS :** Les requêtes d'interrogation et de modification de l'annuaire (les liaisons ou _binds_) nécessitent une authentification pour empêcher la lecture des données sensibles de l'entreprise.
    
- **SYSVOL et NETLOGON :** Ces partages système situés sur les contrôleurs de domaine contiennent les stratégies de groupe (GPO) et les scripts de connexion. Ils exigent une authentification immédiate de chaque machine et utilisateur au démarrage et à l'ouverture de session.

**Les services qu'on peut cibler**

### 1. Services d'authentification et d'annuaire (Core AD)

- **Port 88/tcp (Kerberos-sec) :** Le service KDC (Key Distribution Center) indispensable pour l'émission des tickets d'authentification (TGT/TGS).
    
- **Port 464/tcp (Kpasswd5) :** Le service de changement de mot de passe Kerberos, qui exige une authentification préalable.
    
- **Port 389/tcp et 636/tcp (LDAP / LDAPS) :** L'annuaire Active Directory. Les liaisons (_binds_) authentifiées y sont requises pour interroger ou modifier l'arborescence de manière sécurisée.
    
- **Port 3268/tcp et 3269/tcp (Global Catalog / GC SSL) :** Le catalogue global de l'AD, qui exige également une authentification pour effectuer des recherches à l'échelle de la forêt.
    

### 2. Services de partage et d'infrastructure

- **Port 445/tcp (Microsoft-DS / SMB) et 139/tcp (NetBIOS) :** Les services de partage de fichiers (utilisés notamment pour accéder à `SYSVOL` et `NETLOGON` sur ce contrôleur de domaine). L'authentification y est obligatoire pour récupérer les stratégies de groupe (GPO) et accéder aux ressources.
    
- **Port 53/tcp (DNS - Simple DNS Plus) :** Le service de résolution de noms, qui gère les enregistrements du domaine et s'appuie sur des mécanismes d'authentification pour les mises à jour dynamiques sécurisées.
    

### 3. Services d'administration et de gestion à distance

- **Port 135/tcp (MSRPC) et 593/tcp (RPC over HTTP) :** Les services d'appels de procédures distantes, essentiels pour l'administration des contrôleurs de domaine, qui requièrent une authentification stricte.
    
- **Port 5985/tcp (WinRM / Microsoft HTTPAPI) :** Utilisé pour le PowerShell Remoting et la gestion à distance, nécessitant une authentification (Kerberos / Negotiate / CredSSP).


**Recherche de surface d'attaque**

maintenant quels sont les services qui peuvent nous reveler des info sensbles

Dans un environnement Active Directory (et en se basant sur les services typiques visibles sur votre scan de contrôleur de domaine), certains services sont particulièrement bavards et peuvent être interrogés (parfois même avec un simple compte à bas privilèges ou de manière anonyme selon le niveau de durcissement) pour **énumérer et cartographier** les informations sensibles du réseau.

Les principaux services qui révèlent ces informations se répartissent ainsi :

### 1. LDAP / LDAPS et Global Catalog (Ports 389, 636, 3268, 3269)

C'est la source d'information la plus riche de l'Active Directory.

- **Informations révélées :** La liste exhaustive des utilisateurs, des groupes, des machines, des appartenances, des descriptions de postes, des politiques de mots de passe, et parfois des attributs sensibles (comme des commentaires laissés dans les profils ou des configurations de services).
    
- **Usage offensif / d'audit :** Des outils comme **BloodHound** ou `ldapsearch` s'y connectent pour cartographier l'intégralité des chemins d'attaque et des privilèges au sein du domaine.
    

### 2. DNS (Port 53)

Le service de résolution de noms de l'Active Directory.

- **Informations révélées :** La structure interne du réseau, l'emplacement exact des contrôleurs de domaine (via les enregistrements SRV), la liste des serveurs, des applications hébergées et des postes clients reliés au domaine.
    
- **Usage offensif / d'audit :** Permet de découvrir des sous-domaines ou des machines oubliées (tests de pénétration internes).
    

### 3. SMB et RPC / MSRPC (Ports 445, 135, 139, 593)

Les protocoles de partage et d'appels de procédures distantes de Windows.

- **Informations révélées :**
    
    - Les partages réseau disponibles (et leurs permissions ACL).
        
    - L'énumération des comptes utilisateurs et des groupes locaux/du domaine via les interfaces **SAMR** (Security Account Manager Remote) ou **LSA** (Local Security Authority).
        
- **Usage offensif / d'audit :** Des outils comme `enum4linux` ou `rpcdump` permettent d'extraire la liste des utilisateurs et des politiques de sécurité du système.
    

### 4. Kerberos (Port 88)

Le service d'authentification principal.

- **Informations révélées :**
    
    - **Énumération d'utilisateurs :** En envoyant des requêtes au KDC, il est parfois possible de deviner si un nom d'utilisateur existe ou non selon le code d'erreur renvoyé.
        
    - **AS-REP Roasting :** Si certains comptes utilisateurs ont l'option _"Ne requiert pas de pré-authentification Kerberos"_ activée, le service renvoie un ticket qu'il est possible de tenter de craquer hors ligne pour retrouver le mot de passe.


On va essayer de mapper les différent informations lié à notre controleur de domaine en utilisant bloodhound

Étape 1 : trouver le nom de domaine 

```bash
nmap -p 389 -sV --script "ldap-rootdse" IP_CIBLE
```

mais nous on avai déja fait un scan de la machine concerner et on a pu avoir u  nom de domaine 
```nmap
nmap -p 389 -sV --script "ldap-rootdse" 10.129.82.191 -Pn                                            master  ✱  
Starting Nmap 7.95 ( https://nmap.org ) at 2026-08-08 19:22 GMT  
Nmap scan report for 10.129.82.191  
Host is up (0.61s latency).  
  
PORT    STATE SERVICE VERSION  
389/tcp open  ldap    Microsoft Windows Active Directory LDAP (Domain: checkpoint.htb, Site: Default-First-Site-Nam  
e)  
| ldap-rootdse:  
| LDAP Results  
|   <ROOT>  
|       domainFunctionality: 10  
|       forestFunctionality: 10  
|       domainControllerFunctionality: 10  
|       rootDomainNamingContext: DC=checkpoint,DC=htb  
|       ldapServiceName: checkpoint.htb:dc01$@CHECKPOINT.HTB  
|       isGlobalCatalogReady: TRUE  
|       supportedSASLMechanisms: GSSAPI  
|       supportedSASLMechanisms: GSS-SPNEGO  
|       supportedSASLMechanisms: EXTERNAL  
|       supportedSASLMechanisms: DIGEST-MD5  
|       supportedLDAPVersion: 3  
|       supportedLDAPVersion: 2  
|       supportedLDAPPolicies: MaxPoolThreads  
|       supportedLDAPPolicies: MaxPercentDirSyncRequests  
|       supportedLDAPPolicies: MaxDatagramRecv  
|       supportedLDAPPolicies: MaxReceiveBuffer  
|       supportedLDAPPolicies: MaxPreAuthReceiveBuffer  
|       supportedLDAPPolicies: InitRecvTimeout  
|       supportedLDAPPolicies: MaxConnections  
|       supportedLDAPPolicies: MaxConnIdleTime  
|       supportedLDAPPolicies: MaxPageSize  
|       supportedLDAPPolicies: MaxBatchReturnMessages  
|       supportedLDAPPolicies: MaxQueryDuration  
|       supportedLDAPPolicies: MaxDirSyncDuration  
|       supportedLDAPPolicies: MaxTempTableSize  
|       supportedLDAPPolicies: MaxResultSetSize  
|       supportedLDAPPolicies: MinResultSets  
|       supportedLDAPPolicies: MaxResultSetsPerConn  
|       supportedLDAPPolicies: MaxNotificationPerConn  
|       supportedLDAPPolicies: MaxValRange  
|       supportedLDAPPolicies: MaxValRangeTransitive  
|       supportedLDAPPolicies: ThreadMemoryLimit  
|       supportedLDAPPolicies: SystemMemoryLimitPercent  
|       supportedLDAPPolicies: SecurityDescriptorWarningSize  
|       supportedControl: 1.2.840.113556.1.4.319  
|       supportedControl: 1.2.840.113556.1.4.801  
|       supportedControl: 1.2.840.113556.1.4.473  
|       supportedControl: 1.2.840.113556.1.4.528  
|       supportedControl: 1.2.840.113556.1.4.417  
|       supportedControl: 1.2.840.113556.1.4.619  
|       supportedControl: 1.2.840.113556.1.4.841  
|       supportedControl: 1.2.840.113556.1.4.529  
|       supportedControl: 1.2.840.113556.1.4.805  
|       supportedControl: 1.2.840.113556.1.4.521  
|       supportedControl: 1.2.840.113556.1.4.970  
|       supportedControl: 1.2.840.113556.1.4.1338  
|       supportedControl: 1.2.840.113556.1.4.474  
|       supportedControl: 1.2.840.113556.1.4.1339  
|       supportedControl: 1.2.840.113556.1.4.1340  
|       supportedControl: 1.2.840.113556.1.4.1413  
|       supportedControl: 2.16.840.1.113730.3.4.9  
|       supportedControl: 2.16.840.1.113730.3.4.10  
|       supportedControl: 1.2.840.113556.1.4.1504  
|       supportedControl: 1.2.840.113556.1.4.1852  
|       supportedControl: 1.2.840.113556.1.4.802  
|       supportedControl: 1.2.840.113556.1.4.1907  
|       supportedControl: 1.2.840.113556.1.4.1948  
|       supportedControl: 1.2.840.113556.1.4.1974  
|       supportedControl: 1.2.840.113556.1.4.1341  
|       supportedControl: 1.2.840.113556.1.4.2026  
|       supportedControl: 1.2.840.113556.1.4.2064  
|       supportedControl: 1.2.840.113556.1.4.2065  
|       supportedControl: 1.2.840.113556.1.4.2066  
|       supportedControl: 1.2.840.113556.1.4.2090  
|       supportedControl: 1.2.840.113556.1.4.2205  
|       supportedControl: 1.2.840.113556.1.4.2204  
|       supportedControl: 1.2.840.113556.1.4.2206  
|       supportedControl: 1.2.840.113556.1.4.2211  
|       supportedControl: 1.2.840.113556.1.4.2239  
|       supportedControl: 1.2.840.113556.1.4.2255  
|       supportedControl: 1.2.840.113556.1.4.2256  
|       supportedControl: 1.2.840.113556.1.4.2309  
|       supportedControl: 1.2.840.113556.1.4.2330  
|       supportedControl: 1.2.840.113556.1.4.2354  
|       supportedCapabilities: 1.2.840.113556.1.4.800  
|       supportedCapabilities: 1.2.840.113556.1.4.1670  
|       supportedCapabilities: 1.2.840.113556.1.4.1791  
|       supportedCapabilities: 1.2.840.113556.1.4.1935  
|       supportedCapabilities: 1.2.840.113556.1.4.2080  
|       supportedCapabilities: 1.2.840.113556.1.4.2237  
|       subschemaSubentry: CN=Aggregate,CN=Schema,CN=Configuration,DC=checkpoint,DC=htb  
|       serverName: CN=DC01,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=checkpoint,DC=htb  
|       schemaNamingContext: CN=Schema,CN=Configuration,DC=checkpoint,DC=htb  
|       namingContexts: DC=checkpoint,DC=htb  
|       namingContexts: CN=Configuration,DC=checkpoint,DC=htb  
|       namingContexts: CN=Schema,CN=Configuration,DC=checkpoint,DC=htb  
|       namingContexts: DC=DomainDnsZones,DC=checkpoint,DC=htb  
|       namingContexts: DC=ForestDnsZones,DC=checkpoint,DC=htb  
|       isSynchronized: TRUE  
|       highestCommittedUSN: 151668  
|       dsServiceName: CN=NTDS Settings,CN=DC01,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=  
checkpoint,DC=htb  
|       dnsHostName: DC01.checkpoint.htb  
|       defaultNamingContext: DC=checkpoint,DC=htb  
|       currentTime: 20260809022215.0Z  
|_      configurationNamingContext: CN=Configuration,DC=checkpoint,DC=htb  
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows  
  
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .  
Nmap done: 1 IP address (1 host up) scanned in 9.05 seconds
```
au nivau du root domain on a le nom de domaine du DC qui est : checkpoint.htb en plus de ces info
- **Domaine** : `checkpoint.htb`
- **Nom du DC** : `DC01.checkpoint.htb`
- **IP** : `10.129.82.191`



**Étape 2 : lancer la collecte d'information.**

```bash
nxc ldap $IP -u 'alex.turner' -p 'Checkpoint2024!' --users
```

pour l'énumération des utilisateurs  

```bash
nxc ldap $ip -u $user -p $password --active-users
```
pour l'énumération des utilisateurs  actifs 

![[Pasted image 20260809074504.png]]

# Enumerate Domain Groups

```bash
nxc ldap <ip> -u <username> -p <password> --groups
```

![[Pasted image 20260809075748.png]]

on va essayer de cibler les utilisateur  qui sont dans des groupes critiques  encadré en rouge 

- **Administrators**
- **Users**
- **Guests**
- **Remote Management Users**
- **Domain Admins**
- **BackupAccess**
- **IT-Staff**
- **Domain Admins**

```bash
nxc ldap <ip> -u <username> -p <password> --groups "Domain Admins"
```
![[Pasted image 20260809081000.png]]

Résultat de l'énum 

- **Administrator** (membre des groupes _Administrators_ et _Domain Admins_)
    
- **max.palmer** (membre du groupe _Domain Admins_)
    
- **svc_deploy** (membre des groupes _Remote Management Users_ et _BackupAccess_)
    
- **alex.turner** (membre du groupe _IT-Staff_ et compte utilisé pour exécuter la commande)
    
- **james.harper** (membre du groupe _IT-Staff_)
    
- **sarah.mitchell** (membre du groupe _IT-Staff_)
    
- **Guest** (membre du groupe _Guests_)
