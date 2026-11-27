# Python - The Log Alchemist

## Présentation du projet

**The Log Alchemist** est un projet personnel développé en Python dans le cadre de mon apprentissage de la programmation et de la cybersécurité.

L'objectif de ce projet est de développer progressivement un outil capable de lire, nettoyer et traiter des fichiers de logs afin de préparer leur analyse. Il s'inscrit dans une démarche d'apprentissage pratique visant à comprendre comment manipuler des données, automatiser certaines tâches et développer des outils utiles dans le domaine de la sécurité informatique.

À travers ce projet, je cherche à consolider mes connaissances en Python tout en découvrant les bonnes pratiques de développement : organisation du code, gestion des fichiers, traitement des erreurs et création d'interfaces en ligne de commande.

## Objectifs

The Log Alchemist a pour ambition de devenir un outil de traitement et d'analyse de fichiers de logs. Le développement se fait progressivement, en commençant par les fonctionnalités fondamentales avant d'intégrer des mécanismes d'analyse plus avancés.

Ce projet constitue également un exercice pratique pour apprendre à concevoir un programme structuré, fiable et évolutif.

## Fonctionnement actuel

Le programme utilise une interface en ligne de commande construite avec le module Python `argparse`. L'utilisateur peut indiquer le chemin d'un fichier à traiter, activer un mode détaillé et renseigner un emplacement destiné à un futur rapport.

Le programme commence par lire le fichier fourni, puis nettoie les données en supprimant les espaces superflus et les lignes vides. Une gestion des erreurs permet également de signaler les problèmes d'accès aux fichiers, notamment lorsqu'un fichier est introuvable ou que les permissions sont insuffisantes.

## Technologies utilisées

Le projet repose actuellement sur Python 3 et ses modules intégrés, notamment `argparse` pour la gestion des arguments, `sys` pour la gestion des erreurs et des codes de sortie, ainsi que les fonctions natives de manipulation de fichiers.

## Utilisation

Pour lancer le programme :

```bash
python main.py --file fichier.log
```

Pour activer le mode détaillé :

```bash
python main.py --file fichier.log --verbose
```

Pour indiquer un chemin de sortie destiné au rapport :

```bash
python main.py --file fichier.log --output rapport.txt
```

Pour afficher l'aide :

```bash
python main.py --help
```

## Évolutions envisagées

Le projet étant encore en cours de développement, plusieurs améliorations sont prévues, notamment l'écriture automatique de rapports, l'analyse du contenu des fichiers de logs, la détection d'événements inhabituels et l'ajout de fonctionnalités orientées cybersécurité.

## Conclusion

The Log Alchemist est avant tout un projet d'apprentissage qui évoluera au fil de mes connaissances et de mes expérimentations. Il me permet de mettre en pratique Python dans un contexte concret, tout en construisant progressivement un outil qui pourra trouver sa place dans une démarche d'analyse et de cybersécurité.