      SUBROUTINE PACK(KFILDO,IC,NXY,IS0,IS1,IS2,IS4,ND7,
     1               IPACK,ND5,SECOND,IFIRST,IFOD,MISSP,MISSS,
     2               MINPK,LX,IOCTET,L3264B,IER)
C
C        JANUARY   1995   GLAHN   TDL   MOS-2000
C        JULY      1996   GLAHN   ADDED MISSS AND GRIDLENGTH WORD SIZE
C        MAY       1997   GLAHN   RESTURCTURED FOR PKC4LX, PKS4LX, ETC.
C                                 MAXA ELIMINATED 
C        JUNE      1997   GLAHN   INITIALIZATION OF TDLP AND C7777 MOVED
C                                 TO DATA STATEMENT AND /D ELIMINATION
C        MARCH     2000   DALLAVALLE   MODIFIED FORMAT STATEMENTS TO 
C                                 CONFORM TO FORTRAN 90 STANDARDS
C                                 ON THE IBM-SP
C        SEPTEMBER 2001   GLAHN   INSERTED DIAGNOSSTIC FORMAT 100
C        SEPTEMBER 2001   GLAHN   INCREASED NDG TO 45000
C        JUNE      2002   GLAHN   ADDED MERCATOR IS2(2)=7 CAPABILITY
C        JULY      2012   ENGLE   INCREASED NDG TO 65535
C        OCTOBER   2012   ENGLE   ADDED LOGIC TO INITIALIZE OF TDLP
C                                 ACCORDING TO THE ENDIANNESS OF THE
C                                 SYSTEM. THIS IS ENSURE A BIG-ENDIAN
C                                 TDLPACK RECORD ON A LITTLE-ENDIAN SYSTEM.
C           
C        PURPOSE 
C            SUBROUTINE TO PACK DATA AT "UNITS" RESOLUTION PROVIDED IN
C            IC( ) FOR MOS-2000.  NORMALLY CALLED BY PACK1D OR PACK2D.
C            THE SMALLEST VALUE IS SUBTRACTED TO MAKE ALL VALUES POSITIVE. 
C            ADDITIONAL VALUES ARE TAKEN OUT AT NONUNIFORM STEPS WITH
C            A MINIMUM GROUP SIZE OF MINPK.  IF 2ND ORDER DIFFERENCES
C            ARE TO BE PACKED, THEY ARE ALREADY IN IC( ).  VARIABLES
C            LBIT( ), JMAX( ), JMIN)( ), NOV( ) AND THEIR DIMENSION
C            NDG ARE NOT CARRIED AS ARGUMENTS TO MAKE FOR EASE OF USE.
C            IF NDG IS NOT SUFFICIENT FOR A PARTICULAR SITUATION,
C            THE WORKING COPY OF MINPK IS INCREASED BY 50 PERCENT
C            UNTIL NDG IS BIG ENOUGH; IN THIS CASE A DIAGNOSTIC IS
C            PRINTED.
C
C        DATA SET USE 
C           KFILDO - UNIT NUMBER FOR OUTPUT (PRINT) FILE. (OUTPUT) 
C
C        VARIABLES 
C              KFILDO = UNIT NUMBER FOR OUTPUT (PRINT) FILE.  (INPUT) 
C               IC(K) = HOLDS VALUES TO PACK (K=NXY).  (INPUT)
C                 NXY = THE NUMBER OF VALUES IN IC( ).  ALSO USED AS
C                       THE DIMENSION OF IC( ).  (INPUT)
C              IS0(L) = HOLDS THE VALUES FOR GRIB SECTION 0 
C                       (L=1,3).  NOT ACTUALLY USED.  SECTION 0 IS
C                       CONSTANT FOR THIS PACKER.
C              IS1(L) = HOLDS THE VALUES FOR GRIB SECTION 1 
C                       (L=1,MAX OF ND7).  ALL VALUES ARE INPUT
C                       EXCEPT IS1(1) WHICH IS RETURNED AS THE SECTION
C                       LENGTH IN BYTES.  (INPUT-OUTPUT)
C              IS2(L) = HOLDS THE VALUES FOR GRIB SECTION 2 
C                       (L=1,12).  ALL VALUES ARE INPUT 
C                       EXCEPT IS2(1) WHICH IS RETURNED AS THE SECTION
C                       LENGTH IN BYTES.  THE CONTENTS OF THIS VARIABLE
C                       ARE NOT USED WHEN BIT 8 IN IS1(2) = 0.  
C                       (INPUT-OUTPUT)
C              IS4(L) = HOLDS THE VALUES FOR GRIB SECTION 4 
C                       (L=1,7).  ONLY IS4(2) IS INPUT, AND IT MAY BE
C                       MODIFIED.  IS4(1) IS RETURNED AS THE SECTION
C                       LENGTH IN BYTES.  NOTE THAT BIT 5 OF IS4(2) IS
C                       IGNORED, BECAUSE THIS ROUTIINE DOES NOT SUPPORT
C                       "SIMPLE" PACKING; GROUPS ARE ALWAYS USED.
C                       BIT 4 IN IS4(2) IS NOT USED BECAUSE GRIDPOINT
C                       DATA ARE PACKED IN THE SAME MANNER AS NON-
C                       GRIDPOINT DATA, ONCE BIT 6 OF IS4(2) HAS BEEN
C                       CONSIDERED.  (INPUT-OUTPUT)
C                 ND7 = DIMENSION OF IS0( ), IS1( ), IS2( ), AND IS4( ).
C                       (INPUT)
C            IPACK(J) = THE ARRAY TO HOLD THE ACTUAL PACKED MESSAGE
C                       (J=1,MAX OF ND5).  (OUTPUT)
C                 ND5 = THE SIZE OF THE ARRAY IPACK( ).  (INPUT)
C              SECOND = TRUE WHEN 2ND ORDER DIFFERENCES ARE TO BE
C                       PACKED.  FALSE OTHERWISE.  (LOGICAL)  (INPUT)  
C              IFIRST = WHEN SECOND IS TRUE, IFIRST IS THE FIRST VALUE
C                       IN THE FIELD.  IT IS TO BE USED ONLY WHEN SECOND
C                       ORDER DIFFERENCES ARE PACKED.
C                IFOD = WHEN SECOND IS TRUE, IFOD IS THE FIRST FIRST ORDER
C                       DIFFERENCE.  IT IS TO BE USED ONLY WHEN SECOND
C                       ORDER DIFFERENCES ARE PACKED.
C               MISSP = WHEN MISSING POINTS CAN BE PRESENT IN THE DATA,
C                       THEY WILL HAVE THE VALUE MISSP OR MISSS.  MISSP
C                       IS THE PRIMARY MISSING VALUE AND IS USUALLY 
C                       9999*100000 (PACK1D OR PACK2D HAVE MULTIPLIED
C                       9999 BY 10000), AND 9999 IS HARDCODED IN SOME
C                       SOFTWARE.  MISSS IS THE SECONDARY MISSING VALUE
C                       AND ACCOMMODATES THE 9997 PRODUCED BY SOME
C                       EQUATIONS FOR MOS FORECASTS.  PACK1D OR PACK2D 
C                       HAVE MULTIPLIED 9997 X 10000 FOR PACKING.
C                       MISSP = 0 INDICATES THAT NO MISSING
C                       VALUES (EITHER PRIMARY OR SECONDARY) ARE PRESENT.
C                       MISSS = 0 INDICATES THAT NO SECONDARY MISSING
C                       VALUES ARE PRESENT.
C                       (INPUT)
C               MISSS = SECONDARY MISSING VALUE INDICATOR (SEE MISSP).
C                       MISSS IS PUT INTO IS4(5); REFERRING TO IT THIS 
C                       WAY IS MORE UNDERSTANDABLE.  (INPUT)
C               MINPK = VALUES ARE PACKED IN GROUPS OF MINIMUM SIZE
C                       MINPK.  ONLY WHEN THE NUMBER OF BITS TO HANDLE
C                       A GROUP CHANGES WILL A NEW GROUP BE FORMED.  (INPUT)
C                  LX = THE NUMBER OF GROUPS (THE NUMBER OF 2ND ORDER 
C                       MINIMA).  WHILE NEEDED ONLY INTERNALLY, IT IS
C                       OUTPUT IN THE ARGUMENT LIST IN CASE THE USER
C                       WANTS TO KNOW IT.  (OUTPUT)  
C              IOCTET = THE TOTAL MESSAGE SIZE IN OCTETS (BYTES).  (OUTPUT)
C              L3264B = INTEGER WORD LENGTH OF MACHINE BEING USED.  
C                       A WORKING COPY N = L3264B FOR USE IN CALLS TO PKBG.
C                       (INPUT)
C                 IER = RETURN STATUS CODE.  MOST VALUES ARE RETURNED FROM
C                       SUBROUTINE PKBG.  OTHERWISE,
C                        0 = GOOD RETURN.
C                       18 = MAP PROJECTION INDICATED IN IS2(2) IS NOT
C                            LAMBERT (3), POLAR STEREOGRAPHIC (5) OR
C                            MERCATOR (7) WHEN THE DATA ARE GRIDPOINT
C                            AND SECTION 2 IS TO BE INCLUDED.
C                       19 = A SECTION 3 IS INDICATED, BUT THIS EDITION
C                            DOES NOT SUPPORT IT.
C                       (OUTPUT)  
C             LBIT(M) = THE NUMBER OF BITS NECESSARY TO HOLD THE
C                       PACKED VALUES FOR EACH GROUP M (M=1,LX). 
C                       (INTERNAL)
C             JMAX(M) = THE MAXIMUM OF EACH GROUP M OF PACKED VALUES
C                       AFTER SUBTRACTING THE GROUP MINIMUM VALUE
C                       (M=1,LX).  (INTERNAL)
C             JMIN(M) = THE MINIMUM VALUE SUBTRACTED FOR EACH GROUP
C                       M (M=1,LX).  (INTERNAL)
C              NOV(M) = THE NUMBER OF VALUES IN GROUP M (M=1,LX).
C                       (INTERNAL)
C                 NDG = DIMENSION OF LBIT( ), JMAX( ), JMIN( ), AND
C                       NOV( ).  SET BY PARAMETER.  A PARAMETER IS
C                       USED HERE SO THAT THE USER WILL NOT HAVE TO 
C                       DEFINE AND CARRY THIS VALUE AND ALL THE ASSOCIATED
C                       ARRAYS.  THE AMOUNT OF STORAGE IS NOT LARGE, AND
C                       IF THE VALUE USED IS NOT LARGE ENOUGH, IT CAN
C                       BE INCREASED WITHOUT AFFECTING PREVIOUS PACKING.
C                MINA = THE MINIMUM VALUE IN IC( ) BEFORE
C                       SUBTRACTING THE MINIMUM VALUE.  (INTERNAL)
C                IBIT = THE NUMBER OF BITS REQUIRED TO PACK THE GROUP
C                       MINIMUM VALUES IN JMIN( ).  (INTERMAL)   
C                KBIT = THE NUMBER OF BITS REQUIRED TO PACK THE MINIMUM
C                       VALUES OF THE GROUPS.  (INTERNAL)
C             LBIT( ) = THE NUMBER OF BITS REQUIRED TO PACK THE VALUES
C                       IN EACH GROUP (M=1,LX).)  (INTERNAL)
C                MBIT = THE NUMBER OF BITS REQUIRED TO PACK THE
C                       GROUP SIZES.  (INTERNAL)   
C                JBIT = THE NUMBER OF BITS REQUIRED TO PACK THE
C                       ABSOLUTE VALUE OF THE FIRST FIRST ORDER     
C                       DIFFERENCE.  USED ONLY WHEN PACKING SECOND ORDER
C                       DIFFERENCES.
C                NBIT = THE NUMBER OF BITS REQUIRED TO PACK THE
C                       ABSOLUTE VALUE OF THE MINIMUM SECOND ORDER  
C                       DIFFERENCE.  USED ONLY WHEN PACKING SECOND ORDER
C                       DIFFERENCES.
C               C7777 = HOLDS '7777'.  EQUIVALENCED TO I7777 FOR
C                       PROVISION TO SUBROUTINE PKBG AS AN INTEGER.
C                       (INTERNAL)  (CHARACTER*4)
C               I7777 = SEE C7777.  (INTERNAL) 
C               IFILL = NUMBER OF BITS TO PAD MESSAGE (AT THAT POINT
C                       IN THE PROCESS) TO AN EVEN OCTET.  (INTERNAL)
C              MOCTET = NUMBER OF OCTETS CALCULATED FOR LENGTH OF
C                       SECTIONS, ETC.  (INTERNAL)
C                TDLP = 4 CHARACTERS 'TDLP'.  EQUIVALENCED TO ITDLP
C                       FOR FURNISHING TO ROUTIINE BGPK.  (CHARACTER)
C                       (INTERNAL)
C               ITDLP = SEE TDLP.  (INTERNAL)
C               STATE = HOLDS 4 CHARACTERS FOR PRINTOUT IN CASE OF
C                       ERROR.  (INTERNAL)  (CHARACTER*4)
C                   N = WORKING COPY OF L3264B.  (INTERNAL)
C        1         2         3         4         5         6         7 X
C
C        NON SYSTEM SUBROUTINES CALLED 
C           PKBG, PKMS00, PKMS99, PKC4LX, PKS4LX, CKSYSEND
C
      PARAMETER (NDG=65535)
