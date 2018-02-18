#!/bin/bash
SDIR="$( cd "$( dirname "$0" )" && pwd )"

SCRIPT_VERSION=$(git --git-dir=$SDIR/.git --work-tree=$SDIR describe --always --long)
PIPENAME=OctadsV2

##
# Process command args

TAG=q${PIPENAME}_$$

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
$SDIR/PEMapper/runPEMapperMultiDirectories.sh -t ${TAG}_MAP sacCer_SK1 $MAPPINGFILE | tee ../log_SK1
cd ..
mkdir S288C
cd S288C
$SDIR/PEMapper/runPEMapperMultiDirectories.sh -t ${TAG}_MAP sacCer_S288C $MAPPINGFILE | tee ../log_S288C
cd ..
echo
echo
echo "Holding for Mapping Stage"
bSync "${TAG}_MAP.*"

echo "Computing pileup..."
find SK1/out___ S288C/out___ \
    | fgrep .bam | fgrep ___MD | sort | tee bams \
    | xargs -n 1 bsub -o LSF/ -J ${TAG}_PILE -We 59 $SDIR/getPerfectPileup.sh
bSync ${TAG}_PILE

sleep 15
echo "Reorganize"

SAMPLES=$(ls *pileup.gz | perl -pe 's/_[ABCD]\d___.*//' | sort | uniq )
for si in $SAMPLES; do
    echo $si;
    mkdir -p pileups/$si
    mv "$si"_* pileups/$si
done

ls -d pileups/s_* | xargs -n 1 bsub -o LSF/ -J ${TAG}_SNP -We 59 Rscript --no-save $SDIR/computeSNPTable.R
bSync ${TAG}_SNP
ls sporeTbl____* | xargs -n 1 bsub -o LSF/ -J ${TAG}__SPORE -We 59 python $SDIR/Spore_simplify2a.py


