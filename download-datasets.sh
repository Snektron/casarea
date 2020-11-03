#!/usr/bin/bash
# This script downloads required datasets
# It should be called from casarea.sh

BASE_URL="http://data.law.di.unimi.it/webdata"
mkdir -p "$CASAREA_DATA/datasets/"

for DATASET in $CASAREA_TEST_GRAPHS; do
    for EXT in .graph .properties; do
        FILE="$DATASET$EXT"
        OUT="$CASAREA_DATA/datasets/$FILE"
        wget -nc -q --show-progress -O $OUT "$BASE_URL/$DATASET/$FILE"
    done
done
