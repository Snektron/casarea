#!/bin/bash

# Check arguments
if [ -z "$1" ]; then
    echo No ip configuration file given
    exit
fi

if [ -z "$2" ]; then
    echo No number of nodes given
    exit
fi

if [ -z "$3" ]; then
    echo No timeout given
    exit
fi

# Reserve nodes
RESERVATION_ID=`preserve -np $2 -t "$3" | grep 'Reservation number' | cut -d' ' -f3 | cut -d':' -f1`

# Wait for execution to start
sleep 1
echo Reservation: $RESERVATION_ID

while [ `preserve -llist | awk -F'\t' "{if(\\\$1 == $RESERVATION_ID) {print \\\$0}}" | cut -d$'\t' -f7` != 'R' ]; do
    echo Waiting
    sleep 1
done

# Fetch IP addresses of reserved nodes
echo Fetching ip addresses
for i in `preserve -llist | awk -F'\t' "{if(\\\$1 == $RESERVATION_ID) {print \\\$9}}"`; do
    ssh $i 'ip a' | grep 10.149 | awk -F' ' '{print $2}' | cut -d'/' -f1
done > $1

# Execute commands


# Cleanup reservation
echo Done
preserve -c $RESERVATION_ID
