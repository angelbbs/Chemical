// Win32 RichEdit Control support

#include "FiveWin.ch"
#include "Constant.ch"
#include "WColors.ch"
#include "RichEdit.ch"

#ifdef __XPP__
   #define Super ::TControl
   #define New   _New
#endif

#define CTRL_CLASS        "RichEdit20A"

#define MK_MBUTTON        16

#define WM_ERASEBKGND      20
#define WM_COPY           769
#define WM_PASTE          770    // 0x302

#define FNT_HEIGHT        17

#define WM_SETREDRAW      0x000B

#define FW_BOLD           700

//----------------------------------------------------------------------------//

CLASS TRichEdit FROM TMultiGet

   DATA   cFileName, nRTFSize, lURL, lRE30

   DATA   lHighlight   // use syntax highlighting

   DATA   aKeywords1   // array 1 of highlighted keywords
   DATA   aKeywords2   // array 2 of highlighted keywords
   DATA   cSeparators  // characters string to recognize tokens

   DATA   nClrNumber, nClrString, nClrComment, nClrSeparator
   DATA   nClrText, nClrKey1, nClrKey2

   METHOD New( nTop, nLeft, bSetGet, oWnd, nWidth, nHeight, oFont, ;
               lPixel, cMsg, lHScroll, lReadOnly, bWhen, bValid, ;
               bChanged, lDesign, lHighlight, cFileName, ;
               nRTFSize, lNoURL, lNoScroll, lNoBorder ) CONSTRUCTOR

   METHOD ReDefine( nId, bSetGet, oWnd, nHelpId, oFont, cMsg, ;
                    lReadOnly, lHighlight, cFileName, nRTFSize, ;
                    lNoURL, bWhen, bValid, bChanged ) CONSTRUCTOR

   METHOD CanCopy() INLINE ::IsSelection()
   METHOD CanCut()  INLINE ::IsSelection() .and. ! ::lReadOnly
   METHOD CanDel()  INLINE ::IsSelection() .and. ! ::lReadOnly
   METHOD CanPaste( nFormat ) ;
          INLINE ::SendMsg( EM_CANPASTE, If( nFormat != nil, nFormat, 0 ) ) != 0 .and. ! ::lReadOnly
   METHOD CanUndo() INLINE ::SendMsg( EM_CANUNDO, 0, 0 ) != 0 .and. ! ::lReadOnly
   METHOD CanRedo() INLINE ::SendMsg( EM_CANREDO, 0, 0 ) != 0 .and. ! ::lReadOnly

   METHOD Change() INLINE If( ::bChange != nil, Eval( ::bChange,,, Self ), )

   METHOD Colorize( nStart, nEnd, nColor )

   METHOD Copy()

   METHOD Default()

   METHOD Display() VIRTUAL

   METHOD DLLVersion() INLINE ::lRE30 := REDllVersion() >= 30

   METHOD EraseBkGnd( hDC ) VIRTUAL

   METHOD Find( cFind, lDown, lCase, lWord )

   METHOD GetAlign() INLINE REGetParaFormat( ::hWnd )

   METHOD GetAutoURLDetect() INLINE ::SendMsg( EM_GETAUTOURLDETECT, 0, 0 ) == 1

   METHOD GetCharFormat( nColor ) INLINE REGetCharFormat( ::hWnd, @nColor )

   METHOD GetDlgCode( nLastKey )

   METHOD GetCol()
   METHOD GetRow()

   METHOD GetPos() INLINE ::GetSelection()[ 1 ]
   METHOD GetPosFromChar( nIndex )

   METHOD GetSel()
   METHOD GetSelection()

   METHOD GetTypographyOptions() INLINE ::SendMsg( EM_GETTYPOGRAPHYOPTIONS, 0, 0 )

   METHOD GoToLine( nLine ) INLINE ::SetPos( ::SendMsg( EM_LINEINDEX, nLine, 0 ) )

   METHOD HandleEvent( nMsg, nWParam, nLParam )

   METHOD HighLightAllText()

   METHOD HighLightLine( nLine )

   METHOD Initiate( hDlg ) INLINE Super:Initiate( hDlg ), ::Default()

   METHOD IsModify() INLINE ::SendMsg( EM_GETMODIFY ) != 0

   METHOD IsSelection()

   METHOD KeyChar( nKey, nFlags )
   METHOD KeyDown( nKey, nFlags )

   METHOD LButtonDown( nRow, nCol, nFlags )
   METHOD LButtonUp( nRow, nCol, nFlags )
   METHOD LDblClick( nRow, nCol, nFlags )

   METHOD Len() INLINE RELen( ::hWnd )

   METHOD LimitText() INLINE ::SendMsg( EM_EXLIMITTEXT, 0, ::nRTFSize )

   METHOD LimitUnDo() INLINE ::SendMsg( EM_SETUNDOLIMIT, 10, 0 )

   METHOD LoadRTF( cRTF )

   METHOD LoadAsRTF( cRTF ) INLINE ::LoadRTF( cRTF )

   METHOD LoadFromRTFFile( cFileName ) ;
          INLINE ::cFileName := cFileName, ::LoadRTF( MemoRead( ::cFileName ) )

   METHOD MouseMove( nRow, nCol, nFlags ) VIRTUAL
   METHOD MouseWheel( nKeys, nDelta, nXPos, nYPos )

   METHOD Notify( nIdCtrl, nPtrNMHDR )

   METHOD Paint() VIRTUAL

   METHOD Paste( cRTF )

   METHOD Print( cName )

   METHOD RButtonDown( nRow, nCol, nFlags )

   METHOD ReDo()

   METHOD ReplaceSel( lUnDo, cText )

   METHOD Resize( nType, nWidht, nHeight )

   METHOD SaveAsRTF() INLINE RESaveAsRTF( ::hWnd, SF_RTF )  // returns a RTF string

   METHOD SaveToFile( cFileName )

   // It saves it using RTF format
   METHOD SaveToRTFFile( cFileName ) INLINE MemoWrit( cFileName, ::SaveAsRTF() )

   METHOD Search( cSearch )

   METHOD SetAlign( nAlign )

   METHOD SetAttribute( lBold, lItalic, lUnderline, lStrikeOut, lOnOff )

   METHOD SetAutoUrlDetect( lOnOff )

   METHOD SetBold( lOnOff )      INLINE ::SetAttribute( .t.,,,,  lOnOff )
   METHOD SetItalic( lOnOff )    INLINE ::SetAttribute( , .t.,,, lOnOff )
   METHOD SetUnderline( lOnOff ) INLINE ::SetAttribute( ,, .t.,, lOnOff )
   METHOD SetStrikeOut( lOnOff ) INLINE ::SetAttribute( ,,, .t., lOnOff )

   METHOD SetBkGndColor( nRGB ) INLINE ::SendMsg( EM_SETBKGNDCOLOR, 0, nRGB )

   METHOD SetCharFormat()

   METHOD SetClear() INLINE ::SendMsg( EM_SETMODIFY, 0 )

   METHOD SetFontName( cName ) INLINE RESetFontName( ::hWnd, cName )
   METHOD SetFontSize( nSize ) INLINE RESetFontSize( ::hWnd, nSize * 20 )
   METHOD SetFont2RTF( nSize ) INLINE RESetFontSize( ::hWnd, Font2RTF( nSize ) * 20 )

   METHOD SetModify() INLINE ::SendMsg( EM_SETMODIFY, 1 )

   // METHOD SetPos( nPos ) INLINE RESetPos( ::hWnd, nPos )

   METHOD SetReadOnly( lOnOff )

   METHOD SetText( cText )

   METHOD SetTextColor( nRGB ) INLINE RESetTextColor( ::hWnd, nRGB )

   METHOD SetTypographyOptions() ;
          INLINE If( ::lRE30, ::SendMsg( EM_SETTYPOGRAPHYOPTIONS, ;
                                         TO_ADVANCEDTYPOGRAPHY, ;
                                         TO_ADVANCEDTYPOGRAPHY ), .F. )

   METHOD UnDo()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, bSetGet, oWnd, nWidth, nHeight, oFont, ;
            lPixel, cMsg, lHScroll, lReadOnly, bWhen, bValid, ;
            bChanged, lDesign, lHighlight, cFileName, ;
            nRTFSize, lNoURL, lNoScroll, lNoBorder ) CLASS TRichEdit

   #ifdef __XPP__
      #undef New
   #endif

   DEFAULT nTop       := 0, ;
           nLeft      := 0, ;
           oWnd       := GetWndDefault(), ;
           nWidth     := GetClientRect( oWnd:hWnd )[ 4 ], ;
           nHeight    := GetClientRect( oWnd:hWnd )[ 3 ], ;
           lPixel     := .f., ;
           lHScroll   := .f., ;
           lReadOnly  := .f., ;
           lDesign    := .f., ;
           lHighlight := .f., ;
           cFileName  := "" , ;
           nRTFSize   := 1024 * 1024, ;
           lNoURL     := .f., ;
           lNoScroll  := .f., ;
           lNoBorder  := .f., ;
           oFont      := TFont():New( "Arial", 0, If( LargeFonts(), -11, -13 ) )

   if bSetGet != nil
      ::cCaption = cValToChar( Eval( bSetGet ) )
   else
      ::cCaption = ""
   endif

   ::nTop      = If( lPixel, nTop, nTop * SAY_CHARPIX_H )
   ::nLeft     = If( lPixel, nLeft, nLeft * SAY_CHARPIX_W )
   ::nBottom   = ::nTop + nHeight - 1
   ::nRight    = ::nLeft + nWidth - 1
   ::bSetGet   = bSetGet
   ::oWnd      = oWnd
   ::nStyle    = nOR( WS_CHILD, WS_VISIBLE, WS_TABSTOP, WS_VSCROLL, ;
                      If( lDesign   , WS_CLIPSIBLINGS, 0 ), ;
                      If( !lNoBorder, WS_BORDER, 0 ), ;
                      If( lHScroll  , WS_HSCROLL, 0 ), ;
                      If( !lHScroll , ES_WANTRETURN, 0 ), ;
                      If( !lNoScroll, ES_DISABLENOSCROLL, 0 ), ;
                      ES_MULTILINE )
   ::nId       = ::GetNewId()
   ::cCaption  = RTrim( ::cCaption )
   ::lDrag     = lDesign
   ::lCaptured = .f.
   ::oFont     = oFont
   ::cMsg      = cMsg
   ::lReadOnly = lReadOnly
   ::bWhen     = bWhen
   ::bValid    = bValid
   ::bChange   = bChanged
   ::cFileName = cFileName
   ::nRTFSize  = Max( nRTFSize, 32 * 1024 )
   ::lURL      = !lNoURL

   ::lHighlight  = lHighlight
   ::aKeywords1  = { "CLASS", "FROM", "ENDCLASS", "DATA", "AS", "METHOD", ;
                     "CONSTRUCTOR", "function", "return", "OBJECT", "ENDOBJECT" }
   ::aKeywords2  = { "#include", "Self", "nil", "public", "local", "Super" }
   ::cSeparators = " +-()[]:*/{},="

   ::nClrNumber    = CLR_HMAGENTA
   ::nClrString    = CLR_YELLOW
   ::nClrComment   = CLR_HBLUE
   ::nClrSeparator = CLR_WHITE
   ::nClrText      = CLR_BLACK
   ::nClrKey1      = CLR_HGREEN
   ::nClrKey2      = CLR_HCYAN

   if ! Empty( oWnd:hWnd )
      ::Create( CTRL_CLASS )
      ::Default()
      oWnd:AddControl( Self )
   else
      oWnd:DefControl( Self )
   endif

   ::SetFont2RTF( ::oFont:nHeight )  // to adjust point size

   if ::lHighlight
      ::HighLightAllText() // PostMessage( ::hWnd, FM_HIGHLIGHTALL )
   endif

   if lDesign
      ::CheckDots()
   endif

