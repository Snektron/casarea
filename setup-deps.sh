#!/usr/bin/bash
# This script downloads required software
# It should be called from casarea.sh

CASAREA_SPARK_URL="https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop2.7.tgz"

# Download and extract spark if required
if [ ! -d $CASAREA_DATADIR/software/spark ]; then
    echo "Setting up Spark..."
    mkdir -p $CASAREA_DATADIR/software/spark
    wget -q --show-progress \
        -O "$CASAREA_DATADIR/software/spark.tar.gz" \
        $CASAREA_SPARK_URL
    echo "Extracting..."
    tar xf $CASAREA_DATADIR/software/spark.tar.gz \
        --directory $CASAREA_DATADIR/software/spark/ \
        --strip-components 1
    rm $CASAREA_DATADIR/software/spark.tar.gz
fi
