#!/usr/bin/env bash

TA_LEVEL_GREETING=0
TA_LEVEL_STYLE=1
TA_LEVEL_BAD=2
TA_LEVEL_FATAL=255

function comment {
    python3 <<EOF
from ta.lib import *
ta_comment($1, "$2")
EOF
}

must_have() {
    for f in $*; do
        if [ ! -f $f ]; then
            comment TA_LEVEL_FATAL "Your hand-in should contain a $f."
            exit $TA_LEVEL_FATAL
        else
            comment TA_LEVEL_GREETING "You have a $f. Good."
        fi
    done
}

must_have_exactly_one_of() {
    count=0
    for f in $*; do
        if [ -f $f ]; then
            count+=1
        fi
    done

    if (( count != 1 )); then
        comment TA_LEVEL_FATAL "Your hand-in must contain (exactly) one of $*"
        exit $TA_LEVEL_FATAL
    else
        comment TA_LEVEL_GREETING "You have one of $*. Good."
    fi
}

must_not_have_any() {
    find . -name "$1" | while read -r f; do
        comment TA_LEVEL_FATAL "Please do not include $1."
        exit $TA_LEVEL_FATAL
    done
}
