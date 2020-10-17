/* Ampliaciones de la Clase TVideo by TheFull
   para AVIS, MPEGs y MOV

   DATA cStatus -> Informa sobre el estado del dispositivo
        lResize -> Si permitimos redimensionado.

   METHOD Pause() -> Hacer Pausa, si esta en pausa, continuar
          Resume()-> Continuar
          Play()  -> Si ha sido pausado, continuar
          Repeat()-> Loop continuo de una avi
          Status()-> Pregunta por el estado del dispositivo
          End()   -> Cierra dispositivo
      lStretch()  -> No para el avi, asi si redimensionamos la ventana del video,
                     el video se adapta a la nueva resolucion de la ventana contenedora ,
                     tal y como hace el Media Player de Moco$oft
      HandleEvent() -> Acoplando objectos en la llamada SIZE del sistema
                      Nueva modificacion. Ahora con el raton en la ventana lo
                      ponemos en marcha o hacemos pausa.
                      Cambiamos el cursor( Mano ).Simulando al Media Player.
      New()         -> Nuevo paso de parametros, lResize y lStrech
      Refresh()     -> Refresca posicion de la ventana contenedora

      */

#include "FiveWin.ch"
#include "Constant.ch"

#define MCI_OPEN     2051  //                 0x0803
#define MCI_CLOSE    2052  //                 0x0804
#define MCI_ESCAPE   2053  //                 0x0805
#define MCI_PLAY     2054  //                 0x0806
#define MCI_SEEK     2055  //                 0x0807
#define MCI_STOP     2056  //                 0x0808
#define MCI_PAUSE    2057  //                 0x0809
#define MCI_RESUME   2133  //                 0x0855


#ifdef __XPP__
#define Super ::TControl
#endif

//global cBuffer

//----------------------------------------------------------------------------//

CLASS TVideo FROM TControl

   CLASSDATA lRegistered AS LOGICAL

   CLASSDATA aProperties INIT {"cAviFile", ;
                               "lStretch", ;
                               "nAlign",   ;
                               "nHeight",  ;
                               "nLeft",    ;
                               "nTop",     ;
                               "nWidth" }
  /*Posibles valores del estado del dispositivo

   CLASSDATA aState      INIT {"not ready", ;
                               "paused", ;
                               "playing",   ;
                               "stopped"} */
   DATA   cAviFile
   DATA   cBuffer
   DATA   lxStretch
   DATA   lResize
   DATA   oMci
   DATA   bSignal
//   DATA   nWidth
//   DATA   nHeight

   METHOD New( nRow, nCol, nWidth, nHeight, cFileName, oWnd,;
               bWhen, bValid, lNoBorder, lResize,lStretch ) CONSTRUCTOR

   METHOD ReDefine( nId, cFileName, oDlg, bWhen, bValid ) CONSTRUCTOR

   METHOD Initiate( hDlg )

   METHOD Inspect ( cData )

   METHOD OpenFile()

   METHOD lStretch( lNewVal ) SETGET

   METHOD End() INLINE  ( ::oMci:End() )

   METHOD HandleEvent( nMsg, nWParam, nLParam )

//   METHOD Refresh() INLINE  ( ::lxStretch )
//   METHOD Refresh() INLINE  if(::lResize,(::oWnd:Resize(), ::lStretch( ::lxStretch )),(::lStretch( ::lxStretch )))
   METHOD Refresh() INLINE  (::oWnd:Resize(), ::lStretch( ::lxStretch ) )
//   METHOD Refresh() INLINE  ( ::lStretch( ::lxStretch ) )
//   METHOD Refresh() INLINE  (::oWnd:Resize() )


   METHOD Play( nFrom, nTo ) INLINE ::oMci:Play( nFrom, nTo )
   METHOD Pause()  INLINE ::oMci:Pause()
   METHOD Stop()   INLINE ::oMci:Stop()
   METHOD Repeat() INLINE ::oMci:Repeat()
   METHOD Loop()   INLINE ::Repeat()
   METHOD FullScreen( lMode ) INLINE ::oMci:lFullScreen := lMode
   METHOD ControlPlay()

ENDCLASS


//----------------------------------------------------------------------------//

METHOD New( nRow, nCol, nWidth, nHeight, cFileName, oWnd, lNoBorder,lResize,lStretch ) CLASS TVideo
Local nHandle := 0

   DEFAULT nRow := 10, nCol := 10, nWidth := 200, nHeight := 200,;
           cFileName := "", oWnd := GetWndDefault(), lNoBorder := .f.
public cBuffer

   cBuffer := space( 200 )

   ::lResize := lResize

   ::nTop      = nRow //*  VID_CHARPIX_H  // 8
   ::nLeft     = nCol //* VID_CHARPIX_W   // 14
   ::nBottom   = ::nTop  + nHeight // - 1
   ::nRight    = ::nLeft + nWidth  //+ 1
   ::nStyle    = nOR( WS_CHILD, WS_VISIBLE, WS_TABSTOP, If( ! lNoBorder, WS_BORDER, 0 ),;
                      if( lResize, WS_THICKFRAME, 0 ) )
   ::nId       = ::GetNewId()
   ::oWnd      = oWnd
   ::cAviFile  = cFileName
   ::oMci      = TMci():New( "MPEGVideo!", cFileName, Self )
   ::lDrag     = .f.
   ::lCaptured = .f.
   ::lxStretch := lStretch
   ::oMci:lAudio       := .T.           // Por defecto esta activado el Sonido

   ::Register( nOR( CS_VREDRAW, CS_HREDRAW ) )

   if ! Empty( oWnd:hWnd )
      ::Create()
      ::oMci:lOpen(cFileName,,Self)
      ::oMci:SetWindow( Self )
      ::Refresh()
