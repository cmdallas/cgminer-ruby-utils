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

-f, --host-file:
    Specify the location of the host file

-i, --ip:
    IP to be removed from the host file

    EOF
  when '--host-file'
    @blacklist_host_file_arg = arg
  when '--ip'
    @blacklist_ip = arg
  end
end

def adhoc_blacklist
  hosts = File.read(@blacklist_host_file_arg)
  blacklist = hosts.gsub(/#{@blacklist_ip}\n/, '')
  File.write(@blacklist_host_file_arg, blacklist)
end

if @blacklist_ip
  adhoc_blacklist
end
