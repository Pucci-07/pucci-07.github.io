---
layout: post
title: "Write-up TryHackMe Attacktive Directory"
date: 2026-11-27 02:53:00
description: "Parcours de la room Attacktive Directory : reconnaissance AD, compte Kerberos sans pré-authentification, partage SMB et privilèges de réplication."
tags: [tryhackme, writeup, windows, active-directory, kerberos]
categories: [Write-ups]
writeup_id: thm-attacktive-directory
writeup_platform: TryHackMe
writeup_title: Attacktive Directory
writeup_language: fr
writeup_image: assets/img/attacktive-directory/00-thm-room-card.png
giscus_comments: true
related_posts: false
---

**Room** : Attacktive Directory — TryHackMe<br />
**Auteur** : [0xD4C](https://tryhackme.com/p/0xD4C)<br />
**Room** : [Attacktive Directory sur TryHackMe](https://tryhackme.com/room/attacktivedirectory)

> Ce write-up décrit une room TryHackMe et un environnement de laboratoire autorisé. Les mots de passe, hashes et commandes permettant d’obtenir ou de réutiliser des accès sont volontairement omis.

## Reconnaissance Active Directory

La première phase consiste à identifier les services exposés par le contrôleur de domaine. Le scan fourni montre notamment DNS, Kerberos, LDAP, SMB et RDP. Les ports LDAP 389 et Global Catalog 3268 permettent d’interroger les services d’annuaire; Kerberos est disponible sur son port standard.

{% include figure.liquid path="assets/img/attacktive-directory/00-thm-room.png" class="img-fluid rounded z-depth-1" %}

Les réponses du serveur donnent les informations de domaine suivantes :

- domaine DNS : `spookysec.local`;
- nom NetBIOS : `THM-AD`;
- nom de l’ordinateur : `ATTACKTIVEDIREC`;
- système : Windows Server.

{% include figure.liquid path="assets/img/attacktive-directory/01-ad-scan.png" class="img-fluid rounded z-depth-1" %}

SMB est également exposé sur les ports 139 et 445. Même si la première énumération ne révèle pas immédiatement de fichier intéressant, le service reste une piste à revisiter après l’obtention d’identifiants.

## Comptes Kerberos et pré-authentification

L’énumération des comptes du domaine révèle plusieurs noms valides, dont `svc-admin`, `backup`, `administrator` et `paradox`. La sortie indique que `svc-admin` n’exige pas la pré-authentification Kerberos.

Lorsqu’un compte est configuré ainsi, une requête Kerberos peut fournir un bloc de données chiffré avec un secret dérivé du mot de passe du compte. Ce type de réponse peut faire l’objet d’une vérification hors ligne dans un audit autorisé : un mot de passe faible peut alors être deviné sans envoyer une série de tentatives de connexion au contrôleur de domaine.

Une première tentative de vérification du hash fourni par l’outil d’énumération ne donne pas de résultat. La cause relevée dans les notes est un format de hash incompatible avec le mode de vérification utilisé. En récupérant une sortie au format attendu par l’outil de vérification, l’audit hors ligne aboutit à un mot de passe faible pour `svc-admin`. Les hashes et le mot de passe ne sont pas publiés.

Cette étape illustre pourquoi il faut distinguer la découverte d’un compte, la génération d’un hash et son format : un mauvais format peut faire échouer une vérification sans invalider la piste.

## Accès SMB et partage de sauvegarde

Les identifiants du compte `svc-admin` permettent d’énumérer les partages SMB. Le partage `backup` est particulièrement intéressant et devient accessible avec un second compte de service, `backup`.

Le partage contient un fichier nommé `backup_credentials.txt`. Son contenu est encodé en Base64. Base64 est un encodage, pas un chiffrement : toute personne qui peut lire le fichier peut retrouver son contenu original sans disposer d’une clé cryptographique. Les identifiants décodés ne sont pas reproduits dans cet article.

## Compte de sauvegarde et privilèges d’annuaire

Le compte `backup` permet une session RDP sur le contrôleur de domaine. L’examen de ce compte révèle des droits sensibles liés à la réplication Active Directory. De tels droits sont réservés aux rôles qui doivent réellement répliquer des données d’annuaire; attribués à un compte de sauvegarde sans nécessité, ils peuvent exposer les informations d’authentification du domaine.

Les notes d’origine utilisent un outil Impacket pour récupérer des données de hachage du domaine. Les commandes et valeurs récupérées sont omises. Le point important est l’impact des permissions : un compte de sauvegarde ne devrait pas disposer par défaut de droits permettant de lire les secrets de tous les utilisateurs.

## Validation de l’impact

Les données d’authentification obtenues dans le laboratoire montrent que les privilèges du compte de sauvegarde dépassent son besoin apparent. Les notes décrivent ensuite une validation de l’accès administrateur à l’aide d’un hash NTLM. Le hash, la commande de réutilisation et les données de compte ne sont pas reproduits.

Cette démonstration met en évidence le risque des secrets d’annuaire : une permission de réplication mal attribuée peut transformer un compte de service compromis en compromission étendue du domaine.

## Recommandations

- Exiger la pré-authentification Kerberos pour tous les comptes qui n’ont pas de besoin documenté de la désactiver.
- Utiliser des mots de passe longs et uniques; privilégier des comptes de service gérés lorsque c’est possible.
- Ne pas déposer d’identifiants dans des partages SMB; Base64 ne protège pas un secret.
- Restreindre les droits de réplication Active Directory aux comptes strictement nécessaires et auditer régulièrement leurs attributions.
- Limiter les comptes de service aux ressources requises; éviter de leur accorder RDP ou des rôles d’administration sans justification.
- Réagir immédiatement à l’exposition d’un mot de passe ou d’un hash : rotation, révocation des sessions et vérification des accès effectués.

## Conclusion

Attacktive Directory montre comment plusieurs erreurs s’enchaînent : pré-authentification désactivée sur un compte, mot de passe faible, identifiants encodés dans un partage SMB et privilèges de réplication accordés à un compte de sauvegarde. La défense repose sur des identifiants robustes, la protection des secrets et une attribution minimale des permissions AD.

## Références

- [Room Attacktive Directory — TryHackMe](https://tryhackme.com/room/attacktivedirectory)
