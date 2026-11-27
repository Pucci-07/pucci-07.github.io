---
layout: post
title: "Write-up HTB Timelapse"
date: 2026-11-27 02:53:00
description: "Parcours détaillé sur Timelapse : partages SMB, certificat WinRM, secrets exposés dans l’historique PowerShell et configuration LAPS."
tags: [htb, writeup, windows, active-directory, laps]
categories: [Write-ups]
writeup_id: htb-timelapse
writeup_platform: Hack The Box
writeup_title: Timelapse
writeup_language: fr
writeup_difficulty: Easy
writeup_image: assets/img/timelapse-writeups/00-htb-machine-card.png
giscus_comments: true
related_posts: false
---

**Machine** : Timelapse — Easy, Windows<br />
**Auteur** : DoOm / ppporrkkky<br />
**Profil HTB** : [DoOm](https://profile.hackthebox.com/profile/019c56c9-a8f8-721d-ad7b-fd7b3dd2f9de)<br />
**Machine** : [Timelapse sur Hack The Box](https://app.hackthebox.com/machines/Timelapse)

> Ce write-up concerne une machine HTB de laboratoire. Les mots de passe, clés privées, hashes et commandes permettant d’obtenir ou d’utiliser des accès sont volontairement omis des articles et des captures publiées.

## Reconnaissance

Timelapse est une machine Windows qui expose plusieurs services associés à Active Directory. L’énumération révèle notamment DNS, Kerberos, RPC, SMB, LDAP, le catalogue global LDAP et WinRM sur HTTPS. Le nom de domaine observé est `timelapse.htb`; le contrôleur de domaine est `dc01.timelapse.htb`.

{% include figure.liquid path="assets/img/timelapse-writeups/00-htb-machine.png" class="img-fluid rounded z-depth-1" %}

Les services AD indiquent qu’il faut examiner les partages réseau et les méthodes d’authentification disponibles. Le service WinRM standard n’est pas accessible sur son port habituel, mais son endpoint HTTPS sera confirmé plus tard.

{% include figure.liquid path="assets/img/timelapse-writeups/01-ad-scan.png" class="img-fluid rounded z-depth-1" %}

## Énumération des partages SMB

Avec une identité de laboratoire déjà disponible, l’énumération SMB donne accès aux partages `IPC$` et `Shares`. La source d’origine ne précise pas comment les premiers identifiants utilisés à cette étape ont été obtenus; le parcours documenté reprend à partir de la découverte des partages.

`IPC$`, partage administratif standard, ne contient pas ici de fichier utile. Le partage `Shares`, en revanche, présente plusieurs fichiers intéressants :

- une archive `winrm_backup.zip`;
- l’installateur `LAPS.x64.msi`;
- des documents de référence LAPS.

Les guides LAPS confirment que la machine utilise la gestion des mots de passe administrateur locaux. L’archive WinRM mérite une analyse distincte : elle est protégée par mot de passe et contient un conteneur de certificat.

## Archive et certificat client

L’archive protégée est récupérée depuis le partage et son contenu est examiné dans le laboratoire. Une vérification hors ligne du mot de passe permet de l’ouvrir; la valeur du mot de passe n’est pas publiée ici. L’archive contient un fichier PFX, un format qui regroupe généralement un certificat et sa clé privée.

Le PFX est lui-même protégé par une phrase secrète. Après l’avoir déverrouillé dans le laboratoire, les métadonnées du certificat révèlent le nom commun **Legacyy**. Cette valeur fournit une piste pour l’identité qui sera utilisée avec WinRM. Les données cryptographiques et les phrases secrètes restent exclues du write-up.

## Accès initial par WinRM HTTPS

Les vérifications de ports montrent que WinRM sur le port 5985 est filtré tandis que l’endpoint HTTPS sur le port 5986 répond. La connexion par certificat correspond donc mieux au service exposé qu’une authentification WinRM en clair.

{% include figure.liquid path="assets/img/timelapse-writeups/16-winrm-https.png" class="img-fluid rounded z-depth-1" %}

Le certificat indique l’identité `legacyy`, qui est utilisée pour ouvrir une session WinRM. La capture du sujet du certificat est conservée; elle ne contient ni clé privée ni phrase secrète.

{% include figure.liquid path="assets/img/timelapse-writeups/17-certificate-cn.png" class="img-fluid rounded z-depth-1" %}

Une version ancienne d’Evil-WinRM a ensuite échoué côté client avec une erreur liée à la méthode Ruby `File.exists?`, supprimée dans des versions récentes de Ruby. La note d’origine propose de modifier directement le fichier du gem installé sur le système. Ce contournement n’est pas recommandé : il vaut mieux utiliser une version d’Evil-WinRM compatible avec Ruby ou un environnement isolé et reproductible.

La clé privée demandait également sa phrase secrète lors de certaines connexions. Les notes décrivent la création d’une copie sans phrase secrète pour éviter cette invite. Une clé privée non chiffrée augmente le risque en cas de fuite : conserver la clé originale protégée et ne pas publier de copie déverrouillée.

La session obtenue correspond au compte `legacyy`. À ce stade, l’accès est un compte utilisateur et non une session administrateur.

## Recherche d’identifiants locaux

L’énumération de la machine révèle qu’un historique PowerShell contient une commande de connexion avec des identifiants de service. Le secret associé au compte `svc_deploy` était donc conservé en clair dans un fichier d’historique accessible à l’utilisateur connecté.

Cette découverte fournit une nouvelle piste d’authentification et permet d’ouvrir une session WinRM sous `svc_deploy`. Les identifiants eux-mêmes ne sont pas reproduits : un historique de commandes peut contenir des secrets réels et doit être traité comme une donnée sensible.

## LAPS et accès administrateur local

La session `svc_deploy` dispose d’un accès de lecture aux informations LAPS de l’ordinateur cible. Dans cette machine, cet accès permet de récupérer le mot de passe administrateur local géré par LAPS, puis d’ouvrir une session avec le compte `Administrator`.

Une précision importante : l’ancienne génération de Microsoft LAPS stocke le mot de passe dans un attribut de l’objet ordinateur Active Directory, dont la lecture est contrôlée par des permissions. Windows LAPS peut prendre en charge le chiffrement des mots de passe selon sa configuration; il ne faut donc pas supposer que toutes les installations LAPS chiffrent automatiquement la valeur stockée.

## Privilèges de sauvegarde et portée de l’accès

L’énumération sous le compte administrateur local met en évidence le privilège Windows `SeBackupPrivilege`.

{% include figure.liquid path="assets/img/timelapse-writeups/30-privilege-enumeration.png" class="img-fluid rounded z-depth-1" %}

Ce privilège concerne les opérations de sauvegarde et peut permettre à un administrateur autorisé de lire des fichiers protégés en utilisant les mécanismes de sauvegarde Windows. Il ne faut toutefois pas le confondre avec les permissions de réplication Active Directory : `SeBackupPrivilege` seul ne prouve pas qu’un compte possède les droits DCSync.

Les notes d’origine rapportent ensuite une extraction de données d’authentification du domaine à l’aide d’outils Impacket. Elles ne documentent pas clairement si cette extraction repose sur une copie de sauvegarde hors ligne ou sur des droits de réplication. Ces mécanismes sont distincts; la méthode exacte doit être vérifiée avant d’attribuer l’extraction au seul privilège de sauvegarde. Les commandes et les hashes ne sont pas publiés.

## Recommandations

- Restreindre les partages SMB et vérifier régulièrement les fichiers qui y sont déposés.
- Ne pas stocker de clés privées, certificats protégés ou mots de passe en clair dans des archives et historiques de commandes.
- Mettre à jour les outils clients et préférer un environnement isolé à la modification manuelle d’un gem système.
- Protéger les clés privées par une phrase secrète et limiter leur durée de conservation.
- Restreindre la lecture des attributs LAPS aux seuls groupes qui en ont réellement besoin.
- Vérifier séparément les privilèges locaux de sauvegarde et les droits de réplication AD; ne pas accorder ces permissions à des comptes de service sans justification.

## Conclusion

Timelapse illustre une chaîne de mauvaises pratiques plutôt qu’une seule faille : des fichiers sensibles exposés via SMB, un certificat permettant l’authentification WinRM, des identifiants laissés dans l’historique PowerShell, puis une lecture LAPS trop largement accordée. Chaque étape augmente les privilèges disponibles; protéger les secrets et réduire les permissions aurait interrompu cette progression.

## Références

- [Machine Timelapse — Hack The Box](https://app.hackthebox.com/machines/Timelapse)
