# 🏗️ Infrastructure Homelab — Schéma d'Architecture & Allocation des Ressources

**Date de création :** 16 octobre 2026
**Dernière mise à jour :** 26 octobre 2026 — passage de Fail2ban à CrowdSec (§8, §10), mise en place de la supervision (§16), UFW, restriction par IP et port SSH personnalisé (§17)
**Serveur hôte :** Proxmox — 32 threads · 32 Go RAM

---

## §1 — Rôles et Fonctions des Composants

| # | Composant / Rôle | Fonction principale | Notes |
|---|---|---|---|
| 1 | **OPNsense** — Réseau & Sécurité | • Plan d'adressage IP sur mesure<br>• Serveur DHCP (attribution)<br>• Serveur DNS (résolution locale)<br>• Pare-feu (filtrage du trafic entrant & sortant) | Fondement du réseau isolé du homelab |
| 2 | **Docker** — Hébergement d'applications | • Environnement de conteneurs : héberger, isoler et exécuter les apps<br>• Reverse proxy (Traefik ou Nginx) : point d'entrée qui reçoit les requêtes IP & nom de domaine → redirection dynamique vers l'app / le conteneur interne | Isole et exécute les applications |
| 3 | **Kubernetes / K8s** — Orchestration | • Node Controller (Control Plane) : surveillance du cycle de vie, état des nœuds, répartition de charge<br>• Nodes Workers × 2 : exécution concrète des apps et pods/conteneurs | Coordination intelligente de conteneurs |
| 4 | **Supervision** — Observabilité / Monitoring | • Prometheus : collecte de métriques en temps réel<br>• Grafana : dashboards de santé (serveurs, containers, cluster K8s)<br>• Loki : gestion et recherche centralisée des logs | Pilotage complet du système (détail au §16) |

---

## §2 — Allocation des Ressources (Les Trois Blocs)

| Bloc | Contenu détaillé | RAM allouée | vCPU alloués |
|---|---|---|---|
| **Docker** | Docker + applications + reverse proxy | 6 – 8 Go | 4 |
| **Supervision** | Prometheus + Grafana + Loki | 3 – 4 Go | 2 |
| **K8s** (Control + 2 Workers) | Orchestration cluster Kubernetes | 10 – 12 Go | 6 |
| **TOTAL DES TROIS BLOCS** | | **19 – 24 Go** | **12 vCPU** |

> 💡 La marge de RAM libre (2–8 Go) permet à Proxmox de respirer, d'absorber les pics de charge et de garder de la place pour des tests temporaires ou des clones de VM.

---

## §3 — Budget Global (Base de l'Infrastructure + Serveur Hôte)

| Élément | RAM | vCPU |
|---|---|---|
| Hôte Proxmox (serveur physique : 32 threads / 32 Go RAM) | 3 – 4 Go | n/a (sur hardware) |
| VM OPNsense (routeur, pare-feu, DNS, DHCP) | 2 Go | 2 vCPU |
| Les trois blocs (Docker + Supervision + K8s) | 19 – 24 Go | 12 vCPU |
| **Total global estimé** | **≈ 24 – 30 Go sur 32** | **≈ 14 vCPU (sur 32 threads)** |

### Distribution RAM — Serveur Proxmox (32 Go total)

```
Proxmox Host   │ ██████░░░░░░░░░░░░░░   3–4 Go    (≈ 10–12 %)    ✅ Flexibilité hôte garantie
OPNsense VM    │ ███░░░░░░░░░░░░░░░░░   2 Go      (≈ 6 %)        🔒 Sécurité & réseau
Docker Block   │ ████████░░░░░░░░░░░░   6–8 Go    (≈ 25 %)       ⚡ Apps isolées + Reverse Proxy
Supervision    │ █████░░░░░░░░░░░░░░░   3–4 Go    (≈ 12,5 %)     📊 Monitoring live
K8s Cluster    │ ██████████░░░░░░░░░░   10–12 Go  (≈ 37–40 %)    ⚠️ Plus gourmand → nécessite la marge !
───────────────┼──────────────────────────────────────────────────────────────────────────
Marge libre    │ ≈ 2–8 Go — flexibilité & pics de charge ✅
```

---

## §4 — Vue d'Écran / Architecture Finale (Top-Down)

