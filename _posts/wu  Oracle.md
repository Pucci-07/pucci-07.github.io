## Challenge 2 — Oracle Fa / Ifá (Crypto)

### Description

Un fichier `oracle.txt` contenant une série de signes inspirés de la divination Ifá/Fa, pratiquée en Afrique de l'Ouest (notamment au Togo et au Bénin). Chaque signe est composé de **2 colonnes × 4 lignes**. Chaque ligne est soit simple (`I`) soit double (`II`).

L'indice du chercheur : _"Lis les marques comme des bits."_

### Décodage

**Convention :**

- `I` (ligne simple) = bit `0`
- `II` (ligne double) = bit `1`

**Lecture :** ligne par ligne, colonne gauche puis colonne droite → 8 bits par signe → 1 octet ASCII.

**Exemple — Signe 1 :**

```
I  II   →  0 1
I  I    →  0 0
II I    →  1 0
I  I    →  0 0
```

Bits : `01001000` = `0x48` = **`H`**

**Script de décodage :**

python

```python
signs_raw = """..."""  # contenu de oracle.txt

signs = [s.strip() for s in signs_raw.strip().split('\n\n')]
result = []
for sign in signs:
    lines = sign.strip().split('\n')
    bits = ''
    for line in lines:
        parts = line.split()
        bits += '0' if parts[0] == 'I' else '1'
        bits += '0' if parts[1] == 'I' else '1'
    val = int(bits, 2)
    result.append(chr(val))

print(''.join(result))
```

### Flag

```
HackDCTF{f4_0r4cl3_r34d5_b1n4ry}
```
