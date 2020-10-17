#include "FiveWin.ch"
#INCLUDE "video.CH"
#include "RichEdit.ch"
#include "Slider.ch"
#include "Image.ch"
#include "FileGTF.ch"

#include "progdate.ch"
#include "progtime.ch"

GLOBAL aElements:={}


FUNCTION Main()

public oWnd, oIntroDlg, oTimer

public oCursorHand, oCursorWait, oCursorArrow
public nVideoType
public mustResized:=.f.
PUBLIC hDLL := LoadLibrary( "Riched20.dll" )

prgtime:=left(progtime,len(progtime)-3 )
myLogo1:="Сборка "+OemToAnsi(progdate)+" "+prgtime
//?CURDIR()

   DEFINE WINDOW oIntroWnd FROM 0,0 TO 0,0 BORDER NONE;
          NOSYSMENU NOCAPTION NOICONIZE NOZOOM
    define timer oTimer dialog oIntroWnd interval 2000 action ( OnIntroPaint() )

   DEFINE DIALOG oIntroDlg FROM 0,0 TO 2,2 SIZE 396, 298 STYLE nOR( WS_POPUP, WS_VISIBLE )
   @ 0, 0 BITMAP oBmp RESOURCE "Intro" OF oIntroDlg SIZE 400, 300 NOBORDER PIXEL
   oBmp:bPainted = { || SetBkMode( oBmp:hDC, 1 ), SetTextColor( oBmp:hDC, CLR_WHITE ),;
                        TextOut( oBmp:hDC, 280, 2, " "+myLogo1 ) }
   oBmp:blClicked = { || OnIntroPaint() }
   ACTIVATE DIALOG oIntroDlg CENTERED ON INIT ( oTimer:Activate() )



if !file("Periodic Table\ptable.dbf")
  pTable := {}
   AADD(pTable, { "pNumber", "C",6, 0 })
   AADD(pTable, { "pNaim", "C",12, 0 })
   AADD(pTable, { "pInfo", "C",50, 0 })
  DBCREATE("Periodic Table\ptable.dbf", pTable)
  select 1
  use "Periodic Table\ptable.dbf"
  Append blank
  close 1
 msgStop("База данных периодической таблицы элементов разрушена!")
 quit
end if

if !file("Biography\btable.dbf")
  bTable := {}
   AADD(bTable, { "bName", "C",40, 0 })
   AADD(bTable, { "bFile", "C",20, 0 })
  DBCREATE("Biography\btable.dbf", bTable)
  select 2
  use "Biography\btable.dbf"
  Append blank
  close 2
 msgStop("База данных биографий разрушена!")
 quit
end if






select 1
use "Periodic Table\ptable.dbf" SHARED
INDEX ON PNUMBER TO "Periodic Table\ptable.ntx"
close 1
use "Periodic Table\ptable.dbf" INDEX "Periodic Table\ptable.ntx" SHARED READONLY

select 2
use "Biography\btable.dbf" SHARED READONLY


if !file("Video\Experience.dbf")
 msgstop("Отсутствует файл Video\Experience.dbf!")
 close all
 quit
end if
select 3
use "Video\Experience.dbf" SHARED READONLY

if !file("Video\Information.dbf")
 msgstop("Отсутствует файл Video\Information.dbf!")
 close all
 quit
end if
select 4
use "Video\Information.dbf" SHARED READONLY


if !file("Periodic Table\long.dbf")
 msgstop("Отсутствует файл Periodic Table\long.dbf!")
 close all
 quit
end if
select 5
use "Periodic Table\long.dbf" SHARED READONLY

if !file("Periodic Table\short.dbf")
 msgstop("Отсутствует файл Periodic Table\short.dbf!")
 close all
 quit
end if
select 6
use "Periodic Table\short.dbf" SHARED READONLY


if !file("Tests\tests.dbf")
  tTable := {}
   AADD(tTable, { "tName", "C",40, 0 })
   AADD(tTable, { "tFile", "C",40, 0 })
  DBCREATE("Tests\tests.dbf", tTable)
  select 7
  use "Tests\tests.dbf"
  Append blank
  close 7
 msgStop("База данных контрольных вопросов разрушена!")
 quit
end if