C
      CHARACTER*4 TDLP,C7777
      CHARACTER*4 STATE
C
      LOGICAL SECOND
C
      DIMENSION IC(NXY)
      DIMENSION IPACK(ND5)
      DIMENSION IS0(ND7),IS1(ND7),IS2(ND7),IS4(ND7) 
      DIMENSION JMAX(NDG),JMIN(NDG),NOV(NDG),LBIT(NDG)
      EQUIVALENCE (C7777,I7777),(TDLP,ITDLP)
C
      DATA IZERO/0/
      DATA IVERSN/0/
      DATA INC/1/
C      DATA TDLP/'TDLP'/
      DATA C7777/'7777'/
CD    WRITE(KFILDO,100)(IS1(J),J=9,12)
CD100  FORMAT(' IN PACK--(IS1(J),J=9,12)'4I12)
C
C        FIND THE MAX AND MIN VALUES AND SUBTRACT THE MINIMUM VALUE.
C        JMAX( ), JMIN( ), LBIT( ), NOV( ), LX, IBIT, JBIT, AND KBIT
C        ARE ALL CALCULATED AS WELL AS MINA.  
C        THE ROUTINE CALLED DEPENDS ON WHETHER OR NOT MISSP = 0.
C
      IER=0
      N=L3264B
C        THIS ASSIGNMENT IS MADE MAINLY TO KEEP MOST CALLS TO PKBG
C        TO ONE LINE.  IT MAY HELP THE COMPILER TO BE MORE EFFICIENT.
      IF(MISSP.EQ.0)
     1   CALL PKMS00(KFILDO,IS1,ND7,IC,NXY,MINPK,INC,MISSP,MISSS,
     2               JMAX,JMIN,LBIT,NOV,NDG,LX,IBIT,JBIT,KBIT,MINA)    
      IF(MISSP.NE.0)
     1   CALL PKMS99(KFILDO,IS1,ND7,IC,NXY,MINPK,INC,MISSP,MISSS,
     2               JMAX,JMIN,LBIT,NOV,NDG,LX,IBIT,JBIT,KBIT,
     3               MINA,IER) 
      IF(IER.NE.0)GO TO 902   
