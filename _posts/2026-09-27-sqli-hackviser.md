---
layout: post
title: "Basic SQL Injection — Hackviser Lab"
date: 2026-09-27 12:00:00
description: Bypassing a SQL-injection-vulnerable login page on a Hackviser lab, retrieving a target user's email address.
tags: [writeup, sqli, hackviser, web]
categories: [Write-ups]
giscus_comments: true
related_posts: false
---

## The objective

The Hackviser **Basic SQL Injection** lab contains a SQL injection vulnerability in the login function. The goal is to bypass the login page to retrieve the email address of the user named **Sky Raincin**.

Once on the site's URL, this interface is presented:

{% include figure.liquid path="assets/img/sqli-hackviser/01-login-page.png" class="img-fluid rounded z-depth-1" %}

## First payload — failure

A classic injection payload is tried in the Username field:

```
' OR 1=1--
```

{% include figure.liquid path="assets/img/sqli-hackviser/02-payload-attempt.png" class="img-fluid rounded z-depth-1" %}

The server's response:

{% include figure.liquid path="assets/img/sqli-hackviser/03-wrong-credentials.png" class="img-fluid rounded z-depth-1" %}

**Wrong username or password** — the server appears to treat the input as a plain string rather than as SQL injection.

## Diagnosis — the wrong quote character

The cause is the character used next to the injected parameter: in SQL, a straight apostrophe `'` is **not equivalent** to a typographic (curly) apostrophe `'`. In other words, defining a string as `'my string'` works, but `'my string'` (with a curly apostrophe) gets interpreted as literal text, not SQL syntax.

In this case, the initial payload used the wrong apostrophe, so `' OR 1=1--` was interpreted as a harmless string, hence the "wrong username or password" error.

The corrected payload, with the proper straight apostrophe:

```
'OR 1=1 - -
```

The result:

{% include figure.liquid path="assets/img/sqli-hackviser/04-500-error.png" class="img-fluid rounded z-depth-1" %}

This time it partially worked, but a **500 Internal Server Error** is returned. Hypothesis: the database server isn't interpreting the comment syntax correctly. What usually varies between SQL engines isn't the entire syntax, but mainly the **comment** syntax. So `#` is tried instead of `--`:

```
'OR 1=1 #
```

## Success

{% include figure.liquid path="assets/img/sqli-hackviser/05-hash-payload.png" class="img-fluid rounded z-depth-1" %}

{% include figure.liquid path="assets/img/sqli-hackviser/06-profile-result.png" class="img-fluid rounded z-depth-1" %}

The target user's profile is obtained, along with their email address: **sraincin0@moonfruit.hv**.

**Technical note**: in MySQL, the `--` comment must be followed by a space to be recognized as such — without that space, it's ignored, hence the 500 error (malformed query). The `#` comment doesn't have that constraint, which explains the immediate success with the second payload.

## Recommendations

- **Prepared / parameterized statements** (PDO, prepared statements) to structurally eliminate injection.
- Use of an **ORM** that automatically escapes user input.
- **Principle of least privilege** on the database account used by the application (avoid an account with admin rights).
- **WAF** as an additional defense layer — but never as a replacement for fixing the application code.
- **Input validation/sanitization** on the server side, favoring a **whitelist** over a blacklist.
- Never pass user-supplied parameters directly into a SQL query built through string concatenation.
