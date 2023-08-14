#!/usr/bin/env bash

set -euo pipefail

function comment {
  python3 <<EOF
from ta.lib import *
ta_comment($1, """$2""")
EOF
}

path=$1

if file "${path}" | grep -q -v "\btext\b"; then
  comment 1 "${path} doesn't look like source code, purging.
Consider purging this before submitting to a human."
  rm "${path}"
fi
