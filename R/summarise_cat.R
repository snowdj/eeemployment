summarise_cat <- function(cleaned_subset) {
  ## Main job, employee - all jobs - weighted.
  DCMS_Main_Employee_4digit <- cleaned_subset %>%
    dplyr::filter(INECAC05 == 1 & DCMS_main == 1) %>%
    # try weighting before
    dplyr::mutate(M_E_DCMS = DCMS_main * PWTA16) %>%
    dplyr::group_by(INDC07M, !!cat) %>%
    dplyr::summarise(M_E_DCMS = sum(M_E_DCMS)) %>%
    dplyr::rename(SIC = INDC07M)


  # Main job, self employed - all jobs - weighted.
  DCMS_Main_Self_4digit <- cleaned_subset %>%
    dplyr::filter(INECAC05 == 2 & DCMS_main == 1) %>%
    # try weighting before
    dplyr::mutate(M_SE_DCMS = DCMS_main * PWTA16) %>%
    dplyr::group_by(INDC07M, !!cat) %>%
    dplyr::summarise(M_SE_DCMS = sum(M_SE_DCMS)) %>%
    dplyr::rename(SIC = INDC07M)

  # Second job, employee - all jobs - weighted.
  DCMS_Second_Employee_4digit <- cleaned_subset %>%
    dplyr::filter(SECJMBR == 1 & DCMS_second == 1) %>%
    # try weighting before
    dplyr::mutate(S_E_DCMS = DCMS_second * PWTA16) %>%
    dplyr::group_by(INDC07S, !!cat) %>%
    dplyr::summarise(S_E_DCMS = sum(S_E_DCMS)) %>%
    dplyr::rename(SIC = INDC07S)

  # Second job, self-employed - all jobs - weighted.
  DCMS_Second_Self_4digit <- cleaned_subset %>%
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

  return(final)
}
