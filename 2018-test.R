library(tidyverse)
library(noradstats)
library(here)

library(tidyverse)
library(tidymodels)
library(stopwords)
library(tidytext)
library(stringr)
library(textrecipes)
library(themis)
library(LiblineaR)
library(ranger)
library(doParallel)
library(noradstats)
library(here)
library(janitor)
library(knitr)


# Load and prepare data ---------------------------------------------------

# Load statsys data for the ten last years
df_statsys <- noradstats::read_aiddata(here("data", "statsys_ten.csv")) |> 
  janitor::clean_names()

# Exclude non-ODA agreements, exclude the frame agreement level and chose years. Sorting levels.
df_oda <- df_statsys |> 
  filter(type_of_flow == "ODA",
         type_of_agreement != "Rammeavtale") |> 
  mutate(pm_climate_change_mitigation = fct_relevel(pm_climate_change_mitigation, "None", after = Inf))

# Making a binary variable "mitigation" and character variable "title_desc"
df_oda <- df_oda |>
  mutate(mitigation = if_else(pm_climate_change_mitigation == "None", "Not mitigation", "Mitigation")) |> 
  mutate(title_desc = paste0(agreement_title, ". ", description_of_agreement))

# Load and test algo ------------------------------------------------------

# Inklude only new agreements

df_old <- df_oda |> 
  filter(year %in% c(2013:2017)) |> 
  distinct()


df_2018 <- df_oda |> 
  filter(year == 2018) |> 
  distinct()

df_2018 <- df_2018 |> 
  filter(!agreement_number %in% df_old$agreement_number)

final_workflow <- readRDS("final_workflow.rds")

# Predict on testing data
df_pred <- augment(final_workflow, new_data = df_2018)

df_pred |> 
  conf_mat(mitigation, .pred_class)

df_pred |> 
  conf_mat(mitigation, .pred_class) |> 
  autoplot()

sensitivity <- 216 / (216+108)*100
