Strategy Water Meter Performance
================

## Overview

Functions, datasets and script used in the paper *A strategy to assess
water meter performance* by Clara Cordeiro, Ana Borges and M. Rosario
Ramos, in *Journal of Water Resources Planning and Management*, 2021.
Status: *under revision*.

### Install packages

``` r
install.packages("forecast",dependencies = TRUE)
install.packages("strucchange",dependencies = TRUE)
install.packages("trend",dependencies = TRUE)
```

### Usage

``` r
library(forecast)  # version 8.14
library(strucchange) # 1.5-2
library(trend) # 1.1.4
load("workspace_data_functions.RData")
```

which includes the functions:

-   **test.Outliers.STL**: boolean output, *True* in case of outliers

-   **T.dec**: boolean output, *True* in case of a decreasing trend
    using Mann-Kendall test

-   **s.bp**: find the relevant breakpoints

-   **RelMChange**: calculate the RMC (Eq. 5)

### Example

#### Initial settings

``` r
y<-RH2  # Residential household 2 (RH2)
```

<img src="README_files/figure-gfm/unnamed-chunk-4-1.png" style="display: block; margin: auto;" />

``` r
al<-0.05  # level of significance
s<-12   # define frequency or just use s<-frequency(y)
n.y<-length(y)  # time series length
k<-3  # the error measure considered, in this case is Mean Absolute Error (MAE). However, it can be set as Mean Error (ME) (k<-1), or Root Mean Square Error (RMSE) (k<-2), see function accuracy() at package forecast for more information about it
```

#### Step 1 - Seasonal-trend decomposition based on Loess

``` r
rob.y<-test.Outliers.STL(y) # check outliers
fit.y<-stl.fit(y,rob.y,k)  # stl.fit function
```

<img src="README_files/figure-gfm/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

#### Step 2 - Detecting *breakpoints* (bp)

``` r
ystar<-y-fit.y$stlfit$time.series[,"seasonal"] # seasonally adjusted (y*)  (Eq.2)
min.h<-round(s/n.y,2) # max breaks (Eq. 3)
max.break<-ceiling(0.5/min.h) # min h (Eq. 4)
bpy<-breakpoints(ystar~1,h = min.h,breaks=max.break) # breakpoints() from package strucchange
```

<img src="README_files/figure-gfm/unnamed-chunk-6-1.png" style="display: block; margin: auto;" />

#### Step 3 - Detecting *relevant breakpoints* (bp\*)

``` r
bpy.star<-s.bp(ystar,bpy$breakpoints,al)
```

<img src="README_files/figure-gfm/unnamed-chunk-7-1.png" style="display: block; margin: auto;" />

#### Step 4 - Determining *Relative Magnitude of Change* (RMC)

If bp\*=NULL then stop otherwise do the following

``` r
rmc<-RelMChange(ystar,bpy$breakpoints,bpy.star) (Eq. 5)
```

## Results

Table 1 and table 2, separated by double **\| \|**. See
*script\_tables.R*.

    ## [1] "Type | Breakpoints |  Segment 1  | Segment 2  | Segment 3  | | Relevant bp* | RMC "

    ## [1] "Rh2 | 2012(Apr),2015(Dec) | 0.01(0.89256) | -0.02(0.39474) | -0.26(2e-04) |  |  2015(Dec)  |  -12 |"

## Note

Contributions, issues, and feature requests are welcome!
