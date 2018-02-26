[![Travis-CI Build Status](https://travis-ci.org/DCMSstats/eeemployment.svg?branch=master)](https://travis-ci.org/DCMSstats/eeemployment)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/DCMSstats/eeemployment?branch=master&svg=true)](https://ci.appveyor.com/project/DCMSstats/eeemployment)
[![Coverage Status](https://img.shields.io/codecov/c/github/DCMSstats/eeemployment/master.svg)](https://codecov.io/github/DCMSstats/eeemployment?branch=master)

# UNDER DEVELOPMENT

## part 1
Labour For Survey data set:
I think there is a row for each recipient and the following columns:
INDC07M and INDC07S will contain a sic code to flag the recipient is employed in that industry.
INECAC05 and SECJMBR flag whether the job is employed (1) or self-employed (2), for main and second jobs respectively.
There are various categories like sex, age nationality, etc for the different breakdowns.
for all the industry/occupation sic codes, they only appear when row/participant is employed in that sic

INDC07M: industry sic codes (4 digit) to flag the recipient has main employment in that industry
INDC07S: industry sic codes (4 digit) to flag the recipient has second employment in that industry
SOC10M: occupation code main job
SOC10S: occupation code second job
INECAC05: main job - 1 for employee, 2 for self employed
SECJMBR: second job - 1 for employee, 2 for self employed
PWTA16: population weighting
INDSC07M:industry subclass sic codes (5 digit)
INDSC07S:industry subclass sic codes (5 digit)
SEX: code for gender categories
ETHUK11: code for ethnicity categories

DCMS_main: flag if INDC07M is one of our sics
DCMS_second: flag if INDC07S is one of our sics


  INDC07M   INDC07S   SOC10M    SOC10S    INECAC05  SECJMBR   PWTA16 INDSC07M  INDSC07S  SEX       ETHUK11  
1 6622      <NA>      1115      <NA>      1         5            260 66220     <NA>      1         1        
2 <NA>      <NA>      <NA>      <NA>      25        <NA>         382 <NA>      <NA>      2         1        
3 4778      <NA>      9233      <NA>      1         5            371 47789     <NA>      2         1        
4 <NA>      <NA>      <NA>      <NA>      34        <NA>         304 <NA>      <NA>      2         1        
5 8020      <NA>      7211      <NA>      1         5            476 80200     <NA>      2         1        
6 7112      <NA>      2126      <NA>      1         5            380 71129     <NA>      1         1     

DCMS_main and DCMS_second are then set to 1 if these sic flags exist AND IS IN OUR LIST, and then weighted up with PWTA16 for the general population.

with weighted counts:
  INDC07M   INDC07S   SOC10M SOC10S INECAC05 SECJMBR PWTA16 INDSC07M INDSC07S SEX   dcms_code ETHUK11 DCMS_main DCMS_second
1 6622      <NA>      1115   <NA>   1           5.00    260 66220    <NA>     1             1 Whilte          0           0
2 <NA>      <NA>      <NA>   <NA>   25         NA       382 <NA>     <NA>     2             1 Whilte          0           0
3 4778      <NA>      9233   <NA>   1           5.00    371 47789    <NA>     2             1 Whilte          0           0
4 <NA>      <NA>      <NA>   <NA>   34         NA       304 <NA>     <NA>     2             1 Whilte          0           0
5 8020      <NA>      7211   <NA>   1           5.00    476 80200    <NA>     2             1 Whilte          0           0
6 7112      <NA>      2126   <NA>   1           5.00    380 71129    <NA>     1             1 Whilte          0           0

## part 2
For each breakdown we then sum DCMS_main and DCMS_second (after weighting) by the cat and either INDC07M or INDC07S (short SICs)(and rename them to SIC), to get our 4 columns, which we then join together:
# A tibble: 6 x 9
# Groups:   SIC [2]
  SIC       ETHUK11                                     M_E_DCMS M_SE_DCMS S_E_DCMS S_SE_DCMS 
1 1820      Asian / Asian British                           545         0        0         0 
2 1820      Whilte                                          45425      4543      0         0 
3 2611      Asian / Asian British                           5435243   453245     0         0 
4 2611      Black / African / Caribbean / Black British      5454         0      0         0 
5 2611      Mixed / Multiple ethnic groups                   4545         0      0         0 
6 2611      Whilte                                         234545       6565     0       134 

M_E_DCMS: Main job, employee - all jobs - weighted. (INECAC05 == 1 & DCMS_main == 1)
M_SE_DCMS: Main job, self employed - all jobs - weighted. (INECAC05 == 2 & DCMS_main == 1) 
S_E_DCMS: Second job, employee - all jobs - weighted. (SECJMBR == 1 & DCMS_second == 1) 
S_SE_DCMS: Second job, self-employed - all jobs - weighted. (SECJMBR == 2 & DCMS_second == 1) 


## part 3 - excel transformations
for some stuff:
Then the above tables are joined on to the table format where there is a column of (4digit) sics, and then a flag for each sector, but the columns added are only counts for employed, self-employed, and total. does not differentiate between main and second job.

We then simply join all these tables together into a very wide table with first the column of sics, then columns for all age levels for employed, then self-employed, then total, then similarly for the ethnicity levels etc. so for each category n columns = levels * 3

for category breakdowns:
make a category and sic string lookup 19-251820 in spss excel output then lookup this to append to a different sector \* table for each category which each has a sector \* e/se. these summary tables are then used to compile a sector \* e/se + cat table, or whatever the final table format is.


## part 4 - final formats
the main excel file has the normal time series table for total jobs, index; then split by employed, self-employed and for each sub sector by uk region. then there is threeway category + employed/self-employed * sector, with slight variations like different orientations or not splitting e/se.
Then there is an excel file for each subsector, similar to above but the category breakdowns are time series, mostly the same format, with no e/se split.
then there is the individual classification which is just time series for each sic
finally,  there is 4 tables of breakdowns by occupation.

`G:\Economic Estimates\2017 publications\July publication\Final documents to publish`
simply has all the excel files which are online, I believe the values are copy paste valued from:
`G:\Economic Estimates\Employment - Helen\2016\2016 Main Workbook.xlsx` - so this is what we need to focus on
choose an aspect to start with first, and then just keep on working towards it until I have the output


see chapter the for all emplyment stuff in pdf report

## starting with DCMS_Sectors_Economic_Estimates_Employment_2016_tables
only the first two tables are time series

### Other sheets
most of these are by Ejobs, Ejobs%, SEjobs, SEjobs%, Total jobs, followed by some percentages

For the sector summaries, this is 

3.2 - Employed-selfemployed
Compiled data 20XX
sector * e/se with %

3.3 - Region (000's)
Regions - all DCMS sectors
region * e/se with %
also "% of DCMS sector jobs in all regions",	"% of all jobs in region"
	

The below sector sheets are all also
region * e/se with %
also "% of XXSectorXX jobs in all regions"
Gambling and telecoms don't have E and SE columns

3.3a - Civil Society
Civil Society - regional

3.3b - Creative Industries
CI - regional

3.3c - Cultural Sector
Cultural sector - regional

3.3d - Digital Sector
Digital Sector - regional

3.3e - Gambling
Gambling - regional

3.3f - Sport
Sport - regional

3.3g - Telecoms
Telecoms - regional


3.4 - Nationality (000's)
EU breakdown
nationality + e/se * sector

3.5 - Gender (000's)
Gender breakdown
sector * e/se + gender with %

3.6 - Ethnicity (000's)
Ethnicity breakdown
sector * ethnicity with %

3.7 - Age (000's)
possibly from "Age breakdown" but there is less categories, not sure where this calculation was done
sector * e/se + age

3.8 - Qualification (000's)
Qualification breakdown
sector * qualification

3.9 - Fulltime Parttime (000's)
Full time Part time breakdown
sector * ftpt with %

3.10 - NS-SEC (000's)
probably "NSSEC breakdown" but has been recategorised as first four columns and second four columns
sector * e/se + nssec

3.11 - SIC (000's)
"Individual SIC" even though some annoymisation had been done, there is more done in the final table below
sic + description * e/se

## anonymisation rule
anon any value < 6
for each row group with a total

