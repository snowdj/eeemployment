cat <- dplyr::quo(NATOX7)
cat_name <- "gender"

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
    NATOX7,
    AGE
  )

#nation_lookup <- read.csv("inst/extdata/nation_lookup.csv")
#devtools::use_data(nation_lookup)


cleaned_subset <- raw_subset_2016 %>%
  dplyr::mutate(SECJMBR = ifelse(SECJMBR == 3, 1, SECJMBR)) %>%
  dplyr::mutate(NewAge = ifelse(AGE < 30, 29, 30)) %>%
  dplyr::mutate(NATOX7 = as.integer(!!cat)) %>%
  dplyr::left_join(nation_lookup, by = c("NATOX7" = "ons_spss_code")) %>%
  dplyr::rename(NEWNAT = dcms_label2) %>%
  dplyr::mutate(NEWNAT = as.character(NEWNAT)) %>%

  # below was included in SPSS but I can't work out how to make do it for labels, and the values don't appear in the data anyway
  # dplyr::mutate(NSECMJ10 = ifelse(NSECMJ10 == -8, 23, NSECMJ10)) %>%
  # dplyr::mutate(NSECMJ10 = ifelse(NSECMJ10 == -9, 23, NSECMJ10)) %>%

  dplyr::mutate(DCMS_main = ifelse(INDC07M %in% sics, 1, 0)) %>%
  dplyr::mutate(DCMS_second = ifelse(INDC07S %in% sics, 1, 0))


DCMS_Main_Employee_4digit <- cleaned_subset %>%
  dplyr::filter(INECAC05 == 1 & DCMS_main == 1) %>%
  # try weighting before
  dplyr::mutate(M_E_DCMS = DCMS_main * PWTA16) %>%
  dplyr::group_by(INDC07M, NEWNAT, NewAge) %>%
  dplyr::summarise(M_E_DCMS = sum(M_E_DCMS)) %>%
  dplyr::rename(SIC = INDC07M)


# Main job, self employed - all jobs - weighted.
DCMS_Main_Self_4digit <- cleaned_subset %>%
  dplyr::filter(INECAC05 == 2 & DCMS_main == 1) %>%
  # try weighting before
  dplyr::mutate(M_SE_DCMS = DCMS_main * PWTA16) %>%
  dplyr::group_by(INDC07M, NEWNAT, NewAge) %>%
  dplyr::summarise(M_SE_DCMS = sum(M_SE_DCMS)) %>%
  dplyr::rename(SIC = INDC07M)

# Second job, employee - all jobs - weighted.
DCMS_Second_Employee_4digit <- cleaned_subset %>%
  dplyr::filter(SECJMBR == 1 & DCMS_second == 1) %>%
  # try weighting before
  dplyr::mutate(S_E_DCMS = DCMS_second * PWTA16) %>%
  dplyr::group_by(INDC07S, NEWNAT, NewAge) %>%
  dplyr::summarise(S_E_DCMS = sum(S_E_DCMS)) %>%
  dplyr::rename(SIC = INDC07S)

# Second job, self-employed - all jobs - weighted.
DCMS_Second_Self_4digit <- cleaned_subset %>%
  dplyr::filter(SECJMBR == 2 & DCMS_second == 1) %>%
  # try weighting before
  dplyr::mutate(S_SE_DCMS = DCMS_second * PWTA16) %>%
  dplyr::group_by(INDC07S, NEWNAT, NewAge) %>%
  dplyr::summarise(S_SE_DCMS = sum(S_SE_DCMS)) %>%
  dplyr::rename(SIC = INDC07S)


# the next steps simply faff around joining the 4 datasets and renaming inc07 to SIC

main <-
  dplyr::full_join(
    DCMS_Main_Employee_4digit,
    DCMS_Main_Self_4digit
  )

second <-
  dplyr::full_join(
    DCMS_Second_Employee_4digit,
    DCMS_Second_Self_4digit
  )

final <- dplyr::full_join(
  main,
  second
  #by = c("SIC", "NewAge")
)
final[is.na(final)] <- 0

final <- final %>%
  dplyr::mutate(employed = M_E_DCMS	+ S_E_DCMS) %>%
  dplyr::mutate(selfemployed = M_SE_DCMS	+ S_SE_DCMS) %>%
  dplyr::mutate(employment = employed	+ selfemployed)


# openxlsx::write.xlsx(final, paste0("eu_age", ".xlsx"))
