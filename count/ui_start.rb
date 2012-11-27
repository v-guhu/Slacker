#coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'ui'
require 'makedir'

$threads = Hash.new
ui = BaseUI::UI.new

Thread.new do
  loop do
    ui.show_time
    ui.clock.run
    sleep(1)
  end
end

ui.loop