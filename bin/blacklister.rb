#!/usr/bin/env ruby

require 'fileutils'
require 'getoptlong'

ARGV << '--help' if ARGV.empty?

opts = GetoptLong.new(
  [ '--host-file', '-f', GetoptLong::REQUIRED_ARGUMENT],
  [ '--ip', '-i', GetoptLong::OPTIONAL_ARGUMENT]
)

opts.each do |opt, arg|
  case opt
  when '--help'
    puts <<-EOF

Usage: blacklister.rb -f hosts --ip '10.0.0.74 10.0.0.75'

-f, --host-file:
    Specify the location of the host file

-i, --ip:
    IP to be removed from the host file

    EOF
  when '--host-file'
    @blacklist_host_file_arg = arg
  when '--ip'
    @blacklisted_ips = arg.split.map { |ip| ip + "\n" }
  end
end

def blacklist
  begin
    updated_hosts = String.new
    host_file = File.readlines(@blacklist_host_file_arg)
    host_file.each do |line|
      if @blacklisted_ips.include?(line)
        line.sub!(line, '')
      else
        updated_hosts << line
      end
    end
  end
  host_file = File.open(@blacklist_host_file_arg, 'w')
  host_file.write(updated_hosts)
end

def main
  if @blacklisted_ips
    blacklist
  end
end

if __FILE__ == $0
  main
end
