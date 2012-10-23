$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'ui'
$threads = Hash.new

BaseUI::UI.new