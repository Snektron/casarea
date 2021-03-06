#!/usr/bin/bash
# This script downloads and converts required datasets
# It should be called from casarea.sh

set -eu

# Fetch datasets
BASE_URL="http://data.law.di.unimi.it/webdata"
mkdir -p "$CASAREA_DATADIR/datasets/"

for DATASET in $CASAREA_TEST_GRAPHS; do
    for EXT in .graph .properties; do
        FILE="$DATASET$EXT"
        OUT="$CASAREA_DATADIR/datasets/$FILE"
        wget -nc -q -O $OUT "$BASE_URL/$DATASET/$FILE" || true
    done
done

# Convert to edges format
# This is a binary format, where each edge consists of 2 uint32_t's of id's
# The edge list is split up into multiple files so that it may be parallelized more easily
WEBGRAPH_EXTRACT="$CASAREA_ROOT/webgraph-extract/build/install/webgraph-extract/bin/webgraph-extract"

# Extract the edge list
PIDS=""
for DATASET in $CASAREA_TEST_GRAPHS; do
    if [ ! -f "$CASAREA_DATADIR/datasets/$DATASET.edges" ]; then
        ./schedule_single.sh \
            "" \
            $WEBGRAPH_EXTRACT \
                "$CASAREA_DATADIR/datasets/$DATASET" \
                "$CASAREA_DATADIR/datasets/$DATASET.edges" \
            &
        PIDS="$PIDS $!"
    fi
done

if [ ! -z "$PIDS" ]; then
    echo "Waiting for generation processes to finish..."
    wait $PIDS
fi
