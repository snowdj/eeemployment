# devtools::install_version("haven", version = "1.1.0", repos = "http://cran.us.r-project.org")
# raw_2016 <- haven::read_sav("G:/Economic Estimates/APS/2016/APSP_JD16_CLIENT_PWTA16.sav")

# devtools::use_data(raw_2016)

# load_all() will load the raw data every time you run it without reset = FALSE
devtools::load_all(reset = FALSE)

# raw_2016 <- eeemployment::raw_2016

library(magrittr)

# both the sic lists in spss are identical - and between programs i think they are identical
sics <- c(1820, 2611, 2612, 2620, 2630, 2640, 2680, 3012, 3212, 3220, 3230, 4651, 4652, 4763, 4764, 4910, 4932, 4939, 5010, 5030, 5110, 5510, 5520, 5530, 5590, 5610, 5621, 5629, 5630, 5811, 5812, 5813, 5814, 5819, 5821, 5829, 5911, 5912, 5913, 5914, 5920, 6010, 6020, 6110, 6120, 6130, 6190, 6201, 6202, 6203, 6209, 6311, 6312, 6391, 6399, 6820, 7021, 7111, 7311, 7312, 7410, 7420, 7430, 7711, 7721, 7722, 7729, 7734, 7735, 7740, 7911, 7912, 7990, 8230, 8551, 8552, 9001, 9002, 9003, 9004, 9101, 9102, 9103, 9104, 9200, 9311, 9312, 9313, 9319, 9321, 9329, 9511, 9512)

# I dont understand why there is a value of 0 in NEWNAT for eu and age - I'm  just gonna leave it for now - the row is set as missing in my data
 # can't work out why ethnicity figures don't match

raw_subset_2016 <- eeemployment::raw_2016 %>%
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
    AGE)

library(magrittr)

# part 1 - update categories

# part 2 - created weighted count just say use weight col if sic in siclist

# part 3 - need to calculate main and second job individually, split by e/se
# can we just add both together first? so employed, keep weight if INECAC05 = 1 and SECJMBR = 1.

# part 4 - group by sic and category

cleaned_subset <- raw_subset_2016 %>%
  dplyr::mutate(SECJMBR = ifelse(SECJMBR == 3, 1, SECJMBR)) %>%
  dplyr::mutate(NewAge = ifelse(AGE < 30, 29, 30)) %>%
  dplyr::mutate(DCMS_main = ifelse(INDC07M %in% sics, 1, 0)) %>%
  dplyr::mutate(DCMS_second = ifelse(INDC07S %in% sics, 1, 0))


## Main job, employee - all jobs - weighted.
DCMS_Main_Employee_4digit_newage <- cleaned_subset %>%
  dplyr::filter(INECAC05 == 1 & DCMS_main == 1) %>%
  # try weighting before
  dplyr::mutate(M_E_DCMS = DCMS_main * PWTA16) %>%
  dplyr::group_by(INDC07M, NewAge) %>%
  dplyr::summarise(M_E_DCMS = sum(M_E_DCMS)) %>%
  dplyr::rename(SIC = INDC07M)

# Main job, self employed - all jobs - weighted.
DCMS_Main_Self_4digit_newage <- cleaned_subset %>%
  dplyr::filter(INECAC05 == 2 & DCMS_main == 1) %>%
  # try weighting before
  dplyr::mutate(M_SE_DCMS = DCMS_main * PWTA16) %>%
  dplyr::group_by(INDC07M, NewAge) %>%
  dplyr::summarise(M_SE_DCMS = sum(M_SE_DCMS)) %>%
  dplyr::rename(SIC = INDC07M)

