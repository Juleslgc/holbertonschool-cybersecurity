# 🏗️ Engineering Standards & Architecture

## 📖 Description

Cette partie concerne les **bonnes pratiques d'ingénierie logicielle** nécessaires pour créer des scripts et des projets fiables, maintenables et sécurisés.

L'objectif est de ne pas seulement faire fonctionner un programme, mais de construire une solution **propre, compréhensible, réutilisable et facile à maintenir**.

---

## 🎯 Learning Objectives

### 🧩 1. Code Quality

Un code de qualité doit être :

- lisible ;
- organisé ;
- cohérent ;
- documenté lorsque nécessaire ;
- facile à modifier.

Éviter notamment :

- le code dupliqué ;
- les fonctions trop longues ;
- les variables mal nommées ;
- les valeurs hardcodées ;
- les comportements difficiles à comprendre.

### 🏗️ 2. Modular Architecture

Un projet doit être divisé en **composants ayant chacun une responsabilité claire**.

Exemple :

    project/
    ├── script.sh
    ├── config.conf
    ├── functions.sh
    └── tests/

Chaque partie possède un rôle précis.

Cela permet de modifier une partie du projet sans devoir réécrire tout le reste.

### 🔄 3. Reusability

Le code doit pouvoir être **réutilisé** plutôt que copié-collé.

Exemple :

    check_service() {
        systemctl is-active --quiet "$1"
    }

    check_service ssh
    check_service nginx

Une seule fonction peut ainsi être utilisée pour plusieurs services.

### 🧪 4. Testing & Verification

Un bon projet doit pouvoir vérifier que son comportement est correct.

Il faut notamment tester :

- le fonctionnement normal ;
- les erreurs ;
- les paramètres invalides ;
- les fichiers manquants ;
- les permissions insuffisantes ;
- les cas particuliers.

Un script doit également utiliser correctement les **codes de sortie** :

    0    → succès
    != 0 → erreur ou condition particulière

### 🔐 5. Security by Design

La sécurité doit être prise en compte **dès la conception**, et pas ajoutée uniquement à la fin.

Quelques principes importants :

- **Least Privilege** → donner uniquement les permissions nécessaires.
- **Defense in Depth** → utiliser plusieurs protections.
- **Fail Secure** → en cas d'erreur, éviter de laisser le système dans un état dangereux.
- **Input Validation** → vérifier les entrées utilisateur.
- **No Secrets in Code** → ne pas mettre de mots de passe, clés ou tokens directement dans le code.

### 📐 6. Maintainability

Une bonne architecture doit faciliter les futures modifications.

Il faut donc :

- séparer configuration et logique ;
- limiter les dépendances inutiles ;
- utiliser des noms explicites ;
- documenter les choix importants ;
- garder une structure de projet prévisible.

---

## 🧰 Commands & Tools to Know

    # Vérifier la syntaxe Bash
    bash -n script.sh

    # Exécuter avec des informations de debug
    bash -x script.sh

    # Vérifier le code de sortie
    echo $?

    # Rechercher du code ou une fonction
    grep -R "function_name" .

    # Voir la structure d'un projet
    tree

    # Contrôler les permissions
    ls -l

    # Vérifier un fichier
    file script.sh

---

## 💡 À retenir

- **Clean Code** → code lisible et compréhensible.
- **Modularité** → chaque composant possède une responsabilité claire.
- **Réutilisabilité** → éviter le copier-coller.
- **Tests** → vérifier que le programme fonctionne aussi dans les cas d'erreur.
- **Sécurité dès la conception** → ne pas attendre la fin du projet.
- **Least Privilege** → limiter les permissions.
- **Séparation** → distinguer configuration, logique et données.
- **Maintenabilité** → rendre les futures modifications simples et sûres.

---

## 🎯 Objectif final

Être capable de concevoir un projet avec une architecture :

    Claire
      ↓
    Modulaire
      ↓
    Testable
      ↓
    Sécurisée
      ↓
    Maintenable

L'objectif n'est pas seulement d'avoir un programme qui **fonctionne**, mais un programme que quelqu'un d'autre peut **comprendre, tester, modifier et maintenir**.