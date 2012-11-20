$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

if !Dir.exist?("../files")
  Dir.mkdir("../files")
end