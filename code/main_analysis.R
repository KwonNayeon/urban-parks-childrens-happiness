# Main Analysis Script
# This script performs a main analysis for the given dataset.

# Load necessary libraries
# Uncomment the following line to install any missing packages
# install.packages(c("tidyverse", "readxl", "haven", "CBPS", "lubridate", "skimr", "tableone",
#                    "survey", "senstrat", "MASS", "ggdag", "dagitty", "broom", "scales",
#                    "truncnorm", "ipw", "WeightIt", "cobalt", "optmatch", "MatchIt",
#                    "DOS2", "Matching", "ggplot2", "sensitivityfull", "sensitivitymw", 
#                    "lmtest", "sandwich", "Rglpk"))

# Load Data
library(tidyverse)
library(readxl)
library(haven)

# Read data files
extra2 <- read_excel("data/extra2.xlsx")
w7_2014_data_220324 <- read_dta("data/w7_2014_data_220324.dta")
shp2 <- read.csv("data/shp2.csv", header = TRUE, fileEncoding = "euc-kr")

# Load Packages
library(lubridate)
library(skimr)
library(tableone)
library(survey)
library(senstrat)
library(MASS)
library(ggdag)  # For plotting DAGs
library(dagitty)  # For working with DAG logic
library(broom)  # augment_columns
library(scales)
library(truncnorm)
library(ipw)
library(WeightIt)
library(cobalt)
library(optmatch)
library(MatchIt)
library(DOS2)
library(Matching)
library(ggplot2)
library(sensitivityfull)
library(sensitivitymw)
library(lmtest) # coeftest
library(sandwich) # vcovCL


# pre-processing

# Install spatial data-related packages if necessary
# Uncomment the following line to install any missing packages
# install.packages(c("raster", "sf", "tmap", "sp","spdep"))

# Load spatial data-related packages
library(raster)
library(sf)
library(tmap)
library(sp)
library(spdep)  # To find adjacent polygons

# Process extra data
extra <- extra2 %>%
  mutate(
    region = factor(DHu14region),  # Create a new variable
    region2 = factor(ifelse(gri == 40577, 1, ifelse(gri == 30892, 2, 3))),
    ca = factor(ca)
  ) %>%
  filter(
    !is.na(housing),  # Exclude rows with missing values in housing
    !is.na(ca)        # Exclude rows with missing values in ca (capital/non-capital region)
  )

# Merge extra with shp2
merged <- left_join(x = extra, y = shp2, by = 'region')


