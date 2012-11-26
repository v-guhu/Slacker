#coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'ui'
require 'makedir'

$threads = Hash.new
ui = BaseUI::UI.new

Thread.new {
  loop do
    now = Time.now
    date =  prefix_zero(now.hour) + ':' + prefix_zero(now.min) + ':' + prefix_zero(now.sec) + '  ' + prefix_zero(now.year) + '年' + prefix_zero(now.month) + '月' + prefix_zero(now.day) + '日'
    ui.date_label.text = date
    sleep(1)
  end
}

ui.loop