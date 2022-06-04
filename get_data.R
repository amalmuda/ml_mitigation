# Script to download statsys data to data folder

# Loading packages
library(googledrive)
library(here)

# Connecting to noradstats google drive
googledrive::drive_auth(email = "noradstats@gmail.com")

# Find available files
googledrive::drive_find()

# Create ./data-folder if not present.
if(file.exists("./data") == FALSE) {
  dir.create(file.path("./data"))
}

selected_file <- "statsys_ten.csv"

# Download file, using generic filename
googledrive::drive_download(file = selected_file, path = here("data", selected_file), overwrite = TRUE)
