# Causal Effect of Urban Parks on Children’s Happiness

## Overview
This repository contains the thesis titled "Causal Effect of Urban Parks on Children’s Happiness," including data, results, and code.

## Repository Structure
- `thesis/`: Contains the main thesis document, abstract, individual chapters, and references.
- `data/`: Contains raw and processed datasets used in the analysis.
- `results/`: Contains figures and tables generated from the analysis.
- `award/`: Contains documents related to the awards and recognitions received for this work.
- `code/`: Contains R scripts and notebooks for data preprocessing, analysis, and creating plots.

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

- `ggdag` (For plotting Directed Acyclic Graphs)
- `MatchIt`
- `ggplot2`
- `sensitivityfull`
- `sensitivitymw`
- `lmtest` (For `coeftest`)
- `sandwich` (For `vcovCL`)
- `tidyverse` (Includes `dplyr` and other packages)

You can install these packages in R using the following command:
```r
install.packages(c("ggdag", "MatchIt", "ggplot2", "sensitivityfull", "sensitivitymw", "lmtest", "sandwich", "tidyverse"))
```
### Notes

The above list includes only some of the packages used in the analysis. Other packages may also be required for specific functionalities or scripts.

If you encounter errors related to missing packages, please refer to the script's `library()` calls to identify any additional packages that may need to be installed.

For a complete list of packages, refer to `main_analysis.Rmd` in the code folder or contact me for assistance.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact
For any questions or comments, please contact [nayeonkn0330@gmail.com].