return Self

//----------------------------------------------------------------------------//

METHOD ReDefine( nId, bSetGet, oWnd, nHelpId, oFont, cMsg, lReadOnly, ;
                 lHighlight, cFileName, nRTFSize, lNoURL, bWhen, bValid, ;
                 bChanged ) CLASS TRichEdit

   DEFAULT lHighlight := .f., ;
           cFileName  := "" , ;
           nRTFSize   := 1024 * 1024, ;
           lNoURL     := .f., ;
           oFont      := TFont():New( "Arial", 0, If( LargeFonts(), -11, -13 ) )

   ::cFileName = cFileName
   ::nRTFSize  = Max( nRTFSize, 32 * 1024 )
   ::lURL      = !lNoURL

   ::lHighlight  = lHighlight
   ::aKeywords1  = { "CLASS", "FROM", "ENDCLASS", "DATA", "AS", "METHOD",;
                    "CONSTRUCTOR", "function", "return", "OBJECT", "ENDOBJECT" }
   ::aKeywords2  = { "#include", "Self", "nil", "public", "local", "Super" }
   ::cSeparators = " +-()[]:*/{},="

   ::nClrNumber    = CLR_HMAGENTA
   ::nClrString    = CLR_YELLOW
   ::nClrComment   = CLR_HBLUE
   ::nClrSeparator = CLR_WHITE
   ::nClrText      = CLR_BLACK
   ::nClrKey1      = CLR_HGREEN
   ::nClrKey2      = CLR_HCYAN