if !file("Tests\tests.dbf")
 msgstop("Отсутствует файл Tests\tests.dbf!")
 close all
 quit
end if
select 7
use "Tests\tests.dbf" SHARED READONLY





DEFINE CURSOR oCursorHand HAND
DEFINE CURSOR oCursorWait WAIT
DEFINE CURSOR oCursorArrow ARROW

   DEFINE WINDOW oWnd FROM 0,0 TO 10,20 TITLE "Урок химии   ("+myLogo1+")";
    MENU SetMenu() COLOR CLR_BLACK,CLR_HGRAY
    SET MESSAGE OF oWnd TO "" CLOCK DATE KEYBOARD
   oWnd:SetIcon( TIcon():New( ,, "Main" ) )


   ACTIVATE WINDOW oWnd MAXIMIZED ON RESIZE resizeTable()  ON INIT FillKletka("long")



RETURN ( nil )

Function FillKletka(tabletype)
//Заполняем клетки

 cursorwait()


//if valtype(aElements)<>NIL
if len(aElements)<>0
 for nElement=1 to len(aElements)
  oBmpName=aElements[nElement][1]
  &oBmpName:End()
  &oBmpName:Destroy()
//  oCursorHand:End()
//sysrefresh()
 next
 sysrefresh()
 aElements:={}

DEFINE CURSOR oCursorHand HAND
DEFINE CURSOR oCursorWait WAIT
DEFINE CURSOR oCursorArrow ARROW

end if



if tabletype=="long"
 select 5
// ASIZE( aElements, lastrec() )
end if
if tabletype=="short"
 select 6
// ASIZE( aElements, lastrec() )
end if


kZap=lastrec()
for nZPT=1 to kZap

  if tabletype=="long"
   select 5
  end if
  if tabletype=="short"
   select 6
  end if

  go nZPT
  hKletka=val(alltrim(POSY))
  vKletka=val(alltrim(POSX))
  cFileName = alltrim(KNAME)
  hKletkaSize = val(alltrim(SIZEY))
  vKletkaSize = val(alltrim(SIZEX))
  hKletkaKoef = val(alltrim(KOEFY))
  vKletkaKoef = val(alltrim(KOEFX))
   if alltrim(LBORDER)=="0"
    isBorder=.f.
   else
    isBorder=.t.
   end if
   if alltrim(LFIXEDS)=="0"
    isFixedSize=.f.
   else
    isFixedSize=.t.
   end if


DispKletka(hKletka, vKletka, cFileName, isBorder, isFixedSize, hKletkaSize, vKletkaSize, hKletkaKoef, vKletkaKoef) //Отрисовка клетки

next
sysrefresh()
cursorarrow()
mustResized=.t.
resizeTable()


return nil



Function ResizeTable()

if mustResized=.f.
 return nil
end if

for nElement=1 to len(aElements) //Пересчитаем позицию всех элементов

oBmpName=aElements[nElement][1]
hKletka=aElements[nElement][2]
vKletka=aElements[nElement][3]
isFixedSize=aElements[nElement][4]
hKletkaSize=aElements[nElement][5]
vKletkaSize=aElements[nElement][6]
hKletkaKoef=aElements[nElement][7]
vKletkaKoef=aElements[nElement][8]
   oldWidth = &oBmpName:nWidth
   oldHeight = &oBmpName:nHeight
   &oBmpName:nTop:=((vKletka*oldHeight)-oldHeight)/(746/oWnd:nHeight)*vKletkaKoef
   &oBmpName:nLeft:=((hKletka*oldWidth)-oldWidth)/(1032/oWnd:nWidth)*hKletkaKoef
   &oBmpName:nWidth:=(oWnd:nWidth)/(1032/hKletkaSize)
   &oBmpName:nHeight:=(oWnd:nHeight)/(746/vKletkaSize)
next

return nil


Function DispKletka(hKletka, vKletka, cFileName, isBorder, isFixedSize, hKletkaSize, vKletkaSize, hKletkaKoef, vKletkaKoef) //Отрисовка клетки
local cToolTip:=" ", nElement:=0
local  cMessage:=""
local  cNaimE:=""
local  cAtom:=""
local  cT_Kip:=""
local  cT_Plav:=""
local  cIon:=""
local  cElectro:=""
local  cRad:=""
local  cPlotn:=""


