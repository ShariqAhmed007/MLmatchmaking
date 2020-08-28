Using Machine Learning For Matchmaking
================

### Objective:

-   Using clustering algorithms to cluster people based on their interests.
-   Finding people for a random user from his cluster group.
-   Ranking them based on how much their personality matches with the user's personality

### Datasets used:

-   Big5 personality dataset
-   Interests dataset
-   Baby-names dataset

### Approach:

1.  Combining Big5 personality dataset with personality dataset
2.  Adding names for ease in identification
3.  Using PCA for dimention reduction in both Big5 and Interests columns
4.  Using the PCA'd data to run heirarchical clustering
5.  Finding the appropriate no of cluster from heirarchical clustering
6.  Clustering the data using K-Means Clustering
7.  Attaching cluster assignments to the original PCA'd dataset
8.  Selecting a user
9.  Filtering out people within same cluster, country, age-group as user's
10. Creating a list of people with personality most similar to user's

``` r
library(cluster)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
setwd('E:/Datasets/BIG5/Data')
```

### Reading the Big5 dataset

``` r
big = read.csv('data.csv', sep= "")
head(big)
```

    ##   race age engnat gender hand source country E1 E2 E3 E4 E5 E6 E7 E8 E9 E10 N1
    ## 1    3  53      1      1    1      1      US  4  2  5  2  5  1  4  3  5   1  1
    ## 2   13  46      1      2    1      1      US  2  2  3  3  3  3  1  5  1   5  2
    ## 3    1  14      2      2    1      1      PK  5  1  1  4  5  1  1  5  5   1  5
    ## 4    3  19      2      2    1      1      RO  2  5  2  4  3  4  3  4  4   5  5
    ## 5   11  25      2      2    1      2      US  3  1  3  3  3  1  3  1  3   5  3
    ## 6   13  31      1      2    1      2      US  1  5  2  4  1  3  2  4  1   5  1
    ##   N2 N3 N4 N5 N6 N7 N8 N9 N10 A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 C1 C2 C3 C4 C5 C6
    ## 1  5  2  5  1  1  1  1  1   1  1  5  1  5  2  3  1  5  4   5  4  1  5  1  5  1
    ## 2  3  4  2  3  4  3  2  2   4  1  3  3  4  4  4  2  3  4   3  4  1  3  2  3  1
    ## 3  1  5  5  5  5  5  5  5   5  5  1  5  5  1  5  1  5  5   5  4  1  5  1  5  1
    ## 4  4  4  2  4  5  5  5  4   5  2  5  4  4  3  5  3  4  4   3  3  3  4  5  1  4
    ## 5  3  3  4  3  3  3  3  3   4  5  5  3  5  1  5  1  5  5   5  3  1  5  3  3  1
    ## 6  5  4  5  1  4  4  1  5   2  2  2  3  4  3  4  3  5  5   3  2  5  4  3  3  4
    ##   C7 C8 C9 C10 O1 O2 O3 O4 O5 O6 O7 O8 O9 O10
    ## 1  4  1  4   5  4  1  3  1  5  1  4  2  5   5
    ## 2  5  1  4   4  3  3  3  3  2  3  3  1  3   2
    ## 3  5  1  5   5  4  5  5  1  5  1  5  5  5   5
    ## 4  5  4  2   3  4  3  5  2  4  2  5  2  5   5
    ## 5  1  3  3   3  3  1  1  1  3  1  3  1  5   3
    ## 6  5  3  5   3  4  2  1  3  3  5  5  4  5   3

(Refer to Readme)

``` r
str(big)
```

    ## 'data.frame':    19719 obs. of  57 variables:
    ##  $ race   : int  3 13 1 3 11 13 5 4 5 3 ...
    ##  $ age    : int  53 46 14 19 25 31 20 23 39 18 ...
    ##  $ engnat : int  1 1 2 2 2 1 1 2 1 1 ...
    ##  $ gender : int  1 2 2 2 2 2 2 1 2 2 ...
    ##  $ hand   : int  1 1 1 1 1 1 1 1 3 1 ...
    ##  $ source : int  1 1 1 1 2 2 5 2 4 5 ...
    ##  $ country: chr  "US" "US" "PK" "RO" ...
    ##  $ E1     : int  4 2 5 2 3 1 5 4 3 1 ...
    ##  $ E2     : int  2 2 1 5 1 5 1 3 1 4 ...
    ##  $ E3     : int  5 3 1 2 3 2 5 5 5 2 ...
    ##  $ E4     : int  2 3 4 4 3 4 1 3 1 5 ...
    ##  $ E5     : int  5 3 5 3 3 1 5 5 5 2 ...
    ##  $ E6     : int  1 3 1 4 1 3 1 1 1 4 ...
    ##  $ E7     : int  4 1 1 3 3 2 5 4 5 1 ...
    ##  $ E8     : int  3 5 5 4 1 4 4 3 2 4 ...
    ##  $ E9     : int  5 1 5 4 3 1 4 4 5 1 ...
    ##  $ E10    : int  1 5 1 5 5 5 1 3 3 5 ...
    ##  $ N1     : int  1 2 5 5 3 1 2 1 2 5 ...
    ##  $ N2     : int  5 3 1 4 3 5 4 4 4 2 ...
    ##  $ N3     : int  2 4 5 4 3 4 2 4 5 5 ...
    ##  $ N4     : int  5 2 5 2 4 5 4 4 3 2 ...
    ##  $ N5     : int  1 3 5 4 3 1 2 1 3 3 ...
    ##  $ N6     : int  1 4 5 5 3 4 2 1 5 4 ...
    ##  $ N7     : int  1 3 5 5 3 4 3 1 5 3 ...
    ##  $ N8     : int  1 2 5 5 3 1 2 1 4 2 ...
    ##  $ N9     : int  1 2 5 4 3 5 2 1 3 3 ...
    ##  $ N10    : int  1 4 5 5 4 2 2 1 3 4 ...
    ##  $ A1     : int  1 1 5 2 5 2 5 2 1 2 ...
    ##  $ A2     : int  5 3 1 5 5 2 5 5 5 3 ...
    ##  $ A3     : int  1 3 5 4 3 3 1 1 1 1 ...
    ##  $ A4     : int  5 4 5 4 5 4 5 4 5 4 ...
    ##  $ A5     : int  2 4 1 3 1 3 1 3 1 2 ...
    ##  $ A6     : int  3 4 5 5 5 4 5 3 5 4 ...
    ##  $ A7     : int  1 2 1 3 1 3 1 1 1 3 ...
    ##  $ A8     : int  5 3 5 4 5 5 5 3 5 3 ...
    ##  $ A9     : int  4 4 5 4 5 5 4 4 5 3 ...
    ##  $ A10    : int  5 3 5 3 5 3 5 5 4 2 ...
    ##  $ C1     : int  4 4 4 3 3 2 2 4 4 5 ...
    ##  $ C2     : int  1 1 1 3 1 5 4 2 3 2 ...
    ##  $ C3     : int  5 3 5 4 5 4 3 5 5 4 ...
    ##  $ C4     : int  1 2 1 5 3 3 3 1 2 2 ...
    ##  $ C5     : int  5 3 5 1 3 3 3 4 5 3 ...
    ##  $ C6     : int  1 1 1 4 1 4 3 1 2 2 ...
    ##  $ C7     : int  4 5 5 5 1 5 3 4 5 4 ...
    ##  $ C8     : int  1 1 1 4 3 3 3 1 2 2 ...
    ##  $ C9     : int  4 4 5 2 3 5 3 3 4 4 ...
    ##  $ C10    : int  5 4 5 3 3 3 3 5 3 4 ...
    ##  $ O1     : int  4 3 4 4 3 4 3 3 3 4 ...
    ##  $ O2     : int  1 3 5 3 1 2 1 1 3 2 ...
    ##  $ O3     : int  3 3 5 5 1 1 5 5 5 5 ...
    ##  $ O4     : int  1 3 1 2 1 3 1 1 3 2 ...
    ##  $ O5     : int  5 2 5 4 3 3 4 4 5 4 ...
    ##  $ O6     : int  1 3 1 2 1 5 1 1 1 1 ...
    ##  $ O7     : int  4 3 5 5 3 5 4 5 5 4 ...
    ##  $ O8     : int  2 1 5 2 1 4 3 3 3 3 ...
    ##  $ O9     : int  5 3 5 5 5 5 3 2 4 4 ...
    ##  $ O10    : int  5 2 5 5 3 3 4 5 5 4 ...

Removing NAs and unwanted columns

``` r
big = big[,-c(5,6)]
head(big)
```

    ##   race age engnat gender country E1 E2 E3 E4 E5 E6 E7 E8 E9 E10 N1 N2 N3 N4 N5
    ## 1    3  53      1      1      US  4  2  5  2  5  1  4  3  5   1  1  5  2  5  1
    ## 2   13  46      1      2      US  2  2  3  3  3  3  1  5  1   5  2  3  4  2  3
    ## 3    1  14      2      2      PK  5  1  1  4  5  1  1  5  5   1  5  1  5  5  5
    ## 4    3  19      2      2      RO  2  5  2  4  3  4  3  4  4   5  5  4  4  2  4
    ## 5   11  25      2      2      US  3  1  3  3  3  1  3  1  3   5  3  3  3  4  3
    ## 6   13  31      1      2      US  1  5  2  4  1  3  2  4  1   5  1  5  4  5  1
    ##   N6 N7 N8 N9 N10 A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 C1 C2 C3 C4 C5 C6 C7 C8 C9 C10
    ## 1  1  1  1  1   1  1  5  1  5  2  3  1  5  4   5  4  1  5  1  5  1  4  1  4   5
    ## 2  4  3  2  2   4  1  3  3  4  4  4  2  3  4   3  4  1  3  2  3  1  5  1  4   4
    ## 3  5  5  5  5   5  5  1  5  5  1  5  1  5  5   5  4  1  5  1  5  1  5  1  5   5
    ## 4  5  5  5  4   5  2  5  4  4  3  5  3  4  4   3  3  3  4  5  1  4  5  4  2   3
    ## 5  3  3  3  3   4  5  5  3  5  1  5  1  5  5   5  3  1  5  3  3  1  1  3  3   3
    ## 6  4  4  1  5   2  2  2  3  4  3  4  3  5  5   3  2  5  4  3  3  4  5  3  5   3
    ##   O1 O2 O3 O4 O5 O6 O7 O8 O9 O10
    ## 1  4  1  3  1  5  1  4  2  5   5
    ## 2  3  3  3  3  2  3  3  1  3   2
    ## 3  4  5  5  1  5  1  5  5  5   5
    ## 4  4  3  5  2  4  2  5  2  5   5
    ## 5  3  1  1  1  3  1  3  1  5   3
    ## 6  4  2  1  3  3  5  5  4  5   3

``` r
big = na.omit(big)
```

``` r
names(big)
```

    ##  [1] "race"    "age"     "engnat"  "gender"  "country" "E1"      "E2"     
    ##  [8] "E3"      "E4"      "E5"      "E6"      "E7"      "E8"      "E9"     
    ## [15] "E10"     "N1"      "N2"      "N3"      "N4"      "N5"      "N6"     
    ## [22] "N7"      "N8"      "N9"      "N10"     "A1"      "A2"      "A3"     
    ## [29] "A4"      "A5"      "A6"      "A7"      "A8"      "A9"      "A10"    
    ## [36] "C1"      "C2"      "C3"      "C4"      "C5"      "C6"      "C7"     
    ## [43] "C8"      "C9"      "C10"     "O1"      "O2"      "O3"      "O4"     
    ## [50] "O5"      "O6"      "O7"      "O8"      "O9"      "O10"

``` r
dim(big)
```

    ## [1] 19710    55

