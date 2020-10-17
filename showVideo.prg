function showVideo(nVideoType)
public oDlgVideo, cVideoInfo, oVideoInfo, oJpgVideo, cJpgVideo, cVideoCopyRight, oSayCopyRight

cJpgVideo:=""

nVideo=1
public aVideo:={}

if nVideoType=3
 select 3
end if
if nVideoType=4
 select 4
end if

for nZ=1 to lastrec()
 go nZ
 AADD(aVideo,oName)
next

select 1


public oBtnVideoPlay

  DEFINE DIALOG oDlgVideo NAME "showVideo"

  REDEFINE COMBOBOX nVideo ID 13 ITEMS aVideo  OF oDlgVideo ON CHANGE GetVideoInfo(nVideo)
  REDEFINE GET oVideoInfo VAR cVideoInfo ID 11 OF oDlgVideo MULTILINE
  REDEFINE IMAGE oJpgVideo ID 102 OF oDlgVideo FILENAME cJpgVideo ADJUST
  REDEFINE SAY oSayCopyRight VAR cVideoCopyRight ID 501 OF oDlgVideo

   REDEFINE BUTTON oBtnVideoPlay ID 10 OF oDlgVideo ;
      ACTION showVideo1(nVideo)


  ACTIVATE DIALOG oDlgVideo CENTERED ON INIT GetVideoInfo(nVideo)



return nil

Function GetVideoInfo(nVideo)

if nVideoType=3
 select 3
end if
if nVideoType=4
 select 4
end if
 go nVideo
 cVideoName := oName
 cVideoFile := oVideo
 cVideoTxt := oTxt
 cVideoCopyRight := oCopyR
 oSayCopyRight:SetText(cVideoCopyRight)
select 1


if !file("Video\"+cVideoFile)
 oBtnVideoPlay:Disable()
else
 oBtnVideoPlay:Enable()
end if

 cVideoInfo:=memoread("Video\"+cVideoTxt)
 cJpgVideo=STRTRAN("Video\"+cVideoFile, "avi", "jpg")
if !file(cJpgVideo)
  cJpgVideo="Video\nopic.jpg"
end if

oJpgVideo:LoadImage( , cJpgVideo )
oVideoInfo:Refresh()
oJpgVideo:Refresh()

return nil


Function showVideo1(nVideo)
public oWndVideo, oVideo

oDlgVideo:Disable()

if nVideoType=3
 select 3
end if
if nVideoType=4
 select 4
end if
 go nVideo
 cVideoName := oName
 cVideoFile := oVideo
 cVideoTxt := oTxt
select 1



   DEFINE WINDOW oWndVideo FROM 0,0 TO 524+65,640+2 PIXEL OF oDlgVideo TITLE cVideoName;
   BORDER NONE NOICONIZE NOZOOM COLOR CLR_WHITE, CLR_BLACK

   public oBtnPlay, oBtnPause, oBtnStop

public oSlideVideo, oTimerVideo, oSayPos
public nSlideVideo:=0
public cSayPos:="             "

   @ 524+23-18, 2 BTNBMP oBtnPlay SIZE 32, 32 ;
      RESOURCE "Play1"  OF oWndVideo ACTION ( oBtnPlay:Disable(), oVideo:oMci:Play(0), oBtnStop:Enable(), oBtnPause:Enable(), oTimerVideo:Activate(), oSlideVideo:Enable() )

   @ 524+23-18, 36 BTNBMP oBtnPause SIZE 32, 32 ;
      RESOURCE "Pause1"  OF oWndVideo ACTION (oVideo:ControlPlay() )

   @ 524+23-18, 70 BTNBMP oBtnStop SIZE 32, 32 ;
      RESOURCE "Stop1"  OF oWndVideo ACTION ( oBtnStop:Disable(), oVideo:oMci:Stop(), oBtnPlay:Enable(), oBtnPause:Disable(), oTimerVideo:Deactivate(), oSlideVideo:Disable() )

   ACTIVATE WINDOW oWndVideo VALID (oVideo:End(), oDlgVideo:Enable() )

define timer oTimerVideo dialog oDlgVideo interval 1000 action ( UpdateVideoInfo() )


@ 0,  0 VIDEO oVideo FILE "Video\"+cVideoFile SIZE 640,524 OF oWndVideo ADJUST NOBORDER

  @ 524+3, 110 SLIDER oSlideVideo VAR nSlideVideo OF oWndVideo ;
            HORIZONTAL ;
            TOP DIRECTION ;
            RANGE 0, oVideo:oMci:Length() ;
            MARKS 22;
            EXACT ;
            SIZE 210, 23 PIXEL ;
            COLOR CLR_WHITE, CLR_BLACK;
            UPDATE ;
            ON CHANGE oVideo:Play(nSlideVideo);
            ON THUMBPOS ( oTimerVideo:Deactivate(), oVideo:Pause(), oVideo:Play(nSlideVideo), oTimerVideo:Activate() )

   @ 36.5, 31 SAY oSayPos PROMPT cSayPos

sysrefresh()
inkey(0.1)
oVideo:Play()
oTimerVideo:Activate()
sysrefresh()

return nil

Function UpdateVideoInfo()

oSlideVideo:Set( oVideo:oMci:Position() )
oSayPos:SetText( alltrim(str(int(oVideo:oMci:Position()/25)))+" / "+alltrim(str(int(oVideo:oMci:Length()/25)))+" сек." )

if oVideo:oMci:Position() >= oVideo:oMci:Length()
 oBtnStop:Disable()
 oVideo:oMci:Stop()
 oBtnPlay:Enable()
 oBtnPause:Disable()
 oTimerVideo:Deactivate()
 oSlideVideo:Disable()
end if

return nil