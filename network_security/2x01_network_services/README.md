# 🌐 DNS & DHCP Fundamentals

## 📖 Description

Ce projet permet de comprendre le fonctionnement de **DNS et DHCP**, deux services essentiels au fonctionnement d'un réseau.

L'objectif est de comprendre comment une machine obtient sa configuration réseau, comment elle traduit un nom de domaine en adresse IP et quelles sont les principales failles liées à ces services.

---

## 🎯 Learning Objectives

### 🌐 1. DNS Fundamentals

Le **DNS (Domain Name System)** permet de traduire un nom de domaine en adresse IP.

    google.com
        ↓
    DNS
        ↓
    IP address

### 🔄 Recursive vs Iterative

Une requête **récursive** demande au serveur DNS de trouver lui-même la réponse complète.

Une requête **itérative** demande au serveur de fournir la meilleure information qu'il possède, éventuellement sous forme de référence vers un autre serveur.

### 🌳 DNS Hierarchy

Le DNS fonctionne avec une hiérarchie :

    Root
      ↓
    TLD (.com, .fr, .org...)
      ↓
    Authoritative DNS
      ↓
    Domaine

Les serveurs :

- **Root servers** → indiquent où trouver les serveurs TLD.
- **TLD servers** → indiquent les serveurs autoritaires du domaine.
- **Authoritative servers** → possèdent les informations officielles du domaine.

### 📋 DNS Records

| Record | Rôle |
|---|---|
| `A` | Nom → adresse IPv4 |
| `AAAA` | Nom → adresse IPv6 |
| `CNAME` | Alias vers un autre nom |
| `MX` | Serveurs de messagerie |
| `TXT` | Informations textuelles, SPF, vérifications... |
| `PTR` | IP → nom, reverse DNS |
| `SOA` | Informations principales de la zone |
| `NS` | Serveurs DNS autoritaires |

### ⏱️ TTL & Cache

Le **TTL (Time To Live)** indique combien de temps une réponse DNS peut être conservée en cache.

    DNS Query
       ↓
    Response + TTL
       ↓
    Cache
       ↓
    Réutilisation jusqu'à expiration

Le cache permet d'éviter de refaire constamment les mêmes requêtes DNS.

---

## 🔐 2. DNS Security

### 📄 `/etc/hosts`

Le fichier `/etc/hosts` permet d'associer localement un nom à une adresse IP.

Exemple :

    192.168.1.100 example.local

Selon la configuration de résolution du système, `/etc/hosts` peut être consulté avant DNS.

Un malware peut abuser de ce mécanisme pour rediriger un utilisateur vers une adresse IP contrôlée par l'attaquant.

### ✉️ SPF

**SPF (Sender Policy Framework)** est un mécanisme publié dans un enregistrement `TXT` DNS.

Il indique quels serveurs sont autorisés à envoyer des emails pour un domaine.

Cela permet notamment de réduire l'usurpation de l'adresse d'expéditeur.

SPF **n chiffre pas les emails** et ne protège pas à lui seul contre toutes les formes de spoofing.

### 🔄 Zone Transfer

Une **zone transfer** permet de répliquer les informations DNS entre serveurs.

Les principaux mécanismes sont :

    AXFR → transfert complet
    IXFR → transfert incrémental

Un serveur mal configuré qui autorise n'importe qui à effectuer un transfert peut révéler :

- les sous-domaines ;
- les adresses IP ;
- les serveurs DNS ;
- les serveurs mail ;
- d'autres informations internes.

### 🎯 Interroger un DNS spécifique

On peut demander directement à un serveur DNS de résoudre un domaine :

    dig @8.8.8.8 example.com

Cela permet notamment de comparer les réponses de différents résolveurs.

---

## 📡 3. DHCP Fundamentals

Le **DHCP (Dynamic Host Configuration Protocol)** permet de configurer automatiquement une machine sur le réseau.

### 🔄 DORA

Le processus classique est :

    Discover
        ↓
    Offer
        ↓
    Request
        ↓
    Acknowledge

**Discover** → le client cherche un serveur DHCP.

**Offer** → le serveur propose une configuration.

**Request** → le client demande cette configuration.

**Acknowledge** → le serveur confirme l'attribution.

### 📦 Informations fournies par DHCP

DHCP peut fournir notamment :

- adresse IP ;
- masque ;
- passerelle ;
- serveur DNS ;
- durée du bail (lease).

### 💾 DHCP Lease

Le client conserve généralement des informations sur son bail DHCP.

L'emplacement dépend du client réseau utilisé et de la distribution Linux.

On peut notamment rencontrer :

    /var/lib/dhcp/

Mais ce chemin n'est **pas universel**.

### ⚠️ Rogue DHCP

Un **rogue DHCP server** est un serveur DHCP non autorisé sur le réseau.

Il peut fournir aux machines :

- une fausse passerelle ;
- un faux serveur DNS ;
- une mauvaise configuration réseau.

Cela peut permettre à un attaquant de **rediriger ou intercepter le trafic**.

---

## 🛠️ 4. Practical Skills

### `dig`

Outil très pratique pour effectuer des requêtes DNS.

    dig example.com
    dig A example.com
    dig MX example.com
    dig TXT example.com
    dig @8.8.8.8 example.com

### `nslookup`

Permet de réaliser des requêtes DNS et de faire du dépannage interactif.

    nslookup example.com

### `/etc/resolv.conf`

Contient généralement les serveurs DNS utilisés par le système.

    cat /etc/resolv.conf

Exemple :

    nameserver 8.8.8.8

### Reverse DNS

Le reverse DNS permet de faire :

    IP → nom de domaine

Avec `dig` :

    dig -x 8.8.8.8

Avec un enregistrement `PTR`, le serveur DNS peut retourner le nom associé à l'adresse IP.

---

## 🧰 Commands to Know

    # DNS lookup
    dig example.com

    # Specific record
    dig A example.com
    dig MX example.com
    dig TXT example.com

    # Specific DNS server
    dig @8.8.8.8 example.com

    # Reverse DNS
    dig -x 8.8.8.8

    # Interactive DNS troubleshooting
    nslookup example.com

    # DNS configuration
    cat /etc/resolv.conf

    # Local hostname resolution
    cat /etc/hosts

    # Check network configuration
    ip addr

---

## 💡 À retenir

- **DNS** → transforme les noms en informations réseau.
- **Recursive** → le serveur cherche la réponse complète.
- **Iterative** → le serveur indique où poursuivre la recherche.
- **Root → TLD → Authoritative** → hiérarchie DNS.
- **TTL** → durée de conservation d'une réponse dans le cache.
- `/etc/hosts` → résolution locale pouvant prendre priorité sur DNS selon la configuration.
- **SPF** → indique quels serveurs peuvent envoyer des emails pour un domaine.
- **AXFR/IXFR** → mécanismes de transfert de zone.
- **DHCP** → fournit automatiquement la configuration réseau.
- **DORA** → Discover → Offer → Request → Acknowledge.
- **Rogue DHCP** → serveur DHCP non autorisé pouvant fournir une configuration malveillante.
- **Reverse DNS** → IP → nom grâce notamment aux enregistrements `PTR`.

---

## 🎯 Objectif final

Être capable de suivre le fonctionnement d'une machine sur un réseau :

    DHCP
      ↓
    IP + Gateway + DNS
      ↓
    DNS Query
      ↓
    Resolver
      ↓
    Root → TLD → Authoritative
      ↓
    IP obtenue
      ↓
    Connexion au serveur