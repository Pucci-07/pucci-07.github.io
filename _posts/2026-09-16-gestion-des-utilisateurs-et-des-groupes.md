[[Command Prompt Basics]]

En tant qu'administrateur système, la gestion des utilisateurs et des groupes est une compétence clé, car nos utilisateurs sont souvent notre principal atout à gérer et, généralement, le plus grand vecteur d'attaque d'une organisation. En tant que pentesters, comprendre comment énumérer, interpréter et tirer parti des utilisateurs et des groupes est l'un des moyens les plus simples d'obtenir un accès et d'élever nos privilèges lors d'une mission de pentest. Cette section couvrira ce que sont les utilisateurs et les groupes, comment les gérer avec PowerShell, et introduira brièvement le concept des domaines Active Directory et des utilisateurs de domaine.

---

## Que sont les comptes utilisateur ?

Les comptes utilisateur sont un moyen pour le personnel d'accéder et d'utiliser les ressources d'un hôte. Dans certaines circonstances, le système utilisera également un compte utilisateur spécialement provisionné pour effectuer des actions. Lorsque nous pensons aux comptes, nous rencontrons généralement quatre types différents :

- Comptes de service (Service Accounts)
- Comptes intégrés (Built-in accounts)
- Utilisateurs locaux (Local users)
- Utilisateurs de domaine (Domain users)

### Comptes utilisateur locaux par défaut

Plusieurs comptes sont créés dans chaque instance de Windows lors de l'installation du système d'exploitation pour aider à la gestion de l'hôte et à l'utilisation de base. Vous trouverez ci-dessous une liste des comptes intégrés standard.

#### Comptes intégrés

|**Compte**|**Description**|
|---|---|
|`Administrator`|Ce compte est utilisé pour accomplir des tâches administratives sur l'hôte local.|
|`Default Account`|Le compte par défaut est utilisé par le système pour exécuter des applications d'authentification multi-utilisateurs comme l'utilitaire Xbox.|
|`Guest Account`|Ce compte est un compte à droits limités qui permet aux utilisateurs sans compte utilisateur normal d'accéder à l'hôte. Il est désactivé par défaut et doit le rester.|
|`WDAGUtility Account`|Ce compte est utilisé pour Defender Application Guard, qui peut isoler les sessions d'application dans un bac à sable (sandbox).|

---

## Brève introduction à Active Directory

En bref, `Active Directory` (AD) est un service d'annuaire (directory service) pour les environnements Windows qui fournit un point de gestion central pour les `utilisateurs`, les ordinateurs, les `groupes`, les périphériques réseau, les `partages de fichiers`, les stratégies de groupe, les `périphériques` et les approbations avec d'autres organisations. Pensez-y comme le gardien d'un environnement d'entreprise. Toute personne faisant partie du domaine peut accéder librement aux ressources, tandis que toute personne qui n'en fait pas partie se voit refuser l'accès à ces mêmes ressources ou, au minimum, est bloquée en attente au centre des visiteurs.

