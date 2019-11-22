#!/bin/bash

# Git Pull
# This script will do the following:
# Gather input about a user and store to variables
# Modify ansible playbook
# Run ansible playbook
# Git add/commit/push
git pull
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

function groupcalc {

        ##### FIRST NAME
        function firstnamecalc {
        echo "$FIRSTNAME" | tr '[:upper:]' '[:lower:]' | head -c 1
        }

        NEWFIRSTNAME=$(firstnamecalc)

        ##### LAST NAME
        function lastnamecalc {
        echo "$LASTNAME" | tr '[:upper:]' '[:lower:]'
        }

        NEWLASTNAME=$(lastnamecalc)
        USERNAME="$NEWFIRSTNAME$NEWLASTNAME"

        if [ $CUSTOMGROUP = "televinken" ]; then
        HOME_DIR="/tvltsp/users/televinken/$USERNAME"
        GROUPNAME="foretag"

        elif [ $CUSTOMGROUP = "3kundservice" ]; then
        HOME_DIR="/tvltsp/users/3kundservice/$USERNAME"
        GROUPNAME="telesales"

        elif [ $CUSTOMGROUP = "3telesales" ]; then
        HOME_DIR="/tvltsp/users/3telesales/$USERNAME"
        GROUPNAME="kundservice"

        elif [ $CUSTOMGROUP = "3solsidan" ]; then
        HOME_DIR="/tvltsp/users/3solsidan/$USERNAME"
        GROUPNAME="people"

    fi
}

groupcalc



cat <<EOF
- username: "$USERNAME"
  comment: "$FIRSTNAME $LASTNAME"
  uid: "$CUSTOMUID"
  group: "$CUSTOMGROUP"
  password: "$PASSWORD"
  shell: /bin/bash
  home: $HOME_DIR
EOF



read -p "-------> Is this correct?(y/n) " -n 1 -r
echo    #
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
        echo "Exiting: Rerun the script"
    exit 1
fi


tee -a roles/user-add/vars/main.yml <<EOF
- username: "$USERNAME"
  comment: "$FIRSTNAME $LASTNAME"
  uid: "$CUSTOMUID"
  group: "$CUSTOMGROUP"
  password: "$PASSWORD"
  shell: /bin/bash
  home: $HOME_DIR

EOF

clear

echo "creating user..."
ansible-playbook modify-users.yml -K
git add .
git commit -a -m "added user $USERNAME"
git push
echo "user creation complete!"