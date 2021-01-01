#!/bin/bash -x

set -e
set -u

IS_RECORD="n"
IS_REPLAY="n"
OUTPUT_LOG_FNAME="output.log"
TMP_LOG_FNAME="tmp.log"

# option
while getopts rp OPT
do
    case $OPT in
        "r" ) IS_RECORD="y"
          shift;;
        "p" ) IS_REPLAY="y"
          shift;;
    esac
done

if [ $IS_RECORD != "n"  ];then
    ############
    ##        ##
    ## record ##
    ##        ##
    ############
    echo "RECORD command:[$*], see $OUTPUT_LOG_FNAME"
    echo "$*" | xargs bash -c 'printf "%s %s\n" "$(date +%Y%m%d%H%M%S%N)" "$*"' bash 2>&1 | tee $OUTPUT_LOG_FNAME
    $* | xargs -L 1 bash -c 'printf "%s %s\n" "$(date +%Y%m%d%H%M%S%N)" "$*"' bash 2>&1 | tee $TMP_LOG_FNAME
    cat $TMP_LOG_FNAME >> $OUTPUT_LOG_FNAME
    rm $TMP_LOG_FNAME
    echo "record replay log: $OUTPUT_LOG_FNAME"

elif [ $IS_REPLAY != "n"  ];then
    ############
    ##        ##
    ## replay ##
    ##        ##
    ############
    echo "REPLAY command:[`head -1 $OUTPUT_LOG_FNAME`]"
    PREV_TIME=`head -1 $OUTPUT_LOG_FNAME | cut -d' ' -f1`
    while read line; do
    CURRENT_TIME=`echo $line | cut -d' ' -f1`
    TMP=`echo $((CURRENT_TIME-PREV_TIME))`
    TIME_DIFF=`echo "scale=5; $TMP / 1000000000.0" | bc`
    PREV_TIME=$CURRENT_TIME
    COMMAND_LOG=`echo $line | cut -d' ' -f2-`

    #echo "$TIME_DIFF $COMMAND_LOG"
    echo "$COMMAND_LOG"
    sleep $TIME_DIFF

    done < $OUTPUT_LOG_FNAME
fi
