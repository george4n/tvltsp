#!/bin/bash

# Git Pull
# This script will do the following:
# Gather input about a user and store to variables
# Modify ansible playbook
# Run ansible playbook
# Git add/commit/push

clear

echo "Firstname:"
read FIRSTNAME

echo "Lastname:"
read LASTNAME

echo "UID:"
read CUSTOMUID

echo "Group Name: televinken, 3kundservice, 3telesales, 3solsidan"
read CUSTOMGROUP

echo "Password:"
read PASSWORD


# This prints "Bwah ok"
tee -a new.sh <<EOF
- username: "$FIRSTNAME"
  comment: "$FIRSTNAME $LASTNAME"
  group: "$CUSTOMGROUP"
  password: "$PASSWORD"
  shell: /bin/bash
EOF

echo date