# 🐧 Linux Permissions & Security

## 📖 Description

Ce projet permet de comprendre les bases de la **gestion des fichiers, des permissions et de la sécurité sous Linux**.

L'objectif est de savoir administrer un système Linux, rechercher des fichiers, gérer les accès et appliquer les principaux principes de sécurité.

## 🎯 Learning Objectives

### 📁 Linux Filesystem Hierarchy

Comprendre le rôle des principaux répertoires Linux :

- `/etc` → fichiers de configuration
- `/var` → logs, cache et données variables
- `/home` → fichiers personnels des utilisateurs
- `/usr` → programmes et bibliothèques
- `/tmp` → fichiers temporaires

Comprendre pourquoi la protection de certains répertoires et fichiers est importante pour la sécurité.

---

### 🔐 Linux Permissions

Comprendre le modèle de permissions Linux :

    User | Group | Others

Et les permissions :

    r = read
    w = write
    x = execute

Savoir lire une permission comme :

    -rwxr-xr--

Et comprendre ce que chaque utilisateur peut faire.

### 🔢 Octal & Symbolic Notation

Savoir convertir entre les deux principales notations :

    chmod 755 file

et :

    chmod u=rwx,go=rx file

Valeurs à connaître :

    r = 4
    w = 2
    x = 1

Exemple :

    755 = rwxr-xr-x

---

### ⭐ Special Bits

Comprendre les trois bits spéciaux :

- **SUID** → permet à un programme de s'exécuter avec les droits de son propriétaire.
- **SGID** → permet notamment l'utilisation des droits du groupe et l'héritage du groupe sur les répertoires.
- **Sticky Bit** → protège les fichiers dans les répertoires partagés comme `/tmp`.

Comprendre pourquoi un **SUID mal configuré**, notamment sur un programme vulnérable appartenant à `root`, peut représenter un risque important.

---

### 🔎 Searching & Pattern Matching

Savoir utiliser `find` pour rechercher précisément des fichiers selon :

- le nom ;
- le type ;
- la taille ;
- la date ;
- les permissions.

Exemple :

    find /var -type f -size +10M

Savoir utiliser `grep` pour rechercher des informations dans des fichiers :

    grep "error" /var/log/syslog

Et utiliser des **expressions régulières** pour rechercher des motifs plus complexes.

---

### 🔑 Access Control Lists (ACL)

Comprendre les **ACL** et leur utilité lorsqu'on a besoin de permissions plus précises que le modèle classique :

    User / Group / Others

Commandes principales :

    getfacl file
    setfacl -m u:alice:r file

Les ACL permettent notamment d'accorder des permissions spécifiques à un utilisateur ou à un groupe.

---

### 🌐 Remote Administration

Savoir administrer une machine à distance avec **SSH** :

    ssh user@server

Et transférer des fichiers avec **SCP** :

    scp file.txt user@server:/home/user/

L'objectif est de pouvoir travailler sur un serveur sans accès physique ou interface graphique.

---

## 🛡️ Security Mindset

### Audit Before You Fix

Toujours **analyser avant de modifier**.

Avant de changer une permission, il faut comprendre :

- qui utilise le fichier ;
- qui doit y accéder ;
- quelles permissions sont nécessaires ;
- quelles conséquences peut avoir la modification.

---

### Least Privilege

Le principe du **Least Privilege** consiste à donner uniquement les permissions nécessaires.

    Moins de privilèges
          ↓
    Moins de risques
          ↓
    Impact limité en cas de compromission

---

### Defense in Depth

La sécurité ne repose pas sur une seule protection.

Exemple :

    Firewall
       ↓
    SSH sécurisé
       ↓
    Authentification
       ↓
    Permissions
       ↓
    ACL
       ↓
    Logs / Monitoring

Si une protection est contournée, les autres peuvent encore limiter l'impact.

---

## 🧰 Commands to Know

    # Permissions
    ls -l
    chmod
    chown
    chgrp
    stat

    # Recherche
    find
    grep

    # ACL
    getfacl
    setfacl

    # Administration distante
    ssh
    scp

    # Recherche SUID / SGID
    find / -perm -4000 -type f 2>/dev/null
    find / -perm -2000 -type f 2>/dev/null

---

## 💡 À retenir

    rwx          → Permissions
    chmod        → Modifier les permissions
    SUID         → Droits du propriétaire
    SGID         → Droits / héritage du groupe
    Sticky Bit   → Protection des fichiers partagés
    find         → Rechercher des fichiers
    grep         → Rechercher du contenu
    ACL          → Permissions avancées
    SSH          → Connexion distante
    SCP          → Transfert de fichiers

**Objectif : comprendre les permissions Linux, savoir administrer un système à distance et adopter une approche de sécurité basée sur le moindre privilège et l'audit.**