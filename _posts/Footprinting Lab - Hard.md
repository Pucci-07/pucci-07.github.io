[[Footprinting HTB]]
The third server is an MX and management server for the internal network. Subsequently, this server has the function of a backup server for the internal accounts in the domain. Accordingly, a user named `HTB` was also created here, whose credentials we need to access.

on commence par le classique nmap 

![[Pasted image 20260910142207.png]]

les services potentiellement exploitables ici sont le pop3 et le imap 
on va essayé de lancer des scan nmap de brute force pour voir 

![[Pasted image 20260910143416.png]]

on a pas de résultat satisfaisant 
si on se rappelle on avait afficher le contenu d'un partage ou on avait peut voir les id d'un user alex:lol123!mD 

![[Pasted image 20260910021105.png]]

donc ce sont les creds de l'utilisateur alex concernant le serveur smtp 
les infos qu'on a 
user : alex
password : lol123!mD 
mail address : alex.g@web.dev.inlanefreight.htb 

donc on peut tenter quelque chose avec sa  

initiation de la connexion  

openssl s_client -connect $ip:imaps 

![[Pasted image 20260910153000.png]]

la sorti ressemble est ci dessus  
maintenant initions la connexion au compte 

? lOGIN alex lol123!mD 

![[Pasted image 20260910153313.png]]
nos crédentials ne sont pas validés 

