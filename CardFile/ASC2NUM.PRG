* Asc2Num   && Convert multi-character hi-byte, lo-byte to decimal
Parameter tcString
Private lnNum

* Trim off ending CHR(00)'s
do while right(tcString,len(tcString)) = chr(00)
   tcString = left(tcString,len(tcString)-1)
enddo

lnNum = 0
for i = len(tcString) to 1 step -1
	lnNum = lnNum + ASC(SUBSTR(tcString,i,1))*256^(i-1)
next
return lnNum    
