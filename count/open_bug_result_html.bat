@echo off
prompt BugCountTool
set Path=C:\Program Files\Internet Explorer\
cd ..
iexplore.exe %cd%\files\bug_result.html
@echo on
