#!/bin/bash
#
# OpenIPC.org (c)
#

#
# Constants
#

MAX_KERNEL_SIZE=0x200000              #    2MiB,  2097152
MAX_KERNEL_SIZE_ULTIMATE=0x300000     #    3MiB,  3145728
MAX_KERNEL_SIZE_EXPERIMENTAL=0x3E8480 # ~3.9MiB,  4097152
MAX_ROOTFS_SIZE=0x500000              #    5MiB,  5242880
MAX_ROOTFS_SIZE_ULTIMATE=0xA00000     #   10MiB, 10485760
MAX_factory_t31_ZMC6tiIDQN_SIZE=5242880
MAX_UBOOT_SIZE=0x40000

_d=$(date +"%y.%m.%d")
OPENIPC_VER=$(echo OpenIPC v${_d:0:1}.${_d:1})
unset _d

SRC_CACHE_DIR="/tmp/buildroot_dl"
LOCK_FILE="$(pwd)/openipc.lock"

#
# Functions
#

echo_c() {
  # 30 grey, 31 red, 32 green, 33 yellow, 34 blue, 35 magenta, 36 cyan,37 white
  echo -e "\e[1;$1m$2\e[0m"
}

check_or_set_lock() {
  if [ -f "$LOCK_FILE" ] && ps -ax | grep "^\s*\b$(cat "$LOCK_FILE")\b" >/dev/null; then
    echo_c 31 "Another instance running with PID $(cat "$LOCK_FILE")."
    exit 1
  fi

  echo_c 32 "Starting OpenIPC builder."
  echo $$ >$LOCK_FILE
}

