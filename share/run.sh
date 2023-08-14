#!/usr/bin/env bash

set -euo pipefail

base=`python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$(dirname "$0")"`

SUBMISSION=`python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$1"`

export PYTHONPATH="$base/lib"

"$base"/test.py "${SUBMISSION}"
