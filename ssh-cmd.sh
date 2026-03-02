#!/bin/bash
# Usage: ./ssh-cmd.sh <IP> <PASSWORD> <COMMAND>
# Runs a command on the remote trading box via expect+ssh.
# Outputs only the command's stdout (strips spawn/password junk).

IP="$1"
PASS=$(printf '%s' "$2" | sed 's/\\\(.\)/\1/g')
CMD="$3"

if [ -z "$IP" ] || [ -z "$PASS" ] || [ -z "$CMD" ]; then
  echo "Usage: ./ssh-cmd.sh <IP> <PASSWORD> <COMMAND>" >&2
  exit 1
fi

expect <<EXPECT_EOF 2>/dev/null | sed '1,2d'
spawn ssh -o StrictHostKeyChecking=no root@$IP {$CMD}
expect "password:"
send {$PASS}
send "\r"
expect eof
EXPECT_EOF
