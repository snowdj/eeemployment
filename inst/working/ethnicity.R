cat <- dplyr::quo(ETHUK11)
cat_name <- "ethnicity"

# subsetting is useful to be able to use View()
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
    ETHUK11
  )

# ethnicity_lookup <-
#   read.csv("inst/extdata/ethnicity_lookup.csv", stringsAsFactors = FALSE)
# devtools::use_data(ethnicity_lookup, overwrite = TRUE)


cleaned_subset <- raw_subset_2016 %>%
  dplyr::mutate(SECJMBR = ifelse(SECJMBR == 3, 1, SECJMBR)) %>%
  dplyr::mutate(ETHUK11 = as.integer(!!cat)) %>%
  dplyr::left_join(ethnicity_lookup, by = c("ETHUK11" = "ons_spss_code")) %>%
  dplyr::select(-ETHUK11) %>%
  dplyr::rename(ETHUK11 = label) %>%

  # below was included in SPSS but I can't work out how to make do it for labels, and the values don't appear in the data anyway
  # dplyr::mutate(NSECMJ10 = ifelse(NSECMJ10 == -8, 23, NSECMJ10)) %>%
  # dplyr::mutate(NSECMJ10 = ifelse(NSECMJ10 == -9, 23, NSECMJ10)) %>%

  dplyr::mutate(DCMS_main = ifelse(INDC07M %in% sics, 1, 0)) %>%
  dplyr::mutate(DCMS_second = ifelse(INDC07S %in% sics, 1, 0))

ethnicity <- summarise_cat(cleaned_subset, ETHUK11)

openxlsx::write.xlsx(ethnicity, paste0("ethnicity", ".xlsx"))
