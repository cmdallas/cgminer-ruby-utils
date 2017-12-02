#!/usr/bin/env ruby

require 'cgminer/api'
require 'colorize'
require 'getoptlong'
require 'pry'
require 'sane_timeout'

require_relative '../lib/alarm_helper'
require_relative '../lib/assets'
require_relative '../lib/aws_helper'
require_relative '../lib/constants'
require_relative '../lib/log_helper'

ARGV << '--help' if ARGV.empty?

opts = GetoptLong.new(
  [ '--hash15m', '--h15m', GetoptLong::NO_ARGUMENT],
  [ '--hardware', '--hw', GetoptLong::NO_ARGUMENT],
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--host-file', '-f', GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, arg|
  case opt
  when '--help'
    puts <<-EOF

Usage: fleet_warden.rb -f /path/to/host_file --hash15m

-c, --command
    Specify the command to send to the cgminer API
    (NOT YET IMPLEMENTED)

-f, --host-file:
    Specify the location of the host file

--h15m, --hash15m:
    Listen for hashrate anomalies using a rolling 15 minute average

--hw, --hardware
    Listen for hardware errors

      EOF
  when '--hash15m'
    @hash15m_arg = arg
  when '--hardware'
    @hardware_arg = arg
  when '--host-file'
    @host_file_arg = arg
  end
end

@host_list = []
def host_list_constructor
# build the host list from a file
  host_file = @host_file_arg
  begin
    File.open(host_file, "r") do |host|
      host.each_line do |line|
        # remove any possible new lines from ingested hosts file
        line.delete!("\n")
        @host_list << line
      end
    end
  rescue
    puts 'Problem creating the hosts file. Was one specified?'.upcase.red
  end
end

def query_cgminers(command)
# query the host list constructed by the host_constructor
  command = command.to_sym
  @host_list.each do |addr|
    begin
      host = CGMiner::API::Client.new(addr.to_s, 4028)
      returned_data = Timeout::timeout(3) { host.send(command) }
      json_response = JSON.parse(returned_data.body.to_json)
      if @hash15m_arg
        hashrate_listener_mh15m(addr, json_response)
      elsif @hardware_arg
        hardware_listener(addr, json_response)
      else
        raise
      end
    rescue Timeout::Error
      timeout_listener(addr)
      next
    rescue => e
      fatal_listener(addr, e)
      next
    end
  end
  anomaly_collector
  alarm_dispatcher
end

def main
  sns_client_constructor
  host_list_constructor
  begin
    query_cgminers(SUMMARY)
  rescue => e
    puts e
  end
end

if __FILE__ == $0
  main
end
