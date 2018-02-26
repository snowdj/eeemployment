# devtools::install_version("haven", version = "1.1.0", repos = "http://cran.us.r-project.org")
# raw_2016 <- haven::read_sav("G:/Economic Estimates/APS/2016/APSP_JD16_CLIENT_PWTA16.sav")

# devtools::use_data(raw_2016)

# load_all() will load the raw data every time you run it without reset = FALSE
devtools::load_all(reset = FALSE)

# raw_2016 <- eeemployment::raw_2016

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
    AGE,
    ETHUK11,
    HIQUL15D,
    FTPT,
    NSECMJ10)

# part 1 - update categories

# part 2 - created weighted count just say use weight col if sic in siclist

# part 3 - need to calculate main and second job individually, split by e/se
# can we just add both together first? so employed, keep weight if INECAC05 = 1 and SECJMBR = 1.

# part 4 - group by sic and category


#### REASONS TO USE PYTHON OVER R
# In R, because of the inefficient memory use, you have to aggregate the data before mapping on sector etc
# 3 way contingency tables are confusing in R, easy in python: http://wesmckinney.com/blog/contingency-tables-and-cross-tabulations-in-pandas/
# R does copy on change, whereas pandas works by reference so is much faster and uses memory more efficiently. for example, rerunning the code multiple times as is common when change formatting at the end of the process will be much better in python, and in R I have come across memory problems when dealing with the sic level dataset which has forced me to change the strucutre of the code to something less intuitive.
# fundamentally, R is designed for statistical analysis, not automation, whereas python is a general purpose language which is widely used for automation, e.g. luigi, HR etc.


# the problem with adding together the main and second job, is you then loose which part of the count comes from which sic.

# remember that we need a separate "all dcms" sector, because there is overlap so can't just add them up

# REMEMBER - mapping sics have decimal, list of sics dont
rm(list = ls()[!(ls() %in% c("raw_subset_2016", "sics"))])
# make columns
df <- as.data.frame(raw_subset_2016)
df$SECJMBR <- ifelse(df$SECJMBR == 3, 1, df$SECJMBR)

# format columns
# age - ages is a code (1-15) for the age bands. We want to define our own categories so use age column
# cut will do (16, 25] for 0, 16, 25, so need to do 0, 15, 24
df$dcms_ageband <-
  as.character(
    cut(as.numeric(df$AGE),
        breaks=c(-1, 15, 24, 39, 59, Inf),
        labels=c("0-15 years", "16-24 years", "25-39 years", "40-59 years", "60 years +")
    )
  )

# df$dcms_ageband <-
#   as.character(
#     cut(as.numeric(df$AGE),
#         breaks=c(-1, 15, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, 69, Inf),
#         labels=c("0-15 years", "16-19 years", "20-24 years", "25-29 years", "30-34 years", "35-39 years", "40-44 years", "45-49 years", "50-54 years", "55-59 years", "60-64 years", "65-69 years", "70 and over")
#     )
#   )

df$NewAge <- ifelse(df$AGE < 30, 29, 30)

df$sex <- as.integer(haven::zap_labels(df$SEX))
df$sex <- ifelse(df$sex == 1, "Male", "Female")

df$ethnicity <- as.integer(haven::zap_labels(df$ETHUK1))
# unique(df$ethnicity)
# df$ETHUK11 # displays label mappings - travellers are mapped to 5 which is then relabelled as other.
# even though code 0 is labelled as missing (and there are 225 NA rows), no missing is output to excel
# sum(is.na(df$ETHUK11))
# Recode ETHUK11
# (1=1)
# (3=2)
# (4=3) (5=3) (6=3) (7=3) (8=3)
# (9=4)
# (10=5) (11=5) (2=5) into ETHUK11.
# I couldn't work it out from the SPSS code, but judging by the numbers produced, missing ethnicities are included in BAME
df$ethnicity <- ifelse(df$ethnicity != 1 | is.na(df$ethnicity), "BAME", "White")

