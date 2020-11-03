#!/usr/bin/bash
# Casarea main entry point

# Fail whenever an executed command fails or when a non-existing
# variable is expanded
set -e -u

# Check argument count
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <config-file.sh>"
    exit 0
fi

# Get the root of the project in order to find other files
export CASAREA_ROOT=$(realpath $(dirname $0))

# Get and source the config file the user passed via the arguments
# The configuration file should contain the following variables:
# - DATADIR: The root of the directory where static data (software, datasets,
#   etc) should be stored
# - WORKDIR: The root of the directory where temporary information should
#   be stored during the program runtime
# - TEST_GRAPHS: The graphs which the tests should be performed on.
#   (useful to test with smaller graphs). These graphs are downloaded from
#   http://data.law.it.unimi.it/.
# The script which sets these variables can make use of the following variables:
# - CASAREA_ROOT: The root directory of the casarea project
export CASAREA_CONFIG_FILE=$(realpath $1)
source $CASAREA_CONFIG_FILE

# Re-export the variables set in the configuration file
# This has a double working: both checking that the user has set everything,
# and exports the variables to sub scripts
export CASAREA_DATADIR=$DATADIR
export CASAREA_WORKDIR=$WORKDIR
export CASAREA_TEST_GRAPHS=$TEST_GRAPHS

# Set up the system
# Download software (skips existing files)
$CASAREA_ROOT/setup-deps.sh

# Set java path
export JAVA_HOME="$CASAREA_DATADIR/software/openjdk"

# Download datasets (skips existing files)
$CASAREA_ROOT/download-datasets.sh