```
╔══════════════════════════════════════════════════════════════════════════╗
║  🚀 SERVEUR PROXMOX (Serveur Hôte)                                       ║
║     Configuration : 32 threads · 32 Go RAM                               ║
╠══════════════════════════════════════════════════════════════════════════╣
║                                                                          ║
║  ┌────────────────────────── OPNsense ───────────────────────────────┐   ║
║  │  🔒 Routeur / Pare-feu           │ 2 Go RAM · 2 vCPU               │   ║
║  │  DHCP + DNS isolé                │ Plan d'adressage IP sur mesure  │   ║
║  └────────────────────────────────────────────────────────────────────┘   ║
║                                                                          ║
║  ┌──────────────────── Docker (Hébergement) ─────────────────────────┐   ║
║  │  🐳 Conteneurs + Applications    │ 6–8 Go RAM · 4 vCPU             │   ║
║  │  ⚡ Reverse Proxy (Traefik/Nginx) │ Redirige trafic IP/Domaine → app │   ║
║  └────────────────────────────────────────────────────────────────────┘   ║
║                                                                          ║
║  ┌─────────────────── Supervision (Observabilité) ───────────────────┐   ║
║  │  📊 Prometheus + Grafana + Loki  │ 3–4 Go RAM · 2 vCPU             │   ║
║  │  Métriques temps réel · Dashboards santé · Logs centralisés        │   ║
║  └────────────────────────────────────────────────────────────────────┘   ║
║                                                                          ║
║  ┌──────────────────────── Kubernetes / K8s ─────────────────────────┐   ║
║  │  🧠 Node Controller (Control Plane) │ 10–12 Go RAM · 6 vCPU        │   ║
║  │  ⚙️ Worker Node 1 — Exécution apps/pods                            │   ║
║  │  ⚙️ Worker Node 2 — Exécution apps/pods                            │   ║
║  └────────────────────────────────────────────────────────────────────┘   ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

## §5 — Ordre des Tâches à Effectuer (Guide Opérationnel)

| Étape | Tâche | Composant concerné | Priorité |
|---|---|---|---|
| 1️⃣ | Installer Proxmox VE sur le serveur physique (32 threads / 32 Go RAM) | Hôte Proxmox | 🔴 Première étape absolue |
| 2️⃣ | Créer la VM OPNsense, puis configurer DHCP, DNS local, pare-feu et adressage IP sur mesure (avec réservations DHCP statiques pour les machines d'administration, voir §17) | OPNsense | 🔴 Base réseau / sécurité |
| 3️⃣ | Installer Docker et un reverse proxy (Traefik ou Nginx) dans une VM dédiée | Docker Block | 🟡 Hébergement des applications |
| 4️⃣ | Déployer les applications sur Docker et configurer le routage via le reverse proxy | Docker Block | 🟡 Connexion applications ↔ réseau |
| 5️⃣ | Installer et configurer la supervision (Prometheus + Grafana + Loki, voir §16) | Supervision Block | 🟢 Monitoring et observabilité |
| 6️⃣ | Déployer la sécurité de chaque VM : UFW avec restriction par IP et port SSH personnalisé (§17) et CrowdSec (§10) via le template et Ansible | Toutes les VM | 🔴 Durcissement avant la mise en production |
| 7️⃣ | Créer le cluster Kubernetes (1 nœud contrôleur + 2 workers) et orchestrer les pods / applications | K8s Block | ⚠️ Complexité maximale — dernière étape |
| 8️⃣ | Valider l'allocation RAM / vCPU globale (budget ≤ 30 Go / ≈ 14 vCPU) et conserver une marge libre | Audit Budget | ✅ Contrôle final |
| 9️⃣ | Effectuer les tests fonctionnels, les benchmarks de métriques, les scans de ports depuis une IP non autorisée et la documentation système | Tout le système | ✅ Validation opérationnelle |

---

## §6 — Résumé du Positionnement des Ressources

```
Serveur Proxmox (32 Go RAM / 32 threads)
│
├── Hôte Proxmox   →  3–4 Go RAM (~10–12 %)   ✅ Flexibilité hôte garantie
├── OPNsense VM    →  2 Go RAM · 2 vCPU       ✅ Sécurité & réseau
├── Docker         →  6–8 Go RAM · 4 vCPU     ✅ Apps isolées
├── Supervision    →  3–4 Go RAM · 2 vCPU     ✅ Monitoring live
└── K8s Cluster    →  10–12 Go RAM · 6 vCPU   ⚠️ Plus gourmand → nécessite la marge !
                      ─────────────────────────────
                      Total alloué : ~24–30 Go / ≈ 14 vCPU
                      Marge libre  : 2–8 Go ✅ (sauvegarde & flexibilité)
