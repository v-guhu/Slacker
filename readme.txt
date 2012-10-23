
This tool was writed by ruby, require watir gem, so you must install ruby and watir gem before run it.
Also make sure the bin path of ruby is added to environment variable PATH.
How to install watir: open command line and execute command "gem install watir"

For GUI version: run gui_start.bat(make sure Tcl/Tk support is checked when install ruby in your computer. if not please run console_start.bat instead.)
For console version: run console_start.bat

version 1.3
1 can view the result from IE now
2 add labrun anlysis function

version 1.2
1 show full url of labruns in sorted by bugs table
2 add the function of count out unfinished labruns

version 1.1
1 fix couldn't manipulate main UI when counting issue or open old bug result.
2 fix bugs is null cause method using issue
3 delete labruns without bug record
4 process labrun loading timeout/failed exception

version 1.0
TODO: add watir-webdriver supported
copyright@Phiso Hu
2012.08.12