Countries of respondents

``` r
sort(table(big$country), decreasing = TRUE)
```

    ## 
    ##   US   GB   IN   AU   CA   PH  (nu   IT   MY   PK   DE   ZA   BR   ID   SE   NZ 
    ## 8753 1531 1464  974  924  649  369  277  247  222  191  179  175  172  169  157 
    ##   NO   RO   NL   SG   FR   DK   IE   AE   FI   PT   BE   GR   RS   ES   MX   PL 
    ##  147  135  133  133  129  122  107  100   90   88   86   85   85   82   82   79 
    ##   TR   EG   SA   BD   KE   TH   AR   BG   HK   LB   CH   CN   HR   JP   NG   HU 
    ##   70   49   45   44   43   42   41   41   41   41   40   40   40   37   35   34 
    ##   SI   LK   KR   VN   LT   CZ   JM   IL   TW   EU   TT   SK   LV   AT   GH   AP 
    ##   34   31   30   30   29   28   28   27   26   24   23   22   21   20   20   19 
    ##   RU   CL   CO   BZ   IR   VE   PR   JO   EE   IS   AL   UA   MT   UG   BA   NP 
    ##   19   18   18   17   17   17   16   14   13   13   12   12   11   11   10   10 
    ##   QA   A2   CR   MA   A1   BH   BM   CY   MU   PE   MK   TN   EC   KW   OM   SV 
    ##   10    9    9    9    8    8    8    8    8    8    7    7    6    6    6    6 
    ##   BN   DO   AZ   BW   DZ   GE   HN   PA   BO   GT   JE   KH   ME   MM   MV   ZW 
    ##    5    5    4    4    4    4    4    4    3    3    3    3    3    3    3    3 
    ##   BB   BS   CM   FJ   GG   HT   IQ   LA   LS   LY   MN   MP   MW   MZ   NI   PG 
    ##    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2 
    ##   PY   RW   SY   TZ   UY   VC   VI   ZM   AG   AO   AS   BF   BT   CV   ET   FO 
    ##    2    2    2    2    2    2    2    2    1    1    1    1    1    1    1    1 
    ##   GD   GP   GU   GY   IM   KG   KY   KZ   MR   PW   SD   SR   TC   UZ 
    ##    1    1    1    1    1    1    1    1    1    1    1    1    1    1

Removing rows with vague age values

``` r
unique(big$age)
```

    ##   [1]        53        46        14        19        25        31        20
    ##   [8]        23        39        18        17        15        22        21
    ##  [15]        28        26        29        52        48        37        42
    ##  [22]        27        60        24        47        35        34        36
    ##  [29]        54        45        32        49        13        33        16
    ##  [36]        30        59        41        44        43        38      1997
    ##  [43]        40        55        58        51        57      1995        56
    ##  [50]        68        70        50        76        63        65      1994
    ##  [57]        62        61        67        69      1992        66      1988
    ##  [64]      1990      1999        74        73        64        71      1989
    ##  [71]        72      1984 999999999      1993       208      1996        75
    ##  [78]      1982      1991      1998      1961        92       100      1986
    ##  [85]      1976    412434      1977        77      2000      1968        97
    ##  [92]        80      1974       223      1985       211       266        99
    ##  [99]       188        79       191        78      1964       118

``` r
big = big[!(big$age>=120),]
unique(big$age)
```

    ##  [1]  53  46  14  19  25  31  20  23  39  18  17  15  22  21  28  26  29  52  48
    ## [20]  37  42  27  60  24  47  35  34  36  54  45  32  49  13  33  16  30  59  41
    ## [39]  44  43  38  40  55  58  51  57  56  68  70  50  76  63  65  62  61  67  69
    ## [58]  66  74  73  64  71  72  75  92 100  77  97  80  99  79  78 118

### Taking a sample of 5000 respondents (due to computational reasons)

``` r
set.seed(2)
train = big[sample.int(nrow(big), 5000),]
remove(big)
```

Adding 5000 unique names for easier identification

``` r
names=read.csv('baby-names.csv')
```

``` r
names = names$name
names = unique(names)
names = names[sample.int(length(names), 5000)]
```

``` r
train = data.frame(names,train)
train[1:6,1:6]
```

    ##            names race age engnat gender country
    ## 12171      Penni    3  21      1      1      US
    ## 13326 Margaretha    3  18      2      1      IT
    ## 4831     Isadore    3  34      1      2      US
    ## 11065    Kinsley    3  25      1      2      US
    ## 8502        Shad    1  24      1      2      US
    ## 3293        Sara   13  42      2      1      SA

### Reading the interests dataset

``` r
int = read.csv('interests.csv')
head(int)
```

    ##   Music Classical.music Musical Pop Rock Metal.or.Hardrock Hiphop..Rap
    ## 1     5               2       1   5    5                 1           1
    ## 2     4               1       2   3    5                 4           1
    ## 3     5               4       5   3    5                 3           1
    ## 4     5               1       1   2    2                 1           2
    ## 5     5               4       3   5    3                 1           5
    ## 6     5               3       3   2    5                 5           4
    ##   Rock.n.roll Alternative Techno..Trance Movies Horror Thriller Comedy Romantic
    ## 1           3           1              1      5      4        2      5        4
    ## 2           4           4              1      5      2        2      4        3
    ## 3           5           5              1      5      3        4      4        2
    ## 4           2           5              2      5      4        4      3        3
    ## 5           1           2              2      5      4        4      5        2
    ## 6           4           5              1      5      5        5      5        2
    ##   Sci.fi War Fantasy.Fairy.tales Animated Documentary Action History Psychology
    ## 1      4   1                   5        5           3      2       1          5
    ## 2      4   1                   3        5           4      4       1          3
    ## 3      4   2                   5        5           2      1       1          2
    ## 4      4   3                   1        2           5      2       4          4
    ## 5      3   3                   4        4           3      4       3          2
    ## 6      3   3                   4        3           3      4       5          3
    ##   Politics Mathematics Physics Internet PC Economy.Management Biology Chemistry
    ## 1        1           3       3        5  3                  5       3         3
    ## 2        4           5       2        4  4                  5       1         1
    ## 3        1           5       2        4  2                  4       1         1
    ## 4        5           4       1        3  1                  2       3         3
    ## 5        3           2       2        2  2                  2       3         3
    ## 6        4           2       3        4  4                  1       4         4
    ##   Reading Geography Foreign.languages Medicine Law Cars Art.exhibitions
    ## 1       3         3                 5        3   1    1               1
    ## 2       4         4                 5        1   2    2               2
    ## 3       5         2                 5        2   3    1               5
    ## 4       5         4                 4        2   5    1               5
    ## 5       5         2                 3        3   2    3               1
    ## 6       3         3                 4        4   3    5               2
    ##   Religion Dancing Musical.instruments Writing Passive.sport Active.sport
    ## 1        1       3                   3       2             1            5
    ## 2        1       1                   1       1             1            1
    ## 3        5       5                   5       5             5            2
    ## 4        4       1                   1       3             1            1
    ## 5        4       1                   3       1             3            1
    ## 6        2       1                   5       1             5            4
    ##   Science.and.technology Theatre Adrenaline.sports Pets Appearence.and.gestures
    ## 1                      4       2                 4    4                       4
    ## 2                      3       2                 2    5                       4
    ## 3                      2       5                 5    5                       3
    ## 4                      3       1                 1    1                       3
    ## 5                      3       2                 2    1                       3
    ## 6                      3       1                 3    2                       3
    ##   Happiness.in.life               Education
    ## 1                 4 college/bachelor degree
    ## 2                 4 college/bachelor degree
    ## 3                 4        secondary school
    ## 4                 2 college/bachelor degree
    ## 5                 3        secondary school
    ## 6                 3        secondary school

``` r
int = na.omit(int)
```

``` r
knitr::opts_chunk$set(echo = FALSE, 
                      warning = FALSE, 
                      messages = FALSE, 
                      include = TRUE)
heatmap(cor(int[,-51]))
```

![](MLmatchmaking/plots/unnamed-chunk-13-1.png)