```

---

## §7 — Accès Distant Sécurisé (Cloudflare)

Le serveur n'est disponible que dans mon réseau local : il n'est exposé directement sur aucune adresse publique, et aucun port n'est ouvert sur Internet.

Pour y accéder depuis l'extérieur, j'utilise Cloudflare (Zero Trust / WARP), qui ouvre un accès privé vers le réseau du serveur. Seuls les appareils autorisés dans Cloudflare peuvent atteindre mon LAN, comme s'ils y étaient connectés physiquement.

| Élément | Choix retenu | Intérêt |
|---|---|---|
| Exposition du serveur | Réseau local uniquement | Surface d'attaque minimale |
| Accès depuis l'extérieur | Accès privé Cloudflare | Aucune redirection de port |

> ⚠️ Ce choix a une conséquence sur la résolution DNS des postes connectés via WARP, détaillée dans le retour d'expérience §13.
> ⚠️ Il a aussi une conséquence sur les restrictions par IP (§17) : selon le mode de déploiement, le trafic distant peut arriver au LAN avec l'IP du connecteur Cloudflare et non celle du poste.

---

## §8 — Templates de VM et Déploiement Automatisé

Pour accélérer la création des machines et éviter les erreurs de configuration manuelle, j'ai mis en place des templates de VM. Chaque nouvelle VM est clonée depuis un modèle déjà préparé : la base est identique d'une machine à l'autre, et l'auto-configuration s'applique dès la création.

À chaque création de VM, les éléments suivants sont déployés automatiquement :

| Élément | Rôle |
|---|---|
| **UFW** | Pare-feu applicatif de la VM : politique « tout refuser en entrée », seuls les ports nécessaires sont ouverts, et uniquement depuis les IP autorisées ; SSH sur un port personnalisé (détail au §17) |
| **CrowdSec** (agent + bouncer pare-feu) | Détection des comportements malveillants dans les logs et bannissement automatique des adresses concernées, avec décisions partagées entre les VM (détail au §10) |
| **Agents de supervision** (node_exporter + Grafana Alloy) | Remontée des métriques vers Prometheus et des logs vers Loki dès le premier démarrage (détail au §16) |
| **Mises à jour** (update + upgrade) | Paquets mis à jour à chaque lancement de la VM |

---

## §9 — Mise en place de Terraform et d'Ansible pour l'automatisation de l'infrastructure

Dans le cadre de mon projet Homelab DevOps, j'ai mis en place une chaîne d'automatisation reposant sur Terraform et Ansible afin de gérer l'ensemble de mon infrastructure de manière reproductible, versionnée et évolutive.

### Provisionnement de l'infrastructure avec Terraform

Terraform est utilisé pour créer et gérer automatiquement les machines virtuelles sur l'hyperviseur Proxmox VE. L'ensemble de l'infrastructure est décrit sous forme de code (Infrastructure as Code), ce qui permet de déployer rapidement un environnement complet à partir d'un simple fichier de configuration.

Les ressources déployées incluent notamment :
- Un pare-feu OPNsense.
- Une VM Docker hébergeant Portainer.
- Une VM dédiée à la supervision.
- Un cluster Kubernetes composé d'un nœud de contrôle et de plusieurs nœuds workers.

L'utilisation de Terraform permet de :
- Standardiser le déploiement des machines virtuelles.
- Éviter les erreurs de configuration manuelle.
- Recréer rapidement l'environnement en cas de besoin.
- Centraliser la configuration de l'infrastructure dans un dépôt Git.

### Configuration automatisée avec Ansible

Une fois les machines créées par Terraform, Ansible est utilisé pour effectuer leur configuration automatique. Un inventaire regroupe les différentes machines selon leur rôle :
- Docker
- Supervision
- Kubernetes Control Plane
- Kubernetes Workers

Des playbooks permettent d'automatiser :
- La mise à jour des systèmes Debian.
- L'installation des paquets de base.
- La configuration du fuseau horaire.
- La gestion des utilisateurs.
- La création de répertoires nécessaires aux services.
- Le déploiement de fichiers de configuration à l'aide de templates Jinja2.
- La gestion des redémarrages après mise à jour du système.

### Déploiement de mes projets avec Ansible et Portainer

Je ne me limite pas à la configuration des systèmes : mes projets sont eux aussi intégrés à la chaîne d'automatisation. Sur la VM Docker, Ansible prépare l'environnement (installation de Docker, création des répertoires, dépôt des fichiers Docker Compose et de la configuration) et déploie Portainer, que j'utilise pour administrer mes conteneurs.

Les images de mes projets et leurs fichiers Compose sont ensuite déployés sous forme de stacks dans Portainer, avec les réseaux internes décrits dans le §14. Ansible reste ainsi la source de vérité de l'installation, tandis que Portainer me donne une vue claire de l'état de mes conteneurs et me permet de les gérer au quotidien. Une application n'a donc pas besoin d'être installée à la main : elle est déployée avec le reste de l'infrastructure.

### Bénéfices obtenus

- Infrastructure entièrement documentée sous forme de code.
- Déploiement rapide et reproductible.
- Réduction des tâches manuelles.
- Facilitation de la maintenance et de l'évolution du projet.
- Application des bonnes pratiques DevOps et Infrastructure as Code (IaC).

L'association de Terraform pour le provisionnement et d'Ansible pour la configuration constitue aujourd'hui la base de l'automatisation de mon infrastructure Homelab et me permet de préparer la mise en place de services plus avancés tels que Kubernetes, Docker, la supervision et les pratiques DevOps.

---

## §10 — Politique de Sécurité des VM

### CrowdSec plutôt que Fail2ban

J'avais d'abord retenu Fail2ban. Je le remplace par CrowdSec, pour les raisons suivantes :

| Critère | Fail2ban | CrowdSec | Pourquoi ce changement |
|---|---|---|---|
| Détection | Filtres à base d'expressions régulières, un jail à écrire et à maintenir par service | Scénarios comportementaux et collections prêtes à l'emploi du Hub (SSH, Linux, HTTP, Nginx Proxy Manager…) | Je protège aussi le reverse proxy et les applications, pas seulement SSH |
| Architecture | Tout-en-un, indépendant sur chaque machine | Agent (détecte) · LAPI (décide) · Bouncer (bloque), trois rôles séparés | Un seul point de décision pour toute l'infrastructure |
| Parc de VM | Chaque VM bannit dans son coin | Une IP bannie sur une VM est bloquée sur toutes les autres | Le parc compte désormais 5 VM Debian (Docker, supervision, contrôleur K8s, 2 workers), plus OPNsense |
| Observabilité | Pas de métriques natives | Endpoint Prometheus natif et logs exploitables dans Loki | S'intègre directement à ma supervision (§16) |
| Performance | Écrit en Python | Écrit en Go, plus léger | Je dispose de peu de RAM par VM (voir §2) |
| Renseignement collectif | Aucun | Liste de blocage communautaire (adresses déjà signalées par d'autres utilisateurs) | Protection préventive, en complément de la détection locale |
| Maintenance | Jails et filtres à entretenir à la main | `cscli hub update && cscli hub upgrade`, automatisable avec Ansible | Cohérent avec ma chaîne IaC (§9) |

Les trois arguments que j'avais retenus pour Fail2ban ne tiennent plus :
- **Taille du parc** : avec le cluster Kubernetes et la VM de supervision, le parc a dépassé les « 3 à 4 VM » initiales ; la gestion centralisée devient un vrai gain.
- **Simplicité** : CrowdSec demande plus de configuration au départ, mais celle-ci est écrite une seule fois dans le template et dans un rôle Ansible.
- **Exposition limitée** : le serveur reste accessible uniquement depuis mon réseau (§7), mais cela n'écarte pas le risque venant de l'intérieur (appareil du LAN compromis, poste autorisé via WARP). Je garde donc une défense en profondeur.

> ℹ️ **Contreparties assumées :** un service de plus par VM, et la LAPI centrale devient un composant à superviser. Comme le serveur n'est pas exposé sur Internet, la liste de blocage communautaire a un intérêt limité ; les vrais bénéfices pour moi sont la détection étendue, la centralisation et les métriques.

### Mise en place de CrowdSec

**Topologie retenue :** LAPI centrale sur la VM de supervision, un agent et un bouncer pare-feu sur chaque VM Debian.

1. **Installation :** ajout du dépôt officiel CrowdSec, puis `apt install crowdsec` sur chaque VM ; la VM de supervision héberge la LAPI.
2. **Agents :** sur chaque autre VM, enregistrement auprès de la LAPI (`cscli lapi register --url http://<IP_SUPERVISION>:8080`), puis validation de la machine côté LAPI (`cscli machines validate <nom>`). L'API locale de l'agent est désactivée, la décision restant centralisée.
3. **Bouncers :** `apt install crowdsec-firewall-bouncer-nftables` sur chaque VM ; une clé est générée par VM sur la LAPI (`cscli bouncers add <nom-vm>`) et renseignée dans `/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml` (`api_url` et `api_key`).
4. **Collections :** `crowdsecurity/linux` et `crowdsecurity/sshd` sur toutes les VM, et la collection Nginx Proxy Manager sur la VM Docker avec lecture de ses logs.
5. **Automatisation :** le tout est porté par un rôle Ansible `crowdsec` et appelé par le template de VM (§8).
6. **Métriques :** l'endpoint Prometheus de CrowdSec est collecté par Prometheus (§16) ; les décisions et alertes se consultent avec `cscli decisions list` et `cscli alerts list`.

