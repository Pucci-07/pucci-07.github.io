---
layout: post
title: "post parameter fuzzing"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

POST parameter fuzzing is a type of testing aimed at discovering security vulnerabilities by altering the parameters sent in POST requests with different values. This type of attack seeks to uncover whether critical data sent through POST requests can manipulate various functions of the application or gain access to sensitive information.

POST parameter fuzzing is typically performed using wordlists or randomly generated character combinations. Tools send POST requests to the application to understand how the parameters are evaluated. Responses are analyzed to determine if the application returns unexpected data or leaks information through error messages.

### Example

Consider a web application where a form is submitted using the POST method during authentication. For this scenario, an example HTTP request might look like this:

```auto
POST /login.php HTTP/1.1
Host: example.com
Content-Type: application/x-www-form-urlencoded

username=admin&password=123456
```

Here, the username and password fields can be tested with different wordlists or random combinations. If the application does not provide adequate protection against incorrect authentication attempts, brute force attacks could potentially gain access to user accounts.

### Tools

Burp Suite Intruder

Burp Suite Intruder is a widely used comprehensive security testing tool for POST parameter fuzzing.

**Usage Example**

1. Capture the request with a proxy and send it to Intruder.
2. Mark the POST parameters and specify the attack type.
3. Add the wordlist and start the attack.
4. Analyze the responses based on HTTP status codes, response time, and content.

ffuf

ffuf is a fast and flexible tool that can also be used for POST parameter fuzzing.

**Usage Example**

```auto
ffuf -u "https://example.com/login.php" -X POST -d "username=admin&password=FUZZ" -w /usr/share/wordlists/rockyou.txt -H "Content-Type: application/x-www-form-urlencoded"
```

- **
    
    -u
    
    **: Specifies the target URL.
- **
    
    -X
    
    **: Specifies the request method (POST).
- **
    
    -d
    
    **: Specifies the form data to be sent; the FUZZ placeholder indicates where different values will be tried for the password.
- **
    
    -w
    
    **: Specifies the path to the wordlist.
- **
    
    -H
    
    **: Adds header information to the HTTP request. "Content-Type" specifies the type of the submitted form.