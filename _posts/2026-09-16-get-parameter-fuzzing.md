---
layout: post
title: "get parameter fuzzing"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

[[Brute-Force in Web Applications]]

GET parameter fuzzing is a testing method aimed at identifying security vulnerabilities and unexpected behaviors in web applications by manipulating GET parameters received via the URL using random or specially crafted inputs. This type of attack primarily focuses on analyzing whether the application directly processes URL parameters, how it responds to various inputs, and whether potentially sensitive information is leaked.

GET parameter fuzzing is carried out using wordlists or custom-crafted payloads. Tools send various combinations of data to parameter points in the target URL and evaluate the server's HTTP responses. This evaluation is based on specific status codes, response times, or server error messages.

### Tools

ffuf

ffuf is a tool that can be used for GET parameter fuzzing.

**Example**

```auto
ffuf -u "https://example.com/page.php?param=FUZZ" -w /path/to/wordlist.txt
```

- **
    
    -u
    
    **: Specifies the URL to be tested, where **FUZZ** is a placeholder indicating where fuzzing should be applied.
- **
    
    -w
    
    **: Specifies the path to the wordlist. The
    
    wordlist.txt
    
    contains the parameter values to be tested.

ffuf sends requests for each test value and evaluates the server's responses based on factors such as response size, HTTP status, and content to identify potential security vulnerabilities.

Burp Suite Intruder

Burp Suite Intruder is a powerful security testing tool that can be used for parameter fuzzing and other types of attacks in web applications.

**Usage**

1. Capture the request to the application via proxy and send it to Intruder.
2. Mark the GET parameters to be tested.
3. Specify the wordlist and start the attack.