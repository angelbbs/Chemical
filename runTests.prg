#define ES_CENTER                 1

Function RunTests(TestName)
local tresult:=.t.
local cUserName:=SPACE(50)
local cUserFam:=SPACE(50)
local cUserSchool:=SPACE(50)
local cUserKlass:=SPACE(50)
public tmpPath:=alltrim(GETENV("TEMP"))+"\"

SET DATE FORMAT "dd.mm.yyyy"

 DEFINE DIALOG oDlgUserData NAME "UserData"
   REDEFINE GET oUserName VAR cUserName ID 101 OF oDlgUserData
   REDEFINE GET oUserFam VAR cUserFam ID 102 OF oDlgUserData
   REDEFINE GET oUserSchool VAR cUserSchool ID 104 OF oDlgUserData
   REDEFINE GET oUserKlass VAR cUserKlass ID 103 OF oDlgUserData
   REDEFINE BUTTON oBtnTestNext ID 1 OF oDlgUserData ACTION oDlgUserData:End()
   REDEFINE BUTTON oBtnTestCancel ID 2 OF oDlgUserData ACTION ( tresult:=.f., oDlgUserData:End() )
 ACTIVATE DIALOG oDlgUserData CENTERED

     if tresult=.f.
      return nil
     end if

 StartTests(TestName, cUserName, cUserFam, cUserSchool, cUserKlass)

return nil


Function StartTests(TestName, cUserName, cUserFam, cUserSchool, cUserKlass)

local TestFile:=""
local errorTest:=""

select 7
for nZTest=1 to lastrec()
 go nZTest
  if alltrim(TestName)==alltrim(TNAME)
   TestFile:=alltrim(TFILE)
  end if
next

