[[Subdomain Scan]]

## Ffuf - Subdomain Fuzzing

We will learn how to actively scan for subdomains of a website using ffuf.

With the scan we'll perform, we will check whether different subdomains exist, whether they have a public DNS record, and whether this record directs us to a working server IP.

In the SecLists repository, there is a dedicated section for sub-domain wordlists composed of commonly used words for subdomains. We can find this wordlist on HackerBox at

/root/Desktop/misc/SecLists/Discovery/DNS/subdomains-top1million-20000.txt

. For a broader scan, a larger list such as

subdomains-top1million-110000.txt

can also be used.

**subdomains-top1million-20000.txt**

```auto
root💀hackerbox:~# head -n 20 /root/Desktop/misc/SecLists/Discovery/DNS/subdomains-top1million-20000.txt
www
mail
ftp
localhost
webmail
smtp
webdisk
pop
cpanel
whm
ns1
ns2
autodiscover
autoconfig
ns
test
m
blog
dev
www2
```

We can use these wordlists to perform subdomain scanning with ffuf.

**Syntax:**

```auto
ffuf -w /path/to/wordlist -u https://FUZZ.example.com/
```

**Example Application**

```auto
root💀hackerbox:~# ffuf -w /root/Desktop/misc/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -u https://FUZZ.google.com/

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://FUZZ.google.com
 :: Wordlist         : FUZZ: /root/Desktop/misc/SecLists/Discovery/DNS/subdomains-top1million-5000.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

mail                    [Status: 301, Size: 215, Words: 14, Lines: 11, Duration: 73ms]
m                       [Status: 302, Size: 282, Words: 9, Lines: 7, Duration: 85ms]
mobile                  [Status: 301, Size: 227, Words: 9, Lines: 7, Duration: 70ms]
www                     [Status: 200, Size: 18916, Words: 462, Lines: 17, Duration: 119ms]
search                  [Status: 301, Size: 220, Words: 9, Lines: 7, Duration: 32ms]
dns                     [Status: 302, Size: 216, Words: 9, Lines: 7, Duration: 105ms]
images                  [Status: 200, Size: 18758, Words: 462, Lines: 16, Duration: 121ms]
blog                    [Status: 301, Size: 221, Words: 9, Lines: 7, Duration: 84ms]
ads                     [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 97ms]
apps                    [Status: 301, Size: 223, Words: 9, Lines: 7, Duration: 84ms]
video                   [Status: 301, Size: 227, Words: 9, Lines: 7, Duration: 82ms]
news                    [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 261ms]
ipv4                    [Status: 200, Size: 18932, Words: 462, Lines: 17, Duration: 121ms]
admin                   [Status: 302, Size: 371, Words: 9, Lines: 7, Duration: 335ms]
chat                    [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 201ms]
support                 [Status: 200, Size: 1014664, Words: 30635, Lines: 4640, Duration: 204ms]
files                   [Status: 200, Size: 12718, Words: 2525, Lines: 297, Duration: 94ms]
store                   [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 262ms]
help                    [Status: 301, Size: 224, Words: 9, Lines: 7, Duration: 83ms]
tv                      [Status: 302, Size: 215, Words: 9, Lines: 7, Duration: 80ms]
services                [Status: 301, Size: 220, Words: 9, Lines: 7, Duration: 82ms]
survey                  [Status: 301, Size: 224, Words: 9, Lines: 7, Duration: 82ms]
home                    [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 267ms]
photo                   [Status: 301, Size: 223, Words: 9, Lines: 7, Duration: 33ms]
meet                    [Status: 302, Size: 226, Words: 9, Lines: 7, Duration: 142ms]
docs                    [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 178ms]

<SNIP>

history                 [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 102ms]
hotels                  [Status: 301, Size: 233, Words: 9, Lines: 7, Duration: 84ms]
podcast                 [Status: 301, Size: 225, Words: 9, Lines: 7, Duration: 82ms]
moon                    [Status: 301, Size: 225, Words: 9, Lines: 7, Duration: 33ms]
sb                      [Status: 302, Size: 220, Words: 9, Lines: 7, Duration: 84ms]
about                   [Status: 301, Size: 218, Words: 9, Lines: 7, Duration: 85ms]
movies                  [Status: 301, Size: 226, Words: 9, Lines: 7, Duration: 81ms]
print                   [Status: 301, Size: 222, Words: 9, Lines: 7, Duration: 82ms]
plus                    [Status: 301, Size: 314, Words: 9, Lines: 7, Duration: 31ms]
sky                     [Status: 301, Size: 224, Words: 9, Lines: 7, Duration: 83ms]
surveys                 [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 178ms]
myaccount               [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 90ms]
gemini                  [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 264ms]
groups                  [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 692ms]
profile                 [Status: 200, Size: 1489986, Words: 25006, Lines: 320, Duration: 534ms]
enterprise              [Status: 301, Size: 222, Words: 9, Lines: 7, Duration: 84ms]
nexus                   [Status: 301, Size: 226, Words: 9, Lines: 7, Duration: 83ms]
earth                   [Status: 302, Size: 226, Words: 9, Lines: 7, Duration: 84ms]
fi                      [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 141ms]
lp                      [Status: 302, Size: 297, Words: 9, Lines: 7, Duration: 764ms]
gmail                   [Status: 301, Size: 215, Words: 14, Lines: 11, Duration: 75ms]
one                     [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 349ms]
voice                   [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 94ms]
www.photo               [Status: 301, Size: 223, Words: 9, Lines: 7, Duration: 84ms]
payments                [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 732ms]
translate               [Status: 200, Size: 1278794, Words: 40716, Lines: 316, Duration: 129ms]
accounts                [Status: 302, Size: 365, Words: 14, Lines: 11, Duration: 79ms]
get                     [Status: 301, Size: 220, Words: 9, Lines: 7, Duration: 84ms]
desktop                 [Status: 200, Size: 283, Words: 18, Lines: 10, Duration: 84ms]
pki                     [Status: 301, Size: 214, Words: 9, Lines: 7, Duration: 86ms]
express                 [Status: 301, Size: 0, Words: 1, Lines: 1, Duration: 698ms]
fotos                   [Status: 301, Size: 223, Words: 9, Lines: 7, Duration: 84ms]
isp                     [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 789ms]
europe                  [Status: 200, Size: 18907, Words: 462, Lines: 17, Duration: 418ms]
channel                 [Status: 200, Size: 1489997, Words: 25006, Lines: 320, Duration: 439ms]
asia                    [Status: 200, Size: 18990, Words: 462, Lines: 17, Duration: 117ms]
script                  [Status: 302, Size: 248, Words: 14, Lines: 11, Duration: 193ms]
donate                  [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 844ms]
gd                      [Status: 302, Size: 220, Words: 9, Lines: 7, Duration: 85ms]
ai                      [Status: 301, Size: 215, Words: 9, Lines: 7, Duration: 85ms]
fusion                  [Status: 302, Size: 220, Words: 9, Lines: 7, Duration: 82ms]
ebooks                  [Status: 301, Size: 227, Words: 9, Lines: 7, Duration: 82ms]
www.docs                [Status: 307, Size: 0, Words: 1, Lines: 1, Duration: 194ms]
pixel                   [Status: 302, Size: 237, Words: 9, Lines: 7, Duration: 85ms]
safety                  [Status: 302, Size: 219, Words: 9, Lines: 7, Duration: 83ms]
cse                     [Status: 301, Size: 224, Words: 9, Lines: 7, Duration: 249ms]
developers              [Status: 200, Size: 205493, Words: 55207, Lines: 8708, Duration: 873ms]
tasks                   [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 665ms]
messages                [Status: 200, Size: 19017, Words: 1472, Lines: 70, Duration: 97ms]
www.photos              [Status: 301, Size: 223, Words: 9, Lines: 7, Duration: 88ms]
documents               [Status: 307, Size: 0, Words: 1, Lines: 1, Duration: 178ms]
offers                  [Status: 301, Size: 227, Words: 9, Lines: 7, Duration: 74ms]
toolbar                 [Status: 302, Size: 240, Words: 9, Lines: 7, Duration: 85ms]
www.image               [Status: 301, Size: 223, Words: 9, Lines: 7, Duration: 78ms]
apis                    [Status: 301, Size: 226, Words: 9, Lines: 7, Duration: 33ms]
elections               [Status: 301, Size: 222, Words: 9, Lines: 7, Duration: 82ms]
contacts                [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 95ms]
vr                      [Status: 302, Size: 221, Words: 9, Lines: 7, Duration: 84ms]
goto                    [Status: 302, Size: 55, Words: 3, Lines: 1, Duration: 73ms]
wave                    [Status: 301, Size: 267, Words: 9, Lines: 7, Duration: 84ms]
alerts                  [Status: 301, Size: 226, Words: 9, Lines: 7, Duration: 84ms]
pride                   [Status: 301, Size: 218, Words: 9, Lines: 7, Duration: 93ms]
discover                [Status: 302, Size: 220, Words: 9, Lines: 7, Duration: 322ms]
inbox                   [Status: 301, Size: 230, Words: 9, Lines: 7, Duration: 38ms]
investor                [Status: 302, Size: 222, Words: 9, Lines: 7, Duration: 88ms]
opensource              [Status: 301, Size: 223, Words: 9, Lines: 7, Duration: 83ms]
drive                   [Status: 302, Size: 0, Words: 1, Lines: 1, Duration: 176ms]
postmaster              [Status: 302, Size: 364, Words: 14, Lines: 11, Duration: 696ms]
blogger                 [Status: 301, Size: 227, Words: 9, Lines: 7, Duration: 87ms]
www.gmail               [Status: 301, Size: 221, Words: 9, Lines: 7, Duration: 84ms]
answers                 [Status: 302, Size: 231, Words: 9, Lines: 7, Duration: 87ms]
reader                  [Status: 301, Size: 233, Words: 9, Lines: 7, Duration: 98ms]
chrome                  [Status: 301, Size: 227, Words: 9, Lines: 7, Duration: 36ms]
workspace               [Status: 200, Size: 286044, Words: 88212, Lines: 3482, Duration: 115ms]
www.plus                [Status: 301, Size: 221, Words: 9, Lines: 7, Duration: 84ms]
:: Progress: [4989/4989] :: Job [1/1] :: 47 req/sec :: Duration: [0:00:31] :: Errors: 4776 ::
```