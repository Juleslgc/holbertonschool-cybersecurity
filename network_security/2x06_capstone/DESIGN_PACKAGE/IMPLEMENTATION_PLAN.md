# LogiCorp Gateway — Implementation Plan

## 1. Purpose

This document defines the implementation sequence for the proposed firewall, VPN, and legacy-service security changes.

The main priorities are to avoid administrative lockout, preserve required business services, and provide a tested recovery method for every major change.

## 2. General Safety Requirements

Before each change:

- Back up the affected configuration.
- Record the current working state.
- Confirm how to restore access if the change fails.
- Identify the expected result and the tests required.
- Apply the change only with the required authorization.

Changes should be performed in a controlled environment or during an approved maintenance window.

## 3. Implementation Sequence and Rollback

| Step | Action | Validation | Rollback |
|---|---|---|---|
| 1 | Inspect the network, services, firewall, and accounts | Confirm service locations, routes, and dependencies | No configuration change; retain the baseline |
| 2 | Back up configurations and prepare recovery access | Confirm backups are readable and recovery access is available | Restore the verified backup if preparation fails |
| 3 | Finalize the addressing scheme and access rules | Check for IP overlap and confirm required business flows | Revise the design before deployment |
| 4 | Configure WireGuard | Test an administrator peer and a Finance peer | Remove the new VPN configuration and restore the previous state if required |
| 5 | Verify administration through the VPN | Confirm a new SSH session works through the approved path | Keep the existing management session and restore prior access rules if testing fails |
| 6 | Apply firewall rules in stages | Test allowed and blocked traffic after each change | Restore the previous ruleset using the prepared recovery method |
| 7 | Restrict FTP and review its configuration | Test Finance access, passive transfers, and denied external access | Restore the backed-up FTP configuration and prior rules if essential transfers fail |
| 8 | Harden SSH and disable Telnet after dependency checks | Confirm authorized administration works and Telnet is no longer required | Restore the previous service configuration only if necessary to recover approved operations, then investigate the failure |
| 9 | Configure monitoring and log collection | Confirm that test events appear in the expected logs | Restore the previous monitoring configuration if collection fails |
| 10 | Run final acceptance tests | Verify access controls, business functions, and recovery procedures | Revert the affected change and repeat testing before approval |

Rollback procedures must be prepared and tested for the actual environment. Restoring a configuration file alone may not be sufficient if routing, service state, or related firewall rules have also changed.

## 4. Critical Lockout Prevention

Firewall and SSH changes can interrupt remote administration.

To reduce this risk:

1. Keep an existing administrative session open while testing a new access path.
2. Confirm that the VPN works before restricting SSH.
3. Test a separate new SSH connection rather than relying only on the existing session.
4. Prepare a working recovery method before applying restrictive firewall rules.
5. Apply restrictive changes incrementally and verify them immediately.
6. Do not close the existing session until the new access path has been confirmed.

If no reliable recovery method exists, restrictive changes must not be applied remotely until one is established.

## 5. Firewall Deployment

The firewall must be introduced in stages.

First, document the current rules and required traffic. Next, prepare the proposed ruleset and verify its syntax and intended behavior. Apply it through the approved recovery procedure, then test the VPN, SSH, FTP, application, database, and required outbound traffic.

Do not assume that a valid ruleset is safe merely because it loads successfully.

## 6. Service Hardening

SSH must be restricted only after the new administrative access path has been verified.

Telnet should be disabled after confirming that no required system depends on it.

If FTP is retained, disable anonymous access, restrict user permissions, configure the passive port range, and limit connections to approved VPN clients. If FTP cannot be secured sufficiently, migration to SFTP should be prioritized.

## 7. Monitoring and Final Validation

Confirm that the firewall, VPN, SSH, and file-transfer services produce the expected logs.

If Suricata is deployed, verify that it receives the intended traffic and that test activity produces appropriate alerts. Centralized logging must also be tested if included in the deployment.

The final review must confirm that:

- Authorized users can reach the required services.
- Unauthorized connections are blocked.
- Database access follows the approved policy.
- The application and required business functions still work.
- Logs and alerts are available as intended.
- Rollback procedures are documented and usable.
- Remaining risks have been recorded and approved where necessary.

## 8. Completion and Handover

The project is complete only after the tests pass, the final configuration is documented, and outstanding issues have been reviewed.

Record the implementation date, responsible operator, test results, rollback results where tested, unresolved risks, and required follow-up actions.

## 9. Status

This is a proposed implementation plan. The steps, recovery mechanisms, and rollback procedures must be adapted to the verified LogiCorp environment before execution.
