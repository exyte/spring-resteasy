
       IDENTIFICATION DIVISION.

       PROGRAM-ID. xholidays.

       DATA DIVISION.

       LINKAGE SECTION.

       WORKING-STORAGE SECTION.

       1 INITIAL-MESSLEN PIC 99999 VALUE 10000.
       1 MESS PIC X(10000).
       1 MESSLEN PIC 99999 VALUE 1000.
       1 P1 PIC 9(5).
       1 P2 PIC 9(5).
       1 ERRMESS PIC X(80).
       1 CNT PIC S9999 COMP.
       1 DECODE-J PIC S9999 COMP.
       1 DECODE-Y PIC X(9999).
       1 DECODE-K PIC S9999 COMP.
       1 EVENT PIC 9999.

       1 OUTMESS-I COMP PIC S9(4) VALUE 1.
       1 TARGET PIC X(25).
         88 post-entry-name VALUE 'postholiday'.
         88 get-entry-name VALUE 'getholiday'.
         88 put-entry-name VALUE 'putholiday'.
         88 delete-entry-name VALUE 'deleteholiday'.
       1 post-hol-linkage.
         2 post-hol-rec.
           3 post-hol-id PIC 9(3).
           3 post-hol-name PIC X(25).
           3 post-hol-dt.
             4 post-hol-wkday PIC X(9).
             4 post-hol-mon PIC X(9).
             4 post-hol-day PIC 9(2).
             4 post-hol-yr PIC 9(4).
           3 post-hol-cur-dt PIC X(21).
         2 post-hol-io-msg PIC X(20).
       1 get-hol-linkage.
         2 get-hol-rec.
           3 get-hol-id PIC 9(3).
           3 get-hol-name PIC X(25).
           3 get-hol-dt.
             4 get-hol-wkday PIC X(9).
             4 get-hol-mon PIC X(9).
             4 get-hol-day PIC 9(2).
             4 get-hol-yr PIC 9(4).
           3 get-hol-cur-dt PIC X(21).
         2 get-hol-io-msg PIC X(20).
       1 put-hol-linkage.
         2 put-hol-rec.
           3 put-hol-id PIC 9(3).
           3 put-hol-name PIC X(25).
           3 put-hol-dt.
             4 put-hol-wkday PIC X(9).
             4 put-hol-mon PIC X(9).
             4 put-hol-day PIC 9(2).
             4 put-hol-yr PIC 9(4).
           3 put-hol-cur-dt PIC X(21).
         2 put-hol-io-msg PIC X(20).
       1 delete-hol-linkage.
         2 delete-hol-rec.
           3 delete-hol-id PIC 9(3).
           3 delete-hol-name PIC X(25).
           3 delete-hol-dt.
             4 delete-hol-wkday PIC X(9).
             4 delete-hol-mon PIC X(9).
             4 delete-hol-day PIC 9(2).
             4 delete-hol-yr PIC 9(4).
           3 delete-hol-cur-dt PIC X(21).
         2 delete-hol-io-msg PIC X(20).

       1 CRLF PIC XX VALUE X'0D0A'.

       PROCEDURE DIVISION.

       ACCEPT MESS FROM SYSIN

       INSPECT MESS 
       TALLYING P2 FOR CHARACTERS AFTER INITIAL '</PROGRAM>'
       COMPUTE MESSLEN = INITIAL-MESSLEN - P2
       INSPECT MESS(1:MESSLEN) TALLYING P1
          FOR CHARACTERS BEFORE INITIAL '<PROGRAM'
       IF P1 >= 0 AND P1 < MESSLEN
          MOVE MESS(P1 + 1:MESSLEN - P1) TO MESS
          COMPUTE MESSLEN = MESSLEN - P1
       ELSE
          MOVE 'XML Parsing Error' TO ERRMESS
          PERFORM ERR
       END-IF

       MOVE 0 TO EVENT

       XML PARSE MESS(1:MESSLEN) PROCESSING PROCEDURE INMESS
       ON EXCEPTION
          MOVE 'Parser error' TO ERRMESS
          PERFORM ERR
       END-XML

       PERFORM CALLTARGET

       PERFORM OUTMESS

       PERFORM PUTMESS

       GOBACK.
       INMESS SECTION.
       EVALUATE EVENT ALSO TARGET ALSO XML-EVENT ALSO XML-TEXT
          WHEN 0 ALSO SPACES
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'PROGRAM'
             CONTINUE
          WHEN 1 ALSO SPACES
                 ALSO 'ATTRIBUTE-NAME'
                 ALSO 'name'
             CONTINUE
          WHEN 2 ALSO SPACES
                 ALSO 'ATTRIBUTE-CHARACTERS'
                 ALSO ANY
             IF XML-TEXT NOT = 'holidays'
                MOVE 'invalid program name : holidays'
                TO ERRMESS
                PERFORM ERR
             END-IF
          WHEN 3 ALSO SPACES
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'ENTRY'
             CONTINUE
          WHEN 4 ALSO SPACES
                 ALSO 'ATTRIBUTE-NAME'
                 ALSO 'name'
             CONTINUE
          WHEN 5 ALSO SPACES
                 ALSO 'ATTRIBUTE-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO TARGET
          WHEN 6 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'PARAM'
             CONTINUE
          WHEN 7 ALSO 'postholiday'
                 ALSO 'ATTRIBUTE-NAME'
                 ALSO 'name'
             CONTINUE
          WHEN 8 ALSO 'postholiday'
                 ALSO 'ATTRIBUTE-CHARACTERS'
                 ALSO ANY
             IF XML-TEXT NOT = 'hol-linkage'
                MOVE 'invalid parameter name : '
                TO ERRMESS
                MOVE XML-TEXT
                TO ERRMESS(26:)
                PERFORM ERR
             END-IF
          WHEN 9 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-linkage'
             CONTINUE
          WHEN 10 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-rec'
             CONTINUE
          WHEN 11 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-id'
             CONTINUE
          WHEN 12 ALSO 'postholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO post-hol-id
          WHEN 13 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-id'
             CONTINUE
          WHEN 14 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-name'
             CONTINUE
          WHEN 15 ALSO 'postholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO post-hol-name
          WHEN 16 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-name'
             CONTINUE
          WHEN 17 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-dt'
             CONTINUE
          WHEN 18 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-wkday'
             CONTINUE
          WHEN 19 ALSO 'postholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO post-hol-wkday
          WHEN 20 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-wkday'
             CONTINUE
          WHEN 21 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-mon'
             CONTINUE
          WHEN 22 ALSO 'postholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO post-hol-mon
          WHEN 23 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-mon'
             CONTINUE
          WHEN 24 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-day'
             CONTINUE
          WHEN 25 ALSO 'postholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO post-hol-day
          WHEN 26 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-day'
             CONTINUE
          WHEN 27 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-yr'
             CONTINUE
          WHEN 28 ALSO 'postholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO post-hol-yr
          WHEN 29 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-yr'
             CONTINUE
          WHEN 30 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-dt'
             CONTINUE
          WHEN 31 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-cur-dt'
             CONTINUE
          WHEN 32 ALSO 'postholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO post-hol-cur-dt
          WHEN 33 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-cur-dt'
             CONTINUE
          WHEN 34 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-rec'
             CONTINUE
          WHEN 35 ALSO 'postholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-io-msg'
             CONTINUE
          WHEN 36 ALSO 'postholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO post-hol-io-msg
          WHEN 37 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-io-msg'
             CONTINUE
          WHEN 38 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-linkage'
             CONTINUE
          WHEN 39 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'PARAM'
             CONTINUE
          WHEN 40 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'ENTRY'
             CONTINUE
          WHEN 41 ALSO 'postholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'PROGRAM'
             CONTINUE
          WHEN 6 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'PARAM'
             CONTINUE
          WHEN 7 ALSO 'getholiday'
                 ALSO 'ATTRIBUTE-NAME'
                 ALSO 'name'
             CONTINUE
          WHEN 8 ALSO 'getholiday'
                 ALSO 'ATTRIBUTE-CHARACTERS'
                 ALSO ANY
             IF XML-TEXT NOT = 'hol-linkage'
                MOVE 'invalid parameter name : '
                TO ERRMESS
                MOVE XML-TEXT
                TO ERRMESS(26:)
                PERFORM ERR
             END-IF
          WHEN 9 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-linkage'
             CONTINUE
          WHEN 10 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-rec'
             CONTINUE
          WHEN 11 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-id'
             CONTINUE
          WHEN 12 ALSO 'getholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO get-hol-id
          WHEN 13 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-id'
             CONTINUE
          WHEN 14 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-name'
             CONTINUE
          WHEN 15 ALSO 'getholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO get-hol-name
          WHEN 16 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-name'
             CONTINUE
          WHEN 17 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-dt'
             CONTINUE
          WHEN 18 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-wkday'
             CONTINUE
          WHEN 19 ALSO 'getholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO get-hol-wkday
          WHEN 20 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-wkday'
             CONTINUE
          WHEN 21 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-mon'
             CONTINUE
          WHEN 22 ALSO 'getholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO get-hol-mon
          WHEN 23 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-mon'
             CONTINUE
          WHEN 24 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-day'
             CONTINUE
          WHEN 25 ALSO 'getholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO get-hol-day
          WHEN 26 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-day'
             CONTINUE
          WHEN 27 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-yr'
             CONTINUE
          WHEN 28 ALSO 'getholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO get-hol-yr
          WHEN 29 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-yr'
             CONTINUE
          WHEN 30 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-dt'
             CONTINUE
          WHEN 31 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-cur-dt'
             CONTINUE
          WHEN 32 ALSO 'getholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO get-hol-cur-dt
          WHEN 33 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-cur-dt'
             CONTINUE
          WHEN 34 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-rec'
             CONTINUE
          WHEN 35 ALSO 'getholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-io-msg'
             CONTINUE
          WHEN 36 ALSO 'getholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO get-hol-io-msg
          WHEN 37 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-io-msg'
             CONTINUE
          WHEN 38 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-linkage'
             CONTINUE
          WHEN 39 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'PARAM'
             CONTINUE
          WHEN 40 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'ENTRY'
             CONTINUE
          WHEN 41 ALSO 'getholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'PROGRAM'
             CONTINUE
          WHEN 6 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'PARAM'
             CONTINUE
          WHEN 7 ALSO 'putholiday'
                 ALSO 'ATTRIBUTE-NAME'
                 ALSO 'name'
             CONTINUE
          WHEN 8 ALSO 'putholiday'
                 ALSO 'ATTRIBUTE-CHARACTERS'
                 ALSO ANY
             IF XML-TEXT NOT = 'hol-linkage'
                MOVE 'invalid parameter name : '
                TO ERRMESS
                MOVE XML-TEXT
                TO ERRMESS(26:)
                PERFORM ERR
             END-IF
          WHEN 9 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-linkage'
             CONTINUE
          WHEN 10 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-rec'
             CONTINUE
          WHEN 11 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-id'
             CONTINUE
          WHEN 12 ALSO 'putholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO put-hol-id
          WHEN 13 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-id'
             CONTINUE
          WHEN 14 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-name'
             CONTINUE
          WHEN 15 ALSO 'putholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO put-hol-name
          WHEN 16 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-name'
             CONTINUE
          WHEN 17 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-dt'
             CONTINUE
          WHEN 18 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-wkday'
             CONTINUE
          WHEN 19 ALSO 'putholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO put-hol-wkday
          WHEN 20 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-wkday'
             CONTINUE
          WHEN 21 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-mon'
             CONTINUE
          WHEN 22 ALSO 'putholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO put-hol-mon
          WHEN 23 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-mon'
             CONTINUE
          WHEN 24 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-day'
             CONTINUE
          WHEN 25 ALSO 'putholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO put-hol-day
          WHEN 26 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-day'
             CONTINUE
          WHEN 27 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-yr'
             CONTINUE
          WHEN 28 ALSO 'putholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO put-hol-yr
          WHEN 29 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-yr'
             CONTINUE
          WHEN 30 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-dt'
             CONTINUE
          WHEN 31 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-cur-dt'
             CONTINUE
          WHEN 32 ALSO 'putholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO put-hol-cur-dt
          WHEN 33 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-cur-dt'
             CONTINUE
          WHEN 34 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-rec'
             CONTINUE
          WHEN 35 ALSO 'putholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-io-msg'
             CONTINUE
          WHEN 36 ALSO 'putholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO put-hol-io-msg
          WHEN 37 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-io-msg'
             CONTINUE
          WHEN 38 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-linkage'
             CONTINUE
          WHEN 39 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'PARAM'
             CONTINUE
          WHEN 40 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'ENTRY'
             CONTINUE
          WHEN 41 ALSO 'putholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'PROGRAM'
             CONTINUE
          WHEN 6 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'PARAM'
             CONTINUE
          WHEN 7 ALSO 'deleteholiday'
                 ALSO 'ATTRIBUTE-NAME'
                 ALSO 'name'
             CONTINUE
          WHEN 8 ALSO 'deleteholiday'
                 ALSO 'ATTRIBUTE-CHARACTERS'
                 ALSO ANY
             IF XML-TEXT NOT = 'hol-linkage'
                MOVE 'invalid parameter name : '
                TO ERRMESS
                MOVE XML-TEXT
                TO ERRMESS(26:)
                PERFORM ERR
             END-IF
          WHEN 9 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-linkage'
             CONTINUE
          WHEN 10 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-rec'
             CONTINUE
          WHEN 11 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-id'
             CONTINUE
          WHEN 12 ALSO 'deleteholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO delete-hol-id
          WHEN 13 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-id'
             CONTINUE
          WHEN 14 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-name'
             CONTINUE
          WHEN 15 ALSO 'deleteholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO delete-hol-name
          WHEN 16 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-name'
             CONTINUE
          WHEN 17 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-dt'
             CONTINUE
          WHEN 18 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-wkday'
             CONTINUE
          WHEN 19 ALSO 'deleteholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO delete-hol-wkday
          WHEN 20 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-wkday'
             CONTINUE
          WHEN 21 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-mon'
             CONTINUE
          WHEN 22 ALSO 'deleteholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO delete-hol-mon
          WHEN 23 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-mon'
             CONTINUE
          WHEN 24 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-day'
             CONTINUE
          WHEN 25 ALSO 'deleteholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO delete-hol-day
          WHEN 26 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-day'
             CONTINUE
          WHEN 27 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-yr'
             CONTINUE
          WHEN 28 ALSO 'deleteholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO delete-hol-yr
          WHEN 29 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-yr'
             CONTINUE
          WHEN 30 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-dt'
             CONTINUE
          WHEN 31 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-cur-dt'
             CONTINUE
          WHEN 32 ALSO 'deleteholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO delete-hol-cur-dt
          WHEN 33 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-cur-dt'
             CONTINUE
          WHEN 34 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-rec'
             CONTINUE
          WHEN 35 ALSO 'deleteholiday'
                 ALSO 'START-OF-ELEMENT'
                 ALSO 'hol-io-msg'
             CONTINUE
          WHEN 36 ALSO 'deleteholiday'
                 ALSO 'CONTENT-CHARACTERS'
                 ALSO ANY
             MOVE XML-TEXT
             TO delete-hol-io-msg
          WHEN 37 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-io-msg'
             CONTINUE
          WHEN 38 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'hol-linkage'
             CONTINUE
          WHEN 39 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'PARAM'
             CONTINUE
          WHEN 40 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'ENTRY'
             CONTINUE
          WHEN 41 ALSO 'deleteholiday'
                 ALSO 'END-OF-ELEMENT'
                 ALSO 'PROGRAM'
             CONTINUE
          WHEN OTHER
             DISPLAY 'event:' EVENT
             DISPLAY 'target:' TARGET
             DISPLAY 'xml-ev:' XML-EVENT
             DISPLAY 'xml-tx:' XML-TEXT
             MOVE 'invalid XML'
             TO ERRMESS
             PERFORM ERR
          END-EVALUATE
          ADD 1 TO EVENT.
       CALLTARGET SECTION.
          IF post-entry-name THEN
             CALL TARGET USING post-hol-linkage 
          ELSE IF get-entry-name THEN
             CALL TARGET USING get-hol-linkage 
          ELSE IF put-entry-name THEN
             CALL TARGET USING put-hol-linkage 
          ELSE IF delete-entry-name THEN
             CALL TARGET USING delete-hol-linkage 
          ELSE
             MOVE 'invalid entry : '
             TO ERRMESS
             MOVE TARGET
             TO ERRMESS(17:)
             PERFORM ERR
          END-IF.
       OUTMESS SECTION.
       MOVE '<PROGRAM name="holidays">'
       TO MESS(OUTMESS-I:)
       ADD 25 TO OUTMESS-I
       IF TARGET = 'postholiday'
          MOVE '<ENTRY name="postholiday">'
          TO MESS(OUTMESS-I:)
          ADD 26 TO OUTMESS-I
          MOVE '<PARAM name="hol-linkage">'
          TO MESS(OUTMESS-I:)
          ADD 26 TO OUTMESS-I
          MOVE '<hol-linkage>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '<hol-rec>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-id>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE post-hol-id
          TO MESS(OUTMESS-I:)
          ADD 3 TO OUTMESS-I
          MOVE '</hol-id>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-name>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE post-hol-name
          TO MESS(OUTMESS-I:)
          ADD 25 TO OUTMESS-I
          MOVE '</hol-name>'
          TO MESS(OUTMESS-I:)
          ADD 11 TO OUTMESS-I
          MOVE '<hol-dt>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE '<hol-wkday>'
          TO MESS(OUTMESS-I:)
          ADD 11 TO OUTMESS-I
          MOVE post-hol-wkday
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-wkday>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE '<hol-mon>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE post-hol-mon
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-mon>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-day>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE post-hol-day
          TO MESS(OUTMESS-I:)
          ADD 2 TO OUTMESS-I
          MOVE '</hol-day>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-yr>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE post-hol-yr
          TO MESS(OUTMESS-I:)
          ADD 4 TO OUTMESS-I
          MOVE '</hol-yr>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-dt>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-cur-dt>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE post-hol-cur-dt
          TO MESS(OUTMESS-I:)
          ADD 21 TO OUTMESS-I
          MOVE '</hol-cur-dt>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '</hol-rec>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-io-msg>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE post-hol-io-msg
          TO MESS(OUTMESS-I:)
          ADD 20 TO OUTMESS-I
          MOVE '</hol-io-msg>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '</hol-linkage>'
          TO MESS(OUTMESS-I:)
          ADD 14 TO OUTMESS-I
          MOVE '</PARAM>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE '</ENTRY>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
       END-IF
       IF TARGET = 'getholiday'
          MOVE '<ENTRY name="getholiday">'
          TO MESS(OUTMESS-I:)
          ADD 25 TO OUTMESS-I
          MOVE '<PARAM name="hol-linkage">'
          TO MESS(OUTMESS-I:)
          ADD 26 TO OUTMESS-I
          MOVE '<hol-linkage>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '<hol-rec>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-id>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE get-hol-id
          TO MESS(OUTMESS-I:)
          ADD 3 TO OUTMESS-I
          MOVE '</hol-id>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-name>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE get-hol-name
          TO MESS(OUTMESS-I:)
          ADD 25 TO OUTMESS-I
          MOVE '</hol-name>'
          TO MESS(OUTMESS-I:)
          ADD 11 TO OUTMESS-I
          MOVE '<hol-dt>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE '<hol-wkday>'
          TO MESS(OUTMESS-I:)
          ADD 11 TO OUTMESS-I
          MOVE get-hol-wkday
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-wkday>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE '<hol-mon>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE get-hol-mon
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-mon>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-day>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE get-hol-day
          TO MESS(OUTMESS-I:)
          ADD 2 TO OUTMESS-I
          MOVE '</hol-day>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-yr>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE get-hol-yr
          TO MESS(OUTMESS-I:)
          ADD 4 TO OUTMESS-I
          MOVE '</hol-yr>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-dt>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-cur-dt>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE get-hol-cur-dt
          TO MESS(OUTMESS-I:)
          ADD 21 TO OUTMESS-I
          MOVE '</hol-cur-dt>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '</hol-rec>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-io-msg>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE get-hol-io-msg
          TO MESS(OUTMESS-I:)
          ADD 20 TO OUTMESS-I
          MOVE '</hol-io-msg>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '</hol-linkage>'
          TO MESS(OUTMESS-I:)
          ADD 14 TO OUTMESS-I
          MOVE '</PARAM>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE '</ENTRY>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
       END-IF
       IF TARGET = 'putholiday'
          MOVE '<ENTRY name="putholiday">'
          TO MESS(OUTMESS-I:)
          ADD 25 TO OUTMESS-I
          MOVE '<PARAM name="hol-linkage">'
          TO MESS(OUTMESS-I:)
          ADD 26 TO OUTMESS-I
          MOVE '<hol-linkage>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '<hol-rec>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-id>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE put-hol-id
          TO MESS(OUTMESS-I:)
          ADD 3 TO OUTMESS-I
          MOVE '</hol-id>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-name>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE put-hol-name
          TO MESS(OUTMESS-I:)
          ADD 25 TO OUTMESS-I
          MOVE '</hol-name>'
          TO MESS(OUTMESS-I:)
          ADD 11 TO OUTMESS-I
          MOVE '<hol-dt>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE '<hol-wkday>'
          TO MESS(OUTMESS-I:)
          ADD 11 TO OUTMESS-I
          MOVE put-hol-wkday
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-wkday>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE '<hol-mon>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE put-hol-mon
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-mon>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-day>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE put-hol-day
          TO MESS(OUTMESS-I:)
          ADD 2 TO OUTMESS-I
          MOVE '</hol-day>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-yr>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE put-hol-yr
          TO MESS(OUTMESS-I:)
          ADD 4 TO OUTMESS-I
          MOVE '</hol-yr>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-dt>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-cur-dt>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE put-hol-cur-dt
          TO MESS(OUTMESS-I:)
          ADD 21 TO OUTMESS-I
          MOVE '</hol-cur-dt>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '</hol-rec>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-io-msg>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE put-hol-io-msg
          TO MESS(OUTMESS-I:)
          ADD 20 TO OUTMESS-I
          MOVE '</hol-io-msg>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '</hol-linkage>'
          TO MESS(OUTMESS-I:)
          ADD 14 TO OUTMESS-I
          MOVE '</PARAM>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE '</ENTRY>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
       END-IF
       IF TARGET = 'deleteholiday'
          MOVE '<ENTRY name="deleteholiday">'
          TO MESS(OUTMESS-I:)
          ADD 28 TO OUTMESS-I
          MOVE '<PARAM name="hol-linkage">'
          TO MESS(OUTMESS-I:)
          ADD 26 TO OUTMESS-I
          MOVE '<hol-linkage>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '<hol-rec>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-id>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE delete-hol-id
          TO MESS(OUTMESS-I:)
          ADD 3 TO OUTMESS-I
          MOVE '</hol-id>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-name>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE delete-hol-name
          TO MESS(OUTMESS-I:)
          ADD 25 TO OUTMESS-I
          MOVE '</hol-name>'
          TO MESS(OUTMESS-I:)
          ADD 11 TO OUTMESS-I
          MOVE '<hol-dt>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE '<hol-wkday>'
          TO MESS(OUTMESS-I:)
          ADD 11 TO OUTMESS-I
          MOVE delete-hol-wkday
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-wkday>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE '<hol-mon>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE delete-hol-mon
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-mon>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-day>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE delete-hol-day
          TO MESS(OUTMESS-I:)
          ADD 2 TO OUTMESS-I
          MOVE '</hol-day>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-yr>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE delete-hol-yr
          TO MESS(OUTMESS-I:)
          ADD 4 TO OUTMESS-I
          MOVE '</hol-yr>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '</hol-dt>'
          TO MESS(OUTMESS-I:)
          ADD 9 TO OUTMESS-I
          MOVE '<hol-cur-dt>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE delete-hol-cur-dt
          TO MESS(OUTMESS-I:)
          ADD 21 TO OUTMESS-I
          MOVE '</hol-cur-dt>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '</hol-rec>'
          TO MESS(OUTMESS-I:)
          ADD 10 TO OUTMESS-I
          MOVE '<hol-io-msg>'
          TO MESS(OUTMESS-I:)
          ADD 12 TO OUTMESS-I
          MOVE delete-hol-io-msg
          TO MESS(OUTMESS-I:)
          ADD 20 TO OUTMESS-I
          MOVE '</hol-io-msg>'
          TO MESS(OUTMESS-I:)
          ADD 13 TO OUTMESS-I
          MOVE '</hol-linkage>'
          TO MESS(OUTMESS-I:)
          ADD 14 TO OUTMESS-I
          MOVE '</PARAM>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
          MOVE '</ENTRY>'
          TO MESS(OUTMESS-I:)
          ADD 8 TO OUTMESS-I
       END-IF
       MOVE '</PROGRAM>'
       TO MESS(OUTMESS-I:)
       ADD 10 TO OUTMESS-I
       MOVE OUTMESS-I TO MESSLEN
       .

       PUTMESS SECTION.
          DISPLAY 'Content-Type: text/plain;charset=us-ascii' CRLF
          DISPLAY MESS(1:MESSLEN)
          GOBACK.
       ERR SECTION.
          DISPLAY 'Content-Type: text/plain;charset=us-ascii'
          DISPLAY 'Status: 403 NOK' CRLF
          DISPLAY ERRMESS
          GOBACK.
