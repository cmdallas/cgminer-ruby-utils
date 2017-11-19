#!/usr/bin/env ruby

def hardware_listener
  puts 'TODO hardware_listener'
  []
end

def hashrate_listener_mh15m(addr, json_response)
  puts 'test'
  uptime = json_response[0]["Elapsed"]
  mhs_15m = json_response[0]["MHS 15m"]
  # Allow 3 minutes before making determinations
  if uptime < 180
    # add logic to append logfile
    puts "#{addr} warming up. Uptime: #{uptime}"
  elsif uptime.to_i > 180 && mhs_15m.to_i > 11000
    puts mhs_15m
    puts "#{addr} #{mhs_15m} OK #{Time.now.strftime('%m %d %Y %H:%M:%S')}"
  elsif uptime.to_i > 180 && mhs_15m.to_i < 11000
    puts "#{addr} #{mhs_15m} LOWHASH #{Time.now.strftime('%m %d %Y %H:%M:%S')}"
    @anamolies_hashrate << "#{addr}: #{mhs_15m} | #{uptime}"
  else
    puts mhs_15m
  end
end
