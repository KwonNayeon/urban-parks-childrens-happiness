# Code Directory

This folder contains the R scripts used for data pre-processing, analysis, and creating plots for the thesis "Causal Effect of Urban Parks on Children’s Happiness."

## Files

### 1. `main_analysis.Rmd`

- **Description**: This is the main file for the analysis. It includes the complete workflow from data pre-processing to analysis and visualization.
- **Usage**: Run this R Markdown file to reproduce the results and plots presented in the thesis.

### 2. `main_analysis.R`

- **Description**: This is the main script for the analysis, similar to `main_analysis.Rmd`, but in R script format. It performs the complete workflow from data pre-processing to analysis and visualization. 
- **Usage**: Run this R script to reproduce the results and plots presented in the thesis.

### 3. `sensitivity_analysis.Rmd`

- **Description**: This file contains the sensitivity analysis code. Note that it does not include data pre-processing steps, so it relies on the `main_analysis.Rmd` file. Ensure that all required libraries are installed before running this script. Running this file in conjunction with `main_analysis.Rmd` should not cause any issues.
- **Usage**: Execute this R Markdown file to reproduce the results and plots presented in the thesis.

### 4. `sensitivity_analysis.R`

- **Description**: This is the R script version of the sensitivity analysis, similar to `sensitivity_analysis.Rmd`. It does not include data pre-processing steps and relies on the `main_analysis.Rmd` file. 
- **Usage**: Run this R script to reproduce the sensitivity analysis results and plots presented in the thesis.

### 5. `functions.R`

- **Description**: This file contains various functions related to Propensity Score Matching (PSM). While these functions were not directly used in the thesis, they were helpful in understanding the underlying mechanisms of the PSM methods used.
- **Usage**: Source this file if you need to use the included functions for your own analysis or to understand the PSM methods better.

## Notes
- The original analysis was developed using the R Markdown (`.Rmd`) format. If you encounter any errors or issues running the R scripts, please refer to the corresponding `.Rmd` files for the correct code and execution flow.
