Avec l'aide du `Protocole d'accès aux messages Internet` (`IMAP` pour Internet Message Access Protocol), l'accès aux e-mails depuis un serveur de messagerie est possible. Contrairement au `Protocole Post Office` (`POP3` pour Post Office Protocol), l'IMAP permet la gestion en ligne des e-mails directement sur le serveur et prend en charge les structures de dossiers. Il s'agit donc d'un protocole réseau pour la gestion en ligne des e-mails sur un serveur distant. Le protocole est basé sur un modèle client-serveur et permet la synchronisation d'un client de messagerie local avec la boîte aux lettres sur le serveur, offrant une sorte de système de fichiers en réseau pour les e-mails, ce qui permet une synchronisation sans problème entre plusieurs clients indépendants. Le POP3, en revanche, n'a pas les mêmes fonctionnalités que l'IMAP, et il ne fournit que le listage, la récupération et la suppression des e-mails comme fonctions sur le serveur de messagerie. Par conséquent, des protocoles tels que l'IMAP doivent être utilisés pour des fonctionnalités supplémentaires telles que les boîtes aux lettres hiérarchiques directement sur le serveur de messagerie, l'accès à plusieurs boîtes aux lettres au cours d'une session et la présélection des e-mails.

Les clients accèdent à ces structures en ligne et peuvent créer des copies locales. Même entre plusieurs clients, cela aboutit à une base de données uniforme. Les e-mails restent sur le serveur jusqu'à ce qu'ils soient supprimés. L'IMAP est basé sur du texte et dispose de fonctions étendues, telles que la navigation dans les e-mails directement sur le serveur. Il est également possible pour plusieurs utilisateurs d'accéder simultanément au serveur de messagerie. Sans une connexion active au serveur, la gestion des e-mails est impossible. Cependant, certains clients proposent un mode hors ligne avec une copie locale de la boîte aux lettres. Le client synchronise toutes les modifications locales hors ligne lorsqu'une connexion est rétablie.

Le client établit la connexion au serveur via le port `143`. Pour la communication, il utilise des commandes textuelles au format `ASCII`. Plusieurs commandes peuvent être envoyées successivement sans attendre la confirmation du serveur. Les confirmations ultérieures du serveur peuvent être associées aux commandes individuelles à l'aide des identifiants envoyés avec les commandes. Immédiatement après l'établissement de la connexion, l'utilisateur est authentifié auprès du serveur par son nom d'utilisateur et son mot de passe. L'accès à la boîte aux lettres souhaitée n'est possible qu'après une authentification réussie.

Le SMTP est généralement utilisé pour envoyer des e-mails. En copiant les e-mails envoyés dans un dossier IMAP, tous les clients ont accès à tous les messages envoyés, quel que soit l'ordinateur depuis lequel ils ont été envoyés. Un autre avantage du protocole d'accès aux messages Internet est la création de dossiers personnels et de structures de dossiers dans la boîte aux lettres. Cette fonctionnalité rend la boîte aux lettres plus claire et plus facile à gérer. Cependant, l'espace de stockage requis sur le serveur de messagerie augmente.

Sans mesures supplémentaires, l'IMAP fonctionne de manière non chiffrée et transmet les commandes, les e-mails, ou les noms d'utilisateur et mots de passe en clair. De nombreux serveurs de messagerie exigent l'établissement d'une session IMAP chiffrée pour garantir une plus grande sécurité dans le trafic de messagerie et empêcher tout accès non autorisé aux boîtes aux lettres. Le SSL/TLS est généralement utilisé à cette fin. Selon la méthode et l'implémentation utilisées, la connexion chiffrée utilise le port standard `143` ou un port alternatif tel que `993`.

---

## Configuration par défaut

L'IMAP et le POP3 disposent tous deux d'un grand nombre d'options de configuration, ce qui rend difficile l'examen en détail de chaque composant. Si vous souhaitez examiner ces configurations de protocole plus en profondeur, nous vous recommandons de créer une VM localement et d'installer les deux paquets `dovecot-imapd` et `dovecot-pop3d` en utilisant `apt` et d'expérimenter avec les configurations.

Dans la documentation de Dovecot, nous pouvons trouver les [paramètres principaux](https://doc.dovecot.org/2.4.1/core/summaries/settings.html) individuels et les options de [configuration de service](https://doc.dovecot.org/2.4.1/core/config/service.html) qui peuvent être utilisées pour nos expériences. Cependant, regardons la liste des commandes et voyons comment nous pouvons interagir et communiquer directement avec l'IMAP et le POP3 en utilisant la ligne de commande.

#### Commandes IMAP

|**Commande**|**Description**|
|---|---|
|`1 LOGIN username password`|Connexion de l'utilisateur.|
|`1 LIST "" *`|Liste tous les répertoires.|
|`1 CREATE "INBOX"`|Crée une boîte aux lettres avec un nom spécifié.|
|`1 DELETE "INBOX"`|Supprime une boîte aux lettres.|
|`1 RENAME "ToRead" "Important"`|Renomme une boîte aux lettres.|
|`1 LSUB "" *`|Renvoie un sous-ensemble de noms parmi l'ensemble des noms que l'utilisateur a déclarés comme étant `actifs` ou `abonnés`.|
|`1 SELECT INBOX`|Sélectionne une boîte aux lettres pour que les messages qu'elle contient puissent être consultés.|
|`1 UNSELECT INBOX`|Quitte la boîte aux lettres sélectionnée.|
|`1 FETCH <ID> all`|Récupère les données associées à un message dans la boîte aux lettres.|
|`1 CLOSE`|Supprime tous les messages marqués du drapeau `Deleted`.|
|`1 LOGOUT`|Ferme la connexion avec le serveur IMAP.|

#### Commandes POP3

|**Commande**|**Description**|
|---|---|
|`USER username`|Identifie l'utilisateur.|
|`PASS password`|Authentification de l'utilisateur à l'aide de son mot de passe.|
|`STAT`|Demande au serveur le nombre d'e-mails enregistrés.|
|`LIST`|Demande au serveur le nombre et la taille de tous les e-mails.|
|`RETR id`|Demande au serveur de délivrer l'e-mail demandé par son ID.|
|`DELE id`|Demande au serveur de supprimer l'e-mail demandé par son ID.|
|`CAPA`|Demande au serveur d'afficher les capacités du serveur.|
|`RSET`|Demande au serveur de réinitialiser les informations transmises.|
|`QUIT`|Ferme la connexion avec le serveur POP3.|

---

## Paramètres dangereux

Néanmoins, des options de configuration mal configurées pourraient nous permettre d'obtenir plus d'informations, comme le débogage des commandes exécutées sur le service ou la connexion en tant qu'anonyme, à l'instar du service FTP. La plupart des entreprises utilisent des fournisseurs de messagerie tiers tels que Google, Microsoft et bien d'autres. Cependant, certaines entreprises utilisent encore leurs propres serveurs de messagerie pour de nombreuses raisons différentes. L'une de ces raisons est de préserver la confidentialité qu'elles souhaitent garder entre leurs mains. De nombreuses erreurs de configuration peuvent être commises par les administrateurs, ce qui, dans le pire des cas, nous permettra de lire tous les e-mails envoyés et reçus, qui peuvent même contenir des informations confidentielles ou sensibles. Certaines de ces options de configuration incluent :

|**Paramètre**|**Description**|
|---|---|
|`auth_debug`|Active tous les journaux de débogage de l'authentification.|
|`auth_debug_passwords`|Ce paramètre ajuste la verbosité des journaux, les mots de passe soumis et le schéma sont journalisés.|
|`auth_verbose`|Journalise les tentatives d'authentification infructueuses et leurs raisons.|
|`auth_verbose_passwords`|Les mots de passe utilisés pour l'authentification sont journalisés et peuvent également être tronqués.|
|`auth_anonymous_username`|Ceci spécifie le nom d'utilisateur à utiliser lors de la connexion avec le mécanisme SASL ANONYMOUS.|

---

## Prise d'empreinte du service

Par défaut, les ports `110` et `995` sont utilisés pour le POP3, et les ports `143` et `993` sont utilisés pour l'IMAP. Les ports les plus élevés (`993` et `995`) utilisent TLS/SSL pour chiffrer la communication entre le client et le serveur. En utilisant Nmap, nous pouvons scanner le serveur pour ces ports. Le scan renverra les informations correspondantes (comme vu ci-dessous) si le serveur utilise un certificat intégré.

#### Nmap

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap 10.129.14.128 -sV -p110,143,993,995 -sC  Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-19 22:09 CEST Nmap scan report for 10.129.14.128 Host is up (0.00026s latency).  PORT    STATE SERVICE  VERSION 110/tcp open  pop3     Dovecot pop3d |_pop3-capabilities: AUTH-RESP-CODE SASL STLS TOP UIDL RESP-CODES CAPA PIPELINING | ssl-cert: Subject: commonName=mail1.inlanefreight.htb/organizationName=Inlanefreight/stateOrProvinceName=California/countryName=US | Not valid before: 2021-09-19T19:44:58 |_Not valid after:  2295-07-04T19:44:58 143/tcp open  imap     Dovecot imapd |_imap-capabilities: more have post-login STARTTLS Pre-login capabilities LITERAL+ LOGIN-REFERRALS OK LOGINDISABLEDA0001 SASL-IR ENABLE listed IDLE ID IMAP4rev1 | ssl-cert: Subject: commonName=mail1.inlanefreight.htb/organizationName=Inlanefreight/stateOrProvinceName=California/countryName=US | Not valid before: 2021-09-19T19:44:58 |_Not valid after:  2295-07-04T19:44:58 993/tcp open  ssl/imap Dovecot imapd |_imap-capabilities: more have post-login OK capabilities LITERAL+ LOGIN-REFERRALS Pre-login AUTH=PLAINA0001 SASL-IR ENABLE listed IDLE ID IMAP4rev1 | ssl-cert: Subject: commonName=mail1.inlanefreight.htb/organizationName=Inlanefreight/stateOrProvinceName=California/countryName=US | Not valid before: 2021-09-19T19:44:58 |_Not valid after:  2295-07-04T19:44:58 995/tcp open  ssl/pop3 Dovecot pop3d |_pop3-capabilities: AUTH-RESP-CODE USER SASL(PLAIN) TOP UIDL RESP-CODES CAPA PIPELINING | ssl-cert: Subject: commonName=mail1.inlanefreight.htb/organizationName=Inlanefreight/stateOrProvinceName=California/countryName=US | Not valid before: 2021-09-19T19:44:58 |_Not valid after:  2295-07-04T19:44:58 MAC Address: 00:00:00:00:00:00 (VMware)  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 12.74 seconds`

