# GAP ANALYSIS REPORT
## Safety assessment

**Organization :** LogiCorp    
**Date :** 10/26/2026  
**Written by :** Jules  
**Version :** 1.0  
**Classification :** Confidentiel

---

## 1. Executive Summary
An analysis of the documentation reveals several security flaws: an insufficiently segmented network, SSH access exposed to the Internet, and an FTP protocol that transmits credentials in cleartext. It is a priority to segment the network using a DMZ, strengthen access controls with a firewall configured for a "deny-by-default" policy, and secure data transfers using FTPS/TLS. Finally, implementing redundancy will help improve service availability.

## 2. Current State Assessment

### 2.1 Scope of the analysis
This analysis focuses on the company's network infrastructure, including network connectivity (WAN, LAN, and DMZ), remote access, the FTP protocol used bythe finance department, and network security mechanisms. It also considers infrastructure availability, although the implementation of redundancy is outside the scope.

The objective is to identify gaps between the current state—as described in the documentation—and the defined security requirements, in order to propose appropriate corrective measures.

### 2.2 Current state of the infrastructure
**Network Connectivity**

The documentation indicates that the infrastructure relies on a flat network, where all devices reside on the same subnet (192.168.1.x). There is no documented separation between the WAN, LAN, and DMZ environments.

**Remote Access**

The SSH service is accessible from the entire Internet, and the root account is enabled. This configuration increases the risk of unauthorized access attempts and system compromise.

**Legacy Application**

The financial service requires the use of the FTP protocol. The server currently operates without encryption, which potentially exposes credentials and exchanged data to interception.

**Network Security**

No active firewall is mentioned in the documentation. Consequently, a filtering policy based on a "default deny" principle has yet to be implemented.

**Availability and Redundancy**

The infrastructure contains a single point of failure. A failure of the affected system could result in a service interruption. However, the implementation of redundancy is outside the scope of this analysis.

### 2.3 Target situation
The target state is based on the following requirements:

- **Connectivity:** Establish separate WAN, LAN, and DMZ environments tailored to the organization's needs.

- **Remote access:** Encrypt SSH communications, restrict connections to authorized personnel, and disable direct access to the root account.

- **FTP protocol:** Maintain the functionality required by the finance department while securing transfers—specifically through the use of FTPS with TLS.

- **Network security:** Implement a firewall that enforces a "deny-by-default" policy, permitting only necessary communications.

- **Monitoring:** Verify that logging and monitoring mechanisms are in place to enable the detection of suspicious activity.

Monitoring and logging will need to be assessed using additional documentation, as their current status is not specified in the available materials.

## 3. Gap Assessment

### 3.1 Network architecture
**Observed discrepancy:** All devices are located on the same subnet, with no documented segmentation between internal and public-facing environments.

**Risk:** In the event that a device is compromised, the lack of proper separation could facilitate an attacker’s lateral movement to other systems.

**Recommended measure:** Segment the network into distinct environments—such as a LAN and a DMZ—and implement controls over communications between these zones.

### 3.2 Access control
**Identified discrepancy:** The SSH service is exposed to the entire Internet, and the root account is enabled.

**Risk:** This exposure increases the attack surface and the risk of unauthorized access, particularly in the event of compromised credentials or an exploitable vulnerability.

**Recommended measure:** Restrict SSH access to authorized sources, disable direct root login, and prioritize SSH key-based authentication where appropriate.

### 3.3 Encryption
**Identified discrepancy:** The FTP server transmits data without encryption, whereas this protocol is required by the finance department.

**Risk:** Credentials and transferred data could be intercepted over the network.

**Recommended measure:** Migrate to FTPS with TLS, or evaluate the feasibility of using SFTP, while taking into account technical and business constraints.

### 3.4 Network security
**Identified gap:** The documentation indicates that no firewall is active, whereas the target environment requires a security policy based on the "default deny" principle.

**Risk:** The lack of communication filtering increases the risk of unauthorized access to network services and equipment.

