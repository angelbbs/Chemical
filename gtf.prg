// GTF functions

#include "FiveWin.ch"

#include "GTF.ch"

// #define ES_LEFT                 0
// #define ES_RIGHT                2
#define ES_CENTER               1

//----------------------------------------------------------------------------//

function IsGTF( cText )
return ( Left( cText, At( SP_REG, cText ) - 1 ) == FORMAT_TEXT_TYPE )

//----------------------------------------------------------------------------//

function IsRTF( cText )
return ( Upper( SubStr( cText, At( "\rtf", cText ) + 1, 3 ) ) == "RTF" )

//----------------------------------------------------------------------------//

function GTFToRTF( cGTF )

   local n

   local nPos
   local nCrLf, nLen
   local nOldCrLf, nOldLen

   local cRTF, cRTFHead, cRTFBody

   local cFormat, cVersion

   local lCrLf, cText
   local lAlign

   local aFonts, aColors

   local nId, nIdFont, nIdColor

   local cType
   local nFont, nColor, nAlign
   local cFont, cColor, cAlign

   local cFaceName, nHeight, nWidth, lBold, lItalic, lUnderline, lStrikeOut

   local cTitle := "", cAuthor := ""

   nPos := 1
   nLen := 0

   cRTF := "{"

   cRTFHead := ""
   cRTFBody := ""

   nLen := At( SP_REG, SubStr( cGTF, nPos ) )
   cFormat := SubStr( cGTF, nPos, nLen - 1 )
   nPos += nLen
   nLen := At( SP_FIELD, SubStr( cGTF, nPos ) )
   cVersion := SubStr( cGTF, nPos, nLen - 1 )
   nPos += nLen

   if !( cFormat == FORMAT_TEXT_TYPE )
      MsgAlert( "The data are not GTF (Get Text Format)!" )
      return nil
   endif

   cRTFHead += "\rtf1\ansi\deff0\deftab720"
   cRTFBody += "\pard"

   nFont := 0

   aFonts := {}

   do while SubStr( cGTF, nPos, 1 ) != SP_FIELD

      nLen := At( SP_REG, SubStr( cGTF, nPos ) )
      cFaceName := SubStr( cGTF, nPos, nLen - 1 )
      nPos += nLen
      nLen := At( SP_REG, SubStr( cGTF, nPos ) )
      nHeight := Val( SubStr( cGTF, nPos, nLen - 1 ) )
      nPos += nLen
      nLen := At( SP_REG, SubStr( cGTF, nPos ) )
      nWidth := Val( SubStr( cGTF, nPos, nLen - 1 ) )
      nPos += nLen
      nLen := At( SP_REG, SubStr( cGTF, nPos ) )
      lBold := SubStr( cGTF, nPos, nLen - 1 ) == "1"
      nPos += nLen
      nLen := At( SP_REG, SubStr( cGTF, nPos ) )
      lItalic := SubStr( cGTF, nPos, nLen - 1 ) == "1"
      nPos += nLen
      nLen := At( SP_REG, SubStr( cGTF, nPos ) )
      lUnderline := SubStr( cGTF, nPos, nLen - 1 ) == "1"
      nPos += nLen
      nLen := At( SP_REG, SubStr( cGTF, nPos ) )
      lStrikeOut := SubStr( cGTF, nPos, nLen - 1 ) == "1"
      nPos += nLen

      nIdFont := AScan( aFonts, { | aFont | aFont[ 2 ] == cFaceName } )
      if nIdFont == 0
         nIdFont := len( aFonts ) + 1
      endif
      AAdd( aFonts, { nIdFont, cFaceName, nWidth, nHeight, lBold, lItalic, lUnderline, lStrikeOut } )

   enddo

   aColors := {}

   nOldCrLf := -1
   nOldLen := -1

   nPos++

   do while ( cType := SubStr( cGTF, nPos, 1 ) ) != SP_FIELD

      do case
         case cType == TP_ALIGN
              nLen := At( SP_REG, SubStr( cGTF, nPos ) )
              nAlign := Val( SubStr( cGTF, nPos + 1, nLen - 2 ) )
              do case
                 case nAlign == ES_LEFT
                      cAlign := "\ql"
                 case nAlign == ES_RIGHT
                      cAlign := "\qr"
                 case nAlign == ES_CENTER
                      cAlign := "\qc"
              endcase
              lAlign := .t.
              nPos += nLen

         case cType == TP_FONT
              nLen := At( SP_REG, SubStr( cGTF, nPos ) )
              nFont := Val( SubStr( cGTF, nPos + 1, nLen - 2 ) )
              cFont := "\f" + LTrim( Str( aFonts[ nFont, 1 ] ) ) + ;
                       "\fs" + LTrim( Str( Round( aFonts[ nFont, 4 ] * 0.75, 0 ) * 2 ) )
              if aFonts[ nFont, 5 ]
                 cFont += "\b"
              endif
              if aFonts[ nFont, 6 ]
                 cFont += "\i"
              endif
              if aFonts[ nFont, 7 ]
                 cFont += "\ul"
              endif
              if aFonts[ nFont, 8 ]
                 cFont += "\strike"
              endif
              nPos += nLen

         case cType == TP_COLOR
              nLen := At( SP_REG, SubStr( cGTF, nPos ) )
              nColor := Val( SubStr( cGTF, nPos + 1, nLen - 2 ) )
              nIdColor := AScan( aColors, nColor )
              if nIdColor == 0
                 nIdColor := len( aColors ) + 1
                 AAdd( aColors, nColor )
              endif
              cColor := "\cf" + LTrim( Str( nIdColor ) )
              nPos += nLen

         otherwise
              if nOldCrLf == 0
                 nCrLf := 0
              else
                 nCrLF := At( CRLF, SubStr( cGTF, nPos ) )
              endif
              if nOldLen == 0
                 nLen := 0
              else
                 nLen := At( SP_REG, SubStr( cGTF, nPos ) )
              endif
              nOldCrLf := nCrLf
              nOldLen := nLen
              nLen := if( nCrLf == 0, nLen, if( nLen == 0, nCrlf, Min( nCrLf, nLen ) ) )

              if lAlign
                 cRTFBody += "\pard" + cAlign
                 lAlign := .f.
              endif

              lCrLf := .f.

              if nLen != 0
                 if ( lCrlf := ( nCrLf != 0 .and. nCrLf == nLen ) )
                    cText := SubStr( cGTF, nPos, nLen - 1 )
                    nPos += nLen + 1
                 else
                    do while SubStr( cGTF, nPos + --nLen - 1, 1 ) > Chr( 32 )
                    enddo
                    cText := SubStr( cGTF, nPos, nLen - 1 )
                    nPos += nLen - 1
                 endif
              else
                 nLen := Len( SubStr( cGTF, nPos ) )
                 cText := SubStr( cGTF, nPos, nLen - 1 )
                 nPos += nLen - 1
              endif

              cRTFBody += "{"
              cRTFBody += cFont
              cRTFBody += cColor
              cRTFBody += " " + CodeText( cText )
              cRTFBody +=  "}"
              if lCrLf
                 cRTFBody += "{\par}" + CRLF
              endif

      endcase

   enddo

   nId := 0

   cRTFHead += "{"
   cRTFHead += "\fonttbl"
   for n := 1 to Len( aFonts )
       if ( nFont := aFonts[ n, 1 ] ) > nId
          nId := nFont
          cRTFHead += "{" + "\f" + LTrim( str( nId ) ) + "\fcharset204\fnil"
          cRTFHead += " " + aFonts[ nFont, 2 ] + ";}"
       endif
   next
   cRTFHead += "}"

   cRTFHead += "{"
   cRTFHead += "\colortbl;"
   for n := 1 to Len( aColors )
       nColor := aColors[ n ]
       nId := n
       cRTFHead += "\red" + LTrim( str( GetRValue( nColor ) ) ) + ;
                   "\green" + LTrim( str( GetGValue( nColor ) ) ) + ;
                   "\blue" + LTrim( str( GetBValue( nColor ) ) ) + ";"
   next
   cRTFHead += "}"

   cRTFHead += "{"
   cRTFHead += "\info"
   cRTFHead += "{\title " + cTitle + "}"
   cRTFHead += "{\author " + cAuthor + "}"
   cRTFHead += "}"

   cRTF += cRTFHead + "{" + cRTFBody + "}"

   cRTF += "}"

