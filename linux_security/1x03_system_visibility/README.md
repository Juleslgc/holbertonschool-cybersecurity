# ⚙️ Linux Processes, Signals & Network Visibility

## 📖 Description

Ce projet permet de comprendre le fonctionnement des **processus Linux**, la gestion des signaux, les connexions réseau et l'analyse des logs système.

L'objectif est de savoir identifier ce qui tourne sur une machine, comprendre les processus, repérer les ports ouverts et corréler les événements avec les logs.

## 🎯 Learning Objectives

### ⚙️ Process Fundamentals

#### Process Hierarchy

Comprendre les principaux éléments d'un processus :

    PID  → identifiant du processus
    PPID → identifiant du processus parent

Les processus forment une hiérarchie :

    Process parent
         ↓
    Process child
         ↓
    Process child

Comprendre également les principaux états :

- **Running** → processus en cours d'exécution
- **Sleeping** → processus en attente
- **Zombie** → processus terminé mais dont le parent n'a pas encore récupéré le résultat

---

### 📂 `/proc`

`/proc` est un système de fichiers virtuel qui expose des informations sur le système et les processus.

Exemple :

    /proc/<PID>/

On peut notamment y retrouver des informations sur :

- le processus ;
- sa mémoire ;
- ses fichiers ouverts ;
- son environnement ;
- son état.

Des outils comme `ps` et `top` utilisent notamment les informations fournies par le système et `/proc` pour afficher l'état des processus.

---

### 👤 Process Ownership

Chaque processus est associé à un utilisateur.

Permet de savoir **qui a lancé le processus** et avec quels privilèges il fonctionne.

Commandes utiles :

    ps aux
    ps -ef

Exemple :

    ps -ef | grep nginx

---

# 📡 Signal Management

Les signaux permettent de communiquer avec les processus.

### 🟢 SIGTERM

`SIGTERM` demande au processus de s'arrêter proprement.

    kill -TERM PID

C'est généralement le signal à utiliser en premier car le programme peut effectuer son nettoyage avant de quitter.

---

### 🔴 SIGKILL

`SIGKILL` force immédiatement l'arrêt du processus.

    kill -KILL PID

ou :

    kill -9 PID

Le processus ne peut pas intercepter ou ignorer `SIGKILL`.

### À retenir

    SIGTERM → demande gentiment l'arrêt
    SIGKILL → force l'arrêt

---

### ⏸️ SIGSTOP & SIGCONT

`SIGSTOP` suspend un processus.

    kill -STOP PID

Le processus est alors gelé.

`SIGCONT` permet de le reprendre :

    kill -CONT PID

Cela peut être utile pour suspendre temporairement un processus lors d'une analyse.

---

### 🦠 Signal Handling

Un programme peut gérer certains signaux.

Par exemple, un malware peut intercepter ou ignorer `SIGTERM`.

En revanche :

    SIGKILL

ne peut pas être intercepté par le processus.

C'est pourquoi `SIGKILL` peut être utilisé lorsqu'un processus refuse de s'arrêter normalement.

---

# 🌐 Network Visibility

## 🔌 Socket States

Les sockets représentent les communications réseau d'un système.

États importants :

- **LISTEN** → un service attend des connexions
- **ESTABLISHED** → une connexion est active
- **TIME_WAIT** → une connexion récemment terminée est encore maintenue temporairement

---

## 🔎 Port-to-Process Mapping

En cybersécurité, il est important de savoir **quel processus utilise quel port**.

Exemple :

    Port 22 → sshd
    Port 80 → nginx
    Port 443 → serveur web

Cela permet notamment d'identifier les services exposés sur une machine.

---

### `ss`

`ss` permet d'afficher les sockets et connexions réseau.

Exemple :

    ss -tulpn

Permet notamment de voir :

- TCP ;
- UDP ;
- ports en écoute ;
- processus associés.

---

### `lsof`

`lsof` permet de savoir quels fichiers et ressources sont ouverts par les processus.

Pour les connexions réseau :

    lsof -i

Pour un port spécifique :

    lsof -i :22

---

### `netstat`

`ss` et `lsof` sont aujourd'hui couramment utilisés pour remplacer ou compléter `netstat`.

---

# 📜 Log Analysis

## 📝 systemd-journald

`systemd-journald` collecte de nombreux événements système dans le journal de `systemd`.

La commande principale est :

    journalctl

Afficher les logs :

    journalctl

Voir les logs récents :

    journalctl -n 50

Filtrer depuis une certaine période :

    journalctl --since "1 hour ago"

Suivre les nouveaux événements :

    journalctl -f

---

## 🧠 Kernel Ring Buffer

Le noyau Linux conserve également des messages concernant notamment :

- matériel ;
- pilotes ;
- démarrage ;
- événements bas niveau.

La commande :

    dmesg

permet de consulter ces messages.

Exemple :

    dmesg | tail

---

# 🔗 Log Correlation

La **corrélation des logs** consiste à mettre en relation plusieurs événements pour comprendre ce qui s'est passé.

Exemple :

    14:00 → processus lancé
    14:01 → connexion réseau établie
    14:02 → fichier modifié
    14:03 → erreur enregistrée

En corrélant ces informations, on peut identifier un comportement potentiellement suspect.

---

# 🧰 Commands to Know

### Processus

    ps aux
    ps -ef
    top
    /proc

### Signaux

    kill -TERM PID
    kill -KILL PID
    kill -STOP PID
    kill -CONT PID

### Réseau

    ss -tulpn
    ss -ant
    lsof -i
    lsof -i :22

### Logs

    journalctl
    journalctl -f
    journalctl --since "1 hour ago"
    dmesg

---

# 💡 À retenir

    PID       → identifiant du processus
    PPID      → processus parent
    /proc     → informations système et processus

    SIGTERM   → arrêt propre
    SIGKILL   → arrêt forcé
    SIGSTOP   → suspendre
    SIGCONT   → reprendre

    LISTEN    → attend une connexion
    ESTABLISHED → connexion active
    TIME_WAIT → connexion récemment terminée

    ss        → sockets et connexions
    lsof      → fichiers / ressources ouverts

    journalctl → logs systemd
    dmesg      → messages du noyau

## 🎯 Objectif final

Être capable d'analyser une machine Linux pour déterminer :

- quels processus sont actifs ;
- qui les a lancés ;
- quels processus sont parents ou enfants ;
- quels processus sont suspects ;
- quels ports sont ouverts ;
- quel processus utilise un port ;
- quelles connexions réseau sont actives ;
- quels événements ont été enregistrés dans les logs.

**L'objectif est de pouvoir relier processus, réseau et logs afin de comprendre ce qui se passe réellement sur une machine Linux.**