**Recommended measure:** Implement a firewall configured to block all communications by default, allowing only the traffic necessary for the operation of the services.

### 3.5 Monitoring and logging
**Observed gap:** The available information does not make it possible to determine whether security logs are centralized or if event monitoring is in place.

**Potential risk:** Insufficient logging could delay the detection of a compromise and complicate investigations.

**Recommended measure:** Verify existing mechanisms, then centralize relevant logs and implement alerts for suspicious events, if necessary.

## 4. Risk Assessment Matrix

| ID | Identified gap | Potential impact | Gravity | Priority |
|---|---|---|---|---|
| GAP-01 | Lack of documented network segmentation | Spread of a compromise to other devices | High | P1 |
| GAP-02 | SSH accessible from the Internet and root account enabled | Unauthorized access to the system | High | P1 |
| GAP-03 | Unencrypted FTP | Interception of credentials and data | High | P1 |
| GAP-04 | No active firewall | Insufficiently filtered communications | High | P1 |
| GAP-05 | Monitoring status undocumented | Late detection of an incident | To be confirmed | P2 |
| GAP-06 | Single point of failure | Potential service interruption | To be evaluated | Outside the scope |

Severity levels are preliminary. They will need to be confirmed by a more in-depth analysis of the plausibility, business impact and controls already in place.

## 5. Preliminary Recommendations

### 5.1 Priority actions
**1. Secure SSH access**

Restrict connections to authorized IP addresses or networks.
Disable direct login for the root account.
Prioritize SSH key-based authentication and verify authorized accounts.

**2. Implement a firewall**

Apply a "deny by default" policy.
Allow only the traffic essential for the services.
Document and test rules before deploying them into production.

**3. Segment the network architecture**

Separate LAN and DMZ environments.
Place services accessible from the Internet in an appropriate zone.
Control traffic between the Internet, the DMZ, and the internal network.

**4. Secure file transfers**

Replace unencrypted FTP with FTPS (using TLS) or SFTP, depending on the requirements of the finance department.
Verify encryption configuration and access permissions.
Plan the migration to ensure service continuity.

**5. Evaluate monitoring**

Identify available logs and recorded events.
Verify whether centralization and security alerts are in place.
Define necessary improvements based on the results of this assessment.

### 5.2 Comprehensive remediation approach
Remediation must begin by reducing the risks of unauthorized access and implementing appropriate network filtering. Subsequently, infrastructure segmentation and the securing of file transfers must be planned and validated through testing.

Any changes must be prepared, tested, and accompanied by a rollback plan to minimize the risk of service disruption.

### 5.3 Forward-looking action plan
| Action | Priority | Proposed Owner | Indicative Deadline |
|----|----|----|----|
| Restrict and secure SSH | P1 | System Administrator | Short term |
| Define and deploy firewall rules | P1 | Network Administrator | Short term |
| Design LAN/DMZ segmentation | P1 | Network Team | Short to medium term |
| Secure file transfers | P1 | System Team and Finance Department | Short term |
| Verify logging and alerts | P2 | Security Team / SOC | Medium term |

The assigned responsibilities and deadlines are provided for guidance only and are subject to validation by the company. The implementation of redundancy is not included in this plan, in accordance with the defined scope.

## 6. Conclusion

The document review highlights several significant gaps regarding network segmentation, the securing of remote access, the encryption of data transfers, and the filtering of communications. The priority is to reduce exposure to unauthorized access, control network traffic, and protect the data exchanged by the finance department.

Further technical assessments will be required to confirm these findings, evaluate the actual risks, and validate the effectiveness of the proposed corrective measures.

## 7. Limitations

This analysis is based exclusively on the documentation provided. No access to the production system was obtained. The findings presented should be validated through further technical checks.

## 8. Annexes

- **Document A :** Internal Memo
- **Document B :** Client Request
- **Document C :** Technical specifications
- **Document D :** The "As-Is" Diagram