Par exemple, à partir de la sortie, nous pouvons voir que le nom commun est `mail1.inlanefreight.htb`, et que le serveur de messagerie appartient à l'organisation `Inlanefreight`, qui est située en Californie. Les capacités affichées nous montrent les commandes disponibles sur le serveur et pour le service sur le port correspondant.

Si nous parvenons à trouver les identifiants d'accès de l'un des employés, un attaquant pourrait se connecter au serveur de messagerie et lire ou même envoyer les messages individuels.

#### cURL

        shellsession
`ppporrkkky@htb[/htb]$ curl -k 'imaps://10.129.14.128' --user user:p4ssw0rd  * LIST (\HasNoChildren) "." Important * LIST (\HasNoChildren) "." INBOX`

Si nous utilisons également l'option `verbose` (`-v`), nous verrons comment la connexion est établie. À partir de là, nous pouvons voir la version de TLS utilisée pour le chiffrement, d'autres détails du certificat SSL, et même la bannière, qui contiendra souvent la version du serveur de messagerie.

        shellsession
`ppporrkkky@htb[/htb]$ curl -k 'imaps://10.129.14.128' --user cry0l1t3:1234 -v  *   Trying 10.129.14.128:993... * TCP_NODELAY set * Connected to 10.129.14.128 (10.129.14.128) port 993 (#0) * successfully set certificate verify locations: *   CAfile: /etc/ssl/certs/ca-certificates.crt   CApath: /etc/ssl/certs * TLSv1.3 (OUT), TLS handshake, Client hello (1): * TLSv1.3 (IN), TLS handshake, Server hello (2): * TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8): * TLSv1.3 (IN), TLS handshake, Certificate (11): * TLSv1.3 (IN), TLS handshake, CERT verify (15): * TLSv1.3 (IN), TLS handshake, Finished (20): * TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1): * TLSv1.3 (OUT), TLS handshake, Finished (20): * SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 * Server certificate: *  subject: C=US; ST=California; L=Sacramento; O=Inlanefreight; OU=Customer Support; CN=mail1.inlanefreight.htb; emailAddress=cry0l1t3@inlanefreight.htb *  start date: Sep 19 19:44:58 2021 GMT *  expire date: Jul  4 19:44:58 2295 GMT *  issuer: C=US; ST=California; L=Sacramento; O=Inlanefreight; OU=Customer Support; CN=mail1.inlanefreight.htb; emailAddress=cry0l1t3@inlanefreight.htb *  SSL certificate verify result: self signed certificate (18), continuing anyway. * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4): * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4): * old SSL session ID is stale, removing < * OK [CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE LITERAL+ AUTH=PLAIN] HTB-Academy IMAP4 v.0.21.4 > A001 CAPABILITY < * CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE LITERAL+ AUTH=PLAIN < A001 OK Pre-login capabilities listed, post-login capabilities have more. > A002 AUTHENTICATE PLAIN AGNyeTBsMXQzADEyMzQ= < * CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE SORT SORT=DISPLAY THREAD=REFERENCES THREAD=REFS THREAD=ORDEREDSUBJECT MULTIAPPEND URL-PARTIAL CATENATE UNSELECT CHILDREN NAMESPACE UIDPLUS LIST-EXTENDED I18NLEVEL=1 CONDSTORE QRESYNC ESEARCH ESORT SEARCHRES WITHIN CONTEXT=SEARCH LIST-STATUS BINARY MOVE SNIPPET=FUZZY PREVIEW=FUZZY LITERAL+ NOTIFY SPECIAL-USE < A002 OK Logged in > A003 LIST "" * < * LIST (\HasNoChildren) "." Important * LIST (\HasNoChildren) "." Important < * LIST (\HasNoChildren) "." INBOX * LIST (\HasNoChildren) "." INBOX < A003 OK List completed (0.001 + 0.000 secs). * Connection #0 to host 10.129.14.128 left intact`

