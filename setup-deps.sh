#!/usr/bin/bash
# This script downloads required software
# It should be called from casarea.sh

set -eu

CASAREA_JAVA_URL="https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz"
CASAREA_GRADLE_URL="https://downloads.gradle-dn.com/distributions/gradle-6.7-bin.zip"
CASAREA_SPARK_URL="https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop2.7.tgz"

# Download and extract java if required
if [ ! -d $CASAREA_DATADIR/software/openjdk ]; then
    echo "Setting up Java"
    mkdir -p "$CASAREA_DATADIR/software/openjdk"
    wget -q \
        -O "$CASAREA_DATADIR/software/openjdk.tar.gz" \
        $CASAREA_JAVA_URL
    echo "Extracting..."
    tar xf $CASAREA_DATADIR/software/openjdk.tar.gz \
        --directory $CASAREA_DATADIR/software/openjdk/ \
        --strip-components 1
    rm "$CASAREA_DATADIR/software/openjdk.tar.gz"
fi

# Download and extract gradle if required
if [ ! -d $CASAREA_DATADIR/software/gradle ]; then
    echo "Setting up Gradle..."
    mkdir -p "$CASAREA_DATADIR/software/"
    wget -q \
        -O "$CASAREA_DATADIR/software/gradle.zip" \
        $CASAREA_GRADLE_URL
    echo "Extracting..."
    unzip -q "$CASAREA_DATADIR/software/gradle.zip" \
        -d "$CASAREA_DATADIR/software/"
    rm "$CASAREA_DATADIR/software/gradle.zip"
    # Fix up directory name
    mv "$CASAREA_DATADIR/software/gradle-6.7" "$CASAREA_DATADIR/software/gradle"
fi

# Download and extract spark if required
if [ ! -d $CASAREA_DATADIR/software/spark ]; then
    echo "Setting up Spark..."
    mkdir -p "$CASAREA_DATADIR/software/spark/"
    wget -q \
        -O "$CASAREA_DATADIR/software/spark.tar.gz" \
        $CASAREA_SPARK_URL
    echo "Extracting..."
    tar xf $CASAREA_DATADIR/software/spark.tar.gz \
        --directory $CASAREA_DATADIR/software/spark/ \
        --strip-components 1
    rm "$CASAREA_DATADIR/software/spark.tar.gz"
fi
