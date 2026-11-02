# Refactor the calculations in original/messy_analysis.R into these interfaces.
# Preserve the required behavior described in README.md.
# This file should define functions only: no reads, writes, or analysis run.

calculate_maf <- function(genotypes, na_rm = TRUE) {
    # TODO: calculate MAF for one numeric genotype vector.
    
    # exactly one, non-missing logical value, and reject invalid settings 
    if (!is.logical(na_rm) || length(na_rm) != 1 || is.na(na_rm)) {
        stop("na_rm is not exactly one non-missing logical value", call. = FALSE)
    }
    
    # check genotypes is numeric vector 
    if (!is.numeric(genotypes) || !is.null(dim(genotypes))) {
        stop("genotypes is not numeric vector", call. = FALSE)
    }
    
    # check and remove missing values
    geno_na <- is.na(genotypes)
    values <- genotypes[!geno_na]
    
    # throw error if observed values are anything other than 0,1,2, or NA
    if (!all(values %in% c(0,1,2))) {
        stop("genotypes contain values other than 0, 1, 2, or NA", call. = FALSE)
    }
    
    # if na_rm = FALSE, and there are NAs or if we have all missing input
    if ((!na_rm && any(geno_na))) {
        return(NA_real_)
    }
    
    if (length(values) == 0) {
        return(NA_real_)
    }
    
    # calculate allele frequency
    all_freq <- sum(values) / (2 * length(values))
    
    maf <- min(all_freq, 1 - all_freq)
    
    return(maf)
}

summarize_variant <- function(genotypes, min_maf = 0.25,
                              max_missing = 0.25) {
    # TODO: return the specified one-row summary, calling calculate_maf().
    
    # min_maf must be one finite numeric value between 0 and 0.5 inclusive
    if (!is.numeric(min_maf) || length(min_maf) != 1 || !is.finite(min_maf) || min_maf < 0 || min_maf > 0.5) {
        stop("min_maf is not one finite numeric value between 0 and 0.5", call. = FALSE)
        
    }
    
    if (!is.numeric(max_missing) || length(max_missing) != 1 || !is.finite(max_missing) || max_missing < 0 || max_missing > 1) {
        stop("max_missing is not one finite numeric value between 0 and 1", call. = FALSE)
        
    }
    
    # calculate maf
    maf <- calculate_maf(genotypes, na_rm = TRUE)
    
    # counts
    n_total <- length(genotypes)
    
    n_called <- sum(!is.na(genotypes))
    
    # calculate missingness 
    # zero call rate should be interpreted as NaN
    if (n_total == 0) {
        missing_rate <- NA_real_
    } else {
        missing_rate <- (n_total - n_called) / n_total
    }
    
    
    # Logical TRUE exactly when there is at least one called genotype, MAF is at least min_maf, and missing rate is at most max_missing. Otherwise FALSE.
    keep <- n_called >= 1 && maf > min_maf && missing_rate <= max_missing
    
    data.frame(n_called = n_called, missing_rate = missing_rate, maf = maf, keep = keep)
    
}
