#!/bin/bash

# Copyright 2016
# Ubiquitous Knowledge Processing (UKP) Lab
# Technische Universität Darmstadt
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script takes an AMT results file and determines how many rejected
# assignments there are for each HIT.  Then it adds a corresponding number
# of assignments for those HITs.

usage() {
    echo "Usage: $0 [ -s ] <file.result>"
    echo
    echo "  -s	run against the AMT developer sandbox environment"
    echo "  -h	how many hours to extend the expiration date of the HITs"
}

while getopts ":s" opt; do
    case "$opt" in
	s)
	    sandbox="-sandbox"
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done
shift $((OPTIND-1))

if [ $# != 1 ]; then
    usage
    exit 1
fi

resultfile=$1

if [ ! -r "$resultfile" ]; then
    echo "Can't open $resutfile"
    exit 1
fi

approvefile="$(mktemp)"
echo -e "assignmentIdToApprove\tassignmentIdToApproveComment" > "$approvefile"

cut -f19,21 "$resultfile" \
    | fgrep "Submitted" \
    | cut -f1 \
    | sed 's/$/\t/' \
	   >> "$approvefile"

./approveWork.sh "$sandbox" -approvefile "$approvefile"
rm "$approvefile"
