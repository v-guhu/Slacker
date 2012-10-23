$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'anlysis'

a = Anlysis::LabrunAnLysis.new
a.get_labruns '..\files\labruns.txt'
a.start_anlysis
a.output_result '..\files\anlysis_result.html'