Le `système de fichiers réseau` (`Network File System` ou `NFS`) est un système de fichiers réseau développé par Sun Microsystems et a le même objectif que SMB. Son but est d'accéder à des systèmes de fichiers sur un réseau comme s'ils étaient locaux. Cependant, il utilise un protocole entièrement différent. [NFS](https://en.wikipedia.org/wiki/Network_File_System) est utilisé entre les systèmes Linux et Unix. Cela signifie que les clients NFS ne peuvent pas communiquer directement avec les serveurs SMB. NFS est un standard Internet qui régit les procédures dans un système de fichiers distribué. Alors que la version 3.0 du protocole NFS (`NFSv3`), utilisée depuis de nombreuses années, authentifie l'ordinateur client, cela change avec `NFSv4`. Ici, comme avec le protocole SMB de Windows, l'utilisateur doit s'authentifier.

|**Version**|**Caractéristiques**|
|---|---|
|`NFSv2`|Plus ancienne, cette version est prise en charge par de nombreux systèmes et fonctionnait initialement entièrement sur UDP.|
|`NFSv3`|Elle dispose de plus de fonctionnalités, notamment une taille de fichier variable et un meilleur rapport d'erreurs, mais n'est pas entièrement compatible avec les clients NFSv2.|
|`NFSv4`|Elle inclut Kerberos, fonctionne à travers les pare-feux et sur Internet, ne nécessite plus de portmappers, prend en charge les listes de contrôle d'accès (ACL), applique des opérations basées sur l'état, et offre des améliorations de performance ainsi qu'une sécurité élevée. C'est également la première version à disposer d'un protocole à état (stateful protocol).|

La version 4.1 de NFS ([RFC 8881](https://datatracker.ietf.org/doc/html/rfc8881)) vise à fournir un support protocolaire pour tirer parti des déploiements de serveurs en cluster, y compris la capacité de fournir un accès parallèle évolutif aux fichiers distribués sur plusieurs serveurs (extension pNFS). De plus, NFSv4.1 inclut un mécanisme de `session trunking`, également connu sous le nom de `NFS multipathing`. Un avantage significatif de NFSv4 par rapport à ses prédécesseurs est qu'un seul port UDP ou TCP `2049` est utilisé pour exécuter le service, ce qui simplifie l'utilisation du protocole à travers les pare-feux.

NFS est basé sur le protocole [Appel de procédure à distance Open Network Computing](https://en.wikipedia.org/wiki/Sun_RPC) (`Open Network Computing Remote Procedure Call` ou `ONC-RPC`/`SUN-RPC`) exposé sur les ports `TCP` et `UDP` `111`, qui utilise la [Représentation externe des données](https://en.wikipedia.org/wiki/External_Data_Representation) (`External Data Representation` ou `XDR`) pour l'échange de données indépendant du système. Le protocole NFS n'a `aucun` mécanisme d'`authentification` ou d'`autorisation`. Au lieu de cela, l'authentification est entièrement reportée sur les options du protocole RPC. L'autorisation est dérivée des informations disponibles sur le système de fichiers. Dans ce processus, le serveur est responsable de la traduction des informations de l'utilisateur client dans le format du système de fichiers et de la conversion des détails d'autorisation correspondants dans la syntaxe UNIX requise aussi précisément que possible.

L'authentification la plus courante se fait via les `UID`/`GID` UNIX et les `appartenances aux groupes`, c'est pourquoi cette syntaxe est la plus susceptible d'être appliquée au protocole NFS. Un problème est que le client et le serveur n'ont pas nécessairement les mêmes correspondances d'UID/GID avec les utilisateurs et les groupes, et le serveur n'a rien de plus à faire. Aucune vérification supplémentaire ne peut être effectuée de la part du serveur. C'est pourquoi NFS ne devrait être utilisé avec cette méthode d'authentification que dans des réseaux de confiance.

---

## Configuration par défaut

NFS n'est pas difficile à configurer car il n'y a pas autant d'options que pour FTP ou SMB. Le fichier `/etc/exports` contient une table des systèmes de fichiers physiques sur un serveur NFS accessibles par les clients. La [Table des partages NFS (NFS Exports Table)](http://manpages.ubuntu.com/manpages/trusty/man5/exports.5.html) montre quelles options elle accepte et indique ainsi quelles options sont à notre disposition.

#### Fichier Exports

        shellsession
`ppporrkkky@htb[/htb]$ cat /etc/exports   # /etc/exports : la liste de contrôle d'accès pour les systèmes de fichiers qui peuvent être exportés #                vers des clients NFS. Voir exports(5). # # Exemple pour NFSv2 et NFSv3 : # /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check) # # Exemple pour NFSv4 : # /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check) # /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)`

Le fichier `exports` par défaut contient également quelques exemples de configuration de partages NFS. D'abord, le dossier est spécifié et mis à la disposition des autres, puis les droits qu'ils auront sur ce partage NFS sont liés à un hôte ou à un sous-réseau. Enfin, des options supplémentaires peuvent être ajoutées aux hôtes ou aux sous-réseaux.

|**Option**|**Description**|
|---|---|
|`rw`|Permissions de lecture et d'écriture.|
|`ro`|Permissions de lecture seule.|
|`sync`|Transfert de données synchrone. (Un peu plus lent)|
|`async`|Transfert de données asynchrone. (Un peu plus rapide)|
|`secure`|Les ports supérieurs à 1024 ne seront pas utilisés.|
|`insecure`|Les ports supérieurs à 1024 seront utilisés.|
|`no_subtree_check`|Cette option désactive la vérification des arborescences de sous-répertoires.|
|`root_squash`|Attribue toutes les permissions des fichiers de l'UID/GID 0 de root à l'UID/GID de l'utilisateur anonyme, ce qui empêche `root` d'accéder aux fichiers sur un montage NFS.|

Créons une telle entrée à des fins de test et jouons avec les paramètres.

#### ExportFS

        shellsession
`root@nfs:~# echo '/mnt/nfs  10.129.14.0/24(sync,no_subtree_check)' >> /etc/exports root@nfs:~# systemctl restart nfs-kernel-server  root@nfs:~# exportfs  /mnt/nfs        10.129.14.0/24`

Nous avons partagé le dossier `/mnt/nfs` avec le sous-réseau `10.129.14.0/24` avec les paramètres indiqués ci-dessus. Cela signifie que tous les hôtes du réseau pourront monter ce partage NFS et inspecter le contenu de ce dossier.

---

## Paramètres dangereux

Cependant, même avec NFS, certains paramètres peuvent être dangereux pour l'entreprise et son infrastructure. En voici quelques-uns :

|**Option**|**Description**|
|---|---|
|`rw`|Permissions de lecture et d'écriture.|
|`insecure`|Les ports supérieurs à 1024 seront utilisés.|
|`nohide`|Si un autre système de fichiers est monté sous un répertoire exporté, ce répertoire est exporté par sa propre entrée d'exportation.|
|`no_root_squash`|Tous les fichiers créés par root sont conservés avec l'UID/GID 0.|

Il est fortement recommandé de créer une VM locale et d'expérimenter avec les paramètres. Nous découvrirons des méthodes qui nous montreront comment le serveur NFS est configuré. Pour cela, nous pouvons créer plusieurs dossiers et attribuer différentes options à chacun d'eux. Ensuite, nous pourrons les inspecter et voir quel effet les paramètres peuvent avoir sur le partage NFS, ses permissions et le processus d'énumération.

Nous pouvons examiner l'option `insecure`. Elle est dangereuse car les utilisateurs peuvent utiliser des ports supérieurs à 1024. Les 1024 premiers ports ne peuvent être utilisés que par root. Cela empêche le fait qu'aucun utilisateur ne puisse utiliser des sockets au-dessus du port 1024 pour le service NFS et interagir avec lui.

---

## Prise d'empreinte du service

Lors de la prise d'empreinte (`footprinting`) de NFS, les ports TCP `111` et `2049` sont essentiels. Nous pouvons également obtenir des informations sur le service NFS et l'hôte via RPC, comme le montre l'exemple ci-dessous.

#### Nmap

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap 10.129.14.128 -p111,2049 -sV -sC  Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-19 17:12 CEST Nmap scan report for 10.129.14.128 Host is up (0.00018s latency).  PORT    STATE SERVICE VERSION 111/tcp open  rpcbind 2-4 (RPC #100000) | rpcinfo:  |   program version    port/proto  service |   100000  2,3,4        111/tcp   rpcbind |   100000  2,3,4        111/udp   rpcbind |   100000  3,4          111/tcp6  rpcbind |   100000  3,4          111/udp6  rpcbind |   100003  3           2049/udp   nfs |   100003  3           2049/udp6  nfs |   100003  3,4         2049/tcp   nfs |   100003  3,4         2049/tcp6  nfs |   100005  1,2,3      41982/udp6  mountd |   100005  1,2,3      45837/tcp   mountd |   100005  1,2,3      47217/tcp6  mountd |   100005  1,2,3      58830/udp   mountd |   100021  1,3,4      39542/udp   nlockmgr |   100021  1,3,4      44629/tcp   nlockmgr |   100021  1,3,4      45273/tcp6  nlockmgr |   100021  1,3,4      47524/udp6  nlockmgr |   100227  3           2049/tcp   nfs_acl |   100227  3           2049/tcp6  nfs_acl |   100227  3           2049/udp   nfs_acl |_  100227  3           2049/udp6  nfs_acl 2049/tcp open  nfs_acl 3 (RPC #100227) MAC Address: 00:00:00:00:00:00 (VMware)  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 6.58 seconds`

Le script NSE `rpcinfo` récupère une liste de tous les services RPC en cours d'exécution, leurs noms et descriptions, ainsi que les ports qu'ils utilisent. Cela nous permet de vérifier si le partage cible est connecté au réseau sur tous les ports requis. De plus, pour NFS, Nmap dispose de quelques scripts NSE qui peuvent être utilisés pour les scans. Ceux-ci peuvent alors nous montrer, par exemple, le `contenu` du partage et ses `statistiques`.

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap --script nfs* 10.129.14.128 -sV -p111,2049  Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-19 17:37 CEST Nmap scan report for 10.129.14.128 Host is up (0.00021s latency).  PORT     STATE SERVICE VERSION 111/tcp  open  rpcbind 2-4 (RPC #100000) | nfs-ls: Volume /mnt/nfs |   access: Read Lookup NoModify NoExtend NoDelete NoExecute | PERMISSION  UID    GID    SIZE  TIME                 FILENAME | rwxrwxrwx   65534  65534  4096  2021-09-19T15:28:17  . | ??????????  ?      ?      ?     ?                    .. | rw-r--r--   0      0      1872  2021-09-19T15:27:42  id_rsa | rw-r--r--   0      0      348   2021-09-19T15:28:17  id_rsa.pub | rw-r--r--   0      0      0     2021-09-19T15:22:30  nfs.share |_ | nfs-showmount:  |_  /mnt/nfs 10.129.14.0/24 | nfs-statfs:  |   Filesystem  1K-blocks   Used       Available   Use%  Maxfilesize  Maxlink |_  /mnt/nfs    30313412.0  8074868.0  20675664.0  29%   16.0T        32000 | rpcinfo:  |   program version    port/proto  service |   100000  2,3,4        111/tcp   rpcbind |   100000  2,3,4        111/udp   rpcbind |   100000  3,4          111/tcp6  rpcbind |   100000  3,4          111/udp6  rpcbind |   100003  3           2049/udp   nfs |   100003  3           2049/udp6  nfs |   100003  3,4         2049/tcp   nfs |   100003  3,4         2049/tcp6  nfs |   100005  1,2,3      41982/udp6  mountd |   100005  1,2,3      45837/tcp   mountd |   100005  1,2,3      47217/tcp6  mountd |   100005  1,2,3      58830/udp   mountd |   100021  1,3,4      39542/udp   nlockmgr |   100021  1,3,4      44629/tcp   nlockmgr |   100021  1,3,4      45273/tcp6  nlockmgr |   100021  1,3,4      47524/udp6  nlockmgr |   100227  3           2049/tcp   nfs_acl |   100227  3           2049/tcp6  nfs_acl |   100227  3           2049/udp   nfs_acl |_  100227  3           2049/udp6  nfs_acl 2049/tcp open  nfs_acl 3 (RPC #100227) MAC Address: 00:00:00:00:00:00 (VMware)  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 0.45 seconds`

Une fois que nous avons découvert un tel service NFS, nous pouvons le monter sur notre machine locale. Pour cela, nous pouvons créer un nouveau dossier vide sur lequel le partage NFS sera monté. Une fois monté, nous pouvons y naviguer et visualiser son contenu comme s'il s'agissait de notre système local.

#### Afficher les partages NFS disponibles

        shellsession
`ppporrkkky@htb[/htb]$ showmount -e 10.129.14.128  Export list for 10.129.14.128: /mnt/nfs 10.129.14.0/24`

#### Montage du partage NFS

        shellsession
`ppporrkkky@htb[/htb]$ mkdir target-NFS ppporrkkky@htb[/htb]$ sudo mount -t nfs 10.129.14.128:/ ./target-NFS/ -o nolock ppporrkkky@htb[/htb]$ cd target-NFS ppporrkkky@htb[/htb]$ tree .  . └── mnt     └── nfs         ├── id_rsa         ├── id_rsa.pub         └── nfs.share  2 directories, 3 files`

Là, nous aurons la possibilité d'accéder aux droits et aux noms d'utilisateurs et de groupes auxquels appartiennent les fichiers affichés et consultables. Car une fois que nous avons les noms d'utilisateurs, les noms de groupes, les UID et les GUID, nous pouvons les créer sur notre système et les adapter au partage NFS pour visualiser et modifier les fichiers.

#### Lister le contenu avec les noms d'utilisateur et de groupe

        shellsession
`ppporrkkky@htb[/htb]$ ls -l mnt/nfs/  total 16 -rw-r--r-- 1 cry0l1t3 cry0l1t3 1872 Sep 25 00:55 cry0l1t3.priv -rw-r--r-- 1 cry0l1t3 cry0l1t3  348 Sep 25 00:55 cry0l1t3.pub -rw-r--r-- 1 root     root     1872 Sep 19 17:27 id_rsa -rw-r--r-- 1 root     root      348 Sep 19 17:28 id_rsa.pub -rw-r--r-- 1 root     root        0 Sep 19 17:22 nfs.share`

#### Lister le contenu avec les UID et les GUID

        shellsession
`ppporrkkky@htb[/htb]$ ls -n mnt/nfs/  total 16 -rw-r--r-- 1 1000 1000 1872 Sep 25 00:55 cry0l1t3.priv -rw-r--r-- 1 1000 1000  348 Sep 25 00:55 cry0l1t3.pub -rw-r--r-- 1    0 1000 1221 Sep 19 18:21 backup.sh -rw-r--r-- 1    0    0 1872 Sep 19 17:27 id_rsa -rw-r--r-- 1    0    0  348 Sep 19 17:28 id_rsa.pub -rw-r--r-- 1    0    0    0 Sep 19 17:22 nfs.share`

Il est important de noter que si l'option `root_squash` est activée, nous ne pouvons pas modifier le fichier `backup.sh` même en tant que `root`.

Nous pouvons également utiliser NFS pour une élévation de privilèges ultérieure. Par exemple, si nous avons accès au système via SSH et que nous voulons lire des fichiers d'un autre dossier qu'un utilisateur spécifique peut lire, nous devrions téléverser un shell sur le partage NFS qui a le `SUID` de cet utilisateur, puis exécuter le shell via l'utilisateur SSH.

Après avoir effectué toutes les étapes nécessaires et obtenu les informations dont nous avons besoin, nous pouvons démonter le partage NFS.

#### Démontage

        shellsession
`ppporrkkky@htb[/htb]$ cd .. ppporrkkky@htb[/htb]$ sudo umount ./target-NFS`