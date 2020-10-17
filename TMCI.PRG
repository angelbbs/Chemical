// MCI - Media Control Interface                                              //
// by TheFull( Rafa Carmona )
// Reescribiendo la Clase MCI ampliando horizontes.
/*   DATA cStatus -> Informa sobre el estado del dispositivo
          cAlias  -> Usado para enviar mensajes a traves de SendStr()
          nId     -> Usado para enviar comandos MCISendCommand() .

   METHOD Pause() -> Hacer Pausa
          Resume()-> Continuar
          Play()  -> Si ha sido pausado, continuar
          Repeat()-> Loop continuo de una avi
          Status()-> Pregunta por el estado del dispositivo
          End()   -> Cierra dispositivo
          New()         -> Nuevo paso de parametros
          Audio()       -> Controlando el Audio del Video
          Speed()       -> Controlando la velocidad de ejecucion un valor de 1000 es por defecto
          Length()      -> Devuelve longitud del MEDIO
          Position()    -> Nos devuelve la posicion actual de reproduccion del MEDIO
          Seek()        -> Busca el frame y te posicionas
          Config()      -> Ventana de Configuracion
          Error()       -> Devuelve el error tipo cadena

          FullScreen()  -> Valor .T. vemos el video a pantalla completa ;)
          Loop , Repeat -> Repite una y otra vez lo mismo ;)
          lDebug        -> Muestra cualquier error producido por cualquier comando.
          cErrorMsg     -> Contiene mensaje del ultimo error producido.

      */


#include "FiveWin.ch"

#define MCI_OPEN     2051  //                 0x0803
#define MCI_CLOSE    2052  //                 0x0804
#define MCI_ESCAPE   2053  //                 0x0805
#define MCI_PLAY     2054  //                 0x0806
#define MCI_SEEK     2055  //                 0x0807
#define MCI_STOP     2056  //                 0x0808
#define MCI_PAUSE    2057  //                 0x0809
#define MCI_RESUME   2133  //                 0x0855

#define BUF_SIZE  200
#define MCI_NOTIFY      1

//----------------------------------------------------------------------------//

