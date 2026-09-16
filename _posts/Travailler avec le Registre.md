
À ce stade, nous devrions être à l'aise avec la CLI. Il est temps d'améliorer à nouveau nos compétences et d'aborder l'un des aspects les plus compliqués du système d'exploitation Windows, le `Registre` (Registry). Cette section nous expliquera ce qu'est le Registre, comment y naviguer, comment lire les paires clé/valeur et y apporter des modifications si nécessaire.

---

## Qu'est-ce que le Registre Windows ?

À la base, le `Registre` peut être considéré comme une arborescence hiérarchique qui contient deux éléments essentiels : les `clés` (keys) et les `valeurs` (values). Cette arborescence stocke toutes les informations requises pour que le système d'exploitation et les logiciels installés s'exécutent dans des sous-arborescences (considérez-les comme des branches d'un arbre). Ces informations peuvent être n'importe quoi, des paramètres aux répertoires d'installation en passant par des options et des valeurs spécifiques qui déterminent le fonctionnement de l'ensemble. Pour les testeurs d'intrusion (pentesters), le Registre est un excellent endroit pour trouver des informations utiles, implanter de la persistance, et plus encore. [MITRE](https://attack.mitre.org/techniques/T1112/) fournit de nombreux exemples de ce qu'un acteur malveillant (threat actor) peut faire avec un accès (local ou distant) à la ruche du Registre (registry hive) d'un hôte.

### Que sont les clés

Les `clés`, pour l'essentiel, sont des conteneurs qui représentent un composant spécifique du PC. Les clés peuvent contenir d'autres clés et des valeurs comme données. Ces entrées peuvent prendre de nombreuses formes, et les contextes de nommage exigent seulement qu'une clé soit nommée en utilisant des caractères alphanumériques (imprimables) et ne soit pas sensible à la casse. Pour un exemple visuel de clés, si nous regardons l'image ci-dessous, chaque dossier dans le `rectangle vert` est une clé et contient des sous-clés.

#### Clés (Vert)

![Éditeur du Registre affichant le chemin : HKEY_LOCAL_MACHINE\SOFTWARE\Adobe\Adobe Acrobat\10.0\Installer. Le volet de droite affiche 'DisableMaintenance' avec la valeur 1.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/registry.png)

### Fichiers de clés du Registre

Les `clés racine` (root keys) du Registre d'un système hôte sont stockées dans plusieurs fichiers différents et sont accessibles depuis `C:\Windows\System32\Config\`. En plus de ces fichiers de clés, les ruches du Registre sont conservées à divers autres endroits de l'hôte.

#### Clés racine du Registre

        powershell
`PS C:\htb> Get-ChildItem C:\Windows\System32\config\      Directory: C:\Windows\System32\config  Mode                 LastWriteTime         Length Name ----                 -------------         ------ ---- d----           12/7/2019  4:14 AM                Journal d----           12/7/2019  4:14 AM                RegBack d----           4/28/2021 11:43 AM                systemprofile d----           9/18/2021 12:22 AM                TxR -a---          10/12/2022 10:06 AM         786432 BBI -a---           1/20/2021  5:13 PM          28672 BCD-Template -a---          10/18/2022 11:14 AM       38273024 COMPONENTS -a---          10/12/2022 10:06 AM        1048576 DEFAULT -a---          10/15/2022  9:33 PM       13463552 DRIVERS -a---           1/27/2021  2:54 PM          32768 ELAM -a---          10/12/2022 10:06 AM         131072 SAM -a---          10/12/2022 10:06 AM          65536 SECURITY -a---          10/12/2022 10:06 AM      168034304 SOFTWARE -a---          10/12/2022 10:06 AM       29884416 SYSTEM -a---          10/12/2022 10:06 AM           1623 VSMIDK`

Pour une liste détaillée de toutes les ruches du Registre et de leurs fichiers de support dans le SE, nous pouvons consulter [ICI](https://learn.microsoft.com/en-us/windows/win32/sysinfo/registry-hives). Parlons maintenant des valeurs dans le Registre.

### Que sont les valeurs

Les `valeurs` représentent des données sous forme d'objets qui se rapportent à cette clé spécifique. Ces valeurs se composent d'un nom, d'une spécification de type et des données requises pour identifier leur fonction. L'image ci-dessous représente visuellement les `valeurs` comme les données entre les lignes `oranges`. Ces valeurs sont imbriquées dans la clé Installer, qui se trouve elle-même à l'intérieur d'une autre clé.

#### Valeurs

![Éditeur du Registre affichant le chemin : HKEY_LOCAL_MACHINE\SOFTWARE\Adobe\Adobe Acrobat\10.0\Installer. Le volet de droite affiche 'DisableMaintenance' avec la valeur 1.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/registry-values.png)

Nous pouvons consulter la liste complète des valeurs de clés du Registre [ICI](https://docs.microsoft.com/en-us/windows/win32/sysinfo/registry-value-types). En tout, il y a 11 types de valeurs différents qui peuvent être configurés.

### Ruches du Registre

Chaque hôte Windows possède un ensemble de clés de Registre prédéfinies qui gèrent l'hôte et les paramètres requis pour son utilisation. Vous trouverez ci-dessous une description de chaque ruche et de ce que l'on peut y trouver.

#### Détail des ruches

|**Nom**|**Abréviation**|**Description**|
|---|---|---|
|HKEY_LOCAL_MACHINE|`HKLM`|Cette sous-arborescence contient des informations sur l'`état physique` de l'ordinateur, telles que les données sur le matériel et le système d'exploitation, les types de bus, la mémoire, les pilotes de périphériques, et plus encore.|
|HKEY_CURRENT_CONFIG|`HKCC`|Cette section contient les enregistrements du `profil matériel actuel` de l'hôte (montre la différence entre les configurations actuelles et par défaut). Considérez cela comme une redirection de la clé de profil [HKLM](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc739525\(v=ws.10\)) CurrentControlSet.|
|HKEY_CLASSES_ROOT|`HKCR`|Les informations sur les types de fichiers, les extensions de l'interface utilisateur et les paramètres de rétrocompatibilité sont définis ici.|
|HKEY_CURRENT_USER|`HKCU`|Les entrées de valeur ici définissent les paramètres spécifiques du SE et des logiciels pour chaque utilisateur. Les paramètres du `profil itinérant`, y compris les préférences de l'utilisateur, sont stockés sous HKCU.|
|HKEY_USERS|`HKU`|Le profil utilisateur `par défaut` et les paramètres de configuration de l'utilisateur actuel pour l'ordinateur local sont définis sous HKU.|

Il existe d'autres clés prédéfinies pour le Registre, mais elles sont spécifiques à certaines versions et paramètres régionaux de Windows. Pour plus d'informations sur ces entrées et les clés du Registre en général, consultez la documentation fournie par [Microsoft](https://learn.microsoft.com/en-us/windows/win32/sysinfo/predefined-keys).

### Pourquoi les informations stockées dans le Registre sont-elles importantes ?

En tant que testeur d'intrusion, le Registre peut être une mine d'or d'informations qui peuvent nous aider à faire progresser nos missions. Tout, des logiciels installés à la version actuelle du SE, en passant par les paramètres de sécurité pertinents, le contrôle de Defender, et plus encore, se trouve dans le Registre. Pouvons-nous trouver toutes ces informations ailleurs ? Oui. Mais il n'y a pas de meilleur point unique pour tout trouver et avoir la capacité d'apporter des changements étendus à l'hôte simultanément. D'un point de vue offensif, le Registre est difficile à protéger pour les défenseurs. Les ruches sont énormes et remplies de centaines d'entrées. Trouver un seul changement ou ajout parmi les ruches, c'est comme chercher une aiguille dans une botte de foin (sauf s'ils conservent des sauvegardes solides de leurs configurations et de l'état de l'hôte). Avoir une compréhension générale du Registre et de l'emplacement des valeurs clés peut nous aider à agir plus rapidement et, pour les défenseurs, à repérer les problèmes plus tôt.

---

## Comment accéder aux informations ?

Depuis la CLI, nous avons plusieurs options pour accéder au Registre et gérer nos clés. La première consiste à utiliser [reg.exe](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg). `Reg` est un exécutable DOS spécialement conçu pour la gestion des paramètres du Registre. La seconde consiste à utiliser les cmdlets `Get-Item` et `Get-ItemProperty` pour lire les clés et les valeurs. Si nous souhaitons apporter une modification, l'utilisation de New-ItemProperty fera l'affaire.

### Interroger les entrées du Registre

Nous allons d'abord examiner l'utilisation de `Get-Item` et `Get-ChildItem`. Ci-dessous, nous pouvons voir la sortie de l'utilisation de Get-Item et de la redirection du résultat vers Select-Object.

#### Get-Item

        powershell
`PS C:\htb> Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run | Select-Object -ExpandProperty Property    SecurityHealth RtkAudUService WavesSvc DisplayLinkTrayApp LogiOptions Acrobat Assistant 8.0 (default) Focusrite Notifier AdobeGCInvoker-1.0`

C'est une sortie simple qui ne nous montre que le nom des services/applications en cours d'exécution. Si nous souhaitions voir chaque clé et objet dans une ruche, nous pourrions également utiliser `Get-ChildItem` avec le paramètre `-Recurse` comme ceci :

#### Recherche récursive

        powershell
`PS C:\htb> Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion -Recurse  Hive: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths <SNIP> Name                           Property ----                           -------- 7zFM.exe                       (default) : C:\Program Files\7-Zip\7zFM.exe                                Path      : C:\Program Files\7-Zip\ Acrobat.exe                    (default) : C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe                                Path      : C:\Program Files\Adobe\Acrobat DC\Acrobat\ AcrobatInfo.exe                (default) : C:\Program Files\Adobe\Acrobat DC\Acrobat\AcrobatInfo.exe                                Path      : C:\Program Files\Adobe\Acrobat DC\Acrobat\ AcroDist.exe                   Path      : C:\Program Files\Adobe\Acrobat DC\Acrobat\                                (default) : C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrodist.exe Ahk2Exe.exe                    (default) : C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe AutoHotkey.exe                 (default) : C:\Program Files\AutoHotkey\AutoHotkey.exe chrome.exe                     (default) : C:\Program Files\Google\Chrome\Application\chrome.exe                                Path      : C:\Program Files\Google\Chrome\Application cmmgr32.exe                    CmNative          : 2                                CmstpExtensionDll : C:\Windows\System32\cmcfg32.dll CNMNSST.exe                    (default) : C:\Program Files (x86)\Canon\IJ Network Scanner Selector EX\CNMNSST.exe                                Path      : C:\Program Files (x86)\Canon\IJ Network Scanner Selector EX devenv.exe                     (default) : "C:\Program Files\Microsoft Visual                                Studio\2022\Community\common7\ide\devenv.exe" dfshim.dll                     UseURL : 1 excel.exe                      (default) : C:\Program Files\Microsoft Office\Root\Office16\EXCEL.EXE                                Path      : C:\Program Files\Microsoft Office\Root\Office16\                                UseURL    : 1                                SaveURL   : 1 fsquirt.exe                    DropTarget : {047ea9a0-93bb-415f-a1c3-d7aeb3dd5087} IEDIAG.EXE                     (default) : C:\Program Files\Internet Explorer\IEDIAGCMD.EXE                                Path      : C:\Program Files\Internet Explorer; IEDIAGCMD.EXE                  (default) : C:\Program Files\Internet Explorer\IEDIAGCMD.EXE                                Path      : C:\Program Files\Internet Explorer; IEXPLORE.EXE                   (default) : C:\Program Files\Internet Explorer\IEXPLORE.EXE                                Path      : C:\Program Files\Internet Explorer; install.exe                    BlockOnTSNonInstallMode : 1 javaws.exe                     (default) : C:\Program Files\Java\jre1.8.0_341\bin\javaws.exe                                Path      : C:\Program Files\Java\jre1.8.0_341\bin licensemanagershellext.exe     (default) : C:\Windows\System32\licensemanagershellext.exe mip.exe                        (default) : C:\Program Files\Common Files\Microsoft Shared\Ink\mip.exe mpc-hc64.exe                   (default) : C:\Program Files (x86)\K-Lite Codec Pack\MPC-HC64\mpc-hc64.exe                                Path      : C:\Program Files (x86)\K-Lite Codec Pack\MPC-HC64 mplayer2.exe                   (default) : "C:\Program Files\Windows Media Player\wmplayer.exe"                                Path      : C:\Program Files\Windows Media Player MSACCESS.EXE                   (default) : C:\Program Files\Microsoft Office\Root\Office16\MSACCESS.EXE                                Path      : C:\Program Files\Microsoft Office\Root\Office16\                                UseURL    : 1 msedge.exe                     (default) : C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe                                Path      : C:\Program Files (x86)\Microsoft\Edge\Application      Hive: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe  Name                           Property ----                           -------- SupportedProtocols             http  :                                https : <SNIP>`  

Nous avons tronqué la sortie car elle développe et montre chaque clé et les valeurs associées dans la clé `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion`. Nous pouvons rendre notre sortie plus facile à lire en utilisant la cmdlet `Get-ItemProperty`. Essayons cette même requête mais avec `Get-ItemProperty`.

#### Get-ItemProperty

        powershell
`PS C:\htb> Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run  SecurityHealth        : C:\Windows\system32\SecurityHealthSystray.exe RtkAudUService        : "C:\Windows\System32\DriverStore\FileRepository\realtekservice.inf_amd64_85cff5320735903                         d\RtkAudUService64.exe" -background WavesSvc              : "C:\Windows\System32\DriverStore\FileRepository\wavesapo9de.inf_amd64_d350b8504310bbf5\W                         avesSvc64.exe" -Jack DisplayLinkTrayApp    : "C:\Program Files\DisplayLink Core Software\DisplayLinkTrayApp.exe" -basicMode LogiOptions           : C:\Program Files\Logitech\LogiOptions\LogiOptions.exe /noui Acrobat Assistant 8.0 : "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrotray.exe" (default)             : Focusrite Notifier    : "C:\Program Files\Focusriteusb\Focusrite Notifier.exe" AdobeGCInvoker-1.0    : "C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient\AGCInvokerUtility.exe" PSPath                : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Curren                         tVersion\Run PSParentPath          : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Curren                         tVersion PSChildName           : Run PSProvider            : Microsoft.PowerShell.Core\Registry`

Analysons cela. Nous avons lancé la commande `Get-ItemProperty`, spécifié notre `path` comme regardant dans le Registre, et spécifié la clé `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`. La sortie nous fournit le `nom` des services démarrés et la `valeur` qui a été utilisée pour les exécuter (le chemin depuis lequel ils ont été exécutés). Cette clé de Registre est utilisée pour `démarrer` des services/applications lorsqu'un utilisateur `se connecte` à l'hôte. C'est une excellente clé sur laquelle avoir de la visibilité et à garder à l'esprit en tant que testeur d'intrusion. Il existe plusieurs versions de cette clé que nous aborderons un peu plus tard dans cette section. L'utilisation de Get-ItemProperty est beaucoup plus lisible que celle de Get-Item. Lorsqu'il s'agit d'interroger des informations, nous pouvons également utiliser Reg.exe. Jetons un coup d'œil à la sortie de cette commande. Nous allons examiner une clé plus simple pour cet exemple.

#### Reg.exe

        powershell
`PS C:\htb> reg query HKEY_LOCAL_MACHINE\SOFTWARE\7-Zip  HKEY_LOCAL_MACHINE\SOFTWARE\7-Zip     Path64    REG_SZ    C:\Program Files\7-Zip\     Path    REG_SZ    C:\Program Files\7-Zip\`

Nous avons interrogé la clé `HKEY_LOCAL_MACHINE\SOFTWARE\7-Zip` avec Reg.exe, ce qui nous a fourni les valeurs associées. Nous pouvons voir que `deux` valeurs sont définies, `Path` et `Path64`, le ValueType est une valeur `Reg_SZ` qui spécifie qu'elle contient une chaîne de caractères Unicode ou ASCII, et que cette valeur est le chemin vers 7-Zip `C:\Program Files\7-Zip\`.

## Trouver des informations dans le Registre

Pour nous, en tant que testeurs d'intrusion et administrateurs, trouver des données dans le Registre est une compétence indispensable. C'est là que `Reg.exe` brille vraiment pour nous. Nous pouvons l'utiliser pour rechercher des mots-clés et des chaînes comme `Password` et `Username` dans les noms de clés et de valeurs ou dans les données qu'ils contiennent. Avant de l'utiliser, décomposons l'utilisation de `Reg Query`. Nous allons examiner la chaîne de commande `REG QUERY HKCU /F "password" /t REG_SZ /S /K`.

- `Reg query` : Nous faisons appel à Reg.exe et spécifions que nous voulons interroger des données.
- `HKCU` : Cette partie définit le chemin de recherche. Dans ce cas, nous cherchons dans tout HKey_Current_User.
- `/f "password"` : /f définit le modèle que nous recherchons. Dans ce cas, nous cherchons "Password".
- `/t REG_SZ` : /t définit le type de valeur à rechercher. Si nous ne le spécifions pas, reg query cherchera dans tous les types.
- `/s` : /s indique de rechercher récursivement dans toutes les sous-clés et valeurs.
- `/k` : /k limite la recherche aux noms de clés uniquement.

#### Recherche avec Reg Query

        powershell
`PS C:\htb>  REG QUERY HKCU /F "Password" /t REG_SZ /S /K  HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Winlogon\PasswordExpiryNotification     NotShownErrorTime    REG_SZ    08::23::24, 2022/10/19     NotShownErrorReason    REG_SZ    GetPwdResetInfoFailed  End of search: 2 match(es) found.`

Les résultats de cette requête ne sont pas des plus passionnants, mais cela vaut quand même la peine de jeter un œil et d'utiliser une recherche similaire pour d'autres mots-clés et phrases comme Username, Credentials et Keys. Nous pourrions être surpris par ce que nous trouvons. Comme nous pouvons le voir, interroger les clés et les valeurs du Registre est relativement facile. Et si nous voulions définir une nouvelle valeur ou créer une nouvelle clé ?

### Créer et modifier des clés et des valeurs du Registre

Lorsqu'il s'agit de modifier ou de créer de `nouvelles clés et valeurs`, nous pouvons utiliser des cmdlets PowerShell standard comme `New-Item`, `Set-Item`, `New-ItemProperty` et `Set-ItemProperty` ou utiliser à nouveau `Reg.exe` pour effectuer les changements dont nous avons besoin. Essayons de créer une nouvelle clé de Registre ci-dessous. Pour notre exemple, nous allons créer une nouvelle clé de test dans la ruche RunOnce `HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce` nommée `TestKey`. En plaçant la clé et la valeur dans RunOnce, elle sera supprimée après son exécution.

**Scénario : Nous avons atterri sur un hôte et pouvons ajouter une nouvelle clé de registre pour la persistance. Nous devons définir une clé nommée `TestKey` et une valeur de `C:\Users\htb-student\Downloads\payload.exe` qui indique à RunOnce d'exécuter notre charge utile (payload) que nous laissons sur l'hôte la prochaine fois que l'utilisateur se connectera. Cela garantira que si l'hôte redémarre ou si nous perdons l'accès, la prochaine fois que l'utilisateur se connectera, nous obtiendrons un nouveau shell.**

#### Nouvelle clé du Registre

        powershell
`PS C:\htb> New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\ -Name TestKey      Hive: HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce  Name                           Property ----                           -------- TestKey`   

Nous avons maintenant une nouvelle clé dans la clé RunOnce. En spécifiant le paramètre `-Path`, nous évitons de changer notre emplacement dans le shell vers l'endroit où nous voulons ajouter une clé dans le Registre, ce qui nous permet de travailler de n'importe où tant que nous spécifions le chemin absolu. Définissons maintenant une propriété et une valeur.

#### Définir une nouvelle propriété d'élément du Registre

        powershell
`PS C:\htb>  New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\TestKey -Name  "access" -PropertyType String -Value "C:\Users\htb-student\Downloads\payload.exe"  access       : C:\Users\htb-student\Downloads\payload.exe PSPath       : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\                TestKey PSParentPath : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce PSChildName  : TestKey PSDrive      : HKCU PSProvider   : Microsoft.PowerShell.Core\Registry`

Après avoir utilisé New-ItemProperty pour définir notre valeur nommée `access` et spécifié la valeur comme `C:\Users\htb-student\Downloads\payload.exe`, nous pouvons voir dans les résultats que notre valeur a été créée avec succès, ainsi que les informations correspondantes, telles que l'emplacement du chemin et le nom de la clé. Juste pour montrer que notre clé a été créée, nous pouvons voir la nouvelle clé et ses valeurs dans l'image ci-dessous depuis l'éditeur graphique du Registre.

#### Création de TestKey

![Éditeur du Registre affichant le chemin : HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\TestKey. Le volet de droite affiche 'access' avec le chemin vers 'C:\Users\htb-student\Downloads\payload.exe'.](https://cdn.services-k8s.prod.aws.htb.systems/content/modules/167/testkeys.png)

Si nous voulions ajouter la même paire clé/valeur en utilisant Reg.exe, nous le ferions comme ceci :

        PowerShell
`reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce\TestKey" /v access /t REG_SZ /d "C:\Users\htb-student\Downloads\payload.exe"`  

Maintenant, dans un vrai pentest, nous aurions laissé une charge utile exécutable sur l'hôte, et dans le cas où l'hôte redémarre ou l'utilisateur se connecte, nous acquerrions un nouveau shell vers notre C2. Cette valeur ne nous est pas très utile pour le moment, alors entraînons-nous à la supprimer.

#### Supprimer les propriétés du Registre

        powershell
`PS C:\htb> Remove-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\TestKey -Name  "access"  PS C:\htb> Get-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\TestKey`

Si aucune fenêtre d'erreur n'est apparue, notre paire clé/valeur a été supprimée avec succès. Cependant, c'est l'une de ces choses avec lesquelles vous devez être extrêmement prudent. La suppression d'entrées du Registre Windows pourrait avoir un effet négatif sur l'hôte et son fonctionnement. Assurez-vous de savoir ce que vous supprimez avant de le faire. Selon les sages paroles de l'oncle Ben, "`Un grand pouvoir implique de grandes responsabilités.`"

---

## Et maintenant

Maintenant que nous maîtrisons la gestion du Registre, il est temps de passer à la gestion des journaux d'événements via PowerShell.

LAB de fin

![[Pasted image 20260903165203.png]] 
Rep : Values 

![[Pasted image 20260903165230.png]]

Rep : HKCU


![[Pasted image 20260903175458.png]] 
ici on va essayer d'executer  rufus.exe pour le test 

![[Pasted image 20260903175635.png]]

on l'a déja ici donc le chemin vers l'exe est C:\Users\htb-student\rufus.exe

maintenant notre but c'est de pouvoir exectuer rufus.exe dés que l'utilisateur ouvre sa session  
donc le but pour nous serait de manipuler la ruche windows qui gère se genre de comportement donc : `HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce`
ou 
```
HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\
```
on peut créer une valeur pour qu'elle pointe vers notre executable 

avec : 
```Powershell
reg add KEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce`/v access /t REG_SZ /d " C:\Users\htb-student\rufus.exe"
```
ou 

``` Powershell
New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\ -Name  "access" -PropertyType String -Value "C:\Users\htb-student\Downloads\payload.exe"
```

![[Pasted image 20260903181425.png]]
une fois exécuter on se déconnecter de la session et se reconnecter pour voir l’exécution de l'exécutable 

![[Pasted image 20260903181708.png]]

on c'est reconnecter 
![[Pasted image 20260903181806.png]]

rufus.exe n'a pas pu s'exécuter pourquoi parceque dans notre commande 
pour la liason de donnée payload.exe n'existe pas don rien ne s'execute 
revoyaon la commande 
![[Pasted image 20260903182309.png]]

maintenat que c'est bon  on se deconnecte et on se relogue  et après avoir changer le chemin en  C:\Users\htb-student\rufus.exe 
on a : 

![[Pasted image 20260903183344.png]]

et on a rufus qui c'est executer 
![[Pasted image 20260903183414.png]]