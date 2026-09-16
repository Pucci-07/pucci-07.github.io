[[Windows (HTB)]]

Inlanefreight a récemment connu un incident au cours duquel un employé mécontent du service marketing a accédé à un partage RH hébergé en interne et a supprimé plusieurs fichiers et dossiers confidentiels. Heureusement, l'équipe informatique disposait de bonnes sauvegardes et a restauré toutes les données supprimées. On s'inquiète maintenant du fait que cet employé mécontent ait pu, en premier lieu, accéder au partage RH. Après avoir réalisé une évaluation de la sécurité, vous avez découvert que l'équipe IT ne comprend peut-être pas entièrement le fonctionnement des autorisations (permissions) dans Windows. Vous organisez une formation et une démonstration pour montrer au service les bonnes pratiques de sécurité en matière de partage de fichiers dans un environnement Windows, ainsi que la consultation des services depuis la ligne de commande pour vérifier toute manipulation potentielle.

Remarque : Il est important que chaque étape soit réalisée dans l'ordre de présentation. Commencez par l'étape 1 et progressez jusqu'à l'étape 8, en incluant toutes les spécifications associées à chaque étape. Sachez que chaque étape est conçue pour vous donner l'occasion d'appliquer les compétences et les concepts enseignés tout au long de ce module. Prenez votre temps, amusez-vous et n'hésitez pas à demander de l'aide si vous êtes bloqué.

Dans cette démonstration, vous allez :

## 1. Créer un dossier partagé nommé Company Data

![Pasted image 20260828121658.png](/assets/img/writeups/Pasted image 20260828121658.png)


![Pasted image 20260828121752.png](/assets/img/writeups/Pasted image 20260828121752.png)

![Pasted image 20260828122021.png](/assets/img/writeups/Pasted image 20260828122021.png)

![Pasted image 20260828122059.png](/assets/img/writeups/Pasted image 20260828122059.png)

![Pasted image 20260828122141.png](/assets/img/writeups/Pasted image 20260828122141.png)


## 2. Créer un sous-dossier nommé HR à l'intérieur du dossier Company Data

![Pasted image 20260828122230.png](/assets/img/writeups/Pasted image 20260828122230.png)
## 3. Créer un utilisateur nommé Jim

- `Décocher : L'utilisateur doit changer le mot de passe à la prochaine ouverture de session`
![Pasted image 20260828122318.png](/assets/img/writeups/Pasted image 20260828122318.png)

## 4. Créer un groupe de sécurité nommé HR

![Pasted image 20260828122414.png](/assets/img/writeups/Pasted image 20260828122414.png)

## 5. Ajouter Jim au groupe de sécurité HR

![Pasted image 20260828122940.png](/assets/img/writeups/Pasted image 20260828122940.png)
## 6. Ajouter le groupe de sécurité HR au dossier partagé Company Data et à la liste des autorisations NTFS

- `Supprimer le groupe présent par défaut`
-![Pasted image 20260828124241.png](/assets/img/writeups/Pasted image 20260828124241.png)
- `Autorisations de partage : Autoriser Modifier et Lecture`

![Pasted image 20260828124659.png](/assets/img/writeups/Pasted image 20260828124659.png)

![Pasted image 20260828124818.png](/assets/img/writeups/Pasted image 20260828124818.png)



![Pasted image 20260828123700.png](/assets/img/writeups/Pasted image 20260828123700.png)

- `Désactiver l'héritage avant d'attribuer des autorisations NTFS spécifiques`
- `Autorisations NTFS : Modification, Lecture et exécution, Affichage du contenu du dossier, Lecture, Écriture`

![Pasted image 20260828125423.png](/assets/img/writeups/Pasted image 20260828125423.png)

## 7. Ajouter le groupe de sécurité HR à la liste des autorisations NTFS du sous-dossier HR

- `Supprimer le groupe présent par défaut`
- `Désactiver l'héritage avant d'attribuer des autorisations NTFS spécifiques`
- `Autorisations NTFS : Modification, Lecture et exécution, Affichage du contenu du dossier, Lecture, et Écriture`
-![Pasted image 20260828125808.png](/assets/img/writeups/Pasted image 20260828125808.png)

## 8. Utiliser PowerShell pour lister les détails d'un service

![Pasted image 20260828125757.png](/assets/img/writeups/Pasted image 20260828125757.png)
---



![Pasted image 20260828132001.png](/assets/img/writeups/Pasted image 20260828132001.png)

rep : everyone 

![Pasted image 20260828132026.png](/assets/img/writeups/Pasted image 20260828132026.png) 
rep : security 

![Pasted image 20260828132049.png](/assets/img/writeups/Pasted image 20260828132049.png)

 ```Powershell
(Get-LocalGroup -Name "HR").SID.Value
 ```
 