CrowdSec fonctionne en complément d'UFW (§17) : UFW limite qui peut atteindre quoi, CrowdSec bannit les adresses qui se comportent mal, y compris parmi celles qui sont autorisées à atteindre un service.

### Liste blanche (whitelist)

Toutes les adresses IP de mon réseau sont placées en liste blanche dans CrowdSec. En cas de mauvaise manipulation, je ne risque donc pas de me bannir moi-même de mes propres serveurs. Le fichier est déployé par Ansible dans `/etc/crowdsec/parsers/s02-enrich/` :

```yaml
name: custom/lan-whitelist
description: "Whitelist du réseau local du homelab"
whitelist:
  reason: "Réseau LAN du homelab"
  cidr:
    - "10.20.10.0/24"
```

### Sécurisation de l'accès SSH

Sur tous les serveurs, j'ai configuré la connexion SSH et désactivé l'accès direct au compte root. On se connecte avec un utilisateur standard, puis on élève ses droits si nécessaire. Le port SSH est un port personnalisé (et non le 22), ouvert via UFW uniquement aux IP d'administration (§17).

---

## §11 — Sauvegardes Automatiques sur NAS Externe

J'ai mis en place une sauvegarde automatique des VM vers un NAS externe. Les sauvegardes sont ainsi conservées hors du serveur et restent disponibles en cas de panne ou de mauvaise manipulation.