DEFAULT isFixedSize:=.t.



oBmpName= left( cFileName, at(".",cFileName)-1 )
oBmpName = right(oBmpName, len(oBmpName)-rat("\", oBmpName) )
public &oBmpName
AADD(aElements, {oBmpName, hKletka, vKletka, isFixedSize, hKletkaSize, vKletkaSize, hKletkaKoef, vKletkaKoef} )

select 1


if left(oBmpName,7) == "element" //Элементы
 nElement=val(STRTRAN(oBmpName,"element","")) //Если число, то элемент

Seek (alltrim(str(nElement)))

    cToolTip=alltrim(PNAIM)
    cMessage=alltrim(PNAIM)
    cNaimE=alltrim(PNAIM_E)
    cAtom=alltrim(ATOM)
    cT_Kip=alltrim(T_KIP)
    cT_Plav=alltrim(T_PLAV)
    cIon=alltrim(ION)
    cElectro=alltrim(ELECTRO)
    cRad=alltrim(RAD)
    cPlotn=alltrim(PLOTN)
end if


do case
  case left(oBmpName,1) == "I" .or. left(oBmpName,1) == "V"  //Группы
   for nZ=1 to lastrec()
    go nZ
    if alltrim(pNUMBER)==alltrim(oBmpName)
     cToolTip=alltrim(PINFO)
     cMessage=alltrim(PNAIM)
     nElement=alltrim(pNUMBER)
    end if
   next

  case Left(oBmpName,4) == "lant"
   for nZ=1 to lastrec()
    go nZ
    if alltrim(pNUMBER)=="Lant"
     cToolTip=alltrim(PINFO)
     cMessage=alltrim(PNAIM)
     nElement="Lantanoid"
    end if
   next

  case Left(oBmpName,4) == "acti"
   for nZ=1 to lastrec()
    go nZ
    if alltrim(pNUMBER)=="Act"
     cToolTip=alltrim(PINFO)
     cMessage=alltrim(PNAIM)
     nElement="Actinoid"
    end if
   next

end case

//if isFixedSize=.t.
  if isBorder = .f.
   @ ((vKletka*vKletkaSize)-vKletkaSize)*vKletkaKoef, ((hKletka*hKletkaSize)-hKletkaSize)*hKletkaKoef BITMAP &oBmpName FILENAME cFileName;
     ADJUST SIZE hKletkaSize, vKletkaSize PIXEL OF oWnd;
     on right click ( rClickAction(nElement,cToolTip,cNaimE, cAtom, cT_Kip, cT_Plav, cIon, cElectro, cRad, cPlotn) );
     on left click ( lClickAction(nElement,cToolTip) );
     NOBORDER CURSOR oCursorHand MESSAGE cMessage TOOLTIP cToolTip
  else
   @ ((vKletka*vKletkaSize)-vKletkaSize)*vKletkaKoef, ((hKletka*hKletkaSize)-hKletkaSize)*hKletkaKoef BITMAP &oBmpName FILENAME cFileName;
     ADJUST SIZE hKletkaSize, vKletkaSize PIXEL OF oWnd;
     on right click ( rClickAction(nElement,cToolTip,cNaimE, cAtom, cT_Kip, cT_Plav, cIon, cElectro, cRad, cPlotn) );
     on left click ( lClickAction(nElement,cToolTip) ) CURSOR oCursorHand;
     MESSAGE cMessage TOOLTIP cToolTip
  end if


return nil


Function lClickAction(nElement,cToolTip)
cursorwait()
oWnd:Disable()
ShowElem(nElement,cToolTip)
return nil

Function rClickAction(nElement,cToolTip,cNaimE, cAtom, cT_Kip, cT_Plav, cIon, cElectro, cRad, cPlotn)

if valtype(nElement)<>"N"
 return nil
end if
if nElement < 1
 return nil
end if


cInfo="Атомный номер: "+alltrim(str(nElement))+CRLF;
     +"Русское название: "+alltrim(cToolTip)+CRLF;
     +"Английское название: "+alltrim(cNaimE)+CRLF;
     +"Атомная масса: "+alltrim(cAtom)+CRLF

 if len(alltrim(cT_Plav))>0
     cInfo=cInfo+"Температура плавления (K): "+alltrim(cT_Plav)+CRLF
 end if
 if len(alltrim(cT_Kip))>0
     cInfo=cInfo+"Температура кипения (K): "+alltrim(cT_Kip)+CRLF
 end if
 if len(alltrim(cIon))>0
     cInfo=cInfo+"Потенциал ионизации: "+alltrim(cIon)+CRLF
 end if
 if len(alltrim(cElectro))>0
     cInfo=cInfo+"Электроотрицательность"+CRLF+"по Оллерду-Рохову: "+alltrim(cElectro)+CRLF
 end if
 if len(alltrim(cRad))>0
     cInfo=cInfo+"Ковалентный радиус: "+alltrim(cRad)+CRLF
 end if
 if len(alltrim(cPlotn))>0
     cInfo=cInfo+"Плотность (г/л): "+alltrim(cPlotn)
 end if

 msginfo(cInfo,cToolTip)
return nil


static function SetMenu()

local oMenu
public cBiographyFile, cBiographyName, nBiography, oMenuBiography, oVariableName

   MENU oMenu
        MENUITEM "Периодическая таблица"
        MENU
            MENUITEM "Длинные периоды"  MESSAGE "Длинные периоды" ;
                     ACTION FillKletka("long")
            MENUITEM "Короткие периоды"  MESSAGE "Короткие периоды" ;
                     ACTION FillKletka("short")
        ENDMENU

        MENUITEM "Биографии"

        MENU

          select 2
           for nBiography=1 to lastrec()
            go nBiography
            cBiographyName := alltrim(BNAME)
            cBiographyFile := alltrim(BFILE)
            oVariableName := cBiographyFile
            public &oVariableName
            MENUITEM &oVariableName PROMPT (cBiographyName) MESSAGE "Биография "+(cBiographyName) ;
                     ACTION showBiography(&oVariableName:cPrompt)

           next
        ENDMENU

        MENUITEM "Видеофрагменты"
        MENU
            MENUITEM "Химические опыты"  MESSAGE "Демонстрация химических опытов" ;
                     ACTION ( nVideoType:=3, showVideo(nVideoType) )
            MENUITEM "Информационные"  MESSAGE "Информационные видеофрагменты" ;
                     ACTION ( nVideoType:=4, showVideo(nVideoType) )

        ENDMENU

        MENUITEM "Контрольные вопросы"
        MENU
          select 7
           for nTest=1 to lastrec()
            go nTest
            cTestName := alltrim(TNAME)
            cTestFile := alltrim(TFILE)

         if file("Tests\"+cTestFile)
            oVariableName := cTestFile
            public &oVariableName

            MENUITEM &oVariableName PROMPT (cTestName) MESSAGE (cTestName) ;
                     ACTION runTests(&oVariableName:cPrompt)
         end if
           next

        ENDMENU


        MENUITEM "О программе"
        MENU
            MENUITEM "Информация"  MESSAGE "Информация" ;
                     ACTION ProgInfo()

        ENDMENU

   ENDMENU

return oMenu

function OnIntroPaint()
oTimer:Deactivate()
oTimer:End()

oIntroDlg:End()
return .t.

Function ProgInfo()
//   DEFINE DIALOG oIntroDlg FROM 0,0 TO 2,2 SIZE 396, 298 TITLE "Информация о программе"

//   @ 7,1 BUTTON "Закрыть" of oIntroDlg ACTION oIntroDlg:End()

//   ACTIVATE DIALOG oIntroDlg CENTERED
//?FWCOPYRIGHT , FWVERSION
//MsgAbout( FWVERSION, FWCOPYRIGHT )
pInfo1="Разботчик Галкин А.В., Руководитель Андреев В.В."+CRLF;
+FWVERSION+", "+VERSION()

MsgAbout( "Урок химии  ("+myLogo1+")", pInfo1 )


return nil


#include "bitmap.prg"
#include "showelem.prg"
#include "showBiography.prg"
#include "showVideo.prg"
#include "runTests.prg"

#include "tmci.prg"
#include "video.prg"
#include "gtf.prg"
#include "trichedi.prg"
#include "pragma.prg"
