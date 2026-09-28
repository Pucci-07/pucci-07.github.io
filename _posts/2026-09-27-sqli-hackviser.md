---
layout: post
title: "Basic SQL Injection — Hackviser Lab"
date: 2026-09-27 12:00:00
description: Contournement d'une page de login vulnérable à l'injection SQL sur un lab Hackviser, avec récupération de l'email d'un utilisateur cible.
tags: [writeup, sqli, hackviser, web]
categories: [Write-ups]
giscus_comments: true
related_posts: false
---

## L'objectif

Le lab Hackviser **Basic SQL Injection** contient une vulnérabilité d'injection SQL dans la fonction de login. Le but est de bypasser la page de connexion pour retrouver l'adresse email de l'utilisateur nommé **Sky Raincin**.

Une fois sur l'URL du site, on arrive sur cette interface :

{% include figure.liquid path="assets/img/sqli-hackviser/01-login-page.png" class="img-fluid rounded z-depth-1" %}

## Premier payload — échec

On teste un payload classique d'injection dans le champ Username :

```
' OR 1=1--
```

{% include figure.liquid path="assets/img/sqli-hackviser/02-payload-attempt.png" class="img-fluid rounded z-depth-1" %}

La réponse du serveur :

{% include figure.liquid path="assets/img/sqli-hackviser/03-wrong-credentials.png" class="img-fluid rounded z-depth-1" %}

**Wrong username or password** — le serveur semble traiter notre entrée comme une simple chaîne de caractères plutôt que comme une injection de commande SQL.

## Diagnostic — le mauvais guillemet

La cause est le caractère utilisé à côté du paramètre injecté : en SQL, l'apostrophe droite `'` n'est **pas équivalente** à une apostrophe typographique `'`. Autrement dit, définir une chaîne comme `'ma chaîne'` fonctionne, mais `'ma chaîne'` (avec une apostrophe courbe) est interprété comme du texte littéral, pas comme une syntaxe SQL.

Dans notre cas, le payload initial utilisait la mauvaise apostrophe, donc `' OR 1=1--` était interprété comme une chaîne de caractères inoffensive, d'où l'erreur "wrong username or password".

Le payload corrigé, avec la bonne apostrophe droite :

```
'OR 1=1 - -
```

Le résultat :

{% include figure.liquid path="assets/img/sqli-hackviser/04-500-error.png" class="img-fluid rounded z-depth-1" %}

Cette fois, ça a partiellement marché, mais on tombe sur une erreur **500 Internal Server Error**. Hypothèse : le serveur de base de données n'interprète pas correctement la syntaxe de commentaire envoyée. Ce qui varie généralement d'un moteur SQL à l'autre, ce n'est pas toute la syntaxe, mais surtout la syntaxe des **commentaires**. On teste donc avec `#` à la place de `--` :

```
'OR 1=1 #
```

## Succès

{% include figure.liquid path="assets/img/sqli-hackviser/05-hash-payload.png" class="img-fluid rounded z-depth-1" %}

{% include figure.liquid path="assets/img/sqli-hackviser/06-profile-result.png" class="img-fluid rounded z-depth-1" %}

On obtient le profil de l'utilisateur cible avec son adresse email : **sraincin0@moonfruit.hv**.

**Note technique** : en MySQL, le commentaire `--` doit obligatoirement être suivi d'un espace pour être reconnu comme tel — sans cet espace, il est ignoré, d'où l'erreur 500 (requête malformée). Le commentaire `#`, lui, n'a pas cette contrainte, ce qui explique le succès immédiat avec ce second payload.

## Recommandations

- **Requêtes préparées / paramétrées** (PDO, prepared statements) pour éliminer structurellement l'injection.
- Utilisation d'un **ORM** qui échappe automatiquement les entrées utilisateur.
- **Principe du moindre privilège** sur le compte de base de données utilisé par l'application (éviter un compte avec droits admin).
- **WAF** en couche de défense additionnelle — mais jamais en remplacement de la correction du code applicatif.
- **Validation/sanitization** des entrées côté serveur, en privilégiant une **whitelist** plutôt qu'une blacklist.
- Ne jamais passer directement des paramètres saisis par l'utilisateur dans une requête SQL construite par concaténation de chaînes.
