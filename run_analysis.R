# Run from the repository root.
# TODO: move and simplify the DRIVER portion of original/messy_analysis.R here.
# Read data/genotypes.csv with colClasses = "numeric", call your functions for each column, and write ONE
# combined results/summary.csv after all variant summaries are calculated.
# Put the thresholds in named settings and pass them as function arguments.
# Source R/variant_functions.R to load your function definitions.


# Invented teaching data. Run from the repository root.
source("R/variant_functions.R")

# read in data
genotypes <- read.csv("data/genotypes.csv", colClasses = "numeric")

# filtering thresholds
maf_threshold <- 0.25
missing_threshold <- 0.25

# create summary_rows 
summary_rows <- list()

for(i in seq_len(ncol(genotypes))) {
    
    variant_summary <- summarize_variant(genotypes[[i]],
                                         min_maf = maf_threshold,
                                         max_missing = missing_threshold)
    summary_rows[[i]] <- data.frame(variant_id = names(genotypes)[i], variant_summary)
    
    summary_table <- do.call(rbind, summary_rows)
    
    # Make the folder.
    dir.create("results", showWarnings=FALSE)
    
    # Write it without quotes, with commas, and with no row names.
    write.table(summary_table,"results/summary.csv",sep=",",quote=FALSE,row.names=FALSE)
}
