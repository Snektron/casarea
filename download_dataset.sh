#!/bin/bash

BASE_URL="http://law.di.unimi.it/webdata"
DATASETS="uk-2007-05 twitter-2010"

for dataset in $DATSETS; do
	for ext in .graph .properties; do
		wget $BASE_URL/$dataset$ext -P datasets/
	done
done
