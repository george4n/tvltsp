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

        if [ $CUSTOMGROUP = "501" ]; then
        HOME_DIR="$BASE_DIR/foretag/$USERNAME"
        GROUPNAME="foretag"
        NFS_DIR="/media/foretag"
        SKEL_DIR="/media/foretag/sforetag"
        NFS_SERVER="172.20.220.100"

        elif [ $CUSTOMGROUP = "502" ]; then
        HOME_DIR="$BASE_DIR/telesales/$USERNAME"
        GROUPNAME="telesales"
        NFS_DIR="/media/telesales"
        SKEL_DIR="/media/telesales/stelesales"
        NFS_SERVER="172.20.220.100"

        elif [ $CUSTOMGROUP = "503" ]; then
        HOME_DIR="$BASE_DIR/kundservice/$USERNAME"
        GROUPNAME="kundservice"
        NFS_DIR="/media/kundservice"
        SKEL_DIR="/media/kundservice/skundservice"
        NFS_SERVER="172.20.100.13"

        elif [ $CUSTOMGROUP = "504" ]; then
        HOME_DIR="$BASE_DIR/televinken/$USERNAME"
        GROUPNAME="people"
        NFS_DIR="/media/televinken"
        SKEL_DIR="/media/televinken/Skel-Televinken"
        NFS_SERVER="172.20.210.100"

        elif [ $CUSTOMGROUP = "505" ]; then
        HOME_DIR="$BASE_DIR/savedesk/$USERNAME"
        GROUPNAME="savedesk"
        NFS_DIR="/media/savedesk"
        SKEL_DIR="/media/savedesk/ssavedesk"
        NFS_SERVER="172.20.100.13"
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
EOF



read -p "-------> Is this correct?(y/n) " -n 1 -r
echo    #
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
        echo "Exiting: Rerun the script"
    exit 1
fi


tee -a roles/users-add/vars/main.yml <<EOF

- username: "$USERNAME"
  comment: "$FIRSTNAME $LASTNAME"
  uid: "$CUSTOMUID"
  group: "$CUSTOMGROUP"
  password: "$PASSWORD"
  shell: /bin/bash

EOF

clear

echo "creating user..."
ansible-playbook modify-users.yml -K
git add .
git commit -a -m "added user $USERNAME"
git push
echo "user creation complete!"