# install.packages("dplyr")
library(dplyr)
w7 = w7_2014_data_220324 %>%
  
  ### 새 변수 생성 (Creating new variables)
  mutate(
    # 유아의 행복감 (Child's happiness)
    y = JCh14shs001 + JCh14shs002 + JCh14shs003 + JCh14shs004 + EMt14shs005 + FFt14shs005,                               
    
    # 유아의 자아존중감 (Child's self-esteem)
    JCh14sfs = JCh14sfs012 + JCh14sfs013 + JCh14sfs014 + JCh14sfs015 + JCh14sfs016 + JCh14sfs017 +
      JCh14sfs018 + JCh14sfs019 + JCh14sfs020 + JCh14sfs021 + JCh14sfs022 + JCh14sfs023 +
      JCh14sfs024 + JCh14sfs025 + JCh14sfs026 + JCh14sfs027 + JCh14sfs028 + JCh14sfs029 +
      JCh14sfs030 + JCh14sfs031 + JCh14sfs032 + JCh14sfs033 + JCh14sfs034 + JCh14sfs035 + JCh14sfs036,
    
    # 유아의 학업능력 (문해 및 언어능력) (Child's academic ability: literacy and language skills)
    HIn14acs = HIn14acs001 + HIn14acs002 + HIn14acs003 + HIn14acs004 + HIn14acs005 + HIn14acs006 +
      HIn14acs007 + HIn14acs008 + HIn14acs009 + HIn14acs010 + HIn14acs011 + HIn14acs012 +
      HIn14acs013 + HIn14acs014,
    
    # 유아의 사회적유능감(주장성) (Child's social competence: assertiveness)
    HIn14ssr = HIn14ssr002 + HIn14ssr008 + HIn14ssr017 + HIn14ssr018 + HIn14ssr021,
    
    # 모 양육 효능감 (Mother's parenting efficacy)
    EMt14sff = EMt14sff012 + EMt14sff013 + EMt14sff014 + EMt14sff015 + EMt14sff016 + EMt14sff017 +
      EMt14sff018 + EMt14sff019 + EMt14sff020 + EMt14sff021 + EMt14sff022 + EMt14sff023 +
      EMt14sff024 + EMt14sff025 + EMt14sff026 + EMt14sff027,
    
    # 모 행복감 (Mother's happiness)
    EMt14shs = EMt14shs001 + EMt14shs002 + EMt14shs003 + EMt14shs004,
    
    # 모 통제적 양육행동 (Mother's controlling parenting behavior)
    EMt14crs = EMt14crs010 + EMt14crs011 + EMt14crs012 + EMt14crs013 + EMt14crs014 + EMt14crs015,
    
    # 모 애정적 부모간양육행동 (Mother's affectionate co-parenting behavior)
    EMt14aff = EMt14crs035 + EMt14crs037 + EMt14crs038 + EMt14crs039,
    
    # 모 통합적 부모간양육행동 (Mother's integrative co-parenting behavior)
    EMt14integ = EMt14crs046 + EMt14crs047 + EMt14crs048,
    
    # 부 양육스트레스 (Father's parenting stress)
    FFt14prs = FFt14prs001 + FFt14prs002 + FFt14prs003 + FFt14prs004 + FFt14prs005 + FFt14prs006 +
      FFt14prs007 + FFt14prs008 + FFt14prs009 + FFt14prs010 + FFt14prs011,
    
    # 부 행복감 (Father's happiness)
    FFt14shs = FFt14shs001 + FFt14shs002 + FFt14shs003 + FFt14shs004,
    
    # 부 애정적 부모간양육행동 (Father's affectionate co-parenting behavior)
    FFt14aff = FFt14crs035 + FFt14crs037 + FFt14crs038 + FFt14crs039,
    
    # 유아의 기관선호도 (Child's preference for institution)
    HIn14chc = HIn14chc037 + HIn14chc038,
    
    # 어머니의 최종학력 고졸이하 (Mother's final education level: high school or below)
    DMt14dmg014 = factor(ifelse(DMt14dmg014 %in% c(1,2,3,4), 4, DMt14dmg014)),
    
    # 아버지의 최종학력 고졸이하 (Father's final education level: high school or below)
    DFt14dmg014 = factor(ifelse(DFt14dmg014 %in% c(3,4), 4, DFt14dmg014)),
    
    # 시/군/구 변수 (City/district variable)
    region = factor(DHu14cmm015),
    
    # 가구 치안 측면 안전성 (Household safety in terms of security)
    EHu14cmm011 = factor(EHu14cmm011),
    
    # 가구 공원 이용 편리성 (Household convenience in park usage)
    EHu14cmm009b = factor(EHu14cmm009b),
    
    # 보호자 육아지원 서비스 이용 여부 (Use of guardian's childcare support services: part-time special academies and special activities)
    DCh14cht001 = factor(DCh14cht001),
    
    # 가구 공원 이용 일(1개월 ()일) (Household park usage days in a month)
    EHu14cmm017b = factor(EHu14cmm017b),
    
    # 아동 외출 등 실외활동(평일 총 ()시간) (Child's outdoor activities on weekdays: total hours)
    DCh14dlc010 = factor(DCh14dlc010),
    
    # 보호자 현 이용 시간제 특기학원 및 특별활동 이용 수 (Current use of part-time special academies and special activities by guardian)
    DCh14cht002 = factor(DCh14cht002)
  ) %>%
  
  ## 분석대상 filtering (Filtering for analysis)
  filter(
    JCh14int001 == 1,                                     # 아동 7차조사 참여 (Child participated in the 7th survey)
    EMt14int001 == 1,                                     # 어머니 7차조사 참여 (Mother participated in the 7th survey)
    FFt14int001 == 1,                                     # 아버지 7차조사 참여 (Father participated in the 7th survey)
    DHu14int001 == 1,                                     # 보호자 7차조사 참여 (Guardian participated in the 7th survey)
    HIn14int001 == 1 | HIn14int001 == 2,                  # 유치원과 어린이집 외의 기관에 다니는 유아 제외 (Exclude children attending institutions other than kindergartens and daycare centers)
    !is.na(JCh14sfs012),                                  # 아동 자아존중감1 결측치 제외 (Exclude missing values for child's self-esteem 1)
    !is.na(ICh14ssr027) | ICh14ssr027 != 99999999,        # 아동 사회적 유능감: 주장성1 결측치 제외 (Exclude missing values for child's social competence: assertiveness 1)
    !is.na(ICh14ssr030) | ICh14ssr030 != 99999999,        # 아동 사회적 유능감: 주장성2 결측치 제외 (Exclude missing values for child's social competence: assertiveness 2)
    !is.na(ICh14ssr034) | ICh14ssr034 != 99999999,        # 아동 사회적 유능감: 주장성4 결측치 제외 (Exclude missing values for child's social competence: assertiveness 4)
    !is.na(ICh14ssr042) | ICh14ssr042 != 99999999,        # 아동 사회적 유능감: 주장성5 결측치 제외 (Exclude missing values for child's social competence: assertiveness 5)
    DHu14ses006 != 88888888 | DHu14ses006 != 99999999,    # 가구소득 결측값 제외 (Exclude missing values for household income)
    !is.na(DFt14dmg014),                                  # 아버지 학력 결측값 제외 (Exclude missing values for father's education)
    !is.na(DMt14dmg014)                                   # 어머니 학력 결측값 제외 (Exclude missing values for mother's education)
  ) 

## merge data (Merging data)
merged <- merge(x=w7, y=extra, by='region', all.x=TRUE)
# write.csv(merged, "/Users/user02/R/merged.csv")

## 제거되지 않은 결측값 제거 (Removing unfiltered missing values)
## extra data frame에 추가하기 (Add to the extra data frame)

merged = merged %>%
  filter(
    !is.na(papc),                              # Exclude missing values for 'papc'
    ICh14ssr027 != 99999999,                   # Exclude invalid values for child's social competence: assertiveness 1
    ICh14ssr030 != 99999999,                   # Exclude invalid values for child's social competence: assertiveness 2
    ICh14ssr034 != 99999999,                   # Exclude invalid values for child's social competence: assertiveness 4
    ICh14ssr042 != 99999999,                   # Exclude invalid values for child's social competence: assertiveness 5
    DHu14ses006 != 88888888,                   # Exclude invalid values for household income
    DHu14ses006 != 99999999                    # Exclude invalid values for household income
  )


# median 기준 trt

