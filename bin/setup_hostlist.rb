#!/usr/bin/env ruby

require 'colorize'
require 'ipaddress'
require 'optparse'

# Use this file to interactively create a host file

ARGV << '-h' if ARGV.empty?

@options = {}
OptionParser.new do |opts|
  opts.banner = "\nUsage: setup_hostlist.rb -f /path/to/host_file [-c 10.0.0.1/24],\
  [-r TODO], [--flush]"
  @options[:cidr_creation] = nil
  opts.on(
    '-c',
    '--cidr',
    'Build the host list by specifying a subnet using CIDR notation') do |v|
      @options[:cidr_creation] = ARGV
  end
  @options[:hosts] = nil
  opts.on(
    '-f',
    '--host-file',
    'host file location') do |v|
      @options[:hosts] = ARGV
  end
  @options[:flush] = nil
  opts.on(
    '--flush',
    'Clear the host list file'
    'Example usage: ./bin/setup_hostlist.rb -f hosts --flush') do |v|
      @options[:flush] = true
  end
  @options[:range_creation] = nil
  opts.on(
    '-r',
    '--range',
    'Build the host list by specifying the first and last addresses in a range') do |v|
      @options[:range_creation] = true
    end
    opts.on_tail('-h', '--help', 'Please use one of the options above') do
      puts opts
      exit
    end
end.parse!

@host_file_location = @options[:hosts][0]
@host_list = []

################################################################################
# Interactive functions
def interactive_range_creation
  print 'Enter first host (ex. 10.0.0.1): '
  first = gets.to_s.chomp
  print 'Enter last host (ex. 10.0.0.254): '
  last = gets.to_s.chomp
  dynamic_host_constructor(first, last)
  edit_host_list
  puts @host_list
  puts 'Host list successfully editted!'.upcase.green
end

@address_range = ''
def interactive_cidr_creation
  print 'Enter network (ex. 10.0.0.1/24) '
  subnet = @options[:cidr_creation][1]
  @address_range = subnet
  static_host_constructor
  edit_host_list
  puts @host_list
  puts 'Host list successfully editted!'.upcase.green
end

def flush_hostlist
  # Empty the hostlist
  puts "\nClearing all entries in the hostlist located at: #{@host_file_location}".yellow
  @host_list = []
  edit_host_list
  puts @host_list
  puts "\nHost list successfully cleared!".upcase.green
end

################################################################################
def dynamic_host_constructor(first_address, last_address)
# Build a custom range of IP addresses without using a netmask
  first = IPAddress first_address
  last = IPAddress last_address
  @host_list = first.to(last)
end

def static_host_constructor
# Use @address_range to construct a list
  ip = IPAddress @address_range
  ip.each do |addr|
    @host_list << addr.address
  end
end

################################################################################
def edit_host_list
# Build the host list from a file
  begin
    File.open(@host_file_location, "w") do |file|
      @host_list.each { |host| file.puts(host) }
      end
  rescue => e
    puts ' Problem creating the hosts file'.upcase.red
    puts e
  end
end

if __FILE__ == $0
  if @options[:range_creation]
    interactive_range_creation
  elsif @options[:cidr_creation]
    interactive_cidr_creation
  elsif @options[:flush]
    flush_hostlist
  end
end