---

## §12 — Retour d'Expérience : Dépannage DNS sur la VM Portainer

### Contexte

Lors de l'installation d'OPNsense, j'ai configuré le LAN, le DHCP et la passerelle (Gateway) afin de donner accès au routeur. J'ai ensuite créé une VM Portainer, qui n'arrivait pas à communiquer avec le DNS.

### Démarche de diagnostic

| Étape | Action | Résultat | Conclusion |
|---|---|---|---|
| 1️⃣ | Vérification de la configuration d'OPNsense (LAN, DHCP, Gateway, DNS) | Aucune anomalie | Configuration correcte en apparence |
| 2️⃣ | Création d'un conteneur LXC sur le même réseau et test de `ping google.com` | ✅ Le ping aboutit | OPNsense route et résout correctement : le problème ne vient pas d'OPNsense |
| 3️⃣ | Analyse de la VM Portainer, fichier `/etc/resolv.conf` | ❌ Aucun nameserver renseigné | Cause identifiée |

### Cause racine

Le fichier `/etc/resolv.conf` de la VM ne contenait aucun serveur DNS. Sans `nameserver`, la VM ne pouvait pas résoudre les noms de domaine, ce qui l'empêchait de communiquer avec l'extérieur.

### Solution

Ajout d'une ligne `nameserver` dans `/etc/resolv.conf` :

```
nameserver <IP d'OPNsense>    # ou un DNS public, par exemple 1.1.1.1
```

> 💡 **Leçon retenue :** pour isoler une panne réseau, tester depuis un second équipement (ici un conteneur LXC) permet de savoir rapidement si le problème vient du routeur ou de la machine concernée.

---

## §13 — Retour d'Expérience : Reverse Proxy et Résolution DNS

### Contexte et objectif

J'ai déployé l'application Relance via Portainer, ainsi que Nginx Proxy Manager (reverse proxy) sur la VM Docker (10.20.10.11). L'objectif était de rendre l'application accessible par un nom de domaine interne, `http://relance.younes.homelab`, plutôt que par une adresse IP et un numéro de port.

### Symptôme

Depuis mon poste (macOS), le nom de domaine n'était pas résolu : la requête retournait `NXDOMAIN`. Le reverse proxy n'était donc jamais sollicité, puisque le poste ne disposait d'aucune adresse vers laquelle émettre la requête.

### Analyse

J'ai mené le diagnostic en trois temps :

