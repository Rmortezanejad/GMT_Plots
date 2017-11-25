#!bin/bash

# Sumatra-Andaman map
#

# Things to do in terminal prior to plotting the data:
# 1. Figure out the xmin/xmax and ymin/ymax of the data sets by using the gmtinfo command
#    a. topography.xy - xmin = 0, xmax = 237.5, ymin = -18.98, ymax = 0
#    b. spectrum.xy - xmin = 0, xmax = 199.99390877, ymin = 6.53e-06, ymax = 0.8641337
# 2. Change the c-shell script to an executable file by using chmod +x fileName.csh

# Add preferences here
gmt gmtset FORMAT_GEO_MAP DD #set labels on the map to decimal degrees

gmt gmtset MAP_FRAME_TYPE fancy #make outline of the map a single line with ticks

gmt gmtset FONT_TITLE 24p #size of the title font

gmt gmtset MAP_TITLE_OFFSET -0.4c #offset the map title down by 0.4 cm

gmt gmtset FONT_LABEL 14p #size of the label fonts

gmt gmtset MAP_LABEL_OFFSET 0.3c #offset the labels up by 0.3 cm

gmt gmtset FONT_ANNOT_PRIMARY 12p #size of the primary annotation font

#set the -R flag: LONleft/LONright/ LATbottom/ LATtop
region="-R88/100/0/15"

#set the -J flag:
#-JM6i= mercator projection with longest axis=6 inches
#-JX7i/2i= XY projection 7 inches horizontal and 2 inches vertical 
#
projection="-JM4i"

#used with the opening/first postscript file
open="-K -V"

#used when adding to an existing postscript file
add="-O -K -V"

#used when adding the last object to postscript file
close="-O -V"

#output file names
psFile=$0.ps

pdfFile=$0.pdf
 topo=./ETOPO1_Bed_g_gmt4.grd


#Start code here
misc="-X5.5 -Y15" #Shift the map in the page
gmt psbasemap $region $projection -P -B2/2WSen $misc $open > $psFile
#-B flag parameters: -B20g10f5:"x-axis label":/5g2.5f1:"y-axis label"::."Title of Plot":WSen
# 20g10f5:"x-axis label": 
#					20 = label increment
#					g10 = grid spacing
#					f5 = small tick mark spacing
#					:"x-axis label": = name
#					/ separates x and y labelling scheme
# 5g2.5f1:"y-axis label":
#					5 = label increment
#					g2.5 = grid spacing
#					f1 = small tick mark spacing
#					:"y-axis label": = name
# :."Title of the  plot":
#
# WSen = how the axis is drawn. W = west, S = south, E = east, N = north.
# if the letter is capitalized gmt will add label axes, draw tick marks and corresponding outline.

#make color pallete
gmt makecpt -Crelief -T-8000/8000/500 -Z > topo.cpt

gmt grdgradient $topo -A135 -Ne0.8 -Gshadow.grd

gmt grdimage $topo $region $projection $add -Ctopo.cpt -Ishadow.grd >> $psFile

gmt pscoast $region $projection $add -W2 -Df -Na -Ia -Lf89.4/14/10/200+lkm >> $psFile

gmt makecpt -Crainbow -T0/50/10 -Z > seis.cpt

awk 'NR>18 {print($1,$2,$3)}' GCMT_psmeca.txt | psxy $region $projection $add -W.1 -Sc.2 -Cseis.cpt >> $psFile

psscale -D0/3.2/6/1 -B10:Depth:/:km: -Cseis.cpt $add >> $psFile

# View transect line 3
psxy $region $projection $add -W1 -Ss.2 -G255/0/0 <<END>> $psFile
94 3
96 1.5
98 0
END

psxy $region $projection $add -Wthin,red,- <<END>> $psFile
94 3
98 0
END

psxy $region $projection $add -Wthick,red <<END>> $psFile
95 0
98.3 4.7
END

pstext $region $projection $add -N -F+f12p,Helvetica-Bold,red <<END>> $psFile
98.5 5 14 0 5 MC (3)
END

#USE PSMECA AND PSVELOMECA TO GET A COMMON FILE WITH FOCAL MECHANISM AND LOCATION
join GCMT_psmeca.txt GCMT_psvelomeca.txt > temp1.txt
awk 'NR>34 {print($1,$2,$3,$15,$16,$17,$18,$19,$20)}' temp1.txt > temp2.txt

#PROJECT DATA
awk 'NR>18 {print($1,$2,$3,$4,$5,$6,$7,$8,$9)}' temp2.txt | project -C95/0 -E98.3/4.7 -W-1.2/1.2 -Lw > projection3.dat

rm -f temp1.txt temp2.txt

#MAKE SCATTER PLOT
region="-R94/100/-100/0"
projection="-JX4i/1.5i"
misc="-Y-5"
awk '{print($12,$3*(-1.0))}' projection3.dat | psxy $region $projection -B1:Longitude:/20:Depth:WSen -W1 -Sc.2 -G200 $misc $close >> $psFile


ps2pdf $psFile $pdfFile

see $pdfFile

echo "end of script"