return cRTF

//----------------------------------------------------------------------------//

function RTFToGTF( cRTF )

   local n
   local n1, n2

   local nPos
   local nLen

   local aRTFFonts, aRTFColors

   local cGTF, cGTFHead, cGTFBody

   local lDelimited, lCommand

   local cFormat, cDelimited, cCommand, cText

   local aFonts, aColors

   local nHead, nBody

   local cChar, cStr, cVal
   local nRed, nGreen, nBlue

   local nFont, nColor, nAlign
   local cFont, cColor, cAlign

   local lInit, bInit
   local nGroup, aGroup

   local nNewAlign, cNewFont, nNewColor

   local cFaceName, cHeight, cWidth, cBold, cItalic, cUnderline, cStrikeOut

   nPos := 1
   nLen := 0

   cGTF := FORMAT_TEXT_TYPE + SP_REG + ;
           FORMAT_TEXT_VERSION + SP_FIELD

   cRTF := StrTran( StrTran( cRTF, "\par" + CRLF, "\par" + " " ), CRLF )
   if Asc( Right( cRTF, 1 ) ) = 0
      cRTF := Left( cRTF, Len( cRTF ) - 1 )
   endif

   nLen := At( "\rtf", SubStr( cRTF, nPos ) )
   nPos += nLen
   cFormat := Upper( SubStr( cRTF, nPos, 3 ) )
   nPos += 3

   nHead := nPos

   nPos := 1
   nLen := 0

   nLen := At( "\pard", SubStr( cRTF, nPos ) )
   nPos += nLen

   nBody := nPos

   if !( cFormat == "RTF" )
      MsgAlert( "The data are not RTF (Rich Text Format)!" )
      return nil
   endif

   aRTFFonts := {}

   nPos:= nHead
   nLen := At( "\fonttbl", SubStr( cRTF, nPos ) )

   if nLen != 0

      nPos += nLen + 7
      nLen := At( "{", SubStr( cRTF, nPos ) )
      nPos += nLen - 1
      do while ( cChar := SubStr( cRTF, nPos, 1 ) ) == " "
         nPos++
      enddo

      do while cChar == "{"
        nLen := At( ";}", SubStr( cRTF, nPos ) )
        cFont := SubStr( cRTF, nPos + 1, nLen - 1 )
        n1 := At( "{", cFont )
        n2 := At( "}", cFont )
        if n1 != 0 .and. n2 != 0
           cFont := Stuff( cFont, n1, n2 - n1 + 1, " " )
        endif
        n1 := At( "\f", cFont )
        nFont := Val( SubStr( cFont, n1 + 2 ) )
        n1 := RAt( "\", cFont )
        n1 := At( " ", SubStr( cFont, n1 ) ) + n1 - 1
        n2 := At( ";", cFont )
        if n1 != 0 .and. n2 != 0
           cFont := SubStr( cFont, n1 + 1, n2 - n1 - 1 )
        elseif n2 == 0
           cFont := ""
        endif
        AAdd( aRTFFonts, { nFont, cFont } )
        nPos += nLen + 1
        do while ( cChar := SubStr( cRTF, nPos, 1 ) ) == " "
           nPos++
        enddo
      enddo

   endif

   aRTFColors := {}

   nPos := nHead
   nLen := At( "\colortbl", SubStr( cRTF, nPos ) )

   if nLen != 0

      nPos += nLen + 8
      do while ( cChar := SubStr( cRTF, nPos, 1 ) ) == " "
         nPos++
      enddo
      if cChar == ";"
         AAdd( aRTFColors, nRGB( 0, 0, 0 ) )
      endif
      nLen := At( "\", SubStr( cRTF, nPos ) )
      nPos += nLen - 1
      cChar := SubStr( cRTF, nPos, 1 )

      do while cChar == "\"
         nLen := At( ";", SubStr( cRTF, nPos ) )
         cColor := SubStr( cRTF, nPos, nLen )
         n1 := At( "\red", cColor )
         nRed := Val( SubStr( cColor, n1 + 4 ) )
         n1 := At( "\green", cColor )
         nGreen := Val( SubStr( cColor, n1 + 6 ) )
         n1 := At( "\blue", cColor )
         nBlue := Val( SubStr( cColor, n1 + 5 ) )
         AAdd( aRTFColors, nRGB( nRed, nGreen, nBlue ) )
         nPos += nLen
         do while ( cChar := SubStr( cRTF, nPos, 1 ) ) == " "
            nPos++
         enddo
      enddo

   endif

   aFonts := {}
   aColors := {}

   nPos := nBody

   nAlign := ES_LEFT
   cAlign := Str( ES_LEFT, 1 )

   cFaceName := aRTFFonts[ 1, 2 ]
   cHeight := "11"   // Round( 16 / 1.5, 0 )
   cWidth := "4.84"  // 11 * 0.44

   cBold := "0"
   cItalic := "0"
   cUnderline := "0"
   cStrikeOut := "0"

   cFont := ""

   nColor := 0
   cColor := "0"

   lDelimited := .f.
   lCommand := .f.

   cGTFHead := ""
   cGTFBody := TP_ALIGN + cAlign + SP_REG +;
               TP_COLOR + cColor + SP_REG

   lInit := .t.
   bInit := {|| nNewAlign := Val( cAlign ), nAlign := nNewAlign,;
                cGTFBody += TP_ALIGN + cAlign + SP_REG,;
                cNewFont := cFaceName + SP_REG +;
                            cHeight + SP_REG + cWidth + SP_REG +;
                            cBold + SP_REG + cItalic + SP_REG +;
                            cUnderline + SP_REG + cStrikeOut + SP_REG,;
                cFont := cNewFont,;
                nFont := AScan( aFonts, cFont ),;
                if( nFont == 0, ( AAdd( aFonts, cFont ),;
                                  cGTFHead += cFont,;
                                  nFont := Len( aFonts ) ), nil ),;
                cGTFBody += TP_FONT + LTrim( Str( nFont ) ) + SP_REG,;
                nNewColor := Val( cColor ), nColor := nNewColor,;
                cGTFBody += TP_COLOR + cColor + SP_REG }

   nGroup := 1
   aGroup := Array( 10, 9 )

   do while Len( cChar := SubStr( cRTF, nPos - 1, 1 ) ) != 0

      do case
         case cChar $ "{}"
              nLen := 1
              cDelimited := cChar
              lCommand := .f.

              if cDelimited == "{"
                 if nGroup > 0
                    aGroup[ nGroup, 1 ] := cAlign
                    aGroup[ nGroup, 2 ] := cFaceName
                    aGroup[ nGroup, 3 ] := cHeight
                    aGroup[ nGroup, 4 ] := cWidth
                    aGroup[ nGroup, 5 ] := cBold
                    aGroup[ nGroup, 6 ] := cItalic
                    aGroup[ nGroup, 7 ] := cUnderline
                    aGroup[ nGroup, 8 ] := cStrikeOut
                    aGroup[ nGroup, 9 ] := cColor
                 endif
                 nGroup++
              endif

              if cDelimited == "}"
                 nGroup--
                 if nGroup > 0
                    cAlign := aGroup[ nGroup, 1 ]
                    cFaceName := aGroup[ nGroup, 2 ]
                    cHeight := aGroup[ nGroup, 3 ]
                    cWidth := aGroup[ nGroup, 4 ]
                    cBold := aGroup[ nGroup, 5 ]
                    cItalic := aGroup[ nGroup, 6 ]
                    cUnderline := aGroup[ nGroup, 7 ]
                    cStrikeOut := aGroup[ nGroup, 8 ]
                    cColor := aGroup[ nGroup, 9 ]
                 else
                    nLen++
                 endif
              endif

         case cChar == "\" .and. !( SubStr( cRTF, nPos, 1 ) $ "'\{}" )
              nLen := AAt( { "\", " ", "{", "}" }, SubStr( cRTF, nPos ) )
              cCommand := SubStr( cRTF, nPos - 1, nLen )
              lCommand := .t.

              if !( cCommand == "" )

                 do case
                    /*
                    case cCommand == "\tab"
                         if lInit
                            Eval( bInit )
                            lInit := .f.
                         endif
                         cGTFBody += Space( 9 )
                    */

                    case cCommand == "\par"
                         if lInit
                            Eval( bInit )
                            lInit := .f.
                         endif
                         cGTFBody += CRLF

                    case cCommand == "\pard"
                         cAlign := "0"
                         cBold := "0"
                         cItalic := "0"
                         cUnderline := "0"
                         cStrikeOut := "0"
                         cColor := "0"

                    case cCommand == "\plain"
                         cBold := "0"
                         cItalic := "0"
                         cUnderline := "0"
                         cStrikeOut := "0"
                         cColor := "0"

                    case Left( cCommand, 3 ) == "\fs"
                         cVal := SubStr( cCommand, 4 )
                         if isDigit( cVal )
                            cHeight := LTrim( Str( Round( Val( cVal ) / 1.5, 0 ) ) )
                            cWidth := LTrim( Str( Val( cHeight ) * 0.44 ) )
                         endif

                    case Left( cCommand, 3 ) == "\cf"
                         cVal := SubStr( cCommand, 4 )
                         if isDigit( cVal )
                            cColor := LTRim( Str( aRTFColors[ Val( cVal ) + 1 ] ) )
                         endif

                    case Left( cCommand, 2 ) == "\f"
                         cVal := SubStr( cCommand, 3 )
                         if isDigit( cVal )
                            nFont := AScan( aRTFFonts, { |aFont| aFont[ 1 ] == Val( cVal ) } )
                            cFaceName := aRTFFonts[ nFont, 2 ]
                         endif

                    case Left( cCommand, 2 ) == "\b"
                         cVal := SubStr( cCommand, 3 )
                         cBold := if( Empty( cVal ), "1", cVal )

                    case Left( cCommand, 2 ) == "\i"
                         cVal := SubStr( cCommand, 3 )
                         cItalic := if( Empty( cVal ), "1", cVal )

                    case Left( cCommand, 3 ) == "\ul"
                         cVal := SubStr( cCommand, 4 )
                         cUnderline := if( Empty( cVal ), "1", cVal )

                    case cCommand == "\strike"
                         cStrikeOut := "1"

                    case cCommand == "\ql"
                         cAlign := Str( ES_LEFT, 1 )

                    case cCommand == "\qr"
                         cAlign := Str( ES_RIGHT, 1 )

                    case cCommand == "\qc"
                         cAlign := Str( ES_CENTER, 1 )

                 endcase

              endif

         otherwise
              nLen := AAt( { "\", "{", "}" }, SubStr( cRTF, nPos - 1 ) )
              do while SubStr( cRTF, nPos + nLen - 2, 1 ) == "\" .and.;
                       SubStr( cRTF, nPos + nLen - 1, 1 ) $ "'\{}"
                 nLen += AAt( { "\", "{", "}" }, SubStr( cRTF, nPos + nLen ) ) + 1
              enddo
              nLen--
              if lCommand .and. cChar == " "
                 cText := DecodeText( SubStr( cRTF, nPos, nLen - 1 ) )
              else
                 cText := DecodeText( SubStr( cRTF, nPos - 1, nLen ) )
              endif
              lCommand := .f.

              if !( cText == "" )

                 if lInit
                    Eval( bInit )
                    lInit := .f.
                 endif

                 nNewAlign := Val( cAlign )
                 if nAlign != nNewAlign
                    nAlign := nNewAlign
                    cGTFBody += TP_ALIGN + cAlign + SP_REG
                 endif

                 cNewFont := cFaceName + SP_REG +;
                             cHeight + SP_REG + cWidth + SP_REG +;
                             cBold + SP_REG + cItalic + SP_REG +;
                             cUnderline + SP_REG + cStrikeOut + SP_REG
                 if cFont != cNewFont
                    cFont := cNewFont
                    nFont := AScan( aFonts, cFont )
                    if nFont == 0
                       AAdd( aFonts, cFont )
                       cGTFHead += cFont
                       nFont := Len( aFonts )
                    endif
                    cGTFBody += TP_FONT + LTrim( Str( nFont ) ) + SP_REG
                 endif

                 nNewColor := Val( cColor )
                 if nColor != nNewColor
                    nColor := nNewColor
                    cGTFBody += TP_COLOR + cColor + SP_REG
                 endif

                 cGTFBody += DecodeText( cText )

              endif

      endcase

      nPos += nLen

   enddo

   cGTF += cGTFHead + SP_FIELD + cGTFBody

   cGTF += SP_FIELD

return cGTF

//----------------------------------------------------------------------------//

static function GetRValue( nRGB )
return nLoByte( nLoWord( nRGB ) )

static function GetGValue( nRGB )
return nHiByte( nLoWord( nRGB ) )

static function GetBValue( nRGB )
return nLoByte( nHiWord( nRGB ) )

//----------------------------------------------------------------------------//
// R.Avendaño. 2000
