#-----------------------------------------------------------------------
# Author: Carlos Navarro
# CIAT-CCAFS
# c.e.navarro@cgiar.org
#-----------------------------------------------------------------------

require(maptools)
require(raster)
require(ncdf)
require(rgdal)
require(sp)
# rcpList <- c("rcp26", "rcp45", "rcp60", "rcp85")


### Parameters ###

# rcp <- "rcp26"
# rcp <- "rcp45"
# rcp <- "rcp60"
# rcp <- "rcp85"
# ens <- "r1i1p1"
# basePer <- "1961_1990"

# 
# otp <- GCMTmpCalc(rcp, baseDir)
# otp <- GCMAverage(rcp, baseDir)
# otp <- GCMAnomalies(rcp, baseDir, ens, basePer)
# otp <- GCMSummary(baseDir, ens)
# 
# basePer <- "1975s"
# basePer <- "1985s"
# otp <- GCMEnsembleAnom(baseDir, ens, basePer)
# 
# imageDir <- "T:/gcm/cmip5/baseinfo/inventory"
# baseDir <- "T:/gcm/cmip5/raw/monthly"
# ens <- "r1i1p1"
# otp <- GCMVerification(baseDir, ens, imageDir)
# otp <- GCMAnomaliesYearly(rcp, baseDir, ens, basePer, outDir)


#####################################################################################################
# Description: This function is to calculate the averaging surfaces of the CMIP5 monhtly climate data
#####################################################################################################

# source("00-monthly-data-functions-mod1.R")
# rcp <- "historical"
# scrDir <- "G:/_scripts/dapa-climate-change/IPCC-CMIP5/data"
# baseDir <- "T:/gcm/cmip5/raw/monthly"
# otp <- GCMAverage(rcp, baseDir, scrDir)

