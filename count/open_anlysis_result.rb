$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'browser'

e = Integration::Environment.new 'chrome'
e.browser.goto "#{Dir.pwd}/../files/anlysis_result.html"