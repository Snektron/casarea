#!/usr/bin/bash
# This script downloads and converts required datasets
# It should be called from casarea.sh

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

# Compile the programs
"$CASAREA_DATADIR/software/gradle/bin/gradle" \
    -b "$CASAREA_ROOT/webgraph-extract/build.gradle" \
    --quiet \
    install

WEBGRAPH_EXTRACT="$CASAREA_ROOT/webgraph-extract/build/install/webgraph-extract/bin/webgraph-extract"

# Extract the edge list
for DATASET in $CASAREA_TEST_GRAPHS; do
    if [ ! -f "$CASAREA_DATADIR/datasets/$DATASET.edges" ]; then
        echo "Generating $DATASET.edges..."
        prun -v -np 1 -1 $WEBGRAPH_EXTRACT "$CASAREA_DATADIR/datasets/$DATASET" "$CASAREA_DATADIR/datasets/$DATASET.edges"
    fi
done