return Super:Redefine( nId, bSetGet, oWnd, nHelpId,,, oFont,, ;
                       cMsg,, bWhen, lReadOnly, bValid, bChanged )

//----------------------------------------------------------------------------//

METHOD Colorize( nStart, nEnd, nColor ) CLASS TRichEdit

   local nChars := ::LineIndex( -1 )

   ::SetSel( Max( nChars + nStart - 2, 0 ), nChars + nEnd - 1 )
   RESetCharFormat( ::hWnd, ::oFont:cFaceName, ;
                    ::oFont:nHeight * FNT_HEIGHT, nColor, ;
                    ::oFont:nCharSet, ;
                    ::oFont:nPitchFamily, ;
                    ::oFont:nWeight, ;
                    ::oFont:lItalic, ;
                    ::oFont:lUnderline, ;
                    ::oFont:lStrikeOut )
   ::HideSel()

return nil

//----------------------------------------------------------------------------//

METHOD Copy() CLASS TRichEdit

   #ifdef __XPP__
      #undef New
   #endif

   ::SendMsg( WM_COPY )

return nil

//----------------------------------------------------------------------------//

METHOD Default() CLASS TRichEdit

   Super:Default()

   ::DllVersion()
   ::LimitText()
   ::LimitUnDo()

   if ::lReadOnly
      ::SetReadOnly( .t. )
   endif

   ::SetAutoURLDetect( ::lURL )
   ::SetTypographyOptions()

   if ! Empty( ::cFileName )
      ::LoadRTF( MemoRead( ::cFileName ) )
   else
      ::SetText( ::cCaption )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Find( cFind, lDown, lCase, lWord ) CLASS TRichEdit

   local nIndex := REFindText( ::hWnd, cFind, lDown, lCase, lWord )

   if nIndex != -1
      RESetSelection( ::hWnd, nIndex + Len( cFind ), nIndex )
      ::Change()
   else
      MsgInfo( "String not found: " + cFind, "Find" )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD GetDlgCode( nLastKey ) CLASS TRichEdit

   ::oWnd:nLastKey := nLastKey

