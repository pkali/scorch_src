import sys
from string import strip

lineCount = 0
lengths = []
alltexts = []

for line in open("TALK1.txt"):
	lineCount+=1
	line = strip(line)
	lengths.append(len(line))
	alltexts.append(line)
off = lineCount

for line in open("TALK2.txt"):
	lineCount+=1
	line = strip(line)
	lengths.append(len(line))
	alltexts.append(line)

tmpNo = 0
for line in alltexts:
	print ("L"+str(tmpNo)+' dta "'+line+'"')
	tmpNo+= 1
l=""
for i in range(0,lineCount):
	l+="<L"+str(i)+","
l=l[:-1]
print ("OffensiveTextTableL")
print ("    dta "+l)
l=""
for i in range(0,lineCount):
	l+=">L"+str(i)+","
l=l[:-1]
print ("OffensiveTextTableH")
print ("    dta "+l)

l=""
for i in range(0,lineCount):
	l+=str(lengths[i])+","
l=l[:-1]
print ("OffensiveTextLengths")
print ("    dta "+l)


deff = lineCount-off
print ("NumberOfOffensiveTexts="+str(off))
print ("NumberOfDeffensiveTexts="+str(deff))
