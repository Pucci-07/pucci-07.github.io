---
layout: post
title: "gobuster dns mode"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

[[Subdomain Scan]]

## Gobuster - DNS Mode

With the Gobuster scanning tool, we can discover hidden directories, files, subdomains, and much more on web servers. In this section, we will cover the

dns

mode we can use with Gobuster to scan subdomains.

### DNS Mode

The DNS mode is designed to discover subdomains under a specific domain. This mode is used to try possible subdomain names for a given target domain and determine if these subdomains are active.

When using Gobuster's DNS mode, a wordlist and a target domain are required. This mode performs DNS queries by combining each word in the wordlist with the target domain and determines which subdomains can be resolved based on the results of these queries.

Using Gobuster's DNS mode is simple and can be easily executed from the terminal.

**Syntax**

```auto
gobuster dns -d example.com -w /path/to/wordlist
```

Help Menu

```auto
root💀hackerbox:~# gobuster dns -h
Uses DNS subdomain enumeration mode

Usage:
  gobuster dns [flags]

Flags:
  -d, --domain string      The target domain
  -h, --help               help for dns
      --no-fqdn            Do not automatically add a trailing dot to the domain, so the resolver uses the DNS search domain
  -r, --resolver string    Use custom DNS server (format server.com or server.com:port)
  -c, --show-cname         Show CNAME records (cannot be used with '-i' option)
  -i, --show-ips           Show IP addresses
      --timeout duration   DNS resolver timeout (default 1s)
      --wildcard           Force continued operation when wildcard found

Global Flags:
      --debug                 Enable debug output
      --delay duration        Time each thread waits between requests (e.g. 1500ms)
      --no-color              Disable color output
      --no-error              Don't display errors
  -z, --no-progress           Don't display progress
  -o, --output string         Output file to write results to (defaults to stdout)
  -p, --pattern string        File containing replacement patterns
  -q, --quiet                 Don't print the banner and other noise
  -t, --threads int           Number of concurrent threads (default 10)
  -v, --verbose               Verbose output (errors)
  -w, --wordlist string       Path to the wordlist. Set to - to use STDIN.
      --wordlist-offset int   Resume from a given position in the wordlist (defaults to 0)
```

Example Application

```auto
root💀hackerbox:~# gobuster dns -w /root/Desktop/misc/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -d facebook.com
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Domain:     facebook.com
[+] Threads:    10
[+] Timeout:    1s
[+] Wordlist:   /root/Desktop/misc/SecLists/Discovery/DNS/subdomains-top1million-5000.txt
===============================================================
Starting gobuster in DNS enumeration mode
===============================================================
Found: www.facebook.com

Found: m.facebook.com

Found: arena.facebook.com

Found: safety.facebook.com

Found: monster.facebook.com

Found: solutions.facebook.com

Found: touch.facebook.com

Found: polaris.facebook.com

Found: vs.facebook.com

Found: gl.facebook.com

Found: east.facebook.com

Found: comet.facebook.com

Found: tcs.facebook.com

Found: michael.facebook.com

Found: m.dev.facebook.com

Found: sia.facebook.com

<SNIP>

Found: housing.facebook.com

Found: impact.facebook.com

Found: ais.facebook.com

Found: ja.facebook.com

Found: ig.facebook.com

Found: apex.facebook.com

Found: lds.facebook.com

Found: extern.facebook.com

Found: imc.facebook.com

Found: opensource.facebook.com

Found: ibm.facebook.com

Found: sanantonio.facebook.com

Found: bloom.facebook.com

Found: www.hr.facebook.com

Found: faith.facebook.com

Found: move.facebook.com

Found: betty.facebook.com

Progress: 4989 / 4990 (99.98%)
===============================================================
Finished
===============================================================
```