return DLGC_WANTALLKEYS

//----------------------------------------------------------------------------//

METHOD GetCol() CLASS TRichEdit

return ::GetSelection()[ 2 ] - ::SendMsg( EM_LINEINDEX, ::GetRow() - 1 , 0 ) + 1

//----------------------------------------------------------------------------//

METHOD GetRow() CLASS TRichEdit

return ::SendMsg( EM_EXLINEFROMCHAR, 0, ::GetSelection()[ 2 ] ) + 1

//----------------------------------------------------------------------------//

METHOD GetPosFromChar( nIndex ) CLASS TRichEdit

   local nPos := ::SendMsg( EM_POSFROMCHAR, nIndex, 0 )

return { nLoWord( nPos ), nHiWord( nPos ) }

//----------------------------------------------------------------------------//

METHOD GetSel() CLASS TRichEdit

   local aGetSel := ::GetSelection()
   local cBuffer := Space( aGetSel[ 2 ] - aGetSel[ 1 ] )

   if Len( cBuffer ) <> 0
      ::SendMsg( EM_GETSELTEXT, 0, cBuffer )
   endif

return cBuffer

//----------------------------------------------------------------------------//

METHOD GetSelection() CLASS TRichEdit

   local nStart := 0
   local nEnd   := 0

   REGetSelection( ::hWnd, @nStart, @nEnd )

return { nStart, nEnd }

//----------------------------------------------------------------------------//

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TRichEdit

   do case
      case nMsg == FM_HIGHLIGHT
         return ::HighLightLine()

      case nMsg == FM_HIGHLIGHTALL
         return ::HighlightAllText()

   endcase

return Super:HandleEvent( nMsg, nWParam, nLParam )

//----------------------------------------------------------------------------//

