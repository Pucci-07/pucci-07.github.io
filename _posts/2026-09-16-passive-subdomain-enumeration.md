---
layout: post
title: "passive subdomain enumeration"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

[[Subdomain Scan]]
## Passive Subdomain Enumeration

Passive subdomain discovery involves mapping all subdomains associated with a domain name. This process expands our attack surface and can often reveal administrative panels that network administrators are trying to keep hidden.

In this stage, we will perform passive subdomain discovery only using third-party services or public information.

### Subdomain Discovery from SSL/TLS Certificates

SSL/TLS certificates are interesting sources of information that we can use to extract subdomains. The main reason is that each SSL/TLS certificate must be published in a public log by a Certificate Authority (CA) after it is issued, as part of the Certificate Transparency (CT) project.

Primary Sources

- **Censys:** Censys scans devices and configurations on the internet, providing various security-related data, including SSL/TLS certificates.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/e2a99d3f-f1d7-4049-b060-388ef4cae62f/image-e673f6e6c.webp)

- **CRT.sh:** CRT.sh is a search engine for SSL/TLS certificates where you can query the information in Certificate Transparency logs.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/e2a99d3f-f1d7-4049-b060-388ef4cae62f/image-3-8345e94a9.webp)

### VirusTotal

VirusTotal offers a DNS replication service by storing DNS resolutions performed when users submit URLs.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/e2a99d3f-f1d7-4049-b060-388ef4cae62f/image-2-a5c49e8e3.webp)

### DNSdumpster

DNSdumpster is an online tool penetration testers can use to discover DNS records, subdomains, and hosts related to a domain.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/e2a99d3f-f1d7-4049-b060-388ef4cae62f/image-1-9afe9c8cc.webp)

### theHarvester

theHarvester is a popular open-source intelligence gathering tool used by penetration testers to collect email addresses, subdomains, hosts, and other sensitive information from public sources.

```auto
root💀hackerbox:~# theharvester --domain kali.org -b all
*******************************************************************
*  _   _                                            _             *
* | |_| |__   ___    /\  /\__ _ _ ____   _____  ___| |_ ___ _ __  *
* | __|  _ \ / _ \  / /_/ / _` | '__\ \ / / _ \/ __| __/ _ \ '__| *
* | |_| | | |  __/ / __  / (_| | |   \ V /  __/\__ \ ||  __/ |    *
*  \__|_| |_|\___| \/ /_/ \__,_|_|    \_/ \___||___/\__\___|_|    *
*                                                                 *
* theHarvester 4.6.0                                              *
* Coded by Christian Martorella                                   *
* Edge-Security Research                                          *
* cmartorella@edge-security.com                                   *
*                                                                 *
*******************************************************************

[*] Target: kali.org 

<SNIP>

[*] Hosts found: 286
---------------------
*.kali.org
10cake.kali.org
10year.kali.org
2Fdocs.kali.org
2Ftools.kali.org
API count exceeded - Increase Quota with Membershipmail2.kali.org:52.44.83.41
aphrodite.kali.org
apollo.kali.org
apollo.kali.org:23.239.31.82
ar.docs.kali.org
ar.docs.kali.org:50.116.58.136
archive-11.kali.org
archive-2.kali.org
archive-3.kali.org
archive-4.kali.org

<SNIP>
```