
This tool was writed by ruby, require watir gem, so you must install ruby and watir/watir-webdriver gems before run it.
Also make sure the bin path of ruby is added to environment variable PATH.
make sure Tcl/Tk support is checked when install ruby in your computer.
How to install watir: open command line and execute command
"gem install watir"
"gem install watir-webdriver"

usage:
all start here: start.bat.

Use GitHub to control versions, no need to update this file

version 1.4
1 can export bugs from JIRA now, labruns hyperlink is inserted into the bug excel automatically for every bug(chrome only)
2 optimize module count code
3 disable export bug result as txt type function
4 not support console model any more, if some one in favor of it, please go back to version 1.3
5 add application icon, if the path contains GBK encoded string, use default TK icon instead

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
