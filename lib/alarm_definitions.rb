#!/usr/bin/env ruby

def hardware_listener(addr, json_response)
  hw_errors = json_response[0]["Hardware Errors"]
  if hw_errors < 1
    puts "#{addr} OK"
  else
    puts "#{addr} HWERROR #{hw_errors} #{Time.now.strftime('%m %d %Y %H:%M:%S')}"
    @anamolies_pool[0] << "#{addr} HWERROR #{hw_errors}"
  end
end

def hashrate_listener_mh15m(addr, json_response)
  uptime = json_response[0]["Elapsed"]
  mhs_15m = json_response[0]["MHS 15m"]
  # Allow 3 minutes before making determinations
  if uptime < 180
    # add logic to append logfile
    puts "#{addr} warming up. Uptime: #{uptime}"
  elsif uptime.to_i > 180 && mhs_15m.to_i > 11000
    puts mhs_15m
    puts "#{addr} OK mhs15m: #{mhs_15m} #{Time.now.strftime('%m %d %Y %H:%M:%S')}"
  elsif uptime.to_i > 180 && mhs_15m.to_i < 11000
    puts "#{addr} LOWHASH mhs_15m: #{mhs_15m} #{Time.now.strftime('%m %d %Y %H:%M:%S')}"
    @anamolies_pool[1] << "#{addr}: #{mhs_15m} | #{uptime}"
  else
    puts mhs_15m
  end
end
