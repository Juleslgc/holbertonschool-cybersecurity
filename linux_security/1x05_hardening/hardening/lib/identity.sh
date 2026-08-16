#!/bin/bash

harden_identity() {

        log "Starting identity hardening"

        if ! configure_password_policy; then
                log "ERROR: Password policy configuration failed"
                return 1
        fi

        if ! configure_lockout; then
                log "ERROR: Lockout configuration failed"
                return 1
        fi

        if ! cleanup_users; then
                log "ERROR: User cleanup failed"
                return 1
        fi

        if ! lock_root_password; then
                log "ERROR: Root password locking failed"
                return 1
        fi

        log "Identity hardening completed"

        return 0
}

configure_password_policy() {
    log "Configuring password policy"

    # Longueur minimale
    sed -i '/^minlen/d' /etc/security/pwquality.conf
    echo "minlen = $PASS_MIN_LEN" >> /etc/security/pwquality.conf

    # Une majuscule minimum
    sed -i '/^ucredit/d' /etc/security/pwquality.conf
    echo "ucredit = -1" >> /etc/security/pwquality.conf

    # Une minuscule minimum
    sed -i '/^lcredit/d' /etc/security/pwquality.conf
    echo "lcredit = -1" >> /etc/security/pwquality.conf

    # Un chiffre minimum
    sed -i '/^dcredit/d' /etc/security/pwquality.conf
    echo "dcredit = -1" >> /etc/security/pwquality.conf

    # Un caractère spécial minimum
    sed -i '/^ocredit/d' /etc/security/pwquality.conf
    echo "ocredit = -1" >> /etc/security/pwquality.conf

    # Configuration PAM
    sed -i '/pam_pwquality.so/d' /etc/pam.d/common-password
    sed -i '1i password requisite pam_pwquality.so retry=3' /etc/pam.d/common-password

    # Expiration du mot de passe
    sed -i '/^PASS_MAX_DAYS/d' /etc/login.defs
    echo "PASS_MAX_DAYS $PASS_MAX_DAYS" >> /etc/login.defs

    log "Password policy configured"
}


configure_lockout() {
    log "Configuring account lockout"

    # Nombre d'échecs avant verrouillage
    sed -i '/^deny/d' /etc/security/faillock.conf
    echo "deny = $FAIL_LOCK_ATTEMPTS" >> /etc/security/faillock.conf

    # Configuration PAM faillock
    sed -i '/pam_faillock.so/d' /etc/pam.d/common-auth

    sed -i '1i auth required pam_faillock.so preauth' /etc/pam.d/common-auth
    sed -i '/pam_unix.so/i auth [default=die] pam_faillock.so authfail' /etc/pam.d/common-auth

    log "Account lockout configured"
}


cleanup_users() {
    log "Starting user cleanup"

    while IFS=: read -r username password uid gid gecos home shell
    do
        if [ "$uid" -le "$UID_THRESHOLD" ]; then
            continue
        fi

        groups=$(id -nG "$username" 2>/dev/null)

        if echo "$groups" | grep -qw "sudo"; then
            continue
        fi

        if echo "$groups" | grep -qw "wheel"; then
            continue
        fi

        log "Deleting user $username"

        if ! userdel "$username"; then
            log "ERROR: Failed to delete $username"
            return 1
        fi

    done < /etc/passwd

    log "User cleanup completed"
}


lock_root() {
    log "Locking root password"

    if passwd -l root; then
        log "Root password locked successfully"
        return 0
    fi

    log "ERROR: Failed to lock root password"
    return 1
}