# Convert 'papc' into a binary variable based on its median value
# If 'papc' is less than or equal to the median value, assign 0; otherwise, assign 1
merged$papc = ifelse(merged$papc <= median(merged$papc), 0, 1)

## table 및 missing value 확인
# Attach the 'merged' data frame to the R search path for easy variable access
attach(merged)

# Display a frequency table of 'papc' to see the counts of 0s and 1s
table(papc)            # Frequency table for 'papc'

# Check the number of missing values in the 'y' variable
sum(is.na(y))          # Total number of missing values in 'y'

# Display frequency tables for variables with potential invalid values (99999999)
table(ICh14ssr027)     # Frequency table for 'ICh14ssr027', excluding 99999999
table(ICh14ssr030)     # Frequency table for 'ICh14ssr030', excluding 99999999
table(ICh14ssr034)     # Frequency table for 'ICh14ssr034', excluding 99999999
table(ICh14ssr042)     # Frequency table for 'ICh14ssr042', excluding 99999999
table(DHu14ses006)     # Frequency table for 'DHu14ses006', excluding 99999999

# Detach the 'merged' data frame from the R search path
detach(merged)


# Generate DAG

# generate DAG
# Load necessary libraries
library(ggdag)
library(dplyr)

# Define the Directed Acyclic Graph (DAG) structure
papc.dag <- dagify(
  # Define relationships between variables
  y ~ x + f + g,
  x ~ b,
  b ~ c,
  c ~ d + e,
  f ~ c + d + e,
  u2 ~ c,
  g ~ u2,
  
  # Specify exposure and outcome variables
  exposure = "x",
  outcome = "y",
  
  # Define labels for the variables
  labels = c(
    y = "Child’s happiness", 
    x = "Park area per capita", 
    b = "Living inside capital area (Y/N)", 
    c = "Household income", 
    d = "Father’s education level",
    e = "Mother’s education level", 
    f = "Child's literacy", 
    g = "Father's stress", 
    u2 = "Father's self-efficacy (unobserved)"
  ),
  
  # Define coordinates for the DAG plot
  coords = list(
    x = c(
      x = 1, b = 1, c = 2, d = 4, e = 4, f = 6, g = 7, u2 = 4, y = 7
    ),
    y = c(
      x = 6, b = 2, c = 4, d = 5, e = 3, f = 4, g = 3, u2 = 2, y = 6
    )
  )
)

# Notes on variables
# U1: Mother's self-efficacy (commented out in DAG)
# U2: Father's self-efficacy

# Visualize the DAG
ggdag_status(papc.dag, use_labels = "label", text = FALSE) +
  guides(fill = FALSE, color = FALSE) +  # Disable the legend
  theme_dag()


# Data frame 1

# Extract variables from the merged dataset
y <- merged$y                     # Child’s happiness
papc <- merged$papc               # Treatment: Park area per capita
housing <- merged$housing         # Housing information
# region2 <- merged$region2       # (Commented out) Region information
ca <- merged$ca                   # Categorical variable (e.g., region or category)
income <- merged$DHu14ses006      # Household income
Fschool <- merged$DFt14dmg014     # Father's final education level
Mschool <- merged$DMt14dmg014     # Mother's final education level
Kacs <- merged$HIn14acs           # Child's academic ability (literacy and language)
Fstress <- merged$FFt14prs        # Father's parenting stress
Msff <- merged$EMt14sff           # Mother's parenting efficacy
Mhappiness <- merged$EMt14shs     # Mother's happiness
Mcrs <- merged$EMt14crs           # Mother's controlling parenting behavior
Maff <- merged$EMt14aff           # Mother's affectionate parenting behavior
Minteg <- merged$EMt14integ       # Mother's integrated parenting behavior
Fhappiness <- merged$FFt14shs     # Father’s happiness
Faff <- merged$FFt14aff           # Father’s affectionate parenting behavior
Ksfs <- merged$JCh14sfs           # Child’s self-esteem
Kssr <- merged$HIn14ssr           # Child’s social competence
Kprefe <- merged$HIn14chc         # Child’s institutional preference

# Combine the variables into a data frame
PSKC.data <- data.frame(
  y = y,
  papc = papc,
  housing = housing,
  ca = ca,
  income = income,
  Fschool = Fschool,
  Mschool = Mschool,
  Kacs = Kacs,
  Fstress = Fstress,
  Msff = Msff,
  Mhappiness = Mhappiness,
  Mcrs = Mcrs,
  Maff = Maff,
  Minteg = Minteg,
  Fhappiness = Fhappiness,
  Faff = Faff,
  Ksfs = Ksfs,
  Kssr = Kssr,
  Kprefe = Kprefe
)

# Convert specific columns to factors
for (i in c(4, 6:7)) {
  PSKC.data[[colnames(PSKC.data)[i]]] <- factor(PSKC.data[[colnames(PSKC.data)[i]]])
}

# Display summary statistics of the data frame
summary(PSKC.data)

# Feature property: Examine categorical variables
PSKC.data %>% skim(ca, Fschool, Mschool)


# Create the dataframe with selected features and transformations

# The commented code section shows the previous approach for reference

