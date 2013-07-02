@echo off
color 0e
mode con: cols=50 lines=25
title Slacker
prompt Slacker
echo Thank you for using bug count tool, any suggestion or question please mail me: xausee@gmail.com
echo This is a GUI version, it's easy to manipulate it.
cd count
ruby.exe ui_start.rb
@echo on