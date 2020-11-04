#!/usr/bin/bash
# Casarea main entry point

# Fail whenever an executed command fails or when a non-existing
# variable is expanded
set -eu

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <action>"
    echo "actions:"
    echo "- setup    download and extract dependencies and datasets"
    exit 1
fi

# Get the root of the project in order to find other files
export CASAREA_ROOT=$(realpath $(dirname $0))

# Check that the user has set the required configuration variables.
# The following variables are required:
# - CASAREA_DATADIR: The root of the directory where static data (software, datasets,
#   etc) should be stored
# - CASAREA_WORKDIR: The root of the directory where temporary information should
#   be stored during the program runtime
# - CASAREA_TEST_GRAPHS: The graphs which the tests should be performed on.
#   (useful to test with smaller graphs). These graphs are downloaded from
#   http://data.law.it.unimi.it/.
# - CASAREA_RUN_LOCAL: Schedule compute jobs locally instead of through prun
#   1 = run local
: $CASAREA_DATADIR
: $CASAREA_WORKDIR
: $CASAREA_TEST_GRAPHS
: $CASAREA_RUN_LOCAL

# Schedule a single job and wait for completion
# Uses prun if required otherwise runs the command locally
function schedule-single {
    if [ $CASAREA_RUN_LOCAL -eq 1 ]; then
        $@
    else
        prun -v -np 1 -1 $@
    fi
}

export -f schedule_single

# Set java path
export JAVA_HOME="$CASAREA_DATADIR/software/openjdk"

ACTION=$1
case $ACTION in
    setup)
        echo "Performing setup"
        $CASAREA_ROOT/setup-deps.sh
        $CASAREA_ROOT/setup-subprojects.sh
        $CASAREA_ROOT/setup-datasets.sh
        ;;
    *)
        echo "Invalid action '$ACTION'"
        exit 1
        ;;
esac