GCMAverage <- function(rcp='rcp26', baseDir="T:/gcm/cmip5/raw/monthly", scrDir="G:/_scripts/dapa-climate-change/IPCC-CMIP5/data") {
  
  cat(" \n")
  cat("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX \n")
  cat("XXXXXXXXXX GCM AVERAGE CALCULATION XXXXXXXXX \n")
  cat("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX \n")
  cat(" \n")
  
  ens <- "r1i1p1"
  
  # Read gcm characteristics table
  gcmStats <- read.table(paste(scrDir, "/cmip5-", rcp, "-monthly-data-summary.txt", sep=""), sep="\t", na.strings = "", header = TRUE)
  
  # Get a list of month with and withour 0 in one digit numbers
  monthList <- c(paste(0,c(1:9),sep=""),paste(c(10:12)))
  monthListMod <- c(1:12)
  
  # Set number of days by month
  ndays <- c(31,28,31,30,31,30,31,31,30,31,30,31)
  
  # Combirn number of month and days in one single data frame
  ndaymtx <- as.data.frame(cbind(monthList, ndays, monthListMod))
  names(ndaymtx) <- c("Month", "Ndays", "MonthMod")

  # List of variables to average
  varList <- c("prec", "tmax", "tmin")
  
  # Get gcm statistics
  dataMatrix <- c("rcp", "model", "xRes", "yRes", "nCols", "nRows", "xMin", "xMax", "yMin", "yMax")
  
  # Loop around gcms and ensembles
  for (i in 1:nrow(gcmStats)){
  
    # Don't include variables without all three variables
    if(!paste(as.matrix(gcmStats)[i,10]) == "ins-var") {
      
      if(!paste(as.matrix(gcmStats)[i,10]) == "ins-yr"){
        
        if(paste(as.matrix(gcmStats)[i,3]) == "r1i1p1"){
        # Get gcm and ensemble names

        gcm <- paste(as.matrix(gcmStats)[i,2])
        
        # Path of each ensemble
        ensDir <- paste(baseDir, "/", rcp, "/", gcm, "/", ens, sep="")
        
        # Directory with monthly splitted files
        mthDir <- paste(ensDir, "/monthly-files", sep="")
        
        # Create output average directory
        avgDir <- paste(ensDir, "/average", sep="")
        if (!file.exists(avgDir)) {dir.create(avgDir)}
        
        # Period list for historical and future pathways
        if (rcp == "historical"){
          
#           periodList <- c("1961", "1971", "1981")
          period <- "1981"
        } else {
          
          periodList <- c("2020", "2030", "2040", "2050", "2060", "2070")
          
        }
        
        # Loop around periods
#         for (period in periodList) {
          
          # Define start and end year
          staYear <- as.integer(period)
          endYear <- as.integer(period) + 24
          
          cat("\nAverage over: ", rcp, " ", gcm, " ", ens, " ", paste(staYear, "_", endYear, sep="")," \n\n")
  
          # Loop around variables
          for (var in varList) {
            
            # Loop around months
            for (mth in monthList) {
              
              if (!file.exists(paste(avgDir, "/", staYear, "_", endYear, sep=""))) 
              {dir.create(paste(avgDir, "/", staYear, "_", endYear, sep=""))}
              
              # Define month without 0 in one digit number
              mthMod <- as.numeric(paste((ndaymtx$MonthMod[which(ndaymtx$Month == mth)])))
              outNcAvg <- paste(avgDir, "/", staYear, "_", endYear, "/", var, "_", mthMod, ".nc", sep="")
              
              if (!file.exists(outNcAvg)){
                
                # List of NetCDF files by month for all 30yr period
                mthNc <- lapply(paste(mthDir, "/", staYear:endYear, "/", var, "_", mth, ".nc", sep=""), FUN=raster)
                
                # Create a stack of list of NC, rotate and convert units in mm/monnth and deg celsious
                if (var == "prec"){
                  
                  daysmth <- as.numeric(paste((ndaymtx$Ndays[which(ndaymtx$Month == mth)])))
                  mthNcAvg <- rotate(mean(stack(mthNc))) * 86400 * (daysmth)
                  
                } else {
                  
                  mthNcAvg <- rotate(mean(stack(mthNc))) - 272.15
                }
                
                # Write output average NetCDF file
                mthNcAvg <- writeRaster(mthNcAvg, outNcAvg, format='CDF', overwrite=T)
              
                cat(" .> ", paste(var, "_", mthMod, sep=""), "\tdone!\n")
              
              } else {cat(" .>", paste(var, "_", mthMod, sep=""), "\tdone!\n")}
              
              }
            }
#           
#           if(ens == "r1i1p1") {
#           
#             # Get a table with resolution and extent by model
#             exNc <- raster(paste(avgDir, "/", staYear, "_", endYear, "/prec_1.nc", sep=""))
#             
#             xRes <- xres(exNc)
#             yRes <- yres(exNc)
#             nCols <- ncol(exNc)
#             nRows <- nrow(exNc)
#             xMin <- xmin(exNc)
#             xMax <- xmax(exNc)
#             yMin <- ymin(exNc)
#             yMax <- ymax(exNc)
#             
# #             gcmChart <- cbind(rcp, gcm, xRes, yRes, nCols, nRows, xMin, xMax, yMin, yMax)
#             
#             dataMatrix <- rbind(dataMatrix,c(rcp, gcm, xRes, yRes, nCols, nRows, xMin, xMax, yMin, yMax))
#             
#             }
#           }
      }
        }
      }
    
      
    }
  
#   write.csv(dataMatrix, paste(baseDir, "/", rcp, "-gcm-chart.csv", sep=""), row.names=F)
  cat("GCM Average Process Done!")
  
  }

#################################################################################################################
# Description: This function is to calculate the anomalies of averaged surfaces of the CMIP5 monhtly climate data
#################################################################################################################


# rcp <- "rcp26"
# rcp <- "rcp45"
# rcp <- "rcp85"

# rcp <- "rcp85"
# baseDir="T:/gcm/cmip5/raw/monthly"
# ens="r1i1p1"
# basePer <- "1981_2005"
# oDir="G:/cenavarro/ecu-hidroelectrica/anomalies_cmip5"
# bbox <- "G:/cenavarro/ecu-hidroelectrica/02_baseline/_region/alt-prj-ecu.asc"
# otp <- GCMAnomalies(rcp, baseDir, ens, basePer, oDir, bbox)

