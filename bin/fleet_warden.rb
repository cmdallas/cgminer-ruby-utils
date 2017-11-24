#!/usr/bin/env ruby

require 'cgminer/api'
require 'colorize'
require 'optparse'
require 'pry'
require 'sane_timeout'

require_relative '../lib/alarm_helper'
require_relative '../lib/assets'
require_relative '../lib/aws_helper'
require_relative '../lib/constants'
require_relative '../lib/log_helper'

ARGV << '--help' if ARGV.empty?

@options = {}
OptionParser.new do |opts|
  opts.banner = "\nUsage: ./adhoc_runner.rb -f /path/to/hostsfile [option]"
  @options[:host_file] = nil
  opts.on(
    '-f',
    '--host-file',
    'Host file location') do |v|
      @options[:host_file] = ARGV
    end
  @options[:hashrate_listener] = nil
  opts.on(
    '--h15m',
    '--hash15m',
    'Listen for hashrate anomalies') do |v|
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
# build the host list from a file
  host_file = @options[:host_file][0]
  begin
    File.open(host_file, "r") do |host|
      host.each_line do |line|
        # remove any possible new lines from ingested hosts file
        line.delete!("\n")
        @host_list << line
      end
    end
  rescue => e
    puts e.backtrace
    puts ' Problem creating the hosts file'.upcase.red
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
      if @options[:hashrate_listener]
        hashrate_listener_mh15m(addr, json_response)
      elsif @options[:hardware_listener]
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
  # TODO: this needs to be more dynamic
  if !@hashrate_mh15m_anomalies.empty?
    puts @hashrate_mh15m_anomalies
    sns_send(ERROR_MSG_HASHRATE, @hashrate_mh15m_anomalies)
  elsif !@hardware_anomalies.empty?
    puts @hardware_anomalies
    sns_send(ERROR_MSG_HW, @hardware_anomalies)
  elsif !@timeout_anomalies.empty?
    puts @timeout_anomalies
    sns_send(ERROR_MSG_TIMEOUT, @timeout_anomalies)
  elsif !@fatal_anomalies.empty?
    puts @fatal_anomalies
    sns_send(ERROR_MSG_FATAL, @fatal_anomalies)
  else
    puts "Done"
  end
  close_log_file_handle
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