1. **Mauvais service DNS.** J'avais initialement créé l'enregistrement dans Dnsmasq, alors que le service actif sur le port 53 est Unbound. J'ai recréé l'entrée dans *Unbound → Overrides → Host Overrides*. Une interrogation directe d'OPNsense (`nslookup relance.younes.homelab 10.20.10.1`) retournait alors une réponse : la configuration du routeur n'était plus en cause.
2. **Identification du résolveur utilisé par le poste.** Sans préciser de serveur, la requête partait vers `2001:db8:1111::2`, qui ne correspond pas à OPNsense (le LAN ne dispose que d'une adresse IPv4, 10.20.10.1).
3. **Origine du résolveur.** Cette adresse est le résolveur DNS interne de Cloudflare WARP, que j'utilise pour accéder à mon LAN.

### Cause racine

Lorsque WARP est actif, il intercepte l'ensemble des requêtes DNS du poste et les achemine vers son propre résolveur. Celui-ci n'a pas connaissance du domaine privé `younes.homelab`. Les requêtes n'atteignaient donc jamais le DNS d'OPNsense, bien que celui-ci soit correctement configuré.

### Résolution

La correction s'effectue côté Cloudflare : déclarer le domaine `younes.homelab` dans **Local Domain Fallback** (profil des appareils, Zero Trust) avec le serveur DNS `10.20.10.1`, en veillant à ce que le réseau `10.20.10.0/24` soit inclus dans les **Split Tunnels**. Cette règle reste à valider.

En attendant, j'utilise un contournement local sur le poste, dans `/etc/hosts` :

```
10.20.10.11 relance.younes.homelab
```

Il m'a permis de valider le reste de la chaîne : `curl` retourne un code 200 avec l'en-tête `Server: openresty`, ce qui confirme que Nginx Proxy Manager transmet correctement la requête au front (`10.20.10.11:3000`).

### Configuration Nginx Proxy Manager retenue

| Paramètre | Valeur |
|---|---|
| Domain Names | `relance.younes.homelab` |
| Scheme | `http` |
| Forward Hostname / IP | `10.20.10.11` |
| Forward Port | `3000` (port publié du front) |
| Websockets Support | activé |

### Enseignements

- Un enregistrement DNS associe un nom à une adresse IP, jamais à un port. Avec un reverse proxy, il doit pointer vers l'IP du proxy, qui assure ensuite l'aiguillage vers l'application.
- Lorsque plusieurs services DNS sont installés (Unbound, Dnsmasq), il faut vérifier lequel écoute réellement sur le port 53 avant de créer un enregistrement.
- Avec Cloudflare WARP actif, le poste n'utilise plus le DNS du réseau local : les domaines privés doivent être déclarés dans Local Domain Fallback.
- `nslookup` ignore `/etc/hosts`, contrairement au navigateur et à `curl`. Pour valider le DNS, il faut utiliser `nslookup`.
- Interroger directement le serveur DNS (`nslookup nom 10.20.10.1`) permet de déterminer si la panne provient du serveur ou du poste client.

---

## §14 — Segmentation du réseau Docker

### Objectif

J'ai mis en place des réseaux internes dans Docker pour cloisonner mes services. Chaque composant n'est accessible que par ceux qui en ont réellement besoin, et ma base de données n'est à aucun moment exposée vers l'extérieur.

### Principe de fonctionnement

J'ai organisé l'architecture comme une chaîne d'accès à sens unique, où chaque maillon ne dialogue qu'avec son voisin direct :

| Composant | Interlocuteur autorisé | Rôle dans l'architecture |
|---|---|---|
| Reverse proxy | Conteneurs front | Point d'entrée unique : seul composant à recevoir les requêtes |
| Front | API | Seul composant habilité à solliciter l'API |
| API | Base de données | Seul composant autorisé à interroger la BDD |
| Base de données | API uniquement | Aucun port publié : invisible depuis l'extérieur |

```
LAN ──► [ Reverse proxy ] ──► [ Front ] ──► [ API ] ──► [ BDD ]
```

### Mécanisme

- J'ai créé un réseau Docker dédié pour chaque liaison (proxy ↔ front, front ↔ API, API ↔ BDD).
- Deux conteneurs ne peuvent communiquer que s'ils partagent un réseau ; à défaut, ils s'ignorent mutuellement.
- Seul mon reverse proxy publie des ports. Les autres services échangent entre eux via leur nom de service, résolu par le DNS interne de Docker.
- Je ne rattache une application à un réseau que si elle a un besoin avéré du service concerné.

### Exemple de configuration (Docker Compose)

```yaml
networks:
  proxy_net:        # reverse proxy ↔ front
  api_net:          # front ↔ API
    internal: true
  db_net:           # API ↔ base de données
    internal: true

services:
  reverse-proxy:
    ports: ["80:80", "443:443"]     # seul service qui publie des ports
    networks: [proxy_net]

  front:
    networks: [proxy_net, api_net]

  api:
    networks: [api_net, db_net]

  db:
    networks: [db_net]              # aucun port publié
```

> 💡 **Leçon retenue :** un conteneur ne perçoit que les réseaux qui lui sont attribués. Cette approche limite la surface d'exposition et garantit que ma base de données reste isolée.

---

## §15 — Chiffrement HTTPS avec mkcert

### Objectif

J'ai doté mes applications web auto-hébergées d'un certificat SSL, afin de chiffrer les échanges au sein de mon réseau local.

### Pourquoi j'ai choisi mkcert

Mon choix s'explique par le contexte d'usage de mon infrastructure :

| Critère | Ma situation | Conséquence |
|---|---|---|
| Utilisateurs | Je suis le seul administrateur du serveur | Pas besoin d'une infrastructure de certificats complexe |
| Exposition | Je ne prévois pas de publier mes applications sur Internet | Pas de nom de domaine public ni de validation externe nécessaires |
| Mise en œuvre | Outil simple, sans service tiers | Génération rapide de certificats de confiance en local |

mkcert répond donc à mon besoin sans dépendance externe, avec un niveau de complexité adapté à un usage strictement privé.

### Limite

Mes certificats ne sont reconnus que sur les appareils où l'autorité de certification mkcert est installée. Si je devais un jour publier une application sur Internet, je basculerais vers une solution adaptée à l'exposition publique, comme Let's Encrypt.

---

## §16 — Mise en place de la Supervision (Prometheus, Grafana, Loki)

### Objectif
Disposer d'une vue complète de la santé de l'infrastructure : métriques (Prometheus), dashboards (Grafana) et logs centralisés (Loki), hébergés sur la VM de supervision (3–4 Go de RAM · 2 vCPU, voir §2).

### Architecture
```
 Toutes les VM                          VM Supervision
┌──────────────────────┐   scrape    ┌──────────────────────────────┐
│ node_exporter  :9100 │◄────────────│ Prometheus :9090             │
│ (cAdvisor :8081)     │             │         │                    │
│ Grafana Alloy        │───push─────►│ Loki :3100                   │
│ (logs journald,      │             │         │                    │
│  CrowdSec…)          │             │         ▼                    │
└──────────────────────┘             │ Grafana :3000 (dashboards)   │
                                     │ CrowdSec LAPI :8080          │
                                     └──────────────────────────────┘
```
- Prometheus interroge (pull) les exporters de chaque machine.
- Loki reçoit (push) les logs envoyés par Grafana Alloy, qui remplace Promtail, arrivé en fin de vie.
- Grafana lit les deux sources de données.

### Sources collectées

| Source | Outil | Port | Contenu |
|---|---|---|---|
| Toutes les VM Debian | node_exporter | 9100 | CPU, RAM, disque, réseau |
| OPNsense | plugin os-node_exporter | 9100 | Santé du routeur / pare-feu |
| VM Docker | cAdvisor | 8081 | Consommation par conteneur |
| Hôte Proxmox (optionnel) | prometheus-pve-exporter | 9221 | État des VM et du stockage |
| CrowdSec (LAPI) | endpoint Prometheus natif | 6060 | Alertes, décisions, bans |
| Logs de toutes les VM | Grafana Alloy → Loki | 3100 | Journal systemd, logs CrowdSec |
| Cluster K8s | node_exporter sur les 3 VM, puis kube-state-metrics en phase 2 | 9100 | Santé des nœuds, puis état des pods |

### Déploiement sur la VM de supervision
La pile (Prometheus, Loki, Grafana) est déployée avec Ansible via Docker Compose, en `network_mode: host` : les ports sont ouverts directement sur la VM et filtrés par UFW (voir le piège Docker/UFW au §17). Les versions des images sont à épingler en production.

### Configuration
- **Prometheus** : intervalle de collecte de 30 s, rétention de 30 jours. Cibles : OPNsense, VM Docker, VM supervision, contrôleur K8s et workers (port 9100), cAdvisor (10.20.10.11:8081) et CrowdSec (localhost:6060).
- **Loki** : stockage sur disque, rétention de 30 jours (compactor activé) pour borner l'espace utilisé.
- **Grafana** : les sources Prometheus (par défaut) et Loki sont déclarées par provisioning, donc reproductibles avec Ansible.
- **Dashboards à importer** : Node Exporter Full (ID 1860) pour les serveurs, puis cAdvisor / Docker, Kubernetes et CrowdSec.

### Agents sur chaque VM (via le template et Ansible)
- node_exporter installé en service systemd natif (donc filtré par UFW).
- Grafana Alloy envoie le journal systemd et les logs CrowdSec vers Loki :

```
// /etc/alloy/config.alloy
loki.source.journal "systemd" {
  forward_to = [loki.write.supervision.receiver]
  labels     = { job = "systemd-journal" }
}

local.file_match "crowdsec" {
  path_targets = [{ "__path__" = "/var/log/crowdsec.log", "job" = "crowdsec" }]
}

loki.source.file "crowdsec" {
  targets    = local.file_match.crowdsec.targets
  forward_to = [loki.write.supervision.receiver]
}

loki.write "supervision" {
  endpoint {
    url = "http://<IP_SUPERVISION>:3100/loki/api/v1/push"
  }
}
```
L'utilisateur du service Alloy doit appartenir au groupe `systemd-journal` pour lire le journal.

### Validation

| Test | Commande / action | Résultat attendu |
|---|---|---|
| Prometheus prêt | `curl http://localhost:9090/-/ready` | Réponse positive |
| Cibles collectées | Prometheus → Status → Targets | Toutes les cibles UP |
| Loki prêt | `curl http://localhost:3100/ready` | `ready` |
| Logs reçus | Grafana → Explore → Loki → `{job="systemd-journal"}` | Logs de plusieurs VM |
| Dashboards | Import du dashboard 1860 | Métriques de toutes les VM |

### Alertes de base
Alertes Grafana sur : machine injoignable (cible Prometheus DOWN), disque rempli à plus de 85 %, RAM saturée, et pic d'alertes CrowdSec.

---

## §17 — UFW et Restriction d'Accès par IP

### Objectif
Chaque VM n'ouvre que les ports dont elle a besoin, et chaque port n'est accessible que depuis les IP qui en ont l'usage. Les interfaces d'administration (SSH, Portainer, Grafana, Prometheus, Nginx Proxy Manager) ne sont jamais ouvertes à tout le LAN.

### Prérequis : des IP stables
Réservations DHCP statiques dans OPNsense pour : OPNsense (10.20.10.1), VM Docker (10.20.10.11), poste d'administration (qui sert aussi à Ansible), VM supervision et VM Kubernetes.

### Politique par défaut (appliquée par le template)
```bash
ufw default deny incoming
ufw default allow outgoing

# Règle SSH AVANT d'activer UFW, sinon risque de perdre l'accès
ufw allow from <IP_ADMIN> to any port <PORT_SSH> proto tcp comment 'SSH admin + Ansible'
ufw allow from <IP_SUPERVISION> to any port 9100 proto tcp comment 'node_exporter'

ufw enable
```
Les règles propres à chaque rôle sont ajoutées ensuite par Ansible (module `community.general.ufw`).

### Changer le port SSH par défaut
Pour plus de sécurité, le port SSH n'est plus le 22 : il passe sur un port personnalisé `<PORT_SSH>` (par exemple 2222, ou un port plus élevé non utilisé), ce qui écarte les scans et bots automatiques qui ciblent le port 22. Ce n'est pas une protection à elle seule : elle complète UFW, la restriction par IP, la désactivation de root et CrowdSec.

1. Dans `/etc/ssh/sshd_config` (déployé via le template et Ansible) : `Port <PORT_SSH>`.
2. Ouvrir le nouveau port dans UFW **avant** de redémarrer SSH, puis tester la connexion sur le nouveau port dans une seconde session, avant de fermer la première.
3. Supprimer l'ancienne règle du port 22 une fois le test validé.
4. Mettre à jour Ansible (`ansible_port=<PORT_SSH>` dans l'inventaire) et la config SSH du poste admin (`Port <PORT_SSH>` dans `~/.ssh/config`).
5. CrowdSec (collection `sshd`) lit les logs et fonctionne quel que soit le port.

### Matrice des accès

| VM | Port(s) | Service | Autorisé depuis |
|---|---|---|---|
| **Toutes** | `<PORT_SSH>` | SSH | IP admin |
| **Toutes** | 9100 | node_exporter | IP supervision |
| **Docker** | 80, 443 | Reverse proxy | LAN |
| **Docker** | 81, 9443 | NPM admin, Portainer | IP admin |
| **Docker** | 8081 | cAdvisor | IP supervision |
| **Supervision** | 3000, 9090 | Grafana, Prometheus | IP admin |
| **Supervision** | 3100, 8080 | Loki, CrowdSec LAPI | LAN |
| **Kubernetes** | 6443 | API Kubernetes | IP admin + workers |
| **Kubernetes** | 10250, 2379-2380 | kubelet, etcd | Nœuds du cluster uniquement |
| **Kubernetes** | 30000-32767 | NodePorts | Reverse proxy |



### Autres niveaux de restriction
- **Nginx Proxy Manager** : une Access List « Admin » (seule `<IP_ADMIN>` autorisée) associée aux hôtes sensibles (Grafana, Portainer, NPM).
- **OPNsense** : un alias `ADMIN_HOSTS` (IP admin, Ansible inclus) sert de source pour les ports d'administration. UFW n'existe pas sur FreeBSD, le pare-feu d'OPNsense joue ce rôle.
- **Cloudflare (§7)** : selon le mode de déploiement, le trafic distant peut arriver avec l'IP du connecteur. Le contrôle se fait alors côté Zero Trust (appareils et identités), en plus des règles par IP. À vérifier par un test réel depuis l'extérieur.

### Cohérence avec CrowdSec
- Le LAN 10.20.10.0/24 est en liste blanche CrowdSec (§10) : aucun risque de se bannir depuis une IP autorisée.
- UFW limite qui peut atteindre quoi ; CrowdSec bannit les IP qui, même autorisées, ont un comportement malveillant (ex. force brute).
- Ordre de déploiement : règles UFW, puis CrowdSec, puis validation par scan de ports et tests de connexion.

💡 **Leçon retenue** : un pare-feu applicatif ne protège que s'il est vérifié de l'extérieur. Après chaque changement, tester depuis une IP non autorisée, en particulier pour les ports publiés par Docker.


# §18 — Installation de Suricata sur OPNsense

J'ai installé **Suricata** sur OPNsense pour renforcer la sécurité de mon réseau. Il analyse le trafic réseau pour détecter les activités suspectes et les menaces potentielles.

J'ai activé plusieurs catégories de règles pour améliorer la détection :

* **`emerging-scan.rules`** : détecte les scans de ports et les tentatives de reconnaissance du réseau.
* **`attempted-recon`** : permet de repérer des activités suspectes liées à la reconnaissance du réseau.
* **`emerging-malware.rules`** : détecte des communications associées à des logiciels malveillants.
* **`botcc.rules`** : repère les communications avec des serveurs connus pour contrôler des machines infectées.
* **`compromised.rules`** : détecte les communications avec des adresses ou des systèmes identifiés comme compromis.
* **`drop.rules`** : contient des règles destinées à repérer et, selon la configuration, bloquer certains trafics considérés comme malveillants.

## Objectif

Avec Suricata, je peux mieux surveiller le trafic de mon réseau et repérer certaines menaces, comme les scans de ports, les malwares et les communications suspectes. 

Cette installation complète la protection déjà mise en place avec le pare-feu OPNsense, les restrictions d'accès et CrowdSec sur mes machines virtuelles.

> **Attention :** la détection ne signifie pas forcément que le trafic est bloqué. Le blocage dépend du mode de fonctionnement de Suricata et de la configuration des règles.