GCMAnomalies <- function(rcp='rcp26', baseDir="T:/gcm/cmip5/raw/monthly", ens="r1i1p1", basePer="1981_2005", oDir="G:/cenavarro/ecu-hidroelectrica/anomalies_cmip5", bbox="G:/cenavarro/ecu-hidroelectrica/02_baseline/_region/alt-prj-ecu.asc.asc") {
  
  cat(" \n")
  cat("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX \n")
  cat("XXXXXXXXX GCM ANOMALIES CALCULATION XXXXXXXX \n")
  cat("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX \n")
  cat(" \n")

  # List of variables and months
  varList <- c("prec", "tmax", "tmin")
  monthList <- c(1:12)
  
  curDir <- paste(baseDir, "/historical", sep="")
  futDir <- paste(baseDir, "/", rcp, sep="")
  
  bbox <- raster(bbox)
  extbbox <- extent(bbox)
    
  gcmList <- list.dirs(curDir, recursive = FALSE, full.names = FALSE)
  
#   dataMatrix <- c("gcm", "period", "var_mth", "value_st_1")
  
  for (gcm in gcmList) {
    
    # Get gcm names    
    gcm <- basename(gcm)

    # Path of each ensemble
    curEnsDir <- paste(curDir, "/", gcm, "/", ens, sep="")
    
    # Average directory
    curAvgDir <- paste(curEnsDir, "/average/", basePer, sep="")
    
    if (file.exists(curAvgDir)){
      
      periodList <- c("2020", "2040", "2070")
  
      for (period in periodList) {
        
      # Define start and end year
      staYear <- as.integer(period)
      endYear <- as.integer(period) + 29
    
      futAvgDir <- paste(futDir, "/", gcm, "/", ens, "/average/", staYear, "_", endYear, sep="")
        
      if (file.exists(futAvgDir)){
        
        if (file.exists(curAvgDir)){
          
          cat("\t Anomalies over: ", rcp, " ", gcm, " ", ens, " ", paste(staYear, "_", endYear, sep="")," \n\n")
          
          # Create anomalies output directory 
          if (basePer == "1961_1990"){

            anomDir <- paste(futDir, "/", gcm, "/", ens, "/anomalies_1975s", sep="")
            anomPerDir <- paste(futDir, "/", gcm, "/", ens, "/anomalies_1975s/", staYear, "_", endYear, sep="") 
            
          } else if (basePer == "1971_2000") {
            
            anomDir <- paste(futDir, "/", gcm, "/", ens, "/anomalies_1985s", sep="")
            anomPerDir <- paste(futDir, "/", gcm, "/", ens, "/anomalies_1985s/", staYear, "_", endYear, sep="")
           
          } else if (basePer == "1981_2005") {
            
            anomDir <- paste(futDir, "/", gcm, "/", ens, "/anomalies_1995s", sep="")
            anomPerDir <- paste(futDir, "/", gcm, "/", ens, "/anomalies_1995s/", staYear, "_", endYear, sep="")
            oDirPer <- paste(oDir, "/",rcp, "/",gcm, "/", ens, "/anomalies_1995s/", staYear, "_", endYear, sep="")
            oDirPerRes <- paste(oDir, "_res/", rcp, "/",gcm, "/", staYear, "_", endYear, sep="")
          }
          
          
          if (!file.exists(anomDir)) {dir.create(anomDir)}
          if (!file.exists(anomPerDir)) {dir.create(anomPerDir)}
          if (!file.exists(oDirPer)) {dir.create(oDirPer, recursive=T)}
          if (!file.exists(oDirPerRes)) {dir.create(oDirPerRes, recursive=T)}
        
          # Loop around variables
          for (var in varList) {
            
            # Loop around months
            for (mth in monthList) {
              
              
              outNc <- paste(anomPerDir, "/", var, "_", mth, ".nc", sep="")
              if (!file.exists(outNc)) {
              
                curAvgNc <- raster(paste(curAvgDir, "/", var, "_", mth, ".nc", sep=""))
                futAvgNc <- raster(paste(futAvgDir, "/", var, "_", mth, ".nc", sep=""))
                
                anomNc <- futAvgNc - curAvgNc
                anomNc <- writeRaster(anomNc, outNc, format='CDF', overwrite=FALSE)
              }
              
              
              outNcRes <- paste(oDirPerRes, "/", var, "_", mth, ".nc", sep="")
              if (!file.exists(outNcRes)) {
                
                system(paste("cdo sellonlatbox,",extbbox@xmin-5,",",extbbox@xmax+5,",",extbbox@ymin-5,",",extbbox@ymax+5," ", outNc, " ", oDirPer, "/", var, "_", mth, ".nc", sep=""))
                
                anomNc <- raster(paste(oDirPer, "/", var, "_", mth, ".nc", sep=""))
                
                # resAnomNc  <- resample(anomNc, rs, method='ngb')
                # anomNcExt <- setExtent(anomNc, extbbox, keepres=TRUE, snap=FALSE)
                resAnomNcExt  <- resample(anomNc, bbox, method='bilinear')
                resAnomNcExt <- writeRaster(resAnomNcExt, outNcRes, format='CDF', overwrite=FALSE)
                
#                 coordinates <- read.csv(stFile)[2:3]
#                 stId <- read.csv(stFile)[1]
#                 
#                 coords <- data.frame(coordinates$longitude[st],coordinates$latitude[st])
#                 value <- extract(resAnomNcExt, coords)
#                 
#                 dataMatrix <- rbind(dataMatrix,c(gcm, paste(staYear, "_", endYear, sep=""), paste(var, "_", mth, sep=""), value)) 
                
              }
#               write.csv(dataMatrix, paste(outFolder, "/", paste(stId$station[st]), ".csv", sep=""), row.names=F)
              
#               
#               outShp <- paste(anomPerDir, "/", var, "_", mth, ".shp", sep="")
#               
#               if (!file.exists(outShp)) {
#                 
#                 anomPts <- rasterToPoints(raster(outNc)) 
#                 
#                 coords <- data.frame(anomPts[,1:2])
#                 colnames(coords) <- c("LON", "LAT")
#                 
#                 values <- data.frame(anomPts[,3])
#                 colnames(values) <- c("VALUE")
#                 
#                 anomPts <- SpatialPointsDataFrame(coords,values)
#                 anomShp <- writePointsShape(anomPts, paste(anomPerDir, "/", var, "_", mth, sep=""))
#                 
#                 cat(" .> Anomalies ", paste("\t ", var, "_", mth, sep=""), "\tdone!\n")
#               
#               } else {cat(" .> Anomalies ", paste("\t ", var, "_", mth, sep=""), "\tdone!\n")}
#               
            }    
          } 
        }  
      }  
    }
      
    }
    
  }
  cat("GCM Anomalies Process Done!")
}


