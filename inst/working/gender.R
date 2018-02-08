cat <- dplyr::quo(SEX)
cat_name <- "gender"

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
    SEX
  )

# both the sic lists in spss are identical - and between programs i think they are identical
sics <- c(1820, 2611, 2612, 2620, 2630, 2640, 2680, 3012, 3212, 3220, 3230, 4651, 4652, 4763, 4764, 4910, 4932, 4939, 5010, 5030, 5110, 5510, 5520, 5530, 5590, 5610, 5621, 5629, 5630, 5811, 5812, 5813, 5814, 5819, 5821, 5829, 5911, 5912, 5913, 5914, 5920, 6010, 6020, 6110, 6120, 6130, 6190, 6201, 6202, 6203, 6209, 6311, 6312, 6391, 6399, 6820, 7021, 7111, 7311, 7312, 7410, 7420, 7430, 7711, 7721, 7722, 7729, 7734, 7735, 7740, 7911, 7912, 7990, 8230, 8551, 8552, 9001, 9002, 9003, 9004, 9101, 9102, 9103, 9104, 9200, 9311, 9312, 9313, 9319, 9321, 9329, 9511, 9512)

#sort(unique(raw_subset_2016$SECJMBR))

cleaned_subset_2016 <- raw_subset_2016 %>%
  dplyr::mutate(SECJMBR = ifelse(SECJMBR == 3, 1, SECJMBR)) %>%
  dplyr::mutate(SEX = as.character(haven::as_factor(!!cat))) %>%

  # below was included in SPSS but I can't work out how to make do it for labels, and the values don't appear in the data anyway
  # dplyr::mutate(NSECMJ10 = ifelse(NSECMJ10 == -8, 23, NSECMJ10)) %>%
  # dplyr::mutate(NSECMJ10 = ifelse(NSECMJ10 == -9, 23, NSECMJ10)) %>%

  dplyr::mutate(SEX = ifelse(is.na(!!cat), "Missing", !!cat)) %>%
  dplyr::mutate(DCMS_main = ifelse(INDC07M %in% sics, 1, 0)) %>%
  dplyr::mutate(DCMS_second = ifelse(INDC07S %in% sics, 1, 0))

## Main job, employee - all jobs - weighted.
DCMS_Main_Employee_4digit <- cleaned_subset_2016 %>%
  dplyr::filter(INECAC05 == 1 & DCMS_main == 1) %>%
  # try weighting before
  dplyr::mutate(M_E_DCMS = DCMS_main * PWTA16) %>%
  dplyr::group_by(INDC07M, !!cat) %>%
  dplyr::summarise(M_E_DCMS = sum(M_E_DCMS)) %>%
  dplyr::rename(SIC = INDC07M)


# Main job, self employed - all jobs - weighted.
DCMS_Main_Self_4digit <- cleaned_subset_2016 %>%
  dplyr::filter(INECAC05 == 2 & DCMS_main == 1) %>%
  # try weighting before
  dplyr::mutate(M_SE_DCMS = DCMS_main * PWTA16) %>%
  dplyr::group_by(INDC07M, !!cat) %>%
  dplyr::summarise(M_SE_DCMS = sum(M_SE_DCMS)) %>%
  dplyr::rename(SIC = INDC07M)

# Second job, employee - all jobs - weighted.
DCMS_Second_Employee_4digit <- cleaned_subset_2016 %>%
  dplyr::filter(SECJMBR == 1 & DCMS_second == 1) %>%
  # try weighting before
  dplyr::mutate(S_E_DCMS = DCMS_second * PWTA16) %>%
  dplyr::group_by(INDC07S, !!cat) %>%
  dplyr::summarise(S_E_DCMS = sum(S_E_DCMS)) %>%
  dplyr::rename(SIC = INDC07S)

# Second job, self-employed - all jobs - weighted.
DCMS_Second_Self_4digit <- cleaned_subset_2016 %>%
  dplyr::filter(SECJMBR == 2 & DCMS_second == 1) %>%
  # try weighting before
  dplyr::mutate(S_SE_DCMS = DCMS_second * PWTA16) %>%
  dplyr::group_by(INDC07S, !!cat) %>%
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

openxlsx::write.xlsx(final, paste0(cat_name, ".xlsx"))
