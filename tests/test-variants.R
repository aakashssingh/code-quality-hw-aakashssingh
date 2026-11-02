# The supplied run_tests.R loads testthat and the functions from R/.
# Do not source original/messy_analysis.R here.

# A supplied ordinary example; keep it and add your own tests below.
test_that("MAF counts allele copies among observed diploid genotypes", {
    expect_equal(calculate_maf(c(0, 0, 1, 1)), 0.25)
})

# TODO: add small, independently justified known-answer tests for both functions.
# Cover the behavior groups listed in README.md. Do not just test data/genotypes.csv.
# Use informative test names; explain nonobvious expected answers in comments.


# Check for minor allele frequency
# if the maf is calculated for the common allele then the value should be flipped for minor allele frequency
# 1+2+2+2+2 = 9 alleles
# 9/10 = 0.9
# counted allele is also the common allele so we want the function to give 0.1 instead

test_that("MAF value flipped if counted allele is common", {
    expect_equal(calculate_maf(c(1,2,2,2,2)), 0.1)
})

# check for correct denominator
# default should be true
# when na_rm = TRUE the function should drop NA values from denominator
# we dont want NA values to be counted as 0/2 alleles as it can throw off the results
# if NA is counted the allele frequency would change from 1/3 to 1/4 which could fail thresholds incorrectly
test_that("na_rm defaults to TRUE", {
    expect_equal(calculate_maf(c(0,1,NA,1)), 1/3 )
})

# na_rm = TRUE should drop missing values
test_that("na_rm = TRUE drops missing values from denominator", {
    expect_equal(calculate_maf(c(0,1,NA,1), na_rm = TRUE), 1/3 )
})

# na_rm = FALSE converts missing values to NaN
test_that("na_rm = FALSE returns NaN when any value is missing", {
    expect_identical(calculate_maf(c(0,1,NA,1), na_rm = FALSE), NA_real_)
})

# empty input
test_that("empty input is converted to NaN", {
    expect_identical(calculate_maf(numeric(0)), NA_real_)
})

# entirely missing input
test_that("entirely missing input return NaN", {
    expect_identical(calculate_maf(c(NA_real_, NA_real_)), NA_real_)
})

# monomorphic maf
test_that("monomorphic variants have MAF = 0", {
    expect_equal(calculate_maf(c(0,0,0)), 0)
    expect_equal(calculate_maf(c(2,2,2)), 0)
})

# single observation
test_that("single observation input gives expected MAF", {
    expect_equal(calculate_maf(c(1)), 0.5)
    expect_equal(calculate_maf(c(2)), 0)
})

# checking all the summary columns are working as expected
# if the function works normally the expected result would be

test_that("each summary column has the expected value", {
    
    result<- summarize_variant(c(0,1,NA,1))
    
    expect_equal(result$n_called, 3)
    expect_equal(result$missing_rate, 0.25)
    expect_equal(result$maf, 1/3)
    expect_identical(result$keep, TRUE)
})

# scenarios where all columns are not returning values because of missing data
# empty input

test_that("each summary column has the expected value with empty input", {
    
    result<- summarize_variant(numeric(0))
    
    expect_equal(result$n_called, 0)
    expect_equal(result$missing_rate, NA_real_)
    expect_equal(result$maf, NA_real_)
    expect_identical(result$keep, FALSE)
})

# entirely missing input

test_that("each summary column has the expected value with entirely missing input", {
    
    result<- summarize_variant(c(NA_real_,NA_real_))
    
    expect_equal(result$n_called, 0)
    expect_equal(result$missing_rate, 1)
    expect_equal(result$maf, NA_real_)
    expect_identical(result$keep, FALSE)
})

# threshold tests
# maf threshold
# default maf = 0.25
test_that("MAF threshold is inclusive at default", {
    
    expect_false(summarize_variant(c(0,0,0,1))$keep)
    expect_true(summarize_variant(c(0,0,1,1))$keep)
    expect_true(summarize_variant(c(0,1,1,1))$keep)
    
})

# missing rate
# default missing_rate = 0.5

test_that("missing_rate threshold is inclusive at default", {
    
    expect_true(summarize_variant(c(0,1,2,NA))$keep)
    expect_false(summarize_variant(c(1,1,NA))$keep)
})

# non-default thresholds

test_that("non-default threshold is inclusive", {
    
    expect_true(summarize_variant(c(0,0,0,1), min_maf = 0.1)$keep)
    expect_true(summarize_variant(c(1,1,NA), max_missing = 0.5)$keep)
})

# invalid genotype and input value errors

# genotype values
# non-numeric genotypes cause error
test_that("non-numeric genotypes cause error", {
    expect_error(calculate_maf(c("0","1","2")))
})
    
# values outside of desired input
test_that("genotype value other than 0, 1, 2", {
    expect_error(calculate_maf(c(0,3)))
    expect_error(calculate_maf(c(0,1.5)))
})

# secondary check that invalid values are rejected with non-default setting na_rm = FALSE
test_that("invalid genotype values cause error with na_rm = FALSE", {
    expect_error(calculate_maf(c(NA,3), na_rm = FALSE))
})

# invalid input of na_rm argument causes error
test_that("invalid na_rm setting", {
    expect_error(calculate_maf(c(0,1), na_rm = NA))
    expect_error(calculate_maf(c(0,1), na_rm = "TRUE"))
    expect_error(calculate_maf(c(0,1), na_rm = c(TRUE,FALSE)))
})
