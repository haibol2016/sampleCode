
## combine a large number of RNA-seq count table file with same gene features as rows

combine_count_tables <- function(directory = getwd(), suffix = ".txt", geneIDIsRowNames = TRUE, geneIDCol = 1)
{
    files <- dir(directory, pattern = paste0(suffix, "$"))
    tryCatch(
    ## read files, change colnames, and sort by rownames    
    {
        read_file <- function(x) 
        {
            if (geneIDIsRowNames)
            {
                temp_df <- read.delim(x, as.is = TRUE)
            }else{
                temp_df <- read.delim(x, as.is = TRUE, row.names = geneIDCol)
            }
            sampleID <- gsub(suffix, "", x)
            colnames(temp_df) <- paste(sampleID, colnames(temp_df), sep = "_")
            temp_df <- temp_df[order(rownames(temp_df)), ]
            temp_df
        }
        comb_table <- lapply(files, read_file)
        all_counts <- do.call(cbind, comb_table)
    }, error = function(e) {print(paste0("Can't open file ", x))}
    )
   all_counts    
}