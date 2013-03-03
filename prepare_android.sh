#!/bin/sh
# prepare_android.sh
# This script will prepare an Android Phone for flashing or wiping data by backing up all the data and optionally restoring it.
# USAGE:
#   -r  Restore backup after recovery
#   -h  Show help message
#   -s  Skip backup 
#   ?   Show help message
# Copyright Will Evans 2013

ADB_LOCATION=""

usage(){
cat << EOF
usage: $0 [-s] [-r] [-h] 

This script will prepare an Android Phone for flashing or wiping data by backing up all the data and optionally restoring it.
OPTIONS:
   -h      Show this message
   -r      Restore backup after recovery
   -s      Skip backup
EOF
}
process() {
  if [ ! $NOBACKUP ]; then
    read -p "Press [Enter] key to start backup..."
    $ADB_LOCATION backup -apk -all -f ./Backups/backup.ab
  fi
  read -p "Press [Enter] key to boot into Recovery mode..."
  $ADB_LOCATION reboot recovery
  if [ $RESTORE ]; then
    read -p "Press [Enter] key when Android is booted..."
    read -p "Press [Enter] key to restore data..."
    $ADB_LOCATION restore ./Backups/backup.ab
  fi
}

RESTORE=
NOBACKUP=

while getopts "shr" OPTION
do
     case $OPTION in
         h)
             usage
             exit 
             ;;
         r)
             RESTORE=1
             ;;
         s)
             NOBACKUP=1
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [ -z "$ADB_LOCATION" ]; then
  echo "Variable ADB_LOCATION not set in script..."
  echo "Enter the location of the ADB file and then press [Enter]..."
  read ADB_LOCATION
  if [ -z "$ADB_LOCATION" ]; then
    echo "Blank file location for ADB..."
    exit
  fi
  if [ ! -f $ADB_LOCATION ]; then
    echo "ADB file doesn't exist in specified location"
    exit
  fi
fi

echo "Prepare Android Phone for flashing or wiping data..."
read -p "Press [Enter] key once Nexus 4 is plugged in..."
if [ -d "./Backups" ]; then
  if [ -f "./Backups/backup.ab" ]; then
    mv ./Backups/backup.ab ./Backups/backup.`date +%d-%m-%y`.ab
    process
  else
    process
  fi
else
  mkdir Backups
  process
fi
