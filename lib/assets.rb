def help_text
  puts "\n"
  puts '#'.red * 20
  puts "Example usage:\n".yellow
  puts ('Windows: ./fleet_warden.rb -f C:\\path\\to\\hostsfile [options]'.yellow)
  puts ('Linux: ./fleet_warden.rb -f /path/to/hostsfile [options]'.yellow)
  puts '#'.red * 20
  puts ''
end

### pool_utils messages
@add_msg = " pool added: (TODO: print added pool) #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n"
@remove_msg = " pool removed: (TODO: print removed pool) #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n"
@switch_msg = " pool switched to (TODO: parse for pool) #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n"
