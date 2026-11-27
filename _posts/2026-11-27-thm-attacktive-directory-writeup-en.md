---
layout: post
title: "TryHackMe Attacktive Directory Write-up"
date: 2026-11-27 02:53:00
description: "An Attacktive Directory walkthrough: AD reconnaissance, a Kerberos account without pre-authentication, an SMB share, and replication privileges."
tags: [tryhackme, writeup, windows, active-directory, kerberos]
categories: [Write-ups]
writeup_id: thm-attacktive-directory
writeup_platform: TryHackMe
writeup_title: Attacktive Directory
writeup_language: en
writeup_image: assets/img/attacktive-directory/00-thm-room-card.png
giscus_comments: true
related_posts: false
---

**Room**: Attacktive Directory — TryHackMe<br />
**Author**: [0xD4C](https://tryhackme.com/p/0xD4C)<br />
**Room**: [Attacktive Directory on TryHackMe](https://tryhackme.com/room/attacktivedirectory)

> This write-up covers a TryHackMe room in an authorized lab environment. Passwords, hashes, and commands that obtain or reuse access are intentionally omitted.

## Active Directory reconnaissance

The first phase identifies services exposed by the domain controller. The supplied scan shows DNS, Kerberos, LDAP, SMB, and RDP. LDAP on ports 389 and Global Catalog on 3268 provide directory services; Kerberos is available on its standard port.

{% include figure.liquid path="assets/img/attacktive-directory/00-thm-room.png" class="img-fluid rounded z-depth-1" %}

Server responses provide the following domain information:

- DNS domain: `spookysec.local`;
- NetBIOS name: `THM-AD`;
- computer name: `ATTACKTIVEDIREC`;
- operating system: Windows Server.

{% include figure.liquid path="assets/img/attacktive-directory/01-ad-scan.png" class="img-fluid rounded z-depth-1" %}

SMB is also exposed on ports 139 and 445. Although the initial enumeration does not immediately reveal an interesting file, the service remains worth revisiting after credentials are obtained.

## Kerberos accounts and pre-authentication

Account enumeration identifies several valid domain names, including `svc-admin`, `backup`, `administrator`, and `paradox`. The output indicates that `svc-admin` does not require Kerberos pre-authentication.

When an account is configured this way, a Kerberos request can return an encrypted data block derived from the account password. In an authorized audit, this response can be checked offline: a weak password may be guessed without sending repeated login attempts to the domain controller.

An initial attempt to check the hash returned by the enumeration tool does not succeed. The notes identify a mismatch between the hash format and the verification mode. Obtaining output in the expected format allows the offline audit to recover a weak password for `svc-admin`. The hash and password are not published.

This step demonstrates why account discovery, hash extraction, and hash formatting must be distinguished: an incompatible format can cause a verification attempt to fail without disproving the lead.

## SMB access and the backup share

The `svc-admin` credentials allow SMB share enumeration. The `backup` share is especially relevant and becomes accessible with a second service account, `backup`.

The share contains a file named `backup_credentials.txt`. Its contents are Base64-encoded. Base64 is an encoding, not encryption: anyone who can read the file can recover its original contents without a cryptographic key. The decoded credentials are not reproduced here.

## Backup account and directory privileges

The `backup` account can establish an RDP session to the domain controller. Reviewing this account reveals sensitive Active Directory replication privileges. Such rights should be reserved for roles that genuinely need to replicate directory data; assigning them to a backup account without a clear requirement can expose domain authentication material.

The original notes use an Impacket tool to retrieve domain hash data. The commands and recovered values are omitted. The key issue is the permission impact: a backup account should not automatically be able to read every user's directory secrets.

## Validating the impact

Authentication data recovered in the lab demonstrates that the backup account's privileges exceed its apparent need. The original notes then describe validating administrator access using an NTLM hash. The hash, reuse command, and account data are not reproduced.

This demonstrates the risk of directory secrets: an incorrectly assigned replication permission can turn a compromised service account into a broader domain compromise.

## Recommendations

- Require Kerberos pre-authentication for every account without a documented need to disable it.
- Use long, unique passwords and managed service accounts where practical.
- Do not place credentials in SMB shares; Base64 does not protect a secret.
- Restrict Active Directory replication rights to essential accounts and audit assignments regularly.
- Limit service accounts to required resources; avoid granting RDP or administrative roles without justification.
- Respond immediately to exposed passwords or hashes by rotating credentials, revoking sessions, and reviewing access.

## Conclusion

Attacktive Directory demonstrates how several weaknesses can compound: pre-authentication disabled for an account, a weak password, encoded credentials in an SMB share, and replication privileges assigned to a backup account. Defenses depend on strong credentials, protected secrets, and least-privilege Active Directory permissions.

## References

- [Attacktive Directory room — TryHackMe](https://tryhackme.com/room/attacktivedirectory)