#we drop missing and don't know
df$qualification <- haven::as_factor(df$HIQUL15D)
levels(df$qualification)[levels(df$qualification)=="Degree or equivalent"] <- "Degree or equivalent"
levels(df$qualification)[levels(df$qualification)=="Higher education"] <- "Higher Education"
levels(df$qualification)[levels(df$qualification)=="GCE A level or equivalent"] <- "A Level or equivalent"
levels(df$qualification)[levels(df$qualification)=="GCSE grades A*-C or equivalent"] <- "GCSE A* - C or equivalent"
levels(df$qualification)[levels(df$qualification)=="Other qualification"] <- "Other"
levels(df$qualification)[levels(df$qualification)=="No qualification"] <- "No Qualification"
levels(df$qualification)[levels(df$qualification)=="Don?t know"] <- "dont know"
df$qualification <- as.character(df$qualification)

# it looks like everything except full time and part time is dropped since the vlookup in 2016 main workbook only looks for  those two values
df$ftpt <- as.character(haven::as_factor(df$FTPT))

df$nssec <- as.integer(df$NSECMJ10)
df$nssec <- ifelse(df$nssec %in% 1:4, "More Advantaged Group (NS-SEC 1-4)", df$nssec)
df$nssec <- ifelse(df$nssec %in% 5:8, "Less Advantaged Group (NS-SEC 5-8)", df$nssec)

#catvar <- "sex"; catorder <- c("Male", "Female"); sheet <- 14; xy <- c(2,9); perc <- TRUE; cattotal <- TRUE
#catvar <- "ethnicity"; catorder <- c("White", "BAME"); sheet <- 15; xy <- c(2,8); perc <- TRUE; cattotal <- TRUE
#catvar <- "dcms_ageband"; catorder <- NA; sheet <- 16; xy <- c(2,8); perc <- FALSE; cattotal <- TRUE
#catvar <- "qualification"; catorder <- NA; sheet <- 17; xy <- c(2,7); perc <- FALSE; catorder <- c("Degree or equivalent",	"Higher Education",	"A Level or equivalent", "GCSE A* - C or equivalent",	"Other",	"No Qualification"); cattotal <- TRUE
#catvar <- "ftpt"; catorder <- c("Full time", "Part time"); sheet <- 18; xy <- c(2,8); perc <- TRUE; cattotal <- TRUE
catvar <- "nssec"; catorder <- c("More Advantaged Group (NS-SEC 1-4)", "Less Advantaged Group (NS-SEC 5-8)"); sheet <- 19; xy <- c(2,8); perc <- FALSE; cattotal <- FALSE


if (catvar == "qualification") df <- df[df[, catvar] != "dont know" & !is.na(df[, catvar]), ]
if (catvar == "ftpt") df <- df[df[, catvar] %in% catorder, ]
if (catvar == "nssec") df <- df[df[, catvar] %in% catorder, ]

df$cat <- df[, catvar]

sic_mappings <- read.csv("inst/extdata/sic_mappings.csv", stringsAsFactors = FALSE)
sic_mappings <- sic_mappings[sic_mappings$sic != 62.011, ]
sic_mappings$sic <- as.integer(round(sic_mappings$sic * 100, 0))

#breakdown <- "sic"
breakdown <- "sector"

if (breakdown == "sic") {
  agg <-
    expand.grid(
      sic = sics, cat = unique(df[, catvar]), stringsAsFactors = FALSE)
}
if (breakdown == "sector") {
  agg <-
    expand.grid(
      sector = c(unique(sic_mappings$sector),"civil society", "total_uk"),
      cat = unique(df[, catvar]),
      stringsAsFactors = FALSE) # for sector breakdowns
}