Creating a dataset of 5000 from 800 with replacement

    ##      Music       Classical.music    Musical           Pop       
    ##  Min.   :1.000   Min.   :1.000   Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:5.000   1st Qu.:2.000   1st Qu.:2.000   1st Qu.:3.000  
    ##  Median :5.000   Median :3.000   Median :3.000   Median :4.000  
    ##  Mean   :4.735   Mean   :2.964   Mean   :2.754   Mean   :3.466  
    ##  3rd Qu.:5.000   3rd Qu.:4.000   3rd Qu.:4.000   3rd Qu.:4.000  
    ##  Max.   :5.000   Max.   :5.000   Max.   :5.000   Max.   :5.000  
    ##       Rock       Metal.or.Hardrock  Hiphop..Rap     Rock.n.roll   
    ##  Min.   :1.000   Min.   :1.000     Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:3.000   1st Qu.:1.000     1st Qu.:2.000   1st Qu.:2.000  
    ##  Median :4.000   Median :2.000     Median :3.000   Median :3.000  
    ##  Mean   :3.779   Mean   :2.359     Mean   :2.896   Mean   :3.167  
    ##  3rd Qu.:5.000   3rd Qu.:3.000     3rd Qu.:4.000   3rd Qu.:4.000  
    ##  Max.   :5.000   Max.   :5.000     Max.   :5.000   Max.   :5.000  
    ##   Alternative   Techno..Trance      Movies          Horror         Thriller    
    ##  Min.   :1.00   Min.   :1.000   Min.   :1.000   Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:2.00   1st Qu.:1.000   1st Qu.:4.000   1st Qu.:1.000   1st Qu.:3.000  
    ##  Median :3.00   Median :2.000   Median :5.000   Median :3.000   Median :4.000  
    ##  Mean   :2.85   Mean   :2.302   Mean   :4.603   Mean   :2.772   Mean   :3.361  
    ##  3rd Qu.:4.00   3rd Qu.:3.000   3rd Qu.:5.000   3rd Qu.:4.000   3rd Qu.:4.000  
    ##  Max.   :5.00   Max.   :5.000   Max.   :5.000   Max.   :5.000   Max.   :5.000  
    ##      Comedy         Romantic         Sci.fi           War       
    ##  Min.   :1.000   Min.   :1.000   Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:4.000   1st Qu.:3.000   1st Qu.:2.000   1st Qu.:2.000  
    ##  Median :5.000   Median :4.000   Median :3.000   Median :3.000  
    ##  Mean   :4.503   Mean   :3.483   Mean   :3.125   Mean   :3.163  
    ##  3rd Qu.:5.000   3rd Qu.:5.000   3rd Qu.:4.000   3rd Qu.:4.000  
    ##  Max.   :5.000   Max.   :5.000   Max.   :5.000   Max.   :5.000  
    ##  Fantasy.Fairy.tales    Animated      Documentary        Action     
    ##  Min.   :1.000       Min.   :1.000   Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:3.000       1st Qu.:3.000   1st Qu.:3.000   1st Qu.:3.000  
    ##  Median :4.000       Median :4.000   Median :4.000   Median :4.000  
    ##  Mean   :3.752       Mean   :3.782   Mean   :3.627   Mean   :3.527  
    ##  3rd Qu.:5.000       3rd Qu.:5.000   3rd Qu.:5.000   3rd Qu.:5.000  
    ##  Max.   :5.000       Max.   :5.000   Max.   :5.000   Max.   :5.000  
    ##     History        Psychology       Politics      Mathematics   
    ##  Min.   :1.000   Min.   :1.000   Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:2.000   1st Qu.:2.000   1st Qu.:1.000   1st Qu.:1.000  
    ##  Median :3.000   Median :3.000   Median :2.000   Median :2.000  
    ##  Mean   :3.194   Mean   :3.117   Mean   :2.621   Mean   :2.375  
    ##  3rd Qu.:4.000   3rd Qu.:4.000   3rd Qu.:4.000   3rd Qu.:3.000  
    ##  Max.   :5.000   Max.   :5.000   Max.   :5.000   Max.   :5.000  
    ##     Physics         Internet          PC        Economy.Management
    ##  Min.   :1.000   Min.   :1.00   Min.   :1.000   Min.   :1.000     
    ##  1st Qu.:1.000   1st Qu.:4.00   1st Qu.:2.000   1st Qu.:1.000     
    ##  Median :2.000   Median :4.00   Median :3.000   Median :2.000     
    ##  Mean   :2.085   Mean   :4.18   Mean   :3.119   Mean   :2.662     
    ##  3rd Qu.:3.000   3rd Qu.:5.00   3rd Qu.:4.000   3rd Qu.:4.000     
    ##  Max.   :5.000   Max.   :5.00   Max.   :5.000   Max.   :5.000     
    ##     Biology        Chemistry        Reading        Geography    
    ##  Min.   :1.000   Min.   :1.000   Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:1.000   1st Qu.:1.000   1st Qu.:2.000   1st Qu.:2.000  
    ##  Median :2.000   Median :2.000   Median :3.000   Median :3.000  
    ##  Mean   :2.641   Mean   :2.139   Mean   :3.148   Mean   :3.094  
    ##  3rd Qu.:4.000   3rd Qu.:3.000   3rd Qu.:5.000   3rd Qu.:4.000  
    ##  Max.   :5.000   Max.   :5.000   Max.   :5.000   Max.   :5.000  
    ##  Foreign.languages    Medicine         Law             Cars      
    ##  Min.   :1.000     Min.   :1.00   Min.   :1.000   Min.   :1.000  
    ##  1st Qu.:3.000     1st Qu.:1.00   1st Qu.:1.000   1st Qu.:1.000  
    ##  Median :4.000     Median :2.00   Median :2.000   Median :2.000  
    ##  Mean   :3.805     Mean   :2.49   Mean   :2.256   Mean   :2.657  
    ##  3rd Qu.:5.000     3rd Qu.:3.00   3rd Qu.:3.000   3rd Qu.:4.000  
    ##  Max.   :5.000     Max.   :5.00   Max.   :5.000   Max.   :5.000  
    ##  Art.exhibitions    Religion        Dancing      Musical.instruments
    ##  Min.   :1.000   Min.   :1.000   Min.   :1.000   Min.   :1.000      
    ##  1st Qu.:1.000   1st Qu.:1.000   1st Qu.:1.000   1st Qu.:1.000      
    ##  Median :2.000   Median :2.000   Median :2.000   Median :2.000      
    ##  Mean   :2.602   Mean   :2.267   Mean   :2.433   Mean   :2.318      
    ##  3rd Qu.:4.000   3rd Qu.:3.000   3rd Qu.:3.000   3rd Qu.:4.000      
    ##  Max.   :5.000   Max.   :5.000   Max.   :5.000   Max.   :5.000      
    ##     Writing      Passive.sport    Active.sport   Science.and.technology
    ##  Min.   :1.000   Min.   :1.000   Min.   :1.000   Min.   :1.00          
    ##  1st Qu.:1.000   1st Qu.:2.000   1st Qu.:2.000   1st Qu.:2.00          
    ##  Median :1.000   Median :4.000   Median :3.000   Median :3.00          
    ##  Mean   :1.886   Mean   :3.412   Mean   :3.282   Mean   :3.26          
    ##  3rd Qu.:3.000   3rd Qu.:5.000   3rd Qu.:5.000   3rd Qu.:4.00          
    ##  Max.   :5.000   Max.   :5.000   Max.   :5.000   Max.   :5.00          
    ##     Theatre     Adrenaline.sports      Pets       Appearence.and.gestures
    ##  Min.   :1.00   Min.   :1.000     Min.   :1.000   Min.   :1.000          
    ##  1st Qu.:2.00   1st Qu.:2.000     1st Qu.:2.000   1st Qu.:3.000          
    ##  Median :3.00   Median :3.000     Median :4.000   Median :4.000          
    ##  Mean   :3.01   Mean   :2.923     Mean   :3.285   Mean   :3.594          
    ##  3rd Qu.:4.00   3rd Qu.:4.000     3rd Qu.:5.000   3rd Qu.:4.000          
    ##  Max.   :5.00   Max.   :5.000     Max.   :5.000   Max.   :5.000          
    ##  Happiness.in.life  Education        
    ##  Min.   :1.000     Length:839        
    ##  1st Qu.:3.000     Class :character  
    ##  Median :4.000     Mode  :character  
    ##  Mean   :3.709                       
    ##  3rd Qu.:4.000                       
    ##  Max.   :5.000

### Master dataset with names, Big5 data and Interest data

    ##   [1] "names"                   "race"                   
    ##   [3] "age"                     "engnat"                 
    ##   [5] "gender"                  "country"                
    ##   [7] "E1"                      "E2"                     
    ##   [9] "E3"                      "E4"                     
    ##  [11] "E5"                      "E6"                     
    ##  [13] "E7"                      "E8"                     
    ##  [15] "E9"                      "E10"                    
    ##  [17] "N1"                      "N2"                     
    ##  [19] "N3"                      "N4"                     
    ##  [21] "N5"                      "N6"                     
    ##  [23] "N7"                      "N8"                     
    ##  [25] "N9"                      "N10"                    
    ##  [27] "A1"                      "A2"                     
    ##  [29] "A3"                      "A4"                     
    ##  [31] "A5"                      "A6"                     
    ##  [33] "A7"                      "A8"                     
    ##  [35] "A9"                      "A10"                    
    ##  [37] "C1"                      "C2"                     
    ##  [39] "C3"                      "C4"                     
    ##  [41] "C5"                      "C6"                     
    ##  [43] "C7"                      "C8"                     
    ##  [45] "C9"                      "C10"                    
    ##  [47] "O1"                      "O2"                     
    ##  [49] "O3"                      "O4"                     
    ##  [51] "O5"                      "O6"                     
    ##  [53] "O7"                      "O8"                     
    ##  [55] "O9"                      "O10"                    
    ##  [57] "Music"                   "Classical.music"        
    ##  [59] "Musical"                 "Pop"                    
    ##  [61] "Rock"                    "Metal.or.Hardrock"      
    ##  [63] "Hiphop..Rap"             "Rock.n.roll"            
    ##  [65] "Alternative"             "Techno..Trance"         
    ##  [67] "Movies"                  "Horror"                 
    ##  [69] "Thriller"                "Comedy"                 
    ##  [71] "Romantic"                "Sci.fi"                 
    ##  [73] "War"                     "Fantasy.Fairy.tales"    
    ##  [75] "Animated"                "Documentary"            
    ##  [77] "Action"                  "History"                
    ##  [79] "Psychology"              "Politics"               
    ##  [81] "Mathematics"             "Physics"                
    ##  [83] "Internet"                "PC"                     
    ##  [85] "Economy.Management"      "Biology"                
    ##  [87] "Chemistry"               "Reading"                
    ##  [89] "Geography"               "Foreign.languages"      
    ##  [91] "Medicine"                "Law"                    
    ##  [93] "Cars"                    "Art.exhibitions"        
    ##  [95] "Religion"                "Dancing"                
    ##  [97] "Musical.instruments"     "Writing"                
    ##  [99] "Passive.sport"           "Active.sport"           
    ## [101] "Science.and.technology"  "Theatre"                
    ## [103] "Adrenaline.sports"       "Pets"                   
    ## [105] "Appearence.and.gestures" "Happiness.in.life"      
    ## [107] "Education"

    ## 
    ##                 secondary school          college/bachelor degree 
    ##                             3130                             1001 
    ##                   masters degree                   primary school 
    ##                              421                              387 
    ## currently a primary school pupil                 doctorate degree 
    ##                               37                               21 
    ##                                  
    ##                                3

![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-17-1.png) ![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-18-1.png)

PRINCIPAL COMPONENT ANALYSIS
============================

Principal Component Analysis on interest columns
------------------------------------------------

    ## [1] -0.06634427 -0.25277250 -0.22282635  0.03677082 -0.12167650 -0.05569898

    ##             PC1        PC2         PC3         PC4        PC5        PC6
    ## 849  2.40633523 1.18845622 -2.20520117  0.67070390 -0.4008390  0.9623631
    ## 925  0.74924685 2.59133550  0.29012247 -0.06594698 -0.7980948 -2.5904208
    ## 498 -1.71110350 1.84238406 -1.82041733  1.89584090 -0.8066074  1.0725876
    ## 466  0.08267284 0.08253572 -0.07333943  2.30800138 -0.5239428  1.3757298
    ## 325  0.49601123 2.03728398  0.82221728 -1.29199027 -0.4204712  0.3998408
    ## 416 -0.98882514 2.68628023  2.27038431 -2.48013758  0.7205849 -3.4452011
    ##              PC7        PC8        PC9       PC10       PC11       PC12
    ## 849  3.109552821 -0.6674774  3.0711772 -0.5850462 -0.7363013  1.8818547
    ## 925 -1.505994366  1.2534910 -1.1161595  0.5383166  1.7365408 -0.4675288
    ## 498  1.940319388  0.8377373 -0.2676961 -0.4364324 -2.8254240  1.0166555
    ## 466 -1.699375591 -0.7817496  0.3996406 -1.4110333  0.3824675 -1.8161302
    ## 325  0.006628133 -0.9736738  0.5380429  0.3662837 -0.1728037 -0.3725905
    ## 416  0.193662549 -2.7277398  2.5091072  0.4679246  0.4802233  1.4365345
    ##           PC13       PC14       PC15       PC16        PC17       PC18
    ## 849  0.4826010  0.6609888 -1.9975681  0.8528922  0.18012957  0.9483154
    ## 925  1.6130843 -1.1724638 -0.8574918 -1.1629262  0.40275968 -1.5147372
    ## 498 -1.2620974  1.5818881 -2.1051698  1.2337745  1.76217476 -0.5227804
    ## 466  0.8601170 -0.6864529  0.8235895  0.1501181  1.30775116 -1.6443888
    ## 325 -0.5157871 -0.4723268  0.1541035 -0.3300593  0.06962588  0.3900671
    ## 416 -0.8228892 -2.0800021 -1.0992713  0.1605568 -0.70611558 -1.1311807
    ##           PC19       PC20       PC21        PC22       PC23        PC24
    ## 849 -1.2676371 -0.3616065  1.1676896  1.27376395  0.0544559 -0.21925461
    ## 925 -0.5204020  0.7815334 -0.4324554  0.17016485  0.2050060  0.08155448
    ## 498  1.5301582 -0.6192447 -0.8500545 -0.19147989 -1.0873140  0.99838670
    ## 466  0.0441281  0.2654131  0.1169813 -0.07266223  0.9228714  0.25047310
    ## 325 -0.5906688  0.3422169  0.2580642 -0.04543875 -1.9387515  0.47572640
    ## 416 -1.5665277 -0.1885298 -1.2328182 -0.15022279  0.3878765  0.90870086
    ##            PC25        PC26        PC27        PC28       PC29        PC30
    ## 849  2.04372396  0.16851331  0.71567466 -0.91784809 -0.5954112  1.09093626
    ## 925  0.07889581  0.08804379  0.54310055  0.25686379 -0.3488732  0.02761916
    ## 498  0.48515130 -0.85344380  0.55537054 -0.88773647 -0.4510348  0.48507795
    ## 466 -0.45043636  0.21253488  0.58494838 -0.05180905  0.9369118  0.34782387
    ## 325  0.98293752 -0.15281424 -0.01630172  0.95195215 -2.2572486  0.04281828
    ## 416  0.27236859  0.03650196 -0.79860338 -0.09817686 -0.1828348 -0.18950406
    ##            PC31       PC32       PC33       PC34       PC35       PC36
    ## 849 -1.55931058  0.4594789  0.2902279 -1.2001133 -0.4746006  0.5164593
    ## 925  0.08615064 -2.0182998 -0.9257653  1.0723580  0.6345827 -2.4738523
    ## 498 -0.40457091 -1.0498547  0.8103899  0.3627377  2.0688254 -1.1660191
    ## 466  0.98647323  1.1090505  0.3642609 -0.5349486 -0.4203652 -0.7350462
    ## 325  0.16927296  0.5503356  0.2791710 -1.4636093 -0.2062266 -0.1613496
    ## 416  0.50959860  0.7850920  1.5028108  0.6860413  1.2902153  1.4440628
    ##            PC37       PC38       PC39        PC40       PC41       PC42
    ## 849 -0.27565200  0.9708775 -0.5095193  0.58698679 -0.8746929 -0.9255954
    ## 925  0.39649642 -0.3045670  0.1300115  0.40125378 -0.4809131 -0.6730388
    ## 498  0.02044798 -0.9197528  0.2229938  0.73644989 -0.1882511 -0.1568487
    ## 466  0.68978027 -0.2724562 -0.5911412 -0.08359082  0.8972696 -0.5811108
    ## 325 -0.36114969 -0.1195906 -0.1020778 -0.06708352  0.5291985  0.2667251
    ## 416  0.64527418 -1.0964685 -0.1599179 -0.12708545 -0.5940999 -0.8549758
    ##           PC43        PC44       PC45       PC46       PC47       PC48
    ## 849  0.2992324  0.36451188  0.2445148  0.3520395  0.6069322  0.5084480
    ## 925 -1.3746090 -0.96708333 -0.7177445  0.3897806  0.1284880  0.5640492
    ## 498  0.3322456  0.73678396 -0.3011576 -0.2849121  0.5052619 -0.2181399
    ## 466 -0.4121059 -0.14560662  0.2772995 -0.1517907 -0.8574704  0.1589322
    ## 325 -0.2291520  0.32761943  1.0040664 -0.9695498 -0.6647947  0.1853779
    ## 416  0.1713340 -0.07994503 -0.1686825 -1.2252849  0.6345866  0.1117559
    ##          PC49         PC50
    ## 849 0.6193716 -0.569225246
    ## 925 0.6475542  0.324285520
    ## 498 1.1323279 -0.007523632
    ## 466 0.8239734  0.418511583
    ## 325 0.2074907 -0.239079499
    ## 416 0.1297339  0.034554799