#####################################################################################################
# Description: This function is to extract values of the anomalies
#####################################################################################################
# source("00-monthly-data-functions-mod1.R")
# rcp='rcp26'
# baseDir="G:/cenavarro/ecu-hidroelectrica/anomalies_cmip5_res"
# outfile="G:/cenavarro/ecu-hidroelectrica/extract_values_anomalies_res"
# stFile="G:/cenavarro/ecu-hidroelectrica/extract_values_anomalies_res/st_for_extract.csv"
# otp <- ExtractValuesAnomalies(rcp, baseDir, outfile,stFile)
# 


ExtractValuesAnomalies <- function(rcp='rcp26', baseDir="G:/cenavarro/ecu-hidroelectrica/anomalies_cmip5_res", outfile="G:/cenavarro/ecu-hidroelectrica/extract_values_anomalies_res",stFile="G:/cenavarro/ecu-hidroelectrica/extract_values_anomalies_res/st_for_extract.csv") {
  
  gcmList <- list.dirs(paste(baseDir,'/',rcp,sep=''), recursive = FALSE, full.names = FALSE)
  
  periodList <- c("2020_2049", "2040_2069", "2070_2099")
  
  stId <- read.csv(stFile)[1]
  stList <- c("M142" ,"M143" ,"M144" ,"M147" ,"M149" ,"M189" ,"M190" ,"M207" ,"M241" ,"M33" ,"M420" ,"M422" ,"M432" ,"M433" ,"M503" ,"M506" ,"M542" ,"M761" ,"MNUE1" ,"MNUE2" ,"M543" ,"M759")
  dataMatrix <- c("gcm", "period", "var_mth", stList)
  
  coordinates <- read.csv(stFile)[2:3]
  names(coordinates) <- c("lon", "lat")
    
  for (period in periodList) {
    
    for (gcm in gcmList) {
      cat(paste("\t Extracting: ", rcp, " ", basename(gcm), " ", period, sep="")," \n")
    
      # Get gcm names    
      gcm <- basename(gcm)  
    
      nclist <- list.files(paste(baseDir,'/',rcp,'/',gcm,'/',period,sep=''),full.names=T, recursive = FALSE,pattern='.nc')
      
      for (nc in nclist) {
        
        var <- basename(nc)
        var <- gsub(".nc",'',var)

#         for (st in 1:nrow(stId)){
        
#         coords <- data.frame(coordinates$lon[st],coordinates$lat[st])
        value <- extract(raster(nc), coordinates)
        
        dataMatrix <- rbind(dataMatrix,c(gcm, period, var, value)) 

#       }
     }
    }
  }
  
  write.csv(dataMatrix, file = paste(outfile, "/", rcp, "_extract_values.csv", sep=""), row.names=F)
  cat("Extract Done!")
}

