---
layout: post
title: "stored xss"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

[[Cross-site Scripting (XSS)]]

## Stored XSS

Stored XSS is a type of attack where malicious scripts are stored in a web application's database and then executed in the user's browser whenever the affected page is viewed. These attacks usually occur in scenarios where user-provided data is stored, such as messaging apps, forum posts, comments, or user profiles. The key difference from Reflected XSS is that the payload is stored in the database.

In a web application with this vulnerability, the user's interaction with the XSS payload link is not necessary. Since the payloads are permanently embedded in the page, they can be triggered easily and can have a larger impact. Rather than making thousands of users click on a link, the attacker can execute code in the browsers of all users visiting the affected page through a script coming from the database, making Stored XSS more critical than Reflected XSS.

### Stored XSS Attack Example

It is possible to find Stored XSS vulnerabilities in messaging applications used by multiple users. Messages are processed and stored on the server to be displayed to other users, and the same messages can be viewed again when the page is refreshed or visited at a different time.

Application Examination

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/bf891dd3-4a79-428b-8012-90927de1ccd2/stored-xss-messages-hello-world-f159ed558.webp)

Here, a short message is sent in the messaging application shown.

```auto
POST /index.php HTTP/1.1
Host: example.com
Cookie: PHPSESSID=jl5kamgcplionfan0kkjhcujh3
Content-Length: 19
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.6367.60 Safari/537.36

message=Hello+World
```

When the sent HTTP request is examined, it is seen that a "message" variable is sent with the POST method.

Detecting the Vulnerability

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/bf891dd3-4a79-428b-8012-90927de1ccd2/stored-xss-document-cookie-payload-6b39dcc13.webp)

A simple JavaScript code that displays session and cookie information in an alert box is written into the detected input field.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/bf891dd3-4a79-428b-8012-90927de1ccd2/stored-xss-session-1f0cef8e3.webp)

When the page is visited, it is seen that a session value named "PHPSESSID" is displayed in the alert box. Since the sent message is stored in the database and does not require an extra value obtained from a GET parameter, this vulnerability is called Stored XSS.

```auto
POST /index.php HTTP/1.1
Host: example.com
Cookie: PHPSESSID=jl5kamgcplionfan0kkjhcujh3
Content-Length: 19
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.6367.60 Safari/537.36

message=<script>alert(document.cookie)</script>
```

### Source Code Analysis

Vulnerable Code Example

```auto
<?php 
    $messages = $db->query("SELECT * FROM messages");
    if ($messages) {
        while ($row = $messages->fetch(PDO::FETCH_ASSOC)) {
            echo "<div>" . $row['message'] . "</div>";
        }
    }
?>
```

This PHP code snippet fetches messages from the database and directly displays them in an HTML context. This creates an environment susceptible to Stored XSS attacks.

Secure Code Example

```auto
<?php 
    $messages = $db->query("SELECT * FROM messages");
    if ($messages) {
        while ($row = $messages->fetch(PDO::FETCH_ASSOC)) {
            echo "<div>" .  htmlspecialchars($row['message']) . "</div>";
        }
    }
?>
```

This PHP code snippet uses the **htmlspecialchars** function to convert HTML special characters into HTML entities. This ensures that any potential harmful scripts are rendered as plain text. With this adjustment, Stored XSS attacks can be largely prevented.