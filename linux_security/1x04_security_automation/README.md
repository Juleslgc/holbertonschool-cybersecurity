# ⚙️ Scripting Architecture, Configuration & Systemd

## 📖 Description

Ce projet permet d'apprendre à créer des **scripts Bash robustes, réutilisables et automatisables**.

L'objectif est de ne pas simplement écrire un script qui fonctionne une fois, mais de construire un script capable de vérifier et maintenir un état du système, de produire des logs exploitables et de s'intégrer proprement à `systemd`.

---

## 🎯 Learning Objectives

### 🧩 1. Scripting Architecture

Un bon script doit être **modulaire** et facile à maintenir.

- Utiliser des **fonctions** pour séparer les différentes tâches.
- Séparer la **configuration** du code.
- Éviter de répéter le même code.
- Utiliser les **codes de sortie** pour indiquer si une opération a réussi ou échoué.

Exemple :

    check_service() {
        systemctl is-active --quiet "$1"
    }

    check_service nginx
    echo $?

Un code `0` signifie généralement **succès**, tandis qu'un code différent de `0` indique une erreur ou une condition particulière.

### 🔁 2. Idempotence

Un script **idempotent** peut être exécuté plusieurs fois sans provoquer de problèmes ni modifier inutilement le système.

Par exemple, au lieu de toujours ajouter une ligne :

    echo "nameserver 8.8.8.8" >> config.txt

On vérifie d'abord si elle existe :

    grep -q "nameserver 8.8.8.8" config.txt || \
        echo "nameserver 8.8.8.8" >> config.txt

Le script peut ainsi être exécuté plusieurs fois sans créer de doublons.

---

## ⚙️ Configuration Management

### 📄 Séparer le code des données

Les valeurs qui peuvent changer doivent idéalement être placées dans un fichier de configuration.

Exemple :

    # config.conf
    SERVICE="nginx"
    LOG_FILE="/var/log/my-script.log"

Puis dans le script :

    source ./config.conf

Cela permet de modifier la configuration **sans modifier le code du script**.

### 🔒 State Enforcement

Il faut distinguer :

- **One-time fix** → effectuer une modification une seule fois.
- **State enforcement** → vérifier que le système est toujours dans l'état souhaité et le corriger si nécessaire.

Exemple :

    systemctl is-enabled --quiet nginx || systemctl enable nginx

Le script vérifie l'état avant d'agir.

### 🏆 Golden Copies

Une **golden copy** est une version connue comme correcte et fiable d'un fichier ou d'une configuration.

On peut comparer un fichier avec cette référence grâce à une somme de contrôle :

    sha256sum config.conf

Si le hash change, le fichier a été modifié.

Cela permet notamment de détecter une modification inattendue ou une altération.

---

## 🔧 Systemd Integration

### 🔹 Service Units

Un fichier `.service` décrit **quoi exécuter** et dans quelles conditions.

Exemple :

    [Unit]
    Description=My Security Script

    [Service]
    Type=oneshot
    ExecStart=/usr/local/bin/security-check.sh

### ⏰ Timer Units

Un fichier `.timer` permet de programmer l'exécution d'un service.

Exemple :

    [Timer]
    OnBootSec=5min
    OnUnitActiveSec=1h

Le script peut ainsi être exécuté automatiquement toutes les heures.

### 🆚 Systemd vs Cron

`systemd` apporte plusieurs avantages par rapport à `cron` :

- gestion des dépendances ;
- gestion des services ;
- logs via `journalctl` ;
- contrôle avec `systemctl` ;
- meilleure intégration avec le démarrage du système.

Commandes utiles :

    systemctl status my-script.service
    systemctl start my-script.service
    systemctl enable my-script.timer
    systemctl list-timers

---

## 📝 Structured Logging

Les logs doivent être suffisamment structurés pour être facilement analysés, notamment par un **SIEM**.

### 📦 JSON

Exemple :

    {"level":"INFO","message":"Service started","service":"nginx"}

Le format JSON permet aux outils de sécurité d'extraire facilement les différents champs.

### 🕐 Timestamp

Un timestamp permet de savoir **quand un événement s'est produit** et de corréler plusieurs événements provenant de différentes machines.

Exemple :

    2026-09-11T14:30:00+02:00

### 🚦 Log Levels

Les niveaux permettent de catégoriser les événements :

- `DEBUG` → informations détaillées pour le développement
- `INFO` → fonctionnement normal
- `WARNING` → situation inhabituelle
- `ERROR` → erreur
- `CRITICAL` → problème important nécessitant une intervention

---

## 🧰 Commands to Know

    # Exit code
    echo $?

    # Vérifier un service
    systemctl status nginx

    # Démarrer / arrêter
    systemctl start nginx
    systemctl stop nginx

    # Activer au démarrage
    systemctl enable nginx

    # Voir les timers
    systemctl list-timers

    # Consulter les logs systemd
    journalctl -u my-script.service

    # Suivre les logs en temps réel
    journalctl -u my-script.service -f

    # Vérifier l'intégrité d'un fichier
    sha256sum config.conf

    # Vérifier une condition
    if command; then
        echo "OK"
    else
        echo "ERROR"
    fi

---

## 💡 À retenir

- **Modularité** → utiliser des fonctions et séparer les responsabilités.
- **Idempotence** → pouvoir exécuter un script plusieurs fois sans créer de problèmes.
- **Exit codes** → `0` = succès, autre valeur = erreur/condition particulière.
- **Configuration externe** → séparer les données du code.
- **State enforcement** → vérifier et maintenir l'état souhaité.
- **Golden copy** → référence fiable permettant de vérifier l'intégrité.
- **Systemd service** → définit ce qui doit être exécuté.
- **Systemd timer** → définit quand l'exécuter.
- **JSON logs** → faciles à exploiter par un SIEM.
- **Timestamp + log level** → facilitent la corrélation et l'analyse des événements.

---

## 🎯 Objectif final

Être capable de créer un **script Bash robuste et sécurisé** qui :

    Configuration → Vérification → Action si nécessaire → Log JSON → Exit code

Puis de l'intégrer à `systemd` pour qu'il soit **automatiquement exécuté, surveillé et journalisé**.