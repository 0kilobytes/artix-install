printf '\n`minimal install goes here\n`'

ping -c 1 archlinux.org > /dev/null
if [[ $? -ne 0 ]] ; then
    echo "Please check the internet connection."
    exit 1
else
    echo "Internet OK."
fi
if [ "$EUID" -ne 0 ]; then
	echo "run as root"
	exit
fi
printf "Username (enter to skip) " && read user
if [[ -z $user ]]; then
	echo "sorwy plz enter a user"
	exit
	#user=user0
fi
pacman -Syu --noconfirm

#install doas
pacman -S --noconfirm --needed doas && \
usermod -aG wheel $user
echo "permit nopass :wheel" > /etc/doas.conf && \
echo "permit nopass root as $user" >> /etc/doas.conf
pacman -Rs sudo --noconfirm
rm -Rf /etc/sudo* $(which sudo)
rm -Rf /bin/sudo
rm -Rf /var/sudo
ln -s /bin/doas /bin/sudo

#install paru
if pacman -Q "yay" >/dev/null 2>&1; then
    pacman -Rnsc yay --noconfirm
    rm -Rf /bin/yay
fi
rm -Rf /home/$user/paru-git
chown -R $user:wheel /home/$user
if pacman -Q "paru" >/dev/null 2>&1; then
    echo "paru is already installed"
else
    pacman -S --needed --noconfirm base-devel && \
    pacman -S --needed --noconfirm git && \
    cd /home/$user/ && \
    sudo -u $user git clone https://aur.archlinux.org/paru-git.git && \
    cd /home/$user/paru-git && sudo -u $user makepkg -si --noconfirm --asdeps && rm -rf /home/$user/paru-git && ln -s /bin/paru /bin/yay
    if pacman -Q "paru" >/dev/null 2>&1; then
    	:
    else
    	echo "paru install failed"
    	exit
    fi
fi

#install zsh
doas -u $user paru -S --skipreview --noconfirm --needed oh-my-zsh-git && \
doas -u $user chsh -s /bin/zsh $user && \
rm -Rf /home/$user/bash*

rm -Rf /etc/pacman.d/mirrorlist-arch
doas -u $user paru -S --skipreview --noconfirm --needed artix-archlinux-support
curl -o /etc/pacman.d/mirrorlist-arch https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/pacman-mirrorlist/trunk/mirrorlist && \
sed -i 's/^#//' /etc/pacman.d/mirrorlist-arch && \

#cat <<EOL >> /etc/pacman.conf
# Arch
#[extra]
#Include = /etc/pacman.d/mirrorlist-arch
#
#[multilib]
#Include = /etc/pacman.d/mirrorlist-arch
#EOL

pacman -Sy --noconfirm archlinux-keyring artix-keyring && \
rm -r /etc/pacman.d/gnupg && \
pacman-key --init && \
pacman-key --populate archlinux artix
yay -Scc --noconfirm

#install 
doas -u $user paru -S --skipreview --noconfirm --needed fastfetch-git
fastfetch && sleep 10 &&
#doas -u $user paru -S --skipreview --needed acpi alsa-utils-openrc android-tools archlinux-keyring base base-devel brightnessctl-git btop-git cmatrix-git connman-openrc cryptsetup cryptsetup-openrc dhcpcd dwl-git efibootmgr element-desktop-git elogind-openrc fastfetch-git ffmpeg flatpak foot gimp git grim-git grub htop hyprland-git jdk-openjdk jre-openjdk keepassxc krita lf-git libdovi libreoffice-fresh linux-firmware linux-headers linux-zen lvm2 lvm2-openrc man-db mercury-browser-bin mkinitcpio mpd mpd-openrc mpv-git mpvpaper neovim-git noto-fonts-cjk nsnake-git oh-my-zsh-git opendoas openrc otf-font-awesome p7zip paru-git pipes-rs-git pipewire-alsa pipewire-openrc pipewire-pulse python-pip python-pipx python-pywalfox python-requests python-selenium pywal-git qt6-wayland rtorrent-vi-color rustdesk-bin slurp-git speedtest-go-git spotify-tui stunnel-openrc sway swaybg-git swayidle-git swayimg-git swaylock-effects-git tree vscodium-git w3m waybar wget windscribe-openrc wireplumber-openrc wpa_supplicant youtube-dl-git zzz