CLASS TMci

   DATA   nError, cErrorMsg, nId
   DATA   cType, cFileName
   DATA   oWnd
   DATA   cBuffer
   DATA   cAlias     // Identificador Unico
   DATA   cStatus
   DATA   lAudio,nSpeed,nSeek,nPos
   DATA   lFullScreen

   DATA   lDebug INIT .F.
   DATA   lOpened INIT .F.

   CLASSDATA nNumero INIT 0

   METHOD New( cDevice, cFileName )  CONSTRUCTOR

   METHOD lOpen()

   METHOD SetWindow( oWnd ) BLOCK ;
      { | Self, oWnd | ::oWnd := oWnd,;
                       ::nError( nMciWindow( ::nId, oWnd:hWnd ),,"SetWindow" ) }
   METHOD SendStr( cMciStr )
   METHOD GetDeviceId( cAlias ) INLINE MciGetId( cAlias )  // Esta linea es la repolla ;)
   METHOD xAlias()
   METHOD Error()

   METHOD Pause()   INLINE ::Error( MCISendCommand( ::nId , MCI_PAUSE  ),,"PAUSE" )
   METHOD Resume()  INLINE ::Error( MCISendCommand( ::nId , MCI_RESUME ),,"RESUME")
   METHOD Stop()    INLINE ::Error( MCISendCommand( ::nId , MCI_STOP   ),,"STOP"  )
   METHOD Foward( nPistas )
   METHOD Rewind( nPistas )
   METHOD Play( nFrom, nTo )
   METHOD FullScreen()   SETGET
   METHOD Repeat() INLINE  ::SendStr("PLAY "+ ::cAlias + " REPEAT",,"REPEAT" )
   METHOD Loop()   INLINE  ::Repeat()

   METHOD Status() INLINE ( ::SendStr( "STATUS "+::cAlias + " MODE" ,,"STATUS"), ::cStatus := ::cBuffer )
   METHOD Audio()  SETGET
   METHOD Speed()  SETGET
   METHOD Seek()   SETGET
   METHOD Length()
   METHOD Position() INLINE ( ::SendStr("STATUS "+::cAlias+" POSITION",,"POSITION" ), ::nPos := Val(::cBuffer) )
   METHOD Config()   INLINE   ::SendStr("CONFIGURE "+ ::cAlias,,"CONFIG" )

   METHOD END()
   METHOD Close() INLINE ::Error( MCISendCommand( ::nId , MCI_CLOSE ),,"CLOSE" )
   METHOD DebugMode( )

   METHOD CanEject()    INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " CAN EJECT" )   )
   METHOD CanPlay()     INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " CAN PLAY" )    )
   METHOD CanRecord()   INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " CAN RECORD" )  )
   METHOD CanReverse()  INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " CAN REVERSE" ) )
   METHOD CanSave()     INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " CAN SAVE" )    )
   METHOD CanStrech()   INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " CAN STRECH" )  )
   METHOD CanCompound() INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " COMPOUND DEVICE"  )  )
   METHOD CanHasVideo() INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " HAS VIDEO"        )  )
   METHOD CanHasAudio() INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " HAS AUDIO"        )  )
   METHOD CanUseFile()  INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " USES FILES"       )  )
   METHOD CanUsePalet() INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " USES PALETTES"    )  )
   METHOD CanFastPlay() INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " FAST PLAY RATE"   )  )
   METHOD CanNormPlay() INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " NORMAL PLAY RATE" )  )
   METHOD CanSlowPlay() INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " SLOW PLAY RATE"   )  )
   METHOD CanWindows()  INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias + " WINDOWS"          )  )

   METHOD DeviceType()  INLINE  ( ::SendStr("CAPABILITY "+ ::cAlias+ " DEVICE TYPE "      )  )

   MESSAGE SetFocus METHOD __SetFocus()


ENDCLASS

//----------------------------------------------------------------------------//
METHOD __SetFocus() CLASS TMci

//   if ::lWhen()
      SetFocus( ::hWnd )
//   endif

return nil




METHOD New( cDevice, cFileName , oWnd ) CLASS TMci

   DEFAULT cDevice := "", oWnd := GetWndDefault()
   ::nError    = 0
   ::nId       = 0
   ::cType     = cDevice
   ::cFileName = cFileName
   ::cBuffer   = Space( BUF_SIZE )
   ::oWnd := oWnd
   ::cAlias := ::xAlias() //alltrim( cGetNewAlias( cFileName ) )
   ::lFullScreen := .F.

return Self

//----------------------------------------------------------------------------//
METHOD lOpen( cFileName, cType, oControl )  CLASS TMci
  Local cBuffer := Space( BUF_SIZE )

  DEFAULT oControl := ::oWnd

  IF cFileName != NIL
     ::cFileName := cFileName
  ENDIF

  IF cType != NIL
     ::cType := cType
  ENDIF

  if Empty( cFileName ) //.OR. !File( Lfn2Sfn( cFileName ) )
     return Nil
  endif

  // bug. Hay que transformar el nombre del fichero a nombre corto!!! Si no, no funciona.
 // Exception. Para poder controlar si ha sido abierto , debemos de prescindir de la
 // llamada a SendStr() y hacerlo directamente
  ::nError := MciSendStr("OPEN "+ ::cType + Upper(Alltrim(Lfn2Sfn(::cFileName)))+;
                         " ALIAS "+ ::cAlias+" PARENT "+Alltrim(str(oControl:hWnd)),@cBuffer,::oWnd:hWnd  )

  if ::nError = 0
     ::lOpened := .T.
  else
     ::lOpened := .F.
     ::Error(::nError,,"LOPEN Open")
     return self
  endif

  ::SendStr("put "+::cAlias+" destination at 0 0 " +;
                     alltrim(str(oControl:nWidth)) + " " +;
                     alltrim(str(oControl:nHeight)) ,,"LOPEN Put")

  ::SendStr("WINDOW "+::cAlias+" HANDLE "+ Alltrim(str( oControl:hWnd) ) ,,"LOPEN Window")

  ::nID:= ::GetDeviceId( ::cAlias )
  ::Length()
  //Intentando enviar señal para que se dispare el evento MM_MCISIGNAL pero
  // parece que no le llega . Mirar HandleEvent de la clase TVideo ;(
  *::SendStr("Signal "+ ::cAlias +" every 1" )

