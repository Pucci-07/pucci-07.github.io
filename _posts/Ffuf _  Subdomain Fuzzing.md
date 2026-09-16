[[Subdomain Scan]]

## Ffuf - Vhost Fuzzing

In the previous section, we saw how we could fuzz public subdomains using public DNS records. However, the same method doesn't work when we're trying to fuzz subdomains that don't have a public DNS record. In this section, we will learn how to do this using Vhost Fuzzing.

To scan VHosts, instead of manually adding the wordlist to our local DNS file

/etc/hosts

, we will use the

Host:

header from HTTP headers to fuzz.

To specify a header for Vhost scanning, we can use the

-H

parameter and utilize the FUZZ keyword within it as shown below.

**Syntax**

```auto
ffuf -w /path/to/wordlist -u https://example.com -H 'Host: FUZZ.example.com'
```

**Example Application**

```auto
root💀hackerbox:~# ffuf -w /root/Desktop/misc/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -u https://youtube.com -H 'Host: FUZZ.youtube.com'

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://youtube.com
 :: Wordlist         : FUZZ: /root/Desktop/misc/SecLists/Discovery/DNS/subdomains-top1million-5000.txt
 :: Header           : Host: FUZZ.youtube.com
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

www                     [Status: 200, Size: 18966, Words: 462, Lines: 17, Duration: 127ms]
m                       [Status: 200, Size: 18817, Words: 462, Lines: 17, Duration: 131ms]
mx                      [Status: 200, Size: 18910, Words: 462, Lines: 17, Duration: 119ms]
admin                   [Status: 200, Size: 18954, Words: 462, Lines: 17, Duration: 123ms]
img                     [Status: 200, Size: 18878, Words: 462, Lines: 17, Duration: 119ms]
news                    [Status: 200, Size: 18937, Words: 462, Lines: 17, Duration: 119ms]
ads                     [Status: 200, Size: 18981, Words: 462, Lines: 17, Duration: 117ms]
www.m                   [Status: 200, Size: 18975, Words: 462, Lines: 17, Duration: 117ms]
cms                     [Status: 200, Size: 18896, Words: 462, Lines: 17, Duration: 119ms]
live                    [Status: 200, Size: 18923, Words: 462, Lines: 17, Duration: 114ms]
it                      [Status: 200, Size: 18977, Words: 462, Lines: 17, Duration: 129ms]
upload                  [Status: 200, Size: 18885, Words: 462, Lines: 17, Duration: 122ms]
tv                      [Status: 200, Size: 18888, Words: 462, Lines: 17, Duration: 118ms]
help                    [Status: 200, Size: 18904, Words: 462, Lines: 17, Duration: 138ms]
s                       [Status: 200, Size: 19290, Words: 468, Lines: 17, Duration: 130ms]
de                      [Status: 200, Size: 18890, Words: 462, Lines: 17, Duration: 128ms]
facebook                [Status: 200, Size: 18971, Words: 462, Lines: 17, Duration: 116ms]
es                      [Status: 200, Size: 18973, Words: 462, Lines: 17, Duration: 119ms]
fr                      [Status: 200, Size: 18899, Words: 462, Lines: 17, Duration: 143ms]
music                   [Status: 200, Size: 18896, Words: 462, Lines: 17, Duration: 145ms]
ca                      [Status: 200, Size: 18851, Words: 462, Lines: 17, Duration: 116ms]
ru                      [Status: 200, Size: 18906, Words: 462, Lines: 17, Duration: 114ms]
uk                      [Status: 200, Size: 18886, Words: 462, Lines: 17, Duration: 121ms]
in                      [Status: 200, Size: 18922, Words: 462, Lines: 17, Duration: 128ms]
nl                      [Status: 200, Size: 19030, Words: 462, Lines: 17, Duration: 121ms]
corp                    [Status: 302, Size: 459, Words: 9, Lines: 7, Duration: 86ms]
p                       [Status: 200, Size: 19179, Words: 468, Lines: 17, Duration: 120ms]
research                [Status: 200, Size: 18903, Words: 462, Lines: 17, Duration: 122ms]
jp                      [Status: 200, Size: 18873, Words: 462, Lines: 17, Duration: 118ms]
analytics               [Status: 200, Size: 18921, Words: 462, Lines: 17, Duration: 118ms]
id                      [Status: 200, Size: 18830, Words: 462, Lines: 17, Duration: 120ms]
tw                      [Status: 200, Size: 18887, Words: 462, Lines: 17, Duration: 116ms]
br                      [Status: 200, Size: 18967, Words: 462, Lines: 17, Duration: 121ms]
studio                  [Status: 200, Size: 18857, Words: 462, Lines: 17, Duration: 119ms]
se                      [Status: 200, Size: 18848, Words: 462, Lines: 17, Duration: 117ms]
au                      [Status: 200, Size: 18886, Words: 462, Lines: 17, Duration: 119ms]
pl                      [Status: 200, Size: 18885, Words: 462, Lines: 17, Duration: 114ms]
cz                      [Status: 200, Size: 18904, Words: 462, Lines: 17, Duration: 124ms]
movies                  [Status: 200, Size: 18895, Words: 462, Lines: 17, Duration: 120ms]
hk                      [Status: 200, Size: 18916, Words: 462, Lines: 17, Duration: 116ms]
kids                    [Status: 200, Size: 18906, Words: 462, Lines: 17, Duration: 118ms]
payments                [Status: 200, Size: 19227, Words: 468, Lines: 17, Duration: 124ms]
fi                      [Status: 200, Size: 18883, Words: 462, Lines: 17, Duration: 125ms]
dk                      [Status: 200, Size: 18866, Words: 462, Lines: 17, Duration: 123ms]
www.sandbox             [Status: 200, Size: 19259, Words: 468, Lines: 17, Duration: 135ms]
accounts                [Status: 200, Size: 18917, Words: 462, Lines: 17, Duration: 115ms]
kr                      [Status: 200, Size: 18916, Words: 462, Lines: 17, Duration: 166ms]
director                [Status: 200, Size: 18912, Words: 462, Lines: 17, Duration: 120ms]
ie                      [Status: 200, Size: 18950, Words: 462, Lines: 17, Duration: 118ms]
insight                 [Status: 200, Size: 18905, Words: 462, Lines: 17, Duration: 118ms]
checkout                [Status: 200, Size: 18971, Words: 462, Lines: 17, Duration: 125ms]
il                      [Status: 200, Size: 18884, Words: 462, Lines: 17, Duration: 122ms]
gr                      [Status: 200, Size: 18942, Words: 462, Lines: 17, Duration: 121ms]
www.research            [Status: 200, Size: 18886, Words: 462, Lines: 17, Duration: 123ms]
no                      [Status: 200, Size: 18902, Words: 462, Lines: 17, Duration: 113ms]
hu                      [Status: 200, Size: 18930, Words: 462, Lines: 17, Duration: 420ms]
nz                      [Status: 200, Size: 18938, Words: 462, Lines: 17, Duration: 118ms]
vr                      [Status: 200, Size: 18906, Words: 462, Lines: 17, Duration: 125ms]
za                      [Status: 200, Size: 18821, Words: 462, Lines: 17, Duration: 131ms]
parents                 [Status: 200, Size: 18912, Words: 462, Lines: 17, Duration: 117ms]
webdisk.sandbox         [Status: 200, Size: 19243, Words: 468, Lines: 17, Duration: 134ms]
:: Progress: [4989/4989] :: Job [1/1] :: 92 req/sec :: Duration: [0:00:27] :: Errors: 4928 ::
```

We notice that most attempts in the wordlist return a status

200 OK

. This is expected, as we're only changing the header each time while visiting [https://youtube.com/](https://youtube.com/). Therefore, we always expect to receive

200 OK

. However, if a VHost actually exists and we provide the correct one in the header, we should receive a different response size, indicating that we are being served a page from that VHost, which would likely show a different page.

Filtering HTTP response size is a common method. The parameter used in ffuf to filter HTTP response size is

-fs

. The following command fetches results where the HTTP response size is different from 4242 bytes.

```auto
ffuf -w /path/to/vhost/wordlist -u http://example.com -H 'Host: FUZZ.example.com' -fs 4242
```