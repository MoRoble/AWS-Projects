# Walkthrough; Multi-Site Infrastructure VPN (v2)

> This walkthrough covers the **manual stages** of the project, the parts done by hand after the
> infrastructure is stood up with Terraform/Terragrunt. Most of the infrastructure (VPCs, subnets,
> the Transit Gateway, EC2 instances, IAM, security groups) is provisioned by IaC; see the
> [How to deploy](./README.md#how-to-deploy) section in the README for that. The steps below are the
> VPN gateway objects, the strongSwan tunnel configuration, the Zabbix proxy registration, and the
> end-to-end monitoring test — the genuinely hands-on parts.

**Convention:** AWS side is `us-west-2` (Oregon); the on-prem site is simulated in `eu-north-1`.
Resource names follow `arday-aws-*` and `arday-onprem-*`.

---

## Stages at a glance

| Stage | What you do | Method |
|---|---|---|
| 0 | Provision both sides | Terraform / Terragrunt (see README) |
| 1 | Create the Customer Gateway | AWS Console |
| 2 | Create the TGW VPN attachment (VPN connection) | AWS Console |
| 3 | Configure strongSwan — bring up Tunnel 1 (+ optional Tunnel 2) | SSH / Session Manager |
| 4 | Wire routing on both sides (TGW + on-prem) | AWS Console + router |
| 5 | Deploy & register the Zabbix proxy | Session Manager |
| 6 | Verify monitoring syncs to the on-prem server | Zabbix UI |
| 7 | Cleanup | Console + Terragrunt |

---

## Stage 0; Provision (IaC, recap)

Before any manual step, stand up both environments:

```bash
cd zabbix-s2s-vpn/infra/terragrunt
terragrunt run-all apply        # AWS side then on-prem, in dependency order
terragrunt output               # capture router public IP, proxy private IP, TGW id, etc.
```

Save the outputs, you'll paste several of them into the steps below.

---

## Stage 1; Create the Customer Gateway (CGW)

The CGW is the AWS-side **record** of your on-prem strongSwan router (its public IP).

1. **VPC Console → Virtual Private Network → Customer Gateways → Create customer gateway**
2. Set:
   - **Name:** `arday-onprem-cgw`
   - **Routing:** Static
   - **BGP ASN:** any private value (e.g. `65000`), required by the form, unused for static
   - **IP address:** the strongSwan router's **Elastic IP** (`onprem_router_eip` from `terragrunt output`)
3. **Create customer gateway.**

> Use the Elastic IP, not the instance's private IP, the CGW must point at the router's public face.

---

## Stage 2; Create the TGW VPN attachment (VPN connection)

This creates the actual encrypted link, terminating on your **Transit Gateway** (not a VGW).

1. **VPC Console → Transit Gateway Attachments → Create transit gateway attachment**
   - **Transit Gateway ID:** your `arday-tgw`
   - **Attachment type:** VPN
   - **Customer Gateway:** Existing → `arday-onprem-cgw`
   - **Routing options:** **Static**
   - **Create attachment**
2. Wait until **State = available** (a few minutes). The VPN connection is created with **two
   tunnels** to two different AWS endpoints.
3. **Download the configuration:**
   - **VPC Console → Site-to-Site VPN Connections →** select the connection **→ Download
     configuration**
   - **Vendor:** Generic (since strongSwan isn't a listed vendor)
   - Save it, you need the tunnel values in Stage 3.
4. From the config file, record for **each tunnel**:
   - AWS **outside** IP (the tunnel endpoint)
   - the inside `/30` addresses
   - the **pre-shared key (PSK)**

> Tunnels will show **DOWN** at this point, that's expected. They come up once strongSwan is
> configured.

---

## Stage 3; Configure strongSwan (bring up the tunnels)

Connect to the on-prem router via Session Manager and edit the three IPSec files.

```bash
# Session Manager → arday-onprem-router
sudo bash
cd /etc
```

**3.1 `/etc/ipsec.conf` - Tunnel 1**

```conf
conn CONN_TUNNEL1
    left=%defaultroute
    leftid=<ONPREM_ROUTER_PUBLIC_IP>
    right=<T1_AWS_OUTSIDE_IP>
    rightid=<T1_AWS_OUTSIDE_IP>
    type=tunnel
    leftsubnet=0.0.0.0/0
    rightsubnet=0.0.0.0/0
    ike=aes128-sha1-modp1024
    esp=aes128-sha1-modp1024
    ikelifetime=28800s
    lifetime=3600s
    keyexchange=ikev1
    mark=100
    auto=start
```

**3.2 `/etc/ipsec.secrets` - the PSK**

```
<ONPREM_ROUTER_PUBLIC_IP> <T1_AWS_OUTSIDE_IP> : PSK "<T1_PSK>"
```

**3.3 `/etc/ipsec-vti.sh` — the virtual tunnel interface**

```bash
ip link add vti1 type vti local <ONPREM_PRIVATE_IP> remote <T1_AWS_OUTSIDE_IP> key 100
ip addr add <T1_ONPREM_INSIDE_IP>/30 dev vti1
ip link set vti1 up mtu 1419
```

**3.4 Apply and verify**

```bash
chmod +x /etc/ipsec-vti.sh
systemctl restart strongswan-starter
bash /etc/ipsec-vti.sh

sudo ipsec status            # CONN_TUNNEL1: ESTABLISHED
ip addr show vti1            # shows the inside /30
```

Check the AWS console too: **VPC → Site-to-Site VPN Connections → Tunnel Details → Tunnel 1: UP**.

**3.5 (Optional) Tunnel 2 for AWS-side HA**, repeat 3.1–3.4 using the **second** AWS outside IP,
the **second** PSK, `mark=200`, and `vti2`. Note: because this is a *static* VPN, Tunnel 2 gives
AWS→on-prem redundancy but not automatic on-prem→AWS failover (that needs BGP).

---

## Stage 4; Wire routing on both sides

Traffic must have a route in **both** directions or TCP silently fails.

**4.1 AWS side, Transit Gateway route table**

- **VPC Console → Transit Gateway Route Tables →** the TGW route table (`tgw-rtb-…`)
- Ensure the **on-prem CIDR** (e.g. `192.168.x.x/…` or your `Hodan-DC` range) routes to the **VPN
  attachment**, and the **VPC CIDRs** (`10.2.0.0/16` etc.) route to their **VPC attachments**.

**4.2 AWS side — VPC route tables**

- In each workload/monitoring VPC's route table, add a route for the **on-prem CIDR → the TGW**.
  (A TGW does **not** propagate routes into VPC route tables, so add this explicitly.)

**4.3 On-prem side — strongSwan host route**

- Ensure the on-prem router routes the **AWS CIDR range(s)** (e.g. `10.0.0.0/16` / the VPC CIDRs)
  over `vti1`:

```bash
ip route add 10.2.0.0/16 dev vti1     # repeat for other AWS CIDRs as needed
```

> The on-prem private hosts (incl. the Zabbix server) need a route to the AWS CIDRs via the router,
> and the router forwards over the VTI. Confirm `source_dest_check = false` on the router instance.

---

## Stage 5; Deploy & register the Zabbix proxy

The proxy lives in the AWS monitoring VPC (`HodaN102-vpc`) and forwards metrics to the on-prem
server.

1. **Session Manager → `hodan102-gto-monitoring`** (the `t3.small` Ubuntu proxy instance).
2. Install and point the proxy at the on-prem Zabbix server:

```bash
sudo bash
# Install Zabbix proxy (repo + package), then edit the config:
nano /etc/zabbix/zabbix_proxy.conf
#   Server=<ONPREM_ZABBIX_SERVER_PRIVATE_IP>   ← reachable across the VPN
#   Hostname=hodan102-proxy
#   ProxyMode=0                                ← active proxy (proxy initiates to server)
systemctl enable --now zabbix-proxy
```

3. On the **on-prem Zabbix server UI**: **Administration → Proxies → Create proxy**
   - **Proxy name:** `hodan102-proxy` (must match `Hostname` above)
   - **Mode:** Active
4. Assign the AWS workload hosts (in `HodaN100` / `HodaN101`) to be **monitored by**
   `hodan102-proxy`.

> The proxy is the key design choice: it collects metrics locally inside AWS, **batches** them, and
> **buffers** them if the tunnel is briefly down — so a tunnel blip doesn't lose data.

---

## Stage 6; Verify monitoring syncs to the on-prem server

This is the v2 equivalent of the v1 "files visible on both sides" proof — here, **AWS metrics appear
on the on-prem dashboard**.

1. **Connectivity sanity check** - from the on-prem Zabbix server (Session Manager):

```bash
ping <zabbix_proxy_private_ip>          # ICMP across the tunnel
nc -vz <zabbix_proxy_private_ip> 10051  # proxy/server port reachable
```

2. **On the on-prem Zabbix UI:**
   - **Administration → Proxies →** `hodan102-proxy` shows **Last seen** updating (proxy is talking
     to the server across the VPN).
   - **Monitoring → Hosts →** the AWS workload hosts show **green/available** with incoming data.
   - **Monitoring → Latest data →** metrics from the AWS hosts are arriving.
3. **Failover sanity (optional):** briefly drop Tunnel 1; confirm the proxy buffers and then
   back-fills data once connectivity returns, no permanent gaps.

Capture a screenshot of the on-prem dashboard showing AWS host metrics, that's the headline
evidence for this project.

---

## Stage 7; Cleanup

Delete the manually-created VPN objects **before** destroying the IaC, or the TGW won't tear down.

1. **VPC Console → Site-to-Site VPN Connections →** delete the VPN connection. Wait for **deleted**.
2. **VPC Console → Customer Gateways →** delete `arday-onprem-cgw`.
3. Destroy the rest:

```bash
cd zabbix-s2s-vpn/infra/terragrunt
terragrunt run-all destroy
```

4. Verify no leftover Elastic IPs, TGW attachments, or running instances in Cost Explorer.

---

*For the architecture, design rationale, and the v1 → v2 story, see the
[README](./README.md).*