METHOD HighLightAllText() CLASS TRichEdit

   local nLine

   LockWindowUpdate( ::hWnd )

   for nLine := 1 to ::GetLineCount()
       ::HighLightLine( nLine )
       SysRefresh()
   next

   LockWindowUpdate()

return nil

//----------------------------------------------------------------------------//

METHOD HighLightLine( nLine ) CLASS TRichEdit

   local cLine, cAt, cToken := ""
   local nAt := 1, nLen, nSep := 0, nStrSng := 0, nStrDob := 0, nStrCom := 0
   local bFindKeyword := { | c | Upper( c ) == Upper( cToken ) }
   local nGetSel   := ::SendMsg( EM_GETSEL )
   local nStartCur := nLoWord( nGetSel )
   local nEndCur   := nHiWord( nGetSel )

   DEFAULT nLine := ::GetRow()

   ::GoTo( nLine )

   // stop control painting
   ::SendMsg( WM_SETREDRAW, 0, 0 )

   // review keywords in current line to highlight them
   cLine = StrTran( ::GetLine( nLine ), Chr( 13 ), "" )
   nLen = Len( cLine )

   while nAt <= nLen

      cAt = StrChar( cLine, nAt )

      // detects '"' strings
      if cAt == '"'
         if nStrDob == 0
            nStrDob = nAt
         else
            ::Colorize( nStrDob, nAt + 1, ::nClrString )
            nStrDob = 0
         endif
         nAt++
         loop
      endif

      if nStrDob > 0
         nAt++
         loop
      endif

      // detects "'" strings
      if cAt == "'"
         if nStrSng == 0
            nStrSng = nAt
         else
            ::Colorize( nStrSng, nAt + 1, ::nClrString )
            nStrSng = 0
         endif
         nAt++
         loop
      endif

      if nStrSng > 0
         nAt++
         loop
      endif

      // detects comments
      if cAt == '/'
         if nStrCom == 0
            nStrCom := nAt
         else
            if nAt == ( nStrCom + 1 )
               ::Colorize( nStrCom, nLen + 1, ::nClrComment )
               exit
            endif
         endif
      endif

      if ! cAt $ ::cSeparators
         cToken += cAt
         if nAt == nLen .and. ! Empty( cToken )
            do case
               case Left( cToken, 1 ) $ "0123456789"
                    ::Colorize( nSep + 1, nAt + 1, ::nClrNumber )

               case AScan( ::aKeywords1, bFindKeyword ) != 0
                    ::Colorize( nSep + 1, nAt + 1, ::nClrKey1 )

               case AScan( ::aKeywords2, bFindKeyword ) != 0
                    ::Colorize( nSep + 1, nAt + 1, ::nClrKey2 )

               otherwise
                    ::Colorize( nSep + 1, nAt + 1, ::nClrText )
            endcase
         endif
      else
         if ! Empty( cToken )
            do case
               case Left( cToken, 1 ) $ "0123456789"
                    ::Colorize( nSep + 2, nAt, ::nClrNumber )

               case AScan( ::aKeywords1, bFindKeyword ) != 0
                    ::Colorize( nSep + 2, nAt, ::nClrKey1 )

               case AScan( ::aKeywords2, bFindKeyword ) != 0
                    ::Colorize( nSep + 2, nAt, ::nClrKey2 )

               otherwise
                    ::Colorize( nSep + 2, nAt, ::nClrText )
            endcase
         endif
         cToken = ""
         ::Colorize( nAt + 1, nAt + 1, ::nClrSeparator )
         nSep = nAt
      endif

      nAt++
   enddo

   // Let the control be painted
   ::SendMsg( WM_SETREDRAW, 1, 0 )
   InvalidateRect( ::hWnd )

   // Place the caret where it was
   ::SetSel( nStartCur, nEndCur )

return nil

//----------------------------------------------------------------------------//

METHOD IsSelection() CLASS TRichEdit

   local aGetSel := ::GetSelection()

return aGetSel[ 1 ] != aGetSel[ 2 ]

//----------------------------------------------------------------------------//

