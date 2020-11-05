#!/usr/bin/bash
# Casarea main entry point

# Fail whenever an executed command fails or when a non-existing
# variable is expanded
set -eu

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <action>"
    echo "actions:"
    echo "- setup          Download and extract dependencies and datasets."
    echo "- test-single    Perform single-core benchmarks."
    echo "- test-spark     Perform spark benchmarks."
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
# - CASAREA_REPETITIONS: The number of times tests should be repeated
# - CASAREA_CORE_TESTS: Numbers of cores that tests should be performed on
# - CASAREA_PRUN_TUNEOUT: The timeout for every spark job
: $CASAREA_DATADIR
: $CASAREA_WORKDIR
: $CASAREA_TEST_GRAPHS
: $CASAREA_RUN_LOCAL
: $CASAREA_REPETITIONS
: $CASAREA_CORE_TESTS

rm -rf "$CASAREA_WORKDIR"
mkdir -p "$CASAREA_DATADIR"
mkdir -p "$CASAREA_WORKDIR"


# Schedule a single job and wait for completion
# Uses prun if required otherwise runs the command locally

function test-single {
    for DATASET in $CASAREA_TEST_GRAPHS; do
        for TASK in pagerank label; do
            for I in $(seq $CASAREA_REPETITIONS); do
                "$CASAREA_ROOT/schedule_single.sh" \
                    "$CASAREA_WORKDIR/$TASK-single-$DATASET.txt" \
                    "$CASAREA_ROOT/single/single" \
                             $TASK \
                            "$CASAREA_DATADIR/datasets/$DATASET.edges" \
                    &
            done
        done
    done

    wait
}

function test-spark {
    for DATASET in $CASAREA_TEST_GRAPHS; do
        for TASK in pagerank label; do
            for N_CORES in $CASAREA_CORE_TESTS; do
                for I in $(seq $CASAREA_REPETITIONS); do
                    "$CASAREA_ROOT/schedule_spark.sh" \
                        $N_CORES \
                        $CASAREA_PRUN_TIMEOUT \
                        $TASK \
                        $DATASET \
                        &
                done
            done
        done
    done

    wait
}

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
    test-single)
        test-single
        ;;
    test-spark)
        test-spark
        ;;
    *)
        echo "Invalid action '$ACTION'"
        exit 1
        ;;
esac