RETURN SELF

//----------------------------------------------------------------------------//
METHOD Play( nFrom, nTo ) CLASS TMci

      DEFAULT nFrom := ::Position(), nTo := 0

      ::Status()

      IF ::cStatus == "paused"
         ::Resume()
      ELSE
          IF nFrom >= 0 .AND. nTo = 0
             ::SendStr("PLAY "+::cAlias+" FROM "+ Alltrim( Str( nFrom ) ) +;
                       if( ::lFullScreen," FULLSCREEN","" ),,"PLAY From" )

          ENDIF

          IF nFrom > 0 .AND. nTo > 0
             ::SendStr("PLAY "+::cAlias+" FROM "+ Alltrim( Str( nFrom ) ) + " TO " +;
                        Alltrim( Str( nTo ) ) + if( ::lFullScreen," FULLSCREEN","" ),,"PLAY From To" )
          ENDIF
      ENDIF

RETURN SELF

//----------------------------------------------------------------------------//
* Admite pasarle el Flag
* cFlag := Wait, Test or Notify
METHOD SendStr( cMciStr, cFlag , cMethod ) CLASS TMci

   local cBuffer := ::cBuffer

   DEFAULT cFlag := ""

   IF !::lOpened
      Return ::nError
   ENDIF

   ::nError :=  MciSendStr( cMciStr + " "  + cFlag, @cBuffer, ::oWnd:hWnd )

   ::cBuffer = cBuffer

   if ::lDebug .AND. ::lOpened
      ::Error( ::nError,, cMethod )
   endif

return ::nError

//----------------------------------------------------------------------------//
/* Method para alias dinamico */
METHOD xAlias() CLASS TMci
   Local xAlias := ::cType
   ::nNumero++

RETURN ( xAlias += StrZero(::nNumero,3 ) )


//----------------------------------------------------------------------------//
METHOD Foward( nPistas ) CLASS TMci
local nPista

 * avanza nPistas
 DEFAULT nPistas := 1

   ::SendStr( "STATUS "+::cAlias + " CURRENT TRACK",,"FOWARD Status" )
   nPista = val( ::cBuffer )

   ::SendStr("SEEK " + ::cAlias + " TO " + ltrim ( str( nPista + nPistas ) ),,"FOWARD Seek" )

return nil

//----------------------------------------------------------------------------//
METHOD Rewind( nPistas ) CLASS TMci

local nPista

 * retrocede nPistas
 DEFAULT nPistas := 1

   ::SendStr( "STATUS "+ ::cAlias +" CURRENT TRACK" ,,"REWIND Status")
   nPista = val( ::cBuffer )

   ::SendStr("SEEK "+ ::cAlias + " TO " + ltrim ( str( nPista - nPistas )),,"REWIND Seek" )

return nil


*********************************************************
METHOD FullScreen( lNewVal )  CLASS TMci
*********************************************************
   DEFAULT lNewVal := .F.

    if lNewVal
     ::lFullScreen := .T.
    else
     ::lFullScreen := .F.
    endif

RETURN ::lFullScreen

*********************************************************
METHOD Audio()  CLASS TMci
*********************************************************

if ::lAudio
   ::SendStr( "SET "+ ::cAlias + " AUDIO ALL OFF" ,,"AUDIO OFF")
   ::lAudio := .F.
