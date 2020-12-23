#install.packages("forecast",dependencies = TRUE)
#install.packages("strucchange",dependencies = TRUE)
#install.packages("trend",dependencies = TRUE)

library(forecast)
library(strucchange)
library(trend)

# the data
y<-RH1 # RH1,RH2,RH3,RH4,NRH1,NRH2,NRH3,Hotel
# specify the frequency  12 months
s<-12
# length y
n.y<-length(y)
# check outliers
rob.y<-test.Outliers.STL(y)

# step1: seasonal-trend decomposition based on Loess
# stl.fit
 k<-3 ## MAE according to function accuracy() package:forecast 
fit.y<-stl.fit(y,rob.y,k)

# y*  (Eq.2) seasonally adjusted
ystar<-y-fit.y$stlfit$time.series[,"seasonal"]

# step2: breakpoint analysis
### max breaks+min h  (Eqs. (3) and (4)) 
min.h<-round(s/n.y,2)
max.break<-ceiling(0.5/min.h)

bpy<-breakpoints(ystar~1,h = min.h,breaks=max.break)

# step3: select bp*
al<-0.05
bpy.star<-s.bp(ystar,bpy$breakpoints,al)

# step4: calculate RMC  Eq. (5)
# if bp* NULL then stop otherwise do the following
## magnitude
rmc<-RelMChange(ystar,bpy$breakpoints,bpy.star)
rmc


######################################################
#### table 1   obtain pvalues 
## RH1
# Breakpoints at observation number:
#  18 
# Corresponding to breakdates:
#  2012(6) 
## segment 1
aux<-bpy$breakpoints
trend::sens.slope(ystar[1:aux[1]])

## segment 2
trend::sens.slope(ystar[aux[1]:n.y])


