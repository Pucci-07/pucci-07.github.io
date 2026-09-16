---
layout: post
title: "vhost fuzzing"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

[[Brute-Force in Web Applications]]

Vhost fuzzing is a type of attack aimed at guessing virtual host (Vhost) configurations hosted on a server and identifying unauthorized access points. Virtual hosts are used to host multiple websites on the same server infrastructure. Attackers try to gain access to hidden or unauthorized areas by finding the correct Vhost names.

Vhost fuzzing is carried out by guessing the names of the virtual spaces hosted on the main machine. Tools generally use dictionary files containing common Vhost names to attempt access to different virtual host configurations on the server.

### Tools

ffuf

ffuf is a fast and flexible fuzzing tool capable of performing Vhost fuzzing.

**Example**

```auto
ffuf -u https://example.com -H "Host: FUZZ.example.com" -w /path/to/wordlist.txt
```

- **
    
    -u
    
    **: Specifies the main target URL.
- **
    
    -H
    
    **: Adds the Host header for accessing different Vhosts.
- **
    
    -w
    
    **: Specifies the wordlist. The
    
    wordlist.txt
    
    contains the Vhost names to be tested.

**Example Output:** Vhosts such as

dev.example.com

,

staging.example.com

,

admin.example.com

can be detected.

Gobuster

Gobuster is a fast scanning tool developed in Go. Besides directory scanning, it can also be used for virtual host discovery.

**Example**

```auto
gobuster vhost -u https://example.com -w /path/to/wordlist.txt
```

- **
    
    vhost
    
    **: Performs virtual host scanning.
- **
    
    -u
    
    **: Specifies the main URL.
- **
    
    -w
    
    **: Specifies the path to the wordlist.

**Example Output:** Vhosts such as

api.example.com

,

admin.example.com

,

test.example.com

can be detected.