![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-20-1.png)![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-20-2.png)

    ## Importance of components:
    ##                           PC1     PC2     PC3     PC4     PC5     PC6     PC7
    ## Standard deviation     2.2820 2.11769 1.77222 1.61656 1.55213 1.31450 1.26972
    ## Proportion of Variance 0.1042 0.08969 0.06282 0.05227 0.04818 0.03456 0.03224
    ## Cumulative Proportion  0.1042 0.19384 0.25666 0.30892 0.35710 0.39166 0.42391
    ##                            PC8     PC9    PC10    PC11    PC12    PC13    PC14
    ## Standard deviation     1.21079 1.17764 1.15138 1.07067 1.06645 1.01904 1.00425
    ## Proportion of Variance 0.02932 0.02774 0.02651 0.02293 0.02275 0.02077 0.02017
    ## Cumulative Proportion  0.45323 0.48096 0.50748 0.53040 0.55315 0.57392 0.59409
    ##                           PC15    PC16   PC17    PC18   PC19    PC20    PC21
    ## Standard deviation     0.98683 0.97055 0.9643 0.94761 0.9221 0.91528 0.89675
    ## Proportion of Variance 0.01948 0.01884 0.0186 0.01796 0.0170 0.01675 0.01608
    ## Cumulative Proportion  0.61357 0.63240 0.6510 0.66896 0.6860 0.70272 0.71880
    ##                           PC22   PC23    PC24    PC25    PC26   PC27    PC28
    ## Standard deviation     0.87297 0.8544 0.84938 0.83874 0.82079 0.8125 0.78645
    ## Proportion of Variance 0.01524 0.0146 0.01443 0.01407 0.01347 0.0132 0.01237
    ## Cumulative Proportion  0.73405 0.7486 0.76307 0.77714 0.79062 0.8038 0.81619
    ##                          PC29    PC30    PC31    PC32    PC33   PC34    PC35
    ## Standard deviation     0.7747 0.76723 0.75284 0.74922 0.73449 0.7247 0.71344
    ## Proportion of Variance 0.0120 0.01177 0.01134 0.01123 0.01079 0.0105 0.01018
    ## Cumulative Proportion  0.8282 0.83997 0.85130 0.86253 0.87332 0.8838 0.89400
    ##                           PC36    PC37    PC38    PC39    PC40    PC41    PC42
    ## Standard deviation     0.68603 0.67684 0.66420 0.65213 0.64529 0.63273 0.63028
    ## Proportion of Variance 0.00941 0.00916 0.00882 0.00851 0.00833 0.00801 0.00794
    ## Cumulative Proportion  0.90341 0.91258 0.92140 0.92991 0.93823 0.94624 0.95419
    ##                           PC43    PC44    PC45    PC46    PC47    PC48    PC49
    ## Standard deviation     0.59362 0.57297 0.55946 0.54910 0.52573 0.50718 0.50051
    ## Proportion of Variance 0.00705 0.00657 0.00626 0.00603 0.00553 0.00514 0.00501
    ## Cumulative Proportion  0.96123 0.96780 0.97406 0.98009 0.98562 0.99076 0.99577
    ##                           PC50
    ## Standard deviation     0.45982
    ## Proportion of Variance 0.00423
    ## Cumulative Proportion  1.00000

![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-21-1.png)

Proportion of Variance explained by each additional PC

![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-22-1.png)

Setting a cutoff point at 60% cumulative percentage

![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-23-1.png)

    ##             PC1        PC2         PC3         PC4        PC5        PC6
    ## 849  2.40633523 1.18845622 -2.20520117  0.67070390 -0.4008390  0.9623631
    ## 925  0.74924685 2.59133550  0.29012247 -0.06594698 -0.7980948 -2.5904208
    ## 498 -1.71110350 1.84238406 -1.82041733  1.89584090 -0.8066074  1.0725876
    ## 466  0.08267284 0.08253572 -0.07333943  2.30800138 -0.5239428  1.3757298
    ## 325  0.49601123 2.03728398  0.82221728 -1.29199027 -0.4204712  0.3998408
    ## 416 -0.98882514 2.68628023  2.27038431 -2.48013758  0.7205849 -3.4452011
    ##              PC7        PC8        PC9       PC10       PC11       PC12
    ## 849  3.109552821 -0.6674774  3.0711772 -0.5850462 -0.7363013  1.8818547
    ## 925 -1.505994366  1.2534910 -1.1161595  0.5383166  1.7365408 -0.4675288
    ## 498  1.940319388  0.8377373 -0.2676961 -0.4364324 -2.8254240  1.0166555
    ## 466 -1.699375591 -0.7817496  0.3996406 -1.4110333  0.3824675 -1.8161302
    ## 325  0.006628133 -0.9736738  0.5380429  0.3662837 -0.1728037 -0.3725905
    ## 416  0.193662549 -2.7277398  2.5091072  0.4679246  0.4802233  1.4365345
    ##           PC13       PC14
    ## 849  0.4826010  0.6609888
    ## 925  1.6130843 -1.1724638
    ## 498 -1.2620974  1.5818881
    ## 466  0.8601170 -0.6864529
    ## 325 -0.5157871 -0.4723268
    ## 416 -0.8228892 -2.0800021

### Taking out the first 14 PCs

    ##             PC1        PC2         PC3         PC4        PC5        PC6
    ## 849  2.40633523 1.18845622 -2.20520117  0.67070390 -0.4008390  0.9623631
    ## 925  0.74924685 2.59133550  0.29012247 -0.06594698 -0.7980948 -2.5904208
    ## 498 -1.71110350 1.84238406 -1.82041733  1.89584090 -0.8066074  1.0725876
    ## 466  0.08267284 0.08253572 -0.07333943  2.30800138 -0.5239428  1.3757298
    ## 325  0.49601123 2.03728398  0.82221728 -1.29199027 -0.4204712  0.3998408
    ## 416 -0.98882514 2.68628023  2.27038431 -2.48013758  0.7205849 -3.4452011
    ##              PC7        PC8        PC9       PC10       PC11       PC12
    ## 849  3.109552821 -0.6674774  3.0711772 -0.5850462 -0.7363013  1.8818547
    ## 925 -1.505994366  1.2534910 -1.1161595  0.5383166  1.7365408 -0.4675288
    ## 498  1.940319388  0.8377373 -0.2676961 -0.4364324 -2.8254240  1.0166555
    ## 466 -1.699375591 -0.7817496  0.3996406 -1.4110333  0.3824675 -1.8161302
    ## 325  0.006628133 -0.9736738  0.5380429  0.3662837 -0.1728037 -0.3725905
    ## 416  0.193662549 -2.7277398  2.5091072  0.4679246  0.4802233  1.4365345
    ##           PC13       PC14
    ## 849  0.4826010  0.6609888
    ## 925  1.6130843 -1.1724638
    ## 498 -1.2620974  1.5818881
    ## 466  0.8601170 -0.6864529
    ## 325 -0.5157871 -0.4723268
    ## 416 -0.8228892 -2.0800021

