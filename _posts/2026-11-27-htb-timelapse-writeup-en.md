---
layout: post
title: "HTB Timelapse Write-up"
date: 2026-11-27 02:53:00
description: "A detailed Timelapse walkthrough: SMB shares, WinRM certificates, exposed PowerShell history, and LAPS permissions."
tags: [htb, writeup, windows, active-directory, laps]
categories: [Write-ups]
writeup_id: htb-timelapse
writeup_platform: Hack The Box
writeup_title: Timelapse
writeup_language: en
writeup_difficulty: Easy
writeup_image: assets/img/timelapse-writeups/00-htb-machine-card.png
giscus_comments: true
related_posts: false
---

**Machine**: Timelapse — Easy, Windows<br />
**Author**: DoOm / ppporrkkky<br />
**HTB profile**: [DoOm](https://profile.hackthebox.com/profile/019c56c9-a8f8-721d-ad7b-fd7b3dd2f9de)<br />
**Machine**: [Timelapse on Hack The Box](https://app.hackthebox.com/machines/Timelapse)

> This write-up covers an HTB lab machine. Passwords, private keys, hashes, and commands that obtain or use access are intentionally omitted from the articles and published screenshots.

## Reconnaissance

Timelapse is a Windows machine exposing several Active Directory-related services. Enumeration identifies DNS, Kerberos, RPC, SMB, LDAP, the LDAP Global Catalog, and WinRM over HTTPS. The observed domain is `timelapse.htb`; the domain controller is `dc01.timelapse.htb`.

{% include figure.liquid path="assets/img/timelapse-writeups/00-htb-machine.png" class="img-fluid rounded z-depth-1" %}

The AD services make network shares and available authentication methods worth examining. Standard WinRM is not reachable on its usual port, but its HTTPS endpoint is confirmed later.

{% include figure.liquid path="assets/img/timelapse-writeups/01-ad-scan.png" class="img-fluid rounded z-depth-1" %}

## Enumerating SMB shares

Using a lab identity already available at this stage, SMB enumeration provides access to the `IPC$` and `Shares` shares. The original notes do not explain how the first credentials used here were obtained; the documented path resumes at share discovery.

The standard administrative `IPC$` share contains no useful files in this case. The `Shares` share, however, contains several items worth reviewing:

- a `winrm_backup.zip` archive;
- the `LAPS.x64.msi` installer;
- LAPS reference documents.

The LAPS guides confirm that local administrator password management is part of the environment. The WinRM archive is a separate lead: it is password-protected and contains a certificate bundle.

## Archive and client certificate

The protected archive is retrieved from the share and examined in the lab. An offline password check allows it to be opened; the password itself is not published. The archive contains a PFX file, a format that commonly bundles a certificate and its private key.

The PFX is also protected by a passphrase. After unlocking it in the lab, the certificate metadata reveals the common name **Legacyy**. This provides a lead for the identity used with WinRM. Cryptographic material and passphrases are excluded from this write-up.

## Initial access over WinRM HTTPS

Port checks show that WinRM on port 5985 is filtered, while the HTTPS endpoint on port 5986 responds. Certificate-based authentication is therefore a better fit for the exposed service than plaintext WinRM authentication.

{% include figure.liquid path="assets/img/timelapse-writeups/16-winrm-https.png" class="img-fluid rounded z-depth-1" %}

The certificate identifies the `legacyy` account, which is used to establish a WinRM session. The certificate subject screenshot is retained; it does not contain a private key or passphrase.

{% include figure.liquid path="assets/img/timelapse-writeups/17-certificate-cn.png" class="img-fluid rounded z-depth-1" %}

An older Evil-WinRM release then failed client-side because it called Ruby's `File.exists?` method, which was removed in recent Ruby versions. The original notes suggest editing the installed gem directly. That workaround is not recommended: use an Evil-WinRM release compatible with Ruby or a reproducible isolated environment instead.

The private key also requested its passphrase on some connections. The original notes describe creating a passphrase-free copy to avoid the prompt. An unencrypted private key increases exposure if the file leaks; keep the original protected and do not publish an unlocked copy.

The resulting session belongs to `legacyy`. At this point, access is limited to a user account rather than an administrator session.

## Finding local credentials

Local enumeration reveals that a PowerShell command history contains a service-account sign-in command. The credential for `svc_deploy` was therefore stored in clear text in a history file accessible to the logged-in user.

This discovery provides another authentication lead and allows a WinRM session as `svc_deploy`. The credential itself is not reproduced: command histories can contain real secrets and must be treated as sensitive data.

## LAPS and local administrator access

The `svc_deploy` session has permission to read LAPS information for the target computer. On this machine, that access allows the managed local administrator password to be retrieved, followed by a session as `Administrator`.

An important distinction: legacy Microsoft LAPS stores the password in an attribute on the computer's Active Directory object, with access controlled by permissions. Windows LAPS can support password encryption depending on configuration; do not assume every LAPS deployment automatically encrypts the stored value.

## Backup privileges and access scope

Enumeration under the local administrator account reveals the Windows `SeBackupPrivilege`.

{% include figure.liquid path="assets/img/timelapse-writeups/30-privilege-enumeration.png" class="img-fluid rounded z-depth-1" %}

This privilege is related to backup operations and can allow an authorized administrator to read protected files through Windows backup semantics. It should not be confused with Active Directory replication permissions: `SeBackupPrivilege` alone does not establish that an account has DCSync rights.

The original notes then report extracting domain authentication data with Impacket tools. They do not clearly document whether this used an offline backup copy or directory replication permissions. Those are different mechanisms; the exact method should be verified before attributing the extraction to the backup privilege alone. Commands and hashes are not published.

## Recommendations

- Restrict SMB shares and regularly review files stored on them.
- Do not store private keys, protected certificates, or plaintext passwords in archives or command histories.
- Keep client tools updated and prefer an isolated environment over manually editing a system gem.
- Protect private keys with a passphrase and limit how long they are retained.
- Limit access to LAPS attributes to the groups that genuinely need it.
- Assess local backup privileges and AD replication rights separately; do not grant them to service accounts without a clear need.

## Conclusion

Timelapse demonstrates a chain of poor practices rather than a single flaw: sensitive files exposed over SMB, a certificate enabling WinRM authentication, credentials left in PowerShell history, and overly broad LAPS read access. Each step increases available privilege; protecting secrets and narrowing permissions would have interrupted this progression.

## References

- [Timelapse machine — Hack The Box](https://app.hackthebox.com/machines/Timelapse)
