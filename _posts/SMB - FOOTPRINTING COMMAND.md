[[SMB]]

``` bash 
nmap -sCV -p445,139 -T5 

``` 

cette commande sert  à une recon de base du service cible sur les ports spécifier 

```bash
smbclient -N -L  //$smb_host 
```
cette commande nous permet si le serveur cible est configurer pour , d'effectuer  une connexion null session (-N) et  de lister les différents partages du host  (-L) 
Donc l'énumération de partages est possible avec ici 

```bash
nxc smb $target_ip -u '$target_user' -p '$target_user_pass' --shares 
```
énumérer les partages et les permission qu'a l'utilisateur si sa session est valide et les partages du serveur SMB cible


```bash
smbclient //$smb_host/$share  
```
permet  de se connecter à un  partage au quel on a une session utilisateur valide  ( cette commande utilise du null session pour la connexion ) , des permissions valide sur le serveur smb cible a fin d'énumérer manuellement les fichiers partagés 

```bash
nxc smb $target_ip -u '$target_user' -p '$target_user_pass' --spider $target_share -pattern .  
```

permet de lister tout le contenu d'un  partage cible  au quel on a une session utilisateur valide   et des permissions valides sur le serveur smb cible 

```bash
nxc smb $target_ip -u '$target_user' -p '$target_user_pass' --get-file //$target_ip/$target_share/schemin_vers_le_fichier fichier_local 
```

