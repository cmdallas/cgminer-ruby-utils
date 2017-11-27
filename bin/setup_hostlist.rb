#!/usr/bin/env ruby

require 'colorize'
require 'getoptlong'
require 'ipaddress'

# Use this file to interactively create a host file

ARGV << '-h' if ARGV.empty?

opts = GetoptLong.new(
  [ '--cidr', '-c', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--flush', GetoptLong::NO_ARGUMENT],
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--host-file', '-f', GetoptLong::REQUIRED_ARGUMENT],
  [ '--range', '-r', GetoptLong::OPTIONAL_ARGUMENT]
)

opts.each do |opt, arg|
  case opt
  when '--help'
    puts <<-EOF

Usage: setup_hostlist.rb -f /path/to/host_file [-c 10.0.0.1/24]

-c, --cidr:
    Build the host list by specifying a subnet using CIDR notation

-f, --host-file:
    Specify the location of the host file

--flush:
    Clear the host list file.
        Example usage: ./bin/setup_hostlist.rb -f hosts --flush

-r, --range:
    Build the host list by specifying the first and last addresses in a range

      EOF
  when '--cidr'
    @cidr_arg = arg
  when '--host-file'
    @host_file_arg = arg
  when '--flush'
    @flush = true
  when '--range'
    @range_arg = arg
  end
end

@host_list = []
################################################################################
# Interactive functions
def interactive_range_creation
  puts 'Enter first host (ex. 10.0.0.1):'
  first = $stdin.gets.to_s.chomp
  puts 'Enter last host (ex. 10.0.0.254):'
  last = $stdin.gets.to_s.chomp
  dynamic_host_constructor(first, last)
  edit_host_list
  puts @host_list
  puts 'Host list successfully editted!'.upcase.green
end

@address_range = ''
def interactive_cidr_creation
  print 'Enter network (ex. 10.0.0.1/24) '
  subnet = @cidr_arg
  @address_range = subnet
  static_host_constructor
  edit_host_list
  puts @host_list
  puts 'Host list successfully editted!'.upcase.green
end

@hostfile_problem = nil
def flush_hostlist
  # Empty the hostlist
  puts "\nClearing all entries in the hostlist located at: #{@host_file_arg}".yellow
  @host_list = []
  edit_host_list
  puts @host_list
  if @hostfile_problem
    raise 'Failed to flush the host list!'.upcase.red
  else
    puts "\nHost list successfully cleared!".upcase.green
  end
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
    File.open(@host_file_arg, "w") do |file|
      @host_list.each { |host| file.puts(host) }
      end
  rescue => e
    puts 'Problem opening the hosts file'.upcase.red
    puts e
    @hostfile_problem = true
  end
end

if __FILE__ == $0
  if @range_arg
    interactive_range_creation
  elsif @cidr_arg
    interactive_cidr_creation
  elsif @flush
    flush_hostlist
  end
end