# # Select relevant features and transform the data
# dat <- merged %>%
#   dplyr::select(
#     y, papc, housing, ca, DHu14ses006, DFt14dmg014, DMt14dmg014,
#     HIn14acs, FFt14prs, EMt14sff, EMt14shs, EMt14crs, EMt14aff,
#     EMt14integ, FFt14shs, FFt14aff, JCh14sfs, HIn14ssr, HIn14chc
#   ) %>%
#   mutate(TrtLevel = ifelse(papc == 1, "1", "0"))
#
# # Rename columns for clarity
# colnames(dat) <- c(
#   "y", "trt", "housing", "ca", "income", "Fschool", "Mschool", "Kacs", "Fstress",
#   "Msff", "Mhappiness", "Mcrs", "Maff", "Minteg", "Fhappiness", "Faff", "Ksfs", "Kssr", "Kprefe", "TrtLevel"
# )
#
# # Convert specific columns to factors
# for (i in c(4, 6:7)) {
#   dat[[colnames(dat)[i]]] <- factor(dat[[colnames(dat)[i]]])
# }
#
# # Display summary statistics of the data frame
# summary(dat)
#
# # Examine categorical variables
# dat %>% skim(ca, Fschool, Mschool)

# Extract and plot the treatment and control groups

# Plot density of 'papc' by 'ca' with color fill
ggplot(merged, aes(x = papc, fill = ca)) +
  geom_density(alpha = 0.3) +
  xlab("Park Area Per Capita (papc)") +
  ylab("Density") +
  ggtitle("Density Plot of Park Area Per Capita by Category")


# Add Propensity Score (PS) and Covariate Balancing Propensity Score (CBPS) to the dataframe

# Load necessary library
library(CBPS)

# Compute and add PS and CBPS to the dataframe
PSKC.data <- PSKC.data %>%
  mutate(
    # Calculate Propensity Score (PS) using logistic regression
    ps = predict(
      glm(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress, 
          data = PSKC.data, 
          family = binomial), 
      type = "response"
    ),
    
    # Calculate Covariate Balancing Propensity Score (CBPS)
    cbps = CBPS(
      factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress, 
      ATT = 0, 
      data = PSKC.data
    )$fitted.values
  )

# Summarize the newly added variables 'ps' and 'cbps'
PSKC.data %>% skim(ps, cbps)


# Add treatment level to the dataframe

# Convert 'papc' to a factor and add it as 'TrtLevel'
PSKC.data <- PSKC.data %>%
  mutate(
    TrtLevel = factor(papc)  # Convert 'papc' to a factor for treatment level
  )

# Summarize the 'TrtLevel' variable
PSKC.data %>% skim(TrtLevel)


# Plot distributions by treatment level

# Plot for outcome 'y'
ggplot(PSKC.data, aes(y, fill = TrtLevel)) +
  geom_density(alpha = 0.3) +
  xlab("y") 

# Plot for Propensity Score (PS)
ggplot(PSKC.data, aes(ps, fill = TrtLevel)) +
  geom_density(alpha = 0.3) +
  labs(x = "Propensity Score", title = "PS Overlap by Treatment", y = "")

# Plot for Covariate Balance Propensity Score (CBPS)
ggplot(PSKC.data, aes(cbps, fill = TrtLevel)) +
  geom_density(alpha = 0.3) +
  labs(x = "CBPS", title = "CBPS Overlap by Treatment", y = "")

# Plot for income
ggplot(PSKC.data, aes(income, fill = TrtLevel)) +
  geom_density(alpha = 0.3) +
  xlab("Income") 

# Plot for academic ability 'Kacs'
ggplot(PSKC.data, aes(Kacs, fill = TrtLevel)) +
  geom_density(alpha = 0.3) +
  xlab("Kacs") 

# Plot for father's stress 'Fstress'
ggplot(PSKC.data, aes(Fstress, fill = TrtLevel)) +
  geom_density(alpha = 0.3) +
  xlab("Fstress")

# Proportion of 'ca' by treatment level
df <- PSKC.data %>% 
  group_by(TrtLevel, ca) %>%
  summarise(count = n()) %>%
  mutate(freq = count / sum(count))
df

# Proportion of 'Fschool' by treatment level
df2 <- PSKC.data %>% 
  group_by(TrtLevel, Fschool) %>%
  summarise(count = n()) %>%
  mutate(freq = count / sum(count))
df2

# Proportion of 'Mschool' by treatment level
df3 <- PSKC.data %>% 
  group_by(TrtLevel, Mschool) %>%
  summarise(count = n()) %>%
  mutate(freq = count / sum(count))
df3


# Regression adjustment

# Fit linear model
lm1 <- lm(
  y ~ factor(papc) + housing + ca + income + Fschool + Mschool + Kacs + Fstress +
    Msff + Mhappiness + Mcrs + Maff + Minteg + Fhappiness + Faff + Ksfs + Kssr + Kprefe, 
  data = PSKC.data
)

# Display model summary
summary(lm1)

# Estimate outcomes under treatment (papc = 1) and control (papc = 0)
data1 <- PSKC.data
data1$papc <- 1
est.y1.lm <- predict(lm1, newdata = data1)

data0 <- PSKC.data
data0$papc <- 0
est.y0.lm <- predict(lm1, newdata = data0)

# Calculate and round Average Treatment Effect (ATE)
est.ATE.lm1 <- mean(est.y1.lm) - mean(est.y0.lm)
round(est.ATE.lm1, 3)

# Display 95% confidence intervals for model coefficients
round(confint(lm1, level = 0.95), 3)

# Print specific coefficient value (example given)
round(1.559e-01, 3)


# propensity score model

# Estimate propensity scores (PS) using logistic regression
propscore.model <- glm(
  factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress, 
  family = binomial(link = "logit"), 
  x = TRUE, 
  data = PSKC.data
)

