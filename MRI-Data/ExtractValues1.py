#--------------------------------------------------
# Description: Extrae valores grids MRI por puntos
# Author: Carlos Navarro
# Actualizado: 25/08/10
#--------------------------------------------------

import arcgisscripting, os, sys
gp = arcgisscripting.create(9.3)

if len(sys.argv) < 7:
	os.system('cls')
	print "\n Too few args"
	print "   - ie: python ExtractValues1.py E:\MRI_grids E:\MRI_Analysis\Extracted\Corpoica E:\MRI_grids\mask\Extract_MRI_Edwin\Points.shp 2015 2039 prec"
	sys.exit(1)

dirbase = sys.argv[1]
dirout = sys.argv[2]
if not os.path.exists(dirout):
	os.system('mkdir ' + dirout)
mask = sys.argv[3]
inityear = int(sys.argv[4])
finalyear = int(sys.argv[5])
variable = sys.argv[6]

os.system('cls')

print "\n"
print "~~~~~~~~~~~~~~~~~~~~"
print "   EXTRACT VALUES   "
print "~~~~~~~~~~~~~~~~~~~~"
print "\n"

for year in range(inityear, finalyear + 1, 1):

	for month in range (1, 12 + 1, 1):

		if month < 10 and gp.Exists(dirbase + "\\" + variable + "\\SN0A\\OUT_" + str(year) + "0" + str(month) + "010000"):
		
			gp.workspace = dirbase + "\\" + variable + "\\SN0A\\OUT_" + str(year) + "0" + str(month) + "010000"
			print "--->...processing : " + dirbase + "\\" + variable + "\\SN0A\\OUT_" + str(year) + "0" + str(month) + "010000"
			diroutraster = dirout + "\\" + variable + "\\SN0A\\OUT_" + str(year) + "0" + str(month) + "010000"
			if not os.path.exists(diroutraster):
				os.system('mkdir ' + diroutraster)
			
			# Get a list of grids in the workspace of each folder
			print "\t ..listing grids"
			dsList = gp.ListDatasets(variable + "*", "all")
			for ds in dsList:
			
				# Set local variables
				InPointsFC = mask 
				OutPointsFC = diroutraster + "\\" + ds

				# Check out Spatial Analyst extension license
				gp.CheckOutExtension("Spatial")

				print "\t ..extracting"
				# Process: Cell Statistics...
				gp.ExtractValuesToPoints_sa(InPointsFC, ds, OutPointsFC, "NONE", "VALUE_ONLY")
			
			print "\t ..done!!"

		if month > 9 and gp.Exists(dirbase + "\\" + variable + "\\SN0A\\OUT_" + str(year) + str(month) + "010000"):
		
			gp.workspace = dirbase + "\\" + variable + "\\SN0A\\OUT_" + str(year) + str(month) + "010000"
			print "--->...processing : " + dirbase + "\\" + variable + "\\SN0A\\OUT_" + str(year) + str(month) + "010000"

			diroutraster = dirout + "\\" + variable + "\\SN0A\\OUT_" + str(year) + str(month) + "010000"
			if not os.path.exists(diroutraster):
				os.system('mkdir ' + diroutraster)
			
			# Get a list of grids in the workspace of each folder
			print "\t ..listing grids"
			dsList = gp.ListDatasets(variable + "*", "all")
			for ds in dsList:
			
				# Set local variables
				InPointsFC = mask 
				OutPointsFC = diroutraster + "\\" + ds

				# Check out Spatial Analyst extension license
				gp.CheckOutExtension("Spatial")

				print "\t ..extracting"
				# Process: Cell Statistics...
				gp.ExtractValuesToPoints_sa(InPointsFC, ds, OutPointsFC, "NONE", "VALUE_ONLY")
			
			print "\t ..done!!"

print "Done!!!!"