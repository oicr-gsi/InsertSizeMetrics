#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

cd $1

find . -regex '.*\.txt$' -printf "%f " -exec sh -c "cat {} | tail -n +5 | md5sum" \;
find . -regex '.*\.pdf$' -printf "%f " -exec sh -c "cat {} | tail -n +7 | md5sum" \;
