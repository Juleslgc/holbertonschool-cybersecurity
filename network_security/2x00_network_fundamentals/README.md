# 🌐 Network Fundamentals & Subnetting

## 📖 Description

Ce projet a pour objectif de comprendre les **fondamentaux des réseaux IPv4**, notamment le fonctionnement des adresses IP, des masques de sous-réseau, du CIDR, du subnetting et du routage.

L'objectif n'est pas seulement de connaître les commandes, mais de comprendre **ce qui se passe réellement au niveau des bits et des paquets réseau**.

À la fin de ce projet, je dois être capable d'expliquer ces concepts **sans avoir besoin de rechercher les réponses sur Google**.

---

# 🎯 Learning Objectives

## 1. 🔢 Binary & Addressing

### Conversion décimal ↔ binaire

Une adresse IPv4 est composée de **32 bits**, répartis en **4 octets de 8 bits**.

Exemple :

    192.168.1.10

Chaque nombre correspond à un octet :

    192       168       1         10
    ↓         ↓         ↓         ↓
    8 bits    8 bits    8 bits    8 bits

Une adresse IPv4 possède donc :

    8 + 8 + 8 + 8 = 32 bits

Chaque octet peut prendre une valeur comprise entre :

    0 et 255

La conversion entre décimal et binaire permet de comprendre comment les adresses IP et les masques fonctionnent réellement.

### Valeurs d'un octet

Les 8 bits d'un octet correspondent aux puissances de 2 suivantes :

    128  64  32  16  8  4  2  1

Par exemple :

    192 = 128 + 64

Donc :

    192 = 11000000

---

## 2. 🛡️ Subnet Masks

Un **masque de sous-réseau** permet de déterminer quelle partie d'une adresse IP correspond :

- au **réseau** ;
- à la **machine (host)**.

Exemple :

    IP      : 192.168.1.10
    Masque  : 255.255.255.0

En binaire :

    IP     : 11000000.10101000.00000001.00001010
    Masque : 11111111.11111111.11111111.00000000

Les `1` représentent la partie **réseau**.

Les `0` représentent la partie **machine**.

    RÉSEAU                         HOST
    11111111.11111111.11111111 | 00000000

Le masque permet donc à une machine de savoir si une adresse appartient au même réseau ou à un autre réseau.

---

## 3. 📌 CIDR

Le **CIDR** permet d'écrire un masque de manière plus courte.

Exemple :

    255.255.255.0

peut être écrit :

    /24

Cela signifie que les **24 premiers bits** sont utilisés pour identifier le réseau.

    11111111.11111111.11111111.00000000
    <--------- 24 bits -------->

Quelques exemples courants :

| CIDR | Masque |
|------|--------|
| `/8` | `255.0.0.0` |
| `/16` | `255.255.0.0` |
| `/24` | `255.255.255.0` |
| `/25` | `255.255.255.128` |
| `/26` | `255.255.255.192` |
| `/27` | `255.255.255.224` |
| `/28` | `255.255.255.240` |
| `/30` | `255.255.255.252` |

Le nombre après `/` indique simplement **combien de bits sont réservés au réseau**.

---

# 4. 🧩 Subnetting

Le **subnetting** consiste à diviser un réseau en plusieurs sous-réseaux plus petits.

Il permet notamment de :

- mieux organiser un réseau ;
- éviter de gaspiller des adresses IP ;
- séparer différents groupes de machines ;
- contrôler plus facilement le trafic réseau.

---

## Network ID

Le **Network ID** identifie le réseau auquel appartient une adresse IP.

Il est obtenu en réalisant un **AND logique** entre l'adresse IP et le masque.

Exemple :

    IP     : 192.168.1.10
    Masque : 255.255.255.0

Le résultat est :

    Network ID : 192.168.1.0

Toutes les machines du réseau `192.168.1.0/24` appartiennent au même réseau.

---

## Broadcast Address

L'adresse de **broadcast** permet d'envoyer un paquet à toutes les machines d'un sous-réseau.

Pour :

    192.168.1.0/24

le broadcast est :

    192.168.1.255

On peut retenir :

    Network ID → première adresse
    Broadcast  → dernière adresse

---

## Plage d'adresses utilisables

Dans un réseau IPv4 classique, les deux adresses suivantes ne sont généralement pas attribuées à des machines :

    Network ID
    Broadcast

