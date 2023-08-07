printf '\n`minimal install goes here\n'

ping -c 1 archlinux.org > /dev/null
if [[ $? -ne 0 ]] ; then
    echo "Please check the internet connection."
    exit 1
else
    echo "Internet OK."
fi
