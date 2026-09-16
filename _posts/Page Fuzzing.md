[[Brute-Force in Web Applications]]

## Page Fuzzing

Page fuzzing, or page brute-forcing, is a brute-force attack technique used to discover non-existent or restricted access pages in web applications. The goal of this attack is to identify hidden or unsecured pages and endpoints on the target server using guessed or commonly used names. Successfully identifying these pages can enable attackers to obtain sensitive information or perform further attacks.

Attackers use fuzzing tools to try out common page names or endpoints. These tools typically rely on dictionary files to attempt various URL paths and detect successful attempts based on HTTP status codes or content size.

### Tools

For performing this type of attack, automated tools are generally preferred over manual methods. There are several tools available for page fuzzing.

ffuf

ffuf (Fuzz Faster U Fool) is a flexible and fast fuzzing tool. It can be used to apply brute-force attacks to URL parameters, HTTP headers, directory and file names, and much more.

**Example**

```auto
ffuf -u https://example.com/FUZZ -w /path/to/wordlist.txt
```

- **
    
    -u
    
    **: Specifies the URL and uses the FUZZ keyword as the test point.
- **
    
    -w
    
    **: Specifies the wordlist. The
    
    wordlist.txt
    
    contains page names to be tested.

**Example Output:** Pages such as

admin.php

,

login.jsp

,

private.html

can be detected.

gobuster

Gobuster is a fast directory search tool that can also be used for page fuzzing.

**Example**

```auto
gobuster dir -u https://example.com -w /path/to/wordlist.txt -x php,html,asp
```

- **
    
    dir
    
    **: Conducts directory or page scanning.
- **
    
    -u
    
    **: Specifies the URL.
- **
    
    -w
    
    **: Specifies the path to the wordlist.
- **
    
    -x
    
    **: Specifies the page extensions (e.g., php, html, asp).

**Example Output:** Pages such as

admin.php

,

index.asp

,

dashboard.html

can be found.