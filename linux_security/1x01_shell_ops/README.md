# 🐚 Linux Shell Pipelines & Data Processing

## 📖 Description

Ce projet permet de comprendre comment **Linux traite les entrées et sorties des commandes** et comment combiner plusieurs outils pour analyser et transformer des données.

L'objectif est de maîtriser les **pipelines**, les redirections, les flux standards et les principaux outils de traitement de texte utilisés en administration système et en cybersécurité.

## 🎯 Learning Objectives

### 🔄 Standard Streams

Comprendre les trois flux standards de Linux :

    stdin  → 0 → entrée standard
    stdout → 1 → sortie standard
    stderr → 2 → sortie d'erreur

Savoir rediriger ces flux :

    command > output.txt
    command >> output.txt
    command < input.txt
    command 2> error.txt

---

### 📄 File Descriptors

Comprendre comment Linux représente les entrées et sorties avec des **file descriptors**.

Les trois principaux sont :

    0 → stdin
    1 → stdout
    2 → stderr

Linux considère de nombreuses ressources comme des fichiers, ce qui permet de manipuler les flux de manière uniforme.

---

### 🔗 Pipeline

Le symbole `|` permet d'envoyer la sortie d'une commande directement vers l'entrée d'une autre.

Exemple :

    cat access.log | grep "404"

Ici :

    cat → produit les données
    |
    grep → filtre les données

Les pipelines évitent de devoir créer un fichier temporaire entre chaque étape.

Exemple :

    command1 | command2 | command3

---

### 🔄 Process Substitution

La substitution de processus permet d'utiliser la sortie d'une commande comme si elle était un fichier.

Syntaxe :

    <(command)

Exemple :

    diff <(ls dossier1) <(ls dossier2)

`>(command)` permet également d'envoyer une sortie vers une commande.

Ces mécanismes sont particulièrement utiles pour comparer ou combiner les résultats de plusieurs commandes.

---

## 🛠️ Tool Mastery

### 🔎 grep

Permet de rechercher des motifs dans du texte.

    grep "error" log.txt

Avec une expression régulière étendue :

    grep -E "error|warning" log.txt

---

### ✏️ sed

Permet de modifier ou transformer du texte directement dans un flux.

Exemple :

    sed 's/http/https/g' file.txt

Ici, `sed` remplace `http` par `https`.

---

### 📊 awk

Permet de traiter des données organisées en colonnes.

Exemple :

    awk '{print $1}' access.log

Affiche le premier champ de chaque ligne.

Très utile pour analyser :

- logs ;
- fichiers CSV ;
- tableaux ;
- données réseau.

---

### 📦 xargs

Permet de transformer une entrée en arguments pour une autre commande.

Exemple :

    cat files.txt | xargs rm

Les éléments de `files.txt` sont utilisés comme arguments de `rm`.

---

### 🔢 sort

Trie les données.

    sort file.txt

---

### 🔁 uniq

Supprime les doublons consécutifs.

    sort file.txt | uniq

Pour compter les occurrences :

    sort file.txt | uniq -c

---

### ✂️ cut

Permet d'extraire certaines colonnes ou parties d'une ligne.

Exemple :

    cut -d ':' -f1 /etc/passwd

Extrait le premier champ de `/etc/passwd`.

---

### 🔤 tr

Permet de remplacer ou supprimer des caractères.

Exemple :

    echo "hello" | tr 'a-z' 'A-Z'

Résultat :

    HELLO

---

### 📋 tee

Permet d'envoyer une sortie vers un fichier **tout en la laissant passer dans le pipeline**.

Exemple :

    command | tee output.txt

La sortie est affichée à l'écran et enregistrée dans `output.txt`.

---

# 🔐 Security Applications

## 📜 Log Analysis

Les pipelines permettent d'analyser rapidement de grandes quantités de logs.

Exemple :

    cat access.log | awk '{print $1}' | sort | uniq -c

Permet par exemple de compter le nombre de requêtes provenant de chaque IP.

On peut également rechercher des erreurs :

    grep "404" access.log

---

## 🚨 IoC Extraction

IoC signifie :

**Indicator of Compromise**

Il peut s'agir de :

- adresses IP ;
- domaines ;
- URLs ;
- noms de fichiers ;
- hashes ;
- adresses email.

Les outils comme `grep`, `awk`, `sed` et `sort` permettent d'extraire et de filtrer ces informations à partir de données brutes.

---

## 📦 Bulk Operations

Les pipelines peuvent être combinés avec `xargs` pour effectuer une opération sur un grand nombre de fichiers.

Exemple :

    find . -name "*.log" | xargs grep "error"

Cela permet de rechercher `error` dans plusieurs fichiers.

Il faut cependant être prudent avec les commandes destructives comme `rm`.

---

## 📈 Anomaly Detection

Les outils de traitement de texte peuvent aider à identifier des comportements inhabituels.

Exemple :

    cat access.log | awk '{print $1}' | sort | uniq -c | sort -n

On peut ainsi repérer les IP qui génèrent un nombre particulièrement élevé de requêtes.

---

# 🧰 Commands to Know

    grep
    sed
    awk
    xargs
    sort
    uniq
    cut
    tr
    tee

Et les opérateurs :

    >
    >>
    <
    |
    2>
    <()
    >()

---

# 💡 À retenir

    stdin  → entrée
    stdout → sortie normale
    stderr → erreurs

    |      → envoyer la sortie vers une autre commande
    >      → rediriger vers un fichier
    >>     → ajouter à un fichier
    2>     → rediriger les erreurs
    <()    → substitution de processus

Les principaux outils :

    grep  → rechercher
    sed   → modifier
    awk   → traiter des colonnes
    xargs → transformer l'entrée en arguments
    sort  → trier
    uniq  → gérer les doublons
    cut   → extraire des champs
    tr    → transformer des caractères
    tee   → afficher + enregistrer

## 🎯 Objectif final

Être capable de construire des **pipelines efficaces** pour :

- analyser des logs ;
- extraire des informations ;
- rechercher des IoC ;
- traiter de grandes quantités de données ;
- détecter des anomalies ;
- automatiser des opérations sur plusieurs fichiers.

**L'objectif est de savoir combiner plusieurs petites commandes Linux pour réaliser des traitements complexes.**