C***D     WRITE(KFILDO,142)(IC(K),K=1,NXY)
C***D142  FORMAT(/' IN PACK, IC( ) ='/(' '20I6))
C***D     WRITE(KFILDO,143)(JMIN(K),K=1,LX)
C***D143  FORMAT(/' JMIN( ) ='/(' '15I5))
C***D     WRITE(KFILDO,144)(LBIT(K),K=1,LX)
C***D144  FORMAT(/' LBIT( ) ='/(' '15I5))
C***D     WRITE(KFILDO,145)(NOV(K),K=1,LX)
C***D145  FORMAT(/ ' NOV( ) ='/(' '15I5))
C***D     WRITE(KFILDO,146)MINA,LX,IBIT,JBIT,KBIT
C***D146  FORMAT(/' MINA, LX, IBIT, JBIT, KBIT ='2I10,4I6)
C
C        *************************************
C
C        PACK SECTION 0 OF THE MESSAGE INTO IPACK( ).
C
C        *************************************
C
      STATE='0   '
CINTEL
C
C        SET CHARACTER STRING TDLP ACCORDING TO THE ENDIANNESS
C        OF THE SYSTEM
C
         ISYSEND=0
         CALL CKSYSEND(KFILDO,'NOPRINT',ISYSEND,IER)
         IF(ISYSEND.EQ.-1)THEN
            TDLP='PLDT'
         ELSEIF(ISYSEND.EQ.1)THEN
            TDLP='TDLP'
         ELSE
            WRITE(KFILDO,150)
 150        FORMAT(/,' ****TROUBLE DETERMINING ENDIANNESS OF SYSTEM ',
     1               'IN PACK AT 150.')
            GO TO 900
         ENDIF
