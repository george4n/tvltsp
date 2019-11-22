#!/bin/bash




echo "Enter the username to delete:"
read USERNAME

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "Using sed for Linux"
        sed -e '/"'$USERNAME'"/{N;N;N;N;N;d}' roles/users-add/vars/main.yml
elif [[ "$OSTYPE" == "darwinn"* ]]; then
        echo "Using sed for Mac OSX"
        sed -e '/"'$USERNAME'"/{N;N;N;N;N;d;}' roles/users-add/vars/main.yml
else
        echo "Unknown OS"
        break
fi

echo "deleting user..."
#ansible-playbook modify-users.yml -K
#git add .
#git commit -a -m "deleted user $USERNAME"
#git push
echo "user deletion complete!"