else
   ::SendStr( "SET "+ ::cAlias + " AUDIO ALL ON" ,,"AUDIO ON")
   ::lAudio := .T.
endif

RETURN ::lAudio

*********************************************************
METHOD Speed( nNewVal )  CLASS TMci
*********************************************************

DEFAULT ::nSpeed := 1000  // Velocidad Standard

if nNewVal != nil
   ::nSpeed := nNewVal
   ::SendStr( "SET " + ::cAlias + " SPEED "+STR( nNewVal),,"SPEED" )
endif

RETURN ::nSpeed


*********************************************************
METHOD Seek( nNewVal )   CLASS TMci
*********************************************************
DEFAULT ::nSeek := 0

if nNewVal != nil

     ::SendStr( "SEEK " + ::cAlias +" TO "+STR( nNewVal),,"SEEK " )
      // Se le debe de pasar el Flag de Notify para que funcione correctamente
      // el handleEvent de TVideo para reanudar la marcha.
      // No preguntes porque , porque realmente no tengo ni idea. XDDD
      *::Pause()
      MCISendCommand( ::nId , MCI_PAUSE , MCI_NOTIFY )
      SysRefresh()
endif

RETURN ::nSeek

//----------------------------------------------------------------------------//
METHOD Length() CLASS TMci

  ::SendStr( "STATUS "+::cAlias+" LENGTH " ,, "LENGTH")

RETURN Val( ::cBuffer )

//----------------------------------------------------------------------------//
/* Nos muestra el error de MCI
   Si pasamos lDebug podemos depurar un error determinado.
   Si ::lDebug es .T. podemos depurar todos los mensajes, util para depurar clases
   TVideo,TMidi,TVCR,etc.. que hagan uso de TMCI
*/
METHOD Error( nError , lDebug , cMethod )  CLASS TMci
  Local cBufferI

  DEFAULT lDebug := ::lDebug, cMethod := ""

  IF nError != 0 .AND. lDebug
     MCIGetErrorString( nError,@cBufferI )
     ::cErrorMsg := cBufferI
     MsgStop( cMethod + CRLF + cBufferI )
  ENDIF

RETURN Self
//----------------------------------------------------------------------------//

METHOD DebugMode() CLASS TMCI
   Local cOrder := space(50)
   Local oGet, oMemo,cSay := ""
   Local lOldDebug := ::lDebug
   Local This := Self
   Local cToken1,cToken2
   Static oDlg

   if !::lOpened  // Si no ha sido abierto , no podemos operar todavia
      return self
   endif

   if oDlg != NIL
      oDlg:SetFocus()
   else
      ::lDebug := .T.   // Activamos mensajes de error
      DEFINE DIALOG oDlg TITLE "Send MCI Debug"

      @1,1 GET oGet Var cOrder OF oDlg SIZE 140,10;
               VALID ( cToken1 := alltrim( StrToken( cOrder, 1, "," ) ),;
                       cToken2 := alltrim( StrToken( cOrder, 2, "," ) ),;
                       ::SendStr( cToken1 +" "+ ::cAlias +" "+ cToken2 ,,"DEBUGMODE" ),;
                       oMemo:VarPut( cValToChar( ::cBuffer ) + CRLF + cValToChar( ::cErrorMsg ) ),;
                       oMemo:Refresh(), .F. )

      @2,1 GET oMemo VAR cSay OF oDlg SIZE 140,50 MEMO

      ACTIVATE DIALOG oDlg CENTER NOWAIT VALID ( This:lDebug := lOldDebug, oDlg := NIL,.T.)
   endif


RETURN Self

**************************************
METHOD End( )   CLASS TMci
**************************************
   ::SendStr("CLOSE "+::cAlias,, "END " )
return .T.



/* Devuelve el ID de un Alias del MCI.*/
DLL32 Function mciGetID(lpszDevice AS STRING ) ;
      AS LONG PASCAL FROM "mciGetDeviceIDA" LIB "WINMM.DLL"
//----------------------------------------------------------------------------//
