#! /bin/bash

USE_TIMESTAMP=0
LOG_RESULT=0

while [ "$1" != "" ]; do
  case $1 in
    -l | --log-result )
      LOG_RESULT=1      
      ;;
    -t | --timestamp )
      USE_TIMESTAMP=1
      ;;
  esac
  shift
done

echo "QuixBugs_oneLinerFix.sh start"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
QUIXBUGS_DIR=$CURRENT_DIR/QuixBugs_projects
# CONTINUOUS_LEARNING_DATA=$CURRENT_DIR/../Continuous_Learning/public/single_run_data

echo "Creating directory 'QuixBugs_projects'"
mkdir -p $QUIXBUGS_DIR
echo

if [ $USE_TIMESTAMP -eq 1 ]; then
  TIMESTAMP=`date +"%d%m%Y-%H%M"`
  QUIXBUGS_PATCHES_DIR=$CURRENT_DIR/QuixBugs_patches/$TIMESTAMP
else
  QUIXBUGS_PATCHES_DIR=$CURRENT_DIR/QuixBugs_patches
fi

echo "Creating directory 'QuixBugs_patches'"
mkdir -p $QUIXBUGS_PATCHES_DIR
echo

echo "Reading from Quixbugs_metadata.csv"
while IFS=, read -r col1 col2 col3 col4 col5
do
  BUG_PROJECT=${QUIXBUGS_DIR}/${col2}
  mkdir -p $BUG_PROJECT
  echo "Checking out ${col2} to ${BUG_PROJECT}"
  cp "/content/QuixBugs/java_programs/${col2}.java" $BUG_PROJECT
  echo

  echo "Generating patches for ${col2}"
  $CURRENT_DIR/../sequencer-predict.sh --model=/content/sequencer/model/model.pt --buggy_file="${BUG_PROJECT}/${col2}.java" --buggy_line=$col4 --beam_size=50 --output=$QUIXBUGS_PATCHES_DIR/${col2}
  echo

  # echo "Running test on all patches for ${col2}"
  # python3 $CURRENT_DIR/validatePatch.py $QUIXBUGS_PATCHES_DIR/${col2} $BUG_PROJECT $BUG_PROJECT/$col3
  # echo

  # echo "Deleting ${BUG_PROJECT}"
  # rm -rf $BUG_PROJECT
  # echo
done < Quixbugs_metadata.csv

# echo "Deleting Defects4J_projects"
# rm -rf $QUIXBUGS_DIR
# echo

# if [ $LOG_RESULT -eq 1 ]; then
#   CREATED=`find $QUIXBUGS_PATCHES_DIR -name '*' -type d | wc -l | awk '{print $1}'`
#   COMPILED=`find $QUIXBUGS_PATCHES_DIR -name '*_compiled' | wc -l | awk '{print $1}'`
#   PASSED=`find $QUIXBUGS_PATCHES_DIR -name '*_passed' | wc -l | awk '{print $1}'`
#   echo "$CREATED,$COMPILED,$PASSED,$TIMESTAMP" > $CONTINUOUS_LEARNING_DATA
# fi

# echo "Found $(find $QUIXBUGS_PATCHES_DIR -name '*_passed' | wc -l | awk '{print $1}') test-suite adequate patches in total."
# echo "Found passing patches for $(find $QUIXBUGS_PATCHES_DIR -name '*_passed' -exec dirname {} \; | sort -u | wc -l | awk '{print $1}') projects"
# echo "Defects4J_oneLinerFix.sh done"
# echo
# exit 0