Pour interagir avec le serveur IMAP ou POP3 via SSL, nous pouvons utiliser `openssl`, ainsi que `ncat`. Les commandes pour cela ressembleraient à ceci :

#### OpenSSL - Interaction chiffrée TLS avec POP3

        shellsession
`ppporrkkky@htb[/htb]$ openssl s_client -connect 10.129.14.128:pop3s  CONNECTED(00000003) Can't use SSL_get_servername depth=0 C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Customer Support, CN = mail1.inlanefreight.htb, emailAddress = cry0l1t3@inlanefreight.htb verify error:num=18:self signed certificate verify return:1 depth=0 C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Customer Support, CN = mail1.inlanefreight.htb, emailAddress = cry0l1t3@inlanefreight.htb verify return:1 --- Certificate chain  0 s:C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Customer Support, CN = mail1.inlanefreight.htb, emailAddress = cry0l1t3@inlanefreight.htb  ...SNIP...  --- read R BLOCK --- Post-Handshake New Session Ticket arrived: SSL-Session:     Protocol  : TLSv1.3     Cipher    : TLS_AES_256_GCM_SHA384     Session-ID: 3CC39A7F2928B252EF2FFA5462140B1A0A74B29D4708AA8DE1515BB4033D92C2     Session-ID-ctx:     Resumption PSK: 68419D933B5FEBD878FF1BA399A926813BEA3652555E05F0EC75D65819A263AA25FA672F8974C37F6446446BB7EA83F9     PSK identity: None     PSK identity hint: None     SRP username: None     TLS session ticket lifetime hint: 7200 (seconds)     TLS session ticket:     0000 - d7 86 ac 7e f3 f4 95 35-88 40 a5 b5 d6 a6 41 e4   ...~...5.@....A.     0010 - 96 6c e6 12 4f 50 ce 72-36 25 df e1 72 d9 23 94   .l..OP.r6%..r.#.     0020 - cc 29 90 08 58 1b 57 ab-db a8 6b f7 8f 31 5b ad   .)..X.W...k..1[.     0030 - 47 94 f4 67 58 1f 96 d9-ca ca 56 f9 7a 12 f6 6d   G..gX.....V.z..m     0040 - 43 b9 b6 68 de db b2 47-4f 9f 48 14 40 45 8f 89   C..h...GO.H.@E..     0050 - fa 19 35 9c 6d 3c a1 46-5c a2 65 ab 87 a4 fd 5e   ..5.m<.F\.e....^     0060 - a2 95 25 d4 43 b8 71 70-40 6c fe 6f 0e d1 a0 38   ..%.C.qp@l.o...8     0070 - 6e bd 73 91 ed 05 89 83-f5 3e d9 2a e0 2e 96 f8   n.s......>.*....     0080 - 99 f0 50 15 e0 1b 66 db-7c 9f 10 80 4a a1 8b 24   ..P...f.|...J..$     0090 - bb 00 03 d4 93 2b d9 95-64 44 5b c2 6b 2e 01 b5   .....+..dD[.k...     00a0 - e8 1b f4 a4 98 a7 7a 7d-0a 80 cc 0a ad fe 6e b3   ......z}......n.     00b0 - 0a d6 50 5d fd 9a b4 5c-28 a4 c9 36 e4 7d 2a 1e   ..P]...\(..6.}*.      Start Time: 1632081313     Timeout   : 7200 (sec)     Verify return code: 18 (self signed certificate)     Extended master secret: no     Max Early Data: 0 --- read R BLOCK +OK HTB-Academy POP3 Server`

