# DEFENSE.md — LogiCorp Security Defense

## Point 1: Risk Acceptance — FTP vs. SFTP

### Business Constraints
FTP was retained to maintain compatibility with existing LogiCorp workflows and avoid immediate migration costs or service interruptions. However, FTP remains an insecure protocol.

### Risk Mitigation
- **WireGuard VPN:** Encrypts FTP traffic while it travels through the VPN tunnel.
- **Firewall restrictions:** Limit FTP access to authorized sources.
- **Network segmentation:** Prevents FTP access from automatically granting access to other internal systems.
- **Access control:** Anonymous FTP access should be disabled and verified.

### Residual Risks
FTP does not encrypt credentials or data by itself. Traffic outside the VPN tunnel may remain exposed, and compromised authorized devices may still access the service.

### Phase 2 Recommendation
Migrate to **SFTP** after testing compatibility with existing applications and scripts. A phased migration will reduce security risks while maintaining business continuity.

---

## Point 2: Firewall Strategy — Network Segmentation

### Security Zones
- **Internet:** Untrusted network.
- **Admin VPN (`10.99.0.10`):** Restricted SSH administration.
- **Finance VPN (`10.99.0.21`, `10.99.0.22`):** Authorized FTP access only.
- **Application server:** Authorized database access.
- **Database (`192.168.1.50`):** Highly restricted access.

### Traffic Restrictions
The firewall uses a default-deny policy and explicitly permits only required traffic:

- WireGuard on UDP port `51820`.
- SSH on TCP port `22` from the authorized admin VPN address.
- FTP for authorized Finance clients.
- Database access on TCP port `3306` from the application server only.
- HTTPS to the reverse proxy, if required.

Direct Finance-to-database access and unauthorized Internet-to-internal connections are blocked.

### Blocking Lateral Movement
If a Finance workstation is compromised, the attacker cannot automatically access the database. The firewall restricts communication between zones, limiting the attacker's ability to move laterally.

### Defense in Depth
Firewall rules are combined with VPN encryption, SSH hardening, least-privilege access, and configuration tests. These layers reduce risk but do not eliminate every possible attack path.

---

## Challenge 3: Resilience — Single Point of Failure

### Current Scope and Risk
High availability was outside the scope of this project. The gateway remains a single point of failure: if it becomes unavailable, VPN access and network traffic routed through it may be interrupted.

### Phase 2 Recommendation
Deploy a redundant gateway with:
- A failover mechanism, such as VRRP with Keepalived.
- Synchronized firewall and routing configurations.
- Gateway health monitoring.
- Tested failover and recovery procedures.

A virtual IP alone does not guarantee seamless WireGuard session continuity, so VPN recovery must also be tested.

### Cost-Benefit Analysis
A second gateway increases infrastructure and maintenance costs but reduces downtime risk. The investment should be justified by comparing implementation costs with potential business losses caused by service interruption.

---

## Conclusion

The project prioritizes security improvements while respecting operational constraints:

- **FTP:** Temporarily retained, with SFTP recommended for Phase 2.
- **Segmentation:** Restricts access and limits lateral movement.
- **Resilience:** Gateway redundancy is a future improvement to reduce downtime.

These decisions reduce risk without claiming to eliminate all vulnerabilities. The final controls must be verified against the deployed configuration.
