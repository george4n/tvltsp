#!/bin/bash

# Get the new USER details via read
# Figure out HOME_DIR
# Figure out the next available UID
# Substitute values
# Merge Firstname and Lastname ofr Username & change case

# Make sure only root can run our script
#if [[ $EUID -ne 0 ]]; then
#   echo "ERROR: Uh oh...this script must be run as root" 1>&2
#   exit 1
#fi
clear

function welcome {

echo "
#############################################################################

This script is designed for Noobuntu 14.04 Server running OpenLDAP.
The primary function is to add users to OpenLDAP in an incremental fashion.

#############################################################################"
}


welcome

### CONSTANTS VARIABLES
#echo "Your Base Directory eg. /mnt/users /mnt"
#read BASE_DIR

BASE_DIR=/mnt


### END

echo "Your Base directory is defined as $BASE_DIR"
read -p "-------> Is this correct?(y/n) " -n 1 -r
echo    #
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
        echo "Exiting: Set the variable in CONSTANTS VARIABLES"
    exit 1
fi


### QUERY LDAP FOR THE CURRENT HIGHEST UID NUMBER

HIGHESTUID=$(ldapsearch -x -LLL -H ldap:/// -b dc=ldapserver,dc=lan | grep uidNumber: | awk '{print $2}' | sed '$!d')

### INCREMENT 1 TO THAT NUMBER

NEWUID=$(($HIGHESTUID + 1))

echo "Firstname:"
read FIRSTNAME

echo "Lastname:"
read LASTNAME

echo "UID:"
read CUSTOMUID

echo "Group Number: 501=foretag, 502=telesales, 503=kundservice, 504=televinken, 505=savedesk"
read GROUPNUMBER

echo "Password:"
read PASSWORD

################################"
echo "Firstname:                $FIRSTNAME"
echo "Lastname:         $LASTNAME"
echo "UID:"             $CUSTOMUID
echo "GID:                      $GROUPNUMBER"
echo "Password:         $PASSWORD


"
read -p "-------> Is this correct?(y/n) " -n 1 -r
echo    #
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
        echo "Exiting: Rerun the script"
    exit 1
fi

### User HOME_DIR placement
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

# SET PARAMETERS DEPENING ON GROUP ID (GID)

if [ $GROUPNUMBER = "501" ]; then
HOME_DIR="$BASE_DIR/foretag/$USERNAME"
GROUPNAME="foretag"
NFS_DIR="/media/foretag"
SKEL_DIR="/media/foretag/sforetag"
NFS_SERVER="172.20.220.100"

elif [ $GROUPNUMBER = "502" ]; then
HOME_DIR="$BASE_DIR/telesales/$USERNAME"
GROUPNAME="telesales"
NFS_DIR="/media/telesales"
SKEL_DIR="/media/telesales/stelesales"
NFS_SERVER="172.20.220.100"

elif [ $GROUPNUMBER = "503" ]; then
HOME_DIR="$BASE_DIR/kundservice/$USERNAME"
GROUPNAME="kundservice"
NFS_DIR="/media/kundservice"
SKEL_DIR="/media/kundservice/skundservice"
NFS_SERVER="172.20.100.13"

elif [ $GROUPNUMBER = "504" ]; then
HOME_DIR="$BASE_DIR/televinken/$USERNAME"
GROUPNAME="people"
NFS_DIR="/media/televinken"
SKEL_DIR="/media/televinken/Skel-Televinken"
NFS_SERVER="172.20.210.100"

elif [ $GROUPNUMBER = "505" ]; then
HOME_DIR="$BASE_DIR/savedesk/$USERNAME"
GROUPNAME="savedesk"
NFS_DIR="/media/savedesk"
SKEL_DIR="/media/savedesk/ssavedesk"
NFS_SERVER="172.20.100.13"



fi
}



echo "Creating LDIF File"
sleep 1
groupcalc

echo "


################################"
echo "Firstname:                $FIRSTNAME"
echo "Lastname:         $LASTNAME"
echo "Username:         $USERNAME"
echo "UID:                      $CUSTOMUID"
echo "GID:                      $GROUPNUMBER"
echo "Password:         $PASSWORD"
echo "HOME_DIR:         $HOME_DIR


"

### Merge Firstname and Lastname for Username & change case

function ldif {
        echo "
dn: cn=$FIRSTNAME $LASTNAME,ou=$GROUPNAME,dc=ldapserver,dc=lan
cn: $FIRSTNAME $LASTNAME
givenName: $FIRSTNAME
gidNumber: $GROUPNUMBER
homeDirectory: $HOME_DIR
sn: $LASTNAME
loginShell: /bin/bash
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
uid: $USERNAME
uidNumber: $CUSTOMUID
userPassword:$PASSWORD
" >> /tmp/tmp.ldif

}

ldif

ldapadd -W -D cn=admin,dc=ldapserver,dc=lan -f /tmp/tmp.ldif

rm /tmp/tmp.ldif

# SSH to NFS and create HOME_DIR from SKEL_DIR

#ssh neo@172.20.100.11 "$SKEL_DIR"

ssh neo@$NFS_SERVER "SKEL_DIR=$SKEL_DIR;
sudo mkdir $NFS_DIR/$USERNAME;
echo "Home Directory Created at $NFS_DIR/$USERNAME";
sleep 1;
sudo cp -r $SKEL_DIR/.cpspace/ $NFS_DIR/$USERNAME/;
echo "Bria config complete!";
sleep 1;
sudo cp -r $SKEL_DIR/.mozilla/ $NFS_DIR/$USERNAME/;
echo "Mozilla config complete!"
sleep 1;
sudo mkdir $NFS_DIR/$USERNAME/.config/;
sudo cp -r $SKEL_DIR/.config/autostart/ $NFS_DIR/$USERNAME/.config/;
echo "Autostart config complete!";
sleep 1;
sudo chown -R "$CUSTOMUID:$GROUPNUMBER" $NFS_DIR/$USERNAME/;
echo "CHOWN Complete";
sudo chmod 0700 $NFS_DIR/$USERNAME/;
echo "CHMOD Complete";
echo "All Done";
exit
"

exit 0