Principal Component Analysis on Big5 columns
--------------------------------------------

    ## [1] 5000  107

    ##           PC1         PC2         PC3         PC4         PC5         PC6
    ## E1  0.1814075 -0.12312074  0.15068499 -0.09008466  0.15962638 -0.10666695
    ## E2 -0.1773063  0.15740616 -0.15045741  0.08792998 -0.14436792 -0.12826274
    ## E3  0.2474366 -0.07720903  0.04944276 -0.11632812  0.06952189 -0.07159757
    ## E4 -0.2010029  0.09180259 -0.15409936  0.11736287 -0.14349983 -0.14157005
    ## E5  0.2314176 -0.13805617  0.09546865 -0.06753983  0.14026444 -0.01060677
    ## E6 -0.1904943  0.11192849 -0.13141372 -0.02142404 -0.08894255 -0.22460688
    ##           PC7         PC8        PC9        PC10        PC11         PC12
    ## E1 0.01926778 -0.08808511 0.01611768 -0.03520748  0.10295568 -0.063794575
    ## E2 0.02001374 -0.13621418 0.07198161  0.03249345  0.05134922 -0.201383838
    ## E3 0.08291197 -0.05874107 0.09548657 -0.01379288  0.02619174  0.054242200
    ## E4 0.04097756 -0.02756089 0.08728882 -0.08474915 -0.01762125 -0.007102815
    ## E5 0.07220435 -0.01225390 0.02393521 -0.04445866 -0.04344394  0.094792590
    ## E6 0.03302689 -0.17099151 0.04199181  0.02760464  0.08399080 -0.242649122
    ##            PC13        PC14        PC15        PC16         PC17        PC18
    ## E1  0.137089105  0.01754058 -0.04348198 -0.09237452 -0.003105910 0.129867777
    ## E2 -0.039216664  0.03411028 -0.10172258  0.11260065  0.203328018 0.075542780
    ## E3  0.042868021 -0.11216921 -0.04939954 -0.05901622  0.206907877 0.049448965
    ## E4  0.004459078 -0.07580240 -0.08739519  0.06925852  0.015924984 0.017837029
    ## E5  0.206579182 -0.11375316 -0.08411300  0.02952746  0.005696409 0.009324362
    ## E6 -0.015094572 -0.02924497 -0.08534992 -0.05876891  0.233342448 0.111503755
    ##            PC19         PC20
    ## E1  0.134428488  0.201773867
    ## E2  0.091241551  0.182241918
    ## E3  0.167431144 -0.009069857
    ## E4 -0.014024581  0.015964943
    ## E5 -0.005559828 -0.074931141
    ## E6  0.111860803  0.239648848

    ##              PC1         PC2        PC3        PC4        PC5        PC6
    ## 12171 -4.2281719  0.09414946 -1.3358523  1.0367636 -3.1158100 -0.5579354
    ## 13326 -1.1591050  0.40162890  2.0486767  1.2753684  3.9863527  0.3281744
    ## 4831   2.9793370 -1.90827884 -1.6553652 -0.2657698  0.5448155 -1.3335340
    ## 11065  2.7232585  2.30375915 -0.6191980  0.8428194  2.7204532  1.9388028
    ## 8502  -0.5840147  1.26746266  1.8184121  0.7904014 -3.6101288 -0.4931417
    ## 3293  -1.7304459  2.37018711  0.2938001 -1.5130163  0.2905016  1.8268955
    ##              PC7         PC8         PC9       PC10       PC11       PC12
    ## 12171  0.2497698 -0.53579970 -0.28985466  1.2367214 -2.1649160 -0.4947592
    ## 13326 -0.4344382 -1.33979430 -1.61670654  1.6336918  0.1593578  1.2330498
    ## 4831  -1.1218635  0.81310945 -0.13324660 -0.8092402  0.2244848 -0.7121255
    ## 11065 -0.8875500  1.15160434  0.04443927  1.4714151  0.6759259  0.4525514
    ## 8502  -0.4901897 -0.11425653 -0.29206909 -0.4725029 -0.7379404  1.5372819
    ## 3293  -1.6583981  0.07137076  0.65128441 -0.5163869 -0.9335496 -0.8234795
    ##              PC13       PC14          PC15        PC16       PC17        PC18
    ## 12171 -0.04607323 -0.0561816  0.0006671697 -0.12732146 -1.2949965  0.19732698
    ## 13326  1.77739261 -0.7340616  0.2374353846  1.80674667 -0.6816483  0.30128877
    ## 4831   0.50579851  0.9184789 -0.6350679776  0.05617190  0.7869923 -0.07708356
    ## 11065  0.56815621 -0.1582787 -0.6707577409  1.07633665  0.8272276  0.30490644
    ## 8502   0.24473280 -0.3744436 -0.1517338728 -0.96654036 -0.6377769  0.06663111
    ## 3293  -0.41729393 -1.7495846 -0.3671674264 -0.04435093  1.1024128  0.37357408
    ##            PC19        PC20       PC21       PC22       PC23       PC24
    ## 12171 2.1958304  0.06327232 -1.0322702  0.1689075 -0.2935073  0.9368265
    ## 13326 0.2309333 -0.51744998  0.3810510  0.4791478  1.9455026 -0.5329160
    ## 4831  0.3967830  0.25950193 -0.6805522  0.6790635  0.8064277  0.2629281
    ## 11065 0.4260374 -0.29630587 -1.5836560 -0.5861661 -0.4482428 -0.6250697
    ## 8502  0.9648619  1.89616376  0.3077211  0.2785895 -0.1913709  0.6014772
    ## 3293  0.3191259  0.63598246 -0.6330488  1.9904586 -0.4040793  0.6050507
    ##              PC25        PC26       PC27        PC28       PC29      PC30
    ## 12171 -0.37408181 -1.34955879 -0.1538797 -0.33027654  0.1271963 0.6728096
    ## 13326  0.16472667  1.23143462 -0.4388517  0.11677837 -0.8859158 0.9799371
    ## 4831   0.39192287  0.35626950 -0.2980237 -0.45841905  0.6312962 0.2158707
    ## 11065 -0.05441121  0.07442711 -0.5220421  1.10190840 -1.1936718 1.0715715
    ## 8502   0.90084730 -0.44447989  0.3666533 -1.08234925  0.7146619 0.8645506
    ## 3293   1.07100633 -0.66082851 -0.3430444  0.06149232  1.1302729 0.6597747
    ##              PC31        PC32       PC33        PC34        PC35        PC36
    ## 12171 -1.02764681  0.13250170  0.4659116 -1.37362726 -0.27940673  0.50840788
    ## 13326  0.14019962  2.28284367 -0.0576576 -0.65195859 -1.27116114  3.15720623
    ## 4831  -0.18236152 -0.08742827 -0.5297614 -0.05102678  0.37705937 -0.21177401
    ## 11065 -1.11330391  1.12831119  0.4111681 -0.69193399  0.04732691  0.50767646
    ## 8502   1.27147411 -0.39405372 -1.0883598 -0.65332280 -0.29666520  1.62545282
    ## 3293  -0.05417387 -0.17319908  0.1393545 -0.90481846  0.45632760 -0.08106184
    ##              PC37       PC38        PC39       PC40        PC41        PC42
    ## 12171 -0.26047924 -1.1238449 -0.75034410  0.7425813  0.02383845 -1.01169014
    ## 13326  0.20791201 -0.2946183  1.72806294 -0.6050935 -1.13347447 -0.41910248
    ## 4831   0.04377552 -0.5869042 -0.54163004  0.2357573  0.62130407 -0.62349473
    ## 11065  0.31948445  0.6755323 -0.21434863  0.3638716  0.74819865  0.05293598
    ## 8502   0.27923794  0.7813368 -0.06250686  0.4061762 -0.17454949  0.07364748
    ## 3293   0.25418262 -0.3464935 -0.03286990  0.7462930 -0.18161169  0.86026067
    ##              PC43       PC44       PC45       PC46         PC47         PC48
    ## 12171  1.29924298 -0.8103453  0.2890748  1.1645788  0.658093553  0.112085494
    ## 13326  0.86491127 -0.2051620  0.5043571  0.7524091  1.065792298  1.490626744
    ## 4831   0.05428579 -0.1794527  0.1472287 -0.1480209 -0.052683257  0.008162951
    ## 11065 -0.01803983 -0.1048829  0.6039027 -0.2225279 -0.003864129  0.438556047
    ## 8502   1.04089473  0.5551200  0.5881510 -0.6462682  0.240949565 -0.907765856
    ## 3293  -0.21571130 -0.2555440 -0.3784223 -0.5690950 -0.684059595  0.354005806
    ##              PC49       PC50
    ## 12171  0.45654972  0.4687007
    ## 13326 -0.12747599 -0.3696767
    ## 4831  -0.41783371 -0.2238276
    ## 11065  0.08072017 -0.4759944
    ## 8502   0.85422051 -2.0360668
    ## 3293   0.10754078  0.5556684

![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-27-1.png)![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-27-2.png)

    ## Importance of components:
    ##                           PC1     PC2     PC3     PC4     PC5     PC6     PC7
    ## Standard deviation     2.8450 2.15128 1.95976 1.87808 1.66947 1.23913 1.15664
    ## Proportion of Variance 0.1619 0.09256 0.07681 0.07054 0.05574 0.03071 0.02676
    ## Cumulative Proportion  0.1619 0.25444 0.33126 0.40180 0.45754 0.48825 0.51501
    ##                            PC8     PC9    PC10    PC11    PC12    PC13    PC14
    ## Standard deviation     1.02914 0.98430 0.96779 0.95148 0.93307 0.92084 0.90414
    ## Proportion of Variance 0.02118 0.01938 0.01873 0.01811 0.01741 0.01696 0.01635
    ## Cumulative Proportion  0.53619 0.55557 0.57430 0.59240 0.60982 0.62678 0.64313
    ##                           PC15   PC16    PC17    PC18    PC19    PC20   PC21
    ## Standard deviation     0.87984 0.8661 0.85619 0.84966 0.82899 0.82431 0.8063
    ## Proportion of Variance 0.01548 0.0150 0.01466 0.01444 0.01374 0.01359 0.0130
    ## Cumulative Proportion  0.65861 0.6736 0.68827 0.70271 0.71646 0.73004 0.7430
    ##                           PC22    PC23    PC24    PC25    PC26    PC27    PC28
    ## Standard deviation     0.79663 0.77960 0.76689 0.76378 0.75675 0.73671 0.72830
    ## Proportion of Variance 0.01269 0.01216 0.01176 0.01167 0.01145 0.01085 0.01061
    ## Cumulative Proportion  0.75574 0.76790 0.77966 0.79133 0.80278 0.81363 0.82424
    ##                           PC29    PC30    PC31    PC32    PC33    PC34    PC35
    ## Standard deviation     0.71113 0.70816 0.70271 0.69560 0.68946 0.67934 0.67148
    ## Proportion of Variance 0.01011 0.01003 0.00988 0.00968 0.00951 0.00923 0.00902
    ## Cumulative Proportion  0.83436 0.84439 0.85426 0.86394 0.87345 0.88268 0.89169
    ##                           PC36    PC37    PC38    PC39    PC40   PC41    PC42
    ## Standard deviation     0.66791 0.65350 0.64617 0.64001 0.62737 0.6243 0.61955
    ## Proportion of Variance 0.00892 0.00854 0.00835 0.00819 0.00787 0.0078 0.00768
    ## Cumulative Proportion  0.90062 0.90916 0.91751 0.92570 0.93357 0.9414 0.94905
    ##                           PC43    PC44   PC45    PC46    PC47    PC48    PC49
    ## Standard deviation     0.60336 0.59488 0.5829 0.57613 0.57386 0.56660 0.54627
    ## Proportion of Variance 0.00728 0.00708 0.0068 0.00664 0.00659 0.00642 0.00597
    ## Cumulative Proportion  0.95633 0.96340 0.9702 0.97684 0.98342 0.98985 0.99581
    ##                           PC50
    ## Standard deviation     0.45752
    ## Proportion of Variance 0.00419
    ## Cumulative Proportion  1.00000

![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-28-1.png)

Proportion of Variance explained by each additional PC

![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-29-1.png)

Setting a cutoff point at 60% cumulative percentage

![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-30-1.png)

    ##              PC1         PC2        PC3        PC4        PC5        PC6
    ## 12171 -4.2281719  0.09414946 -1.3358523  1.0367636 -3.1158100 -0.5579354
    ## 13326 -1.1591050  0.40162890  2.0486767  1.2753684  3.9863527  0.3281744
    ## 4831   2.9793370 -1.90827884 -1.6553652 -0.2657698  0.5448155 -1.3335340
    ## 11065  2.7232585  2.30375915 -0.6191980  0.8428194  2.7204532  1.9388028
    ## 8502  -0.5840147  1.26746266  1.8184121  0.7904014 -3.6101288 -0.4931417
    ## 3293  -1.7304459  2.37018711  0.2938001 -1.5130163  0.2905016  1.8268955
    ##              PC7         PC8         PC9       PC10       PC11       PC12
    ## 12171  0.2497698 -0.53579970 -0.28985466  1.2367214 -2.1649160 -0.4947592
    ## 13326 -0.4344382 -1.33979430 -1.61670654  1.6336918  0.1593578  1.2330498
    ## 4831  -1.1218635  0.81310945 -0.13324660 -0.8092402  0.2244848 -0.7121255
    ## 11065 -0.8875500  1.15160434  0.04443927  1.4714151  0.6759259  0.4525514
    ## 8502  -0.4901897 -0.11425653 -0.29206909 -0.4725029 -0.7379404  1.5372819
    ## 3293  -1.6583981  0.07137076  0.65128441 -0.5163869 -0.9335496 -0.8234795

