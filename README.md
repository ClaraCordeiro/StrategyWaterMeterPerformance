# StrategyWaterMeterPerformance
A strategy to assess water meter performance- Script, functions and datasets.

### Install packages

```R
> install.packages("forecast",dependencies = TRUE)
> install.packages("strucchange",dependencies = TRUE)
> install.packages("trend",dependencies = TRUE)
```

### Load workspace 

```R
load("workspace_data_functions.RData")
```
which includes the functions:

- **test.Outliers.STL**: boolean output, *True* in case of outliers

- **T.dec**: boolean output, *True* in case of a decreasing trend using Mann-Kendall test

- **s.bp**: find the relevant breakpoints

- **RelMChange**: calculate the RMC (Eq. 5)


### Example

#### Initial settings

```R
y<-RH2  # Residential household 2 (RH2)
al<-0.05  # level of significance
s<-12   # define frequency or just use s<-frequency(y)
n.y<-length(y)  # time series length
k<-3  # the error measure considered, in this case is Mean Absolute Error (MAE). However, it can be set as Mean Error (ME) (k<-1), or Root Mean Square Error (RMSE) (k<-2), see function accuracy() at package forecast for more information about it
```

#### Step 1 - Seasonal-trend decomposition based on Loess

```R
rob.y<-test.Outliers.STL(y) # check outliers
fit.y<-stl.fit(y,rob.y,k)  # stl.fit function
ystar<-y-fit.y$stlfit$time.series[,"seasonal"] # seasonally adjusted (y*)  (Eq.2)
```

#### Step 2 - Detecting *breakpoints* (bp)

```R
min.h<-round(s/n.y,2) # max breaks (Eq. 3)
max.break<-ceiling(0.5/min.h) # min h (Eq. 4)
bpy<-breakpoints(ystar~1,h = min.h,breaks=max.break) # breakpoints() from package strucchange
```

#### step 3 - Detecting *relevant breakpoints* (bp*)

```R
bpy.star<-s.bp(ystar,bpy$breakpoints,al)
```

#### step 4 - Determining *Relative Magnitude of Change* (RMC) 

If bp*=NULL then stop otherwise do the following

```R
rmc<-RelMChange(ystar,bpy$breakpoints,bpy.star) (Eq. 5)
```


