#!/usr/bin/env bash
#
# Scaffold a bilingual write-up (EN + FR) for the /writeups/ page.
#
# Creates:
#   _posts/<date>-<id>-writeup-en.md
#   _posts/<date>-<id>-writeup-fr.md
#   assets/img/<id>-writeups/   (with a README reminding you of the expected
#                                 cover image names)
#
# The two posts share the same `writeup_id`, so the /writeups/ page groups
# them into a single card with EN/FR buttons (see _pages/writeups.md).
#
# Usage:
#   scripts/new-writeup.sh --id htb-baby --platform "Hack The Box" \
#       --title Baby --difficulty Easy [--os Windows] [--tags htb,ad,windows] \
#       [--date 2026-11-27] [--time 10:00:00] [--force]
#
# Required:
#   --id          slug used everywhere (writeup_id, filenames, image folder)
#   --platform    "Hack The Box", "TryHackMe", "Hackviser", "Practice Labs", ...
#   --title       display name of the machine/room (e.g. "Baby")
#
# Optional:
#   --difficulty  Easy | Medium | Hard | Insane (shown on the card instead of
#                 the platform name when set)
#   --os          used only to seed the tags list (linux/windows/web/...)
#   --tags        comma-separated tags, overrides the --os default
#   --date        YYYY-MM-DD, defaults to today
#   --time        HH:MM:SS, defaults to the current time
#   --force       overwrite files that already exist
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

id=""
platform=""
title=""
difficulty=""
os=""
tags=""
date_str="$(date +%Y-%m-%d)"
time_str="$(date +%H:%M:%S)"
force=0

usage() {
  sed -n '2,33p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id) id="$2"; shift 2 ;;
    --platform) platform="$2"; shift 2 ;;
    --title) title="$2"; shift 2 ;;
    --difficulty) difficulty="$2"; shift 2 ;;
    --os) os="$2"; shift 2 ;;
    --tags) tags="$2"; shift 2 ;;
    --date) date_str="$2"; shift 2 ;;
    --time) time_str="$2"; shift 2 ;;
    --force) force=1; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1" >&2; usage ;;
  esac
done

if [[ -z "$id" || -z "$platform" || -z "$title" ]]; then
  echo "Error: --id, --platform and --title are required." >&2
  usage
fi

if ! [[ "$id" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Error: --id must be lowercase, kebab-case (e.g. htb-baby). Got: $id" >&2
  exit 1
fi

if [[ -z "$tags" ]]; then
  case "${os,,}" in
    windows) tags="[htb, writeup, windows, active-directory]" ;;
    linux)   tags="[htb, writeup, linux]" ;;
    web)     tags="[writeup, web]" ;;
    *)       tags="[writeup]" ;;
  esac
else
  tags="[$tags]"
fi

img_dir="assets/img/${id}-writeups"
post_en="_posts/${date_str}-${id}-writeup-en.md"
post_fr="_posts/${date_str}-${id}-writeup-fr.md"

for f in "$post_en" "$post_fr"; do
  if [[ -e "$f" && $force -ne 1 ]]; then
    echo "Error: $f already exists. Use --force to overwrite." >&2
    exit 1
  fi
done

mkdir -p "$img_dir"
if [[ ! -e "$img_dir/README.md" ]]; then
  cat > "$img_dir/README.md" <<EOF
Expected images for the "${title}" write-up card and post:

- \`00-machine-card.png\` — used as \`writeup_image\` on the /writeups/ card
  (shown at a ~16:9 ratio; a themed splash or the target's landing page
  works well). Keep it free of flags, password hashes or your own HTB/THM
  session cookie.
- any other screenshot, named so it sorts in the order it appears in the
  post (01-recon.png, 02-foothold.png, ...). Reference them from the post
  with:
  {% include figure.liquid path="${img_dir}/01-recon.png" class="img-fluid rounded z-depth-1" %}

Before publishing a screenshot, double-check it does not reveal the flag,
a cracked password, a private key, or your HTB/THM API token.
EOF
fi

difficulty_line=""
if [[ -n "$difficulty" ]]; then
  difficulty_line="writeup_difficulty: ${difficulty}
"
fi

read -r -d '' body_en <<'EOF' || true
**Machine**: TITLE — DIFFICULTY_OS
**Platform**: PLATFORM

## Reconnaissance

<!-- nmap / initial scan. Redact the real target IP if you want, or keep it
     — HTB/THM target IPs are not secret on their own. -->

## Enumeration

<!-- what you found poking at each open service, and what pointed you to
     the real way in. -->

## Foothold

<!-- the first shell / first valid credentials. -->

## Privilege escalation

<!-- how you went from the foothold user to root/Administrator/SYSTEM. -->

## Takeaways

<!-- one or two sentences: the root cause, and the one-line fix a defender
     would apply. -->

<!--
Checklist before publishing:
- [ ] no real flag (user.txt / root.txt) shown in full
- [ ] no real password or NTLM/NT hash shown in full (truncate or replace
      with a placeholder like `<redacted>`)
- [ ] no HTB/THM profile cookie, API key or session token in a screenshot
- [ ] code blocks use $target_ip / $target_user placeholders, not your
      literal values, where that matches how you write elsewhere
-->
EOF

read -r -d '' body_fr <<'EOF' || true
**Machine** : TITLE — DIFFICULTY_OS
**Plateforme** : PLATFORM

## Reconnaissance

<!-- scan nmap / reconnaissance initiale. -->

## Énumération

<!-- ce que vous avez trouvé en creusant chaque service ouvert, et ce qui
     vous a mis sur la piste. -->

## Point d'entrée

<!-- le premier shell / les premiers identifiants valides. -->

## Élévation de privilèges

<!-- comment vous êtes passé de l'utilisateur initial à root/Administrator/
     SYSTEM. -->

## À retenir

<!-- une ou deux phrases : la cause racine, et le correctif qu'un défenseur
     appliquerait. -->

<!--
À vérifier avant publication :
- [ ] pas de vrai flag (user.txt / root.txt) affiché en entier
- [ ] pas de vrai mot de passe ou hash NTLM/NT affiché en entier (tronquer
      ou remplacer par un espace réservé, ex. `<redacted>`)
- [ ] pas de cookie de profil HTB/THM, de clé API ou de jeton de session
      dans une capture
- [ ] les blocs de code utilisent $target_ip / $target_user, pas vos
      valeurs réelles, si c'est votre convention habituelle
-->
EOF

os_suffix=""
[[ -n "$os" ]] && os_suffix=", ${os}"
body_en="${body_en//TITLE/$title}"
body_en="${body_en//DIFFICULTY_OS/${difficulty:-?}${os_suffix}}"
body_en="${body_en//PLATFORM/$platform}"
body_fr="${body_fr//TITLE/$title}"
body_fr="${body_fr//DIFFICULTY_OS/${difficulty:-?}${os_suffix}}"
body_fr="${body_fr//PLATFORM/$platform}"

cat > "$post_en" <<EOF
---
layout: post
title: "${title} — Write-up (EN)"
date: ${date_str} ${time_str}
description: "One or two sentences: what this box/room is about and the key technique."
tags: ${tags}
categories: [Write-ups]
writeup_id: ${id}
writeup_platform: ${platform}
writeup_title: ${title}
writeup_language: en
${difficulty_line}writeup_image: ${img_dir}/00-machine-card.png
giscus_comments: true
related_posts: false
---

${body_en}
EOF

cat > "$post_fr" <<EOF
---
layout: post
title: "${title} — Write-up (FR)"
date: ${date_str} ${time_str}
description: "Une ou deux phrases : le sujet de la box/room et la technique clé."
tags: ${tags}
categories: [Write-ups]
writeup_id: ${id}
writeup_platform: ${platform}
writeup_title: ${title}
writeup_language: fr
${difficulty_line}writeup_image: ${img_dir}/00-machine-card.png
giscus_comments: true
related_posts: false
---

${body_fr}
EOF

echo "Created:"
echo "  $post_en"
echo "  $post_fr"
echo "  $img_dir/ (with README.md)"
echo
echo "Next steps:"
echo "  1. Drop your cover image at $img_dir/00-machine-card.png"
echo "  2. Fill in the EN and FR bodies, then delete the checklist comments"
echo "  3. bundle exec jekyll serve  # preview at /writeups/ before pushing"