# Estimate CBPS
cbps.model <- CBPS(
  factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress, 
  ATT = 0, 
  data = PSKC.data
)

# Predict propensity scores and CBPS
est.ps <- predict(propscore.model, type = "response")
est.cbps <- predict(cbps.model, type = "response")

# Plot histograms for PS
hist(
  est.ps[PSKC.data$papc == 0], 
  col = rgb(1, 0, 0, 0.2), 
  breaks = 25, 
  xlim = c(0.2, 0.8), 
  xlab = "Propensity Score", 
  main = "Treated (blue) vs. Control (red)"
)
hist(
  est.ps[PSKC.data$papc == 1], 
  col = rgb(0, 0, 1, 0.2), 
  breaks = 25, 
  xlim = c(0.2, 0.8), 
  add = TRUE
)

# Plot histograms for CBPS
hist(
  est.cbps[PSKC.data$papc == 0], 
  col = rgb(1, 0, 0, 0.2), 
  breaks = 25, 
  xlim = c(0.2, 0.8), 
  xlab = "CBPS", 
  main = "Treated (blue) vs. Control (red)"
)
hist(
  est.cbps[PSKC.data$papc == 1], 
  col = rgb(0, 0, 1, 0.2), 
  breaks = 25, 
  xlim = c(0.2, 0.8), 
  add = TRUE
)

# Check min & max of PS
# Control group
round(max(est.ps[PSKC.data$papc == 0]), 3)
round(min(est.ps[PSKC.data$papc == 0]), 3)

# Treated group
round(max(est.ps[PSKC.data$papc == 1]), 3)
round(min(est.ps[PSKC.data$papc == 1]), 3)


# ATE Calculation Using Weighting Methods by Hand with glm

# Calculate Propensity Score Weighting

# Length of the dataset
n <- length(papc)

# IPW (Inverse Probability Weighting)
IP.weight <- rep(NA, n)
IP.weight[papc == 1] <- 1 / est.ps[papc == 1]
IP.weight[papc == 0] <- -1 / (1 - est.ps[papc == 0])
est.ATE.IPW <- mean(IP.weight * y)

# Stabilized IPW (SIPW)
stabilized.IP.weight <- rep(NA, n)
stabilized.IP.weight[papc == 1] <- IP.weight[papc == 1] / sum(IP.weight[papc == 1])
stabilized.IP.weight[papc == 0] <- -IP.weight[papc == 0] / sum(IP.weight[papc == 0])
est.ATE.SPIW <- sum(stabilized.IP.weight * y)

# Doubly-Robust Estimator
est.y1.dr <- mean((papc * y - (papc - est.ps) * est.y1.lm) / est.ps)
est.y0.dr <- mean(((1 - papc) * y + (papc - est.ps) * est.y0.lm) / (1 - est.ps))
est.ATE.dr <- est.y1.dr - est.y0.dr

# Summary of results
round(c(est.ATE.lm1, est.ATE.IPW, est.ATE.SPIW, est.ATE.dr), 3)


# ATE Calculation Using Weighting Methods by Hand with CBPS

# CBPS model
cbps.model = CBPS(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress, ATT = 0, data = PSKC.data)
est.cbps <- fitted(cbps.model)
# n <- length(papc)

## IPW
IP.weight <-rep(NA, n)
IP.weight[papc==1] <- 1/est.cbps[papc==1]
IP.weight[papc==0] <- -1/(1-est.cbps[papc==0])
est.ATE.IPW <- mean(IP.weight*y)

## SIPW
stabilized.IP.weight <- rep(NA,n)
stabilized.IP.weight[papc==1] <- IP.weight[papc==1]/sum(IP.weight[papc==1])
stabilized.IP.weight[papc==0] <- -IP.weight[papc==0]/sum(IP.weight[papc==0])
est.ATE.SPIW <- sum(stabilized.IP.weight*y)

## Doubly-robust
est.y1.dr <- mean((papc*y-(papc-est.cbps)*est.y1.lm)/est.cbps)
est.y0.dr <- mean(((1-papc)*y+(papc-est.cbps)*est.y0.lm)/(1-est.cbps))
est.ATE.dr <- est.y1.dr - est.y0.dr

## results summary
round(c(est.ATE.lm1, est.ATE.IPW, est.ATE.SPIW, est.ATE.dr), 3)


# Bootstrap for Confidence interval

