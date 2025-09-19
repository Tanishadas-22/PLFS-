############################   Creating HH_ID 
rm(list = ls())

library(haven)
library(dplyr)
library(stringr)
library(writexl)

data <- read_sav("~/PLFS 2024/hhv1.sav")

data <- data %>%
  mutate(
    b1q1_hhv1_chr = as.character(b1q1_hhv1),
    b1q14_hhv1_chr = as.character(b1q14_hhv1),
    b1q15_hhv1_chr = as.character(b1q15_hhv1),
    hhid = str_c(b1q1_hhv1_chr, b1q14_hhv1_chr, b1q15_hhv1_chr, sep = "_")  # FSU, Second Stage Stratum No., Sample Household Number
  )

selected_data <- data %>%
  select(
    hhid,
    Social_group = b3q4_hhv1,                      
    Household_Size = b3q1_hhv1,
    Household_Usual_Consumer_Expenditure_Month = b3q5pt6_hhv1
  ) %>%
  slice_sample(n = 253) %>%                      # Take a random sample of 253 records
  mutate(
    Sample_Serial_number = row_number()        # Add natural numbers as sample serial number
  )%>%
select(
  hhid,
  Sample_Serial_number,
  Social_group,
  Household_Size,
  Household_Usual_Consumer_Expenditure_Month
)

View(selected_data)

#length(unique(selected_data$hhid))

#write_xlsx(selected_data, "~/PLFS 2024/hhv1_253_households.xlsx")





################################   Sample Draw 


rm(list = ls())
library(readxl)
library(dplyr)

population <- read_excel("~/PLFS 2024/hhv1_253_households.xlsx")
head(population)

n <- 25  
N <- nrow(population)

                                              ########## SRSWOR

sample_srswor <- population %>%
  slice_sample(n = n, replace = FALSE)

View(sample_srswor)


                                              ########### SRSWR

sample_srswr <- population %>%
  slice_sample(n = n, replace = TRUE)

View(sample_srswr)


                                              ############ Linear Systematic Sampling

k <- floor(N / n)                                           

set.seed(123)                                              
start <- sample(1:k, 1)                                     

indices <- seq(start, by = k, length.out = n)

sample_linear_systematic <- population[indices, ]

head(sample_linear_systematic)


                                              ##############  Circular Systematic Sampling

set.seed(123)
start <- sample(1:k, 1)

indices_circular <- ((start - 1) + (0:(n-1)) * k) %% N + 1

sample_circular_systematic <- population[indices_circular, ]

head(sample_circular_systematic)


                                              ###############  Explicit Stratified Sampling


unique(population$Social_group)

stratum_sizes <- population %>%
  count(Social_group) %>%
  mutate(sample_size = round(n / sum(n) * n))                       # proportional allocation

sample_stratified <- population %>%
  group_by(Social_group) %>%
  group_modify(~ slice_sample(.x, n = stratum_sizes$sample_size[stratum_sizes$Social_group == .y$Social_group], replace = FALSE)) %>%
  ungroup()

View(sample_stratified)


                                              ################  Implicit

population_sorted <- population %>%                             
  arrange(Social_group)                                   # Household_Size is omitted from the arrange portion

k_implicit <- floor(N / n)

set.seed(123)
start_implicit <- sample(1:k_implicit, 1)

indices_implicit <- seq(start_implicit, by = k_implicit, length.out = n)

sample_implicit_stratification <- population_sorted[indices_implicit, ]

head(sample_implicit_stratification)



                                         ##### Create a named list of data frames, each element will be a sheet
library(writexl)
output_list <- list(
  SRSWOR = sample_srswor,
  SRSWR = sample_srswr,
  Linear_Systematic = sample_linear_systematic,
  Circular_Systematic = sample_circular_systematic,
  Stratified = sample_stratified,
  Implicit_Stratification = sample_implicit_stratification
)
#write_xlsx(output_list, path = "~/PLFS 2024/different_sampling_outputs.xlsx")







######################################   estimates


library(tidyr)

calculate_estimates <- function(sample_data) {
  total_household_size <- sum(sample_data$Household_Size, na.rm = TRUE)
  total_population <- total_household_size
  avg_household_size <- mean(sample_data$Household_Size, na.rm = TRUE)
  avg_monthly_expenditure <- mean(sample_data$Household_Usual_Consumer_Expenditure_Month, na.rm = TRUE)
  mpce <- sum(sample_data$Household_Usual_Consumer_Expenditure_Month, na.rm = TRUE) / total_population
  
  tibble(
    Total_Household_Size = total_household_size,
    Total_Population = total_population,
    Average_Household_Size = avg_household_size,
    Average_Monthly_Expenditure = avg_monthly_expenditure,
    MPCE = mpce
  )
}

results <- tibble(
  Sampling_Method = c("SRSWOR", "SRSWR", "Linear Systematic", "Circular Systematic", "Stratified", "implicit_stratification"),
  Estimates = list(
    calculate_estimates(sample_srswor),
    calculate_estimates(sample_srswr),
    calculate_estimates(sample_linear_systematic),
    calculate_estimates(sample_circular_systematic),
    calculate_estimates(sample_stratified),
    calculate_estimates(sample_implicit_stratification)
  )
) %>%
  tidyr::unnest(cols = c(Estimates))

print(results)

#write_xlsx(results, path = "~/PLFS 2024/estiates_outputs.xlsx")





