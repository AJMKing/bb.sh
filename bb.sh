#!/bin/bash

set -euo pipefail
MOUNT=/scratch
FILE=./loop.dat
SIZE=1024
OWNER=$USER

show_help () {
    echo "Usage: $0 [-m : make a burst buffer] [-O {owner} : owner of the bb eg $USER] [ -s {size} : size of the bb ] "
}

make_bb () {
    if [[ ! -f "$FILE" ]]; then
        dd if=/dev/zero of=./loop.dat bs=${SIZE}M count=1 oflag=direct status=progress
        mkfs.xfs -f $FILE
    fi

    if [[ ! -d "$MOUNT" ]]; then
        mkdir $MOUNT
    fi

    if [[ -f "$FILE" ]]; then
        chmod 755 $MOUNT
        chown $OWNER $MOUNT
        mount -o loop,rw $FILE $MOUNT
        losetup -a | grep $FILE
        mount | grep $FILE
    fi
}

unmount() {
    umount $MOUNT
}


while getopts "h?mu:s:O" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    O)
      OWNER="${OPTARG:-}"
      ;;
    s)
      SIZE="${OPTARG:-}"
      ;;
    m)
      make_bb
      ;;
    u)
      unmount
      ;;
  esac
done
