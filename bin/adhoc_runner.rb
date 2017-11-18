#!/usr/bin/env ruby

require 'optparse'
require 'cgminer/api'
require 'colorize'
require 'ipaddress'
require 'sane_timeout'

@host_list = []

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

def query_cgminers(command)
  # Query the host list constructed by the host_constructor
  command = command.to_sym

  @host_list.each do |addr|
    begin
      host = Timeout::timeout(10) { CGMiner::API::Client.new(addr.to_s, 4028) }
      returned_data = host.send(command)
      json_response = JSON.parse(returned_data.body.to_json)
      emitted_metric = json_response[0]["Getworks"] # Needs fixed
        if emitted_metric
          puts emitted_metric
          #next
      # add logic to append logfile
      puts addr + ' ' + emitted_metric.to_s + ' SUCCESS ' + \
                Time.now.strftime('%m %d %Y %H:%M:%S').to_s
        end
    rescue => e
      # add logic to append logfile
      puts addr + ' - FAILURE ' + e.to_s + ' ' + \
                Time.now.strftime('%m %d %Y %H:%M:%S').to_s
    end
  end
end

def empty_args?
  if ARGV.empty?
    puts "\n\nPlease enter the location of the hosts list.\n".red
    puts "Example usage:\n".yellow
    puts ("Windows: ".green) + ("adhoc_runner.rb C:\\path\\to\\hostsfile".yellow)
    puts ("Linux: ".green) + ("adhoc_runner.rb /path/to/hostsfile".yellow)
  end
end

def main
  empty_args?

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

end # main

if __FILE__ == $0
  main
end
