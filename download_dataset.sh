#!/bin/bash

BASE_URL="http://data.law.di.unimi.it/webdata"
DATASETS="uk-2007-05 twitter-2010"
OUT_DIR="/var/scratch/ddps2017/datasets"

for dataset in $DATASETS; do
	for ext in .graph .properties; do
		file=$dataset$ext
		if [ ! -f $OUT_DIR/$file ]; then
			echo "Downloading $file"
			wget -q -O $OUT_DIR/$file $BASE_URL/$dataset/$file
		else
			echo "Skipping $file (already present)"
		fi
	done
done
