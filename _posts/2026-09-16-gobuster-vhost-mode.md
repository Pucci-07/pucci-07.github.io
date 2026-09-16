---
layout: post
title: "gobuster vhost mode"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

[[Subdomain Scan]]

## Gobuster - Vhost Mode

With the Gobuster scanning tool, we can discover hidden directories, files, subdomains, and much more on web servers. In this section, we will cover the

vhost

mode we can use with Gobuster to scan subdomains.

### Vhost Mode

The Vhost mode targets multiple websites hosted under different names on the same server. Many organizations host multiple sites on a single server using virtual hosts to efficiently utilize resources. Gobuster's Vhost mode is designed to discover these virtual hosts and can potentially uncover hidden or forgotten websites.

Using the Vhost mode requires a target and a wordlist, similar to Gobuster's other modes. However, in this mode, fuzzing is specifically done in the HTTP Host header. This way, it tests for the presence of different sites hosted on the same IP address.

Using Gobuster's Vhost mode is simple and can be easily executed from the terminal.

**Syntax**

```auto
gobuster vhost -u https://example.com -w /path/to/wordlist
```

Help Menu

```auto
root💀hackerbox:~# gobuster vhost -h
Uses VHOST enumeration mode (you most probably want to use the IP address as the URL parameter)

Usage:
  gobuster vhost [flags]

Flags:
      --append-domain                     Append main domain from URL to words from wordlist. Otherwise the fully qualified domains need to be specified in the wordlist.
      --client-cert-p12 string            a p12 file to use for options TLS client certificates
      --client-cert-p12-password string   the password to the p12 file
      --client-cert-pem string            public key in PEM format for optional TLS client certificates
      --client-cert-pem-key string        private key in PEM format for optional TLS client certificates (this key needs to have no password)
  -c, --cookies string                    Cookies to use for the requests
      --domain string                     the domain to append when using an IP address as URL. If left empty and you specify a domain based URL the hostname from the URL is extracted
      --exclude-length string             exclude the following content lengths (completely ignores the status). You can separate multiple lengths by comma and it also supports ranges like 203-206
  -r, --follow-redirect                   Follow redirects
  -H, --headers stringArray               Specify HTTP headers, -H 'Header1: val1' -H 'Header2: val2'
  -h, --help                              help for vhost
  -m, --method string                     Use the following HTTP method (default "GET")
      --no-canonicalize-headers           Do not canonicalize HTTP header names. If set header names are sent as is.
  -k, --no-tls-validation                 Skip TLS certificate verification
  -P, --password string                   Password for Basic Auth
      --proxy string                      Proxy to use for requests [http(s)://host:port] or [socks5://host:port]
      --random-agent                      Use a random User-Agent string
      --retry                             Should retry on request timeout
      --retry-attempts int                Times to retry on request timeout (default 3)
      --timeout duration                  HTTP Timeout (default 10s)
  -u, --url string                        The target URL
  -a, --useragent string                  Set the User-Agent string (default "gobuster/3.6")
  -U, --username string                   Username for Basic Auth

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
root💀hackerbox:~# gobuster vhost -w /root/Desktop/misc/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -u https://facebook.com
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:             https://facebook.com
[+] Method:          GET
[+] Threads:         10
[+] Wordlist:        /root/Desktop/misc/SecLists/Discovery/DNS/subdomains-top1million-5000.txt
[+] User Agent:      gobuster/3.6
[+] Timeout:         10s
[+] Append Domain:   false
===============================================================
Starting gobuster in VHOST enumeration mode
===============================================================
Found: whm Status: 400 [Size: 1542]
Found: ftp Status: 400 [Size: 1542]
Found: www Status: 400 [Size: 1542]
Found: pop Status: 400 [Size: 1542]
Found: webmail Status: 400 [Size: 1542]
Found: webdisk Status: 400 [Size: 1542]
Found: smtp Status: 400 [Size: 1542]
Found: cpanel Status: 400 [Size: 1542]
Found: mail Status: 400 [Size: 1542]
Found: localhost Status: 400 [Size: 1542]
Found: ns1 Status: 400 [Size: 1542]
Found: ns2 Status: 400 [Size: 1542]
Found: autodiscover Status: 400 [Size: 1542]
Found: autoconfig Status: 400 [Size: 1542]
Found: ns Status: 400 [Size: 1542]
Found: blog Status: 400 [Size: 1542]

<SNIP>

Found: v2 Status: 400 [Size: 1542]
Found: db1 Status: 400 [Size: 1542]
Found: builder.cp Status: 400 [Size: 1542]
Found: mailserver Status: 400 [Size: 1542]
Found: travel Status: 400 [Size: 1542]
Found: cbf2 Status: 400 [Size: 1542]
Found: s114 Status: 400 [Size: 1542]
Found: spp Status: 400 [Size: 1542]
Found: trident Status: 400 [Size: 1542]
Found: mirror2 Status: 400 [Size: 1542]
Found: s112 Status: 400 [Size: 1542]
Found: nnov Status: 400 [Size: 1542]
Found: www.china Status: 400 [Size: 1542]
Found: sonia Status: 400 [Size: 1542]
Found: alabama Status: 400 [Size: 1542]
Found: photogallery Status: 400 [Size: 1542]
Found: blackjack Status: 400 [Size: 1542]
Found: lex Status: 400 [Size: 1542]
Found: hathor Status: 400 [Size: 1542]
Found: inc Status: 400 [Size: 1542]
Found: xmas Status: 400 [Size: 1542]
Found: common-sw1 Status: 400 [Size: 1542]
Found: tulip Status: 400 [Size: 1542]
Found: and Status: 400 [Size: 1542]
Found: vo Status: 400 [Size: 1542]
Found: betty Status: 400 [Size: 1542]
Found: www.msk Status: 400 [Size: 1542]
Found: pc2 Status: 400 [Size: 1542]
Found: schools Status: 400 [Size: 1542]
Progress: 4989 / 4990 (99.98%)
===============================================================
Finished
===============================================================
```

We see that many attempts in the wordlist return a successful result. This is expected, as we are only changing the header each time while visiting [https://facebook.com/](https://facebook.com/). Therefore, we always expect a successful result. However, if a VHost actually exists and we send the correct one in the header, we should receive a different response size (size), because in that case, we would be served the page from that VHost and likely see a different page.

Filtering HTTP response size is a common method. The parameter we can use in Gobuster to filter HTTP response size is

--exclude-length

. The following command fetches results where the HTTP response size is different from 1542 bytes.

```auto
gobuster vhost -u https://example.com -w /path/to/wordlist --exclude-length 1542
```

This method is particularly useful when you want to discover multiple virtual hosts hosted by a single web server. Vhost fuzzing allows security researchers and penetration testers to uncover hidden services and applications that might not be found using traditional methods. This technique is critical for identifying vulnerabilities and understanding the attack surface of the target system, especially in large and complex web infrastructures.