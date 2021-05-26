#install.packages("forecast",dependencies = TRUE)
#install.packages("strucchange",dependencies = TRUE)
#install.packages("trend",dependencies = TRUE)


library(forecast)
library(strucchange)
library(trend)

# load workspace
load("workspace_data_functions.RData")

# load the data into an array that we call loop over
labels<-list('RH1', 'RH2', 'RH3', 'RH4', 'NRH1', 'NRH2', 'NRH3', 'Hotel')
Y<-list(RH1, RH2, RH3, RH4, NRH1, NRH2, NRH3, Hotel)

# specify the frequency  12 months
s<-12

# set the level of significance
al<-0.05


for(i in 1:length(Y))
{

  # select the ith dataset
  y<-Y[[i]]
    
  # length y
  n.y<-length(y)
  
  # check outliers
  rob.y<-test.Outliers.STL(y)
  
  # step1: seasonal-trend decomposition based on Loess
  # stl.fit
  k<-3 ## MAE according to function accuracy() package:forecast but it could be k<-2 (RMSE) 
  fit.y<-stl.fit(y,rob.y,k)
  
  # y*  (Eq.2) seasonally adjusted
  ystar<-y-fit.y$stlfit$time.series[,"seasonal"]
  
  # step2: breakpoint analysis
  ### max breaks+min h  (Eqs. (3) and (4)) 
  min.h<-round(s/n.y,2)
  max.break<-ceiling(0.5/min.h)
  
  bpy<-breakpoints(ystar~1,h = min.h,breaks=max.break)
  
  ######################################################################################
  #### table 1: breakpoints and slope (p-value) for each segment (between two breakpoints)
  
  aux<-bpy$breakpoints
  
  # compute breakpoint dates
  barray = c()
  for(a in aux){
    barray <- append(barray, paste0(floor(time(y)[a]),'(',month.abb[round(((time(y)[a] %% 1)*12) + 1)],')'))
    }
  
  # add beginning and end indices so we can loop over segments
  aux = c(1, aux, n.y)
  
  # save the breakdates to the output string
  output <- paste0(barray, collapse=',') 
  output <- paste0(output, ' |')
  
  output.seg<-NULL
  # loop over each segment and save the results to the output string
  for(ai in 1:(length(aux)-1)){
    
    seg<-trend::sens.slope(ystar[aux[ai]:aux[ai+1]])
    
    # append the segment data
    output.seg<-paste(output.seg,'Segment', ai ,' |')
    output<-paste(output, 
          paste0(round(seg[["estimates"]][["Sen's slope"]], 2), '(',round(seg[["p.value"]], 4),')', ' |'))
    }

   ### table 2 (append to table 1): relevant breakpoints and RMC
  
  # step3: select bp*
  bpy.star<-s.bp(ystar,bpy$breakpoints,al)
  
  if(is.null(bpy.star)) {
    output2<-paste("No relevant breakpoints", ' |')
} else {
  aux2<-bpy.star
  
  # compute breakpoint dates
  barray = c()
  for(a in aux2){
    barray <- append(barray, paste0(floor(time(y)[a]),'(', month.abb[round(((time(y)[a] %% 1)*12) + 1)], ')'))
    }
  
  # save the breakdates to the output string
  output2 <- paste0(barray, collapse=',') 

  # step4: calculate RMC  Eq. (5)
    rmc<-RelMChange(ystar,bpy$breakpoints,bpy.star)
  
  output.rmc<-c()
  for(ai in 1:length(rmc)){
    output.rmc<-paste(output.rmc, 
                  paste0(round(rmc[ai], 2), ' |'))
  }
  output2<-paste(output2, ' |', output.rmc)
  }
  
  
print(paste('Type | Breakpoints |',output.seg, '| Relevant bp | RMC '))
  
print(paste(labels[i], ' |',output, ' |', output2))
  
}





