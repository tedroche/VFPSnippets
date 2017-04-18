* LLError.PRG
* Low Level Error Handler
Private all like l*
if FERROR() # 0
  DO CASE  && Determine which error
    CASE FERROR() = 2
      lcReason = 'File not found'
    CASE FERROR() = 4
      lcReason = 'Too many files open (out of handles)'
    CASE FERROR() = 5
      lcReason = 'Access denied'
    CASE FERROR() = 6
      lcReason = 'Invalid file handle given'
    CASE FERROR() = 8
      lcReason = 'Out of memory'
    CASE FERROR() = 25
      lcReason = 'Seek error'
    CASE FERROR() = 29
      lcReason = 'Disk full'
    CASE FERROR() = 31
      lcReason = 'General Failure'
    OTHERWISE
      lcReason = 'Unknown LL error '+LTRIM(STR(FERROR()))
  ENDCASE
  *** Display the error ***
  WAIT WINDOW "Low level file error: "+ lcReason NOWAIT
  close all
  return to master
ENDIF
return

