[[Hackviser Academy]]

## Introduction

Brute Force attacks are a common and straightforward yet effective type of attack encountered in cybersecurity. It involves systematically trying many different combinations to find the correct credentials or configuration settings on a target system.

![](https://storage.hackviser.com/file/hackviser-prod/trainings/sections/images/ecf68ff1-283c-4bf3-b5d8-6777b78d1a57/image-9951ab48b.webp)

### Common Types of Brute Force Attacks

1. Dictionary Attack

**Definition:** In this type of attack, attackers use commonly used password lists (dictionaries) systematically to find the correct password. For example, common passwords like "123456", "password", or "admin" are tried from the list.

**Mechanism:** The attacker uses the list or database sequentially to guess the target's password. For example, a password attack for the username "admin" can be attempted via a URL like this.

```auto
https://example.com/login?username=admin&password=123456
```

**Defense Methods:** Implement strong password policies, multi-factor authentication (MFA), and limit password attempts.

2. Exhaustive Search

**Definition:** The attacker tries to find the correct username and password by using all possible character combinations. This method is a time-consuming type of attack.

**Mechanism:** The attacker generates and attempts different combinations of each character set. For example, starting with "a" and trying all letters, numbers, and special characters through "z".

**Defense Methods:** Increase password length and complexity, implement session limits for failed attempts, and use CAPTCHA.

3. Credential Stuffing

**Definition:** Trying to log into different websites using credentials leaked from previous data breaches.

**Mechanism:** The attacker uses username-password combinations obtained from data breaches on other websites.

For example, trying to log in to different sites using previously leaked "[john@example.com](mailto:john@example.com)" email address and "password123" password.

**Defense Methods:** Use multi-factor authentication (MFA), alert systems to prevent password reuse, and notifications for successful logins.

### Effects of Brute Force Attacks

- **Account Takeover:** When the attacker finds the correct credentials, they can take full control of the victim's account and access personal or sensitive information.
- **Service Disruption:** Continuous attempts can affect the application's performance or make the entire system inoperative.
- **Unauthorized Access:** The attacker can perform unauthorized actions or access internal company data with the information obtained through brute force.

### Vulnerable Areas to Brute Force in Web Applications

- **Weak Password Policy:** Simple passwords or weak password policies leave systems vulnerable to brute force attacks.
- **Security Question and Answer:** If password reset security questions are easily guessable, this area is prone to attacks.
- **Lack of Rate Limiting:** If response times are not restricted or session attempts are not limited, attackers can make rapid and successive attempts.

### Protection Methods Against Brute Force

- **Strong Password Policies:** Implement policies that include minimum length and complexity requirements.
- **Multi-Factor Authentication (MFA):** Use SMS, email, or authentication applications to add an extra layer of security.
- **Rate Limiting:** Limit actions such as incorrect login attempts to block attackers.
- **Captcha:** Use CAPTCHA to prevent bot-based brute force attacks.
- **IP Blocking:** Temporarily block the IP address if there are numerous failed login attempts from a specific IP address.