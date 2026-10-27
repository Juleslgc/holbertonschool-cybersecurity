# LogiCorp Gateway — VPN Design

## 1. Purpose

The VPN provides encrypted remote access to approved LogiCorp services.

The proposed solution uses WireGuard. It creates a secure tunnel between each authorized workstation and the LogiCorp Gateway.

A VPN connection does not grant unrestricted access to the internal network. Firewall rules continue to control which services each user can reach.

## 2. Topology

The intended connection paths are:

- **Administrator:** Workstation → Internet → WireGuard Gateway → SSH on an approved administration target.
- **Finance:** Workstation → Internet → WireGuard Gateway → Authorized FTP server, if the legacy service is retained.
- **Application:** Application server → Database server over the approved database connection.
- **Other users:** No access unless explicitly authorized.

The gateway accepts WireGuard connections on UDP port 51820. The firewall then applies the relevant access rules.

## 3. IP Addressing Scheme

The following is a proposed VPN addressing scheme. It must be checked for overlap with existing company networks before use.

| Device or role | Proposed VPN address |
|---|---|
| WireGuard Gateway | `10.99.0.1/24` |
| Administrator workstation | `10.99.0.10/32` |
| Finance workstation 1 | `10.99.0.21/32` |
| Finance workstation 2 | `10.99.0.22/32` |

Each device receives a unique VPN address and its own cryptographic key pair.

The existing database address, `192.168.1.50:3306`, is referenced in the proposed architecture. Its actual location and reachability must be verified. The VPN network must not overlap with the existing internal networks.

The final design must also document the actual addresses and routes of the application server, FTP server, and any reverse proxy.

## 4. Access Control

| Role | SSH | FTP | Application | Database |
|---|---|---|---|---|
| Administrator | Allow to approved administration targets | Only if separately approved | Only if required | Only if separately approved |
| Finance | Deny by default | Allow if retained and required | As required for normal work | Deny by default |
| Public Internet | Deny | Deny | Only through an approved public entry point | Deny |

Database exceptions must be approved and limited to the necessary source, destination, and service.

WireGuard peer configuration and firewall rules must work together. The `AllowedIPs` setting controls peer address selection and routing; it must not be treated as a replacement for firewall access controls.

## 5. Device and Key Management

- Assign each device its own WireGuard keys.
- Protect private keys and exclude them from the project repository.
- Authorize new devices before allowing access.
- Remove a peer when a device is lost or access is no longer required.
- Rotate keys when necessary, especially after suspected exposure.
- Keep a record of authorized peers and their assigned addresses.

## 6. Security Requirements

The gateway must accept WireGuard traffic only on the required UDP port. Internal services must not be exposed directly to the Internet unless specifically approved.

SSH access must be restricted to authorized administrators. Finance access must be limited to the services needed for their work.

The VPN encrypts traffic within the tunnel, but it does not automatically encrypt every connection between internal systems. In particular, traditional FTP remains unencrypted at the application level.

## 7. Testing and Maintenance

Before deployment is considered complete, verify that:

- Authorized devices can connect.
- Each role can access its permitted services.
- Restricted destinations remain inaccessible.
- Routing and DNS behave as intended.
- Removing a peer revokes its access.
- Administrators retain a working recovery path.
- VPN activity can be monitored.

A recent WireGuard handshake confirms peer communication, but does not prove that all internal routes and services are working.

## 8. Status

The addressing scheme is provisional. It must be reconciled with the actual network before the VPN is configured.
