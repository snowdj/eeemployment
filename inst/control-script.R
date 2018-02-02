# install.packages("haven")
# remove.packages("haven")
# devtools::install_version("haven", version = "1.1.0", repos = "http://cran.us.r-project.org")
# packageVersion("haven")
raw_2016 <- haven::read_sav("G:/Economic Estimates/APS/2016/APSP_JD16_CLIENT_PWTA16.sav")

raw_2016 <-
  foreign::?read.spss(
    "G:/Economic Estimates/APS/2016/APSP_JD16_CLIENT_PWTA16.sav",
    to.data.frame = TRUE)
raw_2016 <- as.data.frame(raw_2016, stringsAsFactors = FALSE)
raw_subset_2016 <- raw_2016 %>%
  dplyr::select(
    INDC07M,
    INDC07S,
    SOC10M,
    SOC10S,
    INECAC05,
    SECJMBR,
    PWTA16,
    INDSC07M,
    INDSC07S,
    SEX,
    AGES,
    AGE) %>%
  dplyr::mutate(ifelse(secjmbr = secjmbr == 3, 1, secjmbr)) %>%
  dplyr::mutate(NewAge = ifelse(age < 29, 29, 30)
    age (Lowest thru 29=29) (30 thru Highest=30) (ELSE=SYSMIS) INTO NewAge)

raw2 <- raw



# for development use saved cleaned raw data
# save(raw)
load(raw)
