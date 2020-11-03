# The root of the directory where static data (software, datasets, etc) should be stored
export CASAREA_DATADIR="/var/scratch/ddps2017/casarea/data"

# The root of the directory where temporary information should be stored during
# the program runtime
export CASAREA_WORKDIR="/var/scratch/ddps2017/casarea/work"

# The graphs which the tests should be performed on. (useful to test with smaller
# graphs). These graphs are downloaded from http://data.law.it.unimi.it/.
export CASAREA_TEST_GRAPHS="uk-2007-05 twitter-2010"

# Not used by casarea.sh but still useful to put here
export JAVA_HOME="$CASAREA_DATADIR/software/openjdk"
