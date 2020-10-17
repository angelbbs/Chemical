@ECHO OFF
CLS
ECHO ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
ECHO ³ FiveWin for xHarbour 2.6 - April 2005           xHarbour development power ³Ü
ECHO ³ (c) FiveTech, 1993-2005      for Microsoft Windows 95/98/NT/2000/ME and XP ³Û
ECHO ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
ECHO ÿ ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


if A%1 == A GOTO :SINTAX
if NOT EXIST %1.prg GOTO :NOEXIST

ECHO Compiling...

set hdir=d:\xharbour.bcc55
set bcdir=d:\bcc55
set fwhdir=d:\fwh
SET HB_MT=

echo #define progdate  "%date%" >progdate.ch
echo #define progtime  "%time%" >progtime.ch
::%hdir%\bin\harbour %1 /n /i%hdir%\include;%fwhdir%\include;%bcdir%\include /w /p %2 %3 > clip.log
%hdir%\bin\harbour %1 /n /i%hdir%\include;%fwhdir%\include;%bcdir%\include  /p %2 %3 > clip.log
del progdate.ch
del progtime.ch
@type clip.log
IF ERRORLEVEL 1 PAUSE
IF ERRORLEVEL 1 GOTO EXIT

::echo -O2 -e%1.exe -I%hdir%\include %1.c > b32.bc
echo -O2 -e%1.exe -I%hdir%\include;%bcdir%\include %1.c > b32.bc
%bcdir%\bin\bcc32 -M -c -X -w0 @b32.bc >bccerr.log
::%bcdir%\bin\bcc32 -M -c -v @b32.bc
:ENDCOMPILE
::type bccerr.log

IF EXIST %1.rc %bcdir%\bin\brc32 -r %1

::echo c0w32.obj + > b32.bc
echo %bcdir%\lib\c0w32.obj + > b32.bc
echo %1.obj, + >> b32.bc
echo %1.exe, + >> b32.bc
echo %1.map, + >> b32.bc
echo %fwhdir%\lib\Fivehx.lib %fwhdir%\lib\FiveHc.lib + >> b32.bc
echo D:\FWH\ADDONS\richtext\richtext.lib + >> b32.bc
echo %hdir%\lib\optgui.lib + >> b32.bc
echo %hdir%\lib\rtl.lib + >> b32.bc
echo %hdir%\lib\vm.lib + >> b32.bc
echo %hdir%\lib\gtwin.lib + >> b32.bc
echo %hdir%\lib\lang.lib + >> b32.bc
echo %hdir%\lib\macro.lib + >> b32.bc
echo %hdir%\lib\rdd.lib + >> b32.bc
echo %hdir%\lib\dbfntx.lib + >> b32.bc
echo %hdir%\lib\dbfcdx.lib + >> b32.bc
echo %hdir%\lib\dbfdbt.lib + >> b32.bc
::echo %hdir%\lib\dbffpt.lib + >> b32.bc
::echo %hdir%\lib\hbsix.lib + >> b32.bc
echo %hdir%\lib\debug.lib + >> b32.bc
echo %hdir%\lib\common.lib + >> b32.bc
echo %hdir%\lib\pp.lib + >> b32.bc


rem Uncomment these two lines to use Advantage RDD
::echo %hdir%\lib\rddads.lib + >> b32.bc
::echo %hdir%\lib\Ace32.lib + >> b32.bc

echo %bcdir%\lib\cw32.lib + >> b32.bc
echo %bcdir%\lib\import32.lib + >> b32.bc
::echo %bcdir%\lib\uuid.lib + >> b32.bc
echo %bcdir%\lib\psdk\odbc32.lib + >> b32.bc
echo %bcdir%\lib\psdk\rasapi32.lib, >> b32.bc

IF EXIST %1.res echo %1.res >> b32.bc
rem uncomment this line to use the debugger and comment the following one
rem %bcdir%\bin\ilink32 -Gn -Tpe -s -v @b32.bc
::%bcdir%\bin\ilink32 -L%bcdir%\lib -Gn -aa -Tpe -s -v @b32.bc
%bcdir%\bin\ilink32 -L%bcdir%\lib -Gn -aa -Tpe -s @b32.bc

rem delete temporary files
@del %1.c
@del %1.ppo
@del %1.map
@del %1.obj
@del %1.tds
@del %1.il?

IF ERRORLEVEL 1 GOTO LINKERROR
ECHO * Application successfully built
%1
GOTO EXIT
ECHO

:LINKERROR
rem if exist meminfo.txt notepad meminfo.txt
rem PAUSE * Linking errors *
GOTO EXIT

:SINTAX
ECHO    SYNTAX: Build [Program]     {-- No especifiques la extensi¢n PRG
ECHO                                {-- Don't specify .PRG extension
GOTO EXIT

:NOEXIST
ECHO The specified PRG %1 does not exist

:EXIT
