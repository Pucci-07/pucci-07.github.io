---
layout: post
title: "Write-up HTB Knife"
date: 2026-11-27 02:29:00
description: "Retour d’expérience sur la machine Knife : reconnaissance web, ancienne version de développement de PHP et permissions sudo trop larges."
tags: [htb, writeup, linux, php, privesc]
categories: [Write-ups]
writeup_id: htb-knife
writeup_platform: Hack The Box
writeup_title: Knife
writeup_language: fr
writeup_difficulty: Easy
writeup_image: assets/img/knife-writeups/00-htb-machine-card.png
giscus_comments: true
related_posts: false
---

**Machine** : Knife — Easy, Linux  
**Auteur** : DoOm / ppporrkkky  
**Profil HTB** : [DoOm](https://profile.hackthebox.com/profile/019c56c9-a8f8-721d-ad7b-fd7b3dd2f9de)  
**Machine** : [Knife sur Hack The Box](https://app.hackthebox.com/machines/Knife)

> Ce write-up porte sur une machine HTB retirée et un environnement de laboratoire autorisé. Les détails d’exploitation et commandes permettant d’obtenir un accès shell ou root ne sont pas reproduits ici.

## Reconnaissance

Knife est une machine Linux de difficulté Easy. Le but de cette première phase est de dresser l’inventaire des services exposés avant de choisir une piste.

{% include figure.liquid path="assets/img/knife-writeups/00-htb-machine.png" class="img-fluid rounded z-depth-1" %}

La découverte des services révèle deux ports ouverts :

- **22/tcp** — OpenSSH 8.2p1 sur Ubuntu;
- **80/tcp** — Apache 2.4.41 sur Ubuntu.

Le service web constitue la piste prioritaire : il est accessible sans authentification et permet d’inspecter le contenu ainsi que les métadonnées HTTP. SSH est bien présent, mais aucun identifiant n’est encore disponible.

{% include figure.liquid path="assets/img/knife-writeups/01-nmap.png" class="img-fluid rounded z-depth-1" %}

## Inspection du site web

La page d’accueil affiche un site de démonstration pour un établissement médical, intitulé **Emergent Medical Idea**. Les liens visibles et le contenu de la page ne donnent pas directement accès à une autre section ou à un compte.

{% include figure.liquid path="assets/img/knife-writeups/02-webpage.png" class="img-fluid rounded z-depth-1" %}

Une inspection du code source HTML ne révèle pas de commentaire, de secret ou de fonctionnalité cachée utile pour la suite. Il faut donc examiner aussi les réponses du serveur, notamment les en-têtes qui peuvent divulguer la technologie utilisée.

## Analyse des résultats de reconnaissance

Les informations du serveur identifient **PHP 8.1.0-dev**. Le suffixe `dev` est un signal important : il s’agit d’une version de développement, et non d’une version stable à déployer sur un serveur exposé. Les outils de détection signalent également la signature historique `php-zerodium-backdoor-rce`, associée à une porte dérobée présente dans cette version de développement.

La sortie du scanner contient d’autres alertes qu’il faut distinguer de la piste principale :

- `CVE-2026-109618` est affiché avec une étiquette liée à une branche en fin de vie. Les éléments fournis ne permettent pas de confirmer cette alerte comme vulnérabilité exploitable ni de la relier à l’accès initial; elle n’est donc pas utilisée dans ce parcours.
- `CVE-2023-48795` concerne SSH. Cette alerte n’est pas nécessaire pour progresser sur Knife et n’a pas été vérifiée davantage ici.

Un scanner fournit des hypothèses, pas une preuve à lui seul. Pour éviter de partir sur une fausse piste, on retient le fait vérifiable qui correspond au service observé : le serveur annonce une version de développement de PHP connue pour son historique de porte dérobée.

{% include figure.liquid path="assets/img/knife-writeups/03-nuclei-results.png" class="img-fluid rounded z-depth-1" %}

## Comprendre la piste PHP

La porte dérobée a été introduite dans une ancienne version de développement de PHP puis découverte et retirée. Lorsqu’une installation vulnérable est réellement présente, elle peut transformer une requête HTTP spécialement construite en exécution de code sur le serveur.

La preuve de concept mentionnée dans les notes d’origine exploite ce comportement pour obtenir un shell inversé. Avant d’exécuter une preuve de concept, il faut en lire le code et vérifier ses effets : quelle cible elle contacte, quelles commandes elle lance, si elle écrit des fichiers, et si elle tente de créer une persistance. Le code et le payload permettant d’obtenir le shell ne sont pas inclus dans cette version publiée.

## Accès initial

Dans le laboratoire HTB, la version signalée correspond bien au chemin prévu par la machine. L’exploitation de cette faiblesse donne un premier accès sous le compte non privilégié `james`. On passe ainsi d’une observation distante du serveur web à une session locale sur la machine.

La capture documente le shell reçu. Les commandes de création du shell inversé restent volontairement absentes.

{% include figure.liquid path="assets/img/knife-writeups/04-user-shell.png" class="img-fluid rounded z-depth-1" %}

Le premier shell fonctionne, mais il n’offre pas les fonctions d’un terminal interactif complet : contrôle de terminal limité, gestion imparfaite des raccourcis et affichage parfois inconfortable. Il a été stabilisé en laboratoire pour rendre l’énumération locale plus fiable.

Les notes d’origine mentionnent également la présence d’un répertoire `.ssh` et d’une clé privée. La clé n’est pas nécessaire à la chaîne de résolution décrite ici. Une clé privée trouvée sur une machine doit être traitée comme un secret : ne pas la republier et ne pas ajouter de clé pour maintenir un accès persistant.

## Élévation de privilèges

Une fois l’accès utilisateur obtenu, l’étape suivante consiste à vérifier les permissions administratives accordées à `james`. L’examen sudo montre une règle déterminante : cet utilisateur peut lancer `/usr/bin/knife` en tant que root sans fournir de mot de passe.

{% include figure.liquid path="assets/img/knife-writeups/07-sudo-permissions.png" class="img-fluid rounded z-depth-1" %}

Il faut ensuite comprendre ce que désigne réellement ce chemin. `/usr/bin/knife` est un lien symbolique qui pointe vers l’exécutable de Chef Workstation installé sous `/opt`. Ce n’est donc pas un script personnalisé inconnu, mais l’outil Knife de Chef.

{% include figure.liquid path="assets/img/knife-writeups/08-knife-link.png" class="img-fluid rounded z-depth-1" %}

L’inspection confirme que la destination est un exécutable appartenant à `root`. Knife est un outil Ruby et propose une fonction d’exécution de code Ruby. C’est la combinaison de cette fonctionnalité et de la règle sudo sans mot de passe qui crée le chemin d’élévation — pas un bit SUID isolé ni un binaire au nom aléatoire.

{% include figure.liquid path="assets/img/knife-writeups/09-knife-file.png" class="img-fluid rounded z-depth-1" %}

Dans le laboratoire, cette configuration permet de passer du compte `james` à un shell root. La capture confirme le résultat; la commande qui déclenche l’élévation est masquée afin de ne pas publier une procédure directement réutilisable.

{% include figure.liquid path="assets/img/knife-writeups/10-root-redacted.png" class="img-fluid rounded z-depth-1" %}

## Recommandations pour l’administration

- **Ne pas exposer de versions de développement.** Utiliser une version stable et maintenue de PHP, puis appliquer les mises à jour de sécurité.
- **Ne pas se fier uniquement aux bannières.** Les masquer réduit les informations offertes lors de la reconnaissance, mais ne corrige pas la vulnérabilité; la mise à jour reste indispensable.
- **Vérifier les alertes.** Confirmer les versions concernées, les conditions d’exploitation et la pertinence de chaque résultat avant de le considérer comme une faille avérée.
- **Appliquer le moindre privilège à sudo.** N’autoriser que les actions nécessaires et éviter les outils polyvalents capables d’exécuter du code sous un compte privilégié.
- **Éviter les accès persistants injustifiés.** Ne pas ajouter de clés SSH ni de mécanismes de maintien d’accès pendant une analyse de laboratoire.

## Conclusion

La progression sur Knife repose sur deux mauvaises configurations distinctes : une version de développement de PHP exposée au réseau pour obtenir le premier accès, puis une règle sudo trop permissive sur Knife pour l’élévation locale. Le point important n’est pas de lancer tous les résultats d’un scanner, mais de relier les indices observés aux services réellement présents et de vérifier chaque hypothèse.

## Références

- [Machine Knife — Hack The Box](https://app.hackthebox.com/machines/Knife)
