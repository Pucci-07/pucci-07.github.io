[[Footprinting HTB]]
La société `Inlanefreight Ltd` nous a mandatés pour tester trois serveurs différents sur son réseau interne. L'entreprise utilise de nombreux services différents, et le département de sécurité informatique a estimé qu'un test d'intrusion (penetration test) était nécessaire pour avoir un aperçu de sa posture de sécurité globale.

Le premier serveur est un serveur DNS interne qui doit être examiné. Notre client souhaite notamment savoir quelles informations nous pouvons obtenir de ces services et comment ces informations pourraient être utilisées contre son infrastructure. Notre objectif est de recueillir autant d'informations que possible sur le serveur et de trouver des moyens d'utiliser ces informations contre l'entreprise. Cependant, notre client a clairement indiqué qu'il est interdit d'attaquer les services de manière agressive en utilisant des exploits, car ces services sont en production.

De plus, nos coéquipiers ont trouvé les identifiants suivants "ceil:qwer1234", et ils ont signalé que certains employés de l'entreprise parlaient de clés SSH sur un forum.

Les administrateurs ont stocké un fichier `flag.txt` sur ce serveur pour suivre notre progression et mesurer notre réussite. Énumérez entièrement la cible et soumettez le contenu de ce fichier comme preuve.

on a : ceil:qwer1234  qui sont surement respectivement le nom d'utilisateur et le mot de passe d'un compte valide 

![[Pasted image 20260910004301.png]]

le nmap sur la cible montre que on a quatres  services lancer sur lhote et poour nous aus moins deux sont exploitables : 
le ssh et le ftp commencons par le ftp  
ici on va initier une connexion en anonymous pour voir la réponse et si sa prends pas en va essayer avec les crédentials  'ceil:qwer1234' donnés 

![[Pasted image 20260910004636.png]]

la connexion en anonymous n'est pas autorisé  essayons  avec les credentials donné pour voir 
![[Pasted image 20260910004802.png]]
on a accès au système maintenant on va enumerer les dossiers aux quels on a accès 

![[Pasted image 20260910005509.png]]

on a rien de juteux on prettant attantion au résultat nmap le 2121 on  a  sa 

![[Pasted image 20260910005635.png]] 
'Ceil ftp' comme si c'est la que l'utilisateur Ceil doit se connecter pour le ftp allons vérifier alors 

![[Pasted image 20260910005828.png]]

donc on a vu juste c'est le ftp spécial du user Ceil 
donc maintenant les données qui pouuraient nous interesser serait celles trouvers dans le .ssh , .bash_history 

commencons par le .ssh 

![[Pasted image 20260910010216.png]]

on a les clé de connections ssh de l'utilisateur ceil et celle qui nous interesse plus est la id_rsa qui est la clé privé que le client doit présenté au serveur pour valider l'authentification 

![[Pasted image 20260910010426.png]]

une fois télécharger on peut tenter d'initier une connection ssh vers l'ip cible 

mais d'abord changer les permission du fichier  qu'on vient de changer sinon il serait rejeter par l'agent ssh de connexion 
la commande :  chmod 400 id_rsa 

maintenant on peut tenter d'initier la connection vers lhote cible 

![[Pasted image 20260910010807.png]]

une fois bon on a accès au ssh de l'utilisateur cible maintenant à  nous de cherchez le flag : 
on sait que le truc qu'on cherche  est un fichier et il est nommé flag.txt 
donc on peut le retrouver avec la commande find : 
find / -type f  -name flag.txt 2>/dev/null 

![[Pasted image 20260910011256.png]] 
et on a le flag qui était dans /home/flag 

Fin 


