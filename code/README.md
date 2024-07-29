# Code Directory

This folder contains the R scripts used for data pre-processing, analysis, and creating plots for the thesis "Causal Effect of Urban Parks on Children’s Happiness."

## Files

### 1. `main_analysis.Rmd`

- **Description**: This is the main file for the analysis. It includes the complete workflow from data pre-processing to analysis and visualization.
- **Usage**: Run this R Markdown file to reproduce the results and plots presented in the thesis.

### 2. `sensitivity_analysis.Rmd`

- **Description**: This file contains the sensitivity analysis code. Note that it does not include data pre-processing steps, so it relies on the `main_analysis.Rmd` file. Ensure that all required libraries are installed before running this script. Running this file in conjunction with `main_analysis.Rmd` should not cause any issues.
- **Usage**: Execute this R Markdown file to reproduce the results and plots presented in the thesis.

### 3. `functions.R`

- **Description**: This file contains various functions related to Propensity Score Matching (PSM). While these functions were not directly used in the thesis, they were helpful in understanding the underlying mechanisms of the PSM methods used.
- **Usage**: Source this file if you need to use the included functions for your own analysis or to understand the PSM methods better.
