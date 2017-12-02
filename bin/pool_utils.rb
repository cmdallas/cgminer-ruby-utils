#!/usr/bin/env ruby

require 'cgminer/api'
require 'colorize'
require 'fileutils'
require 'getoptlong'
require 'pry'
require 'sane_timeout'

require_relative '../lib/constants'

ARGV << '--help' if ARGV.empty?

pool_opts = GetoptLong.new(
  [ '--add-pool', '--add', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--conf_file', '-c', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--disable-pool', '--disable', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--enable-pool', '--enable', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--help', '-h', GetoptLong::NO_ARGUMENT],
  [ '--host-file', '-f', GetoptLong::REQUIRED_ARGUMENT],
  [ '--remove-pool', '--remove', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--switch-pool', '-s', GetoptLong::OPTIONAL_ARGUMENT]
)

pool_opts.each do |opt, arg|
  case opt
  when '--help'
    puts <<-EOF

Usage: pool_utils.rb -c /path/to/cgminer.conf -f /path/to/host_file [option]

--add-pool, --add:
    (NOT YET IMPLEMENTED)

--conf, -c:
    Specify the location of the cgminer.conf file

--disable-pool, --disable:
    (NOT YET IMPLEMENTED)

--enable-pool, --enable:
    (NOT YET IMPLEMENTED)

--help, -h:
    Show help menu

--host-file, -f:
    Specify the location of the host file

--remove-pool, --remove:
    (NOT YET IMPLEMENTED)

--switch-pool:
    (NOT YET IMPLEMENTED)

      EOF
  when '--add-pool'
  when '--conf'
    @conf_file_arg = arg.to_s
  when '--disable-pool'
  when '--enable-pool'
  when '--host-file'
    @host_file_arg = arg
  when '--remove-pool'
  when '--switchpool'
    @switch_pool_parameter = arg.to_s
  end
end

def backup_cgminer_conf
  `cp -y "#{@conf_file_arg}" "#{@conf_file_arg}.bak"`
end

def conf_file_handle
  begin
    host_file = File.open(@conf_file_arg)
  rescue => e
    puts e
  end
end

def host_file_handle
  begin
    host_file = File.open(@host_file_arg)
  rescue => e
    puts e
  end
end

@pool_host_list = []
def pool_host_list_constructor
# push the host list from a file into an array
  host_file = @host_file_arg
  begin
    File.open(host_file, "r") do |host|
      host.each_line do |line|
        # remove any possible new lines from ingested hosts file
        line.delete!("\n")
        @pool_host_list << line
      end
    end
  rescue
    puts 'Problem creating the hosts file. Was one specified?'.upcase.red
  end
end

def switch_pool
  command = SWITCH_POOL
  parameter = @switch_pool_parameter
  @pool_host_list.each do |addr|
    begin
      host = CGMiner::API::Client.new(addr.to_s, 4028)
      returned_data = Timeout::timeout(3) { host.send(command, parameter) }
      json_response = JSON.parse(returned_data.body.to_json)
      puts "#{addr} pool switched to (TODO: parse for pool) #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n"
    rescue => e
        puts e
    end
  end
end

def main
  pool_host_list_constructor
  switch_pool
end

if __FILE__ == $0
  main
end
