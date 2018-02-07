# devtools::install_version("haven", version = "1.1.0", repos = "http://cran.us.r-project.org")
raw_2016 <- haven::read_sav("G:/Economic Estimates/APS/2016/APSP_JD16_CLIENT_PWTA16.sav")

# devtools::use_data(raw_2016)
# for some reason load_all wont give access so use:
load("data/raw_2016.rda")
library(magrittr)

