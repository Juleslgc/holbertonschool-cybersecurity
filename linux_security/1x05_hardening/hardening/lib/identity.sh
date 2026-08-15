#!/bin/bash

configure_identity() {

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

        # Minimum length
        sed -i '/^[[:space:]]*minlen[[:space:]]*=/d' "$PWQUALITY_CONFIG"

        echo "minlen = $PASS_MIN_LEN" >> "$PWQUALITY_CONFIG"


        # At least one uppercase
        sed -i '/^[[:space:]]*ucredit[[:space:]]*=/d' "$PWQUALITY_CONFIG"

        echo "ucredit = -1" >> "$PWQUALITY_CONFIG"


        # At least one lowercase
        sed -i '/^[[:space:]]*lcredit[[:space:]]*=/d' "$PWQUALITY_CONFIG"

        echo "lcredit = -1" >> "$PWQUALITY_CONFIG"


        # At least one digit
        sed -i '/^[[:space:]]*dcredit[[:space:]]*=/d' "$PWQUALITY_CONFIG"

        echo "dcredit = -1" >> "$PWQUALITY_CONFIG"


        # At least one special character
        sed -i '/^[[:space:]]*ocredit[[:space:]]*=/d' "$PWQUALITY_CONFIG"

        echo "ocredit = -1" >> "$PWQUALITY_CONFIG"


        # Configure PAM
        sed -i '/pam_pwquality\.so/d' "$COMMON_PASSWORD"

        sed -i '1i password requisite pam_pwquality.so retry=3' "$COMMON_PASSWORD"


        # Password expiration
        sed -i '/^[[:space:]]*PASS_MAX_DAYS[[:space:]]/d' /etc/login.defs

        echo "PASS_MAX_DAYS $PASS_MAX_DAYS" >> /etc/login.defs


        log "Password policy configured"

        return 0
}

configure_lockout() {

        log "Configuring account lockout"

        # Remove existing deny configuration
        sed -i '/^[[:space:]]*deny[[:space:]]*=/d' "$FAILLOCK_CONFIG"

        # Add required value
        echo "deny = $FAIL_LOCK_ATTEMPTS" >> "$FAILLOCK_CONFIG"


        # Ensure pam_faillock is configured
        if ! grep -q "pam_faillock.so" "$COMMON_AUTH"; then

                sed -i '1i auth required pam_faillock.so preauth' "$COMMON_AUTH"

                sed -i '/pam_unix\.so/i auth [default=die] pam_faillock.so authfail' "$COMMON_AUTH"

        fi


        log "Account lockout configured for $FAIL_LOCK_ATTEMPTS attempts"

        return 0
}

cleanup_users() {

        log "Starting user cleanup"

        while IFS=: read -r username password uid gid gecos home shell
        do

                # Ignore UID <= 1000
                if [ "$uid" -le "$UID_THRESHOLD" ]; then
                        continue
                fi


                # Get user's groups
                groups=$(id -nG "$username" 2>/dev/null)


                # Keep sudo users
                if echo "$groups" | grep -qw "sudo"; then
                        log "Keeping $username: member of sudo"
                        continue
                fi


                # Keep wheel users
                if echo "$groups" | grep -qw "wheel"; then
                        log "Keeping $username: member of wheel"
                        continue
                fi


                # Delete user
                log "Deleting user $username with UID $uid"

                if userdel "$username"; then
                        log "User $username deleted successfully"
                else
                        log "ERROR: Failed to delete $username"
                        return 1
                fi

        done < /etc/passwd

        log "User cleanup completed"

        return 0
}

lock_root_password() {

        log "Checking root password status"

        if passwd -S root | grep -q " L "; then
                log "Root password is already locked"
                return 0
        fi

        if passwd -l root; then
                log "Root password locked successfully"
                return 0
        fi

        log "ERROR: Failed to lock root password"

        return 1
}
