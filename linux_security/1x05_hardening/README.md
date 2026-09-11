# 🔐 System Hardening, Configuration & Compliance

## 📖 Description

Ce projet permet d'apprendre à **automatiser le durcissement d'un système Linux** de manière sûre et reproductible.

L'objectif est de ne pas simplement appliquer des commandes manuellement, mais de transformer une **politique de sécurité** en contrôles techniques vérifiables, tout en évitant de rendre le système inaccessible.

---

## 🎯 Learning Objectives

### 🧩 1. Scripting & Architecture

Un script de hardening doit être **robuste, modulaire et idempotent**.

- Utiliser des fonctions pour séparer les différentes tâches.
- Vérifier l'état du système avant de le modifier.
- Éviter les commandes dangereuses exécutées sans vérification.
- Pouvoir exécuter plusieurs fois le script sans créer de problèmes.

Exemple :

    if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
        echo "SSH already hardened"
    else
        echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    fi

### ⚙️ Configuration Management vs Ad-hoc Scripting

**Ad-hoc scripting** consiste généralement à exécuter quelques commandes pour résoudre un problème ponctuel.

**Configuration Management** consiste à définir un **état souhaité** et à vérifier que le système respecte toujours cet état.

Exemple :

    Desired state:
    PasswordAuthentication = no

Le script doit vérifier cette configuration et la corriger si nécessaire.

### 🚫 Éviter le Hardcoding

Le hardcoding consiste à mettre directement des valeurs spécifiques dans le script.

Exemple à éviter :

    USER="jules"
    IP="192.168.1.50"

Cela peut poser des problèmes lorsque le script est utilisé sur une autre machine.

Il est préférable d'utiliser :

- des fichiers de configuration ;
- des variables ;
- des arguments ;
- des valeurs détectées automatiquement.

---

## 🛡️ 2. System Hardening

### 🌐 Automatiser les changements réseau en sécurité

Modifier le réseau à distance peut provoquer une **perte de connexion**, notamment lorsqu'on modifie :

- le firewall ;
- les routes ;
- SSH ;
- les interfaces réseau ;
- les règles de filtrage.

Avant un changement important, il faut donc prévoir une méthode de récupération.

Exemple de vérification SSH :

    sshd -t

Cette commande permet de vérifier la configuration SSH avant de redémarrer le service.

Une bonne pratique est :

    Modifier → Vérifier → Appliquer → Tester

et non :

    Modifier → Redémarrer → Espérer que ça fonctionne

### 🔑 Politique de mots de passe avec PAM

**PAM (Pluggable Authentication Modules)** permet de contrôler différentes étapes de l'authentification Linux.

Les fichiers de configuration se trouvent notamment dans :

    /etc/pam.d/

On peut utiliser PAM pour appliquer des règles concernant :

- la longueur minimale ;
- la complexité ;
- l'historique des mots de passe ;
- le nombre d'échecs ;
- le verrouillage d'un compte.

### 🔐 SSH avec authentification par clé

L'authentification SSH par clé permet d'utiliser une paire :

    Private key → reste sur le client
    Public key  → installée sur le serveur

Une fois configuré, on peut désactiver l'authentification par mot de passe :

    PasswordAuthentication no

Et vérifier la configuration :

    sshd -t

Puis redémarrer/recharger SSH selon la configuration du système.

⚠️ Il faut toujours **tester une nouvelle connexion SSH avant de fermer sa session actuelle**, surtout lorsqu'on désactive les mots de passe.

---

## 📋 3. Compliance & Verification

### 📜 Transformer une politique en contrôles techniques

Une politique de sécurité décrit ce qui doit être respecté.

Exemple :

    Policy:
    "Root login via SSH must be disabled."

Cela devient un contrôle technique :

    PermitRootLogin no

Puis une vérification :

    sshd -T | grep permitrootlogin

L'objectif est donc :

    Politique
        ↓
    Contrôle technique
        ↓
    Vérification
        ↓
    Rapport d'audit

### 🧾 Générer un rapport d'audit

Un script peut vérifier plusieurs règles et produire un rapport.

Exemple :

    [PASS] Root SSH login disabled
    [PASS] Password authentication disabled
    [PASS] Firewall enabled
    [FAIL] Password policy too weak

Cela permet de démontrer qu'un système respecte, ou non, les exigences de sécurité.

### 👤 Authentication vs Authorization

Il est important de ne pas confondre les deux.

**Authentication (AuthN)** répond à :

> "Qui es-tu ?"

Exemples :

- mot de passe ;
- clé SSH ;
- certificat ;
- MFA.

**Authorization (AuthZ)** répond à :

> "Qu'as-tu le droit de faire ?"

Exemples :

- permissions Linux ;
- groupes ;
- sudo ;
- accès à certains fichiers ou services.

À retenir :

    AuthN = Qui es-tu ?
    AuthZ = Qu'as-tu le droit de faire ?

---

## 🧰 Commands to Know

    # Vérifier la configuration SSH
    sshd -t

    # Afficher la configuration SSH effective
    sshd -T

    # Vérifier une règle SSH
    sshd -T | grep permitrootlogin

    # Tester une connexion SSH
    ssh user@server

    # Vérifier les permissions
    ls -l /etc/ssh/sshd_config

    # Voir les utilisateurs
    getent passwd

    # Voir les groupes
    getent group

    # Voir les droits de l'utilisateur
    id

    # Vérifier les règles PAM
    ls /etc/pam.d/

    # Vérifier les permissions sudo
    sudo -l

    # Vérifier l'état d'un service
    systemctl status ssh

    # Vérifier le code de sortie
    echo $?

---

## 💡 À retenir

- **Robuste** → le script vérifie avant de modifier.
- **Modulaire** → utiliser des fonctions et séparer les responsabilités.
- **Idempotent** → plusieurs exécutions ne doivent pas casser le système.
- **Configuration Management** → maintenir un état de sécurité souhaité.
- **Hardcoding** → rend les scripts moins réutilisables et peut exposer des informations sensibles.
- **Hardening réseau** → toujours prévoir une méthode de récupération avant de modifier l'accès.
- **PAM** → permet d'appliquer des politiques d'authentification.
- **SSH par clé** → réduit la dépendance aux mots de passe.
- **Compliance** → transformer une politique en contrôles mesurables.
- **Audit** → vérifier les contrôles et produire des preuves.
- **AuthN** → vérifier l'identité.
- **AuthZ** → déterminer les permissions.

---

## 🎯 Objectif final

Être capable de créer un **script de hardening Linux sécurisé et vérifiable** :

    Politique de sécurité
          ↓
    Contrôles techniques
          ↓
    Script de configuration
          ↓
    Vérification
          ↓
    Rapport d'audit

Le système doit être **durci, reproductible, vérifiable et difficile à casser par une mauvaise automatisation**.