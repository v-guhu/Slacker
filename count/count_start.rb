$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'count'

c = Count::CountBugs.new
c.count_bugs_in_all_labruns '..\files\labruns.txt'
c.write_bugs_to_file '..\files\output.txt'
c.output_result_as_html '..\files\bug_result.html'