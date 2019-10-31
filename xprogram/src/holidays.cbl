       IDENTIFICATION DIVISION.
       PROGRAM-ID.  'holidays'.
       ENVIRONMENT DIVISION. 
       INPUT-OUTPUT SECTION.  
      * 
           select holidaysIX assign to "holidaysIX"
           organization is INDEXED
           access is DYNAMIC
           RECORD KEY IS HOLIDAY-NAME
           ALTERNATE KEY IS HOLIDAY-DATE with DUPLICATES
           ALTERNATE RECORD KEY IS day-key = 
                   the-day, the-month, the-year WITH DUPLICATES
           file status is holiday-status.
      *
       DATA DIVISION.
       FILE SECTION. 
      *
       FD holidaysIX.
      *
       01 holiday-record.
         05 holiday-number  PIC 999.
         05 holiday-name PIC X(25).
         05 holiday-date.
             10 week-day  PIC X(9).
             10 the-month pic X(9).
             10 the-day   pic 99.
             10 the-year  pic XXXX.         
         05 holiday-current-date.
           10 holiday-yyyymmdd     pic x(8).
           10 holiday-hhmmssss     pic x(8).
           10 holiday-gmtoffset    pic x(5).    
      *
       01 holiday-record-2.
         05 holiday-number-2   PIC 999.
         05 holiday-name-2 pic X(25).
         05 holiday-date-2 pic X(24).
         05 holiday-current-date-2  pic X(21).               
      *
       WORKING-STORAGE SECTION.
      *
       77 holiday-status pic xx.       
       77 ws-holiday-number PIC 999 VALUE 0.       
       77 ws-dummy  pic x.
       77 holiday-io-msg PIC x(20).
      *
       LINKAGE SECTION.
       01 hol-linkage.   
        03 hol-rec.
         05 hol-id PIC 999. 
         05 hol-name PIC X(25).
         05 hol-dt.
           10 hol-wkday  PIC X(9).
           10 hol-mon  PIC X(9).
           10 hol-day  PIC 99.
           10 hol-yr   PIC 9(4).         
         05 hol-cur-dt PIC x(21).  
        03 hol-io-msg PIC X(20).
      *
         
      *     
       PROCEDURE DIVISION. 
      *
       ENTRY 'postholiday' USING hol-linkage.
           DISPLAY "IN postholiday" UPON SYSERR.
      *     
           OPEN OUTPUT holidaysIX.

           IF holiday-status NOT = "00"              
             DISPLAY"OPEN FAILED: ", holiday-status UPON SYSERR
             PERFORM UPDATE-HOL-IO-MSG
             MOVE holiday-io-msg TO hol-io-msg
           ELSE
             DISPLAY "OPEN SUCCESSFUL: ", holiday-status UPON SYSERR
             INITIALIZE holiday-record
             ADD 1 TO ws-holiday-number
             MOVE FUNCTION current-date TO holiday-current-date
             MOVE ws-holiday-number TO holiday-number
             MOVE hol-name TO holiday-name 
             MOVE hol-dt TO holiday-date
      *       
             WRITE holiday-record
             IF holiday-status not = "00"
               DISPLAY "WRITE FAILED!: ", holiday-status UPON SYSERR 
             ELSE             
               DISPLAY"WRITE SUCCESSFUL!: ", holiday-status UPON SYSERR
               DISPLAY "Holiday Record: ", holiday-record UPON SYSERR
               MOVE holiday-number TO hol-id
               MOVE holiday-current-date TO hol-cur-dt
               PERFORM UPDATE-HOL-IO-MSG
               MOVE holiday-io-msg TO hol-io-msg
             END-IF
      *       
             CLOSE HOLIDAYSIX
             DISPLAY "CLOSE STATUS: ", HOLIDAY-STATUS UPON SYSERR
           END-IF.  
      *
           GOBACK.
      *
       ENTRY 'getholiday' USING hol-linkage.
           DISPLAY "IN getholiday" UPON SYSERR.
      *     
           OPEN INPUT holidaysIX.
      *
           IF holiday-status NOT = "00"              
             DISPLAY"OPEN FAILED: ", holiday-status UPON SYSERR
             PERFORM UPDATE-HOL-IO-MSG
             MOVE holiday-io-msg TO hol-io-msg
           ELSE
             DISPLAY "OPEN SUCCESSFUL: ", holiday-status UPON SYSERR
             DISPLAY "OPEN Status: ", holiday-status UPON SYSERR
      *       
             MOVE hol-name TO holiday-name
             READ holidaysIX KEY IS holiday-name
             DISPLAY "READ Status: ", holiday-status UPON SYSERR
             IF holiday-status NOT = "00"
               DISPLAY "READ FAILED!" UPON SYSERR
             ELSE                       
               DISPLAY"READ SUCCESSFUL!" UPON SYSERR
               MOVE holiday-record TO hol-rec
             END-IF
             PERFORM UPDATE-HOL-IO-MSG
             MOVE HOLIDAY-IO-MSG TO HOL-IO-MSG            
      *       
             CLOSE holidaysIX
             DISPLAY "CLOSE Status: ", holiday-status UPON SYSERR
           END-IF.
       
           GOBACK.
      *      
       ENTRY 'putholiday' USING hol-linkage.
           DISPLAY "IN putholiday" UPON SYSERR.
      *     
           OPEN I-O holidaysIX. 
      *
           IF holiday-status NOT = "00"              
             DISPLAY"OPEN FAILED: ", holiday-status UPON SYSERR
             PERFORM UPDATE-HOL-IO-MSG
             MOVE holiday-io-msg TO hol-io-msg
           ELSE
             DISPLAY "OPEN SUCCESSFUL: ", holiday-status UPON SYSERR
             MOVE hol-name TO holiday-name
             READ holidaysIX KEY IS holiday-name
      *       
             IF holiday-status NOT = "00"
               DISPLAY "READ FAILED!: ", holiday-status UPON SYSERR
             ELSE                       
               DISPLAY"READ SUCCESSFUL! ", holiday-status UPON SYSERR
               MOVE holiday-record TO hol-rec
               MOVE FUNCTION CURRENT-DATE TO HOLIDAY-CURRENT-DATE
               REWRITE holiday-record
      *
               IF holiday-status NOT = "00"
                 DISPLAY "REWRITE FAILED: ", holiday-status UPON SYSERR
               ELSE
                 DISPLAY"REWRITE SUCCESSFUL!: ", holiday-status 
                                                            UPON SYSERR
                 MOVE holiday-record TO hol-rec
               END-IF                         
             END-IF
             PERFORM UPDATE-HOL-IO-MSG
             MOVE HOLIDAY-IO-MSG TO HOL-IO-MSG
      *       
             CLOSE holidaysIX
             DISPLAY "CLOSE Status: ", holiday-status UPON SYSERR
           END-IF.
           
           GOBACK.
      *     
       ENTRY 'deleteholiday' USING hol-linkage.
           DISPLAY "IN deleteholiday" UPON SYSERR.
      *     
           OPEN I-O holidaysIX.            
           IF holiday-status NOT = "00"
             DISPLAY "OPEN FAILED!: ", holiday-status UPON SYSERR
             PERFORM UPDATE-HOL-IO-MSG
             MOVE holiday-io-msg TO hol-io-msg
           ELSE                   
             MOVE hol-name TO holiday-name
             READ holidaysIX KEY IS holiday-name
             IF holiday-status NOT = "00"
               DISPLAY "READ FAILED: ", holiday-status UPON SYSERR
             ELSE 
               DISPLAY "READ SUCCESSFUL: ", holiday-status UPON SYSERR
               DELETE holidaysIX RECORD  
               IF holiday-status NOT = "00"
                 DISPLAY "DELETE FAILED!: ", holiday-status UPON SYSERR
               ELSE   
                 DISPLAY "DELETE SUCCESSFUL!: ", holiday-status
                                                       UPON SYSERR
                 MOVE HOLIDAY-RECORD TO HOL-REC
               END-IF
             END-IF 
             PERFORM UPDATE-HOL-IO-MSG
             MOVE holiday-io-msg TO hol-io-msg
      *
             CLOSE holidaysIX
             DISPLAY "CLOSE Status: ", holiday-status UPON SYSERR
           END-IF.
      *     
           GOBACK.
      *
       UPDATE-HOL-IO-MSG.     
           INITIALIZE hol-io-msg.
           STRING "HOLIDAY-STATUS:" DELIMITED BY SIZE, 
                   holiday-status DELIMITED BY SIZE, 
                   INTO holiday-io-msg.
      * 
