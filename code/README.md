# Code Directory

## Overview

This folder contains R scripts and RMarkdown files for analyzing the causal relationship between urban park accessibility and children's happiness levels. The code implements propensity score methods and sensitivity analyses.

## Files

### Analysis Scripts

1. `main_analysis.Rmd`
- Main analysis workflow in RMarkdown format
- Includes data pre-processing, analysis, and visualization
- Primary file for reproducing thesis results

2. `main_analysis.R`
- R script version of the main analysis
- Contains identical workflow to `main_analysis.Rmd`

### Sensitivity Analysis

3. `sensitivity_analysis.Rmd`
- Sensitivity analysis in RMarkdown format
- Requires pre-processed data from `main_analysis.Rmd`
- Reproduces sensitivity results from thesis

4. `sensitivity_analysis.R`
- R script version of sensitivity analysis
- Mirrors `sensitivity_analysis.Rmd` functionality

### Utility Scripts

5. `functions.R`
- Contains Propensity Score Matching (PSM) functions
- Reference implementation for understanding PSM methods
- Supplementary to main analysis

## Dependencies

Required R packages:
```r
install.packages(c(
  "tidyverse",    # Data manipulation and visualization
  "readxl",       # Excel file import
  "haven",        # Data import
  "CBPS",         # Causal inference
  "lubridate",    # Date handling
  "skimr",        # Data summaries
  "tableone",     # Descriptive statistics
  "survey",       # Survey analysis
  "senstrat",     # Statistical analysis
  "MASS",         # Statistical functions
  "ggdag",        # DAG visualization
  "dagitty",      # DAG analysis
  "broom",        # Tidy model outputs
  "scales",       # Scale transformations
  "truncnorm",    # Statistical distributions
  "ipw",          # Inverse probability weighting
  "WeightIt",     # Weighting methods
  "cobalt",       # Balance assessment
  "optmatch",     # Optimal matching
  "MatchIt"       # Matching methods
))
```

## Notes

- Analyses are primarily documented in **RMarkdown (.Rmd)** files.  
- **R scripts (.R)** offer alternative versions of the same analyses.  
- If you encounter any issues with the **.R** scripts, please refer to the corresponding **.Rmd** files.