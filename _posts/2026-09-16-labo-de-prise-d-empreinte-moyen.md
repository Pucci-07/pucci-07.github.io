---
layout: post
title: "labo de prise d empreinte moyen"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

[[Footprinting HTB]]
Ce second serveur est un serveur auquel tout le monde sur le réseau interne a accès. Lors de notre discussion avec notre client, nous avons souligné que ces serveurs sont souvent l'une des principales cibles des attaquants et que ce serveur devrait être ajouté au périmètre (scope).

Notre client a accepté et a ajouté ce serveur à notre périmètre. Ici aussi, l'objectif reste le même. Nous devons trouver autant d'informations que possible sur ce serveur et trouver des moyens de les utiliser contre le serveur lui-même. Pour la preuve et la protection des données du client, un utilisateur nommé `HTB` a été créé. Par conséquent, nous devons obtenir les identifiants (credentials) de cet utilisateur comme preuve.

on commence par de l'énumération  classique avec nmap 

![Pasted image 20260910013323.png](/assets/img/writeups/Pasted image 20260910013323.png)

donc ici le service suceptible d'etre notre cible est le rpc plus précisement le serveice NFS (Network file share ) 

l'enumeration 
elle peut se faire avec l'outil showmount  

![Pasted image 20260910013843.png](/assets/img/writeups/Pasted image 20260910013843.png)

on voit que le dossier ou fihier partagé en accès à tout le monde est TechSupport 
on va essayer de le monter avec  la commande mount  et il faudrait que le dossier de reception du dossier soit vide 

la comande est : mount -t nfs $ ip:/$partage  /chemin/de/reception/du/partage 

![Pasted image 20260910015017.png](/assets/img/writeups/Pasted image 20260910015017.png)

listons maintenant le dossier de reception : 

![Pasted image 20260910015110.png](/assets/img/writeups/Pasted image 20260910015110.png)

donc on doit maintenant filtrer le fichier pour trouver une correspodnace à l'interieur ave 'HTB'
la commande est 
grep -r 'HTB'  /chemin/de/reception/du/partage  

après filitrage on a rien trouver donc allons sur une autre piste

revenons en arrière le filtrage à été mal fait au lieu de chercher le char HTB dans tout les fichier et si on essayait de voir quel fichier n'est pas vide car oui  la plus par des fichier sont vides 

on va utiliser la cmd : ls -la pour le tcheck 

![Pasted image 20260910020722.png](/assets/img/writeups/Pasted image 20260910020722.png) 
le 0  montrent que le fichier cible est vide donc on cherhe un truc différent de 0 
![Pasted image 20260910021011.png](/assets/img/writeups/Pasted image 20260910021011.png)

on l'a le fichier non vide en l'affichant on a : 

![Pasted image 20260910021105.png](/assets/img/writeups/Pasted image 20260910021105.png)

ici on a la structure d'un message snmtp envoyer et les identifiants de l'expediteurs : "alex:lol123!mD" qui les envoi  avec le nom de l'hote smtp cible qui est : smtp.web.dev.inlanefreight.htb 

la communication avec le host  smtp.web.dev.inlanefreight.htb n'aboutie pas 

![Pasted image 20260910023842.png](/assets/img/writeups/Pasted image 20260910023842.png)

![Pasted image 20260910023914.png](/assets/img/writeups/Pasted image 20260910023914.png)

n'oubliez pas on avait vu au dessus un service sur le 3389 (le rdp) qui permet un accès direct au système testons cette piste 

la commande :  xfreerdp3 /u:"alex" /p:'lol123!mD' /v:"$ip"

 ![Pasted image 20260910024130.png](/assets/img/writeups/Pasted image 20260910024130.png)

on a une session !!! 
déja ce qui nous intrigue le user alex à un systeme de gestion de base de données pour gérer quoi ? des bases de données et qui  dit bases de données dit de potentiels utilisateurs et possiblement des mot de passes 
donc allez tchecker sa serait pas une mauvaise idée 


![Pasted image 20260910024637.png](/assets/img/writeups/Pasted image 20260910024637.png)

les 1 et 2 représente les identifiants utilisé pour la connexion mai ceux si passent pas ce qui à causer l'erreur au 3 

plusieur  tenatatives on été faite incluant les crédentials utilisés pour le module concernant le MSSQL du footprinting  mais ceux si ne marhent pas 

si on est un peut vagabond une fois arriver sur le répertoire du user alex on a :  

![Pasted image 20260910030147.png](/assets/img/writeups/Pasted image 20260910030147.png)

le dossier devshare qui n'est pas un fichier par défaut à ce enplacement on va juste vérifier son contenu comme on dit on sait jamais 
![Pasted image 20260910030356.png](/assets/img/writeups/Pasted image 20260910030356.png)

comme tout ce qui est 'important' interesse les attaquants on va voir  l'importance de ce fichier  

![Pasted image 20260910030548.png](/assets/img/writeups/Pasted image 20260910030548.png)

on a sa 'sa:87N1ns@slls83'  qui d'après moi ressemble à des identifiants et quand on ouvre notre gestionnaire de base de donné MSSQL on a  : 

![Pasted image 20260910031028.png](/assets/img/writeups/Pasted image 20260910031028.png)

le paramètre login qui a déja une valeur sa qui  nous attends sagement donc il demande que son second (le mot de passe ) qui est : 87N1ns@slls83 

![Pasted image 20260910032814.png](/assets/img/writeups/Pasted image 20260910032814.png)

meme avec les théoriquements  bons creds sa pass pas on va essayeé de changé le nom d'utilisateur pour voir 
![Pasted image 20260910032948.png](/assets/img/writeups/Pasted image 20260910032948.png)
le user alex n'a pas pris 

![Pasted image 20260910033111.png](/assets/img/writeups/Pasted image 20260910033111.png) 
le user administrator aussi n'a pas pris 

on va voir si le passe est un passe d'admin  pourquoi ? parce que il existe la version de notre gestionnaire en CLI nommé   SQLPS.exe  ou on peut tchecker si on a des modules de querry de bases de donnée MSSQL

![Pasted image 20260910034802.png](/assets/img/writeups/Pasted image 20260910034802.png)

![Pasted image 20260910034827.png](/assets/img/writeups/Pasted image 20260910034827.png)

on a la session 

maintenant on a voir si on a les modules necessaires pour le querry de MSSQL 

![Pasted image 20260910040654.png](/assets/img/writeups/Pasted image 20260910040654.png) 
on a un module déja sur le système qui n'attend qu"a etre importer  
la commande  :  import-module nom_du_module

![Pasted image 20260910040809.png](/assets/img/writeups/Pasted image 20260910040809.png)

on peut tester une requètes pour avoir les bases de données  

![Pasted image 20260910040937.png](/assets/img/writeups/Pasted image 20260910040937.png)

la base de données qu'on va cibler est accounts  

maintenant on veut avoir le(s) table(s)

![Pasted image 20260910041145.png](/assets/img/writeups/Pasted image 20260910041145.png)
la table dispo  est  : devsacc 

maintenant lister le contenu de la table cible  pour voir le contenu 
![Pasted image 20260910041320.png](/assets/img/writeups/Pasted image 20260910041320.png)

la logique suit ce qui est demander (c'est à dire le mot de passe de HTB) 

![Pasted image 20260910041509.png](/assets/img/writeups/Pasted image 20260910041509.png)

et on a le flag de ce lab 
gg !! 