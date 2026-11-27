---
layout: post
title: "HTB Knife Write-up"
date: 2026-11-27 02:29:00
description: "A walkthrough of the Knife machine, covering web reconnaissance, an old PHP development build, and overly broad sudo permissions."
tags: [htb, writeup, linux, php, privesc]
categories: [Write-ups]
writeup_id: htb-knife
writeup_platform: Hack The Box
writeup_title: Knife
writeup_language: en
writeup_difficulty: Easy
writeup_image: assets/img/knife-writeups/00-htb-machine-card.png
giscus_comments: true
related_posts: false
---

**Machine**: Knife — Easy, Linux  
**Author**: DoOm / ppporrkkky  
**HTB profile**: [DoOm](https://profile.hackthebox.com/profile/019c56c9-a8f8-721d-ad7b-fd7b3dd2f9de)  
**Machine**: [Knife on Hack The Box](https://app.hackthebox.com/machines/Knife)

> This write-up covers a retired HTB machine in an authorized lab environment. Exploitation details and commands that would obtain a shell or root access are intentionally not reproduced.

## Reconnaissance

Knife is an Easy-rated Linux machine. The goal of this first phase is to inventory exposed services before choosing a lead.

{% include figure.liquid path="assets/img/knife-writeups/00-htb-machine.png" class="img-fluid rounded z-depth-1" %}

Service discovery reveals two open ports:

- **22/tcp** — OpenSSH 8.2p1 on Ubuntu;
- **80/tcp** — Apache 2.4.41 on Ubuntu.

The web service is the primary lead: it is reachable without authentication and exposes both page content and HTTP metadata. SSH is available, but no credentials are known yet.

{% include figure.liquid path="assets/img/knife-writeups/01-nmap.png" class="img-fluid rounded z-depth-1" %}

## Inspecting the website

The home page displays a demo site for a medical provider, titled **Emergent Medical Idea**. The visible links and page content do not immediately reveal access to another section or account.

{% include figure.liquid path="assets/img/knife-writeups/02-webpage.png" class="img-fluid rounded z-depth-1" %}

Reviewing the raw HTML does not reveal a useful comment, secret, or hidden feature. The next step is to examine the server response as well, including HTTP headers that may disclose the technology in use.

## Reviewing the reconnaissance results

The server identifies itself as running PHP development version **8.1.0-dev**. The `dev` suffix matters: this is a development build, not a stable release intended for an exposed server. Detection tools also report the historical `php-zerodium-backdoor-rce` signature, associated with a backdoor in this development version.

The scanner output contains other alerts that should be kept separate from the main lead:

- `CVE-2026-109618` appears with an end-of-life branch label. The supplied evidence does not confirm this as an exploitable vulnerability or connect it to initial access, so it is not used in this path.
- `CVE-2023-48795` concerns SSH. This alert is not needed to progress on Knife and was not investigated further here.

A scanner provides hypotheses, not proof by itself. To avoid following a false lead, focus on the verifiable fact that matches the observed service: the server advertises a PHP development build with a known backdoor history.

{% include figure.liquid path="assets/img/knife-writeups/03-nuclei-results.png" class="img-fluid rounded z-depth-1" %}

## Understanding the PHP lead

The backdoor was introduced in an old PHP development version and later discovered and removed. When a vulnerable installation is actually present, it can turn a specially crafted HTTP request into code execution on the server.

The proof of concept mentioned in the original notes uses this behavior to obtain a reverse shell. Before running any proof of concept, inspect its source and verify its effects: which target it contacts, which commands it runs, whether it writes files, and whether it attempts to establish persistence. The code and payload used to obtain the shell are not included in this published version.

## Initial access

In the HTB lab, the reported version matches the machine's intended path. Exploiting this weakness provides an initial foothold as the unprivileged `james` account. This moves the assessment from remote observation of the web service to a local session on the host.

The screenshot documents the received shell. The reverse-shell setup commands are intentionally omitted.

{% include figure.liquid path="assets/img/knife-writeups/04-user-shell.png" class="img-fluid rounded z-depth-1" %}

The first shell works, but it does not provide all the features of a fully interactive terminal: terminal control is limited, shortcuts may not behave properly, and the display can be awkward. It was stabilized in the lab to make local enumeration more reliable.

The original notes also mention a `.ssh` directory containing a private key. That key is not needed for the path described here. A private key found on a machine must be treated as a secret: do not publish it or add a key to maintain persistent access.

## Privilege escalation

After obtaining user access, the next step is to review the administrative permissions granted to `james`. The sudo configuration reveals a key rule: this user can run `/usr/bin/knife` as root without entering a password.

{% include figure.liquid path="assets/img/knife-writeups/07-sudo-permissions.png" class="img-fluid rounded z-depth-1" %}

The next step is to identify what that path actually points to. `/usr/bin/knife` is a symbolic link to the Chef Workstation executable installed under `/opt`. It is not an unknown custom script, but Chef's Knife utility.

{% include figure.liquid path="assets/img/knife-writeups/08-knife-link.png" class="img-fluid rounded z-depth-1" %}

Inspection confirms that the destination is an executable owned by `root`. Knife is a Ruby tool and includes a feature for executing Ruby code. The combination of this feature and the passwordless sudo rule creates the escalation path—not an isolated SUID bit or a randomly named binary.

{% include figure.liquid path="assets/img/knife-writeups/09-knife-file.png" class="img-fluid rounded z-depth-1" %}

In the lab, this configuration allows moving from `james` to a root shell. The screenshot confirms the result; the command that triggers the escalation is obscured to avoid publishing a directly reusable procedure.

{% include figure.liquid path="assets/img/knife-writeups/10-root-redacted.png" class="img-fluid rounded z-depth-1" %}

## Recommendations for administrators

- **Do not expose development builds.** Use a stable, maintained PHP release and apply security updates.
- **Do not rely only on banners.** Hiding them reduces information exposed during reconnaissance, but does not fix a vulnerability; upgrading remains essential.
- **Verify alerts.** Confirm affected versions, exploitation conditions, and each finding's relevance before treating it as a confirmed vulnerability.
- **Apply least privilege to sudo.** Allow only required actions and avoid granting privileged execution to general-purpose tools that can run code.
- **Avoid unjustified persistence.** Do not add SSH keys or access-retention mechanisms during a lab assessment.

## Conclusion

Progress on Knife relies on two separate misconfigurations: an exposed PHP development build for initial access, followed by an overly permissive sudo rule on Knife for local privilege escalation. The key lesson is not to blindly act on every scanner result, but to connect observed evidence to the services actually present and verify each hypothesis.

## References

- [Knife machine — Hack The Box](https://app.hackthebox.com/machines/Knife)
