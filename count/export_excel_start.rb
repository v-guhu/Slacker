$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'export_excel'
require 'makedir'

ex = Excel::ExportExcel.new 'chrome'
ex.jira_login
ex.query_bugs
ex.open_excel
ex.add_labrun
#ex.save
#ex.close
