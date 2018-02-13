# devtools::install_version("haven", version = "1.1.0", repos = "http://cran.us.r-project.org")
raw_2016 <- haven::read_sav("G:/Economic Estimates/APS/2016/APSP_JD16_CLIENT_PWTA16.sav")

# devtools::use_data(raw_2016)

# load_all() will load the raw data every time you run it without reset = FALSE
devtools::load_all(reset = FALSE)

raw_2016 <- eeemployment::raw_2016


library(magrittr)

# both the sic lists in spss are identical - and between programs i think they are identical
sics <- c(1820, 2611, 2612, 2620, 2630, 2640, 2680, 3012, 3212, 3220, 3230, 4651, 4652, 4763, 4764, 4910, 4932, 4939, 5010, 5030, 5110, 5510, 5520, 5530, 5590, 5610, 5621, 5629, 5630, 5811, 5812, 5813, 5814, 5819, 5821, 5829, 5911, 5912, 5913, 5914, 5920, 6010, 6020, 6110, 6120, 6130, 6190, 6201, 6202, 6203, 6209, 6311, 6312, 6391, 6399, 6820, 7021, 7111, 7311, 7312, 7410, 7420, 7430, 7711, 7721, 7722, 7729, 7734, 7735, 7740, 7911, 7912, 7990, 8230, 8551, 8552, 9001, 9002, 9003, 9004, 9101, 9102, 9103, 9104, 9200, 9311, 9312, 9313, 9319, 9321, 9329, 9511, 9512)

# I dont understand why there is a value of 0 in NEWNAT for eu and age - I'm  just gonna leave it for now - the row is set as missing in my data
 # can't work out why ethnicity figures don't match