Pour :

    192.168.1.0/24

on obtient :

    Network ID       : 192.168.1.0
    Première machine : 192.168.1.1
    Dernière machine : 192.168.1.254
    Broadcast        : 192.168.1.255

La plage utilisable est donc :

    192.168.1.1 → 192.168.1.254

---

# 5. 📐 VLSM

**VLSM (Variable Length Subnet Mask)** permet d'utiliser des masques de tailles différentes dans un même espace réseau.

L'objectif est de **ne pas gaspiller d'adresses IP**.

Par exemple, imaginons que nous devons créer trois réseaux :

    Réseau A → 100 machines
    Réseau B → 30 machines
    Réseau C → 10 machines

Nous n'avons pas besoin d'utiliser le même masque pour les trois réseaux.

On peut attribuer :

    Réseau A → /25
    Réseau B → /27
    Réseau C → /28

Chaque sous-réseau reçoit ainsi uniquement l'espace dont il a besoin.

---

# 6. 🚦 Routing Decisions

Lorsqu'une machine veut communiquer avec une adresse IP, elle doit d'abord déterminer si cette destination est :

- **locale (on-link)** ;
- **distante (off-link)**.

Elle utilise pour cela son **adresse IP et son masque**.

---

## Destination locale

Si la destination appartient au même réseau que la machine, elle peut communiquer **directement** avec elle.

Exemple :

    Machine A : 192.168.1.10/24
    Machine B : 192.168.1.20/24

Les deux machines appartiennent au réseau :

    192.168.1.0/24

La destination est donc **locale / on-link**.

La machine peut directement rechercher l'adresse MAC de la machine B avec **ARP**.

---

## Destination distante

Si la destination appartient à un autre réseau, la machine ne peut pas lui envoyer directement une trame Ethernet.

Elle doit passer par sa **passerelle par défaut (default gateway)**.

Exemple :

    Machine :
    192.168.1.10/24

    Destination :
    8.8.8.8

La destination `8.8.8.8` n'appartient pas au réseau `192.168.1.0/24`.

La machine utilise donc :

    Default Gateway
          ↓
    192.168.1.1

Le paquet est envoyé au routeur, qui se charge ensuite de le faire avancer vers sa destination.

---

# 7. 🔎 ARP

**ARP (Address Resolution Protocol)** permet de trouver l'adresse **MAC** associée à une adresse IPv4 sur le réseau local.

Exemple :

    IP  : 192.168.1.20
    MAC : AA:BB:CC:DD:EE:FF

Une machine peut demander :

    Who has 192.168.1.20?

La machine concernée répond avec son adresse MAC.

### Pourquoi ARP est utilisé uniquement localement ?

ARP fonctionne sur le **réseau local**.

Si la destination est sur un autre réseau, la machine ne cherche pas la MAC du serveur distant.

Elle cherche plutôt la MAC de sa **passerelle**.

Exemple :

    PC
    192.168.1.10
         |
         | Ethernet
         ↓
    Gateway
    192.168.1.1
         |
         | Router
         ↓
    Internet
         |
         ↓
    8.8.8.8

La machine connaît donc la MAC du **prochain équipement local**, pas celle de la destination finale.

---

# 8. 🗺️ Routing Table

La **table de routage** indique à la machine comment atteindre différentes destinations.

Elle contient notamment :

- les réseaux connus ;
- les interfaces à utiliser ;
- les passerelles ;
- les routes par défaut.

Exemple simplifié :

    Destination       Gateway       Interface
    192.168.1.0/24    on-link       eth0
    default           192.168.1.1   eth0

La machine consulte cette table pour déterminer **où envoyer le paquet ensuite**.

Le routeur fait la même chose : il consulte sa table de routage pour décider du **prochain saut (next hop)**.

---

# 9. ⏳ TTL

**TTL (Time To Live)** est une valeur présente dans l'en-tête IPv4.

Elle permet d'empêcher un paquet de circuler indéfiniment sur le réseau.

À chaque fois qu'un routeur fait transiter le paquet, le TTL est diminué.

Exemple :

    PC
    TTL = 64
     ↓
    Routeur
    TTL = 63
     ↓
    Routeur
    TTL = 62
     ↓
    Routeur
    TTL = 61

Si le TTL arrive à `0`, le paquet est supprimé.

Cela permet notamment d'éviter qu'un paquet reste bloqué indéfiniment dans une **boucle de routage**.

