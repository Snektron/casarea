#!/usr/bin/bash
# This script compiles subprojects such as the webgraph extractor, and spark/c++ implementations
# It should be called from casarea.sh

set -eu

# Compile webgraph-extract
"$CASAREA_DATADIR/software/gradle/bin/gradle" \
    -b "$CASAREA_ROOT/webgraph-extract/build.gradle" \
    --quiet \
    install

# Compile the spark implementation
"$CASAREA_DATADIR/software/gradle/bin/gradle" \
    -b "$CASAREA_ROOT/spark/build.gradle" \
    --quiet \
    install

# Compile the single-core implementation
make -C "$CASAREA_ROOT/single/" --quiet
