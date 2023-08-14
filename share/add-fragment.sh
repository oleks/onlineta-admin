#!/usr/bin/env bash

set -euo pipefail

test_name="$1"

grep tests/$test_name/fragment.html index.fragments || printf "%s\n%s" "tests/$test_name/fragment.html" "$(cat index.fragments)" > index.fragments