### Taking out first 12 PCs

    ##              PC1         PC2        PC3        PC4        PC5        PC6
    ## 12171 -4.2281719  0.09414946 -1.3358523  1.0367636 -3.1158100 -0.5579354
    ## 13326 -1.1591050  0.40162890  2.0486767  1.2753684  3.9863527  0.3281744
    ## 4831   2.9793370 -1.90827884 -1.6553652 -0.2657698  0.5448155 -1.3335340
    ## 11065  2.7232585  2.30375915 -0.6191980  0.8428194  2.7204532  1.9388028
    ## 8502  -0.5840147  1.26746266  1.8184121  0.7904014 -3.6101288 -0.4931417
    ## 3293  -1.7304459  2.37018711  0.2938001 -1.5130163  0.2905016  1.8268955
    ##              PC7         PC8         PC9       PC10       PC11       PC12
    ## 12171  0.2497698 -0.53579970 -0.28985466  1.2367214 -2.1649160 -0.4947592
    ## 13326 -0.4344382 -1.33979430 -1.61670654  1.6336918  0.1593578  1.2330498
    ## 4831  -1.1218635  0.81310945 -0.13324660 -0.8092402  0.2244848 -0.7121255
    ## 11065 -0.8875500  1.15160434  0.04443927  1.4714151  0.6759259  0.4525514
    ## 8502  -0.4901897 -0.11425653 -0.29206909 -0.4725029 -0.7379404  1.5372819
    ## 3293  -1.6583981  0.07137076  0.65128441 -0.5163869 -0.9335496 -0.8234795

### Creating a dataframe with Principal Component values only

    ##  [1] "names"   "race"    "age"     "engnat"  "gender"  "country" "PC1"    
    ##  [8] "PC2"     "PC3"     "PC4"     "PC5"     "PC6"     "PC7"     "PC8"    
    ## [15] "PC9"     "PC10"    "PC11"    "PC12"

    ##            names race age engnat gender country     bigPC1      bigPC2
    ## 12171      Penni    3  21      1      1      US -4.2281719  0.09414946
    ## 13326 Margaretha    3  18      2      1      IT -1.1591050  0.40162890
    ## 4831     Isadore    3  34      1      2      US  2.9793370 -1.90827884
    ## 11065    Kinsley    3  25      1      2      US  2.7232585  2.30375915
    ## 8502        Shad    1  24      1      2      US -0.5840147  1.26746266
    ## 3293        Sara   13  42      2      1      SA -1.7304459  2.37018711
    ##           bigPC3     bigPC4     bigPC5     bigPC6     bigPC7      bigPC8
    ## 12171 -1.3358523  1.0367636 -3.1158100 -0.5579354  0.2497698 -0.53579970
    ## 13326  2.0486767  1.2753684  3.9863527  0.3281744 -0.4344382 -1.33979430
    ## 4831  -1.6553652 -0.2657698  0.5448155 -1.3335340 -1.1218635  0.81310945
    ## 11065 -0.6191980  0.8428194  2.7204532  1.9388028 -0.8875500  1.15160434
    ## 8502   1.8184121  0.7904014 -3.6101288 -0.4931417 -0.4901897 -0.11425653
    ## 3293   0.2938001 -1.5130163  0.2905016  1.8268955 -1.6583981  0.07137076
    ##            bigPC9    bigPC10    bigPC11    bigPC12
    ## 12171 -0.28985466  1.2367214 -2.1649160 -0.4947592
    ## 13326 -1.61670654  1.6336918  0.1593578  1.2330498
    ## 4831  -0.13324660 -0.8092402  0.2244848 -0.7121255
    ## 11065  0.04443927  1.4714151  0.6759259  0.4525514
    ## 8502  -0.29206909 -0.4725029 -0.7379404  1.5372819
    ## 3293   0.65128441 -0.5163869 -0.9335496 -0.8234795

    ##  [1] "names"   "race"    "age"     "engnat"  "gender"  "country" "bigPC1" 
    ##  [8] "bigPC2"  "bigPC3"  "bigPC4"  "bigPC5"  "bigPC6"  "bigPC7"  "bigPC8" 
    ## [15] "bigPC9"  "bigPC10" "bigPC11" "bigPC12" "PC1"     "PC2"     "PC3"    
    ## [22] "PC4"     "PC5"     "PC6"     "PC7"     "PC8"     "PC9"     "PC10"   
    ## [29] "PC11"    "PC12"    "PC13"    "PC14"

    ##            names race age engnat gender country     bigPC1      bigPC2
    ## 12171      Penni    3  21      1      1      US -4.2281719  0.09414946
    ## 13326 Margaretha    3  18      2      1      IT -1.1591050  0.40162890
    ## 4831     Isadore    3  34      1      2      US  2.9793370 -1.90827884
    ## 11065    Kinsley    3  25      1      2      US  2.7232585  2.30375915
    ## 8502        Shad    1  24      1      2      US -0.5840147  1.26746266
    ## 3293        Sara   13  42      2      1      SA -1.7304459  2.37018711
    ##           bigPC3     bigPC4     bigPC5     bigPC6     bigPC7      bigPC8
    ## 12171 -1.3358523  1.0367636 -3.1158100 -0.5579354  0.2497698 -0.53579970
    ## 13326  2.0486767  1.2753684  3.9863527  0.3281744 -0.4344382 -1.33979430
    ## 4831  -1.6553652 -0.2657698  0.5448155 -1.3335340 -1.1218635  0.81310945
    ## 11065 -0.6191980  0.8428194  2.7204532  1.9388028 -0.8875500  1.15160434
    ## 8502   1.8184121  0.7904014 -3.6101288 -0.4931417 -0.4901897 -0.11425653
    ## 3293   0.2938001 -1.5130163  0.2905016  1.8268955 -1.6583981  0.07137076
    ##            bigPC9    bigPC10    bigPC11    bigPC12      intPC1     intPC2
    ## 12171 -0.28985466  1.2367214 -2.1649160 -0.4947592  2.40633523 1.18845622
    ## 13326 -1.61670654  1.6336918  0.1593578  1.2330498  0.74924685 2.59133550
    ## 4831  -0.13324660 -0.8092402  0.2244848 -0.7121255 -1.71110350 1.84238406
    ## 11065  0.04443927  1.4714151  0.6759259  0.4525514  0.08267284 0.08253572
    ## 8502  -0.29206909 -0.4725029 -0.7379404  1.5372819  0.49601123 2.03728398
    ## 3293   0.65128441 -0.5163869 -0.9335496 -0.8234795 -0.98882514 2.68628023
    ##            intPC3      intPC4     intPC5     intPC6       intPC7     intPC8
    ## 12171 -2.20520117  0.67070390 -0.4008390  0.9623631  3.109552821 -0.6674774
    ## 13326  0.29012247 -0.06594698 -0.7980948 -2.5904208 -1.505994366  1.2534910
    ## 4831  -1.82041733  1.89584090 -0.8066074  1.0725876  1.940319388  0.8377373
    ## 11065 -0.07333943  2.30800138 -0.5239428  1.3757298 -1.699375591 -0.7817496
    ## 8502   0.82221728 -1.29199027 -0.4204712  0.3998408  0.006628133 -0.9736738
    ## 3293   2.27038431 -2.48013758  0.7205849 -3.4452011  0.193662549 -2.7277398
    ##           intPC9    intPC10    intPC11    intPC12    intPC13    intPC14
    ## 12171  3.0711772 -0.5850462 -0.7363013  1.8818547  0.4826010  0.6609888
    ## 13326 -1.1161595  0.5383166  1.7365408 -0.4675288  1.6130843 -1.1724638
    ## 4831  -0.2676961 -0.4364324 -2.8254240  1.0166555 -1.2620974  1.5818881
    ## 11065  0.3996406 -1.4110333  0.3824675 -1.8161302  0.8601170 -0.6864529
    ## 8502   0.5380429  0.3662837 -0.1728037 -0.3725905 -0.5157871 -0.4723268
    ## 3293   2.5091072  0.4679246  0.4802233  1.4365345 -0.8228892 -2.0800021

    ##  [1] "names"   "race"    "age"     "engnat"  "gender"  "country" "bigPC1" 
    ##  [8] "bigPC2"  "bigPC3"  "bigPC4"  "bigPC5"  "bigPC6"  "bigPC7"  "bigPC8" 
    ## [15] "bigPC9"  "bigPC10" "bigPC11" "bigPC12" "intPC1"  "intPC2"  "intPC3" 
    ## [22] "intPC4"  "intPC5"  "intPC6"  "intPC7"  "intPC8"  "intPC9"  "intPC10"
    ## [29] "intPC11" "intPC12" "intPC13" "intPC14"

CLUSTERING PEOPLE ON THE BASIS OF THEIR INTERESTS
=================================================