CINTEL
      LOC=1
C        LOC = WORD POSITION IN IPACK( ) TO START PACKING.
C        PKBG UPDATES IT.
      IPOS=1
C        IPOS = BIT POSITION IN IPACK(LOC) TO START PUTTING VALUE.
C        PKBG UPDATES IT.
      ITDLP1=ITDLP
      IF(L3264B.EQ.64)ITDLP1=ISHFT(ITDLP,-32)
C        THE ABOVE STATEMENT IS TO ACCOMMODATE THE 64-BIT WORD, BY
C        MOVING THE 4 CHARACTERS TO THE RIGHT HALF OF THE WORD FOR
C        PACKING.
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ITDLP1,32,N,IER,*900)
         LOC0=LOC
         IPOS0=IPOS
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IZERO,24,N,IER,*900)
C        BYTES 5-7 MUST BE FILLED IN LATER WITH THE RECORD LENGTH
C        IN BYTES; ABOVE STATEMENT HOLDS THE PLACE.  LOC0 AND IPOS0
C        HOLD THE LOCATION.
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IVERSN,8,N,IER,*900)
C        THIS IS TDLP EDITION IVERSN (0 AS OF AUGUST 1996).
C
C        *************************************
C
C        PACK SECTION 1 OF THE MESSAGE INTO IPACK( ).
C
C        *************************************
C
      STATE='1   '
      IS1(1)=39+IS1(22)
