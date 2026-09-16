
[[Command Prompt Basics]]

![[Pasted image 20260904024513.png]]

![[Pasted image 20260904024620.png]]

on a le flag entouré en rouge 

![[Pasted image 20260904024700.png]]


![[Pasted image 20260904024809.png]] on a le flag entouré en rouge 

![[Pasted image 20260904024910.png]]
donc ici il s'agit de trouver le nom de l'hote cible avec la commande hostname qui  donne ACADEMY-ICL11

![[Pasted image 20260904025052.png]]

qui est le mot de passe de l'utilisateur user2 

![[Pasted image 20260904025223.png]] 
on a pas le mot de passe du user3  donc on doit ce connecter sur le user2 à la recherche du passe du user3 avec le mot de passe  ACADEMY-ICL11
mais quand on essait le pass ACADEMY-ICL11 avec le user2 sa passe pas mais avec le user3 sa passe Tand mieux alors 

la commande pour afficher les fichiers cacher dnas cmd.exe est : dir /A:H

la commande dir simple nous donne : 
![[Pasted image 20260904030105.png]]
 
 maintenant dir /A:H nous donne sa 
![[Pasted image 20260904030156.png]]

et à la fin on a  : 
![[Pasted image 20260904030235.png]] 
le nombre de  fichier cacher qui est de 101  et qui est en meme temps le passe pour user 4

![[Pasted image 20260904031046.png]]

on va utiliser powershell pour cela avec Get-Childitem 

d'abord affichons le contenu de document 

![[Pasted image 20260904032327.png]]

on a  des dossier 
afichons alors recursivement le contenu des dossier  avec 

```powershell 
get-childItem -Recurse 
```
![[Pasted image 20260904032506.png]]

on a cette sortie tout au long 
alorrs comment filtrer ? 
il faut remarquer que quand le fichier est vide sur window le paramètre Length est à 0 donc on va essayer de filtre en affichant que les documents avec des données à l'intérieur donc des fichiers dont le paramètres Length est différent de 0 avec : 

```Powershell
Get-ChildItem -Recurse  | where {$_.Length -ne "0"} | where {$_.Name -eq "flag.txt"} |   fl
```

![[Pasted image 20260904033615.png]]
on a le chemin du fichier cible 

![[Pasted image 20260904033721.png]] 
et le flag chercher 

![[Pasted image 20260904033829.png]]
on recherche le nombre d'utilisateurs du systèmes 
la commande get-localuser peut nous aider dans cette mission 

![[Pasted image 20260904034002.png]]

une fois le décompte et le retrait cible fais on obtient 14 comptes valides sur l'hote
d'après le hint on doit avoir les information sur le systeme pour retrouver ce qui est cherché  donc comme commande de base on a : 
![[Pasted image 20260904040212.png]] 
on a pas le droit d'accès a cette commade on va utiliser une alternative powershell : 

```powershell
get-computerinfo
```


la sortie nou montre : 
![[Pasted image 20260904040339.png]]

l'utilisateur tend cherché qui est htb-student qui sera le mot de passe de la prochaine étape 

![[Pasted image 20260904040506.png]]

etablissons la connexion ssh avec le user7 et le password htb-student

![[Pasted image 20260904043941.png]]

ensuite voir les module dispo pour notre utilisateur  avec la commande : Get-module

![[Pasted image 20260904044105.png]]

nous c'est module de nom Flag-Finder avec la commande Get-Flag qui  nous interresse 

![[Pasted image 20260904044223.png]]

et on a le flag 

![[Pasted image 20260904044348.png]] 
donc on fera de l'énumération AD avec get-aduser et appliquer des filtres

```Powershell
Get-ADUser -Filter {Name -Like "*Flag*"}
```

![[Pasted image 20260904045258.png]]

![[Pasted image 20260904050204.png]]on va utiliser une combinaison de commandes incluant tasklist et sort 

tasklist  | sort name -Descending

![[Pasted image 20260904050337.png]] 
on a le service cible qui est  le flag 

![[Pasted image 20260904050436.png]]

``` Powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625} | Group-Object {$_.Properties[5].Value} | Sort-Object Count -Descending | Select-Object -First 5 Count, Name
```
    
![[Pasted image 20260904051429.png]]