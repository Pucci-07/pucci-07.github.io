
![[Pasted image 20260804164153.png]]

on commence par de la reconnaissance avec nmap 
mais en attendant on va voir si un port web est ouvert 

il est bien ouvert une fois sur le site on a sa :

![[Pasted image 20260804164457.png]]


le résultat du scan nmap : 
![[Pasted image 20260804164729.png]]

on voit que à part les port  80 , 443 qui joue presque le meme role  on a pas une surface d'attaque tangible / exploitable 

donc on continu l'exploration du site 
on se promenant sur le site , à cette URL on a cette interface 

![[Pasted image 20260804164632.png]]

la fonctionnalité cible de cette interface est le fait de pouvoir aller sur un site ou de fournit une url et de pouvoir prendre de la donnée 
comme la surface d'attaque n'augmente pas tellement on peut esssayer de faire du fuzzing à la recherche de répertoire caché 

```bash
gobuster dir \
  -u http://cohort.htb \
  -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt \
  -x php,txt,bak,sql,js,html,zip,tar.gz,old,save \
  -r \
  -t 50 \
  -s "200,204,301,302,307,401,403,500" \
  -b "" \
  --exclude-length 908 \
  -k
```


en attendant le scan / fuzzing  gobuster on va tchecker si il ya pas  des vulnérabilités dans les outils de déploiement de déploiement  avec nuclei 

```bash
nuclei -u http://cohort.htb
```

![[Pasted image 20260804180441.png]]

on a pas  de vuln succeptible d'etre exploiter
donc on continue avec gobuster / le fuzzing 
 d'après le scan on  a deux dossier qui on un code 403 : /assets et /status 
 
![[Pasted image 20260804175301.png]] 

qu'est ce qui se passait si on utilises l'outil du site pour accéder à ces URL 
pour : 
/assets on a 
![[Pasted image 20260804175557.png]] 
toujours une erreur 403 

essyont /status 
on a une réposnse  
![[Pasted image 20260804175650.png]]


```json
{"service":"cohort-edge","status":"ok","generated_by":"nginx","upstreams":[{"name":"marketing","host":"cohort.htb","root":"/var/www/cohort"},{"name":"insights-api","host":"cohort.htb","path":"/api/","target":"127.0.0.1:5000"},{"name":"notebooks","host":"nb-1be3782a8afd3ad5.cohort.htb","target":"127.0.0.1:8888","note":"internal analyst workspace, not for external use"}]}

```
on a de potentiel surface d'attaque : 

Première info : 
l'indpoint /api/ est accessibe depuis l'hote cohort.htb mais qui est relier au host 127.0.0.1:5000 dans le dossier /var/www/cohort api qui est surement utiliser par le serveur principal 

deuxieme info 
le  host 1be3782a8afd3ad5.cohort.htb redirige vers le port 8888 du localhost donc acessible de puis la machine attaquante si les config sont bien fait 

les configurations de le fichier /etc/hosts
![[Pasted image 20260804183719.png]] 

je crois que maintenant on  va continuer avec la deuxième info une fois l'url  vister on tombe sur cette page : 

![[Pasted image 20260804183808.png]]

qui demande un tocken d'accès on essai  nb-1be3782a8afd3ad5 pour voir 
![[Pasted image 20260804183925.png]]

notre piste était pas la bonne on va cherche le sercice lancer et possiblement les crédential par défaut ou  une CVE  avec les outils qu'on (internet , nuclei )

le scan avec nuclei : 

![[Pasted image 20260804184749.png]] 
on a rien de concret 
allons faire des recherche 
les recherches me dirige vers cette cve # CVE-2026-39987 - Marimo < 0.23.0 Pre-Auth RCE (WebSocket) 
Pour l'nstant on a pas la version du servcie mais on va tester à l'aveugle pour voir
https://github.com/M3PH1569/CVE-2026-39987-POC/blob/main/README.md 

![[Pasted image 20260804191906.png]]
on a pu lancer une cmd distante id et on a le resultat 
c'est une version vulnérable de l'appli qui est lancer 

avec la POC on peut avoir directement un shell 

![[Pasted image 20260804192341.png]]

![[Pasted image 20260804192931.png]] 
et on a le flag user 

passoons à l'escalade de privilege  (la reconnaissance ))

![[Pasted image 20260804195438.png]]
le  packet 1.2.8-2ubuntu1.2 est un packet vulnérable à un CVE : **CVE-2026-41651 (Pack2TheRoot)** 

la Poc se trouve ici  : [CVE-2026-41651 (Pack2TheRoot)**](https://github.com/shibaaa204/Pack2TheRoot/blob/main/exploit.py)
![[Pasted image 20260804195807.png]]