Heirarchical Clustering
-----------------------

    ##            names race age engnat gender country     bigPC1      bigPC2
    ## 12171      Penni    3  21      1      1      US -4.2281719  0.09414946
    ## 13326 Margaretha    3  18      2      1      IT -1.1591050  0.40162890
    ## 4831     Isadore    3  34      1      2      US  2.9793370 -1.90827884
    ## 11065    Kinsley    3  25      1      2      US  2.7232585  2.30375915
    ## 8502        Shad    1  24      1      2      US -0.5840147  1.26746266
    ## 3293        Sara   13  42      2      1      SA -1.7304459  2.37018711
    ##           bigPC3     bigPC4     bigPC5     bigPC6     bigPC7      bigPC8
    ## 12171 -1.3358523  1.0367636 -3.1158100 -0.5579354  0.2497698 -0.53579970
    ## 13326  2.0486767  1.2753684  3.9863527  0.3281744 -0.4344382 -1.33979430
    ## 4831  -1.6553652 -0.2657698  0.5448155 -1.3335340 -1.1218635  0.81310945
    ## 11065 -0.6191980  0.8428194  2.7204532  1.9388028 -0.8875500  1.15160434
    ## 8502   1.8184121  0.7904014 -3.6101288 -0.4931417 -0.4901897 -0.11425653
    ## 3293   0.2938001 -1.5130163  0.2905016  1.8268955 -1.6583981  0.07137076
    ##            bigPC9    bigPC10    bigPC11    bigPC12      intPC1     intPC2
    ## 12171 -0.28985466  1.2367214 -2.1649160 -0.4947592  2.40633523 1.18845622
    ## 13326 -1.61670654  1.6336918  0.1593578  1.2330498  0.74924685 2.59133550
    ## 4831  -0.13324660 -0.8092402  0.2244848 -0.7121255 -1.71110350 1.84238406
    ## 11065  0.04443927  1.4714151  0.6759259  0.4525514  0.08267284 0.08253572
    ## 8502  -0.29206909 -0.4725029 -0.7379404  1.5372819  0.49601123 2.03728398
    ## 3293   0.65128441 -0.5163869 -0.9335496 -0.8234795 -0.98882514 2.68628023
    ##            intPC3      intPC4     intPC5     intPC6       intPC7     intPC8
    ## 12171 -2.20520117  0.67070390 -0.4008390  0.9623631  3.109552821 -0.6674774
    ## 13326  0.29012247 -0.06594698 -0.7980948 -2.5904208 -1.505994366  1.2534910
    ## 4831  -1.82041733  1.89584090 -0.8066074  1.0725876  1.940319388  0.8377373
    ## 11065 -0.07333943  2.30800138 -0.5239428  1.3757298 -1.699375591 -0.7817496
    ## 8502   0.82221728 -1.29199027 -0.4204712  0.3998408  0.006628133 -0.9736738
    ## 3293   2.27038431 -2.48013758  0.7205849 -3.4452011  0.193662549 -2.7277398
    ##           intPC9    intPC10    intPC11    intPC12    intPC13    intPC14
    ## 12171  3.0711772 -0.5850462 -0.7363013  1.8818547  0.4826010  0.6609888
    ## 13326 -1.1161595  0.5383166  1.7365408 -0.4675288  1.6130843 -1.1724638
    ## 4831  -0.2676961 -0.4364324 -2.8254240  1.0166555 -1.2620974  1.5818881
    ## 11065  0.3996406 -1.4110333  0.3824675 -1.8161302  0.8601170 -0.6864529
    ## 8502   0.5380429  0.3662837 -0.1728037 -0.3725905 -0.5157871 -0.4723268
    ## 3293   2.5091072  0.4679246  0.4802233  1.4365345 -0.8228892 -2.0800021

    ##      bigPC1              bigPC2             bigPC3             bigPC4       
    ##  Min.   :-11.97996   Min.   :-6.64893   Min.   :-6.14696   Min.   :-6.9228  
    ##  1st Qu.: -2.00630   1st Qu.:-1.46335   1st Qu.:-1.28595   1st Qu.:-1.2241  
    ##  Median :  0.04769   Median :-0.05334   Median :-0.08839   Median : 0.0419  
    ##  Mean   :  0.00000   Mean   : 0.00000   Mean   : 0.00000   Mean   : 0.0000  
    ##  3rd Qu.:  2.01095   3rd Qu.: 1.42044   3rd Qu.: 1.24753   3rd Qu.: 1.2912  
    ##  Max.   :  8.62334   Max.   : 9.35313   Max.   : 8.67697   Max.   : 5.2253  
    ##      bigPC5             bigPC6             bigPC7             bigPC8        
    ##  Min.   :-6.43637   Min.   :-7.74342   Min.   :-4.25401   Min.   :-4.76082  
    ##  1st Qu.:-1.10852   1st Qu.:-0.73992   1st Qu.:-0.75632   1st Qu.:-0.63424  
    ##  Median :-0.01353   Median : 0.07231   Median :-0.02126   Median : 0.01427  
    ##  Mean   : 0.00000   Mean   : 0.00000   Mean   : 0.00000   Mean   : 0.00000  
    ##  3rd Qu.: 1.05971   3rd Qu.: 0.82752   3rd Qu.: 0.70002   3rd Qu.: 0.66210  
    ##  Max.   : 8.39430   Max.   : 7.57922   Max.   : 5.37350   Max.   : 4.19036  
    ##      bigPC9            bigPC10            bigPC11            bigPC12        
    ##  Min.   :-4.26527   Min.   :-3.64856   Min.   :-4.65148   Min.   :-3.63964  
    ##  1st Qu.:-0.62816   1st Qu.:-0.61485   1st Qu.:-0.58964   1st Qu.:-0.61405  
    ##  Median :-0.01029   Median :-0.01637   Median : 0.02265   Median :-0.01593  
    ##  Mean   : 0.00000   Mean   : 0.00000   Mean   : 0.00000   Mean   : 0.00000  
    ##  3rd Qu.: 0.62928   3rd Qu.: 0.62238   3rd Qu.: 0.61111   3rd Qu.: 0.59557  
    ##  Max.   : 3.97067   Max.   : 4.65299   Max.   : 3.79308   Max.   : 4.54555  
    ##      intPC1             intPC2            intPC3            intPC4        
    ##  Min.   :-6.15531   Min.   :-6.6050   Min.   :-5.0356   Min.   :-4.45407  
    ##  1st Qu.:-1.67308   1st Qu.:-1.5446   1st Qu.:-1.2614   1st Qu.:-1.02977  
    ##  Median :-0.01012   Median : 0.1526   Median : 0.1416   Median : 0.02759  
    ##  Mean   : 0.00000   Mean   : 0.0000   Mean   : 0.0000   Mean   : 0.00000  
    ##  3rd Qu.: 1.63923   3rd Qu.: 1.4387   3rd Qu.: 1.3402   3rd Qu.: 1.13046  
    ##  Max.   : 6.57355   Max.   : 5.0302   Max.   : 5.4538   Max.   : 4.84087  
    ##      intPC5             intPC6             intPC7              intPC8        
    ##  Min.   :-5.28843   Min.   :-3.94786   Min.   :-3.934797   Min.   :-4.74929  
    ##  1st Qu.:-1.00202   1st Qu.:-0.85142   1st Qu.:-0.883630   1st Qu.:-0.79510  
    ##  Median : 0.05238   Median :-0.09942   Median : 0.005552   Median : 0.03857  
    ##  Mean   : 0.00000   Mean   : 0.00000   Mean   : 0.000000   Mean   : 0.00000  
    ##  3rd Qu.: 1.09424   3rd Qu.: 0.90053   3rd Qu.: 0.895008   3rd Qu.: 0.75753  
    ##  Max.   : 3.86125   Max.   : 4.25887   Max.   : 4.233777   Max.   : 5.02253  
    ##      intPC9            intPC10            intPC11            intPC12        
    ##  Min.   :-4.21023   Min.   :-3.43964   Min.   :-3.96774   Min.   :-3.17733  
    ##  1st Qu.:-0.73270   1st Qu.:-0.76225   1st Qu.:-0.70676   1st Qu.:-0.72962  
    ##  Median :-0.04246   Median :-0.02173   Median : 0.00916   Median :-0.04405  
    ##  Mean   : 0.00000   Mean   : 0.00000   Mean   : 0.00000   Mean   : 0.00000  
    ##  3rd Qu.: 0.82123   3rd Qu.: 0.77060   3rd Qu.: 0.66332   3rd Qu.: 0.68411  
    ##  Max.   : 3.55215   Max.   : 3.47732   Max.   : 3.65949   Max.   : 3.90112  
    ##     intPC13             intPC14         
    ##  Min.   :-5.190609   Min.   :-3.144010  
    ##  1st Qu.:-0.634196   1st Qu.:-0.704728  
    ##  Median :-0.002093   Median : 0.009765  
    ##  Mean   : 0.000000   Mean   : 0.000000  
    ##  3rd Qu.: 0.661558   3rd Qu.: 0.705060  
    ##  Max.   : 3.054591   Max.   : 3.086630

Plotting the dendogram ![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-39-1.png)

### Setting the value of clusters at 12

    ## 12171 13326  4831 11065  8502  3293 
    ##     1     2     1     3     2     4

KMeansClustering
----------------

    ## 12171 13326  4831 11065  8502  3293 
    ##     1     9    10     5     6     6

![](MLmatchmaking_files/figure-markdown_github/unnamed-chunk-41-1.png)

    ## 12171 13326  4831 11065  8502  3293  3470 15729 17157 11904 
    ##     1     9    10     5     6     6     1    10     7     4

Joining the cluster assigned with the PCA'd data

    ##  [1] "names"   "race"    "age"     "engnat"  "gender"  "country" "bigPC1" 
    ##  [8] "bigPC2"  "bigPC3"  "bigPC4"  "bigPC5"  "bigPC6"  "bigPC7"  "bigPC8" 
    ## [15] "bigPC9"  "bigPC10" "bigPC11" "bigPC12" "intPC1"  "intPC2"  "intPC3" 
    ## [22] "intPC4"  "intPC5"  "intPC6"  "intPC7"  "intPC8"  "intPC9"  "intPC10"
    ## [29] "intPC11" "intPC12" "intPC13" "intPC14" "cluster"

FINAL STEPS
===========

### Selecting close matches for selected user

    ##       names race age engnat gender country    bigPC1     bigPC2    bigPC3
    ## 12171 Penni    3  21      1      1      US -4.228172 0.09414946 -1.335852
    ##         bigPC4   bigPC5     bigPC6    bigPC7     bigPC8     bigPC9  bigPC10
    ## 12171 1.036764 -3.11581 -0.5579354 0.2497698 -0.5357997 -0.2898547 1.236721
    ##         bigPC11    bigPC12   intPC1   intPC2    intPC3    intPC4    intPC5
    ## 12171 -2.164916 -0.4947592 2.406335 1.188456 -2.205201 0.6707039 -0.400839
    ##          intPC6   intPC7     intPC8   intPC9    intPC10    intPC11  intPC12
    ## 12171 0.9623631 3.109553 -0.6674774 3.071177 -0.5850462 -0.7363013 1.881855
    ##        intPC13   intPC14 cluster
    ## 12171 0.482601 0.6609888       1

### Filtering out people from the same cluster, age-group and country

    ##      names race age engnat gender country     bigPC1     bigPC2     bigPC3
    ## 2   Pattie    1  20      1      2      US -1.3591848 -0.4410222 -2.0629725
    ## 10  Flavia    3  19      1      2      US -0.8608908 -3.5051350  1.8934139
    ## 11 Cordell    3  20      1      2      US -1.2422763 -1.8010652  1.4004030
    ## 15  Trever    3  18      1      2      US  1.0073120 -3.4750066 -0.0208245
    ## 16   Nyree    3  18      1      2      US -2.6417609 -1.3893535  2.1809865
    ## 20 Deandra    5  18      1      2      US -1.9631465 -1.8126092 -1.3268046
    ##        bigPC4     bigPC5     bigPC6     bigPC7     bigPC8      bigPC9
    ## 2   1.3618739  0.9788897 -0.7674841  1.4658995 -0.7795143 -0.31763272
    ## 10  3.3798324 -0.7247746 -0.4886086  0.5040522 -0.4642407 -0.02602447
    ## 11  0.4861108 -1.3481931 -0.2390959  1.0067133 -0.5460684 -0.30644901
    ## 15  1.1923144 -2.6411815  1.5232118 -0.3225577 -0.6669338  0.40951615
    ## 16 -2.0148036 -0.3818699 -0.1107040 -0.7705257  0.3354425  1.14204645
    ## 20  0.1900790  0.5582481 -0.6366194 -1.1087078 -0.4335865  1.53003843
    ##       bigPC10      bigPC11     bigPC12      intPC1     intPC2      intPC3
    ## 2   2.0305558 -0.391862295  0.21380406  2.94005560 -1.8140621  0.45463302
    ## 10  0.7178775  0.306932067 -0.07270868  2.66405460  0.3642381  1.16199285
    ## 11  0.7430249 -0.001685972 -1.30378513  2.78085615  2.5019028 -1.57953246
    ## 15 -0.5783593 -1.261206201  0.15611319  4.35417926 -0.1807315 -0.08391103
    ## 16 -0.6163481 -0.056849961  1.04640579 -0.01935004 -1.5445543 -1.57147154
    ## 20  2.5609672  0.565297217 -1.63971917  2.43000113 -0.1797337  0.28475132
    ##        intPC4     intPC5       intPC6      intPC7     intPC8     intPC9
    ## 2   0.9714420 -1.3388389  0.001766073 -0.64170517  2.4901381 -0.3664859
    ## 10 -1.6653897  1.0512304  0.501088846  0.54067481  0.5130717 -0.7236580
    ## 11 -0.3264251  1.1007270 -0.529838837 -2.06755536  1.3155182 -0.3177771
    ## 15  2.1519543 -2.1294845  0.228448079  0.64759632  1.2410461 -0.8051441
    ## 16 -4.0313972 -1.4910125 -0.514703819  1.62292253 -1.2812964 -0.5466060
    ## 20  2.8646253 -0.2263484 -0.680077314  0.04819325 -1.6112650 -2.1543500
    ##       intPC10    intPC11    intPC12      intPC13    intPC14 cluster
    ## 2   1.9920381  1.7659955  0.9100315 -1.321805468  0.3852264       1
    ## 10  0.6926626  1.0180089 -0.1289024  0.362388808  0.2550768       1
    ## 11 -0.4313477  0.8185153  0.2471594  0.922254812  1.1918573       1
    ## 15 -0.1616401 -0.1316805 -0.6986527 -0.772793391  1.9917018       1
    ## 16 -1.4896094 -0.9447188 -0.6479212 -0.002806051  1.2062599       1
    ## 20 -1.1025048  1.2071866  2.3624806 -0.652065975 -0.1300818       1