METHOD KeyChar( nKey, nFlags ) CLASS TRichEdit

   if ::lReadOnly
      return 0
   endif

   ::PostMsg( FM_CHANGE )

   if ::lHighlight
      ::PostMsg( FM_HIGHLIGHT )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD KeyDown( nKey, nFlags ) CLASS TRichEdit

   if ( nKey == VK_INSERT  .and. GetKeyState( VK_SHIFT ) .or. ;
        nKey == Asc( "V" ) .and. GetKeyState( VK_CONTROL ) )

      if ! ::lReadOnly
         ::Paste()
         ::PostMsg( FM_CHANGE )
      endif

      return 0
   endif

   if ::lReadOnly
      if nKey == VK_BACK .or. nKey == VK_DELETE .or. nKey == VK_RETURN
         return 0
      endif
   endif

   Super:KeyDown( nKey, nFlags )

   ::PostMsg( FM_CHANGE )

   if ::lHighlight
      if nKey == VK_DELETE .or. nKey == VK_BACK
         ::PostMsg( FM_HIGHLIGHT )
      endif
   endif

return nil

//----------------------------------------------------------------------------//

METHOD LButtonDown( nRow, nCol, nFlags ) CLASS TRichEdit

   Super:LButtonDown( nRow, nCol, nFlags )

   ::PostMsg( FM_CHANGE )

return nil

//----------------------------------------------------------------------------//

METHOD LButtonUp( nRow, nCol, nFlags ) CLASS TRichEdit

   Super:LButtonUp( nRow, nCol, nFlags )

   ::PostMsg( FM_CHANGE )

return nil

//----------------------------------------------------------------------------//

METHOD LDblClick( nRow, nCol, nFlags ) CLASS TRichEdit

   Super:LDblClick( nRow, nCol, nFlags )

   ::PostMsg( FM_CHANGE )

return nil

//----------------------------------------------------------------------------//

METHOD LoadRTF( cRTF ) CLASS TRichEdit

   RELoadAsRTF( ::hWnd, cRTF )

   ::SetClear()

   ::Change()

return nil

//----------------------------------------------------------------------------//

METHOD MouseWheel( nKeys, nDelta, nXPos, nYPos ) CLASS TRichEdit

   local nWParam := 0

   if lAnd( nKeys, MK_MBUTTON )
      if nDelta > 0
         nWParam := SB_PAGEUP
      else
         nWParam := SB_PAGEDOWN
      endif
   else
      if nDelta > 0
         nWParam := SB_LINEUP
      else
         nWParam := SB_LINEDOWN
      endif
   endif

   ::SendMsg( EM_SCROLL, nWParam, 0 )

return nil

//----------------------------------------------------------------------------//

METHOD Notify( nIdCtrl, nPtrNMHDR ) CLASS TRichEdit

   local nCode := GetNMHDRCode( nPtrNMHDR )

   if nCode == EN_LINK
      REGetNMHDRLink( ::hWnd, nPtrNMHDR )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Paste() CLASS TRichEdit

   #ifdef __XPP__
      #undef New
   #endif

   ::SendMsg( WM_PASTE )
   ::PostMsg( FM_CHANGE )

return nil

//----------------------------------------------------------------------------//
METHOD Print( cName,margin_top, margin_left, margin_right, margin_bottom, isLandscape, pFont ) CLASS TRichEdit

   local oPrn, oFont

   DEFAULT cName := "Document"

DEFAULT margin_top:=1
DEFAULT margin_left:=2
DEFAULT margin_right:=1
DEFAULT margin_bottom:=1
DEFAULT isLandscape:=.f.

   PRINT oPrn NAME cName FROM USER

 oPrn:SetFont(pFont)

  if isLandscape = .t.
    oPrn:SetLandscape()
  else
    oPrn:SetPortrait()
  end if



      if Empty( oPrn:hDC )
//         MsgStop( "ЏаЁ­вҐа ­Ґ Ј®в®ў!" )
         return Self
      endif

      CursorWait()

      REPrint( ::hWnd, oPrn:hDC, cName, margin_top, margin_left, margin_right, margin_bottom)

      CursorArrow()

   ENDPRINT

return nil

//----------------------------------------------------------------------------//

METHOD RButtonDown( nRow, nCol, nFlags ) CLASS TRichEdit

   local oMenu, oClp

   if GetFocus() != ::hWnd
      ::SetFocus()
      SysRefresh()

      if GetFocus() != ::hWnd
         RETURN NIL
      endif
   endif

   #ifdef __XPP__
      #undef New
   #endif

   if ::bRClicked != NIL
      return Eval( ::bRClicked, nRow, nCol, nFlags )
   endif

   DEFINE CLIPBOARD oClp OF Self FORMAT TEXT

   MENU oMenu POPUP
        #ifndef __XPP__
