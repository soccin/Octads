#!/bin/bash
SDIR="$( cd "$( dirname "$0" )" && pwd )"

SCRIPT_VERSION=$(git --git-dir=$SDIR/.git --work-tree=$SDIR describe --always --long)
PIPENAME="PIPENAME"

##
# Process command args

TAG=q$PIPENAME

COMMAND_LINE=$*
function usage {
    echo
    echo "usage: $PIPENAME/pipe.sh <<ARGS>>"
    echo "version=$SCRIPT_VERSION"
    echo "    <<ARGS>>"
    echo
    exit
}

while getopts "s:hg" opt; do
    case $opt in
        s)
            ARG_S=$OPTARG
            ;;
        h)
            usage
            ;;
        g)
            echo Currently defined genomes
            echo
            ls -1 $SDIR/lib/genomes
            echo
            exit
            ;;
        \?)
            usage
            ;;
    esac
done

shift $((OPTIND - 1))
if [ "$#" -lt "2" ]; then
    usage
fi