## bootstrap estimate of standard error for IPW & SIPW & DR
pseudo_ATE = function(iter, PSKC.data, method = "PS") {
  
  ## setting
  n = nrow(PSKC.data) 
  ipw = sipw = dr = as.numeric(iter)
  
  ## loop station
  for (b in 1:iter) {
    # seed
    set.seed(b)
    
    # randomly select the indices
    dt = PSKC.data[sample(1:n, size = n, replace = TRUE),]
    
    # choose propensity score
    if (method == "PS") {
      dt$ps = glm(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress, family = binomial, data=dt)$fitted.values
    } else if (method == "CBPS") {
      dt$ps = CBPS(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress, ATT = 0, data = dt)$fitted.values
    }
    
    # data set
    data = dt %>% 
      mutate(ipw = ifelse(papc == 1, 1/ps, 1/(1-ps)),
             simReg = predict(lm(y ~ factor(papc) + housing + ca + income + Fschool + Mschool + Kacs + Fstress + Msff + Maff + Minteg + Faff + Mhappiness + Mcrs + Fhappiness + Ksfs + Kssr + Kprefe, data = dt)))
    data = data %>% 
      mutate(sipw = ifelse(papc == 1, ipw/sum(filter(data, papc == 1)$ipw), ipw/sum(filter(data, papc == 0)$ipw)))
    
    # Doubly robust setting : confounder X & mu(z)(Xi)
    SimReg = lm(y ~ factor(papc) + housing + ca + income + Fschool + Mschool + Kacs + Fstress + Msff
                + Maff + Minteg + Faff + Mhappiness + Mcrs + Fhappiness + Ksfs + Kssr + Kprefe, data = data)
    
    X = data[c('papc','housing','ca','income','Fschool','Mschool','Kacs','Fstress','Msff','Maff','Minteg','Faff','Mhappiness','Mcrs','Fhappiness','Ksfs','Kssr','Kprefe')]
    
    mu1 = predict(SimReg, mutate(X, papc = as.factor(1)))
    mu0 = predict(SimReg, mutate(X, papc = as.factor(0)))
    
    # ATE with IPW & SIPW & Doubly Robust  
    ipw[b] = (with(filter(data, papc == 1), sum(y*ipw)) - with(filter(data, papc == 0), sum(y*ipw)))/n
    sipw[b] = (with(filter(data, papc == 1), sum(y*sipw)) - with(filter(data, papc == 0), sum(y*sipw)))
    dr[b] = (with(filter(data, papc == 1), sum((y-simReg)*ipw)) - with(filter(data, papc == 0), sum((y-simReg)*ipw)) + sum(mu1) - sum(mu0))/n
  }
  
  ## CI
  res = data.frame(IPW = c(round(mean(ipw), 3), round(sd(ipw), 3) , round(mean(ipw) - qnorm(0.975)*sd(ipw), 3), round(mean(ipw) + qnorm(0.975)*sd(ipw), 3)),
                   SIPW = c(round(mean(sipw), 3), round(sd(sipw), 3) , round(mean(sipw) - qnorm(0.975)*sd(sipw), 3), round(mean(sipw) + qnorm(0.975)*sd(sipw), 3)),
                   DR = c(round(mean(dr), 3), round(sd(dr), 3) , round(mean(dr) - qnorm(0.975)*sd(dr), 3), round(mean(dr) + qnorm(0.975)*sd(dr), 3)))
  rownames(res) = c(paste0("Point Est based on ",method),"Stand Error", "95% Lower", "95% Upper")
  
  ## result 
  return(res)
}

pseudo_ATE(iter = 100, PSKC.data, method = "PS") 
pseudo_ATE(iter = 100, PSKC.data, method = "CBPS")


# The outcome model using the inverse probability weights by hand

# Outcome Model Using Inverse Probability Weights (IPW) Manually

## Calculate IPW
ipw.papc <- augment_columns(propscore.model, PSKC.data, type.predict = "response") %>%
  rename(propensity = .fitted) %>%
  mutate(
    ipw = (papc / propensity) + ((1 - papc) / (1 - propensity))
  )

## Fit the Outcome Model Using IPW
model.ipw.papc <- lm(y ~ papc, data = ipw.papc, weights = ipw)

## Summarize the Model
tidy(model.ipw.papc) # Coefficients and statistics
round(confint(model.ipw.papc, level = 0.95), 3) # 95% Confidence Intervals

## Check Balance
# Display the first few rows of the data
head(PSKC.data)

# Compute balance for covariates
covs <- subset(PSKC.data, select = c(housing, ca, income, Fschool, Mschool, Kacs, Fstress))
bal.tab(covs, treat = PSKC.data$papc, weights = ipw.papc$ipw)


# The outcome model using the inverse probability weights with packages

# Inverse Probability Weights (IPW) with Propensity Score and Covariate Balancing Propensity Score (CBPS)

## Using Propensity Score (PS)

# Calculate IPW weights using propensity score
weights_ps <- ipwpoint(
  exposure = papc,
  family = "binomial",  # Binary treatment
  link = "logit",
  denominator = ~ ca + income + Fschool + Mschool + Kacs + Fstress,
  data = as.data.frame(PSKC.data)
)

# Display first few IPW weights
head(weights_ps$ipw.weights)
head(ipw.papc$ipw)

# Add IPW weights to the data and fit the model
PSKC_data_ps <- PSKC.data %>% 
  mutate(ipw = weights_ps$ipw.weights)

model_ps <- lm(y ~ papc, data = PSKC_data_ps, weights = ipw)
tidy(model_ps)

## Using Covariate Balancing Propensity Score (CBPS)

# Calculate weights using CBPS
weights_cbps <- weightit(
  papc ~ ca + income + Fschool + Mschool + Kacs + Fstress,
  data = PSKC.data, 
  estimand = "ATE",  # Estimate the Average Treatment Effect
  method = "cbps"    # Use CBPS method
)

# Display CBPS weights
weights_cbps
head(weights_cbps$weights)

# Add CBPS weights to the data and fit the model
PSKC_data_cbps <- PSKC.data %>% 
  mutate(ipw = weights_cbps$weights)

model_cbps <- lm(y ~ papc, data = PSKC_data_cbps, weights = ipw)
tidy(model_cbps)

# Summary statistics
round(c(-0.06067547, 0.1654011), 3)
round(confint(model_cbps, level = 0.95), 3)

## Test Covariate Balance
covs <- subset(PSKC.data, select = c(housing, ca, income, Fschool, Mschool, Kacs, Fstress))
bal.tab(covs, treat = PSKC.data$papc, weights = weights_cbps$weights)


