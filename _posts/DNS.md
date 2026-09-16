
# DNS

---

Le `Système de Noms de Domaine` (`DNS`, pour `Domain Name System`) est une partie intégrante d'Internet. Par exemple, grâce aux noms de domaine, tels que [academy.hackthebox.com](https://academy.hackthebox.com) ou [www.hackthebox.com](https://www.hackthebox.com), nous pouvons atteindre les serveurs web auxquels le fournisseur d'hébergement a attribué une ou plusieurs adresses IP spécifiques. Le DNS est un système permettant de résoudre les noms d'ordinateurs en adresses IP, et il ne dispose pas d'une base de données centrale. De manière simplifiée, on peut l'imaginer comme une bibliothèque avec de nombreux annuaires téléphoniques différents. L'information est répartie sur plusieurs milliers de serveurs de noms. Des serveurs DNS répartis dans le monde entier traduisent les noms de domaine en adresses IP et contrôlent ainsi quel serveur un utilisateur peut atteindre via un domaine particulier. Il existe plusieurs types de serveurs DNS utilisés dans le monde :

- Serveur racine DNS
- Serveur de noms faisant autorité
- Serveur de noms ne faisant pas autorité
- Serveur de mise en cache
- Serveur de redirection
- Résolveur

|**Type de serveur**|**Description**|
|---|---|
|`Serveur Racine DNS`|Les serveurs racines du DNS sont responsables des `domaines de premier niveau` (`TLD`, pour `Top-Level Domains`). En tant que dernière instance, ils ne sont sollicités que si le serveur de noms ne répond pas. Ainsi, un serveur racine est une interface centrale entre les utilisateurs et le contenu sur Internet, car il relie le domaine et l'adresse IP. L'[Internet Corporation for Assigned Names and Numbers](https://www.icann.org/) (`ICANN`) coordonne le travail des serveurs de noms racines. Il existe `13` de ces serveurs racines à travers le globe.|
|`Serveur de Noms Faisant Autorité`|Les serveurs de noms faisant autorité détiennent l'autorité pour une zone particulière. Ils ne répondent qu'aux requêtes de leur zone de responsabilité, et leurs informations sont contraignantes. Si un serveur de noms faisant autorité ne peut pas répondre à la requête d'un client, le serveur de noms racine prend le relais à ce moment-là. En se basant sur le pays, l'entreprise, etc., les serveurs de noms faisant autorité fournissent des réponses aux serveurs de noms DNS récursifs, aidant à trouver le ou les serveurs web spécifiques.|
|`Serveur de Noms ne Faisant pas Autorité`|Les serveurs de noms ne faisant pas autorité ne sont pas responsables d'une zone DNS particulière. Au lieu de cela, ils collectent eux-mêmes des informations sur des zones DNS spécifiques, ce qui se fait à l'aide de requêtes DNS récursives ou itératives.|
|`Serveur DNS de Mise en Cache`|Les serveurs DNS de mise en cache mettent en cache les informations d'autres serveurs de noms pour une période spécifiée. Le serveur de noms faisant autorité détermine la durée de ce stockage.|
|`Serveur de Redirection`|Les serveurs de redirection n'effectuent qu'une seule fonction : ils redirigent les requêtes DNS vers un autre serveur DNS.|
|`Résolveur`|Les résolveurs ne sont pas des serveurs DNS faisant autorité, mais effectuent la résolution de noms localement dans l'ordinateur ou le routeur.|

Le DNS n'est majoritairement pas chiffré. Les appareils sur le WLAN local et les fournisseurs d'accès à Internet peuvent donc pirater et espionner les requêtes DNS. Comme cela représente un risque pour la vie privée, il existe maintenant quelques solutions pour le chiffrement DNS. Par défaut, les professionnels de la sécurité informatique appliquent ici `DNS over TLS` (`DoT`) ou `DNS over HTTPS` (`DoH`). De plus, le protocole réseau `DNSCrypt` chiffre également le trafic entre l'ordinateur et le serveur de noms.

Cependant, le DNS ne se contente pas de lier les noms d'ordinateurs et les adresses IP. Il stocke et fournit également des informations supplémentaires sur les services associés à un domaine. Une requête DNS peut donc également être utilisée, par exemple, pour déterminer quel ordinateur sert de serveur de messagerie pour le domaine en question ou comment s'appellent les serveurs de noms du domaine.

![Schéma montrant la hiérarchie des domaines : Racine, Domaines de premier niveau (TLD) comme net, org, com, dev, io ; Domaine de second niveau inlanefreight.com ; Sous-domaines dev.inlanefreight.com, www.inlanefreight.com, mail.inlanefreight.com ; Hôte WS01.dev.inlanefreight.com.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/27/tooldev-dns.png)

Différents `enregistrements DNS` sont utilisés pour les requêtes DNS, qui ont tous des tâches variées. De plus, des entrées séparées existent pour différentes fonctions puisque nous pouvons configurer des serveurs de messagerie et d'autres serveurs pour un domaine.

|**Enregistrement DNS**|**Description**|
|---|---|
|`A`|Retourne une adresse IPv4 du domaine demandé comme résultat.|
|`AAAA`|Retourne une adresse IPv6 du domaine demandé.|
|`MX`|Retourne les serveurs de messagerie responsables comme résultat.|
|`NS`|Retourne les serveurs DNS (serveurs de noms) du domaine.|
|`TXT`|Cet enregistrement peut contenir diverses informations. Ce polyvalent peut être utilisé, par ex., pour valider la Google Search Console ou valider des certificats SSL. De plus, les entrées SPF et DMARC sont définies pour valider le trafic de messagerie et le protéger du spam.|
|`CNAME`|Cet enregistrement sert d'alias pour un autre nom de domaine. Si vous voulez que le domaine [www.hackthebox.eu](http://www.hackthebox.eu) pointe vers la même IP que hackthebox.eu, vous créeriez un enregistrement A pour hackthebox.eu et un enregistrement CNAME pour [www.hackthebox.eu](http://www.hackthebox.eu).|
|`PTR`|L'enregistrement PTR fonctionne dans l'autre sens (`recherche inversée`, ou `reverse lookup`). Il convertit les adresses IP en noms de domaine valides.|
|`SOA`|Fournit des informations sur la zone DNS correspondante et l'adresse e-mail du contact administratif.|

L'enregistrement `SOA` est situé dans le fichier de zone d'un domaine et spécifie qui est responsable de l'exploitation du domaine et comment les informations DNS pour le domaine sont gérées.

        shellsession
`ppporrkkky@htb[/htb]$ dig soa www.inlanefreight.com  ; <<>> DiG 9.16.27-Debian <<>> soa www.inlanefreight.com ;; global options: +cmd ;; Got answer: ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 15876 ;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1  ;; OPT PSEUDOSECTION: ; EDNS: version: 0, flags:; udp: 512 ;; QUESTION SECTION: ;www.inlanefreight.com.         IN      SOA  ;; AUTHORITY SECTION: inlanefreight.com.      900     IN      SOA     ns-161.awsdns-20.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400  ;; Query time: 16 msec ;; SERVER: 8.8.8.8#53(8.8.8.8) ;; WHEN: Thu Jan 05 12:56:10 GMT 2023 ;; MSG SIZE  rcvd: 128`

Le point (.) est remplacé par une arobase (@) dans l'adresse e-mail. Dans cet exemple, l'adresse e-mail de l'administrateur est `awsdns-hostmaster@amazon.com`.

---

## Configuration par Défaut

Il existe de nombreux types de configuration différents pour le DNS. Par conséquent, nous ne discuterons que des plus importants pour mieux illustrer le principe de fonctionnement d'un point de vue administratif. Tous les serveurs DNS fonctionnent avec trois types de fichiers de configuration différents :

1. fichiers de configuration DNS locaux
2. fichiers de zone
3. fichiers de résolution de noms inversée

Le serveur DNS [Bind9](https://www.isc.org/bind/) est très souvent utilisé sur les distributions basées sur Linux. Son fichier de configuration local (`named.conf`) est grossièrement divisé en deux sections, d'abord la section des options pour les paramètres généraux et ensuite les entrées de zone pour les domaines individuels. Les fichiers de configuration locaux sont généralement :

- `named.conf.local`
- `named.conf.options`
- `named.conf.log`

Il contient la RFC associée où nous pouvons personnaliser le serveur selon nos besoins et la structure de notre domaine avec les zones individuelles pour différents domaines. Le fichier de configuration `named.conf` est divisé en plusieurs options qui contrôlent le comportement du serveur de noms. Une distinction est faite entre les `options globales` et les `options de zone`.

Les options globales sont générales et affectent toutes les zones. Une option de zone n'affecte que la zone à laquelle elle est assignée. Les options non listées dans named.conf ont des valeurs par défaut. Si une option est à la fois globale et spécifique à une zone, alors l'option de zone prévaut.

#### Configuration DNS Locale

        shellsession
`root@bind9:~# cat /etc/bind/named.conf.local  // // Do any local configuration here //  // Consider adding the 1918 zones here, if they are not used in your // organization //include "/etc/bind/zones.rfc1918"; zone "domain.com" {     type master;     file "/etc/bind/db.domain.com";     allow-update { key rndc-key; }; };`

Dans ce fichier, nous pouvons définir les différentes zones. Ces zones sont divisées en fichiers individuels, qui dans la plupart des cas sont principalement destinés à un seul domaine. Les exceptions sont les FAI et les serveurs DNS publics. De plus, de nombreuses options différentes étendent ou réduisent la fonctionnalité. Nous pouvons les consulter sur la [documentation](https://wiki.debian.org/Bind9) de Bind9.

Un `fichier de zone` est un fichier texte qui décrit une zone DNS avec le format de fichier BIND. En d'autres termes, c'est un point de délégation dans l'arbre DNS. Le format de fichier BIND est le format de fichier de zone préféré de l'industrie et est maintenant bien établi dans les logiciels de serveurs DNS. Un fichier de zone décrit une zone complètement. Il doit y avoir exactement un enregistrement `SOA` et au moins un enregistrement `NS`. L'enregistrement de ressource SOA est généralement situé au début d'un fichier de zone. L'objectif principal de ces règles globales est d'améliorer la lisibilité des fichiers de zone. Une erreur de syntaxe entraîne généralement la considération du fichier de zone entier comme inutilisable. Le serveur de noms se comporte de la même manière que si cette zone n'existait pas. Il répond aux requêtes DNS avec un message d'erreur `SERVFAIL`.

En bref, ici, tous les `enregistrements directs` (`forward records`) sont saisis selon le format BIND. Cela permet au serveur DNS d'identifier à quel domaine, nom d'hôte et rôle les adresses IP appartiennent. En termes simples, c'est l'annuaire téléphonique où le serveur DNS recherche les adresses des domaines qu'il cherche.

#### Fichiers de Zone

        shellsession
`root@bind9:~# cat /etc/bind/db.domain.com  ; ; BIND reverse data file for local loopback interface ; $ORIGIN domain.com $TTL 86400 @     IN     SOA    dns1.domain.com.     hostmaster.domain.com. (                     2001062501 ; serial                     21600      ; refresh after 6 hours                     3600       ; retry after 1 hour                     604800     ; expire after 1 week                     86400 )    ; minimum TTL of 1 day        IN     NS     ns1.domain.com.       IN     NS     ns2.domain.com.        IN     MX     10     mx.domain.com.       IN     MX     20     mx2.domain.com.               IN     A       10.129.14.5  server1      IN     A       10.129.14.5 server2      IN     A       10.129.14.7 ns1          IN     A       10.129.14.2 ns2          IN     A       10.129.14.3  ftp          IN     CNAME   server1 mx           IN     CNAME   server1 mx2          IN     CNAME   server2 www          IN     CNAME   server2`

Pour que le `Nom de Domaine Entièrement Qualifié` (`FQDN`, pour `Fully Qualified Domain Name`) soit résolu à partir de l'adresse IP, le serveur DNS doit avoir un fichier de recherche inversée. Dans ce fichier, le nom de l'ordinateur (`FQDN`) est assigné au dernier octet d'une adresse IP, qui correspond à l'hôte respectif, en utilisant un enregistrement PTR. Les enregistrements PTR sont responsables de la traduction inversée des adresses IP en noms, comme nous l'avons déjà vu dans le tableau ci-dessus.

#### Fichiers de Zone de Résolution de Noms Inversée

        shellsession
`root@bind9:~# cat /etc/bind/db.10.129.14  ; ; BIND reverse data file for local loopback interface ; $ORIGIN 14.129.10.in-addr.arpa $TTL 86400 @     IN     SOA    dns1.domain.com.     hostmaster.domain.com. (                     2001062501 ; serial                     21600      ; refresh after 6 hours                     3600       ; retry after 1 hour                     604800     ; expire after 1 week                     86400 )    ; minimum TTL of 1 day        IN     NS     ns1.domain.com.       IN     NS     ns2.domain.com.  5    IN     PTR    server1.domain.com. 7    IN     MX     mx.domain.com. ...SNIP...`

---

## Paramètres Dangereux

Il existe de nombreuses façons dont un serveur DNS peut être attaqué. Par exemple, une liste de vulnérabilités ciblant le serveur BIND9 peut être trouvée sur [CVEdetails](https://www.cvedetails.com/product/144/ISC-Bind.html?vendor_id=64). De plus, SecurityTrails fournit une courte [liste](https://web.archive.org/web/20250329174745/https://securitytrails.com/blog/most-popular-types-dns-attacks) des attaques les plus populaires sur les serveurs DNS.

Certains des paramètres que nous pouvons voir ci-dessous conduisent, entre autres, à ces vulnérabilités. Parce que le DNS peut devenir très compliqué et qu'il est très facile que des erreurs se glissent dans ce service, forçant un administrateur à contourner le problème jusqu'à ce qu'il trouve une solution exacte. Cela conduit souvent à ce que des éléments soient libérés pour que des parties de l'infrastructure fonctionnent comme prévu et souhaité. Dans de tels cas, la fonctionnalité a une priorité plus élevée que la sécurité, ce qui entraîne des erreurs de configuration et des vulnérabilités.

|**Option**|**Description**|
|---|---|
|`allow-query`|Définit quels hôtes sont autorisés à envoyer des requêtes au serveur DNS.|
|`allow-recursion`|Définit quels hôtes sont autorisés à envoyer des requêtes récursives au serveur DNS.|
|`allow-transfer`|Définit quels hôtes sont autorisés à recevoir des transferts de zone du serveur DNS.|
|`zone-statistics`|Collecte des données statistiques sur les zones.|

---

## Prise d'empreinte du service

La `prise d'empreinte` (`footprinting`) sur les serveurs DNS se fait à la suite des requêtes que nous envoyons. Ainsi, tout d'abord, le serveur DNS peut être interrogé pour savoir quels autres serveurs de noms sont connus. Nous le faisons en utilisant l'enregistrement NS et la spécification du serveur DNS que nous voulons interroger en utilisant le caractère `@`. C'est parce que s'il y a d'autres serveurs DNS, nous pouvons également les utiliser et interroger les enregistrements. Cependant, d'autres serveurs DNS peuvent être configurés différemment et, de plus, peuvent être permanents pour d'autres zones.

#### DIG - Requête NS

        shellsession
`ppporrkkky@htb[/htb]$ dig ns inlanefreight.htb @10.129.14.128  ; <<>> DiG 9.16.1-Ubuntu <<>> ns inlanefreight.htb @10.129.14.128 ;; global options: +cmd ;; Got answer: ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 45010 ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2  ;; OPT PSEUDOSECTION: ; EDNS: version: 0, flags:; udp: 4096 ; COOKIE: ce4d8681b32abaea0100000061475f73842c401c391690c7 (good) ;; QUESTION SECTION: ;inlanefreight.htb.             IN      NS  ;; ANSWER SECTION: inlanefreight.htb.      604800  IN      NS      ns.inlanefreight.htb.  ;; ADDITIONAL SECTION: ns.inlanefreight.htb.   604800  IN      A       10.129.34.136  ;; Query time: 0 msec ;; SERVER: 10.129.14.128#53(10.129.14.128) ;; WHEN: So Sep 19 18:04:03 CEST 2021 ;; MSG SIZE  rcvd: 107`

Il est parfois aussi possible d'interroger la version d'un serveur DNS en utilisant une requête de classe CHAOS et de type TXT. Cependant, cette entrée doit exister sur le serveur DNS. Pour cela, nous pourrions utiliser la commande suivante :

#### DIG - Requête de Version

        shellsession
`ppporrkkky@htb[/htb]$ dig CH TXT version.bind 10.129.120.85  ; <<>> DiG 9.10.6 <<>> CH TXT version.bind ;; global options: +cmd ;; Got answer: ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 47786 ;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1  ;; ANSWER SECTION: version.bind.       0       CH      TXT     "9.10.6-P1"  ;; ADDITIONAL SECTION: version.bind.       0       CH      TXT     "9.10.6-P1-Debian"  ;; Query time: 2 msec ;; SERVER: 10.129.120.85#53(10.129.120.85) ;; WHEN: Wed Jan 05 20:23:14 UTC 2023 ;; MSG SIZE  rcvd: 101`

Nous pouvons utiliser l'option `ANY` pour voir tous les enregistrements disponibles. Cela amènera le serveur à nous montrer toutes les entrées disponibles qu'il est prêt à divulguer. Il est important de noter que toutes les entrées des zones ne seront pas affichées.

#### DIG - Requête ANY

        shellsession
`ppporrkkky@htb[/htb]$ dig any inlanefreight.htb @10.129.14.128  ; <<>> DiG 9.16.1-Ubuntu <<>> any inlanefreight.htb @10.129.14.128 ;; global options: +cmd ;; Got answer: ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 7649 ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 5, AUTHORITY: 0, ADDITIONAL: 2  ;; OPT PSEUDOSECTION: ; EDNS: version: 0, flags:; udp: 4096 ; COOKIE: 064b7e1f091b95120100000061476865a6026d01f87d10ca (good) ;; QUESTION SECTION: ;inlanefreight.htb.             IN      ANY  ;; ANSWER SECTION: inlanefreight.htb.      604800  IN      TXT     "v=spf1 include:mailgun.org include:_spf.google.com include:spf.protection.outlook.com include:_spf.atlassian.net ip4:10.129.124.8 ip4:10.129.127.2 ip4:10.129.42.106 ~all" inlanefreight.htb.      604800  IN      TXT     "atlassian-domain-verification=t1rKCy68JFszSdCKVpw64A1QksWdXuYFUeSXKU" inlanefreight.htb.      604800  IN      TXT     "MS=ms97310371" inlanefreight.htb.      604800  IN      SOA     inlanefreight.htb. root.inlanefreight.htb. 2 604800 86400 2419200 604800 inlanefreight.htb.      604800  IN      NS      ns.inlanefreight.htb.  ;; ADDITIONAL SECTION: ns.inlanefreight.htb.   604800  IN      A       10.129.34.136  ;; Query time: 0 msec ;; SERVER: 10.129.14.128#53(10.129.14.128) ;; WHEN: So Sep 19 18:42:13 CEST 2021 ;; MSG SIZE  rcvd: 437`

Le `transfert de zone` (`Zone transfer`) fait référence au transfert de zones vers un autre serveur en DNS, ce qui se produit généralement sur le port TCP 53. Cette procédure est abrégée `Asynchronous Full Transfer Zone` (`AXFR`). Étant donné qu'une panne de DNS a généralement des conséquences graves pour une entreprise, le fichier de zone est presque invariablement maintenu identique sur plusieurs serveurs de noms. Lorsque des modifications sont apportées, il faut s'assurer que tous les serveurs ont les mêmes données. La synchronisation entre les serveurs impliqués est réalisée par transfert de zone. En utilisant une clé secrète `rndc-key`, que nous avons vue initialement dans la configuration par défaut, les serveurs s'assurent qu'ils communiquent avec leur propre maître ou esclave. Le transfert de zone implique le simple transfert de fichiers ou d'enregistrements et la détection de divergences dans les ensembles de données des serveurs impliqués.

Les données originales d'une zone sont situées sur un serveur DNS, qui est appelé le serveur de noms `primaire` pour cette zone. Cependant, pour augmenter la fiabilité, réaliser une simple répartition de charge, ou protéger le primaire contre les attaques, un ou plusieurs serveurs supplémentaires sont installés en pratique dans presque tous les cas, qui sont appelés serveurs de noms `secondaires` pour cette zone. Pour certains `domaines de premier niveau` (`TLD`), il est obligatoire de rendre les fichiers de zone pour les `domaines de second niveau` accessibles sur au moins deux serveurs.

Les entrées DNS ne sont généralement créées, modifiées ou supprimées que sur le primaire. Cela peut se faire en éditant manuellement le fichier de zone pertinent ou automatiquement par une mise à jour dynamique à partir d'une base de données. Un serveur DNS qui sert de source directe pour la synchronisation d'un fichier de zone est appelé un `maître` (`master`). Un serveur DNS qui obtient des données de zone d'un maître est appelé un `esclave` (`slave`). Un primaire est toujours un maître, tandis qu'un secondaire peut être à la fois un esclave et un maître.

L'esclave récupère l'enregistrement `SOA` de la zone concernée auprès du maître à certains intervalles, appelés le `temps de rafraîchissement` (`refresh time`), généralement une heure, et compare les numéros de série. Si le numéro de série de l'enregistrement SOA du maître est supérieur à celui de l'esclave, les ensembles de données ne correspondent plus.

#### DIG - Transfert de Zone AXFR

        shellsession
`ppporrkkky@htb[/htb]$ dig axfr inlanefreight.htb @10.129.14.128  ; <<>> DiG 9.16.1-Ubuntu <<>> axfr inlanefreight.htb @10.129.14.128 ;; global options: +cmd inlanefreight.htb.      604800  IN      SOA     inlanefreight.htb. root.inlanefreight.htb. 2 604800 86400 2419200 604800 inlanefreight.htb.      604800  IN      TXT     "MS=ms97310371" inlanefreight.htb.      604800  IN      TXT     "atlassian-domain-verification=t1rKCy68JFszSdCKVpw64A1QksWdXuYFUeSXKU" inlanefreight.htb.      604800  IN      TXT     "v=spf1 include:mailgun.org include:_spf.google.com include:spf.protection.outlook.com include:_spf.atlassian.net ip4:10.129.124.8 ip4:10.129.127.2 ip4:10.129.42.106 ~all" inlanefreight.htb.      604800  IN      NS      ns.inlanefreight.htb. app.inlanefreight.htb.  604800  IN      A       10.129.18.15 internal.inlanefreight.htb. 604800 IN   A       10.129.1.6 mail1.inlanefreight.htb. 604800 IN      A       10.129.18.201 ns.inlanefreight.htb.   604800  IN      A       10.129.34.136 inlanefreight.htb.      604800  IN      SOA     inlanefreight.htb. root.inlanefreight.htb. 2 604800 86400 2419200 604800 ;; Query time: 4 msec ;; SERVER: 10.129.14.128#53(10.129.14.128) ;; WHEN: So Sep 19 18:51:19 CEST 2021 ;; XFR size: 9 records (messages 1, bytes 520)`

Si l'administrateur a utilisé un sous-réseau pour l'option `allow-transfer` à des fins de test ou comme solution de contournement, ou l'a définie sur `any`, tout le monde pourrait interroger l'ensemble du fichier de zone sur le serveur DNS. De plus, d'autres zones peuvent être interrogées, ce qui peut même révéler des adresses IP et des noms d'hôtes internes.

#### DIG - Transfert de Zone AXFR - Interne

        shellsession
`ppporrkkky@htb[/htb]$ dig axfr internal.inlanefreight.htb @10.129.14.128  ; <<>> DiG 9.16.1-Ubuntu <<>> axfr internal.inlanefreight.htb @10.129.14.128 ;; global options: +cmd internal.inlanefreight.htb. 604800 IN   SOA     inlanefreight.htb. root.inlanefreight.htb. 2 604800 86400 2419200 604800 internal.inlanefreight.htb. 604800 IN   TXT     "MS=ms97310371" internal.inlanefreight.htb. 604800 IN   TXT     "atlassian-domain-verification=t1rKCy68JFszSdCKVpw64A1QksWdXuYFUeSXKU" internal.inlanefreight.htb. 604800 IN   TXT     "v=spf1 include:mailgun.org include:_spf.google.com include:spf.protection.outlook.com include:_spf.atlassian.net ip4:10.129.124.8 ip4:10.129.127.2 ip4:10.129.42.106 ~all" internal.inlanefreight.htb. 604800 IN   NS      ns.inlanefreight.htb. dc1.internal.inlanefreight.htb. 604800 IN A     10.129.34.16 dc2.internal.inlanefreight.htb. 604800 IN A     10.129.34.11 mail1.internal.inlanefreight.htb. 604800 IN A   10.129.18.200 ns.internal.inlanefreight.htb. 604800 IN A      10.129.34.136 vpn.internal.inlanefreight.htb. 604800 IN A     10.129.1.6 ws1.internal.inlanefreight.htb. 604800 IN A     10.129.1.34 ws2.internal.inlanefreight.htb. 604800 IN A     10.129.1.35 wsus.internal.inlanefreight.htb. 604800 IN A    10.129.18.2 internal.inlanefreight.htb. 604800 IN   SOA     inlanefreight.htb. root.inlanefreight.htb. 2 604800 86400 2419200 604800 ;; Query time: 0 msec ;; SERVER: 10.129.14.128#53(10.129.14.128) ;; WHEN: So Sep 19 18:53:11 CEST 2021 ;; XFR size: 15 records (messages 1, bytes 664)`

Les enregistrements `A` individuels avec les noms d'hôtes peuvent également être découverts à l'aide d'une `attaque par force brute` (`brute-force attack`). Pour ce faire, nous avons besoin d'une liste de noms d'hôtes possibles, que nous utilisons pour envoyer les requêtes dans l'ordre. De telles listes sont fournies, par exemple, par [SecLists](https://github.com/danielmiessler/SecLists/blob/master/Discovery/DNS/subdomains-top1million-5000.txt).

Une option serait d'exécuter une `boucle for` en Bash qui liste ces entrées et envoie la requête correspondante au serveur DNS souhaité.

#### Force Brute de Sous-domaines

        shellsession
`ppporrkkky@htb[/htb]$ for sub in $(cat /opt/useful/seclists/Discovery/DNS/subdomains-top1million-110000.txt);do dig $sub.inlanefreight.htb @10.129.14.128 | grep -v ';\|SOA' | sed -r '/^\s*$/d' | grep $sub | tee -a subdomains.txt;done  ns.inlanefreight.htb.   604800  IN      A       10.129.34.136 mail1.inlanefreight.htb. 604800 IN      A       10.129.18.201 app.inlanefreight.htb.  604800  IN      A       10.129.18.15`

De nombreux outils différents peuvent être utilisés pour cela, et la plupart d'entre eux fonctionnent de la même manière. L'un de ces outils est, par exemple, [DNSenum](https://github.com/fwaeytens/dnsenum).

        shellsession
`ppporrkkky@htb[/htb]$ dnsenum --dnsserver 10.129.14.128 --enum -p 0 -s 0 -o subdomains.txt -f /opt/useful/seclists/Discovery/DNS/subdomains-top1million-110000.txt inlanefreight.htb  dnsenum VERSION:1.2.6  -----   inlanefreight.htb   -----   Host's addresses: __________________    Name Servers: ______________  ns.inlanefreight.htb.                    604800   IN    A        10.129.34.136   Mail (MX) Servers: ___________________    Trying Zone Transfers and getting Bind Versions: _________________________________________________  unresolvable name: ns.inlanefreight.htb at /usr/bin/dnsenum line 900 thread 1.  Trying Zone Transfer for inlanefreight.htb on ns.inlanefreight.htb ... AXFR record query failed: no nameservers   Brute forcing with /home/cry0l1t3/Pentesting/SecLists/Discovery/DNS/subdomains-top1million-110000.txt: _______________________________________________________________________________________________________  ns.inlanefreight.htb.                    604800   IN    A        10.129.34.136 mail1.inlanefreight.htb.                 604800   IN    A        10.129.18.201 app.inlanefreight.htb.                   604800   IN    A        10.129.18.15 ns.inlanefreight.htb.                    604800   IN    A        10.129.34.136  ...SNIP... done.`
