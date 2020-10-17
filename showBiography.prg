function showBiography(cBiographyName)

   local oDlgBiography, oRTFBiography
   local lSyntaxHL := .f.
local cRTF  := ""
cBiographyFile := ""

oWnd:Disable()

  select 2
   for nBiography=1 to lastrec()
    go nBiography
     if alltrim(cBiographyName) == alltrim(BNAME)
         cBiographyFile := alltrim(BFILE)
     end if
   next



 DEFINE WINDOW oDlgBiography FROM 10, 10;
  TO 31.9, 100;
  TITLE alltrim(cBiographyName);
  NOZOOM NOMINIMIZE BORDER NONE
@ 0,0 BITMAP oBmpBiography WINDOW oDlgBiography;
  ADJUST UPDATE SIZE 216,326 PIXEL NAME ("Biography\"+cBiographyFile+".bmp")
 oBmpBiography:LoadBmp("Biography\"+cBiographyFile+".bmp")



@ 0, 36 RICHEDIT oRTFBiography OF oDlgBiography ;
       SIZE 500,328 FILENAME ( "Biography\"+cBiographyFile+".rtf" );
       READONLY
   ACTIVATE WINDOW oDlgBiography VALID ( oWnd:Enable() )

return nil

