#!/usr/bin/env ruby

require 'aws-sdk-sns'
require 'cgminer/api'
require 'colorize'
require 'optparse'
require 'sane_timeout'

require_relative '../lib/alarm_definitions'
require_relative '../lib/assets'

ARGV << '--help' if ARGV.empty?

ERROR_MSG_HASHRATE = 'LOWHASH:'
ERROR_MSG_HW = 'HARDWARE ERROR:'

@options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: setup_hostlist.rb [options]'
  @options[:host_file] = nil
  opts.on(
    '-f',
    '--host-file',
    'Host file location') do |v|
      @options[:host_file] = ARGV
    end
  @options[:hashrate_listener] = nil
  opts.on(
    '-h',
    '--hash',
    'Listen for hashrate anamolies') do |v|
      @options[:hashrate_listener] = true
    end
  @options[:hardware_listener] = nil
  opts.on(
    '-w',
    '--hw',
    '--hardware',
    'Listen for hardware errors') do |v|
      @options[:hardware_listener] = true
    end
  opts.on_tail('--help', 'Please use one of the options above') do
    puts opts
    exit
  end
end.parse!

@host_list = []
def host_list_constructor
# Build the host list from a file
  host_file = @options[:host_file][0]
  begin
    File.open(host_file, "r") do |host|
      host.each_line do |line|
        # Remove any possible new lines from ingested hosts file
        line.delete!("\n")
        @host_list << line
      end
    end
  rescue => e
    puts e.backtrace
    puts ' Problem creating the hosts file'.upcase.red
  end
end

def sns_constructor
  @sns = Aws::SNS::Client.new(
    region: 'us-west-2'
  )
end

def sns_send(error_msg, hosts)
  @sns.publish({
    topic_arn: "arn:aws:sns:us-west-2:114600190083:Test_Alert",
    message: "#{error_msg} #{hosts}"
  })
end

@anamolies_pool = [
  @anamolies_hardware = [],
  @anamolies_hashrate = []
]
def query_cgminers(command)
# Query the host list constructed by the host_constructor
  command = command.to_sym
  hardware_anamolies = @anamolies_pool[0]
  mhs15m_anamolies = @anamolies_pool[1]

  @host_list.each do |addr|
    begin
      host = Timeout::timeout(5) { CGMiner::API::Client.new(addr.to_s, 4028) }
      returned_data = host.send(command)
      json_response = JSON.parse(returned_data.body.to_json)
      if @options[:hashrate_listener]
        hashrate_listener_mh15m(addr, json_response)
      elsif @options[:hardware_listener]
        hardware_listener(addr, json_response)
      else
        raise
      end
    rescue => e
      # Add logic to append logfile
      puts e.backtrace
      puts "#{addr} FATAL #{e} #{Time.now.strftime('%m %d %Y %H:%M:%S')}"
    end
  end
  # Search for anamolies in the @anamolies_pool
  if !mhs15m_anamolies.empty?
    puts mhs15m_anamolies
    sns_send(ERROR_MSG_HASHRATE, mhs15m_anamolies)
  elsif !hardware_anamolies.empty?
    puts hardware_anamolies
    sns_send(ERROR_MSG_HW, hardware_anamolies)
  else
    puts "No anamolies detected"
  end
end

def main
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
