Auteur Doom 
équipe Chibrax200 


attachement 
![[cicada.jpg]]

déja on a un mot de passe sur l'image  qui est Cicada123 

l'analyse fichier avec file donne un fichier .jpeg 
![[Pasted image 20260628160948.png]]

donc la possibilité d'utiliser setegsseek ou steghide 

on a va utilisez steghide vu qu'on a un  possible mot de passe 

![[Pasted image 20260628161238.png]] 

on  a un fichier  challengessss.zip en dézippant on un zip bomb donc on va utilsé python pour le dezip 
![[Pasted image 20260628163552.png]]

import os
import zipfile
import re

def extract_nested_zips(start_zip):
    current_zip = start_zip
    
    while True:
        if not os.path.exists(current_zip):
            print(f"[-] Fichier introuvable : {current_zip}")
            break
            
        print(f"[+] Extraction de : {current_zip}")
        
        # On ouvre le zip actuel
        with zipfile.ZipFile(current_zip, 'r') as zip_ref:
            # On extrait tout dans le dossier courant
            zip_ref.extractall(".")
            namelist = zip_ref.namelist()
        
        # On cherche s'il y a un autre fichier zip (ou similaire) dans ce qui vient d'être extrait
        next_zip = None
        for file in namelist:
            # S'adapte si l'extension change légèrement ou si c'est du .zip
            if file.endswith('.zip') or re.search(r'\.(zip|wip|rar|tar)$', file, re.IGNORECASE):
                next_zip = file
                break
        
        # Optionnel : Tu peux supprimer l'ancien zip pour ne pas encombrer ton dossier
        # os.remove(current_zip)
        
        if next_zip:
            current_zip = next_zip
        else:
            print("[✓] Terminé ! Plus aucun fichier compressé trouvé.")
            print(f"Derniers fichiers extraits : {namelist}")
            break

premier_fichier = "archive489.zip" 
extract_nested_zips(premier_fichier)

![[Pasted image 20260628163741.png]]

une fois extrait on aura  un tar-bomb  dans la même logique 

import os
import zipfile
import tarfile
import re

def extract_nested_zips(start_zip):
    current_file = start_zip
    
    while True:
        if not os.path.exists(current_file):
            print(f"[-] Fichier introuvable : {current_file}")
            break
            
        print(f"[+] Extraction de : {current_file}")
        namelist = []
        
        try:
            # Cas 1 : C'est un fichier ZIP
            if zipfile.is_zipfile(current_file):
                with zipfile.ZipFile(current_file, 'r') as zip_ref:
                    zip_ref.extractall(".")
                    namelist = zip_ref.namelist()
                    
            # Cas 2 : C'est un fichier TAR (ou tar.gz, tar.bz2, etc.)
            elif tarfile.is_tarfile(current_file):
                with tarfile.open(current_file, 'r:*') as tar_ref:
                    tar_ref.extractall(".")
                    namelist = tar_ref.getnames()
            
            else:
                print(f"[!] Format inconnu pour le fichier : {current_file}")
                # Si ce n'est ni un zip ni un tar, c'est peut-être le flag final !
                break
                
        except Exception as e:
            print(f"[-] Erreur lors de l'extraction de {current_file} : {e}")
            break
        
        # Recherche du prochain fichier compressé dans ce qui vient d'être extrait
        next_file = None
        for file in namelist:
            # On cherche des extensions connues
            if re.search(r'\.(zip|wip|tar|gz|bz2|xz)$', file, re.IGNORECASE):
                next_file = file
                break
        
        # Optionnel : décommente la ligne dessous si tu veux supprimer les archives au fur et à mesure
        # os.remove(current_file)
        
        if next_file:
            current_file = next_file
        else:
            print("[✓] Terminé ! Plus aucun fichier compressé détecté.")
            print(f"Derniers fichiers extraits : {namelist}")
            break

# Relance à partir de là où ça a planté (ou depuis le début)
premier_fichier = "archive499.tar" 
extract_nested_zips(premier_fichier)

![[Pasted image 20260628163940.png]]

et une fois terminer on na le flag extrait qui est   le flag 

![[Pasted image 20260628164032.png]]