C        LENGTH OF SECTION 1 IS 39 BYTES PLUS IS1(22) BYTES OF
C        PLAIN LANGUAGE DESCRIPTION.  IS1(22) HAS A PRACTICAL 
C        LIMIT OF 32, GOVERNED BY DIMENSION LIMITS IN USING PROGRAMS.
C        IN NO CASE CAN IS1(1) EXCEED 2**8=256. 
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(1),8,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(2),8,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(3),16,N,IER,*900)
C
      DO 210 K=4,7
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(K),8,N,IER,*900)
 210  CONTINUE
C
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(8),32,N,IER,*900)
C        THIS PLACES THE DATE/TIME IN FORMAT YYYYMMDDHH.      
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(9),32,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(10),32,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(11),32,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(12),32,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(13),16,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(14),8,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(15),8,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(16),8,N,IER,*900)
      ISIGN=0
      IF(IS1(17).LT.0)ISIGN=1
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ISIGN,1,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ABS(IS1(17)),7,N,IER,*900)
C        THE SCALE FACTOR IN IS1(17) CAN BE NEGATIVE, WHICH IS
C        INDICATED IN THE PACKED RECORD AS A 1 IN THE LEFTMOST
C        POSITON.
      ISIGN=0
      IF(IS1(18).LT.0)ISIGN=1
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ISIGN,1,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ABS(IS1(18)),7,N,IER,*900)
C        THE SCALE FACTOR IN IS1(18) CAN BE NEGATIVE, WHICH IS
C        INDICATED IN THE PACKED RECORD AS A 1 IN THE LEFTMOST
C        POSITON.
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(19),8,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(20),8,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(21),8,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(22),8,N,IER,*900)
      IF(IS1(22).EQ.0)GO TO 221
C        SOME PLAIN LANGUAGE IS PRESENT TO BE PACKED.
C
      DO 220 K=23,22+IS1(22)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS1(K),8,N,IER,*900)
C        IS1(22) BYTES ARE PACKED, ONE BYTE PER IS1( ) WORD.
 220  CONTINUE
C
C        *************************************
C
C        PACK SECTION 2 OF THE MESSAGE INTO IPACK( ) WHEN THE
C        RIGHTMOST BIT OF IS1(2) IS 1.
C
C        *************************************
C
 221  IS2(1)=0
