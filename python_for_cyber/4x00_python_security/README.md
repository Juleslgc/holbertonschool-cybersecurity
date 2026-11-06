# Objectifs pédagogiques du projet
À la fin de ce projet, je dois être capable d'expliquer et de maîtriser plusieurs notions fondamentales du langage Python, notamment dans le domaine de la cybersécurité.

L'objectif est de comprendre le fonctionnement de ces outils, leur utilité et leur importance dans le développement de programmes fiables et sécurisés, sans avoir besoin de rechercher les réponses sur Internet.

## Voici les différentes compétences que je dois acquérir :
### 1. Les environnements virtuels (`venv`)
Je dois comprendre pourquoi l'utilisation des environnements virtuels est indispensable dans les projets liés à la cybersécurité.

Un environnement virtuel permet d'isoler les bibliothèques et les dépendances d'un projet afin d'éviter les conflits entre différentes versions de logiciels. Il permet également de mieux contrôler l'environnement dans lequel le programme est exécuté et de limiter certains risques liés à la sécurité.

### 2. La différence entre `sys.argv` et `argparse`
Je dois être capable de faire la différence entre ces deux méthodes permettant de récupérer des arguments transmis à un programme Python.
- `sys.argv` permet de récupérer directement les arguments fournis lors du lancement du programme.
- `argparse` permet de gérer ces arguments de manière plus organisée, avec des options, des descriptions et des messages d'aide.
L'objectif est de savoir choisir la méthode la plus adaptée selon les besoins du programme.

### 3. La gestion des erreurs avec `try/except`
Je dois apprendre à utiliser les blocs `try/except` afin d'anticiper et de gérer les erreurs pouvant survenir pendant l'exécution d'un programme.

Cette méthode permet d'éviter qu'un programme s'arrête brutalement lorsqu'une erreur se produit. Elle permet également de contrôler les messages d'erreur affichés à l'utilisateur afin de ne pas divulguer d'informations sensibles sur le fonctionnement interne du programme.

### 4. Les gestionnaires de contexte (`with open...`)
Je dois comprendre pourquoi les gestionnaires de contexte sont importants lors de la manipulation de fichiers en Python.

L'utilisation de `with open()` permet d'ouvrir un fichier et de garantir sa fermeture automatique une fois les opérations terminées, même lorsqu'une erreur survient.

Cette méthode permet d'éviter certains problèmes liés à une mauvaise gestion des fichiers et contribue à rendre le code plus propre, plus fiable et plus sécurisé.

### 5. La structure d'un projet Python (`if __name__ == "__main__":`)
Je dois être capable d'organiser correctement un projet Python en séparant les différentes fonctions et parties du programme.

L'utilisation de `if __name__ == "__main__":` permet de définir le point d'entrée du programme. Cela signifie que certaines instructions ne seront exécutées que lorsque le fichier est lancé directement, et non lorsqu'il est importé dans un autre fichier.

Cette organisation facilite la réutilisation du code, sa maintenance et son évolution.

### 6. La différence entre le hachage (**Hashing**) et le chiffrement (**Encryption**)
Je dois comprendre la différence entre ces deux mécanismes importants en cybersécurité.
- Le hachage (**Hashing**) consiste à transformer une donnée en une empreinte numérique de taille généralement fixe. Cette opération est conçue pour être irréversible. Elle est notamment utilisée pour vérifier l'intégrité des fichiers et stocker des mots de passe de manière sécurisée, avec un algorithme adapté.
- Le chiffrement (**Encryption**) consiste à transformer une information lisible en une donnée illisible afin de la protéger. Contrairement au hachage, le chiffrement peut être réversible à condition de posséder la clé de déchiffrement appropriée.
L'objectif est donc de savoir dans quelles situations utiliser le hachage ou le chiffrement pour protéger des informations.

### 7. Les tests unitaires (**Unit Tests**)
Enfin, je dois apprendre à écrire des tests unitaires afin de vérifier le bon fonctionnement de mon code.

Les tests unitaires permettent de tester individuellement les différentes fonctions d'un programme pour vérifier qu'elles produisent les résultats attendus.

Ils permettent notamment de détecter les erreurs, de prévenir les régressions et de s'assurer que le programme fonctionne correctement dans différentes situations.

## Conclusion
Ce projet a pour objectif de renforcer mes compétences en programmation Python tout en découvrant les bonnes pratiques liées à la cybersécurité.

À travers ces différents apprentissages, je dois être capable de développer un programme structuré, fiable, sécurisé et facile à maintenir.

Au-delà de la simple utilisation de Python, ce projet me permettra de comprendre pourquoi certaines méthodes sont essentielles dans le développement informatique, particulièrement lorsqu'il s'agit de manipuler des données et de protéger des informations sensibles.