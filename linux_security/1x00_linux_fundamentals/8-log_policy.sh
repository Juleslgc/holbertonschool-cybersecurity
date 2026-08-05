#!/bin/bash
chown root:$2 "$1" && chmod 2750 $1 && chmod o-rwx "$1"
cat << EOF > /etc/logrotate.d/app
/var/log/app/*.log {
create 0640 root $2
}
EOF
