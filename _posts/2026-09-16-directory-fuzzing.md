---
layout: post
title: "directory fuzzing"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

[[Brute-Force in Web Applications]]


Directory fuzzing, also known as directory brute-forcing, is a type of attack aimed at identifying hidden or unsecured directories in web applications. Attackers attempt to find weaknesses in the target system by trying out guessed directory names or commonly used directory structures. The directories found can provide insights into the content of the application or sensitive files, potentially opening opportunities for further attacks.

Attackers use dictionary files or tools containing common directory names for directory fuzzing. During the scanning process, they consecutively attempt different paths and filenames to access existing directories or files in the target application.

### Tools

For this type of attack, automated tools are generally preferred over manual methods. There are many tools available for directory fuzzing. Here, we will focus on the two most popular ones.

ffuf

ffuf (Fuzz Faster U Fool) is a flexible and fast fuzzing tool. It can be used to apply brute-force attacks to URL parameters, HTTP headers, directory and file names, and much more.

**Example**

```auto
ffuf -u https://example.com/FUZZ -w /path/to/wordlist.txt
```

- **
    
    -u
    
    **: Specifies the URL and uses **FUZZ** as a placeholder for the test point.
- **
    
    -w
    
    **: Specifies the wordlist. The
    
    wordlist.txt
    
    contains directory names to be tested.

gobuster

Gobuster is a fast directory fuzzing tool written in Go. It can be used for various techniques like directory and file scanning.

**Example**

```auto
gobuster dir -u https://example.com -w /path/to/wordlist.txt
```

- **
    
    dir
    
    **: Performs directory scanning.
- **
    
    -u
    
    **: Specifies the URL.
- **
    
    -w
    
    **: Specifies the path to the wordlist.