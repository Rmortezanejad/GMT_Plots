#	SEPARATE THE NODAL PLANES GCMT DATA FILE
#	Author: Prithvi
#	Last Modified: 09-01-2017 11:37

from sys import argv
from io import StringIO
import numpy as np

#	Read from input file
dataA = np.genfromtxt('projection3.dat', usecols=(3,4,5))
dataB = np.genfromtxt('projection3.dat', usecols=(6,7,8))
dataC = np.zeros((2*len(dataA),3))

#	Change strike to the dip direction
for x in range(len(dataA)):
	dataA[x,0] = (dataA[x,0]+90) if (dataA[x,0]+90) < 360 else (dataA[x,0]+90-360)
	dataB[x,0] = (dataB[x,0]+90) if (dataB[x,0]+90) < 360 else (dataB[x,0]+90-360)

a = 0
b = 0
c = 0
while c < 2*len(dataA):
	if c%2 == 0:
		dataC[c,:] = dataA[a,:]
		a = a+1
		c = c+1
	else:
		dataC[c,:] = dataB[b,:]
		b= b+1
		c= c+1

#np.savetxt('Plane1.txt',dataA, fmt= '%1.0f',header= 'First plane')
#np.savetxt('Plane2.txt',dataB, fmt= '%1.0f',header= 'Second plane')
np.savetxt('PlaneB.txt',dataC, fmt= '%1.0f',header= 'Projection3: Both planes')
