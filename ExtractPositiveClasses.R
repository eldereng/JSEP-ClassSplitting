library(Hmisc)
library(dplyr)
library(data.table)

#The following file has the metrics for all classes per release ordered by class name and release
URIclassesAllReleases <- "MetricsPerClassReleaseOrdered.csv"
classesAllReleases <- read.csv(URIclassesAllReleases, header=TRUE, sep = ";")
classesAllReleases$SYSTEM <- as.character(classesAllReleases$SYSTEM)
classesAllReleases$CLASS <- as.character(classesAllReleases$CLASS)
classesAllReleases$RELEASE <- as.character(classesAllReleases$RELEASE)
# Calculate Deltas
classesAllReleases$nextClass <- Lag(classesAllReleases$CLASS, -1)
classesAllReleases$nextLCOM <- Lag(classesAllReleases$LCOM, -1)
classesAllReleases <- classesAllReleases[-nrow(classesAllReleases),]
deltas <- classesAllReleases[classesAllReleases$CLASS==classesAllReleases$nextClass,]
deltas$deltaLCOM <- deltas$nextLCOM - deltas$LCOM

# Check sizes
nrow(deltas)
length(which(deltas$deltaLCOM == 0)) 
length(which(deltas$deltaLCOM > 0)) 
length(which(deltas$deltaLCOM < 0))


negativeDeltas <- deltas[deltas$deltaLCOM < 0,]
absD <- abs(negativeDeltas$deltaLCOM)
DAM <- median(abs(absD-median(absD)))
LimiarD <- median(absD) + DAM
length(which(deltas$deltaLCOM > LimiarD))

setDT(deltas, keep.rownames = TRUE, key=c("SYSTEM", "CLASS", "RELEASE"))
deltasGTLimiarD <- deltas[deltas$deltaLCOM < -LimiarD,]
deltasGTLimiarD$absDeltaLCOM <- abs(deltasGTLimiarD$deltaLCOM)

#Select maximum absDeltLCOM for a class
# See example in https://www.r-bloggers.com/2019/09/selecting-the-max-value-from-each-group-a-case-study-dplyr-and-sparklyr/
classesDeltasGTLimiarD <-   deltasGTLimiarD %>% 
                                group_by(SYSTEM,CLASS) %>% 
                                arrange(desc(absDeltaLCOM)) %>% 
                                slice(1) %>% 
                                ungroup()

write.csv(classesDeltasGTLimiarD,'PositiveClasses.csv')




