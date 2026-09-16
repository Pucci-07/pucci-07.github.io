# SMTP

---

Le `Simple Mail Transfer Protocol` (`SMTP`) est un protocole d'envoi d'e-mails dans un réseau IP. Il peut être utilisé entre un client de messagerie et un serveur de courrier sortant ou entre deux serveurs SMTP. Le SMTP est souvent associé aux protocoles IMAP ou POP3, qui peuvent récupérer et envoyer des e-mails. En principe, il s'agit d'un protocole client-serveur, bien que le SMTP puisse être utilisé entre un client et un serveur, ainsi qu'entre deux serveurs SMTP. Dans ce cas, un serveur agit en fait comme un client.

Par défaut, les serveurs SMTP acceptent les requêtes de connexion sur le port `25`. Cependant, les serveurs SMTP plus récents utilisent également d'autres ports, comme le port TCP `587`. Ce port est utilisé pour recevoir des e-mails d'utilisateurs/serveurs authentifiés, généralement en utilisant la commande STARTTLS pour faire basculer la connexion existante en texte clair vers une connexion chiffrée. Les données d'authentification sont protégées et ne sont plus visibles en texte clair sur le réseau. Au début de la connexion, l'authentification se produit lorsque le client confirme son identité avec un nom d'utilisateur et un mot de passe. Les e-mails peuvent alors être transmis. Pour ce faire, le client envoie au serveur les adresses de l'expéditeur et du destinataire, le contenu de l'e-mail, ainsi que d'autres informations et paramètres. Une fois l'e-mail transmis, la connexion est à nouveau terminée. Le serveur de messagerie commence alors à envoyer l'e-mail à un autre serveur SMTP.

Le SMTP fonctionne de manière non chiffrée sans mesures supplémentaires et transmet toutes les commandes, données ou informations d'authentification en texte clair. Pour empêcher la lecture non autorisée des données, le SMTP est utilisé conjointement avec le chiffrement SSL/TLS. Dans certaines circonstances, un serveur utilise un port autre que le port TCP standard `25` pour la connexion chiffrée, par exemple, le port TCP `465`.

Une fonction essentielle d'un serveur SMTP est de prévenir le spam en utilisant des mécanismes d'authentification qui n'autorisent que les utilisateurs habilités à envoyer des e-mails. À cette fin, la plupart des serveurs SMTP modernes prennent en charge l'extension de protocole ESMTP avec SMTP-Auth. Après avoir envoyé son e-mail, le client SMTP, également connu sous le nom d'« `Agent Utilisateur de Messagerie` » (`Mail User Agent`, `MUA`), le convertit en un en-tête et un corps, puis les télécharge tous deux sur le serveur SMTP. Celui-ci dispose d'un « `Agent de Transfert de Courrier` » (`Mail Transfer Agent`, `MTA`), la base logicielle pour l'envoi et la réception d'e-mails. Le MTA vérifie la taille de l'e-mail, recherche du spam, puis le stocke. Pour soulager le MTA, il est parfois précédé d'un « `Agent de Soumission de Courrier` » (`Mail Submission Agent`, `MSA`), qui vérifie la validité, c'est-à-dire l'origine de l'e-mail. Ce `MSA` est également appelé serveur `Relais` (`Relay`). Ces derniers sont très importants par la suite, car ce que l'on appelle l'« `attaque de relais ouvert` » (`Open Relay Attack`) peut être menée sur de nombreux serveurs SMTP en raison d'une configuration incorrecte. Nous aborderons cette attaque et comment identifier son point faible un peu plus tard. Le MTA recherche ensuite dans le DNS l'adresse IP du serveur de messagerie du destinataire.

À son arrivée au serveur SMTP de destination, les paquets de données sont réassemblés pour former un e-mail complet. De là, l'« `Agent de Livraison de Courrier` » (`Mail Delivery Agent`, `MDA`) le transfère vers la boîte aux lettres du destinataire.

|Client (`MUA`)|`➞`|Agent de Soumission (`MSA`)|`➞`|Relais Ouvert (`MTA`)|`➞`|Agent de Livraison de Courrier (`MDA`)|`➞`|Boîte aux lettres (`POP3`/`IMAP`)|
|---|---|---|---|---|---|---|---|---|

Mais le SMTP présente deux inconvénients inhérents au protocole réseau.