---

# 10. 🧱 OSI Model — Practical Networking

Ce projet se concentre principalement sur les **couches 2 et 3 du modèle OSI**.

---

## Layer 2 — Data Link

La couche 2 concerne notamment :

- les trames Ethernet ;
- les adresses MAC ;
- les communications sur le réseau local.

Lorsqu'une machine veut envoyer des données vers Internet, elle ne peut pas directement utiliser la MAC du serveur distant.

Elle doit envoyer la trame Ethernet à la **MAC de la passerelle**.

    IP destination :
    8.8.8.8

    MAC destination :
    MAC de la gateway

Le routeur reçoit alors la trame et traite le paquet IP pour continuer son acheminement.

---

## Layer 3 — Network

La couche 3 concerne principalement :

- les adresses IP ;
- les réseaux ;
- les routeurs ;
- le routage ;
- le TTL.

Les routeurs utilisent les informations de couche 3 pour déterminer **où envoyer les paquets**.

Exemple :

    PC
    192.168.1.10
         |
         ↓
    Routeur
    192.168.1.1
         |
         ↓
    Internet
         |
         ↓
    8.8.8.8

Chaque routeur prend une décision de routage et transmet le paquet vers le prochain saut.

---

# 11. 🔗 On-link vs Off-link

Une notion importante est de savoir si une destination est **on-link** ou **off-link**.

### On-link

La destination appartient au même réseau local.

    PC : 192.168.1.10/24
    DST: 192.168.1.20

    → Même réseau
    → On-link
    → Communication directe
    → ARP pour trouver la MAC

### Off-link

La destination appartient à un autre réseau.

    PC : 192.168.1.10/24
    DST: 10.0.0.50

    → Réseau différent
    → Off-link
    → Envoi vers la gateway
    → ARP pour trouver la MAC de la gateway

---

# 🧠 À retenir

Le fonctionnement peut être résumé ainsi :

    ADRESSE IP
         │
         ↓
    +-------------+
    | IP + Masque |
    +-------------+
         │
         ↓
    Même réseau ou non ?
       /             \
     OUI              NON
      │                │
      ↓                ↓
    ON-LINK         OFF-LINK
      │                │
      ↓                ↓
     ARP          ARP Gateway
      │                │
      ↓                ↓
    Machine cible   Routeur
                       │
                       ↓
                 Table de routage
                       │
                       ↓
                    Next Hop

Les notions principales à maîtriser sont donc :

    IPv4
     ↓
    Binaire
     ↓
    Masque
     ↓
    CIDR
     ↓
    Network ID
     ↓
    Broadcast
     ↓
    Host Range
     ↓
    Subnetting
     ↓
    VLSM
     ↓
    On-link / Off-link
     ↓
    ARP
     ↓
    Gateway
     ↓
    Routing Table
     ↓
    Next Hop
     ↓
    TTL

---

# 🛠️ Commandes utiles

Quelques commandes Linux utiles pour mettre ces concepts en pratique.

### Afficher les adresses IP

    ip addr

Cette commande permet d'afficher les interfaces réseau et leurs adresses IP.

### Afficher la table de routage

    ip route

Cette commande permet d'afficher la table de routage de la machine.

### Vérifier le chemin vers une destination

    ip route get 8.8.8.8

Cette commande permet de voir comment la machine compte atteindre une destination donnée.

### Afficher les voisins réseau

    ip neigh

Cette commande permet d'afficher les associations IP ↔ MAC connues par la machine.

### Tester la connectivité

    ping 8.8.8.8

Cette commande permet de tester la connectivité vers une destination.

### Observer les routeurs traversés

    traceroute 8.8.8.8

Cette commande permet d'observer les différents routeurs traversés par les paquets.

---

# 🎓 Final Goal

À la fin du projet, je dois être capable de prendre une adresse comme :

    192.168.10.45/26

et de déterminer sans outil :

    Adresse IP
        ↓
    Masque
        ↓
    Network ID
        ↓
    Broadcast
        ↓
    Plage d'hôtes utilisables
        ↓
    Destination locale ou distante ?
        ↓
    ARP ou Gateway ?
        ↓
    Next Hop

L'objectif final est donc de comprendre **ce qui se passe réellement lorsqu'une machine envoie un paquet sur un réseau**, depuis l'adresse IP jusqu'au routage.
