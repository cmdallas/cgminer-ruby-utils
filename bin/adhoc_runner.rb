#!/usr/bin/env ruby

require 'aws-sdk-sns'
require 'cgminer/api'
require 'colorize'
require 'ipaddress'
require 'sane_timeout'

ERROR_MSG_HASHRATE = 'LOWHASH:'
ERROR_MSG_HW = 'HARDWARE ERROR:'

@host_list = []

def empty_args?
  if ARGV.empty?
    #ARGV << 'C:\Users\Chris\Documents\GitHub\cgminer-ruby-utils\etc\hosts'
    puts "\n\nPlease enter the location of the hosts list.\n".red
    puts "Example usage:\n".yellow
    puts ("Windows: ".green) + ("adhoc_runner.rb C:\\path\\to\\hostsfile".yellow)
    puts ("Linux: ".green) + ("adhoc_runner.rb /path/to/hostsfile".yellow)
  end
end

def host_list_constructor
  # Build the host list from a file
  host_file_location = ARGV[0]
  begin
    File.open(host_file_location, "r") do |host|
      host.each_line do |line|
        # Remove any possible new lines from ingested hosts file
        line.delete!("\n")
        @host_list << line
      end
    end
  rescue => e
    puts ' Problem creating the hosts file'.upcase.red
    puts e
  end
end

def sns_constructor
  @sns = Aws::SNS::Client.new(
    region: 'us-west-2'
  )
end

def sns_send_sms(error_msg, hosts)
  @sns.publish({
    topic_arn: "arn:aws:sns:us-west-2:114600190083:Test_Alert",
    message: "#{error_msg} #{hosts}"
  })
end

def query_cgminers(command)
  # Query the host list constructed by the host_constructor
  command = command.to_sym
  anamolies_hashrate = []

  @host_list.each do |addr|
    begin
      host = Timeout::timeout(5) { CGMiner::API::Client.new(addr.to_s, 4028) }
      returned_data = host.send(command)
      json_response = JSON.parse(returned_data.body.to_json)
      uptime = json_response[0]["Elapsed"]
      mhs_15m = json_response[0]["MHS 15m"]
        # Allow 3 minutes before making determinations
        if uptime < 180
          # add logic to append logfile
          puts "#{addr} warming up. Uptime: #{uptime}"
        elsif uptime.to_i > 180 && mhs_15m.to_i > 11000
          puts mhs_15m.to_s
          puts "#{addr} #{mhs_15m} OK #{Time.now.strftime('%m %d %Y %H:%M:%S')}"
        elsif uptime.to_i > 180 && mhs_15m.to_i < 11000
          puts "#{addr} #{mhs_15m} LOWHASH #{Time.now.strftime('%m %d %Y %H:%M:%S')}"
          anamolies_hashrate << (addr.to_s + ': ' + \
                                 mhs_15m.to_s + ' | ' + \
                                 uptime.to_s)
        else
          puts mhs_15m.to_s
        end
    rescue => e
      # add logic to append logfile
      puts e.backtrace
      puts "#{addr} FATAL #{e} #{Time.now.strftime('%m %d %Y %H:%M:%S')}"
    end
  end
  if !anamolies_hashrate.empty?
    puts anamolies_hashrate
    sns_send_sms(ERROR_MSG_HASHRATE, anamolies_hashrate)
  end
end

def main
  empty_args?
  sns_constructor

  begin
    host_list_constructor
  rescue => e
    puts e
  end

  begin
    query_cgminers('summary')
  rescue => e
    puts e
  end
end

if __FILE__ == $0
  main
end
