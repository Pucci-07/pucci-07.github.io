[[Cross-site Scripting (XSS)]]

Blind XSS is a type of Cross-Site Scripting (XSS) attack that occurs when a web application processes and stores user input but does not reflect it immediately on the visible/frontend of the application. The malicious input may be processed and viewed later in different parts of the application, such as admin panels, reporting tools, or other backend functionalities. Essentially, it can be considered a form of **Stored XSS**.

In a Blind XSS attack, an attacker provides input containing an XSS payload to the application. This input could be in the form of an error message, a user comment, or any information that the system logs. The data is then stored in the application's database or a similar storage location before being utilized in output. The malicious script is executed when an administrator or another user views that data at a later time, for instance, when a system administrator reviews user comments or error reports.

Blind XSS attacks are predominantly targeted toward high-privilege users such as administrators because they frequently review other users' input or system logs.

### Application Areas Prone to Blind XSS

Payloads for Blind XSS attacks can be submitted in areas where user control exists and the data will be reviewed by other users or system administrators later.

1. **Contact Forms**: Information entered by users in contact form fields, usually reviewed by the support team.
2. **Comment Sections**: Comments on blogs, news sites, or product pages, viewed by other visitors or site administrators.
3. **User Profile Fields**: Sections where users introduce themselves, like biography or "about me" areas, generally visible to other users.
4. **Order Forms**: Details entered by users like name, address, etc., reviewed during order processing and by customer service.
5. **Support Ticket Systems**: Information entered in support or issue reporting forms, examined by the technical support team.
6. **Product Reviews**: Reviews on e-commerce sites, typically visible to other customers and site administrators.
7. **Forum Posts**: Discussion forums where user messages are read by other members.
8. **Surveys and Feedback Forms**: Input from users in survey or feedback fields, analyzed and reported on later.

These data entry points, which are directly exposed to user input, often provide attackers with areas to inject malicious JavaScript code, which may be triggered when reviewed by system administrators or other users.

### XSS Attacks Through HTTP Headers

HTTP headers contain metadata information sent as part of HTTP requests and responses. These headers can include information like

User-Agent

,

Referer

, and

Cookie

. If a web application logs these incoming headers or uses them without proper validation, they can contain malicious scripts.

An attacker can utilize the User-Agent header to inject malicious code. If the application logs this header directly and displays it in a web interface, the attack may succeed. This often occurs in a debugging interface or an admin panel and the script is executed when the administrator checks the log file.

1. **User-Agent Header**: The
    
    User-Agent
    
    header contains a string used by a client (usually a web browser) to identify itself to a web server. This information typically includes details about the browser type, operating system, and versions. Servers may use this information for content delivery or compatibility purposes. Attackers can inject JavaScript into this header, and if viewed by the admin panel without filtering, the script is executed upon rendering.
    
    ```auto
    User-Agent: Mozilla/5.0 <script>alert('XSS')</script>
    ```
    
2. **Referer Header**: The
    
    Referer
    
    HTTP header indicates the URL of the resource from which the request was initiated. It is often used for analysis, logging, or security purposes. Attackers can inject JavaScript code into this header, which can be executed if viewed by the admin panel without proper sanitization.
    
    ```auto
    Referer: http://other-site.com <script>alert('XSS')</script>
    ```
    
3. **X-Forwarded-For Header**: The
    
    X-Forwarded-For
    
    header specifies the original IP address from which a request was made. This header is commonly used by load balancers and proxy servers. Attackers can inject JavaScript into this header, and if viewed without filtering, for instance, by an admin panel, the script can be executed.
    
    ```auto
    X-Forwarded-For: 198.51.100.15 <script>alert('XSS');</script>
    ```