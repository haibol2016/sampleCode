
## These R scripts are used to annotate a set of histone modification ChIP-seq peak files (in narrowPeaks or
## broadPeak format)


library("ChIPseeker")
library("GenomicFeatures")
library("ChIPpeakAnno")

## make TxDb from GTF:prepare their own TxDb object by retrieving information from UCSC Genome Bioinformatics 
## and BioMart data resources by R function makeTxDbFromBiomart and  makeTxDbFromUCSC. 
ssc_TxDb <- makeTxDbFromGFF(file = "~/haibol_work/haibo_genome/sus_scrofa/Sus_scrofa.Sscrofa11.1.90.gtf", 
                            format="gtf", dataSource="Ensembl", organism="Sus scrofa", 
                            taxonomyId=NA, circ_seqs="MT", chrominfo=NULL, miRBaseBuild=NA)
							
saveDb(ssc_TxDb, file="~/haibol_work/haibo_genome/sus_scrofa/ssc11.1.v90.sqlite")
ssc_TxDb <- loadDb("~/haibol_work/haibo_genome/sus_scrofa/ssc11.1.v90.sqlite")

peak_files <- dir("./", "Peaks$")
isBroad <- grepl("broadPeak$", peak_files, perl = TRUE)

## read peak files in batch
macsOutput <- mapply(function(.x, .y) {
    if (.y)
    {
        toGRanges(.x, format="broadPeak")
    }else {
        toGRanges(.x, format="narrowPeak")
    }
}, peak_files,  isBroad)


sample_names <- gsub("\\.diffPeaks.broadPeaks", "", peak_files)
names(macsOutput) <- sample_names

## genome-wide coverage plot
pdf("Genome-wide HM peak distribution.pdf", width =12, height =10)
null <- lapply(seq_along(macsOutput), function(.x){
    print(covplot(macsOutput[[.x]], weightCol = "score",
                  title = names(macsOutput)[[.x]], 
                  chrs = c(as.character(1:18), "X", "Y")))
}) 
dev.off()


## peak annotation: The output of annotatePeak is csAnno instance. ChIPseeker provides as.GRanges to convert
## csAnno to GRanges instance, and as.data.frame to convert csAnno to  data.frame which can be exported to 
## file by write.table.ChIPseeker adopted the following priority in genomic annotation.
# Promoter
# 5' UTR
# 3' UTR
# Exon
# Intron
# Downstream
# Intergenic

# ChIPseeker also provides parameter genomicAnnotationPriority for user to prioritize this hierachy.

peakAnnoList <- lapply(seq_along(macsOutput), function(.x){
    peakAnno <- annotatePeak(macsOutput[[.x]], tssRegion=c(-5000, 5000),
                             TxDb=ssc_TxDb, 
                             genomicAnnotationPriority = c("Promoter", 
                                                           "5UTR", "3UTR", 
                                                           "Exon",
                                                           "Intron", 
                                                           "Downstream",
                                                           "Intergenic")) 
    pdf(paste0(names(macsOutput)[.x],
               "-Pie charts showing distribution of peaks among genomic features.pdf"), 
        width = 10,height = 5)
    plotAnnoPie(peakAnno)
    vennpie(peakAnno)
    ## some annotation overlap
    upsetplot(peakAnno)
    dev.off()
    
    peakAnno
})
## Visualize Genomic Annotation

names(peakAnnoList) <- sample_names

## output

peakAnnoList_df <- lapply(peakAnnoList, as.data.frame)

geneID <- read.delim("~/haibol_work/haibo_genome/sus_scrofa/susscrofa11.1.97.geneID.mapping.txt", header = TRUE, sep = "\t", as.is = TRUE)

peakAnnoList_df_namesadded <- lapply(peakAnnoList_df, function(.x){
    .y <- merge(.x, geneID, by.x = "geneId", by.y = "EnsemblID", all.x = TRUE)
    .y <- with(.y, .y[, c(colnames(.x), "GeneName")])
    .y
})

##
raw_peaks <- dir("../", ".diffReps.txt", full.names = TRUE)

##
peakAnnoList_df_ann <- mapply(function(.x, .y){
   .y <- read.delim(.y, comment.char = "#", header = TRUE, as.is = TRUE)[,1:14]
   .x <- .x[, c(1:3, 9:18)]
   .xy <- merge(.y, .x, 
                by.y = c("seqnames", "start", "end"),
                by.x = c("Chrom", "Start", "End"), all.y = TRUE)
   .xy
}, peakAnnoList_df_namesadded, raw_peaks, SIMPLIFY = FALSE)


library("openxlsx")
write.xlsx(peakAnnoList_df_ann, file = "Annotated HM peaks.xlsx", asTable = FALSE, sheetName = names(peakAnnoList),
           colNames = TRUE, rowNames =FALSE,
           firstActiveRow = 2)


pdf("Bar plots showing distribution of peaks among genomic features.pdf", width = 5, height = 6)

plotAnnoBar(peakAnnoList)
plotDistToTSS(peakAnnoList,
              title="Distribution of HM-rich loci\nrelative to TSS")
dev.off()