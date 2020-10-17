function ShowElem(nElement,cToolTip)
   local cRTF  := ""
public cFile := "tryt.avi"
public oWndElem, oGroup, oBar
public oVideo
public nDesktopHeight := GetSysMetrics( 0 )
public nDesktopWidth  := GetSysMetrics( 1 )
public oldWidth, oldHeight
bFile:=""
vFile:=""
rFile:=""
if valtype(nElement)=="N"
 bFile="Periodic Table\element"+alltrim(str(nElement))+".bmp"
 vFile="Periodic Table\element"+alltrim(str(nElement))+".avi"
 rFile="Periodic Table\element"+alltrim(str(nElement))+".rtf"
end if

if valtype(nElement)=="C"
 vFile="Periodic Table\"+alltrim(nElement)+".avi"
 rFile="Periodic Table\"+alltrim(nElement)+".rtf"
end if


 if !file(vFile)
  vFile="Periodic Table\world.avi"
 end if

 if !file(rFile) //Информации нет - нечего окно показывать
  oWnd:Enable()
  return nil
 end if




   DEFINE FONT oFont NAME "Arial" SIZE 0, -40*(nDesktopHeight/1024)


 DEFINE WINDOW oWndElem FROM nDesktopWidth/10, nDesktopHeight/10;
  TO nDesktopWidth - nDesktopWidth/10, nDesktopHeight-nDesktopHeight/10;
  PIXEL TITLE alltrim(cToolTip);
  NOZOOM NOMINIMIZE BORDER NONE COLOR CLR_WHITE, 0

    if file(bFile)
      @ (nDesktopWidth/1400)*288-54, (nDesktopWidth/1400)*352+5 BITMAP oBmpElem;
      FILENAME (bFile);
      OF oWndElem PIXEL NOBORDER  TOOLTIP cToolTip
    end


  @  (nDesktopWidth/72), 0 RICHEDIT oRTF VAR cRTF OF oWndElem;
    SIZE nDesktopHeight-nDesktopHeight/10-nDesktopHeight/10 - 5,;
        nDesktopWidth - nDesktopWidth/10 -nDesktopWidth/10 - (nDesktopWidth/1400)*288 -27;
           FILE (rFile)  READONLY

  @ 1, 35 SAY oSay PROMPT alltrim(cToolTip);
    SIZE (nDesktopWidth/1400)*1000, (nDesktopWidth/1400)*100 FONT oFont OF oWndElem

oldWidth = oWndElem:nWidth
oldHeight = oWndElem:nHeight


oldTop = oWndElem:nTop
oldLeft = oWndElem:nLeft
oldBottom = oWndElem:nBottom
oldRight = oWndElem:nRight
isClose=.f.

   ACTIVATE WINDOW oWndElem ON INIT playvideo(vFile);
    VALID  ( oWnd:Enable(), oVideo:End() )
return nil
//----------------------------------------------------------------------------//

Function PlayVideo(vFile)


 @ 0,  0 VIDEO oVideo FILE (vFile) SIZE (nDesktopWidth/1400)*352, (nDesktopWidth/1400)*288 OF oWndElem NOBORDER ADJUST
oVideo:Loop()
cursorarrow()
return nil

Function RefreshVideo() //Передвинем окно, чтоб видео прорисовалось

oldTop = oWndElem:nTop
oldLeft = oWndElem:nLeft
oldBottom = oWndElem:nBottom
oldRight = oWndElem:nRight
oWndElem:Move(oldTop+1, oldLeft, 0, 0 , .t.)
oWndElem:Move(oldTop-1, oldLeft, 0, 0 , .t.)

return nil
