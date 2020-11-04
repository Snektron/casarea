#!/bin/bash

if [ -z "$1" ]; then
    OUTPUT_FILE="/dev/null"
else
    OUTPUT_FILE="$1"
fi
shift

if [ $CASAREA_RUN_LOCAL -eq 1 ]; then
    $@
else
    prun -v -np 1 -1 $@ >> "$OUTPUT_FILE"
fi
