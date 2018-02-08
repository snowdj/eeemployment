cat <- dplyr::quo(NATOX7)
cat_name <- "eu"

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
    NATOX7
  )

#nation_lookup <- read.csv("inst/extdata/nation_lookup.csv")
#devtools::use_data(nation_lookup)


cleaned_subset <- raw_subset_2016 %>%
  dplyr::mutate(SECJMBR = ifelse(SECJMBR == 3, 1, SECJMBR)) %>%
  dplyr::mutate(NATOX7 = as.integer(!!cat)) %>%
  dplyr::left_join(nation_lookup, by = c("NATOX7" = "ons_spss_code")) %>%
  dplyr::rename(NEWNAT = dcms_label2) %>%
  dplyr::mutate(NEWNAT = as.character(NEWNAT)) %>%

  # below was included in SPSS but I can't work out how to make do it for labels, and the values don't appear in the data anyway
  # dplyr::mutate(NSECMJ10 = ifelse(NSECMJ10 == -8, 23, NSECMJ10)) %>%
  # dplyr::mutate(NSECMJ10 = ifelse(NSECMJ10 == -9, 23, NSECMJ10)) %>%

  dplyr::mutate(DCMS_main = ifelse(INDC07M %in% sics, 1, 0)) %>%
  dplyr::mutate(DCMS_second = ifelse(INDC07S %in% sics, 1, 0))

eu <- summarise_cat(cleaned_subset, NATOX7)

openxlsx::write.xlsx(eu, paste0("eu", ".xlsx"))
