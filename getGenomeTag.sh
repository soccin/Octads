#!/bin/bash

BAM=$1
SIG=$(samtools view -H $BAM | egrep "^@SQ" | md5sum - | awk '{print $1}')

#SGRPAppendVersion k:b4872156089d3f3dd1269f11ba8762a9
#c:fe8f1be9fb7460904b32a115093864e5
#k:201eb0194caf9857579467e86581123f

case $SIG in
    201eb0194caf9857579467e86581123f)
    echo 'k'
    ;;

    fe8f1be9fb7460904b32a115093864e5)
    echo 'c'
    ;;

    *)
    echo "Invalid BAM signature ="$SIG
    exit 1
    ;;
esac