//      ::lxStretch()
   else
      oWnd:DefControl( Self )
   endif

   ::bLClicked  := {|| ::ControlPlay() }
//   ::bRClicked  := {|| ::OpenFile()    }


//::SetFocus()

return Self


//----------------------------------------------------------------------------//

METHOD ReDefine( nId, cFileName, oDlg, bWhen, bValid, lStretch ) CLASS TVideo

   ::nId      = nId
   ::cAviFile = cFileName
   ::bWhen    = bWhen
   ::bValid   = bValid
   ::oWnd     = oDlg
   ::lxStretch := lStretch
   ::lResize   := .F.

   ::oMci     = TMci():New( "MPEGVideo!", cFileName , Self )

   ::Register( nOR( CS_VREDRAW, CS_HREDRAW ) )

   oDlg:DefControl( Self )

   ::bLClicked  := {|| ::ControlPlay() }
   ::bRClicked  := {|| ::OpenFile()    }


return nil

//----------------------------------------------------------------------------//

METHOD Initiate( hDlg ) CLASS TVideo

   Super:Initiate( hDlg )
   ::oMci:lOpen(,,Self )
   ::oMci:SetWindow( Self )
//   ::Refresh()
Return nil

//----------------------------------------------------------------------------//

********************************
 METHOD OpenFile() CLASS TVIDEO
********************************
 local cFile,nError

    /* cGetFile32 Falla a veces más que una escopeta de feria ;(*/

    cFile := cGetFile32("Animation File (*.avi)| *.avi|" +" Video Mpeg ( *.Mpg ) |*.mpg|"+;
                      " MP3 ( *.mp3 ) | *.mp3|"+" Windows Media ( *.asf ) |*.asf|"+;
                      " QuickTime Movie File( *.Mov) |*.Mov|" +" MIDI( *.mid) |*.mid|"+" All( *.*) |*.*|",;
                      "Select a Multimedia File",,cFilePath( ::cAviFile ) )

    // Si cancelamos o no existe fichero, nos vamos
    if Empty( cFile ) //.OR. !File( Lfn2Sfn( cFile ) )
       return Nil
    endif
    // End Causa una salida de FwHarbour ? No se porque...
    ::oMci:Close()
    ::oMci := TMci():New( "MPEGVideo!", cFile, Self )
    ::oMci:lOpen(cFile,,Self)

//    ::Refresh()

    ::cAviFile := cFile

return nil

METHOD Inspect( cData ) CLASS Tvideo
   do case
      case cData == "cAviFile"
           return { | cFileName | ::OpenFile() }
   endcase

return nil

*********************************
   METHOD lStretch( lNewVal ) CLASS TVIDEO
*********************************

if lNewVal != nil

   ::lxStretch := lNewVal

   if lNewVal
      ::oMci:SendStr("put "+::oMci:cAlias+" destination at 0 0 " +;
                 alltrim(str(::nWidth  )) + " " +;
                 alltrim(str(::nHeight )) )
   else
      mciSendStr("put "+::oMci:cAlias+" destination at 0 0", @cBuffer,::oWnd:hWnd)
   endif

//   Super:Refresh() // ::Refresh()
//::oWnd:Resize()
//::lStretch( ::lxStretch )
//::lxStretch ()
//::oMci:SetWindow( Self )

endif
//?"6"
//::lxStretch ()
//::oMci:SetWindow( Self )
//::oMci:SetFocus( )

return ::lxStretch

#define MM_MCISIGNAL    971 //    0x3CB
#define MM_MCINOTIFY    953 //    0x3B9   /* MCI */

/* flags for wParam of MM_MCINOTIFY message */
#define MCI_NOTIFY_SUCCESSFUL    1    //   0x0001
#define MCI_NOTIFY_SUPERSEDED    2    //   0x0002
#define MCI_NOTIFY_ABORTED       4    //   0x0004
#define MCI_NOTIFY_FAILURE       8    //   0x0008
*********************************************************
METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TVideo
*********************************************************
static nPosition := 0
//?"7"
   DO CASE

      CASE nMsg == WM_SIZE
//          ::Refresh() ;   return 0
            return 0

      CASE nMsg == WM_MOUSEMOVE  .OR. nMsg == WM_LBUTTONUP .OR. nMsg == WM_RBUTTONUP
          CursorHand();   return 0

      CASE nMsg == WM_LBUTTONDOWN
           CursorHand()
           // Not return 0 Super:Evalua method bLclicked ;)

      CASE nMsg == WM_RBUTTONDOWN
           CursorHand()
           // Not return 0

      CASE nMsg == MM_MCINOTIFY  // Control notify. realmente funciona ;)
           if nWParam == MCI_NOTIFY_FAILURE
              *? nWParam
           endif
          return 0

      CASE nMsg == MM_MCISIGNAL  // Control de Señal. No VIENE!!!!! ;(
           *? nLParam
           Eval( ::bSignal, nLParam )
           return 0
    ENDCASE


Return Super:HandleEvent( nMsg, nWParam, nLParam )


METHOD ControlPlay() CLASS TVIDEO
//?"8"
  ::oMci:Status()
   if ::oMci:cStatus == "paused"
      if ::oMci:Position() = ::oMci:Length() // Ha llegado al final  ?
         ::Stop()
         ::Play(0)
      else
         ::oMci:Resume()                    // Continuo
      endif
   elseif ::oMci:cStatus == "playing"
          ::oMci:Pause()
   elseif ::oMci:cStatus == "stopped"
          if ::oMci:Position() = ::oMci:Length() // Ha llegado al final ?
             ::Stop()
             ::Play(0)                      // Play desde el inicio
          else
             ::Play()                       // Play desde donde estoy
          endif
   endif

 RETURN SELF
