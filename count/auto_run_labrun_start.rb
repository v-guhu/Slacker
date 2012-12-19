$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'auto_run_labrun'

autorun = AutoRunLabrun.new
autorun.get_labruns '..\files\labruns.txt'
$stdout.puts "The monitor sleep time is #{ARGV[0].delete(',')} minutes."
$stdout.puts "The subpage load time is #{ARGV[1]} seconds."

time = ARGV[0].delete(',')

while(1)
  autorun.run
  sleep(time.to_i*60)
end
