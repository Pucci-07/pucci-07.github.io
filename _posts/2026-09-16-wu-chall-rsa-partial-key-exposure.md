---
layout: post
title: "wu chall rsa partial key exposure"
date: 2026-09-16 12:00:00 +0000
categories: [writeup]
tags: [htb]
---

## Write-Up : RSA Partial Key Exposure

### Contexte

```
n = 7012...  (1023 bits)
e = 65537
c = 2424...
p_high = 6797...  (352 bits de poids fort de p)
unknown_bits = 160
```

### Théorie

`p` est un nombre premier 512 bits tel que :

```
p = p_high × 2^160 + x
```

où `x < 2^160` est inconnu. C'est une attaque **Coppersmith / Howgrave-Graham**.

### Méthodologie

#### Étape 1 : Comprendre la structure

```
p (512 bits) = [ p_high (352 bits) | x (160 bits) ]
```

On connaît 352/512 = **68%** des bits de p → suffisant pour Coppersmith (seuil théorique ≈ 50%).

#### Étape 2 : Construire le polynôme

python

```python
f(x) = p_high × 2^160 + x
# f(x) ≡ 0 (mod p)  ← p divise n
```

On cherche la **petite racine** `x < 2^160` de ce polynôme modulo `n`.

#### Étape 3 : Algorithme de Coppersmith (SageMath)

python

```python
R.<x> = PolynomialRing(Zmod(n))
f = p_high * 2^160 + x
roots = f.small_roots(X=2^160, beta=0.5, epsilon=1/30)
```

`small_roots()` utilise la **réduction LLL** en interne (algorithme de Lenstra-Lenstra-Lovász).

#### Étape 4 : Déchiffrement RSA

python

```python
p = p_high * 2^160 + int(roots[0])
q = n // p
phi = (p-1) * (q-1)
d = inverse_mod(e, phi)
m = power_mod(c, d, n)
flag = bytes.fromhex(hex(m)[2:]).decode()
```

### Outils requis

- **SageMath** (via [sagecell.sagemath.org](https://sagecell.sagemath.org) sans installation)

le code 

```python
n = 70123939729256976726892333466782686483538502484841572984981912683927648464037233484697479461487335341132099420399202199446139242988836623322577345565920259046209435333380033220503473999065421691589744043142768075519015084494711903260235773594981282725005340809034648450053769913777186870191043166015820321207
e = 65537
c = 24242008366638213567409639067027833420148458603935358078703791946273363299938632601124592434552812825683534056504592915294984477437808347749117416114680380074970913972360099470879128170450239122727439822173201322526911617029014599229420462403379627640757779800676127387938895521262566388303206610715819993489
p_high = 6797757016572513539656989819125610900491992170576705900813344137222535920014559707517809589623367147517827
unknown_bits = 160

X = 2^unknown_bits
p0 = p_high * X

R.<x> = PolynomialRing(Zmod(n))
f = p0 + x
roots = f.small_roots(X=X, beta=0.5, epsilon=1/30)
print("Racines:", roots)

for r in roots:
    p = p0 + int(r)
    if n % p == 0:
        q = n // p
        phi = (p-1)*(q-1)
        d = inverse_mod(e, phi)
        m = power_mod(c, d, n)
        print("FLAG:", bytes.fromhex(hex(m)[2:]).decode())

```


![Pasted image 20260628172653.png](/assets/img/writeups/Pasted image 20260628172653.png)