for (i in 1:4) {
  if (i == 1) {
    sicvar <- "INDC07M"; emptype <- "INECAC05"; emptypeflag <- 1; countname <- "mainemp"
  }
  if (i == 2) {
    sicvar <- "INDC07S"; emptype <- "SECJMBR"; emptypeflag <- 1; countname <- "secondemp"
  }
  if (i == 3) {
    sicvar <- "INDC07M"; emptype <- "INECAC05"; emptypeflag <- 2; countname <- "mainselfemp"
  }
  if (i == 4) {
    sicvar <- "INDC07S"; emptype <- "SECJMBR"; emptypeflag <- 2; countname <- "secondselfemp"
  }

  # take copy as we want to keep and reuse the originals
  df$sic <- as.numeric(df[, sicvar])

  # instead of just setting ones we don't want to 0, delete them since we are merging anyway!!! :) we need to do this so that we can merge the sector labels without getting an error - might need to try some base R method instead of merge.


  #dftemp <- df[df$sic %in% sics & df[, emptype] == emptypeflag, ]
  dftemp <- df[df[, emptype] == emptypeflag, ]

  dftemp$count <- dftemp$PWTA16
  #df$count <- ifelse(df$sic %in% sics & df[, emptype] == emptypeflag, df$PWTA16, 0)

  # now try merging with much smaller dataset
  # doing a merge is necessary since we need to create additional rows where there is overlap between sector categories.
  # rows for each sector and all_dcms - use inner join

  if (breakdown == "sector") {
    dftemp_sectors <- merge(x = dftemp, y = sic_mappings[, c("sic", "sector")])

    # rows for total UK (all sics)
    # Note that the code we/spss uses to handle main and second jobs means that some with two jobs gets two counts (times their weighting). However for total UK, spps simply does a weighted count of the e/se columns, INECAC05 and SECJMBR.
    dftemp_totaluk <- dftemp
    dftemp_totaluk$sector <- "total_uk"
    dftemp_totaluk <- dftemp_totaluk[, names(dftemp_sectors)] # reorder for rbind
    dftemp <- rbind(dftemp_totaluk, dftemp_sectors)

    dftemp$sic <- NULL # remove sic if we are just doing sectors
  }

  aggtemp <- aggregate(count ~ ., data = dftemp[, c("count", breakdown, "cat")], sum)
  names(aggtemp)[names(aggtemp) == "count"] <- countname # rename count var
  agg <- merge(x = agg, y = aggtemp, all.x = TRUE)
}

# combine main and second columns
agg[is.na(agg)] <- 0
agg$emp <- agg$mainemp + agg$secondemp
agg$mainemp <- NULL
agg$secondemp <- NULL
agg$selfemp <- agg$mainselfemp + agg$secondselfemp
agg$mainselfemp <- NULL
agg$secondselfemp <- NULL

# #investigating
# agg20to24 <- agg
# agg20to24 <- agg20to24[agg20to24$cat == "20-24 years", ]
# class(agg20to24$sic)
# class(sic_mappings$sic)
# agg20to24[agg20to24$sic == 3230, ]
#
# mysubset <- sic_mappings[c(101, 93), ]
# save(mysubset, file = "mysubset.Rdata")
# load("mysubset.Rdata")
# mysubset$sic # prints both values as expected
# mysubset[mysubset$sic == 3230, ] # prints 0 rows
# mysubset[mysubset$sic == 3012, ] # prints row as expected
#
#
# sic_mappings[sic_mappings$sic == 3012, ]
# class(sic_mappings[93, ]$sic)
# typeof(sic_mappings[93, ]$sic)
# sic_mappings_check <- sic_mappings[order(sic_mappings$sic), ]
# sic_mappings_check[sic_mappings_check$sic == 3230, ]
#
# agg20to24 <- merge(x = agg20to24, y = sic_mappings[, c("sic", "sector")])
# # it is this merge!!!!!!!!!! it is ignoring, for example 3230, even though it apears in both sic lists.
# agg20to24 <- agg20to24[agg20to24$sector == "sport", ]
# openxlsx::write.xlsx(agg20to24, "agg20to24.xlsx")


# stack emptype
aggemp <- agg[, c(breakdown, "cat", "emp")]
names(aggemp)[names(aggemp) == "emp"] <- "count"
aggemp$emptype <- "employed"

aggself <- agg[, c(breakdown, "cat", "selfemp")]
names(aggself)[names(aggself) == "selfemp"] <- "count"
aggself$emptype <- "self employed"

aggtotal <- aggemp
aggtotal$count <- aggemp$count + aggself$count
aggtotal$emptype <- "total"


aggfinal <- rbind(aggemp, aggself, aggtotal)

# get CS
# add CS but keep it blank for now

# drop stuff
if (breakdown == "sector") aggfinal <- aggfinal[aggfinal$sector != "tourism", ]