C        IS2(1) SET = 0 IN CASE THIS SECTION IS NOT PRESENT.
C      IB=IS1(2).AND.1
C      IF(IB.EQ.0)GO TO 300
      IF(.NOT.BTEST(IS1(2),0))GO TO 300
      STATE='2   '
      IER=18
      IF(IS2(2).NE.5.AND.IS2(2).NE.3.AND.IS2(2).NE.7)GO TO 900
C        ONLY POLAR STEROEGRAPHIC, LAMBERT, AND MERCATOR MAP
C        PROJECTIONS ARE CURRENTLY SUPPORTED.
      IER=0
C
      IS2(1)=28
C         SECTION 2 IS 28 BYTES LONG FOR THE IMPLEMENTED PROJECTIONS
C         POLAR STEREOGRAPHIC, LAMBERT, AND MERCATOR.
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS2(1),8,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS2(2),8,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS2(3),16,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS2(4),16,N,IER,*900)
      ISIGN=0
      IF(IS2(5).LT.0)ISIGN=1
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ISIGN,1,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ABS(IS2(5)),23,N,IER,*900)
      ISIGN=0
      IF(IS2(6).LT.0)ISIGN=1
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ISIGN,1,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ABS(IS2(6)),23,N,IER,*900)
      ISIGN=0
      IF(IS2(7).LT.0)ISIGN=1
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ISIGN,1,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ABS(IS2(7)),23,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS2(8),32,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS2(9),24,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS2(10),16,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS2(11),16,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS2(12),16,N,IER,*900)
C
C        *************************************
C
C        PACK SECTION 3 OF THE MESSAGE INTO IPACK( ) WHEN BIT 7 
C        IN IS1(2) IS ONE.
C
C        *************************************
C
 300  IS3=0
C        LENGTH OF SECTION 3 = 0 BYTES FOR CURRENT EDITION.
C      IB=IS1(2).AND.2
C      IF(IB.EQ.0)GO TO 303
      IF(.NOT.BTEST(IS1(2),1))GO TO 303
C        RETURN IS MADE WITH IER=19 WHEN A SECTION 3 IS INDICATED.
      IER=19
      GO TO 900
C
C        *************************************
C
C        PACK SECTION 4 OF THE MESSAGE INTO IPACK( ).
C
C        *************************************
C
 303  STATE='4.0 '
      LOC4=LOC
      IPOS4=IPOS
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IZERO,24,N,IER,*900)
C        BYTES 1-3 MUST BE FILLED IN LATER WITH THE RECORD LENGTH
C        IN BYTES; ABOVE STATEMENT HOLDS THE PLACE.  LOC4 AND IPOS4
C        HOLD THE LOCATION.
C
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS4(2),8,N,IER,*900)
C        THE BITS IN IS4(2) INDICATE VARIOUS THINGS (SEE DOCUMENTATION).
      IS4(3)=NXY
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IS4(3),32,N,IER,*900)
C        IS4(3) IS THE TOTAL NUMBER OF DATA POINTS.  IT IS 
C        INITIALIZED FROM NXY SO THAT THESE VALUES WILL AGREE.
C
C      IB=IS4(2).AND.2
C      IF(IB.EQ.0)GO TO 305
      IF(BTEST(IS4(2),1))GO TO 305
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,MISSP,32,N,IER,*900)
C        THE PRIMARY MISSING VALUE INDICATOR MISSP IS PACKED ONLY
C        WHEN THE NEXT TO THE RIGHTMOST BIT OF IS4(2) IS A 1.
C
C      IB=IS4(2).AND.1
C      IF(IB.EQ.0)GO TO 305
      IF(BTEST(IS4(2),0))GO TO 305
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,MISSS,32,N,IER,*900)
C        THE SECONDARY MISSING VALUE INDICATOR MISSS IS PACKED ONLY
C        WHEN THE RIGHTMOST BIT OF IS4(2) IS A 1.
C
C 305  IB=IS4(2).AND.4
C      IF(IB.EQ.0)GO TO 310
 305  IF(BTEST(IS4(2),2))GO TO 310
