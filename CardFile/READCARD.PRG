* READCARD.PRG - read in cardfile database
*
* Copyright 1993, Ted Roche
*
* Purpose: Read a Window CardFile, 
*          Write a DBF
* 

PRIVATE ALL LIKE L*

****************************************
* Select Input CardFile and Output DBF *
****************************************

lcCardFile = GETFILE("CRD","Read which cardfile?","Read",0)

IF EMPTY(lcCardFile) OR NOT FILE(lcCardFile)  && Cancel or no file
  RETURN
ENDIF
   
lcCardDBF = PUTFILE("Save As:", ;
                    STRTRAN(lcCardFile, "CRD", "DBF"), ;
                    "DBF")

IF EMPTY(lcCardDBF)  && an empty return -> cancel selected
  RETURN
ENDIF  

***************************
* Open the input Cardfile *
***************************

lnCardHandle = FOPEN(lcCardFile,0)
IF lnCardHandle = -1
  DO llError
ENDIF


***************************
* Create the output table *
***************************

CREATE TABLE (lcCardDBF) (Topic C(50),Contents M)

************************
* Read CardFile Header *
************************

IF FSEEK(lnCardHandle,0,0) # 0   && go to BOF
  DO llError
ENDIF
     
lcFileType = FREAD(lnCardHandle,3)
IF lcFileType # "MGC" AND lcFileType # "RRG"
  WAIT WINDOW lcCardFile + "is not a valid CardFile."
  =FCLOSE(lnCardHandle)
  RETURN
ENDIF

*********************************
* Calculate the number of cards *
*********************************

lbCardCnt = FREAD(lnCardHandle,2)   && # cards, binary
DO llError
lnCardCnt = ASC2Num(lbCardCnt)      && # cards, decimal

**************************
* Loop through the cards *
**************************

FOR lnCardNum = 1 TO lnCardCnt      && read in cards

  ***************************
  * Display a status window *
  ***************************

  WAIT WINDOW NOWAIT "Reading card #"+TRANSFORM(lnCardNum,"999")

  **************************
  * Position at the record *
  **************************

  lnPosition = 11 + 52 * (lnCardNum - 1)
  IF lnPosition # FSEEK(lnCardHandle,lnPosition,0)
    DO llError
  ENDIF
  
  ***************************************
  * The first 5 characters point to     *
  * the location of the card's contents *
  ***************************************

  lbContPtr = FREAD(lnCardHandle,5)   && offset,binary
  DO llError
  lnContPtr = Asc2Num(lbContPtr)     && offset, decimal

  ******************
  * Read the Topic *
  ******************

  lcTopic = FREAD(lnCardHandle,47)
  DO llError
  ln0End = AT(CHR(00),lcTopic)
  lcTopic = iif(ln0End=0,lcTopic,left(lcTopic,ln0End-1))

  *************************************
  * Reposition to the Contents & Read *
  *************************************

  IF lnContPtr+2 # FSEEK(lnCardHandle,lnContPtr+2,0)
     DO llError
  ENDIF
  lbContSize = FREAD(lnCardHandle,2)
  DO llError
  lnContSize = Asc2Num(lbContSize)
  IF lnContSize # 0
    lcContents = FREAD(lnCardHandle,lnContSize)
     DO llError
  ELSE
     lcContents = ""
  ENDIF         

  ****************************
  * Create the output record *
  ****************************

  INSERT INTO (lcCardDBF) ;
         (Topic    , ;
          Contents   ;
         ) VALUES    ;
         (lcTopic  , ;
          lcContents ;
         )
NEXT

=FCLOSE(lnCardHandle)

RETURN
