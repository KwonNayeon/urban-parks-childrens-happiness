# Causal Effect of Urban Parks on Children’s Happiness

## Overview
This repository contains the thesis titled "Causal Effect of Urban Parks on Children’s Happiness," including data, results, and code.

## Repository Structure
- `thesis/`: Contains the main thesis document, abstract, and references.
- `data/`: Contains raw and processed datasets used in the analysis.
- `results/`: Contains figures and tables generated from the analysis.
- `code/`: Contains R scripts and notebooks for data preprocessing, analysis, and creating plots.
- `award/`: Contains documents related to the awards and recognitions received for this work.

## Getting Started
1. Clone the repository:
    ```bash
    git clone https://github.com/KwonNayeon/urban-parks-childrens-happiness.git
    ```
2. Navigate to the project directory:
    ```bash
    cd urban-parks-childrens-happiness
    ```
## Dependencies

To run the R scripts and analysis, you need the following R packages:

- `tidyverse` (Includes `dplyr`, `ggplot2`, and other packages)
- `readxl`
- `haven`
- `CBPS`
- `lubridate`
- `skimr`
- `tableone`
- `survey`
- `senstrat`
- `MASS`
- `ggdag` (For plotting Directed Acyclic Graphs)
- `dagitty`
- `broom`
- `scales`
- `truncnorm`
- `ipw`
- `WeightIt`
- `cobalt`
- `optmatch`
- `MatchIt`
- `sensitivityfull`
- `sensitivitymw`
- `lmtest` (For `coeftest`)
- `sandwich` (For `vcovCL`)

You can install these packages in R using the following command:
```r
install.packages(c(
  "tidyverse", 
  "readxl", 
  "haven", 
  "CBPS", 
  "lubridate", 
  "skimr", 
  "tableone", 
  "survey", 
  "senstrat", 
  "MASS", 
  "ggdag", 
  "dagitty", 
  "broom", 
  "scales", 
  "truncnorm", 
  "ipw", 
  "WeightIt", 
  "cobalt", 
  "optmatch", 
  "MatchIt", 
  "sensitivityfull", 
  "sensitivitymw", 
  "lmtest", 
  "sandwich"
))
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact
For any questions or comments, please contact [nayeonkn0330@gmail.com].
