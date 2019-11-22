#!/bin/bash

USERADDFILE='roles/user-add/vars/main.yml'
USERDELFILE='roles/user-del/vars/main.yml'
DELETEOSX=`sed -i '' '/"'$USERNAME'"/{N;N;N;N;N;d;}' $USERADDFILE`
DELETELINUX=`sed -i '/"'$USERNAME'"/{N;N;N;N;N;d}' $USERADDFILE`

function delete-user-conf-osx {

    echo -e "\n- $USERNAME" | tee -a $USERDELFILE
    $DELETEOSX

}

function delete-user-conf-linux {

    echo -e "\n- $USERNAME" | tee -a $USERDELFILE
    $DELETELINUX

}

function playbook {

    echo "deleting user..."
    ansible-playbook modify-users.yml -K
    git add .
    git commit -a -m "deleted user $USERNAME"
    git push
    echo "user deletion complete!"

}


echo "Enter the username to delete:"
read USERNAME

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "Using Linux OS"
        sed -e '/"'$USERNAME'"/{N;N;N;N;N;d}' roles/users-add/vars/main.yml
elif [[ "$OSTYPE" == "darwin"* ]]; then
        
        echo "Using Mac OSX"
        
        #Find patten and print line

        if grep -q $USERNAME $USERADDFILE; then
            echo "$USERNAME found!"
            sed -n  '/"'$USERNAME'"/{N;N;N;N;N;p;}' $USERADDFILE
                
                # Ask permission to delete user
                read -p "-------> Do you want to delete this user? The operation is NOT reversible(y/n) " -n 1 -r
                    
                    clear
                    delete-user-conf-osx
                    playbook
                    exit 0

                if [[ ! $REPLY =~ ^[Yy]$ ]]
                then
                    echo "Exiting: Rerun the script"
                    exit 1
                fi
        else
            echo "$USERNAME not found!"
            echo "aborting..."
            exit 0
        fi


else
        echo "Unknown OS...aborting"
        exit 0
fi


