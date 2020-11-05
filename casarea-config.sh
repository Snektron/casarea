# The root of the directory where static data (software, datasets, etc) should be stored
export CASAREA_DATADIR=$(realpath data)

# The root of the directory where temporary information should be stored during
# the program runtime
export CASAREA_WORKDIR=$(realpath work)

# The graphs which the tests should be performed on. (useful to test with smaller
# graphs). These graphs are downloaded from http://data.law.it.unimi.it/.
export CASAREA_TEST_GRAPHS="uk-2014-host uk-2014-tpd"

# Whether compute jobs should be run locally or through prun
export CASAREA_RUN_LOCAL=1

# Number of times tests should be repeated
export CASAREA_REPETITIONS=5

# Number of cores the spark tests should be ran on
export CASAREA_CORE_TESTS="" 

# The timeout for every spark job
export CASAREA_PRUN_TIMEOUT="00:15:00"

# Not used by casarea.sh but still useful to put here
export JAVA_HOME="$CASAREA_DATADIR/software/openjdk"
export PATH="$PATH:$CASAREA_DATADIR/software/gradle/bin/"
