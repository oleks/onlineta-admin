#!/usr/bin/env bash

set -euo pipefail
touch index.fragments
cat share/header.html $(cat index.fragments) share/footer.html > ~/static/index.html