# Prepare data for matching by selecting relevant columns

# Exclude specific columns from the dataset
matching.data <- subset(
  PSKC.data,
  select = -c(
    housing, Msff, Mhappiness, Mcrs, Maff, Minteg, Fhappiness, Faff, Ksfs, Kssr, Kprefe, ps, cbps, TrtLevel
  )
)

# Display the resulting dataset
matching.data


# Method: PSM

# Propensity Score Matching (PSM)

# Calculate propensity score distance
# propscore.model <- glm(
#   factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
#   family = binomial(link = "logit"), x = TRUE, data = PSKC.data
# )
ps.dist <- match_on(est.ps, z = matching.data$papc)

# Perform matching
psm.out <- matchit(
  factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
  data = matching.data,
  method = "optimal",
  estimand = "ATT",
  distance = ps.dist
)

# Display summary of the matching results
summary(psm.out)

# Plot balance diagnostics
plot(
  summary(psm.out),
  var.order = "unmatched"
)


# Method: CBPSM

# Covariate Balancing Propensity Score Matching (CBPSM)

# Fit CBPS model
cbps.model <- CBPS(
  factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
  ATT = 0,
  data = matching.data
)

# Use CBPS model to estimate propensity scores
# est.cbps <- fitted(cbps.model)
# est.cbps <- predict(cbps.model, type = "response")

# Perform CBPS matching
cbpsm.out <- matchit(
  factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
  data = matching.data,
  method = "optimal",
  distance = "cbps",
  estimand = "ATT"
)

# Display summary of the CBPS matching results
summary(cbpsm.out, un = FALSE)

# Plot balance diagnostics for CBPS matching
plot(
  summary(cbpsm.out),
  var.order = "unmatched"
)


# Method: Propensity Score Caliper Matching
# Using Rank-Based Mahalanobis Distance Within Propensity Score Calipers

# Mahalanobis Distance Matching

# Compute the rank-based Mahalanobis distance
smahal.dist <- optmatch::match_on(
  papc ~ ca + income + Fschool + Mschool + Kacs + Fstress,
  method = "rank_mahalanobis"
)

# Uncomment to perform matching and summarize results without caliper
# mc.out <- matchit(
#   factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
#   data = PSKC.data,
#   method = "optimal",
#   distance = smahal.dist,
#   replace = FALSE
# )
# summary(mc.out, un = FALSE)
# plot(summary(mc.out), var.order = "unmatched")

# Apply a caliper width of 0.1 to Mahalanobis distance
smahal.dist3 <- smahal.dist + caliper(ps.dist, width = 0.1)

# Perform matching with the caliper-adjusted Mahalanobis distance
mc.out3 <- matchit(
  factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
  data = matching.data,
  method = "optimal",
  distance = as.matrix(smahal.dist3)
)
summary(mc.out3, un = FALSE)
plot(summary(mc.out3), var.order = "unmatched")

# Uncomment to use Mahalanobis distance with near-exact matching for housing
# smahal.dist.housing <- addalmostexact(
#   as.matrix(smahal.dist),
#   PSKC.data$papc,
#   PSKC.data$housing,
#   mult = 10
# )
# mc.housing.out <- matchit(
#   factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
#   data = PSKC.data,
#   method = "optimal",
#   distance = as.matrix(smahal.dist.housing)
# )
# summary(mc.housing.out, un = FALSE)
# plot(summary(mc.housing.out), var.order = "unmatched")


# Method: CEM

# Coarsened Exact Matching (CEM) on Covariates, Excluding Capital Area Indicator
# Grouping Parent’s Education: University and Graduate School Combined

cem.out = matchit(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
                  data = matching.data, method = "cem", estimand = "ATT",
                  cutpoints = list(income = "q10", Kacs = "q4", Fstress = "q4"),
                  grouping = list(Mschool = list("4", "5", "6", "7"),
                                  Fschool = list("4", "5", "6", "7")),
                  k2k = TRUE)

summary(cem.out)
plot(summary(cem.out), var.order = "unmatched")


# Method: cardinality matching

# Load necessary library
# install.packages("Rglpk")
library(Rglpk)

# Step 1: Find control group with SMD ≤ 0.01
m.card.out = matchit(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
                     data = matching.data, method = "cardinality", tols = 0.01, solver = "glpk")

# Improved speed with exact matching on `ca`
# m.card.out = matchit(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
#                      data = PSKC.data, method = "cardinality", tols = 0.01, solver = "glpk", exact = ~ca)

summary(m.card.out, un = FALSE)
plot(summary(m.card.out), var.order = "unmatched")

# Step 2: Re-match to improve balance within pairs
# Match similar `x` values within control group with SMD ≤ 0.01
m.card.re = matchit(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress, 
                    data = matching.data, method = "optimal", distance = "mahalanobis",
                    discard = m.card.out$weights == 0)

summary(m.card.re, un = FALSE)
plot(summary(m.card.re), var.order = "unmatched")

# Extract matched data
m.card = match.data(m.card.re)


# plots

new.names <- c(ca = "Living inside capital area (Y/N)",
               income = "Household income",
               Fschool_4 = "Father’s education level: high school and below",
               Fschool_5 = "Father’s education level: associate",
               Fschool_6 = "Father’s education level: bachelor",
               Fschool_7 = "Father’s education level: post-graduate",
               Mschool_4 = "Mother’s education level: high school and below",
               Mschool_5 = "Mother’s education level: associate",
               Mschool_6 = "Mother’s education level: bachelor",
               Mschool_7 = "Mother’s education level: post-graduate",
               Kacs = "Child's literacy",
               Fstress = "Father's stress"
)

