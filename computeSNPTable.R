library(data.table)
# library(dtplyr)
# library(dplyr)
library(readr)
library(magrittr)

#
# Get mapping hash from reference chromosome names to 1..N
# e.g.:
#    chr01 ==> 1
#    chr02 ==> 2
#    ...
#

GENOME_C="/ifs/depot/assemblies/S.cerevisiae/S288C_R64/S288C_R64.fasta.fai"
GENOME_K="/ifs/depot/assemblies/S.cerevisiae/SK1_MvO_v1/SK1_MvO_v1_SGRPappended.fa.fai"
genomeAlias=list()

getChromAlias<-function(genomeFAI) {
    genome=read_tsv(genomeFAI,col_names=F)
    renameChrom=seq(genome$X1)
    names(renameChrom)=genome$X1
    renameChrom
}

genomeAlias[["c"]]=getChromAlias(GENOME_C)
genomeAlias[["k"]]=getChromAlias(GENOME_K)


#
# Load table of snp positions

SNPDB_FILE="/home/socci/Work/Users/KeeneyS/Octads/OctadsV1/listeSNPCor1"
snpDb=fread(SNPDB_FILE)
snpDb[,UUID_c:=paste(chr,pos_c,sep=":")]
snpDb[,UUID_k:=paste(chr,pos_k,sep=":")]
snpDb[,sUUID:=seq(nrow(snpDb))]

getSampleDepth<-function(pileupFile) {

    cat("Processing",pileupFile,"\n")
    base=basename(pileupFile)
    gTag=strsplit(gsub(".pileup.*","",base),"___")[[1]][3]
    sName=strsplit(gsub(".pileup.*","",base),"___")[[1]][1]
    sName=gsub("^s_","",sName)

    dd=fread(paste("zcat",pileupFile),header=F)
    dd[,CHROM:=genomeAlias[[gTag]][dd$V1],]
    dd[,UUID:=paste(CHROM,V2,sep=":"),]
    setnames(dd,"V4","Depth")
    setkey(dd,UUID)

    setkeyv(snpDb,paste("UUID",gTag,sep="_"))

    dd=dd[snpDb,nomatch=0]
    dd$SampleID=paste0(sName,gTag)
    dd=dd[order(sUUID),]
    dd[,c("SampleID","sUUID","Depth")]

}

args=commandArgs(trailing=T)

pileupDir=args[1]

pileupFiles=sort(dir(pileupDir,pattern=".gz",full.names=T))
sampleTag=basename(pileupFiles[1]) %>%
    gsub("___MD.*","",.) %>%
    gsub("s_","",.) %>%
    gsub("_[A-D]\\d$","",.)

ds=lapply(pileupFiles,getSampleDepth)
ds=rbindlist(ds)
save(ds,snpDb,file=cc("checkpoint___",sampleTag,".rda"),compress=T)

dds=dcast(ds,sUUID ~ SampleID,value.var="Depth")
setkey(dds,sUUID)
setkey(snpDb,sUUID)

snpTbl=snpDb[dds,]
snpTbl=snpTbl[,-grep("UUID",colnames(snpTbl)),with=F]

outTbl=snpTbl
colnames(outTbl)=gsub(paste0(sampleTag,"_"),"",colnames(outTbl))

sporeCols=c(
    "chr","pos_k","pos_c","seq_c","seq_k",
    "A1c","A2c","B1c","B2c",
    "C1c","C2c","D1c","D2c",
    "A1k","A2k","B1k","B2k",
    "C1k","C2k","D1k","D2k"
)
outTbl=outTbl[,sporeCols,with=F]
write.table(as.data.frame(outTbl),file=cc("sporeTbl___",sampleTag,".txt"),row.names=F,quote=F,sep="\t")

# samples=unique(ds$SampleID)
# samplesU=unique(gsub("[ck]$","",samples))

# callGT<-function(gg) {
#     gc=gg[1]
#     gk=gg[2]

#     if(is.na(gc)){
#         if(!is.na(gk) & gk>15) {
#             return(0)
#         } else {
#             return(NA)
#         }
#     }

#     if(is.na(gk)){
#         if(!is.na(gc) & gc>15) {
#             return(1)
#         } else {
#             return(NA)
#         }
#     }

#     if(gc>gk) {
#         if(gc>40 & gk<5) {
#             return(1)
#         } else {
#             return(NA)
#         }
#     } else {
#         if(gk>40 & gc<5) {
#             return(0)
#         } else {
#             return(NA)
#         }
#     }
# }