//            MENUITEM "&Undo" ACTION ::UnDo() RESOURCE "UnDo" ;
//                     WHEN ::CanUndo()
        #else
//            MENUITEM "&Undo" ACTION ::TRichEdit:UnDo() RESOURCE "UnDo" ;
//                     WHEN ::CanUndo()
        #endif

        #ifndef __XPP__
//            MENUITEM "&Redo" ACTION ::ReDo() RESOURCE "ReDo" ;
//                     WHEN ::CanRedo()
        #else
//            MENUITEM "&Redo" ACTION ::TRichEdit:ReDo() RESOURCE "ReDo" ;
//                     WHEN ::CanRedo()
        #endif

//        SEPARATOR

        #ifndef __XPP__
//            MENUITEM "Cu&t" ACTION ::Cut() RESOURCE "Cut" ;
//                     WHEN ::CanCut()
        #else
//            MENUITEM "Cu&t" ACTION ::TRichEdit:Cut() RESOURCE "Cut" ;
//                     WHEN ::CanCut()
        #endif

        #ifndef __XPP__
            MENUITEM "Копировать" ACTION ::Copy() RESOURCE "Copy" ;
                     WHEN ::CanCopy()
        #else
            MENUITEM "Копировать" ACTION ::TRichEdit:Copy() RESOURCE "Copy" ;
                     WHEN ::CanCopy()
        #endif

        #ifndef __XPP__
//            MENUITEM "&Paste" ACTION ::Paste() RESOURCE "Paste" ;
//                     WHEN ::CanPaste()
        #else
//            MENUITEM "&Paste" ACTION ::TRichEdit:Paste() RESOURCE "Paste" ;
//                     WHEN ::CanPaste()
        #endif

        #ifndef __XPP__
//            MENUITEM "&Delete" ACTION ::Del() RESOURCE "Del" ;
//                     WHEN ::CanDel()
        #else
//            MENUITEM "&Delete" ACTION ::TRichEdit:Del() RESOURCE "Del" ;
//                     WHEN ::CanDel()
        #endif

        SEPARATOR

        #ifndef __XPP__
//            MENUITEM "&Font..." ACTION ::SetCharFormat() RESOURCE "Font" ;
//                     WHEN !::lReadOnly
        #else
//            MENUITEM "&Font..." ACTION ::TRIchEdit:SetCharFormat() RESOURCE "Font" ;
//                     WHEN !::lReadOnly
        #endif


        #ifndef __XPP__
            MENUITEM "Печать" ACTION ::Print() RESOURCE "Printer"
        #else
            MENUITEM "Печать" ACTION ::TRichEdit:Print() RESOURCE "Printer"
        #endif

        SEPARATOR

        #ifndef __XPP__
            MENUITEM "Выбрать всё" ACTION ::SelectAll() RESOURCE "SelAll"
        #else
            MENUITEM "Выбрать всё" ACTION ::TRichEdit:SelectAll() RESOURCE "SelAll"
        #endif
   ENDMENU

   ACTIVATE POPUP oMenu AT nRow, nCol OF Self

return 0

//----------------------------------------------------------------------------//

METHOD ReDo() CLASS TRichEdit

   ::SendMsg( EM_REDO )
   Eval( ::bSetGet, ::GetText() )

   ::Change()

return nil

//----------------------------------------------------------------------------//

METHOD ReSize( nType, nWidth, nHeight ) CLASS TRichEdit

   Super:ReSize( nType, nWidth, nHeight )

   ::PostMsg( FM_CHANGE )

return nil

//----------------------------------------------------------------------------//

METHOD ReplaceSel( lUndo, cText ) CLASS TRichEdit

   DEFAULT lUndo := .t.

return ::SendMsg( EM_REPLACESEL, lUndo, cText )

//----------------------------------------------------------------------------//

METHOD SaveToFile( cFileName ) CLASS TRichEdit

   DEFAULT cFileName := ::cFileName

   if Empty( cFileName )
      MsgAlert( "No filename provided to save the richedit text" )
      return nil
   endif

   if File( cFileName )
      if MsgYesNo( cFileName + " already exists" + CRLF + ;
                   "Do you want to overwrite it ?" )
         MemoWrit( cFileName, ::GetText() )
      endif
   else
      MemoWrit( cFileName, ::GetText() )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Search( cSearch ) CLASS TRichEdit

   local nIndex := REFindText( ::hWnd, cSearch, .t. )
   local nLine

   if nIndex == -1
      nLine = 0
   else
      MsgInfo( "something found" )
      nLine = ::SendMsg( EM_EXLINEFROMCHAR, 0, nIndex )
   endif

   MsgInfo( nLine )