1. Le premier est que l'envoi d'un e-mail via SMTP ne renvoie pas de confirmation de livraison utilisable. Bien que les spécifications du protocole prévoient ce type de notification, son formatage n'est pas spécifié par défaut, si bien que seul un message d'erreur en anglais, incluant l'en-tête du message non distribué, est généralement renvoyé.
2. Les utilisateurs ne sont pas authentifiés lors de l'établissement d'une connexion, et l'expéditeur d'un e-mail n'est donc pas fiable. Par conséquent, les relais SMTP ouverts sont souvent utilisés à mauvais escient pour envoyer massivement du spam. Les auteurs utilisent à cette fin des adresses d'expéditeur factices arbitraires pour ne pas être tracés (usurpation d'adresse e-mail, ou `mail spoofing`). Aujourd'hui, de nombreuses techniques de sécurité différentes sont utilisées pour empêcher l'utilisation abusive des serveurs SMTP. Par exemple, les e-mails suspects sont rejetés ou déplacés en quarantaine (dossier de spam). Sont par exemple responsables de cela le protocole d'identification [DomainKeys](http://dkim.org/) (`DKIM`) et le [Sender Policy Framework](https://dmarcian.com/what-is-spf/) (`SPF`).

À cette fin, une extension pour SMTP a été développée, appelée `Extended SMTP` (`ESMTP`). Lorsque l'on parle de SMTP en général, on entend généralement ESMTP. ESMTP utilise TLS, ce qui est fait après la commande `EHLO` en envoyant `STARTTLS`. Cela initialise la connexion SMTP protégée par SSL, et à partir de ce moment, toute la connexion est chiffrée et donc plus ou moins sécurisée. Désormais, l'extension [AUTH PLAIN](https://www.samlogic.net/articles/smtp-commands-reference-auth.htm) pour l'authentification peut également être utilisée en toute sécurité.

---

## Configuration par défaut

Chaque serveur SMTP peut être configuré de nombreuses manières, comme tous les autres services. Cependant, il existe des différences car le serveur SMTP n'est responsable que de l'envoi et du transfert des e-mails.

#### Configuration par défaut

        shellsession
`ppporrkkky@htb[/htb]$ cat /etc/postfix/main.cf | grep -v "#" | sed -r "/^\s*$/d"  smtpd_banner = ESMTP Server  biff = no append_dot_mydomain = no readme_directory = no compatibility_level = 2 smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache myhostname = mail1.inlanefreight.htb alias_maps = hash:/etc/aliases alias_database = hash:/etc/aliases smtp_generic_maps = hash:/etc/postfix/generic mydestination = $myhostname, localhost  masquerade_domains = $myhostname mynetworks = 127.0.0.0/8 10.129.0.0/16 mailbox_size_limit = 0 recipient_delimiter = + smtp_bind_address = 0.0.0.0 inet_protocols = ipv4 smtpd_helo_restrictions = reject_invalid_hostname home_mailbox = /home/postfix`

L'envoi et la communication se font également par des commandes spéciales qui amènent le serveur SMTP à faire ce que l'utilisateur demande.

| **Commande** | **Description**                                                                                              |
| ------------ | ------------------------------------------------------------------------------------------------------------ |
| `AUTH PLAIN` | AUTH est une extension de service utilisée pour authentifier le client.                                      |
| `HELO`       | Le client se connecte avec le nom de son ordinateur et démarre ainsi la session.                             |
| `MAIL FROM`  | Le client nomme l'expéditeur de l'e-mail.                                                                    |
| `RCPT TO`    | Le client nomme le destinataire de l'e-mail.                                                                 |
| `DATA`       | Le client lance la transmission de l'e-mail.                                                                 |
| `RSET`       | Le client annule la transmission initiée mais maintient la connexion entre le client et le serveur.          |
| `VRFY`       | Le client vérifie si une boîte aux lettres est disponible pour le transfert de messages.                     |
| `EXPN`       | Avec cette commande, le client vérifie également si une boîte aux lettres est disponible pour la messagerie. |
| `NOOP`       | Le client demande une réponse du serveur pour éviter une déconnexion due à un time-out.                      |
| `QUIT`       | Le client termine la session.                                                                                |

Pour interagir avec le serveur SMTP, nous pouvons utiliser l'outil `telnet` pour initialiser une connexion TCP avec le serveur SMTP. L'initialisation réelle de la session se fait avec la commande mentionnée ci-dessus, `HELO` ou `EHLO`.

#### Telnet - HELO/EHLO

        shellsession
`ppporrkkky@htb[/htb]$ telnet 10.129.14.128 25  Trying 10.129.14.128... Connected to 10.129.14.128. Escape character is '^]'. 220 ESMTP Server    HELO mail1.inlanefreight.htb  250 mail1.inlanefreight.htb   EHLO mail1  250-mail1.inlanefreight.htb 250-PIPELINING 250-SIZE 10240000 250-ETRN 250-ENHANCEDSTATUSCODES 250-8BITMIME 250-DSN 250-SMTPUTF8 250 CHUNKING`

La commande `VRFY` peut être utilisée pour énumérer les utilisateurs existants sur le système. Cependant, cela ne fonctionne pas toujours. Selon la configuration du serveur SMTP, celui-ci peut émettre le `code 252` et confirmer l'existence d'un utilisateur qui n'existe pas sur le système. Une liste de tous les codes de réponse SMTP peut être trouvée [ici](https://serversmtp.com/smtp-error/).

#### Telnet - VRFY

        shellsession
`ppporrkkky@htb[/htb]$ telnet 10.129.14.128 25  Trying 10.129.14.128... Connected to 10.129.14.128. Escape character is '^]'. 220 ESMTP Server   VRFY root  252 2.0.0 root   VRFY cry0l1t3  252 2.0.0 cry0l1t3   VRFY testuser  252 2.0.0 testuser   VRFY aaaaaaaaaaaaaaaaaaaaaaaaaaaa  252 2.0.0 aaaaaaaaaaaaaaaaaaaaaaaaaaaa`

Par conséquent, il ne faut jamais se fier entièrement aux résultats des outils automatiques. Après tout, ils exécutent des commandes préconfigurées, mais aucune des fonctions n'indique explicitement comment l'administrateur configure le serveur testé.

Parfois, nous pouvons avoir à travailler via un proxy web. Nous pouvons également faire en sorte que ce proxy web se connecte au serveur SMTP. La commande que nous enverrions ressemblerait alors à quelque chose comme ceci : `CONNECT 10.129.14.128:25 HTTP/1.0`

Toutes les commandes que nous saisissons dans la ligne de commande pour envoyer un e-mail nous sont familières de tous les programmes clients de messagerie comme Thunderbird, Gmail, Outlook et bien d'autres. Nous spécifions le `sujet`, à qui l'e-mail doit être envoyé, CC, BCC, et les informations que nous voulons partager avec d'autres. Bien sûr, la même chose fonctionne depuis la ligne de commande.

#### Envoyer un e-mail

        shellsession
`ppporrkkky@htb[/htb]$ telnet 10.129.14.128 25  Trying 10.129.14.128... Connected to 10.129.14.128. Escape character is '^]'. 220 ESMTP Server   EHLO inlanefreight.htb  250-mail1.inlanefreight.htb 250-PIPELINING 250-SIZE 10240000 250-ETRN 250-ENHANCEDSTATUSCODES 250-8BITMIME 250-DSN 250-SMTPUTF8 250 CHUNKING   MAIL FROM: <cry0l1t3@inlanefreight.htb>  250 2.1.0 Ok   RCPT TO: <mrb3n@inlanefreight.htb> NOTIFY=success,failure  250 2.1.5 Ok   DATA  354 End data with <CR><LF>.<CR><LF>  From: <cry0l1t3@inlanefreight.htb> To: <mrb3n@inlanefreight.htb> Subject: DB Date: Tue, 28 Sept 2021 16:32:51 +0200 Hey man, I am trying to access our XY-DB but the creds don't work.  Did you make any changes there? .  250 2.0.0 Ok: queued as 6E1CF1681AB   QUIT  221 2.0.0 Bye Connection closed by foreign host.`

L'en-tête de l'e-mail est le porteur d'une grande quantité d'informations intéressantes dans un e-mail. Entre autres, il fournit des informations sur l'expéditeur et le destinataire, l'heure d'envoi et d'arrivée, les stations par lesquelles l'e-mail est passé, le contenu et le format du message, ainsi que l'expéditeur et le destinataire.

Certaines de ces informations sont obligatoires, comme les informations sur l'expéditeur et la date de création de l'e-mail. D'autres informations sont facultatives. Cependant, l'en-tête de l'e-mail ne contient aucune information nécessaire à la livraison technique. Il est transmis dans le cadre du protocole de transmission. L'expéditeur et le destinataire peuvent tous deux accéder à l'en-tête d'un e-mail, bien qu'il ne soit pas visible au premier abord. La structure d'un en-tête d'e-mail est définie par la [RFC 5322](https://datatracker.ietf.org/doc/html/rfc5322).

---

## Paramètres dangereux

Pour éviter que les e-mails envoyés ne soient filtrés par les filtres anti-spam et n'atteignent pas le destinataire, l'expéditeur peut utiliser un serveur relais auquel le destinataire fait confiance. Il s'agit d'un serveur SMTP connu et vérifié par tous les autres. En règle générale, l'expéditeur doit s'authentifier auprès du serveur relais avant de l'utiliser.

Souvent, les administrateurs n'ont pas une vue d'ensemble des plages d'adresses IP qu'ils doivent autoriser. Il en résulte une mauvaise configuration du serveur SMTP que nous retrouverons encore souvent lors de tests d'intrusion (penetration tests) externes et internes. Par conséquent, ils autorisent toutes les adresses IP pour ne pas provoquer d'erreurs dans le trafic e-mail et donc ne pas perturber ou interrompre involontairement la communication avec les clients potentiels et actuels.

#### Configuration de relais ouvert

        shellsession
`mynetworks = 0.0.0.0/0`

Avec ce paramètre, ce serveur SMTP peut envoyer de faux e-mails et ainsi initialiser la communication entre plusieurs parties. Une autre possibilité d'attaque serait d'usurper l'identité de l'e-mail et de le lire.

---

## Prise d'empreinte du service

Les scripts Nmap par défaut incluent `smtp-commands`, qui utilise la commande `EHLO` pour lister toutes les commandes possibles qui peuvent être exécutées sur le serveur SMTP cible.

#### Nmap

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap 10.129.14.128 -sC -sV -p25  Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-27 17:56 CEST Nmap scan report for 10.129.14.128 Host is up (0.00025s latency).  PORT   STATE SERVICE VERSION 25/tcp open  smtp    Postfix smtpd |_smtp-commands: mail1.inlanefreight.htb, PIPELINING, SIZE 10240000, VRFY, ETRN, ENHANCEDSTATUSCODES, 8BITMIME, DSN, SMTPUTF8, CHUNKING,  MAC Address: 00:00:00:00:00:00 (VMware)  Service detection performed. Please report any incorrect results at https://nmap.org/submit/ . Nmap done: 1 IP address (1 host up) scanned in 14.09 seconds`

Cependant, nous pouvons également utiliser le script NSE [smtp-open-relay](https://nmap.org/nsedoc/scripts/smtp-open-relay.html) pour identifier le serveur SMTP cible comme un relais ouvert en utilisant 16 tests différents. Si nous affichons également la sortie du scan en détail, nous pourrons voir quels tests le script exécute.

#### Nmap - Relais ouvert

        shellsession
`ppporrkkky@htb[/htb]$ sudo nmap 10.129.14.128 -p25 --script smtp-open-relay -v  Starting Nmap 7.80 ( https://nmap.org ) at 2021-09-30 02:29 CEST NSE: Loaded 1 scripts for scanning. NSE: Script Pre-scanning. Initiating NSE at 02:29 Completed NSE at 02:29, 0.00s elapsed Initiating ARP Ping Scan at 02:29 Scanning 10.129.14.128 [1 port] Completed ARP Ping Scan at 02:29, 0.06s elapsed (1 total hosts) Initiating Parallel DNS resolution of 1 host. at 02:29 Completed Parallel DNS resolution of 1 host. at 02:29, 0.03s elapsed Initiating SYN Stealth Scan at 02:29 Scanning 10.129.14.128 [1 port] Discovered open port 25/tcp on 10.129.14.128 Completed SYN Stealth Scan at 02:29, 0.06s elapsed (1 total ports) NSE: Script scanning 10.129.14.128. Initiating NSE at 02:29 Completed NSE at 02:29, 0.07s elapsed Nmap scan report for 10.129.14.128 Host is up (0.00020s latency).  PORT   STATE SERVICE 25/tcp open  smtp | smtp-open-relay: Server is an open relay (16/16 tests) |  MAIL FROM:<> -> RCPT TO:<relaytest@nmap.scanme.org> |  MAIL FROM:<antispam@nmap.scanme.org> -> RCPT TO:<relaytest@nmap.scanme.org> |  MAIL FROM:<antispam@ESMTP> -> RCPT TO:<relaytest@nmap.scanme.org> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest@nmap.scanme.org> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest%nmap.scanme.org@[10.129.14.128]> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest%nmap.scanme.org@ESMTP> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<"relaytest@nmap.scanme.org"> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<"relaytest%nmap.scanme.org"> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest@nmap.scanme.org@[10.129.14.128]> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<"relaytest@nmap.scanme.org"@[10.129.14.128]> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<relaytest@nmap.scanme.org@ESMTP> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<@[10.129.14.128]:relaytest@nmap.scanme.org> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<@ESMTP:relaytest@nmap.scanme.org> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<nmap.scanme.org!relaytest> |  MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<nmap.scanme.org!relaytest@[10.129.14.128]> |_ MAIL FROM:<antispam@[10.129.14.128]> -> RCPT TO:<nmap.scanme.org!relaytest@ESMTP> MAC Address: 00:00:00:00:00:00 (VMware)  NSE: Script Post-scanning. Initiating NSE at 02:29 Completed NSE at 02:29, 0.00s elapsed Read data files from: /usr/bin/../share/nmap Nmap done: 1 IP address (1 host up) scanned in 0.48 seconds            Raw packets sent: 2 (72B) | Rcvd: 2 (72B)`