C
C        PACK 2ND ORDER VALUES.  THE ONLY VALUES NEEDED FOR 2ND
C        ORDER VALUES OVER AND ABOVE THOSE NEEDED FOR PACKING
C        ORIGINAL VALUES IS THE FIRST VALUE IN THE FIELD AND
C        THE FIRST FIRST ORDER DIFFERENCE.
C
      ISIGN=0
      IF(IFIRST.LT.0)ISIGN=1
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ISIGN,1,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ABS(IFIRST),31,N,IER,*900)
C        FIRST VALUE IN THE FIELD HAS BEEN PACKED.  32 BITS ARE USED
C        BECAUSE THE MAGNITUDE OF THE FIRST VALUE MAY BE RATHER LARGE.
C
C        FIND THE NUMBER OF BITS, MBIT, NEEDED TO TRANSMIT THE
C        ABSOLUTE VALUE OF THE FIRST FIRST-ORDER DIFFERENCE.
C        THIS VALUE SHOULD BE RATHER SMALL IN MAGNITUDE.
C
      MBIT=1
      MBIT2=2
 306  IF(ABS(IFOD).LT.MBIT2)GO TO 307
      MBIT=MBIT+1
      MBIT2=MBIT2*2
      GO TO 306
C
 307  ISIGN=0
      IF(IFOD.LT.0)ISIGN=1
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,MBIT,5,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ISIGN,1,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ABS(IFOD),MBIT,N,IER,*900)
C        FIRST FIRST ORDER DIFFERENCE HAS BEEN PACKED.
C
C        FIND THE NUMBER OF BITS, NBIT, NEEDED TO TRANSMIT THE
C        ABSOLUTE VALUE OF THE OVERALL MINIMUM VALUE.  THIS COULD BE THE
C        MINIMUM OF THE ORIGINAL VALUES OR OF THE 2ND ORDER DIFFERENCES,
C        WHICHEVER ARE BEING PACKED.  THEN PACK THIS MINIMUM.
C
 310  NBIT=1
      NBIT2=2
 311  IF(ABS(MINA).LT.NBIT2)GO TO 312
      NBIT=NBIT+1
      NBIT2=NBIT2*2
      GO TO 311
C
 312  ISIGN=0
      IF(MINA.LT.0)ISIGN=1
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,NBIT,5,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ISIGN,1,N,IER,*900)
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,ABS(MINA),NBIT,N,IER,*900)
C        THE OVERALL MINIMUM HAS BEEN PACKED.
      IS4(6)=NBIT
C
C        PACK NUMBER OF GROUPS, LX.
C
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,LX,16,N,IER,*900)
C        NUMBER OF GROUPS LX HAS BEEN PACKED.
      IS4(7)=LX
C
C        PACK IBIT, THE NUMBER OF BITS REQUIRED TO PACK THE GROUP
C        MINUMUM VALUES.
C      
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,IBIT,5,N,IER,*900)
C        THE NUMBER OF BITS REQUIRED TO PACK THE GROUP MINIMA HAS BEEN PACKED.
C
C        PACK THE NUMBER OF BITS REQUIRED TO HOLD THE VALUES IN EACH GROUP.
C
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,JBIT,5,N,IER,*900)
C
C        PACK THE NUMBER OF BITS REQUIRED TO PACK THE NUMBER
C        OF VALUES IN EACH GROUP.
C
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,KBIT,5,N,IER,*900)
C
C        PACK GROUP MINIMA.
C
      CALL PKS4LX(KFILDO,IPACK,ND5,LOC,IPOS,JMIN,LX,IBIT,L3264B,IER)
      IF(IER.NE.0)GO TO 900
C
C        PACK THE NUMBER OF BITS REQUIRED FOR EACH VALUE IN EACH GROUP.
C
      CALL PKS4LX(KFILDO,IPACK,ND5,LOC,IPOS,LBIT,LX,JBIT,L3264B,IER)
      IF(IER.NE.0)GO TO 900
C
C        PACK GROUP SIZES.
C
      CALL PKS4LX(KFILDO,IPACK,ND5,LOC,IPOS,NOV,LX,KBIT,L3264B,IER)
      IF(IER.NE.0)GO TO 900
