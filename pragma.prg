#pragma BEGINDUMP

#include "WinTen.h"
#include "Windows.h"
#include "Richedit.h"
#include "ClipApi.h"
#include "hbapi.h"
#include "hbapiitm.h"
#include "hbapifs.h"
#include "hbfast.h"
#include "hbset.h"
#include "hbapierr.h"

//#define CP_ACP      204

HB_FUNC ( REPRINT )
{
   GETTEXTLENGTHEX gt;
   FORMATRANGE fr;
   DOCINFO info;

   HWND hWnd = ( HWND ) hb_parnl( 1 );
   HDC  hDC  = ( HDC ) hb_parnl( 2 );
   LONG lSize, lPrint;

   int margin_top = ( (hb_parnl(4))/100 * 254 * 2);
   int margin_left = ( (hb_parnl(5))/100 * 254 * 2);
   int margin_right = ( (hb_parnl(6))/100 * 254 * 2);
   int margin_bottom = ( (hb_parnl(7))/100 * 254 * 2);

   SetMapMode( hDC, MM_TEXT );

   ZeroMemory( ( char * ) &fr, sizeof( fr ) );
   fr.hdc = hDC;
   fr.hdcTarget = hDC;

   fr.rcPage.top    = 0;
   fr.rcPage.left   = 0;
   fr.rcPage.right  = MulDiv( GetDeviceCaps( hDC, HORZRES ), 1440,
                              GetDeviceCaps( hDC, LOGPIXELSX ) );
   fr.rcPage.bottom = MulDiv( GetDeviceCaps( hDC, VERTRES ), 1440,
                              GetDeviceCaps( hDC, LOGPIXELSY ) );

   fr.rc.top    = fr.rcPage.top + margin_top;
   fr.rc.left   = fr.rcPage.left + margin_left;
   fr.rc.right  = fr.rcPage.right - margin_right;
   fr.rc.bottom = fr.rcPage.bottom - margin_bottom;

   ZeroMemory( ( char * ) &info, sizeof( info ) );
   info.cbSize      = sizeof( DOCINFO );
   info.lpszDocName = hb_parc( 3 );
   info.lpszOutput  = NULL;

   gt.flags = GTL_PRECISE;
   gt.codepage = CP_ACP;
//   gt.codepage = -1;

   lSize = SendMessage( hWnd, EM_GETTEXTLENGTHEX, ( WPARAM ) &gt, 0 );

   fr.chrg.cpMin = 0;
   fr.chrg.cpMax = -1;

   StartDoc( hDC, &info );

   do
   {
      lPrint = SendMessage( hWnd, EM_FORMATRANGE, FALSE, ( LPARAM ) &fr );

      StartPage( hDC );

      SendMessage( hWnd, EM_DISPLAYBAND, 0, ( LPARAM ) &fr.rc );

      EndPage( hDC );

      if( lPrint < lSize )
      {
         fr.chrg.cpMin = lPrint;
         fr.chrg.cpMax = lSize;
      }
   }
   while( lPrint < lSize );

   SendMessage( hWnd, EM_FORMATRANGE, FALSE, ( LPARAM ) NULL );

   EndDoc( hDC );
}

#pragma ENDDUMP