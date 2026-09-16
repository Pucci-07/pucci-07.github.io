[[Cross-site Scripting (XSS)]]

Reflected XSS is a type of attack where a malicious script is sent to a web application and reflected back to the user's browser. These attacks usually occur when users are tricked by social engineering tactics into clicking on a link containing the XSS payload. These links trigger an HTTP request containing malicious code, which the server mirrors back in the HTTP response, executing within the user's browser. It is called Reflected XSS because the attack relies on each victim triggering the attack afresh, completing in a single request/response cycle and requiring user interaction.

### Reflected XSS Attack Example:

An attacker can craft a URL containing a malicious script that gets reflected by the web application:

```auto
https://example.com/home?search=<script>alert('XSS')</script>
```

In this example, when the search box executes, the HTTP GET request with the "search" parameter includes the XSS payload into the page.

When the URL is clicked, the XSS payload is executed in the user's browser within the context of the application they are interacting with. This script can access user data or perform malicious actions.

Application Examination

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/7cf943b0-ab4f-4a2b-9ebe-1c4350d2d52c/reflected-xss-search-0b6ff44d5.webp)

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/7cf943b0-ab4f-4a2b-9ebe-1c4350d2d52c/dev-tools-reflected-search-54a166190.webp)

On this page, we see a search box. By searching for the word "cars", the response is observed. The search term is shown in an alert box. The data is sent to the server with the "q" GET parameter.

Detecting the Vulnerability

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/7cf943b0-ab4f-4a2b-9ebe-1c4350d2d52c/reflected-xss-alert-abcc6b3de.webp)

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/7cf943b0-ab4f-4a2b-9ebe-1c4350d2d52c/dev-tools-reflected-alert-61048b028.webp)

A simple XSS payload was entered into the search box to trigger a JavaScript alert displaying the number "1". The payload successfully executed, confirming the vulnerability.

```auto
?q=<script>alert(1)</script>
```

### HTML Injection

Besides JavaScript code, HTML code can also be injected into the page, altering the page's design. This can turn into a deceptive social engineering attack designed according to the attacker's intentions. This type of attack is known as HTML Injection.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/7cf943b0-ab4f-4a2b-9ebe-1c4350d2d52c/html-injection-d083f4eb6.webp)

```auto
?q=<h1 style="color:green;">TEST</h1>
```

Here, an h1 tag containing the word "TEST" is displayed with green color.

### Source Code Analysis

The fundamental cause of the vulnerability is the direct rendering of user input in the browser without sufficient checks or filtering. This situation leads to security vulnerabilities, particularly XSS attacks.

Vulnerable Code Example

The following PHP code snippet displays user input directly into an HTML context without proper validation, creating an opportunity for XSS attacks.

```auto
<?php 
    if (isset($_GET['q'])) {
        $q = $_GET['q'];
        echo '<div class="alert alert-danger" role="alert">
            No Result Found for <b>' . $q . '</b> 
        </div>';
    } 
?>
```

This code checks for the presence of a

q

GET parameter in the URL. If the parameter is present, its value is assigned to the variable

$q

. This variable is then directly echoed into an HTML context within

<div>

and

<b>

tags.

The "q" parameter, obtained via the GET method, is directly used within

<b>

tags without any security measures. If the "q" parameter contains code like

<script>alert(1)</script>

, this script will be executed in the user's browser, and an alert with the number 1 will be displayed.

Secure Code Example

In this example, the **htmlspecialchars** function is used to safely output user input. This function converts HTML-specific characters (

<

,

>

,

&

,

"

,

'

etc.) into their HTML entities (

&lt;

,

&gt;

,

&amp;

,

&quot;

,

&#039;

etc.).

```auto
<?php 
    if (isset($_GET['q'])) {
        $q = $_GET['q'];
        echo '<div class="alert alert-danger" role="alert">
            No Result Found for <b>' . htmlspecialchars($q) . '</b> 
        </div>';
    } 
?>
```

With this modification, potential harmful scripts in the "q" parameter are converted to harmless text, preventing XSS attacks. For example, even if a user sends a

<script>

tag, it will be rendered as plain text rather than an HTML element by the browser.