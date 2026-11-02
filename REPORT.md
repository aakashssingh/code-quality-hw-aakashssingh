# Code quality and testing report

## Repository and tested revision
Repository URL:
Final commit identifier:
Final passing Actions run URL:
Deliberate test-failure run URL:
Repair run URL:

## Design changes
Explain three meaningful changes and why they improve the code. Include one
structural change, not only renaming/formatting.


The structural change I made splits up the template script into 2 functions 'calculate_maf()' and 'summarize_variant()'. In the messy_analysis script the function 'f()' calculated MAF, missingness rate, and the criteria to keep or drop rows. The original script also declared the threshold variable 'y' and 'z' as global variable that could cause issue if not checked. In my script the thresholds are part of the argument for summarize_variant(), which calls on calculate_maf() to calculate minor allele frequency after verifying the input file and arguments meet the required guidelines.
I also noticed that the template was calculating minor allele frequency twice, which is redundant so I removed that chunk as well. Calculating twice could possibly cause issues because there were double varibles being created (o2 and tmp2).
Lastly I added more test to ensure that the input value is correct and ensures that the incorrect values are handled appropriately. Incorrect input would stop the function instead of provide inaccurate results. Along with this I changed the variable names to be more meaningful and easier to understand for someone that is reviewing the code. I added additional comments to make debugging easier as well.


## Test reasoning
Choose two of your own tests. Explain the required behavior, the independent
expected result, and a plausible mistake each would detect.


The first test I would discuss addresses the scenario if the allele being counted is a common allele which would give a MAF > 0.5 which is incorrect. For example, if the allele counts indicate that there are 9 copies out of 10 alleles, the minor allele frequency would be 0.9 which is incorrect. In this scenario we want the minor allele frequency to be reported as 1 - p instead which would make the output be 0.1 instead. 

The second test I added checks for missing values and ensure they are left out of the denominator. For an input of c(0,1,NA,1), only 3 individuals have genotype information but the old script would read this as 2/8 alleles which will make the minor allele frequency lower than it actually is so changing this makes the allele counts to be read as 2/6 and drops the count for NA from the denominator. 

## Deliberate regression
State the code change, which existing test failed, and why the implementation
rather than the test needed to change. Describe the repair.

The code change I made was changing maf >= min_maf to maf > min_maf in the summarize_variant() function. This makes the maf threshold exclusive and will drop rows that have the same maf as the input threshold. So a variant with maf 0.25 would get dropped if the threshold was set at 0.25

deliberate error: https://github.com/aakashssingh/code-quality-hw-aakashssingh/actions/runs/41444250780

fixed url: https://github.com/aakashssingh/code-quality-hw-aakashssingh/actions/runs/41444562022