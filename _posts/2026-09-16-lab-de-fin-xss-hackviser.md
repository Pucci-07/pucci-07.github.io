---
layout: post
title: "lab de fin xss hackviser"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

[[Cross-site Scripting (XSS)]]

![Pasted image 20260915193856.png](/assets/img/writeups/Pasted image 20260915193856.png)


![Pasted image 20260915193828.png](/assets/img/writeups/Pasted image 20260915193828.png)

donc on se log avec les credentials donné pour voir : 
![Pasted image 20260915194014.png](/assets/img/writeups/Pasted image 20260915194014.png) 
j'avais déja initier le lab avant d'ou  les messages  mais en gros c'est de l'exploitation de XSS de manière à avoir un tocken admin pour ensuite recupérer la session admin et volà quoi 

on va tester le truc avec un payload basique 
```js
<script>alert("mon premier lab XSS")</script>
```

![Pasted image 20260915194440.png](/assets/img/writeups/Pasted image 20260915194440.png)


en envoi et on voit 

![Pasted image 20260915194519.png](/assets/img/writeups/Pasted image 20260915194519.png)

et boom c'est bon on a du XSS mais on c'est pas encore le type

maintenant recuperons le token admin pour voir 

```js
<script>alert(document.cookie)</script>
```

![Pasted image 20260915194808.png](/assets/img/writeups/Pasted image 20260915194808.png)

on envoi pour voir 

![Pasted image 20260915194844.png](/assets/img/writeups/Pasted image 20260915194844.png)

on voit que notre premiere tentative XSS reviens malgré le fait qu'on renvoit donc on est face à du stored XSS 

![Pasted image 20260915194948.png](/assets/img/writeups/Pasted image 20260915194948.png)

et ensuite le token 'possiblement' admin  

on va essayer d'envoyer  le token  pour voir la session qu'on va obtenir : 
s6utb0m2ih869jchhqa5vgpobr

![Pasted image 20260915195216.png](/assets/img/writeups/Pasted image 20260915195216.png)

la valeur à changer est celle du paramètre PHPSID 

![Pasted image 20260915195422.png](/assets/img/writeups/Pasted image 20260915195422.png) 
au 1 : on a la valeur du 'potentiel' token admin 
au 2 : on doit désactiver l'option intercept on en off pour laisser le traffic passer et voir 
![Pasted image 20260915195710.png](/assets/img/writeups/Pasted image 20260915195710.png)

le résultat voulu n'est pas afficher essayons autre chose 

NB : vous aurez noter que le token recupérer est au fait le token de notre utilisateur donc on c'est reconnecter en tand que nous meme au fait 

