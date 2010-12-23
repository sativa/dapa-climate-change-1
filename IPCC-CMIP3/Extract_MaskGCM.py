# ---------------------------------------------------------------------------------
# Author: Carlos Navarro
# Date: September 13th, 2010
# Purpose: Extraction by mask, diseggregated, interpolated or downscaled surfaces
# Note: If process is interrupted, you must be erase the last processed period
# ----------------------------------------------------------------------------------

import arcgisscripting, os, sys, string
gp = arcgisscripting.create(9.3)

#Syntax
if len(sys.argv) < 7:
	os.system('cls')
	print "\n Too few args"
	print "   - ie: python Extract_MaskGCM.py L:\climate_change\IPCC_CMIP3 A1B G:\IPCC_CMIP3\mask\Centroamerica.shp G:\IPCC_CMIP3 2_5min Disaggregated"
	print "   Syntax	: <Extract_MaskGCM.py>, <dirbase>, <scenario>, <mask>, <dirout>, <resolution>, <type>"
	print "   dirbase	: Root folder where are storaged the datasets"
	print "   scenario	: A1B, A2 or B1"
	print "	  mask		: shape with full path and extension"
	print "   dirout	: Out folder"
	print "   resolution: The possibilities are 2_5 min 5min 10min 30s"
	print "   type		: Disaggregated, Interpolated or Downscaled"	
	sys.exit(1)

#Set variables
dirbase = sys.argv[1]
scenario = sys.argv[2]
mask = sys.argv[3]
dirout = sys.argv[4]
resolution = sys.argv[5]
type = sys.argv[6]

os.system('cls')
gp.CheckOutExtension("Spatial")

print "~~~~~~~~~~~~~~~~~~~~~~"
print " EXTRACT BY MASK GCM  "
print "~~~~~~~~~~~~~~~~~~~~~~"

#Get lists 
periodlist = "2010_2039", "2020_2049", "2030_2059", "2040_2069", "2050_2079", "2060_2089", "2070_2099"
modellist = sorted(os.listdir(dirbase + "\\SRES_" + scenario + "\\" + type + "\\Global_" + str(resolution)))
print "Available models: " + str(modellist)

for model in modellist:
    for period in periodlist:

		#Set workspace
        gp.workspace = dirbase + "\\SRES_" + scenario + "\\" + type + "\\Global_" + str(resolution) + "\\" + model + "\\" + period
        print "\n---> Processing: " + dirbase + "SRES_" + scenario + "\\" + type + "\\Global_" + str(resolution) + "\\" + model + "\\" + period

        diroutraster = dirout + "\\SRES_" + scenario + "\\" + type + "\\Global_" + str(resolution) + "\\" + model + "\\" + period

        if not os.path.exists(diroutraster):
            os.system('mkdir ' + diroutraster)
			
			#Get a list of raster in workspace
            rasters = gp.ListRasters("", "GRID")
            for raster in rasters:
                print "    Extracting " + raster
                OutRaster = diroutraster + "\\" + raster
                gp.ExtractByMask_sa(raster, mask, OutRaster)
				
        else:
            print "The model " + model + " " + period + " is already processed"
            print "Processing the next period \n"

print "done!!!"    