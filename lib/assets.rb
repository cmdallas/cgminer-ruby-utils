def help_text
  puts "\n"
  puts '#'.red * 20
  puts "Example usage:\n".yellow
  puts ("Windows: ".green) + ("./adhoc_runner.rb -f C:\\path\\to\\hostsfile [options]".yellow)
  puts ("Linux: ".green) + ("./adhoc_runner.rb -f /path/to/hostsfile [options]".yellow)
end