#### OpenSSL - Interaction chiffrée TLS avec IMAP

        shellsession
``ppporrkkky@htb[/htb]$ openssl s_client -connect 10.129.14.128:imaps  CONNECTED(00000003) Can't use SSL_get_servername depth=0 C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Customer Support, CN = mail1.inlanefreight.htb, emailAddress = cry0l1t3@inlanefreight.htb verify error:num=18:self signed certificate verify return:1 depth=0 C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Customer Support, CN = mail1.inlanefreight.htb, emailAddress = cry0l1t3@inlanefreight.htb verify return:1 --- Certificate chain  0 s:C = US, ST = California, L = Sacramento, O = Inlanefreight, OU = Customer Support, CN = mail1.inlanefreight.htb, emailAddress = cry0l1t3@inlanefreight.htb  ...SNIP...  --- read R BLOCK --- Post-Handshake New Session Ticket arrived: SSL-Session:     Protocol  : TLSv1.3     Cipher    : TLS_AES_256_GCM_SHA384     Session-ID: 2B7148CD1B7B92BA123E06E22831FCD3B365A5EA06B2CDEF1A5F397177130699     Session-ID-ctx:     Resumption PSK: 4D9F082C6660646C39135F9996DDA2C199C4F7E75D65FA5303F4A0B274D78CC5BD3416C8AF50B31A34EC022B619CC633     PSK identity: None     PSK identity hint: None     SRP username: None     TLS session ticket lifetime hint: 7200 (seconds)     TLS session ticket:     0000 - 68 3b b6 68 ff 85 95 7c-8a 8a 16 b2 97 1c 72 24   h;.h...|......r$     0010 - 62 a7 84 ff c3 24 ab 99-de 45 60 26 e7 04 4a 7d   b....$...E`&..J}     0020 - bc 6e 06 a0 ff f7 d7 41-b5 1b 49 9c 9f 36 40 8d   .n.....A..I..6@.     0030 - 93 35 ed d9 eb 1f 14 d7-a5 f6 3f c8 52 fb 9f 29   .5........?.R..)     0040 - 89 8d de e6 46 95 b3 32-48 80 19 bc 46 36 cb eb   ....F..2H...F6..     0050 - 35 79 54 4c 57 f8 ee 55-06 e3 59 7f 5e 64 85 b0   5yTLW..U..Y.^d..     0060 - f3 a4 8c a6 b6 47 e4 59-ee c9 ab 54 a4 ab 8c 01   .....G.Y...T....     0070 - 56 bb b9 bb 3b f6 96 74-16 c9 66 e2 6c 28 c6 12   V...;..t..f.l(..     0080 - 34 c7 63 6b ff 71 16 7f-91 69 dc 38 7a 47 46 ec   4.ck.q...i.8zGF.     0090 - 67 b7 a2 90 8b 31 58 a0-4f 57 30 6a b6 2e 3a 21   g....1X.OW0j..:!     00a0 - 54 c7 ba f0 a9 74 13 11-d5 d1 ec cc ea f9 54 7d   T....t........T}     00b0 - 46 a6 33 ed 5d 24 ed b0-20 63 43 d8 8f 14 4d 62   F.3.]$.. cC...Mb      Start Time: 1632081604     Timeout   : 7200 (sec)     Verify return code: 18 (self signed certificate)     Extended master secret: no     Max Early Data: 0 --- read R BLOCK * OK [CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE LITERAL+ AUTH=PLAIN] HTB-Academy IMAP4 v.0.21.4``

Une fois que nous avons réussi à initier une connexion et à nous connecter au serveur de messagerie cible, nous pouvons utiliser les commandes ci-dessus pour travailler avec le serveur et y naviguer. Nous tenons à souligner que la configuration de notre propre serveur de messagerie, la recherche à ce sujet, et les expériences que nous pouvons faire avec d'autres membres de la communauté nous donneront le savoir-faire pour comprendre la communication qui a lieu et quelles options de configuration en sont responsables.

Dans la section SMTP, nous avons trouvé l'utilisateur `robin`. Un autre membre de notre équipe a pu découvrir que l'utilisateur utilise également son nom d'utilisateur comme mot de passe (`robin`:`robin`). Nous pouvons utiliser ces identifiants et essayer de les utiliser pour interagir avec les services IMAP/POP3.