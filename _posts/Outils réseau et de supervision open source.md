Ce document complète la liste des outils d'analyse réseau (Wireshark, Nmap, Zeek, Suricata, Scapy, etc.) avec un focus sur la **supervision réseau** (monitoring, alerting, métrologie).

---

## 1. Supervision / Monitoring d'infrastructure

### Nagios Core

- Référence historique de la supervision open source
- Vérifie la disponibilité des hôtes/services (ping, ports, plugins custom NRPE)
- Système de plugins extensible (des milliers de plugins communautaires)
- Alerting par mail/SMS/scripts, gestion d'escalade
- Interface web basique ; souvent couplé à des surcouches (Centreon, Icinga Web) pour une meilleure UX

### Icinga 2

- Fork de Nagios, plus moderne (API REST, config déclarative, clustering natif)
- Compatible avec les plugins Nagios existants (NRPE, check_*)
- Icinga Web 2 offre un dashboard bien plus soigné que Nagios de base
- Bonne scalabilité pour de grosses infrastructures distribuées

### Zabbix

- Solution tout-en-un : découverte automatique, collecte de métriques (agents ou SNMP), triggers, dashboards
- Base de données intégrée (PostgreSQL/MySQL) pour l'historique
- Agents légers (Zabbix Agent 2) déployables sur Linux/Windows
- Très utilisé en entreprise pour la supervision de parcs serveurs + réseau

### LibreNMS

- Spécialisé réseau, auto-discovery via SNMP, CDP, LLDP, OSPF, BGP
- Cartographie topologique automatique
- Alerting intégré et bonne API
- Fork actif de feu Observium (dont la version communautaire est figée)

### Cacti

- Plus ancien, orienté graphes RRDtool (bande passante, charge CPU, etc.)
- Interface un peu datée mais toujours fonctionnelle pour du reporting SNMP simple

### Checkmk (édition Raw/CE)

- Basé sur Nagios en interne mais expérience bien plus moderne
- Auto-découverte de services très poussée, bon rapport simplicité/puissance

---

## 2. Métriques temps réel et visualisation

### Prometheus + Grafana

- **Prometheus** : base de données de séries temporelles (TSDB), modèle pull via exporters (node_exporter, snmp_exporter, blackbox_exporter pour tester dispo réseau)
- **Grafana** : dashboards visuels connectables à Prometheus, InfluxDB, Zabbix, Elasticsearch, etc.
- Duo devenu un standard pour le monitoring cloud-native et Kubernetes
- Alerting via Alertmanager (règles, routage, déduplication)

### Netdata

- Monitoring temps réel ultra granulaire (par seconde), zéro config au départ
- Dashboard web auto-généré très visuel, faible empreinte
- Bon pour du diagnostic instantané sur un hôte donné, moins pour de l'historique long terme

### Munin

- Simple, basé sur RRDtool comme Cacti, graphes générés périodiquement (cron)
- Léger, facile à étendre avec des plugins Perl/Python custom

### InfluxDB + Telegraf

- Telegraf collecte les métriques (système, réseau, services) et les pousse vers InfluxDB
- Souvent utilisé en remplacement de Prometheus quand on préfère un modèle push

---

## 3. Analyse de flux réseau (NetFlow / sFlow / IPFIX)

### nfdump / NfSen

- `nfdump` : collecte et interroge des données NetFlow/IPFIX en ligne de commande
- **NfSen** : interface web au-dessus de nfdump pour visualiser les flux, détecter des pics de trafic anormaux

### pmacct (Promiscuous Monitoring & Accounting)

- Collecte NetFlow/sFlow/IPFIX/BGP, exporte vers des bases SQL ou des outils de visualisation
- Très flexible pour construire des pipelines de collecte custom

### Elastiflow

- Pipeline clé en main NetFlow/sFlow → Logstash → Elasticsearch → Kibana
- Bon compromis visuel pour la détection d'anomalies de trafic à grande échelle

---

## 4. Détection d'intrusion réseau (NIDS/NSM) — complément à Zeek/Suricata

### Security Onion

- Distribution Linux complète clé en main qui **package Zeek, Suricata, Wazuh, Elasticsearch, Kibana** et des outils d'investigation (CyberChef, Arkime)
- Pensé pour monter un SOC/NSM complet rapidement en labo ou en prod

### Arkime (ex-Moloch)

- Capture et indexation full-packet à grande échelle, recherche full-text dans des pcaps volumineux
- Complémentaire à Zeek/Suricata : eux génèrent des métadonnées/alertes, Arkime permet de retrouver et rejouer le paquet brut correspondant

### Wazuh

- Plateforme XDR/SIEM open source (fork d'OSSEC) : HIDS + analyse de logs + intégration réseau (Suricata, osquery)
- Bon pour corréler des événements hôte et réseau dans un même dashboard

---

## 5. Gestion de logs et corrélation (SIEM-like)

### ELK / Elastic Stack (Elasticsearch, Logstash, Kibana) + Beats

- Ingestion, indexation et recherche de logs à grande échelle
- Filebeat/Packetbeat/Metricbeat pour envoyer données système, réseau et métriques
- Base de nombreuses solutions de supervision réseau (dont Elastiflow, Security Onion)

### Graylog

- Alternative à ELK plus simple à opérer, centré sur la gestion de logs et l'alerting
- Bon support syslog natif, pratique pour centraliser les logs d'équipements réseau (firewalls, switches)

---

## 6. Cartographie et découverte réseau

### Netdisco

- Inventaire et cartographie automatique de switches/routeurs via SNMP, CDP, LLDP
- Utile pour la gestion de parc réseau (ports, VLANs, adresses MAC)

### NetBox

- Pas un outil de supervision au sens strict, mais IPAM/DCIM open source de référence
- Documente l'infrastructure (IP, VLANs, câblage, racks) — souvent couplé à LibreNMS/Zabbix via API pour garder l'inventaire synchronisé

---

## Récapitulatif par cas d'usage

|Besoin|Outils recommandés|
|---|---|
|Dispo serveurs/services (up/down)|Nagios, Icinga 2, Checkmk|
|Supervision réseau SNMP + topologie|LibreNMS, Cacti, Netdisco|
|Métriques temps réel + dashboards modernes|Prometheus + Grafana, Netdata|
|Analyse de flux (qui parle à qui, volumétrie)|nfdump/NfSen, pmacct, Elastiflow|
|Détection d'intrusion réseau|Zeek, Suricata, Security Onion|
|Investigation pcap à grande échelle|Arkime|
|Centralisation de logs / SIEM léger|Graylog, ELK, Wazuh|
|Inventaire / documentation réseau|NetBox|