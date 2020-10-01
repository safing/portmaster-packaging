FROM greyltc/archlinux-aur:latest

RUN pacman -Suyy --noconfirm && pacman -S --needed --noconfirm imagemagick libnetfilter_queue xz webkit2gtk

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