C
C        NOW PACK THE DATA VALUES THEMSELVES.  "MISSING" VALUES
C        HAVE BEEN SET TO APPROPRIATE VALUES.
C
      CALL PKC4LX(KFILDO,IPACK,ND5,LOC,IPOS,
     1            IC,NXY,NOV,LBIT,LX,L3264B,IER)
      IF(IER.NE.0)GO TO 900
C
C        PAD WITH ZEROS TO AN EVEN OCTET.
C
      IFILL=MOD(L3264B+1-IPOS,8)
      IF(IFILL.NE.0)CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,
     1                        IZERO,IFILL,N,IER,*900)

C        THE LENGTH OF SECTION 4 CAN NOW BE PUT IN BYTES 1-3 
C        AND IS4(1).  LOC4 AND IPOS4 REPRESENT THE LENGTH OF
C        THE RECORD BEFORE SECTION 4.
C
      MOCTET=(LOC *L3264B/8-(L3264B+1-IPOS )/8)
     1      -(LOC4*L3264B/8-(L3264B+1-IPOS4)/8)
C        THE "8" JUST REPRESENTS THE NUMBER OF BITS IN A BYTE.
C        EACH SECTION ENDS AT THE END OF A BYTE.
      IS4(1)=MOCTET
      CALL PKBG(KFILDO,IPACK,ND5,LOC4,IPOS4,MOCTET,24,N,IER,*900)
C
C        *************************************
C
C        PACK END OF MESSAGE, SECTION 5.
C
C        *************************************
C
      I77771=I7777
      IF(L3264B.EQ.64)I77771=ISHFT(I7777,-32)
C        THE ABOVE STATEMENT IS TO ACCOMMODATE THE 64-BIT WORD, BY
C        MOVING THE 4 CHARACTERS TO THE RIGHT HALF OF THE WORD FOR
C        PACKING.
      CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,I77771,32,N,IER,*900)
C        FILL BYTES 5-7 WITH THE TOTAL MESSAGE LENGTH IN BYTES.
      IOCTET=LOC*L3264B/8-(L3264B+1-IPOS)/8
      CALL PKBG(KFILDO,IPACK,ND5,LOC0,IPOS0,IOCTET,24,N,IER,*900)
C
C        THE RECORD IS COMPLETE, EXCEPT IT NEEDS TO BE WRITTEN IN
C        64-BIT CHUNKS SO THAT IT CAN BE READ BY EITHER A 32- OR 64-BIT
C        MACHINE.  DO THAT NOW.  IT MUST BE DONE SO THAT NO MORE THAN
C        32 BITS ARE INSERTED IN ONE CALL.
C
      IFILL1=MOD(32-MOD(IOCTET,4)*8,32)
C        IFILL IS THE NUMBER OF BITS THAT WILL PAD OUT TO NUMBER 
C        OF BYTES EVENLY DIVISIBLE BY 4.
      IF(IFILL1.NE.0)CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,
     1                        IZERO,IFILL1,N,IER,*900)
      IFILL=MOD(64-MOD(IOCTET,8)*8-IFILL1,64)
C        IFILL IS THE NUMBER OF BITS THAT WILL PAD OUT TO NUMBER
C        OF BYTES EVENLY DIVISIBLE BY 8.
      IF(IFILL.NE.0)CALL PKBG(KFILDO,IPACK,ND5,LOC,IPOS,
     1                        IZERO,IFILL,N,IER,*900)
      IOCTET=IOCTET+(IFILL1+IFILL)/8
C        THE IOCTET VALUE RETURNED INCLUDES THE PADDING TO AN EVEN 
C        64 BITS, BUT THE LENGTH IN THE PACKED RECORD DOES NOT.
C        THIS IS SO THE WRITING CAN COUNT ON BLOCKS OF 64 BITS.
CD    WRITE(KFILDO,899)(IS1(J),J=9,18),MISSP,MISSS,(IS4(J),J=1,5)
CD899  FORMAT(/' IN PACK AT 899--(IS1(J),J=9,18),MISSP,MISSS,
CD   1        (IS4(J),J=1,5)'/(10I12))
      
      RETURN
C
C        ERROR RETURN SECTION.
C
 900  WRITE(KFILDO,901)STATE,IER
 901  FORMAT(/,' ****ERROR IN PACK PACKING SECTION ',A4,'  IER =',I4)
 902  RETURN
      END

