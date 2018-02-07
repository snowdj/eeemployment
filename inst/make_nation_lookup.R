lookup <- data.frame(natox = 1:992)

lookup$nation <- 9999

my_update <- function(natox_codes, nation_code) {
  ifelse(lookup$natox %in% natox_codes, nation_code, lookup$nation)
}

lookup$nation <- my_update(c(926), 1)
lookup$nation <- my_update(c(40, 56, 208, 246, 250, 276, 300, 380, 442, 528, 620, 911, 913, 752, 372, 912, 492), 2)
lookup$nation <- my_update(c(203, 233, 348, 428, 440, 616, 703, 705, 971), 3)
lookup$nation <- my_update(c(840), 4)
lookup$nation <- my_update(c(982, 12, 24, 204, 72, 854, 108, 120, 132, 140, 148, 174, 178, 180, 262, 818, 226,232, 231, 266, 270, 288, 324, 624, 384, 404, 426, 430, 434, 450, 454, 466, 478, 480, 175, 504, 508, 516, 562, 566, 638, 646, 678, 686, 690, 694, 706, 654, 736, 748, 48,834, 768, 788, 800, 732, 894, 716, 83, 4, 768, 788, 800, 732, 894, 716), 5)
lookup$nation <- my_update(c(710), 6)
lookup$nation <- my_update(c(36, 554), 7)
lookup$nation <- my_update(c(356), 8)
lookup$nation <- my_update(c(586, 50), 9)
lookup$nation <- my_update(c(100, 642), 10)
lookup$nation <- my_update(c(901, 470), 11)
lookup$nation <- my_update(c(191), 12)
lookup$nation <- my_update(c(807), 13)
lookup$nation <- my_update(c(792), 14)
lookup$nation <- my_update(c(8), 15)
lookup$nation <- my_update(c(70), 16)
lookup$nation <- my_update(c(499), 17)
lookup$nation <- my_update(c(688), 18)
lookup$nation <- my_update(c(248, 20, 51, 31, 112, 902, 903, 981, 234, 268, 292, 352, 438, 498, 578, 643, 674, 974, 744, 756, 804, 972, 336, 973, 891), 19)
lookup$nation <- my_update(c(660, 28, 32, 533, 44, 52, 84, 60, 68, 76, 92, 124, 988, 136, 986, 152, 170, 188, 192, 212, 214, 218, 222, 238, 254, 304, 308, 312, 320, 328, 332, 340, 388, 474, 484, 500, 530, 558, 985, 591, 600, 604, 630, 987, 659, 662, 666, 670, 740, 780, 796, 850, 858, 862), 20)
lookup$nation <- my_update(c(4, 984, 48, 64, 96, 104, 116, 156, 158, 626, 344, 360, 364, 368, 376, 392, 400, 398, 408, 410, 414, 417, 418, 422, 446, 458, 462, 983, 496, 524, 512, 608, 634, 682, 702, 144, 760, 762, 764, 795, 784, 860, 704, 275, 887), 21)
lookup$nation <- my_update(c(16, 10, 989, 74, 86, 162, 166, 184, 242, 258, 260, 316, 334, 296, 584, 583, 520, 540, 570, 574, 580, 585, 598, 612, 882, 90, 239, 772, 776, 798, 581, 548, 876, 991, 992), 22)
lookup$nation <- my_update(c(-8, -9), 23)

lookup <- lookup[lookup$nation != 9999,]

my_update2 <- function(nation_codes, nation_code2) {
  ifelse(lookup$nation %in% nation_codes, nation_code2, lookup$nation2)
}
lookup$nation2 <- NA
lookup$nation2 <- my_update2(c(1), 1)
lookup$nation2 <- my_update2(c(2,3,10,11,12), 2)
lookup$nation2 <- my_update2(c(4,5,6,7,8,9,13,14,15,16,17,18,19,20,21,22), 3)
lookup$nation2 <- my_update2(c(23), 4)

write.csv(lookup, "nation_lookup_raw.csv")

# if natox7 = 926 Nationality=1.
# if any (natox7, 40, 56, 208, 246, 250, 276, 300, 380, 442, 528, 620, 911, 913, 752, 372, 912, 492) Nationality=2.
# if any (natox7,  203, 233, 348, 428, 440, 616, 703, 705, 971) Nationality=3.
# if natox7 = 840 Nationality=4.
# if any (natox7, 982, 12, 24, 204, 72, 854, 108, 120, 132, 140, 148, 174, 178, 180, 262, 818, 226,232, 231, 266, 270, 288, 324, 624, 384, 404,
#         426, 430, 434, 450, 454, 466, 478, 480, 175, 504, 508, 516, 562, 566, 638, 646, 678, 686, 690, 694, 706, 654, 736, 748, 48,834, 768,
#         788, 800, 732, 894, 716, 83, 4, 768, 788, 800, 732, 894, 716)  Nationality=5.
        # if natox7 = 710  Nationality=6.
        # if any (natox7, 36, 554)  Nationality=7.
        # if natox7 = 356  Nationality=8.
        # if any (natox7, 586, 50)  Nationality=9.
        # if any (natox7, 100, 642)  Nationality=10.
        # if any (natox7, 901, 470)  Nationality=11.
        # if natox7 = 191 Nationality=12.
        # if natox7 = 807 Nationality=13.
        # if natox7 = 792 Nationality=14.
        # if natox7 = 8  Nationality=15.
        # if natox7 = 70 Nationality=16.
        # if natox7 = 499 Nationality=17.
        # if natox7 = 688 Nationality=18.
        # if any (natox7, 248, 20, 51, 31, 112, 902, 903, 981, 234, 268, 292, 352, 438, 498, 578, 643, 674, 974, 744, 756, 804, 972, 336, 973, 891)  Nationality=19.
        # if any (natox7, 660, 28, 32, 533, 44, 52, 84, 60, 68, 76, 92, 124, 988, 136, 986, 152, 170, 188, 192, 212, 214, 218, 222, 238, 254, 304, 308, 312,
        #         320, 328, 332, 340, 388, 474, 484, 500, 530, 558, 985, 591, 600, 604, 630, 987, 659, 662, 666, 670, 740, 780, 796, 850, 858, 862)  Nationality=20.
                # if any (natox7, 4, 984, 48, 64, 96, 104, 116, 156, 158, 626, 344, 360, 364, 368, 376, 392, 400, 398, 408, 410, 414, 417, 418, 422, 446, 458, 462,
                #         983, 496, 524, 512, 608, 634, 682, 702, 144, 760, 762, 764, 795, 784, 860, 704, 275, 887)  Nationality=21.
                        # if any (natox7, 16, 10, 989, 74, 86, 162, 166, 184, 242, 258, 260, 316, 334, 296, 584, 583, 520, 540, 570, 574, 580, 585, 598, 612, 882, 90,
                        #         239, 772, 776, 798, 581, 548, 876, 991, 992)  Nationality=22.
                        #         if any (natox7, -8,-9)  Nationality=23.
