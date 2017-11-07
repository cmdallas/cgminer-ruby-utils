require 'colorize'
require 'ipaddress'
require 'optparse'

# Use this file to interactively create a host file

ARGV << '-h' if ARGV.empty?

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: setup_hostlist.rb [options]'
  opts.on(
    '-r',
    '--range',
    'Build the host list by specifying the first and last addresses in a range') do |v|
      options[:interactive_range_creation] = true
  end
    opts.on(
      '-c',
      '--cidr',
      'Build the host list by specifying a subnet using CIDR notation') do |v|
        options[:interactive_cidr_creation] = true
  end
    opts.on(
      '-f',
      '--flush',
      'Clear the host list file') do |v|
        options[:flush_hostlist] = true
  end
    opts.on_tail('-h', '--help', 'Please use one of the options above') do
      puts opts
      exit
  end
end.parse!

@address_range = ''
@host_list = []
# HACK: hard coded host file location for now...
@host_file_location = 'C:\Users\Chris\Documents\GitHub\cgminer-ruby-utils\etc\hosts.txt'

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

def interactive_cidr_creation
  print 'Enter network (ex. 10.0.0.1/24) '
  subnet = gets.to_s.chomp
  @address_range = subnet
  static_host_constructor
  edit_host_list
  puts @host_list
  puts 'Host list successfully editted!'.upcase.green
end

def flush_hostlist
  # Empty the hostlist
  puts "\nClearing all entries in the hostlist located at:".upcase.yellow
  puts @host_file_location
  @host_list = []
  edit_host_list
  puts @host_list
  puts "\nHost list successfully cleared!".upcase.green
end

def change_hostlist_file_location
  # TODO
  []
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
  @host_file_location = 'C:\Users\Chris\Documents\GitHub\cgminer-ruby-utils\etc\hosts.txt'
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
  if options[:interactive_range_creation]
    interactive_range_creation
  elsif options[:interactive_cidr_creation]
    interactive_cidr_creation
  elsif options[:flush_hostlist]
    flush_hostlist
  end
end
