#!/usr/bin/env bash

set -euo pipefail

origin="$(readlink -f "$(dirname "$0")")"
zipfile=${2:-handin.zip}
dirname=${3:-src}

cd "$1"

function comment {
  python3 <<EOF
from ta.lib import *
ta_comment($1, "$2")
EOF
}

if [ -d $dirname ]; then
    exit # If run locally
fi

if [ ! -f "$zipfile" ]; then
  comment 255 "$zipfile missing.."
  exit 255
fi

if ! file --mime-type $zipfile | grep application/zip > /dev/null ; then
  comment 255 "$zipfile doesn't look like a ZIP archive to me!"
  exit 255
fi

mkdir output

if ! unzip $zipfile -d output > /dev/null ; then
  comment 255 "There's something weird about your $zipfile.."
  exit 255
fi

if [ ! -d output/$dirname ];then
  comment 255 "$zipfile should contain a $dirname directory"
  exit 255
fi

mv output/$dirname .
rm -rf output

find $dirname -type f -exec "${origin}/gc.sh" {} \;
