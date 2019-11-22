#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu" ]]; then
        sed -e '/'"$USERNAME"'/{N;N;N;N;N;N;N;d}' vars.yml
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
else
        # Unknown.
fi


echo "Username:"
read USERNAME

echo "deleting user..."
ansible-playbook modify-users.yml -K
#git add .
#git commit -a -m "deleted user $USERNAME"
#git push
echo "user deletion complete!"