# Second job, employee - all jobs - weighted.
DCMS_Second_Employee_4digit_newage <- cleaned_subset %>%
  dplyr::filter(SECJMBR == 1 & DCMS_second == 1) %>%
  # try weighting before
  dplyr::mutate(S_E_DCMS = DCMS_second * PWTA16) %>%
  dplyr::group_by(INDC07S, NewAge) %>%
  dplyr::summarise(S_E_DCMS = sum(S_E_DCMS)) %>%
  dplyr::rename(SIC = INDC07S)

# Second job, self-employed - all jobs - weighted.
DCMS_Second_Self_4digit_newage <- cleaned_subset %>%
  dplyr::filter(SECJMBR == 2 & DCMS_second == 1) %>%
  # try weighting before
  dplyr::mutate(S_SE_DCMS = DCMS_second * PWTA16) %>%
  dplyr::group_by(INDC07S, NewAge) %>%
  dplyr::summarise(S_SE_DCMS = sum(S_SE_DCMS)) %>%
  dplyr::rename(SIC = INDC07S)

main <-
  dplyr::full_join(
    DCMS_Main_Employee_4digit_newage,
    DCMS_Main_Self_4digit_newage
  )

second <-
  dplyr::full_join(
    DCMS_Second_Employee_4digit_newage,
    DCMS_Second_Self_4digit_newage
  )

final <- dplyr::full_join(
  main,
  second
  #by = c("SIC", "NewAge")
)

final[is.na(final)] <- 0
final2 <- final %>%
  dplyr::mutate(employed = M_E_DCMS	+ S_E_DCMS) %>%
  dplyr::mutate(selfemployed = M_SE_DCMS	+ S_SE_DCMS)



# the problem with adding together the main and second job, is you then loose which part of the count comes from which sic.

test <- raw_subset_2016 %>%
  dplyr::mutate(SECJMBR = ifelse(SECJMBR == 3, 1, SECJMBR)) %>%
  dplyr::mutate(NewAge = ifelse(AGE < 30, 29, 30))
#  dplyr::mutate(DCMS_main = ifelse(INDC07M %in% sics, 1, 0)) %>%
#  dplyr::mutate(DCMS_second = ifelse(INDC07S %in% sics, 1, 0)) %>%


dfcheck <- raw_subset_2016
dfcheck$SECJMBR <- ifelse(dfcheck$SECJMBR == 3, 1, dfcheck$SECJMBR)
dfcheck$NewAge <- ifelse(dfcheck$AGE < 30, 29, 30)
dfcheck$mainemployedcount <-
  ifelse(dfcheck$INDC07M %in% sics & dfcheck$INECAC05 == 1, dfcheck$PWTA16, 0)
agg <- aggregate(PWTA16 ~ ., data = dfcheck[, c("PWTA16", "INDC07M", "NewAge")], sum)



  if (exists(df)) dfkeep <- df
  df <- raw_subset_2016 %>%
    dplyr::mutate(SECJMBR = ifelse(SECJMBR == 3, 1, SECJMBR)) %>%
    dplyr::mutate(NewAge = ifelse(AGE < 30, 29, 30)) %>%
    dplyr::mutate(
      mainemployedcount =
        ifelse(INDC07M %in% sics & INECAC05 == 1, PWTA16, 0)) %>%
    dplyr::group_by(INDC07M, NewAge) %>%
    dplyr::summarise(M_E_DCMS = sum(PWTA16)) %>%
    dplyr::rename(SIC = INDC07M)
  if (exists(dfkeep)) {
    df <- dplyr::full_join(df, dfkeep)
  }



  # for employee we need INECAC05 == 1 or SECJMBR == 1

## Main job, employee - all jobs - weighted.
test <- cleaned_subset %>%
  dplyr::filter(INECAC05 == 1 & DCMS_main == 1) %>%
  # try weighting before
  dplyr::mutate(M_E_DCMS = DCMS_main * PWTA16) %>%
  dplyr::group_by(INDC07M, NewAge) %>%
  dplyr::summarise(M_E_DCMS = sum(M_E_DCMS)) %>%
  dplyr::rename(SIC = INDC07M)


