## Multi-Site Infrastructure VPN
### Connecting a monitoring site to an infrastructure site over Site-to-Site VPN

> **Version 2 of my Hodan School Site-to-Site VPN.** In 2021, I connected Hodan Secondary School's
> on-premises network to AWS over a static VPN and demonstrated it with a shared EFS file system
> visible on both sides. This v2 rebuild keeps the same hybrid foundation but modernises the whole
> stack — **strongSwan** as the on-prem router, **Terraform + Terragrunt** for the infrastructure,
> a **Transit Gateway** hub, and an **on-prem Zabbix server monitoring containerised academic
> workloads running in AWS**.

---

## Table of Contents

- [Multi-Site Infrastructure VPN](#multi-site-infrastructure-vpn)
  - [Connecting a monitoring site to an infrastructure site over Site-to-Site VPN](#connecting-a-monitoring-site-to-an-infrastructure-site-over-site-to-site-vpn)
- [Table of Contents](#table-of-contents)
- [Why a version 2](#why-a-version-2)
- [What v1 was (2021)](#what-v1-was-2021)
- [What v2 is (2026)](#what-v2-is-2026)
- [The scenario](#the-scenario)
- [Architecture](#architecture)
- [Why monitoring instead of file sharing](#why-monitoring-instead-of-file-sharing)
- [Stack](#stack)
- [How the monitoring flows across the VPN](#how-the-monitoring-flows-across-the-vpn)
- [Why a Transit Gateway here](#why-a-transit-gateway-here)
- [Tunnels and failover](#tunnels-and-failover)
- [Key concepts I locked down building this](#key-concepts-i-locked-down-building-this)
- [Repository structure](#repository-structure)
- [How to deploy](#how-to-deploy)
- [Walkthrough (manual steps)](#walkthrough-manual-steps)
- [Diagram](#diagram)
- [What I'd do next](#what-id-do-next)

---

## Why a version 2

The 2021 project did its job, it proved I could stand up a hybrid network and move data between a
school's on-prem site and AWS. But it was a product of its time: consumer networking hardware, a
click-ops CloudFormation deploy, a single region, and a file share as the "look, it works on both
sides" demo.

Coming back to it with everything I've learned since, I wanted to rebuild it the way I'd approach it
on a production engagement today, infrastructure as code that's region-aware, a software router I
fully control and can automate, a Transit Gateway hub so the design scales to many VPCs, and a
genuinely useful cross-site workload: **unified monitoring** rather than a file share. Same school,
same hybrid-connectivity foundation, a much more capable build on top.

---

## What v1 was (2021)

- **Scenario:** connect Hodan School's on-prem network to AWS and let staff share files across the
  link.
- **On-prem router:** Ubiquiti **Unifi USG**, behind a Virgin Media fibre modem switched to bridged
  mode.
- **AWS side:** provisioned with **CloudFormation**; two VPCs joined by **VPC peering**; EC2
  instances across two AZs.
- **VPN:** a **static** Site-to-Site VPN, single tunnel (the consumer kit didn't support dual
  tunnels to the same destination).
- **The demo:** an **EFS** file system mounted on both an AWS EC2 instance and an on-prem Ubuntu
  laptop, a file created on one side appeared on the other, proving end-to-end connectivity.

It still lives on the repo's main page as reference.

---

## What v2 is (2026)

Same hybrid foundation, rebuilt and extended:

| Aspect | v1 (2021) | v2 (2026) |
|---|---|---|
| Scenario | File sharing for staff | **Monitoring** containerised academic workloads |
| On-prem router | Unifi USG (hardware) | **strongSwan** on Ubuntu (software, IaC-friendly) |
| IaC | CloudFormation (click-to-deploy) | **Terraform + Terragrunt** |
| Regions | Single region | **Two regions** (Terragrunt-managed) |
| AWS-side hub | VPC peering | **Transit Gateway** (hub-and-spoke, multi-VPC) |
| Cross-site "proof" | EFS file share visible both sides | **Monitoring data synced** to one on-prem dashboard |
| Tunnels | Single (hardware limit) | **Dual-tunnel** (Tunnel 1 preferred, Tunnel 2 backup) |

---

## The scenario

Hodan School has moved its academic systems, student portal, results service, library catalogue,
internal APIs into AWS. The school's IT team still works from the on-prem data centre and needs
**one place to watch the health of everything**: the on-prem infrastructure *and* the academic
services now running in the cloud.

Rather than log into AWS consoles or stand up a second monitoring system, the IT staff run a single
**Zabbix server on-premises**. It monitors the local network as before and across the
Site-to-Site VPN, also collects metrics from the AWS workloads via **Zabbix proxies** deployed
inside the AWS VPCs. One dashboard, on-prem, covering both worlds.

---

## Architecture

**On-premises — `Hodan-DC` (simulated in `eu-north-1` for the lab)**

- A **strongSwan** router (Ubuntu) terminates the IPSec VPN — replacing the v1 Unifi USG.
- The **Zabbix server** (with its database and web UI) runs on-prem; this is the single source of
  truth and the dashboard the IT staff use.
- Staff workstations reach the dashboards over the LAN.

**AWS — `Hodan-AWS-infra` (`us-west-2`, Oregon)**

- A **Transit Gateway** (`tgw-…`) is the AWS-side hub. Its route table carries the routes between
  the VPN attachment and the VPCs (TGW CIDR space `10.0.0.0/16`).
- A dedicated monitoring VPC, **`HodaN102-vpc` (`10.2.0.0/16`)**, runs the **Zabbix proxy** on a
  `t3.small` Ubuntu 22.04 instance in a private subnet (`hodan102-private-subnet-az1`).
- Additional workload VPCs (e.g. **`HodaN100`**, **`HodaN101`**) hold the monitored academic
  instances; they attach to the same TGW.
- Access is via **Session Manager** — no inbound SSH. An IAM **PowerUserAccess** boundary scopes the
  deploy identity.

**The link**

- A **static IPSec Site-to-Site VPN** between the strongSwan router and the TGW, with **two
  tunnels** (Tunnel 1 preferred, Tunnel 2 backup) and routing configured both ways so the proxies
  can reach the on-prem server and vice versa.

---

## Why monitoring instead of file sharing

In v1 I used EFS to make the same files appear on both sides a simple, visual way to prove the
tunnel carried real traffic. In v2 the cross-site workload is **observability data**: metrics from
the AWS workloads flow across the VPN and surface on the on-prem Zabbix dashboard, right alongside
the on-prem metrics.

It's the same underlying idea — *data that originates on one side is usable on the other* — but a far
more realistic enterprise use case. An organisation keeping its monitoring on-prem while its
workloads move to the cloud is exactly the kind of hybrid requirement these VPNs exist to serve.

---

## Stack

| Layer | Tooling |
|---|---|
| IaC | Terraform (`~> 1.6`), AWS provider `~> 5.0` |
| Multi-region orchestration | Terragrunt (state isolation + per-region provider generation) |
| On-prem VPN router | strongSwan (IPSec) on Ubuntu 22.04, VTI interfaces |
| AWS-side hub | AWS Transit Gateway |
| Monitoring | Zabbix server (on-prem) + Zabbix proxy (in-VPC) |
| Config management | Ansible (strongSwan + Zabbix bootstrap) |
| Access | AWS Systems Manager Session Manager (no inbound SSH) |
| Regions | AWS side `us-west-2`; on-prem simulated in `eu-north-1` |

---

## How the monitoring flows across the VPN

```
[ AWS workloads (agents) ]  -->  [ Zabbix proxy (in HodaN102-vpc) ]  --batched/buffered-->
                                                  |
                                       ( TGW  -->  IPSec tunnel )
                                                  |
                                                  v
                                   [ strongSwan router (on-prem) ]
                                                  |
                                                  v
                                   [ Zabbix server + DB + web UI ]
                                                  |
                                                  v
                                   [ Hodan IT staff dashboard ]
```

1. **Zabbix agents** on the AWS workloads collect metrics locally.
2. They report to the **in-VPC Zabbix proxy** — not directly across the VPN. The proxy is the key
   design choice: it collects locally, **batches**, and **buffers** if the tunnel is briefly down,
   so no metrics are lost during a blip.
3. The proxy forwards the batched data through the **TGW and across the IPSec tunnel** to the on-prem
   **Zabbix server**.
4. The server stores it and renders it on the **dashboard** the IT staff watch on-prem.

For the proxy and the server to talk over the VPN, the four fundamentals from v1 still apply: the
**tunnel is UP**, **routing exists in both directions**, **security groups/firewall allow the
traffic**, and **`source_dest_check = false`** on the router. CIDRs must not overlap.

---

## Why a Transit Gateway here

v1 used **VPC peering**, which is fine for two VPCs but doesn't scale — peering is non-transitive, so
N fully-connected VPCs need N×(N-1)/2 connections. v2 uses a **Transit Gateway** as the hub: every
VPC (the monitoring VPC and each workload VPC) attaches once, and the TGW routes between them and the
VPN. Adding another academic-service VPC later is one new attachment, not a mesh of new peerings. The
VPN terminates on the TGW, so all proxy traffic converges at the hub before crossing the tunnel.

(Trade-off worth noting: a TGW does **not** propagate routes into VPC route tables the way a VGW
does, so the VPC-side routes to the on-prem CIDR are added explicitly.)

---

## Tunnels and failover

The VPN runs **two tunnels** — **Tunnel 1 (preferred)** and **Tunnel 2 (backup)** — each with its own
AWS outside IP and inside `/30`. Because this is a **static** VPN, the AWS→on-prem direction
fails over automatically between tunnels, but on-prem→AWS failover is governed by the router's static
routing. True automatic two-way failover would need a **dynamic/BGP** VPN; the dual-tunnel static
setup here gives AWS-side redundancy and is sufficient for the monitoring workload.

---

## Key concepts I locked down building this

Rebuilding the project pushed me to properly understand the networking underneath, not just click
through it:

- **Static vs dynamic (BGP) VPN** — both v1 and v2 are static. Static is simple and works on almost
  any router; dynamic/BGP is what you reach for when you need automatic, two-way failover and
  multiple active links.
- **VGW vs TGW** — a VGW attaches to one VPC and can propagate routes into VPC route tables; a TGW is
  the multi-VPC hub-and-spoke option (no propagation into VPC route tables, but transitive routing
  across many VPCs). With several monitored VPCs, the TGW is the right call.
- **Single vs dual tunnel** — a single tunnel is already bidirectional and is fine for monitoring
  traffic; the second tunnel adds AWS-side redundancy.
- **Route tables & longest-prefix matching** — the most specific route wins; static beats
  propagated; routing must exist both ways or TCP silently fails.
- **The Zabbix proxy pattern** — the single most important scaling decision here. The proxy keeps
  monitoring traffic light across the VPN and tolerates tunnel drops by buffering, which is what makes
  a monitoring-over-VPN design production-viable.

---

## Repository structure

```
Site-to-Site/
├── README.md                     # repo landing — the original 2021 project (kept as-is)
├── EFS-S2S-diagram.jpg           # original Hodan School diagram
│
└── zabbix-s2s-vpn/               # ← this folder: the v2 build
    ├── README.md                 # this file
    ├── infra/
    │   ├── modules/              # reusable TF modules (vpc, s2s, tgw, zabbix, ...)
    │   ├── roots/                # thin roots composing the modules
    │   │   ├── aws-side/
    │   │   └── onprem-side/
    │   └── terragrunt/           # region-keyed leaves + shared root.hcl
    │       ├── root.hcl
    │       ├── us-west-2/aws-side/terragrunt.hcl
    │       └── eu-north-1/onprem-side/terragrunt.hcl
    ├── ansible/                  # strongSwan + Zabbix bootstrap
    └── diagrams/                 # v2 architecture diagram
```

The repo's main page keeps the original project untouched; everything new lives under
`zabbix-s2s-vpn/`.

---

## How to deploy

```bash
# From zabbix-s2s-vpn/infra/terragrunt
# Apply both sides in dependency order (AWS side first, then on-prem):
terragrunt run-all apply

# Or one side at a time:
cd us-west-2/aws-side     && terragrunt apply
cd ../../eu-north-1/onprem-side && terragrunt apply
```

The VPN gateway objects (TGW VPN attachment / Customer Gateway / VPN connection) and the strongSwan +
Zabbix configuration are completed per the walkthrough below. Cleanup tears down the VPN objects
first, then `terragrunt destroy`.

---

## Walkthrough (manual steps)

Most of the infrastructure is provisioned by the Terraform/Terragrunt code in
[How to deploy](#how-to-deploy). The remaining hands-on parts, creating the VPN gateway objects,
bringing up the strongSwan tunnels, registering the Zabbix proxy, and verifying the monitoring sync
are documented step by step:

**➡️ For the walkthrough steps, [click here](./WALKTHROUGH.md).**

It covers, stage by stage: Customer Gateway → TGW VPN attachment → strongSwan tunnel bring-up →
routing both sides → Zabbix proxy deploy & registration → end-to-end monitoring verification →
cleanup.

---

## Diagram

The v2 architecture diagram lives in `diagrams/`. **Note:** the current draft
(`HoDaN-VPN-Demo - 1`) is a work-in-progress placeholder, it still shows a FortiGate 200F router and
a CFN-deployed proxy. This build actually uses **strongSwan** and **Terraform/Terragrunt**, so the
router icon and the "CFN" label will be updated in the next revision. The TGW hub, dual tunnels, and
Zabbix-proxy-per-VPC structure shown there are accurate.

---

## What I'd do next

- Add **alerting** (Zabbix → email/Slack) so the IT team is paged on academic-service issues, not
  just dashboards.
- Evaluate a **dynamic/BGP** VPN for true two-way automatic failover.
- Onboard further academic-service VPCs as new TGW attachments as the estate grows.

---

*v1 (2021): Hodan School S2S VPN with Unifi USG, CloudFormation and EFS file sharing.
v2 (2026): rebuilt with strongSwan, Terraform/Terragrunt, a Transit Gateway hub, and on-prem Zabbix
monitoring of AWS workloads.*
