$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'ui'
require 'makedir'

$threads = Hash.new
BaseUI::UI.new