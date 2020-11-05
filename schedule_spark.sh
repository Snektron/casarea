#!/usr/bin/bash

set -eu

N_CORES_PER_NODE=32

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <cores> <timeout> <pagerank | label> <dataset>"
    exit 1
fi

if [ "$1" -lt 1 ]; then
    echo "Must reserve at least 1 core"
    exit 1
fi

N_CORES=$1
N_NODES=$((($N_CORES + $N_CORES_PER_NODE - 1) / $N_CORES_PER_NODE))

# Reserve nodes
RESERVATION_ID=$(preserve -np $N_NODES -t "$2" | grep 'Reservation number' | cut -d' ' -f3 | cut -d':' -f1)
trap "preserve -c $RESERVATION_ID" EXIT

echo "[$RESERVATION_ID] Reserved $N_NODES node(s)"

# Wait for nodes to become available
echo "[$RESERVATION_ID] Waiting for nodes..."
while [ $(preserve -llist | awk -F'\t' "{if(\$1 == $RESERVATION_ID){print \$7}}") != 'R' ]; do
    sleep 1
done

# Execution started
echo "[$RESERVATION_ID] Nodes available, fetching IP addresses"

MASTER=""
SLAVES=""
for NODE in $(preserve -llist | awk -F'\t' "{if(\$1 == $RESERVATION_ID){print \$9}}"); do
    IP=$(ssh $NODE 'ip a' | grep 'inet 10.149' | awk -F' ' '{print $2}' | cut -d'/' -f1)
    if [ -z "$MASTER" ]; then
        MASTER=$IP
    elif [ -z "$SLAVES" ]; then
        SLAVES="$IP"
    else
        SLAVES="$SLAVES $IP"
    fi
done

echo "[$RESERVATION_ID] IP(s): $MASTER $SLAVES"
NODES="$MASTER $SLAVES"

ssh $MASTER \
    JAVA_HOME="$JAVA_HOME" \
    "$CASAREA_DATADIR/software/spark/sbin/start-master.sh" \
        --host "$MASTER"

for NODE in $NODES; do
    ssh $NODE \
        JAVA_HOME="$JAVA_HOME" \
        "$CASAREA_DATADIR/software/spark/sbin/start-slave.sh" \
            "spark://$MASTER:7077" \
        &
done
wait

TASK="$3"
DATASET="$4"

ssh $MASTER \
    JAVA_HOME="$JAVA_HOME" \
    "$CASAREA_DATADIR/software/spark/bin/spark-submit" \
        --class space.pythons.spark.Main \
        --master "spark://$MASTER:7077" \
        --executor-memory 60G \
        --total-executor-cores $N_CORES \
        "$CASAREA_ROOT/spark/build/install/spark/lib/spark.jar" \
        $TASK \
        "$CASAREA_DATADIR/datasets/$DATASET.edges" \
    >> "$CASAREA_WORKDIR/$TASK-spark-$N_CORES-$DATASET.txt"
