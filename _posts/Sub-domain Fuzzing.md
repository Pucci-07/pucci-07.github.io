## Sub-domain Fuzzing

Sub-domain fuzzing is a brute-force attack technique aimed at identifying the sub-domains of a primary domain. Sub-domains are often used for different services, admin panels, or hidden applications. Attackers, upon discovering these sub-domains, might search for various vulnerabilities to gain access to sensitive information.

Sub-domain fuzzing is performed by trying out guessed or commonly used sub-domain names. Tools employed for this task typically use DNS querying and common sub-domain lists. Attackers try different sub-domain names for the target domain and verify their existence based on the responses from DNS servers.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/e79981b8-4ccd-4db1-8fdc-e49474af2f4a/image-2-33697d4cc.webp)

### Tools

ffuf

The

ffuf

tool is a flexible and fast tool that can be used for sub-domain fuzzing.

**Example**

```auto
ffuf -u https://FUZZ.example.com -w /path/to/wordlist.txt -H "Host: FUZZ.example.com"
```

- **
    
    -u
    
    **: Specifies the URL with the sub-domain. The FUZZ keyword is used as a placeholder for the test point.
- **
    
    -w
    
    **: Specifies the wordlist. The
    
    wordlist.txt
    
    contains sub-domain names to be tested.
- **
    
    -H
    
    **: Specifies the HTTP header to be sent with the sub-domain.

**Example Output:** Sub-domains such as

admin.example.com

,

api.example.com

,

test.example.com

can be detected.

Sublist3r

Sublist3r

is a tool designed to discover sub-domains. It provides quick and comprehensive sub-domain discovery.

**Example**

```auto
sublist3r -d example.com -o subdomains.txt
```

- **
    
    -d
    
    **: Specifies the main domain.
- **
    
    -o
    
    **: Saves the discovered sub-domains to a file.

**Example Output:** Sub-domains such as

admin.example.com

,

mail.example.com

,

vpn.example.com

can be listed.