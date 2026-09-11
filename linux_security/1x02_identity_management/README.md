# 🔐 Linux Identity & Authentication

## 📖 Description

Ce projet permet de comprendre la **gestion des utilisateurs, des mots de passe, des privilèges et de l'authentification sous Linux**.

L'objectif est de comprendre comment Linux identifie les utilisateurs, comment les privilèges sont attribués et comment renforcer l'authentification, notamment avec **SSH et PAM**.

## 🎯 Learning Objectives

### 👤 Identity Fundamentals

#### `/etc/passwd`

Comprendre la structure du fichier `/etc/passwd` et le rôle de ses différents champs.

Exemple :

    user:x:1000:1000:User:/home/user:/bin/bash

Les informations principales sont :

    Username
    Password placeholder
    UID
    GID
    Description
    Home directory
    Login shell

Le **UID 0** est particulier : il correspond à `root` et possède les privilèges administrateur.

---

### 🔑 `/etc/shadow`

Le fichier `/etc/shadow` contient notamment les **hashes des mots de passe**.

Exemples de préfixes :

    $1$ → MD5
    $5$ → SHA-256
    $6$ → SHA-512

Exemple :

    $6$salt$hash...

Le fichier `/etc/shadow` est fortement protégé car son accès permettrait de récupérer les hashes de mots de passe et potentiellement de tenter de les casser hors ligne.

---

### 👥 Service vs Human Accounts

Linux possède différents types de comptes :

- **Human accounts** → comptes utilisés par des personnes
- **Service accounts** → comptes utilisés par des services et programmes

Les comptes de service ne devraient généralement pas avoir de shell interactif.

Exemple :

    /usr/sbin/nologin

Les UID système sont généralement situés dans les plages réservées aux comptes système. Il faut cependant éviter de considérer une règle unique comme « tous les UID < 1000 ne doivent jamais avoir de shell » : les conventions dépendent de la distribution.

---

# 🛡️ Privilege Management

### ⚠️ Dangerous Groups

Certains groupes peuvent donner des capacités très puissantes.

Exemples :

    docker
    disk
    shadow

Une mauvaise configuration de ces groupes peut permettre à un utilisateur de contourner les restrictions normales et potentiellement d'obtenir des privilèges équivalents à `root`.

Il est donc important de vérifier les appartenances aux groupes :

    groups user

ou :

    id user

---

### 📋 Sudoers

`sudo` permet d'autoriser un utilisateur à exécuter certaines commandes avec des privilèges élevés.

La configuration se trouve notamment dans :

    /etc/sudoers
    /etc/sudoers.d/

L'objectif est d'accorder **uniquement les permissions nécessaires**.

Exemple de principe :

    user → peut exécuter une commande précise avec sudo

plutôt que :

    user → peut tout exécuter avec sudo

---

### ⚠️ NOPASSWD

Une règle comme :

    NOPASSWD

permet d'utiliser `sudo` sans demander le mot de passe.

Cela peut être pratique pour l'automatisation, mais devient dangereux si la commande autorisée permet d'obtenir un shell ou d'effectuer des actions avec les privilèges de `root`.

**La commodité ne doit pas remplacer le principe du moindre privilège.**

---

# 🔒 Authentication Hardening

### 🌐 SSH Configuration

SSH permet de se connecter à distance à une machine Linux.

Une configuration plus sécurisée peut notamment :

- désactiver l'authentification par mot de passe ;
- utiliser des clés SSH ;
- limiter les utilisateurs autorisés ;
- empêcher les connexions `root` directes.

Exemple :

    PasswordAuthentication no

L'authentification par clé permet d'utiliser une **paire de clés cryptographiques** plutôt qu'un mot de passe.

---

### 🔑 PAM

PAM signifie :

**Pluggable Authentication Modules**

PAM permet de contrôler et personnaliser différents mécanismes d'authentification Linux.

Il peut notamment être utilisé pour :

- imposer une complexité minimale des mots de passe ;
- limiter les tentatives de connexion ;
- verrouiller temporairement un compte ;
- appliquer des politiques d'authentification.

Les fichiers de configuration PAM se trouvent généralement dans :

    /etc/pam.d/

---

### 🚫 Passwordless Onboarding

Un compte peut être créé sans mot de passe utilisable.

Cela peut être pertinent pour certains comptes techniques ou pour une authentification exclusivement basée sur une clé SSH.

Le principe est :

    Compte
      ↓
    Pas de mot de passe utilisable
      ↓
    Authentification par clé SSH

Cela réduit le risque lié au vol ou au brute-force d'un mot de passe.

---

# 🧰 Commands to Know

    # Utilisateurs
    id
    who
    getent passwd
    getent group

    # Fichiers d'identité
    cat /etc/passwd
    cat /etc/shadow

    # Groupes
    groups
    id

    # Sudo
    sudo -l
    visudo

    # SSH
    ssh
    ssh-keygen

    # PAM
    ls /etc/pam.d/

---

# 💡 À retenir

    /etc/passwd → informations des comptes
    /etc/shadow → hashes et informations des mots de passe
    UID 0       → root
    groups      → droits supplémentaires
    sudo        → exécution avec privilèges élevés
    SSH         → administration distante
    PAM         → gestion de l'authentification

### Principes de sécurité

**Least Privilege**  
→ Donner uniquement les privilèges nécessaires.

**Key-Based Authentication**  
→ Préférer les clés SSH aux mots de passe lorsque c'est adapté.

**No Unnecessary Login Shell**  
→ Les comptes de service n'ont généralement pas besoin d'un shell interactif.

**Audit Before You Fix**  
→ Vérifier les utilisateurs, groupes et permissions avant de modifier la configuration.

## 🎯 Objectif final

Être capable d'analyser un système Linux et de comprendre :

- comment les utilisateurs sont identifiés ;
- comment les mots de passe sont stockés ;
- pourquoi `root` est particulier ;
- quels groupes peuvent représenter un risque ;
- comment fonctionne `sudo` ;
- pourquoi `NOPASSWD` peut être dangereux ;
- comment sécuriser SSH ;
- comment PAM contrôle l'authentification ;
- comment utiliser une authentification sans mot de passe.

**L'objectif est de gérer les identités et les privilèges Linux avec une approche orientée sécurité.**