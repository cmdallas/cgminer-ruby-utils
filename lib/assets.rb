def help_text
  puts "\n"
  puts '#'.red * 20
  puts "Example usage:\n".yellow
  puts ("Windows: ".green) + ("./adhoc_runner.rb -f C:\\path\\to\\hostsfile [options]".yellow)
  puts ("Linux: ".green) + ("./adhoc_runner.rb -f /path/to/hostsfile [options]".yellow)
end

def archon_text
  print <<EOF
  .d8b.       d8888b.       .o88b.      db   db       .d88b.       d8b   db
 d8' `8b      88  `8D      d8P  Y8      88   88      .8P  Y8.      888o  88
 88ooo88      88oobY'      8P           88ooo88      88    88      88V8o 88
 88~~~88      88`8b        8b           88~~~88      88    88      88 V8o88
 88   88      88 `88.      Y8b  d8      88   88      `8b  d8'      88  V888
 YP   YP      88   YD       `Y88P'      YP   YP       `Y88P'       VP   V8P
EOF
end