### Finding people with personality most similar to user's

    ##  [1] "Brody"    "Alissa"   "Young"    "Lizabeth" "Reinhold" "Liza"    
    ##  [7] "Meghann"  "Ephram"   "Keenen"   "Pattie"

    ##        names cluster
    ## 31     Brody       1
    ## 40    Alissa       1
    ## 34     Young       1
    ## 111 Lizabeth       1
    ## 363 Reinhold       1
    ## 367     Liza       1
    ## 184  Meghann       1
    ## 313   Ephram       1
    ## 55    Keenen       1
    ## 2     Pattie       1

Original responses of the filtered people and user
--------------------------------------------------

    ##       names race age engnat gender country E1 E2 E3 E4 E5 E6 E7 E8 E9 E10 N1 N2
    ## 12171 Penni    3  21      1      1      US  1  5  1  5  2  5  1  4  1   5  5  4
    ##       N3 N4 N5 N6 N7 N8 N9 N10 A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 C1 C2 C3 C4 C5 C6
    ## 12171  5  1  4  4  3  2  2   4  1  1  2  5  2  5  2  4  4   3  4  5  5  4  1  4
    ##       C7 C8 C9 C10 O1 O2 O3 O4 O5 O6 O7 O8 O9 O10 Music Classical.music Musical
    ## 12171  1  3  3   3  2  1  4  3  4  2  5  4  4   4     5               3       1
    ##       Pop Rock Metal.or.Hardrock Hiphop..Rap Rock.n.roll Alternative
    ## 12171   3    5                 3           1           3           5
    ##       Techno..Trance Movies Horror Thriller Comedy Romantic Sci.fi War
    ## 12171              2      3      1        2      3        4      4   2
    ##       Fantasy.Fairy.tales Animated Documentary Action History Psychology
    ## 12171                   1        2           1      3       1          5
    ##       Politics Mathematics Physics Internet PC Economy.Management Biology
    ## 12171        2           1       2        5  3                  5       2
    ##       Chemistry Reading Geography Foreign.languages Medicine Law Cars
    ## 12171         2       1         2                 3        1   2    1
    ##       Art.exhibitions Religion Dancing Musical.instruments Writing
    ## 12171               2        1       2                   2       1
    ##       Passive.sport Active.sport Science.and.technology Theatre
    ## 12171             5            1                      3       1
    ##       Adrenaline.sports Pets Appearence.and.gestures Happiness.in.life
    ## 12171                 4    2                       5                 5
    ##                     Education
    ## 12171 college/bachelor degree

    ##          names race age engnat gender country E1 E2 E3 E4 E5 E6 E7 E8 E9 E10 N1
    ## 3470    Pattie    1  20      1      2      US  2  3  2  4  3  2  3  4  2   4  4
    ## 17908    Brody    3  18      1      2      US  1  5  1  5  1  5  1  4  1   5  3
    ## 162      Young    3  22      1      2      US  1  5  3  5  1  5  1  5  1   5  5
    ## 18736   Alissa    1  22      1      2      US  1  5  2  5  1  4  1  5  1   5  5
    ## 7796    Keenen    3  18      1      2      US  2  4  2  4  1  4  1  5  1   5  3
    ## 17916 Lizabeth    3  21      2      2      US  3  5  2  4  4  5  1  4  2   5  4
    ## 8846   Meghann    3  21      1      2      US  1  5  2  5  2  4  1  5  1   5  5
    ## 1382    Ephram   13  18      1      2      US  1  3  1  5  3  5  2  5  3   5  5
    ## 12162 Reinhold    8  21      1      2      US  1  3  2  5  2  3  2  3  4   5  4
    ## 6464      Liza    1  22      1      3      US  1  4  1  5  1  4  1  4  2   5  3
    ##       N2 N3 N4 N5 N6 N7 N8 N9 N10 A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 C1 C2 C3 C4 C5
    ## 3470   3  4  2  5  3  3  4  4   4  5  3  1  5  2  4  3  4  5   4  5  4  5  3  3
    ## 17908  4  3  2  4  3  3  2  2   3  1  5  1  5  2  5  1  3  4   1  3  4  4  2  2
    ## 162    3  5  2  3  5  4  2  3   2  1  2  1  5  2  5  3  5  4   3  1  5  4  5  2
    ## 18736  3  5  2  3  5  5  3  4   3  1  2  3  5  3  5  4  5  5   4  4  3  4  4  1
    ## 7796   4  4  3  2  2  4  4  3   3  1  4  1  5  1  4  1  5  4   4  4  4  3  2  3
    ## 17916  2  4  1  4  4  4  2  3   4  2  4  1  3  3  5  2  3  3   2  4  5  2  3  1
    ## 8846   2  5  1  4  4  4  4  4   5  2  5  3  5  2  5  2  4  5   4  2  4  4  4  2
    ## 1382   5  5  1  3  4  5  4  4   4  1  5  1  5  3  5  1  4  5   3  1  4  4  3  1
    ## 12162  2  5  2  4  5  5  4  3   5  1  4  1  5  1  5  2  4  4   3  3  5  3  5  1
    ## 6464   3  3  1  4  4  3  4  4   5  2  4  4  4  3  3  3  4  4   1  2  5  4  4  2
    ##       C6 C7 C8 C9 C10 O1 O2 O3 O4 O5 O6 O7 O8 O9 O10 Music Classical.music
    ## 3470   4  5  2  5   4  4  2  4  1  4  4  5  3  5   4     3               1
    ## 17908  5  3  3  3   3  4  2  4  1  4  2  4  3  4   4     4               3
    ## 162    5  3  3  1   2  3  3  5  1  4  1  3  1  5   4     5               5
    ## 18736  5  2  1  2   4  4  4  4  2  3  1  4  4  5   4     5               4
    ## 7796   2  3  1  4   4  4  3  5  2  4  1  4  3  4   4     4               2
    ## 17916  5  5  5  3   4  3  3  5  1  5  2  2  4  5   5     4               3
    ## 8846   4  4  4  4   3  5  2  5  2  4  1  4  5  5   4     5               3
    ## 1382   5  5  3  4   3  5  1  5  1  4  1  4  5  5   5     5               3
    ## 12162  5  4  3  1   5  5  1  5  1  4  2  4  4  5   5     5               1
    ## 6464   4  2  4  1   2  4  2  4  2  3  2  4  4  5   4     5               3
    ##       Musical Pop Rock Metal.or.Hardrock Hiphop..Rap Rock.n.roll Alternative
    ## 3470        1   2    3                 2           2           2           2
    ## 17908       1   5    4                 1           1           2           1
    ## 162         3   2    1                 1           5           1           1
    ## 18736       3   4    4                 1           4           3           2
    ## 7796        1   3    3                 3           4           2           1
    ## 17916       1   3    5                 4           1           5           4
    ## 8846        2   3    3                 1           4           3           3
    ## 1382        1   2    3                 2           5           3           2
    ## 12162       1   3    1                 1           1           1           1
    ## 6464        4   4    4                 2           4           4           1
    ##       Techno..Trance Movies Horror Thriller Comedy Romantic Sci.fi War
    ## 3470               2      3      3        3      5        3      3   4
    ## 17908              1      5      1        2      5        2      4   5
    ## 162                2      5      1        1      5        1      4   5
    ## 18736              1      5      5        5      5        3      3   4
    ## 7796               4      5      5        5      5        3      5   5
    ## 17916              1      5      1        4      4        2      2   3
    ## 8846               1      5      3        3      5        4      4   2
    ## 1382               2      5      3        2      4        2      3   5
    ## 12162              1      3      5        5      5        5      3   1
    ## 6464               2      4      3        3      4        2      2   4
    ##       Fantasy.Fairy.tales Animated Documentary Action History Psychology
    ## 3470                    5        5           4      4       3          3
    ## 17908                   3        3           5      5       3          2
    ## 162                     3        1           4      5       4          3
    ## 18736                   3        4           3      4       4          4
    ## 7796                    4        4           3      5       5          2
    ## 17916                   1        1           1      3       4          2
    ## 8846                    4        4           3      4       2          3
    ## 1382                    2        3           5      3       4          4
    ## 12162                   2        1           2      2       1          3
    ## 6464                    2        3           2      4       5          2
    ##       Politics Mathematics Physics Internet PC Economy.Management Biology
    ## 3470         5           2       2        5  5                  4       2
    ## 17908        4           4       2        5  5                  1       1
    ## 162          5           1       1        4  3                  4       1
    ## 18736        4           1       1        5  5                  5       1
    ## 7796         3           2       1        5  3                  2       1
    ## 17916        5           1       1        5  5                  1       1
    ## 8846         1           4       5        4  5                  3       3
    ## 1382         1           3       3        4  3                  2       2
    ## 12162        1           1       5        5  5                  1       3
    ## 6464         5           1       2        4  4                  4       2
    ##       Chemistry Reading Geography Foreign.languages Medicine Law Cars
    ## 3470          2       1         3                 3        2   4    5
    ## 17908         1       3         3                 3        1   1    3
    ## 162           1       1         4                 5        1   3    5
    ## 18736         1       4         3                 3        1   5    1
    ## 7796          1       1         5                 3        3   1    2
    ## 17916         1       4         3                 2        1   4    4
    ## 8846          3       2         3                 5        3   2    5
    ## 1382          2       4         3                 1        2   4    1
    ## 12162         1       1         1                 2        2   1    5
    ## 6464          2       2         4                 4        3   5    3
    ##       Art.exhibitions Religion Dancing Musical.instruments Writing
    ## 3470                3        1       1                   1       1
    ## 17908               1        1       1                   1       1
    ## 162                 3        2       1                   5       3
    ## 18736               1        1       1                   1       4
    ## 7796                1        2       1                   1       1
    ## 17916               2        1       1                   1       1
    ## 8846                3        1       1                   2       1
    ## 1382                1        3       1                   1       1
    ## 12162               1        5       2                   1       1
    ## 6464                1        1       1                   2       1
    ##       Passive.sport Active.sport Science.and.technology Theatre
    ## 3470              5            5                      3       2
    ## 17908             2            1                      5       1
    ## 162               2            5                      2       2
    ## 18736             4            4                      5       3
    ## 7796              3            3                      2       1
    ## 17916             3            2                      3       2
    ## 8846              2            4                      5       4
    ## 1382              5            5                      2       3
    ## 12162             5            2                      5       1
    ## 6464              5            4                      3       4
    ##       Adrenaline.sports Pets Appearence.and.gestures Happiness.in.life
    ## 3470                  5    3                       3                 4
    ## 17908                 1    1                       4                 4
    ## 162                   4    3                       4                 3
    ## 18736                 4    1                       5                 2
    ## 7796                  3    3                       3                 3
    ## 17916                 1    4                       2                 3
    ## 8846                  5    4                       3                 4
    ## 1382                  4    3                       4                 4
    ## 12162                 1    1                       5                 3
    ## 6464                  5    4                       2                 4
    ##                     Education
    ## 3470  college/bachelor degree
    ## 17908        secondary school
    ## 162            masters degree
    ## 18736        secondary school
    ## 7796           primary school
    ## 17916        secondary school
    ## 8846         secondary school
    ## 1382           masters degree
    ## 12162          primary school
    ## 6464  college/bachelor degree

#### Thanks for sticking till the end

#### You can connect with me on:

#### [LinkedIn](https://www.linkedin.com/in/shariq06ahmed/)

#### [GitHub](https://github.com/ShariqAhmed007)
