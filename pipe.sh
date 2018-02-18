#!/bin/bash
SDIR="$( cd "$( dirname "$0" )" && pwd )"

SCRIPT_VERSION=$(git --git-dir=$SDIR/.git --work-tree=$SDIR describe --always --long)
PIPENAME=OctadsV2

##
# Process command args

TAG=q$PIPENAME

COMMAND_LINE=$*
function usage {
    echo
    echo "version=$SCRIPT_VERSION"
    echo "usage: $PIPENAME/pipe.sh Proj_0000_sample_mapping.txt"
    echo
    exit
}

while getopts "s:hg" opt; do
    case $opt in
        h)
            usage
            ;;
        \?)
            usage
            ;;
    esac
done

shift $((OPTIND - 1))
if [ "$#" -lt "1" ]; then
    usage
fi

MAPPINGFILE=$(readlink -e $1)

mkdir SK1
cd SK1
$SDIR/PEMapper/runPEMapperMultiDirectories.sh sacCer_SK1 $MAPPINGFILE >../log_SK1
cd ..
mkdir S288C
cd S288C
$SDIR/PEMapper/runPEMapperMultiDirectories.sh sacCer_S288C $MAPPINGFILE >../log_S288C
cd ..