return nLine

//----------------------------------------------------------------------------//

METHOD SetAlign( nAlign ) CLASS TRichEdit

   DEFAULT nAlign := PFA_LEFT

   RESetParaFormat( ::hWnd, nAlign )

   ::Change()

return nil

//----------------------------------------------------------------------------//

METHOD SetAttribute( lBold, lItalic, lUnderline, lStrikeOut, lOnOff ) CLASS TRichEdit

   local nMask, nEffects

   DEFAULT lBold      := .f., ;
           lItalic    := .f., ;
           lUnderline := .f., ;
           lStrikeOut := .f., ;
           lOnOff     := .t.

   nMask := nOR( If( lBold, CFM_BOLD, 0 ), If( lItalic, CFM_ITALIC, 0 ), ;
                 If( lUnderline, CFM_UNDERLINE, 0 ), ;
                 If( lStrikeOut, CFM_STRIKEOUT, 0 ) )

   nEffects := nOR( If( lBold, CFE_BOLD, 0 ), If( lItalic, CFE_ITALIC, 0 ), ;
                    If( lUnderline, CFE_UNDERLINE, 0 ), ;
                    If( lStrikeOut, CFE_STRIKEOUT, 0 ) )

   RESetAttribute( ::hWnd, nMask, nEffects, lOnOff )

   ::Change()

return nil

//----------------------------------------------------------------------------//

METHOD SetAutoUrlDetect( lOnOff ) CLASS TRichEdit

   DEFAULT lOnOff := .t.

   RESetAutoUrlDetect( ::hWnd, lOnOff )

return nil

//----------------------------------------------------------------------------//

METHOD SetCharFormat() CLASS TRichEdit

   local nColor := 0
   local aFont  := REGetCharFormat( ::hWnd, @nColor )

   aFont[ LF_HEIGHT ] := Font2Size( aFont[ LF_HEIGHT ] )
   aFont[ LF_PITCHANDFAMILY ] := 255

   aFont := ChooseFont( aFont, @nColor )

   if aFont[ LF_PITCHANDFAMILY ] != 255
      aFont[ LF_HEIGHT ] := Size2Font( aFont[ LF_HEIGHT ] )
      aFont[ LF_WEIGHT ] := aFont[ LF_WEIGHT ] == FW_BOLD

      RESetCharFormat( ::hWnd, aFont[ LF_FACENAME ], ;
                       aFont[ LF_HEIGHT ] * 20, nColor, ;
                       aFont[ LF_CHARSET ], aFont[ LF_PITCHANDFAMILY ], ;
                       aFont[ LF_WEIGHT ], aFont[ LF_ITALIC ], ;
                       aFont[ LF_UNDERLINE ], aFont[ LF_STRIKEOUT ] )

      ::Change()
   endif

return nil

//----------------------------------------------------------------------------//

METHOD SetText( cText ) CLASS TRichEdit

   Super:SetText( cText )

   if ::lHighlight
      ::HighlightAllText()
   endif

return nil

//----------------------------------------------------------------------------//

METHOD SetReadOnly( lOnOff ) CLASS TRichEdit

   DEFAULT lOnOff := .t.

   ::lReadOnly := lOnOff

   ::SendMsg( EM_SETOPTIONS, If( lOnOff, ECOOP_OR, ECOOP_XOR ), ECO_READONLY )

return nil

//----------------------------------------------------------------------------//

METHOD UnDo() CLASS TRichEdit

   ::SendMsg( EM_UNDO )
   Eval( ::bSetGet, ::GetText() )

   ::Change()

return nil

//----------------------------------------------------------------------------//

STATIC FUNCTION Font2RTF( nSize )

return Int( nSize * 10/13 )

//----------------------------------------------------------------------------//

STATIC FUNCTION Font2Size( nFontSize )

   local nSize := Int( nFontSize * 4/3 )

   nSize += If( ( nFontSize + 1 ) % 3 == 0, 1, 0 )

return nSize * -1

//----------------------------------------------------------------------------//

STATIC FUNCTION Size2Font( nSize )

return Abs( Round( nSize * 3/4, 0 ) )

//----------------------------------------------------------------------------//