Dans cette section, nous nous intéressons à AD dans le contexte des utilisateurs et des groupes. Nous pouvons les administrer depuis PowerShell sur `n'importe quel hôte joint au domaine` en utilisant le module `ActiveDirectory`. Plonger en profondeur dans Active Directory prendrait plus d'une section, nous n'essaierons donc pas de le faire ici. Pour en savoir plus sur AD, vous devriez consulter le module [Introduction à Active Directory](https://academy.hackthebox.com/module/details/74).

### Utilisateurs locaux vs. utilisateurs joints au domaine

`En quoi sont-ils différents ?`

Les utilisateurs de `domaine` diffèrent des utilisateurs `locaux` en ce qu'ils se voient accorder des droits par le domaine pour accéder à des ressources telles que des serveurs de fichiers, des imprimantes, des hôtes intranet et d'autres objets en fonction de l'appartenance de l'utilisateur et du groupe. Les comptes d'utilisateurs de domaine peuvent se connecter à n'importe quel hôte du domaine, tandis que l'utilisateur local n'a la permission d'accéder qu'à l'hôte spécifique sur lequel il a été créé.

Il est utile de consulter la documentation sur les [comptes](https://learn.microsoft.com/en-us/windows/security/identity-protection/access-control/local-accounts) pour mieux comprendre comment les différents comptes fonctionnent ensemble sur un système Windows individuel et à travers un réseau de domaine. Prenez le temps de les examiner et de comprendre les nuances entre eux. Comprendre leurs utilisations et l'utilité de chaque type de compte peut faire réussir ou échouer la tentative d'un pentester d'obtenir un accès privilégié ou d'effectuer un mouvement latéral (lateral movement) lors d'un test d'intrusion.

### Que sont les groupes d'utilisateurs ?

Les groupes sont un moyen de trier logiquement les comptes utilisateur et, ce faisant, de fournir des permissions granulaires et un accès aux ressources sans avoir à gérer chaque utilisateur manuellement. Par exemple, nous pourrions restreindre l'accès à un répertoire ou à un partage spécifique afin que seuls les utilisateurs qui ont besoin d'y accéder puissent voir les fichiers. Sur un seul hôte, cela ne signifie pas grand-chose pour nous. Cependant, le regroupement logique est essentiel pour maintenir une posture de sécurité (security posture) adéquate au sein d'un domaine de centaines, voire de milliers, d'utilisateurs. Du point de vue du domaine, nous avons plusieurs types de groupes différents qui peuvent contenir non seulement des utilisateurs mais aussi des périphériques finaux comme des PC, des imprimantes, et même d'autres groupes. Ce concept est une plongée trop profonde pour ce module. Cependant, nous allons parler pour l'instant de la manière de gérer les groupes. Si vous souhaitez en savoir plus et approfondir vos connaissances sur Active Directory et la manière dont il utilise les groupes pour maintenir la sécurité, consultez ce [module](https://academy.hackthebox.com/module/details/74).

#### Get-LocalGroup

        powershell
`PS C:\htb> get-localgroup  Name                                Description ----                                ----------- __vmware__                          VMware User Group Access Control Assistance Operators Members of this group can remotely query authorization attributes and permission... Administrators                      Administrators have complete and unrestricted access to the computer/domain Backup Operators                    Backup Operators can override security restrictions for the sole purpose of back... Cryptographic Operators             Members are authorized to perform cryptographic operations. Device Owners                       Members of this group can change system-wide settings. Distributed COM Users               Members are allowed to launch, activate and use Distributed COM objects on this ... Event Log Readers                   Members of this group can read event logs from local machine Guests                              Guests have the same access as members of the Users group by default, except for... Hyper-V Administrators              Members of this group have complete and unrestricted access to all features of H... IIS_IUSRS                           Built-in group used by Internet Information Services. Network Configuration Operators     Members in this group can have some administrative privileges to manage configur... Performance Log Users               Members of this group may schedule logging of performance counters, enable trace... Performance Monitor Users           Members of this group can access performance counter data locally and remotely Power Users                         Power Users are included for backwards compatibility and possess limited adminis... Remote Desktop Users                Members in this group are granted the right to logon remotely Remote Management Users             Members of this group can access WMI resources over management protocols (such a... Replicator                          Supports file replication in a domain System Managed Accounts Group       Members of this group are managed by the system. Users                               Users are prevented from making accidental or intentional system-wide changes an...`  

Ci-dessus se trouve un exemple des groupes locaux sur un hôte autonome. Nous pouvons voir qu'il y a des groupes pour des choses simples comme les administrateurs et les comptes invités, mais aussi des groupes pour des rôles spécifiques comme les administrateurs pour les applications de virtualisation, les utilisateurs distants, etc. Interagissons maintenant avec les utilisateurs et les groupes, maintenant que nous les comprenons.

## Ajout/Suppression/Modification des comptes et groupes d'utilisateurs

Comme pour la plupart des autres choses dans PowerShell, nous utilisons les verbes `get`, `new`, et `set` pour trouver, créer et modifier des utilisateurs et des groupes. Si l'on a affaire à des utilisateurs et groupes locaux, `localuser & localgroup` peuvent accomplir cela. Pour les ressources de domaine, `aduser & adgroup` font l'affaire. Si nous n'étions pas sûrs, nous pourrions toujours utiliser la cmdlet `Get-Command *user*` pour voir ce à quoi nous avons accès. Essayons-en quelques-unes.

#### Identification des utilisateurs locaux

        powershell
`PS C:\htb> Get-LocalUser      Name               Enabled Description ----               ------- ----------- Administrator      False   Built-in account for administering the computer/domain DefaultAccount     False   A user account managed by the system. DLarusso           True    High kick specialist. Guest              False   Built-in account for guest access to the computer/domain sshd               True WDAGUtilityAccount False   A user account managed and used by the system for Windows Defender A...`

`Get-LocalUser` affichera les utilisateurs sur notre hôte. Ces utilisateurs n'ont accès qu'à cet hôte particulier. Disons que nous voulons créer un nouvel utilisateur local nommé `JLawrence`. Nous pouvons accomplir la tâche en utilisant `New-LocalUser`. Si nous ne sommes pas sûrs de la syntaxe appropriée, n'oubliez pas la commande `Get-Help`. Lors de la création d'un nouvel utilisateur local, la seule véritable exigence du point de vue de la syntaxe est de saisir un `name` et de spécifier un `password` (ou `-NoPassword`). Tous les autres paramètres, tels qu'une description ou l'expiration du compte, sont optionnels.

#### Création d'un nouvel utilisateur

        powershell
`PS C:\htb>  New-LocalUser -Name "JLawrence" -NoPassword  Name      Enabled Description ----      ------- ----------- JLawrence True`

Ci-dessus, nous avons créé l'utilisateur `JLawrence` et n'avons pas défini de mot de passe. Ce compte est donc actif et peut être utilisé pour se connecter sans mot de passe. Selon la version de Windows que nous utilisons, en ne définissant pas de mot de passe, nous indiquons à Windows qu'il s'agit d'un compte Microsoft Live, et il tente de se connecter de cette manière au lieu d'utiliser un mot de passe local.

Si nous souhaitons modifier un utilisateur, nous pourrions utiliser la cmdlet `Set-LocalUser`. Pour cet exemple, nous allons modifier `JLawrence` et définir un mot de passe et une description sur son compte.

#### Modification d'un utilisateur

        powershell
`PS C:\htb> $Password = Read-Host -AsSecureString **************** PS C:\htb> Set-LocalUser -Name "JLawrence" -Password $Password -Description "CEO EagleFang" PS C:\htb> Get-LocalUser    Name               Enabled Description ----               ------- ----------- Administrator      False   Built-in account for administering the computer/domain DefaultAccount     False   A user account managed by the system. demo               True Guest              False   Built-in account for guest access to the computer/domain JLawrence          True    CEO EagleFang`

Pour ce qui est de créer et de modifier des utilisateurs, c'est aussi simple que ce que nous voyons ci-dessus. Passons maintenant à l'examen des groupes. Si cela ressemble un peu à un écho... eh bien, ça l'est. Les commandes sont similaires dans leur utilisation.

#### Get-LocalGroup

        powershell
`PS C:\htb> Get-LocalGroup    Name                                Description ----                                ----------- Access Control Assistance Operators Members of this group can remotely query authorization attr... Administrators                      Administrators have complete and unrestricted access to the... Backup Operators                    Backup Operators can override security restrictions for the... Cryptographic Operators             Members are authorized to perform cryptographic operations. Device Owners                       Members of this group can change system-wide settings. Distributed COM Users               Members are allowed to launch, activate and use Distributed... Event Log Readers                   Members of this group can read event logs from local machine Guests                              Guests have the same access as members of the Users group b... Hyper-V Administrators              Members of this group have complete and unrestricted access... IIS_IUSRS                           Built-in group used by Internet Information Services. Network Configuration Operators     Members in this group can have some administrative privileg... Performance Log Users               Members of this group may schedule logging of performance c... Performance Monitor Users           Members of this group can access performance counter data l... Power Users                         Power Users are included for backwards compatibility and po... Remote Desktop Users                Members in this group are granted the right to logon remotely Remote Management Users             Members of this group can access WMI resources over managem... Replicator                          Supports file replication in a domain System Managed Accounts Group       Members of this group are managed by the system. Users                               Users are prevented from making accidental or intentional s...  PS C:\Windows\system32> Get-LocalGroupMember -Name "Users"  ObjectClass Name                             PrincipalSource ----------- ----                             --------------- User        DESKTOP-B3MFM77\demo             Local User        DESKTOP-B3MFM77\JLawrence        Local Group       NT AUTHORITY\Authenticated Users Unknown Group       NT AUTHORITY\INTERACTIVE         Unknown`

Dans la sortie ci-dessus, nous avons exécuté la cmdlet `Get-LocalGroup` pour obtenir une liste de chaque groupe sur l'hôte. Dans la deuxième commande, nous avons décidé d'inspecter le groupe `Users` et de voir qui en est membre. Nous l'avons fait avec la commande `Get-LocalGroupMember`. Maintenant, si nous souhaitons ajouter un autre groupe ou utilisateur à un groupe, nous pouvons utiliser la commande `Add-LocalGroupMember`. Dans l'exemple ci-dessous, nous allons ajouter `JLawrence` au groupe `Remote Desktop Users`.

#### Ajout d'un membre à un groupe

        powershell
`PS C:\htb> Add-LocalGroupMember -Group "Remote Desktop Users" -Member "JLawrence" PS C:\htb> Get-LocalGroupMember -Name "Remote Desktop Users"   ObjectClass Name                      PrincipalSource ----------- ----                      --------------- User        DESKTOP-B3MFM77\JLawrence Local`

Après avoir exécuté la commande, nous avons vérifié l'appartenance au groupe et avons vu que notre utilisateur a bien été ajouté au groupe Remote Desktop Users. La maintenance des utilisateurs et groupes locaux est simple et ne nécessite pas de modules externes. La gestion des utilisateurs et groupes Active Directory demande un peu plus de travail.

### Gestion des utilisateurs et des groupes de domaine

Avant de pouvoir accéder aux cmdlets dont nous avons besoin et de travailler avec Active Directory, nous devons installer le module PowerShell `ActiveDirectory`. Si vous avez installé AdminToolbox, le module AD est peut-être déjà sur votre hôte. Sinon, nous pouvons rapidement récupérer les modules AD et nous mettre au travail. Une exigence est d'avoir la fonctionnalité optionnelle `Remote System Administration Tools` (Outils d'administration de serveur distant) installée. Cette fonctionnalité est le seul moyen d'obtenir le module PowerShell officiel ActiveDirectory. La version dans AdminToolbox et d'autres modules est reconditionnée, donc soyez prudent.

#### Installation de RSAT

        powershell
`PS C:\htb> Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online  Path          :   Online        : True   RestartNeeded : False`  

La commande ci-dessus installera `TOUTES` les fonctionnalités RSAT du catalogue Microsoft. Si nous souhaitons rester légers, nous pouvons installer le paquet nommé `Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0`. Maintenant, nous devrions avoir le module ActiveDirectory installé. Vérifions.

#### Localisation du module AD

        powershell
`PS C:\htb> Get-Module -Name ActiveDirectory -ListAvailable       Directory: C:\Windows\system32\WindowsPowerShell\v1.0\Modules   ModuleType Version    Name                                ExportedCommands ---------- -------    ----                                ---------------- Manifest   1.0.1.0    ActiveDirectory                     {Add-ADCentralAccessPolicyMember, Add-ADComputerServiceAccount, Add-ADDomainControllerPasswordReplicationPolicy, Add-A...`

Parfait. Maintenant que nous avons le module, nous pouvons commencer avec la gestion des `utilisateurs` et `groupes` AD. Le moyen le plus simple de localiser un utilisateur spécifique est de rechercher avec la cmdlet `Get-ADUser`.

#### Get-ADUser

        powershell
`PS C:\htb> Get-ADUser -Filter *  DistinguishedName : CN=user14,CN=Users,DC=greenhorn,DC=corp Enabled           : True GivenName         : Name              : user14 ObjectClass       : user ObjectGUID        : bef9787d-2716-4dc9-8e8f-f8037a72c3d9 SamAccountName    : user14 SID               : S-1-5-21-1480833693-1324064541-2711030367-1110 Surname           : UserPrincipalName :  DistinguishedName : CN=sshd,CN=Users,DC=greenhorn,DC=corp Enabled           : True GivenName         : Name              : sshd ObjectClass       : user ObjectGUID        : 7a324e98-00e4-480b-8a1a-fa465d558063 SamAccountName    : sshd SID               : S-1-5-21-1480833693-1324064541-2711030367-1112 Surname           : UserPrincipalName :  DistinguishedName : CN=TSilver,CN=Users,DC=greenhorn,DC=corp Enabled           : True GivenName         : Name              : TSilver ObjectClass       : user ObjectGUID        : a19a6c8a-000a-4cbf-aa14-0c7fca643c37 SamAccountName    : TSilver SID               : S-1-5-21-1480833693-1324064541-2711030367-1602 Surname           : UserPrincipalName :    <SNIP>`

Le paramètre `-Filter *` nous permet de récupérer tous les utilisateurs dans Active Directory. Selon la taille de notre organisation, cela pourrait produire une tonne de résultats. Nous pouvons utiliser le paramètre `-Identity` pour effectuer une recherche plus spécifique d'un utilisateur par `distinguished name, GUID, objectSid, ou SamAccountName`. Ne vous inquiétez pas si ces options vous semblent du charabia ; ce n'est pas grave. Les spécificités de celles-ci ne sont pas importantes pour l'instant ; pour plus de lecture sur le sujet, consultez [cet article](https://learn.microsoft.com/en-us/windows/win32/ad/naming-properties) ou le module [Intro To Active Directory](https://academy.hackthebox.com/course/preview/introduction-to-active-directory). Nous allons maintenant rechercher l'utilisateur `TSilver`.

#### Obtenir un utilisateur spécifique

        powershell
`PS C:\htb>  Get-ADUser -Identity TSilver   DistinguishedName : CN=TSilver,CN=Users,DC=greenhorn,DC=corp Enabled           : True GivenName         : Name              : TSilver ObjectClass       : user ObjectGUID        : a19a6c8a-000a-4cbf-aa14-0c7fca643c37 SamAccountName    : TSilver SID               : S-1-5-21-1480833693-1324064541-2711030367-1602 Surname           : UserPrincipalName :`
  

Nous pouvons voir dans la sortie plusieurs informations sur l'utilisateur, notamment :

- `Object Class` : qui spécifie si l'objet est un utilisateur, un ordinateur ou un autre type d'objet.
- `DistinguishedName` : Spécifie le chemin relatif de l'objet dans le schéma AD.
- `Enabled` : Nous indique si l'utilisateur est actif et peut se connecter.
- `SamAccountName` : La représentation du nom d'utilisateur utilisée pour se connecter aux hôtes ActiveDirectory.
- `ObjectGUID` : Est l'identifiant unique de l'objet utilisateur.

Les utilisateurs ont de nombreux attributs différents (tous ne sont pas montrés ici) et peuvent tous être utilisés pour les identifier et les regrouper. Nous pourrions également les utiliser pour filtrer des attributs spécifiques. Par exemple, filtrons l'adresse `EmailAddress` de l'utilisateur.

#### Recherche sur un attribut

        powershell
`PS C:\htb> Get-ADUser -Filter {EmailAddress -like '*greenhorn.corp'}   DistinguishedName : CN=TSilver,CN=Users,DC=greenhorn,DC=corp Enabled           : True GivenName         : Name              : TSilver ObjectClass       : user ObjectGUID        : a19a6c8a-000a-4cbf-aa14-0c7fca643c37 SamAccountName    : TSilver SID               : S-1-5-21-1480833693-1324064541-2711030367-1602 Surname           : UserPrincipalName :`

Dans notre sortie, nous pouvons voir que nous n'avions qu'un seul résultat pour un utilisateur avec une adresse e-mail correspondant à notre contexte de nommage `*greenhorn.corp`. Ce n'est qu'un exemple des attributs sur lesquels nous pouvons filtrer. Pour une liste plus détaillée, consultez cet [article Technet](https://social.technet.microsoft.com/wiki/contents/articles/12037.active-directory-get-aduser-default-and-extended-properties.aspx), qui couvre les propriétés par défaut et étendues de l'objet utilisateur.

Nous devons créer un nouvel utilisateur pour un employé nommé `Mori Tanaka` qui vient de rejoindre Greenhorn. Essayons la cmdlet New-ADUser.

#### New ADUser

        powershell
`PS C:\htb> New-ADUser -Name "MTanaka" -Surname "Tanaka" -GivenName "Mori" -Office "Security" -OtherAttributes @{'title'="Sensei";'mail'="MTanaka@greenhorn.corp"} -Accountpassword (Read-Host -AsSecureString "AccountPassword") -Enabled $true   AccountPassword: **************** PS C:\htb> Get-ADUser -Identity MTanaka -Properties * | Format-Table Name,Enabled,GivenName,Surname,Title,Office,Mail  Name    Enabled GivenName Surname Title  Office   Mail ----    ------- --------- ------- -----  ------   ---- MTanaka    True Mori      Tanaka  Sensei Security MTanaka@greenhorn.corp`

Ok, il se passe beaucoup de choses ici. Cela peut paraître intimidant mais disséquons-le. La `première` partie de la sortie ci-dessus crée notre utilisateur :

- `New-ADUser -Name "MTanaka"` : Nous exécutons la commande `New-ADUser` et définissons le SamAccountName de l'utilisateur à `MTanaka`.
- `-Surname "Tanaka" -GivenName "Mori"` : Cette partie définit le `nom de famille` et le `prénom` de notre utilisateur.
- `-Office "Security"` : Définit la propriété étendue `Office` à `Security`.
- `-OtherAttributes @{'title'="Sensei";'mail'="MTanaka@greenhorn.corp"}` : Ici, nous définissons d'autres attributs étendus tels que `title` et `Email-Address`.
- `-Accountpassword (Read-Host -AsSecureString "AccountPassword")` : Avec cette partie, nous définissons le `mot de passe` de l'utilisateur en demandant au shell de nous inviter à saisir un nouveau mot de passe. (nous pouvons le voir sur la ligne en dessous avec les étoiles)
- `-Enabled $true` : Nous activons le compte pour son utilisation. L'utilisateur ne pourrait pas se connecter si cela était défini sur `$False`.

La `seconde` partie valide que l'utilisateur que nous avons créé et les propriétés que nous avons définies existent :

- `Get-ADUser -Identity MTanaka -Properties *` : Ici, nous recherchons les propriétés de l'utilisateur `MTanaka`.
- `|` : C'est le symbole Pipe. Il sera exploré plus en détail dans une autre section, mais pour l'instant, il prend notre `sortie` de `Get-ADUser` et l'envoie à la commande suivante.
- `Format-Table Name,Enabled,GivenName,Surname,Title,Office,Mail` : Ici, nous disons à PowerShell de `formater` nos résultats sous forme de `tableau` incluant les propriétés par défaut et étendues listées.

Voir les commandes décomposées comme ceci aide à démystifier les chaînes de commandes. Maintenant, que se passe-t-il si nous devons modifier un utilisateur ? `Set-ADUser` est notre solution. Beaucoup des filtres que nous avons examinés plus tôt s'appliquent également ici. Nous pouvons changer ou définir n'importe lequel des attributs qui ont été listés. Pour cet exemple, ajoutons une `Description` à M. Tanaka.

#### Modification des attributs d'un utilisateur

        powershell
`PS C:\htb> Set-ADUser -Identity MTanaka -Description " Sensei to Security Analyst's Rocky, Colt, and Tum-Tum"    PS C:\htb> Get-ADUser -Identity MTanaka -Property Description   Description       :  Sensei to Security Analyst's Rocky, Colt, and Tum-Tum DistinguishedName : CN=MTanaka,CN=Users,DC=greenhorn,DC=corp Enabled           : True GivenName         : Mori Name              : MTanaka ObjectClass       : user ObjectGUID        : c19e402d-b002-4ca0-b5ac-59d416166b3a SamAccountName    : MTanaka SID               : S-1-5-21-1480833693-1324064541-2711030367-1603 Surname           : Tanaka UserPrincipalName :`

En interrogeant AD, nous pouvons voir que la `description` que nous avons définie a été ajoutée aux attributs de M. Tanaka. La gestion des utilisateurs et des groupes est une tâche courante que nous pourrions nous retrouver à faire en tant qu'administrateurs système. Cependant, pourquoi devrions-nous nous en soucier en tant que `pentester` ?

## Pourquoi l'énumération des utilisateurs et des groupes est-elle importante ?

Les utilisateurs et les groupes offrent une mine d'opportunités en matière de pentesting d'un environnement Windows. Nous verrons souvent des utilisateurs mal configurés. Ils peuvent se voir accorder des permissions excessives, être ajoutés à des groupes inutiles ou avoir des mots de passe faibles ou inexistants. Les groupes peuvent être tout aussi précieux. Souvent, les groupes auront une appartenance imbriquée (nested membership), permettant aux utilisateurs d'obtenir des privilèges dont ils n'ont peut-être pas besoin. Ces mauvaises configurations peuvent être facilement trouvées et visualisées avec des outils comme [Bloodhound](https://github.com/BloodHoundAD/BloodHound). Pour un aperçu détaillé de l'énumération des utilisateurs et des groupes, consultez le module [Windows Privilege Escalation](https://academy.hackthebox.com/course/preview/windows-privilege-escalation).

---

## Allons plus loin

Maintenant que nous maîtrisons la gestion des utilisateurs et des groupes, passons à la manipulation des fichiers, des dossiers et d'autres objets avec PowerShell.

Lab de fiser

![Pasted image 20260901234950.png](/assets/img/writeups/Pasted image 20260901234950.png)

Rep : Active Directory 

![Pasted image 20260901235225.png](/assets/img/writeups/Pasted image 20260901235225.png)

rep : get-localuser

![Pasted image 20260902000131.png](/assets/img/writeups/Pasted image 20260902000131.png)

![Pasted image 20260902000109.png](/assets/img/writeups/Pasted image 20260902000109.png)

Rep : Loxley 
