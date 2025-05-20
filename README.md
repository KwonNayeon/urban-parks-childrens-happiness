# Causal Effect of Urban Parks on Children's Happiness

## Overview

This repository contains my research thesis investigating the causal relationship between urban park accessibility and children's happiness levels. Using propensity score methods, this study provides empirical evidence for urban planning policies.

## Repository Structure

- `thesis/`: Main thesis document and references
- `data/`: Analysis datasets
- `results/`: Output figures and tables
- `code/`: R scripts for analysis
- `award/`: Awards and recognition

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
- `readxl`, `haven` (For data import)
- `CBPS`, `WeightIt`, `MatchIt` (For causal inference)
- `lubridate`, `skimr`, `tableone` (For data processing)
- `survey`, `senstrat`, `MASS` (For statistical analysis)
- `ggdag`, `dagitty` (For plotting Directed Acyclic Graphs)
- `broom`, `scales`, `truncnorm` (For data transformation)
- `ipw`, `cobalt`, `optmatch` (For matching methods)
- `sensitivityfull`, `sensitivitymw` (For sensitivity analysis)
- `lmtest`, `sandwich` (For robust inference)

## License

This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0).  
See the [LICENSE](./LICENSE) file for details.

## Contact

For questions about the research, please reach out at nayeon.k.datacareer@gmail.com
