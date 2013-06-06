$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'filter_labruns'
require 'makedir'

f = Filter::TrunkFilter.new
f.filter
f.write_result '..\files\filter'