love.plot(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
          data = matching.data, estimand = "ATT",
          stats = "mean.diffs",
          weights = list(w1 = get.w(psm.out),
                         w2 = get.w(cbpsm.out),
                         w3 = get.w(mc.out3),
                         w4 = get.w(cem.out),
                         w5 = get.w(m.card.re)),
          var.order = "unadjusted",
          stars = "raw",
          binary = "std",
          abs = TRUE,
          line = FALSE, 
          thresholds = c(m = .1),
          var.names = new.names,
          #          colors = c("darkgrey", "red", "blue", "darkgreen", "Yellow", "purple"),
          sample.names = c("Raw", "PSM", "CBPSM", "Caliper", "CEM", "Cardinality"),
          position = "bottomright",
          limits = c(0, 1.05)) +
  theme(legend.position = c(.87, .27),
        legend.box.background = element_rect(), 
        legend.box.margin = margin(1, 1, 1, 1))


# Separate optimal pair matching for ca and non-ca

# Matching with separate treatments: Capital Area vs. Non-Capital Area
# Since the outcome was not used in the matching process, it's fine to repeat the matching process multiple times
# Split the matching problem into two cases: Capital Area (ca) and Non-Capital Area (non-ca)

# Perform exact matching with the Capital Area indicator
m.exact.out <- matchit(
  formula = factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
  data = PSKC.data,
  method = "optimal",
  distance = "robust_mahalanobis",
  exact = ~ ca
)

# Summary of the matching results
summary(m.exact.out, un = FALSE)

# Plot the results of the matching
plot(
  summary(m.exact.out),
  var.order = "unmatched"
)


# L1 Distance Calculation
# Load necessary packages

# Check if Tcl/Tk capabilities are available
capabilities("tcltk")

# List directories and check for Tcl/Tk libraries
system("ls -ld /usr/local /usr/local/lib /usr/local/lib/libtcl*")

# Install required packages (uncomment if needed)
# install.packages(c("lattice", "cem"))

# Load libraries
library(lattice)  # For lattice-based plotting
library(cem)      # For Coarsened Exact Matching (CEM)


# Imbalance Check

# Raw Data Imbalance
# Calculate imbalance metrics for the raw data before matching
raw = imbalance(matching.data$papc, matching.data, drop = c("y", "papc"))
raw

# Propensity Score Matching (PSM)
if (require(MatchIt)) {
  # Create distance matrix for PSM
  ps.dist = match_on(est.ps, z = matching.data$papc)
  
  # Perform optimal matching using propensity score distance
  psm.out = matchit(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
                    data = matching.data, method = "optimal", distance = ps.dist)
  
  # Calculate imbalance metrics for PSM
  psm = imbalance(matching.data$papc, matching.data, drop = c("y", "papc"), weights = psm.out$weights)
  psm
}

# CBPS Matching
if (require(MatchIt)) {
  # Perform optimal matching using CBPS distance
  cbpsm.out = matchit(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
                      data = matching.data, method = "optimal", distance = "cbps", estimand = "ATT")
  
  # Calculate imbalance metrics for CBPSM
  cbpsm = imbalance(matching.data$papc, matching.data, drop = c("y", "papc"), weights = cbpsm.out$weights)
  cbpsm
}

# PS with Caliper
if (require(MatchIt)) {
  # Compute rank-based Mahalanobis distance
  smahal.dist <- optmatch::match_on(
    papc ~ ca + income + Fschool + Mschool + Kacs + Fstress,
    method = "rank_mahalanobis"
  )
  
  # Add caliper to Mahalanobis distance
  smahal.dist3 = smahal.dist + caliper(ps.dist, width = 0.1)
  
  # Perform optimal matching using Mahalanobis distance with caliper
  mc.out3 = matchit(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
                    data = matching.data, method = "optimal", distance = as.matrix(smahal.dist3))
  
  # Calculate imbalance metrics for Mahalanobis distance with caliper
  mc3 = imbalance(matching.data$papc, matching.data, drop = c("y", "papc"), weights = mc.out3$weights)
  mc3
}

# Coarsened Exact Matching (CEM)
if (require(MatchIt)) {
  # Perform CEM with specified cutpoints and grouping
  cem.out = matchit(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress,
                    data = matching.data, method = "cem", estimand = "ATT",
                    cutpoints = list(income = "q10", Kacs = "q4", Fstress = "q4"),
                    grouping = list(Mschool = list("4", "5", "6", "7"), Fschool = list("4", "5", "6", "7")),
                    k2k = TRUE)
  
  # Calculate imbalance metrics for CEM
  cem = imbalance(matching.data$papc, matching.data, drop = c("y", "papc"), weights = cem.out$weights)
  cem
}

# Cardinality Matching
if (require(MatchIt)) {
  # Perform cardinality matching with specified distance and discard criteria
  m.card.re = matchit(factor(papc) ~ ca + income + Fschool + Mschool + Kacs + Fstress, 
                      data = matching.data, method = "optimal", distance = "mahalanobis",
                      discard = m.card.out$weights == 0)
  
  # Calculate imbalance metrics for cardinality matching
  m.card = imbalance(matching.data$papc, matching.data, drop = c("y", "papc"), weights = m.card.re$weights)
  m.card
}

