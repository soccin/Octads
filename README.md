# Octads V2

## Project 08277 

### CMDS

```
# Map to both SK1 and S288C

mkdir S288C
cd S288C
../../PEMapper/runPEMapperMultiDirectories.sh sacCer_S288C ../_sample_mapping 
cd ..
mkdir SK1
cd SK1
../../PEMapper/runPEMapperMultiDirectories.sh sacCer_SK1 ../_sample_mapping 
cd ..
SYNC

find S*  | fgrep .bam | sort >bams
cat bams  | xargs -n 1 bsub -o LSF/ -J PILE -We 59 ../OctadsV1/getPerfectPileup.sh 

mkdir pileups/s_F260A1
mkdir pileups/s_F260A2
mkdir pileups/s_WT2

mv s_F260A1_* pileups/s_F260A1
mv s_F260A2_* pileups/s_F260A2/
mv s_WT2_* pileups/s_WT2/

ls -d pileups/s_* | xargs -n 1 time Rscript --no-save ../OctadsV1/computeSNPTable.R

ls sporeTbl____* | xargs -n 1 python ../OctadsV1/Spore_simplify2a.py
```

