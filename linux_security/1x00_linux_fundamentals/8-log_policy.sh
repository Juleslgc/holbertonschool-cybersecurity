#!/bin/bash
chown root:$2 "$1" && chmod g+s "$1" && chmod o-rwx "$1"
cat << 'EOF' > /etc/logrotate.d/app
/var/log/app/*.log {
create 0640 root www-data
}
EOF
