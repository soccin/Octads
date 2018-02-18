#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"
BAM=$1
GTAG=$($SDIR/getGenomeTag.sh $BAM)

samtools view -h $BAM \
    | egrep "(^@|NM:i:0[^0-9])" \
    | samtools view -Sb - \
    | samtools mpileup - \
    | cut -f-4 \
    | gzip -9 -c - \
    > $(basename $BAM | sed 's/.bam//')___${GTAG}.pileup.gz
