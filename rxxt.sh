#!/bin/sh

RXXTFS_DIR=$(pwd)
export PATH=$PATH:~/.local/usr/bin
max_retries=50
timeout=1
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  printf "Unsupported CPU architecture: ${ARCH}"
  exit 1
fi

if [ ! -e $RXXTFS_DIR/.installed ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                      Foxytoux INSTALLER"
  echo "#"
  echo "#                           Copyright (C) 2024, RecodeStudios.Cloud"
  echo "#"
  echo "#"
  echo "#######################################################################################"

  read -p "Do you want to install Ubuntu? (YES/no): " install_ubuntu
fi

case $install_ubuntu in
  [yY][eE][sS])
    wget --tries=$max_retries --timeout=$timeout --no-hsts -O /tmp/rxxtfs.tar.gz \
      "http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.4-base-${ARCH_ALT}.tar.gz"
    tar -xf /tmp/rxxtfs.tar.gz -C $RXXTFS_DIR
    ;;
  *)
    echo "Skipping Ubuntu installation."
    ;;
esac

if [ ! -e $RXXTFS_DIR/.installed ]; then
  mkdir $RXXTFS_DIR/usr/local/bin -p
  wget --tries=$max_retries --timeout=$timeout --no-hsts -O $RXXTFS_DIR/usr/local/bin/prxxt "https://raw.githubusercontent.com/SecretGogeta/freerxxt/main/prxxt-${ARCH}"

  while [ ! -s "$RXXTFS_DIR/usr/local/bin/prxxt" ]; do
    rm $RXXTFS_DIR/usr/local/bin/prxxt -rf
    wget --tries=$max_retries --timeout=$timeout --no-hsts -O $RXXTFS_DIR/usr/local/bin/prxxt "https://raw.githubusercontent.com/SecretGogeta/freerxxt/main/prxxt-${ARCH}"

    if [ -s "$RXXTFS_DIR/usr/local/bin/prxxt" ]; then
      chmod 755 $RXXTFS_DIR/usr/local/bin/prxxt
      break
    fi

    chmod 755 $RXXTFS_DIR/usr/local/bin/prxxt
    sleep 1
  done

  chmod 755 $RXXTFS_DIR/usr/local/bin/prxxt
fi

if [ ! -e $RXXTFS_DIR/.installed ]; then
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > ${RXXTFS_DIR}/etc/resolv.conf
  rm -rf /tmp/rxxtfs.tar.gz /tmp/sbin
  touch $RXXTFS_DIR/.installed
fi

CYAN='\e[0;36m'
WHITE='\e[0;37m'

RESET_COLOR='\e[0m'

display_gg() {
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
  echo -e ""
  echo -e "           ${CYAN}-----> Mission Completed ! <----${RESET_COLOR}"
}

clear
display_gg

$RXXTFS_DIR/usr/local/bin/prxxt \
  --rxxtfs="${RXXTFS_DIR}" \
  -0 -w "/rxxt" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit
