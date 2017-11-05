require 'colorize'
require 'ipaddress'
require 'optparse'

@address_range = '' # Used with static_host_constructor
@host_list = []
@host_file_location = 'C:\Users\Chris\Documents\GitHub\cgminer-ruby-utils\etc\hosts.txt'

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

def flush_hostlist
  # Empty the hostlist
  @host_list = []
end

def edit_host_list
  # Build the host list from a file
  host_file_location = 'C:\Users\Chris\Documents\GitHub\cgminer-ruby-utils\etc\hosts.txt'
  begin
    File.open(host_file_location, "w") do |file|
      @host_list.each { |host| file.puts(host) }
      end
  rescue => e
    puts ' Problem creating the hosts file'.upcase.red
    puts e
  end
end

def main
  # TODO: Use optparse to interactively edit the host list file
  []
end
