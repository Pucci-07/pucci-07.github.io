---
layout: post
title: "wu warmup tiger hackviser"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

site : https://app.hackviser.com/warmups/tiger 

![Pasted image 20260723090838.png](/assets/img/writeups/Pasted image 20260723090838.png)

Question 1 
![Pasted image 20260723090913.png](/assets/img/writeups/Pasted image 20260723090913.png) 

vnc signifie Virtual Network Computing 

Question 1 
![Pasted image 20260723091057.png](/assets/img/writeups/Pasted image 20260723091057.png)

![Pasted image 20260723091201.png](/assets/img/writeups/Pasted image 20260723091201.png)

le scan nmap montre  seul le port 5901 comme ouvert  et si on lit bien le résultat de scan on a : 
![Pasted image 20260723091412.png](/assets/img/writeups/Pasted image 20260723091412.png)
un serveur vnc qui est lancé sur le port 5901 qui n'a pas de protocole d'authentification

![Pasted image 20260723093322.png](/assets/img/writeups/Pasted image 20260723093322.png)

comme client vnc on peut utiliser remmina 

![Pasted image 20260723093519.png](/assets/img/writeups/Pasted image 20260723093519.png)

on a içi l'utilitaire de connexion remmina  
l'option 1 permet de specifier le protocole de connexion  à utiliser  ( vnc dans notre cas )
l'option 2 permet de spécifier l'adresse ip cible  et le port du service cible 

une fois lancer  on a un accès un accès à distance de la cible : 

![Pasted image 20260723094022.png](/assets/img/writeups/Pasted image 20260723094022.png) 

![Pasted image 20260723094743.png](/assets/img/writeups/Pasted image 20260723094743.png)
maintenant connecter on peut ouvrir  le terminal et ensuite lancer la commande : whoami 
pour avoir l'utilisateur 

![Pasted image 20260723094948.png](/assets/img/writeups/Pasted image 20260723094948.png) 
la commande uname -a peut aider içi 

![Pasted image 20260723095028.png](/assets/img/writeups/Pasted image 20260723095028.png)
la commande ps aux peux aider içi 

![Pasted image 20260723095303.png](/assets/img/writeups/Pasted image 20260723095303.png)
d'abord savoir ou se trouve les logs du vnc utiliser serait une piste solide 

![Pasted image 20260723095640.png](/assets/img/writeups/Pasted image 20260723095640.png)

on a un dossier .vnc qui  serait bien a explorer 

![Pasted image 20260723095819.png](/assets/img/writeups/Pasted image 20260723095819.png)
le premier fichier nous interesse 

![Pasted image 20260723100034.png](/assets/img/writeups/Pasted image 20260723100034.png)
- 

donc l'adresse ip chercher est 10.1.9.23