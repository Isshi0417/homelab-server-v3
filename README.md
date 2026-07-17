# Enterprice Private Cloud & IaC Homelab (v3)

A fully automated private cloud environment deployed from bare metal. This project manages the lifecycle of network and server resources, from hardware preparation to multi-tenant container deployments, using Infrastructure as Code (IaC) and configuration management.

---

## 🗺️ System Architecture

```mermaid
graph TD
    subgraph Physical Host [Host: hypervisor.lab.local - 172.30.1.200]
        HostOS[AlmaLinux 10 / Cockpit / KVM]

        subgraph Virtual Network [Bridge Network: br0 - 172.30.1.0/24]
            VM1[freeipa.lab.local<br>AlmaLinux 10]
            VM2[portfolio.lab.local<br>Debian 12]
            VM3[minecraft.lab.local<br>Debian 12]
            VM4[navidrome.lab.local<br>Debian 12]
        end
    end

    subgraph Identity & Core Services
        VM1 -->|Provides| LDAP[Directory Service]
        VM1 -->|Provides| Kerberos[Auth Realm]
        VM1 -->|Provides| BIND[DNS / BINDS]
        VM2 & VM3 & VM4 -->|DNS Resolution| VM1
    end

    subgraph Containerized Workloads (Podman)
        VM2 -->|Runs| Nginx[Nginx Portal Website]
        VM2 -->|Runs| Prom[Prometheus TSDB]
        VM2 -->|Runs| Grafana[Grafana Dashboard]

        VM3 -->|Runs| Minecraft[Fabric Minecraft Server]

        VM4 -->|Runs| ND[Navidrome Server]
        VM4 -->|Mounts| GDrive[rclone Google Drive FUSE]
    end

    subgraph Secure Ingress & Tunnels
        VM2 -->|Exposes Nginx / Grafana| CF[Cloudflared Tunnel]
        VM3 -->|Exposes Port 25565| PI[Playit.gg Tunnel]
    end

    subgraph Cluster Telemetry
        HostOS & VM1 & VM2 & VM3 & VM4 -->|Node Exporter:9100| Prom
    end

    CF -->|Secure HTTPS| PublicInternet((Public Internet))
    PI -->|Secure UDP/TCP| Gamers((Minecraft Client))
```
