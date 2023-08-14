#!/usr/bin/env bash
#
# Deploy the tests for an assignment to production.

set -xeuo pipefail

test_name="$1"
docker_image="$2"

HOST=onlineta@os164.hpc.ku.dk
JUMPHOST=mist@os236.hpc.ku.dk

#ssh ${HOST} rm -rf tests/$n/
ssh -J${JUMPHOST} ${HOST} mkdir -p tests/$test_name/
rsync -av --delete --exclude="*~" --exclude='__pycache__' -e "ssh -A -J$JUMPHOST" . ${HOST}:tests/$test_name/
ssh -J${JUMPHOST} ${HOST} docker build -t $docker_image tests/$test_name
ssh -J${JUMPHOST} ${HOST} touch index.fragments
ssh -J${JUMPHOST} ${HOST} share/add-fragment.sh $test_name
ssh -J${JUMPHOST} ${HOST} share/build-index.sh