build_list_of_projects() {
  FUNCS=()
  AVAILABLE_PROJECTS=$(find br-ext-chip-*/configs/* -name "*_defconfig")
  local p
  for p in $AVAILABLE_PROJECTS; do
    p=${p##*/}; p=${p//_defconfig/}
    FUNCS+=($p)
  done
}

select_project() {
  if [ $# -eq 0 ]; then
    if [ -n "$(command -v fzf)" ]; then
      local entries=$(echo $AVAILABLE_PROJECTS | sed "s/ /\n/g" | fzf)
      [ -z "$entries" ] && echo_c 31 "Cancelled." && drop_lock_and_exit
      BOARD=$(echo $entries | cut -d / -f 3 | awk -F_ '{printf "%s_%s", $1, $2}')
    elif [ -n "$(command -v whiptail)" ]; then
      local cmd="whiptail --title \"Available projects\" --menu \"Please select a project from the list:\" --notags 20 76 12"
      local entry
      for entry in $AVAILABLE_PROJECTS; do
        local project=${entry##*/}; project=${project//_defconfig/}
        local vendor=${entry%%/*}; vendor=${vendor##*-}
        local flavor=${project##*_}
        local chip=${project%%_*}
        cmd="${cmd} \"${project}\" \"${vendor^} ${chip^^} ${flavor}\""
      done
      BOARD=$(eval "${cmd} 3>&1 1>&2 2>&3")
      [ $? != 0 ] && echo_c 31 "Cancelled." && drop_lock_and_exit
    else
      echo -ne "Usage: $0 <variant>\nVariants:"
      local i
      for i in "${FUNCS[@]}"; do echo -n " ${i}"; done
      echo
      drop_lock_and_exit
    fi
  else
    BOARD=$1
  fi
}

drop_lock_and_exit() {
  [ -f "$LOCK_FILE" ] && rm $LOCK_FILE
  exit 0
}

log_and_run() {
  local command=$1
  echo_c 35 "$command"
  $command
}

clone() {
  sudo apt-get update -y
  sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync unzip
  git clone --depth=1 https://github.com/OpenIPC/firmware.git
}

fresh() {
  BR_VER=$1

  if [ -d "$SRC_CACHE_DIR" ]; then
    echo_c 36 "Found cache directory."
  else
    echo_c 31 "Cache directory not found."
    echo_c 34 "Creating cache directory ..."
    log_and_run "mkdir -p ${SRC_CACHE_DIR}"
    echo_c 34 "Done.\n"
  fi

  if [ -d "buildroot-${BR_VER}" ]; then
    echo_c 36 "Found existing Buildroot directory."

    if [ -d "buildroot-${BR_VER}/dl" ]; then
      echo_c 36 "Found existing Buildroot downloads directory."
      echo_c 34 "Copying Buildroot downloads to cache directory ..."
      log_and_run "cp -rvf buildroot-${BR_VER}/dl/* ${SRC_CACHE_DIR}"
      echo_c 34 "Done.\n"
    fi

    echo_c 34 "Cleaning source directory."
    echo_c 35 "make distclean"
    make distclean
    echo_c 34 "Done.\n"
  else
    echo_c 31 "Buildroot sources not found."
  fi

  echo_c 34 "Downloading Buildroot sources to cache directory ..."
  log_and_run "curl --continue-at - --output ${SRC_CACHE_DIR}/buildroot-${BR_VER}.tar.gz https://buildroot.org/downloads/buildroot-${BR_VER}.tar.gz"
  echo_c 34 "Done.\n"

  echo_c 34 "Extracting a fresh copy of Buildroot from Buildroot sources ..."
  log_and_run "tar xvf ${SRC_CACHE_DIR}/buildroot-${BR_VER}.tar.gz"
  echo_c 34 "Done.\n"

  echo_c 34 "Copying cached source files back to Buildroot ..."
  log_and_run "mkdir -p buildroot-${BR_VER}/dl/"
  log_and_run "cp -rvf ${SRC_CACHE_DIR}/* buildroot-${BR_VER}/dl/"
  echo_c 34 "Done.\n"

  make prepare

  echo_c 33 "Start building OpenIPC Firmware ${OPENIPC_VER} for ${SOC}."
  echo "The start-stop times" >/tmp/openipc_buildtime.txt
  date >>/tmp/openipc_buildtime.txt
}

should_fit() {
  local filename=$1
  local maxsize=$2
  local filesize=$(stat --printf="%s" ./output/images/$filename)
  if [[ $filesize -gt $maxsize ]]; then
    export TG_NOTIFY="Warning: $filename is too large: $filesize vs $maxsize"
    echo_c 31 "Warning: $filename is too large: $filesize vs $maxsize"
    exit 1
  fi
}

rename() {
  pwd
  #should_fit uImage.noinitramfs $MAX_KERNEL_SIZE_ULTIMATE
  should_fit rootfs.squashfs $MAX_ROOTFS_SIZE_ULTIMATE
  #should_fit uImage $MAX_factory_t31_ZMC6tiIDQN_SIZE
  should_fit ../../output/build/uboot-2013.07/u-boot-lzo-with-spl.bin $MAX_UBOOT_SIZE
  cp ./output/images/uImage ./output/images/uImage.${SOC}
  cp ./output/images/rootfs.squashfs ./output/images/rootfs.squashfs.${SOC}
  cp ./output/build/uboot-2013.07/u-boot-lzo-with-spl.bin output/images/u-boot-lzo-with-spl.bin.${SOC}
  #cp ./output/images/u-boot.bin ./output/images/u-boot.bin.${SOC}
  #mv -v ./output/images/rootfs.cpio ./output/images/rootfs.${SOC}.cpio
  cp ./output/images/rootfs.tar ./output/images/rootfs.${SOC}.tar
  if [[ -f ~/upgrade.sh ]]; then
    echo "custom upgrade.sh found"
    cp ~/upgrade.sh ./output/images/upgrade.sh
  else
    cp ./scripts/upgrade.sh ./output/images/upgrade.sh
  fi

  date >>/tmp/openipc_buildtime.txt
  echo_c 31 "\n\n$(cat /tmp/openipc_buildtime.txt)\n\n"
}

build_nor_img() {
  #echo_c 34 "\nMaking nor u-boot image"
  #./output/host/bin/mkimage -A arm -O linux -T firmware -n "$OPENIPC_VER" \
  #  -a 0x0 -e 0x50000 -d ./output/images/u-boot.bin.${SOC} \
  #  ./output/images/autoupdate-uboot.img

  #echo_c 34 "\nMaking nor kernel image"
  #./output/host/bin/mkimage -A arm -O linux -T kernel -C none -n "$OPENIPC_VER" \
  #  -a 0x50000 -e 0x250000 -d ./output/images/uImage.${SOC} \
  #  ./output/images/autoupdate-kernel.img

  #echo_c 34 "\nMaking nor rootfs image"
  #./output/host/bin/mkimage -A arm -O linux -T filesystem -n "$OPENIPC_VER" \
  #  -a 0x250000 -e 0x750000 -d ./output/images/rootfs.squashfs.${SOC} \
  #  ./output/images/autoupdate-rootfs.img

  echo_c 34 "\nMaking nor flash image"
  tr '\0' '\377' < /dev/zero | dd bs=1024 count=16384 of=./output/images/nor_full.bin
  dd conv=notrunc if=./output/images/u-boot-lzo-with-spl.bin.${SOC} seek=$((0x0)) of=./output/images/nor_full.bin bs=1
  dd conv=notrunc if=./output/images/uImage.${SOC} seek=$((0x50000)) of=./output/images/nor_full.bin bs=1
  dd conv=notrunc if=./output/images/rootfs.squashfs.${SOC}  seek=$((0x350000)) of=./output/images/nor_full.bin bs=1

  echo "Done!"
}

build_mmc_img() {
  #echo_c 34 "\nMaking factory_t31_ZMC6tiIDQN"
    #cp ./output/images/uImage ./output/images/factory_t31_ZMC6tiIDQN
    #echo "Done!"

  echo_c 34 "\nMaking mmc card image"
    rm -f output/images/wyrecam_install.img
    fallocate -l 50M output/images/wyrecam_install.img
guestfish -a output/images/wyrecam_install.img <<_EOF_
    run
    #part-disk /dev/sda msdos
    part-init /dev/sda msdos
    part-add /dev/sda p 1 102399
    part-set-mbr-id /dev/sda 1 0x0b
    #part-set-name /dev/sda 1 WYRECAM
    #part-add /dev/sda p 51201 -1
    mkfs fat /dev/sda1
    #mkfs ext2 /dev/sda2
    mount /dev/sda1 /
    mkdir /spi_backups
    copy-in factory_t31_ZMC6tiIDQN /
    copy-in output/images/nor_full.bin /
    copy-in output/images/upgrade.sh /
    umount /
    #mount /dev/sda2 /
    #tar-in install/rootfs.tar.gz / compress:gzip
    #umount /
_EOF_
    echo "Done!"
}

copy_function() {
  test -n "$(declare -f "$1")" || return
  eval "${_/$1/$2}"
}

uni_build() {
  [ -z "$BOARD" ] && BOARD=$FUNCNAME

  SOC=$(echo $BOARD | cut -d '_' -f 1)

  set -e
  if [ "$(echo $BOARD | cut -sd '_' -f 2)" == "" ]; then
    BOARD="${BOARD}_lite"
  fi

  echo_c 33 "\n  SoC: $SOC\nBoard: $BOARD\n"

  if [ "all" = "${COMMAND}" ]; then
    fresh $(make BOARD=${BOARD} buildroot-version)
  fi

  log_and_run "make BOARD=${BOARD} ${COMMAND}"

  if [ "all" == "${COMMAND}" ]; then
    rename
    build_nor_img
    build_mmc_img
  fi
}

#######

check_or_set_lock

build_list_of_projects

if [ -n "$1" ]; then
  BOARD=$1
else
  select_project
fi

[ -z "$BOARD" ] && echo_c 31 "Nothing selected." && drop_lock_and_exit

COMMAND=$2
[ -z "$COMMAND" ] && COMMAND=all

for i in "${FUNCS[@]}"; do
  copy_function uni_build $i
done

echo_c 37 "Building OpenIPC for ${BOARD}"
uni_build $BOARD $COMMAND

drop_lock_and_exit
