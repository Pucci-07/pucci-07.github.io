
![[Pasted image 20260809092917.png]] 
on commence la reconaissance avec le classique nmap
![[Pasted image 20260809093124.png]]

on a le  443 et le 22 qui sont ouvert  le service le plus probable d'etre une surface d'attaque est le HTTPS lancer sur le 443 
une fois sur le site on a sa 

![[Pasted image 20260809094828.png]]

on va utiliser un moteur de recherche de vulnérabilités au niveau des applications web 
```bash
nuclei -u $ip 
```
![[Pasted image 20260809095103.png]]

on a un CVE  intituler : CVE-2026-63030  / wp2shell pour plus d'info vous pouvez venir cliquer sur ce lien https://github.com/0xsha/wp2shell qui  a aussi la Poc cible  
une fois cloner le script  wp2shell.py vient avec la possibilité d'avoir un shell directement sans passer par un listner 

```bash
./wp2shell.py shell https://target -i
```