select 71
use ("Tests\"+TestFile)
kolQ=lastrec()
//for nZTest=1 to lastrec()
for nZTest=1 to kolQ
 go nZTest
   questionFile:=QFILE
   Answer1File:=AFILE1
   Answer2File:=AFILE2
   Answer3File:=AFILE3
   Answer4File:=AFILE4
   TrueAnswer:=ATRUE
   Title = TestName +":  "+"Вопрос "+alltrim(str(nZTest))+" из "+alltrim(str(lastrec()))
    resultTest=StepTest(questionFile, Answer1File, Answer2File, Answer3File, Answer4File, TrueAnswer, Title)
     if resultTest="Cancel"
       ?"Тестирование прервано!"
       return nil
     end if
     if resultTest="1" //Правильно
     end if
     if resultTest="0" //Неправильно
      errorTest=errorTest+alltrim(str(nZTest))+"    "
     end if
next

 testReport(TestName+" ("+alltrim(str(kolQ))+" вопросов )", cUserName, cUserFam, cUserSchool, cUserKlass, errorTest)

return nil

//
Function StepTest(questionFile, Answer1File, Answer2File, Answer3File, Answer4File, TrueAnswer, Title)
local oRTFTestQ, oRTFTestA1, oRTFTestA2, oRTFTestA3, oRTFTestA4
local nAnswer:=1
local tresult:="1"


DEFINE DIALOG oDlgTest NAME "showTest" TITLE (title)

 REDEFINE RICHEDIT oRTFTestQ OF oDlgTest ID 200 FILENAME (questionFile)
 REDEFINE RICHEDIT oRTFTestA1 OF oDlgTest ID 201 FILENAME (Answer1File)
 REDEFINE RICHEDIT oRTFTestA2 OF oDlgTest ID 202 FILENAME (Answer2File)
 REDEFINE RICHEDIT oRTFTestA3 OF oDlgTest ID 203 FILENAME (Answer3File)
 REDEFINE RICHEDIT oRTFTestA4 OF oDlgTest ID 204 FILENAME (Answer4File)

 REDEFINE RADIO nAnswer ID 16, 18, 20, 22 OF oDlgTest

 REDEFINE BUTTON oBtnTestNext ID 301 OF oDlgTest ACTION oDlgTest:End()
 REDEFINE BUTTON oBtnTestCancel ID 302 OF oDlgTest ACTION ( tresult:="Cancel", oDlgTest:End() )


   ACTIVATE DIALOG oDlgTest CENTERED

if tresult="Cancel"
 return tresult
end if

if val(TrueAnswer)==nAnswer
 tresult:="1"
else
 tresult:="0"
end if

return tresult

Function testReport(TestName, cUserName, cUserFam, cUserSchool, cUserKlass, errorTest) //Отчет о выполнении тестов

local oRTFReport, oWndReport

DEFINE GTF FONT oFontGTF ; // ** 1 **  Заголовок
       NAME "Arial";
       HEIGHT 18*1.3;
       WIDTH 0;
       BOLD
DEFINE GTF FONT oFontGTF ; // ** 2 **
       NAME "Arial";
       HEIGHT 14*1.3;
       WIDTH 0

GTF oGTF FILE (tmpPath+"temp.gtf")



GTF WRITE ("Результаты ответов на контрольные вопросы") OF oGTF ;
    ALIGN ES_CENTER;
    FONT 1;
    COLOR CLR_BLACK;
    RETURN

GTF WRITE (alltrim(cUserName)+" "+alltrim(cUserFam)) OF oGTF ;
    ALIGN ES_CENTER;
    FONT 2;
    COLOR CLR_BLACK;
    RETURN
GTF WRITE (alltrim(cUserSchool)+",     "+alltrim(cUserKlass)) OF oGTF ;
    ALIGN ES_CENTER;
    FONT 2;
    COLOR CLR_BLACK;
    RETURN


GTF RETURN OF oGTF
GTF WRITE (alltrim(dtoc(DATE() ))) OF oGTF ;
    ALIGN ES_CENTER;
    FONT 2;
    COLOR CLR_BLACK;
    RETURN


GTF RETURN OF oGTF


GTF WRITE TestName OF oGTF ;
    ALIGN ES_CENTER;
    FONT 1;
    COLOR CLR_BLACK;
    RETURN


  GTF RETURN OF oGTF
  GTF RETURN OF oGTF

if len(errorTest)<>0
  GTF WRITE "Номера контрольных вопросов, на которые дан неверный ответ: " OF oGTF ;
      ALIGN ES_CENTER;
      FONT 2;
      COLOR CLR_BLACK;
      RETURN

  GTF WRITE errorTest OF oGTF ;
      ALIGN ES_CENTER;
      FONT 2;
      COLOR CLR_BLACK;
      RETURN

else

  GTF WRITE "На все вопросы даны правильные ответы!" OF oGTF ;
      ALIGN ES_CENTER;
      FONT 2;
      COLOR CLR_BLACK;
      RETURN

end if


ENDGTF oGTF

cGTF:=memoread(tmpPath+"temp.gtf")
cRTF:=GTFToRTF( cGTF )
memowrit(tmpPath+"temp.rtf", cRTF )

DEFINE WINDOW oWndReport FROM 5,5 TO 35,85;
 TITLE "Просмотр результатов" NOZOOM NOMINIMIZE BORDER NONE

 DEFINE BUTTONBAR oBar OF oWndReport _3D SIZE 26, If( LargeFonts(), 23, 27 ) UPDATE

   DEFINE BUTTON RESOURCE "Printer" OF oBar GROUP ;
          MESSAGE "Печать" TOOLTIP "Печать" NOBORDER ;
          ACTION ( oRTFReport:Print("Просмотр результатов",150,200,150,150), oRTFReport:SetFocus() )


@ 0, 0 RICHEDIT oRTFReport VAR cRTF OF oWndReport ;
       SIZE 200,200 FILENAME ( tmpPath+"temp.rtf" ) READONLY


oWndReport:oClient := oRTFReport


ACTIVATE WINDOW oWndReport

sysrefresh()


return nil