if (catvar == "dcms_ageband") aggfinal <- aggfinal[aggfinal$cat != "0-15 years", ]
if (catvar == "ethnicity") aggfinal <- aggfinal[aggfinal$emptype == "total" & aggfinal$cat != 0, ]
if (catvar == "qualification") aggfinal <- aggfinal[aggfinal$emptype == "total", ]
if (catvar == "ftpt") aggfinal <- aggfinal[aggfinal$emptype == "total", ]

# format vaues
aggfinal$count <- round(aggfinal$count / 1000, 0)

# final is a matrix, not a dataframe - no problem, can convert to character matrix if necessary?
if (exists("final")) rm(final)
for (emptype in unique(aggfinal$emptype)) {
  aggfinaltemp <- aggfinal[aggfinal$emptype == emptype, ]
  emptable <- xtabs(count ~ sector + cat, data = aggfinaltemp, na.action = na.pass, exclude = NULL)
  emptable <- as.data.frame.matrix(emptable)

  #this is where we order the categories for output
  if (!is.na(catorder)) {
    if (!all.equal(sort(catorder), sort(colnames(emptable)))) stop("bad catorder input")
    emptable <- emptable[, catorder]
  }


  total <- rowSums(emptable)
  if (perc) {
    cols <- colnames(emptable)
    empnames <- c()
    for (mycol in cols) {
      emptable[, paste0(mycol, "_perc")] <- emptable[, mycol] / total * 100
      empnames <- c(empnames, mycol, paste0(mycol, "_perc"))
    }
    emptable <- emptable[, empnames]
  }
  if (cattotal == TRUE) emptable <- cbind(emptable, Total = total)
  # bind each emp table together
  if (exists("final")) {
    final <- cbind(final, emptable)
  } else {
    final <- emptable
  }
}

# reorder rows
final_real <- final[c("civil society", "creative", "culture", "digital", "gambling", "sport", "telecoms", "all_dcms", "total_uk"), ]

excel_filename <-
  system.file(
    "DCMS_Sectors_Economic_Estimates_Employment_2016_tables_Template.xlsx", package = "eeemployment")

wb <- openxlsx::loadWorkbook(file = excel_filename)

# update sheet "3.7 - Age (000's)"
openxlsx::writeData(wb, sheet = sheet, x = final_real, colNames = FALSE, xy = xy)

openxlsx::saveWorkbook(
  wb, file.path("~", "DCMS_Sectors_Economic_Estimates_Employment_2016_tables.xlsx"), overwrite = TRUE)


# only all_dcms has descrepancy now

# explain to penny and olivia that it is too much for my brain to plan how to account for all the different formats straight off the bat, so I will do a few diffferent ones, and then it will be easier to see how to combine them into the same process, with options for different formats.





#testing
# aggtemp <- aggregate(count ~ ., data = dftemp[, c("count", "sic", "cat")], sum)
# aggtemp <- aggtemp[order(aggtemp$cat, aggtemp$sic), ]
# DCMS_Main_Employee_4digit_newage <-
#   DCMS_Main_Employee_4digit_newage[
#     order(DCMS_Main_Employee_4digit_newage$NewAge, DCMS_Main_Employee_4digit_newage$SIC), ]
# sum(DCMS_Main_Employee_4digit_newage$M_E_DCMS != aggtemp$count)
# so at the sic level my code matches spss (which matches DCMS_Main_Employee_4digit_newage) so the discrepancy lies in adding sectors etc.

#make sector level DCMS_Main_Employee_4digit_newage
# DCMS_Main <- DCMS_Main_Employee_4digit_newage
# names(DCMS_Main)[1] <- "sic"
# DCMS_Main <- merge(x = DCMS_Main, y = sic_mappings[, c("sic", "sector")])
# DCMS_Mainagg <- aggregate(M_E_DCMS ~ ., data = DCMS_Main[, c("M_E_DCMS", "sector", "NewAge")], sum)
# DCMS_Mainagg <- DCMS_Mainagg[order(DCMS_Mainagg$NewAge, DCMS_Mainagg$sector), ]
# aggtemp <- aggtemp[aggtemp$sector != "total_uk", ]
# aggtemp <- aggtemp[order(aggtemp$cat, aggtemp$sector), ]
# sum(DCMS_Mainagg$M_E_DCMS != aggtemp$count)
# so now we are matching at sector level too...

