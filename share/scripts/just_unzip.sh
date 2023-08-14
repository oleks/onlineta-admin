#!/usr/bin/env bash

set -euo pipefail
TA_LEVEL_GREETING=0
TA_LEVEL_STYLE=1
TA_LEVEL_BAD=2
TA_LEVEL_FATAL=255

origin="$(readlink -f "$(dirname "$0")")"
zipfile=${2:-handin.zip}

cd "$1"

function comment {
  python3 <<EOF
from ta.lib import *
ta_comment($1, "$2")
EOF
}

if [ ! -f "$zipfile" ]; then
  comment TA_LEVEL_GREETING "No $zipfile, I assume that we run locally."
  exit
fi

if ! file --mime-type $zipfile | grep application/zip > /dev/null ; then
  comment $TA_LEVEL_FATAL "$zipfile doesn't look like a ZIP archive to me!"
  exit $TA_LEVEL_FATAL
fi

if ! unzip -u $zipfile > /dev/null ; then
  comment $TA_LEVEL_FATAL "There's something weird about your $zipfile.."
  exit $TA_LEVEL_FATAL
fi
