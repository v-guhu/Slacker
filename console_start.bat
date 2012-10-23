@echo off
echo thank you for use bug count tool, any suggestion or question please mail me: xausee@gmail.com.
echo start labrun anlysis(1)
echo start bug count(2)

:start
set /p sf=:
if /i "%sf%"=="1" goto anlysis
if /i "%sf%"=="2" (goto count) else (echo wrong input!&&pause>nul&&goto start)

:anlysis
echo write down all labruns in file labruns.txt and save it...
pause
cd files
notepad.exe labruns.txt
cd ..\count
echo start labrun anlysis...
ruby.exe anlysis_start.rb
echo labrun anlysis finished
echo output your result...
pause
open_anlysis_result.bat
goto e

:count
echo write down all labruns in file labruns.txt and save it...
pause
cd files
notepad.exe labruns.txt
cd ..\count
echo start bug count...
ruby.exe count_start.rb
echo bug count finished
echo output your result...
pause
:output
set /p type=please select output type 't' for txt and 'h' for html:
if /i "%type%"=="t" goto t
if /i "%type%"=="h" (goto h) else (echo wrong input!&&pause>nul&&goto output)
:t
cd ..\files
notepad.exe output.txt
goto e
:h
cd ..\count
open_html_result.bat
goto e

:e
pause
@echo on