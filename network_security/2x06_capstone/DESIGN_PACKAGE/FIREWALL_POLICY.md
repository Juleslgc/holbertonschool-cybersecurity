# LogiCorp Gateway — Firewall Policy

## 1. Purpose

This document defines the proposed firewall rules for protecting the LogiCorp network. It specifies which connections are allowed, which are blocked, and why.

The policy follows the principle of **default deny**: traffic is blocked unless a rule explicitly permits it.

## 2. Default Chain Policies

The following policies are proposed for the nftables `inet` table.

| Chain | Default policy | Purpose |
|---|---|---|
| `input` | `drop` | Block unauthorized traffic destined for the gateway |
| `forward` | `drop` | Block unauthorized traffic passing through the gateway |
| `output` | `accept` initially | Preserve required gateway communications while dependencies are identified |

The `output` policy is initially permissive to reduce the risk of interrupting system updates, DNS, monitoring, and other required services. It should be reviewed and restricted if justified by the security requirements.

The `input` chain must allow WireGuard connections on UDP port `51820` from the external interface and SSH connections on TCP port `22` only from the authorized administrator VPN. All other incoming SSH connections must be dropped.

These are target policies, not verified settings on the current system.

## 3. Rules and Justifications

| Chain | Source | Destination | Service | Action | Justification |
|---|---|---|---|---|---|
| `input` | Gateway (`lo`) | Gateway | Loopback traffic | Allow | Support local system communications |
| `input` | Any | Gateway | Invalid connection states | Drop | Reject malformed or unexpected traffic |
| `input` | Any | Gateway | Established and related connections | Allow | Permit legitimate response traffic |
| `input` | Any | Gateway | Required ICMP/ICMPv6 | Allow | Support diagnostics and essential network functions |
| `input` | Internet / WAN | Gateway | WireGuard, UDP 51820 | Allow | Enable secure remote access |
| `input` | Administrator VPN | Gateway | SSH, TCP 22 | Allow | Permit authorized administration |
| `input` | Unauthorized sources | Gateway | SSH, TCP 22 | Deny | Prevent unauthorized SSH access |
| `input` | Any | Gateway | Other incoming services | Deny by default | Block unapproved access to the gateway |
| `forward` | Any | Any | Invalid connection states | Drop | Reject invalid forwarded packets |
| `forward` | Any | Any | Established and related connections | Allow | Permit responses to authorized forwarded connections |
| `forward` | Finance VPN | FTP server | TCP 21 | Allow conditionally | Permit authorized FTP control connections |
| `forward` | Finance VPN | FTP server | Configured passive TCP ports | Allow conditionally | Support FTP passive-mode file transfers |
| `forward` | Unauthorized sources | FTP server | TCP 21 and passive ports | Deny | Restrict FTP access to authorized Finance peers |
| `forward` | Application server | Database server `192.168.1.50` | TCP 3306 | Allow | Permit required application database access |
| `forward` | Internet | Database server `192.168.1.50` | TCP 3306 | Deny | Prevent direct public database access |
| `forward` | Finance VPN | Database server `192.168.1.50` | TCP 3306 | Deny by default | Prevent unauthorized Finance database access |
| `forward` | Internet | Internal SSH or FTP servers | Relevant service ports | Deny | Prevent direct public access to internal services |
| `forward` | Internet | Reverse proxy | HTTPS, TCP 443 | Allow conditionally | Publish a web service only if required |
| `forward` | Reverse proxy | Application server | Approved application port | Allow conditionally | Permit approved web traffic |
| `forward` | Reverse proxy | Database server `192.168.1.50` | Any direct database connection | Deny | Prevent the proxy from bypassing the application |
| `forward` | Other sources | Protected internal destinations | Any unauthorized traffic | Deny by default | Enforce network segmentation |
| `output` | Gateway (`lo`) | Gateway | Loopback traffic | Allow | Support local system communications |
| `output` | Gateway | Any | Invalid connection states | Drop | Reject invalid outgoing packets |
| `output` | Gateway | Any | Established and related connections | Allow | Permit legitimate ongoing communications |
| `output` | Gateway | Approved DNS resolver | DNS, UDP/TCP 53 | Allow if required | Resolve domain names |
| `output` | Gateway | Approved NTP server | NTP, UDP 123 | Allow if required | Synchronize the system clock |
| `output` | Gateway | Approved repositories | HTTPS, TCP 443 | Allow if required | Download security updates |
| `output` | Gateway | Approved log collector | Configured logging protocol and port | Allow if required | Forward security logs |
| `output` | Gateway | External or internal destinations | Other required outbound services | Allow initially | Preserve essential gateway communications |

The FTP passive port range must be explicitly configured and kept consistent with the firewall. The exact range and service ports must be confirmed before deployment.

Finance users must not receive direct database access by default. If a legitimate business requirement is confirmed, a narrowly scoped exception may be approved and documented.

## 4. Rule Ordering

Rules must be evaluated in a deliberate order so that security controls are applied consistently.

1. Drop invalid connection states.
2. Allow established and related connections.
3. Allow loopback traffic where applicable.
4. Allow required gateway services, including WireGuard.
5. Allow SSH only from authorized administrative VPN addresses.
6. Allow FTP only from authorized Finance VPN addresses, if retained.
7. Allow explicitly approved forwarded application and database traffic.
8. Drop all remaining traffic through the default policies.

The order places general connection-state checks first, followed by narrowly defined service permissions. Unmatched traffic is blocked.

In nftables, the exact ordering must respect chain types and hooks. Rules must not be placed so that an earlier unconditional drop prevents a later legitimate allow rule from being evaluated.

## 5. Input and Forwarded Traffic

The `input` chain protects services running directly on the gateway.

The `forward` chain controls traffic routed between separate systems or network zones.

For example, if the FTP server and database are separate machines behind the gateway, their traffic must be controlled through forwarding rules. If a service runs on the gateway itself, the corresponding access is controlled through the input chain.

The actual rule placement must be confirmed after identifying the service locations and routing paths.

## 6. Outbound Traffic

The initial outbound policy remains permissive until required destinations and dependencies are identified.

The review must cover system updates, DNS, time synchronization, monitoring, and required application communications. Any later restriction must be tested to ensure that legitimate services continue to work.

## 7. Monitoring

Relevant allowed and blocked connections should be logged where useful, without generating excessive log volume.

Suricata may provide additional detection of suspicious network traffic. Its rules and traffic capture must be tested before relying on its alerts.

Centralized logging is a proposed control and must not be considered operational until deployed and verified.

## 8. Validation

Before deployment is approved, testing must confirm that:

- The VPN is reachable from authorized remote devices.
- SSH cannot be reached directly from the Internet.
- Finance can reach only approved file-transfer services.
- The application can reach the database on TCP 3306.
- Direct Internet access to the database is blocked.
- The reverse proxy, if required, exposes only the intended service.
- Required outbound traffic still works.
- Firewall logs and monitoring behave as expected.

## 9. Status

This policy describes the intended security configuration. Existing rules, network interfaces, service locations, and required traffic must be verified before implementation.
