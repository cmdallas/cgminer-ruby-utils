#!/usr/bin/env ruby

require 'colorize'
require 'fileutils'
require 'getoptlong'
require 'pry'
require 'sane_timeout'

require_relative '../lib/api'
require_relative '../lib/assets'
require_relative '../lib/constants'

ARGV << '--help' if ARGV.empty?

pool_opts = GetoptLong.new(
  [ '--add-pool', '--add', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--conf_file', '-c', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--disable-pool', '--disable', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--enable-pool', '--enable', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--help', '-h', GetoptLong::NO_ARGUMENT],
  [ '--host-file', '-f', GetoptLong::REQUIRED_ARGUMENT],
  [ '--pools', '-p', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--remove-pool', '--rm', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--switch-pool', '-s', GetoptLong::OPTIONAL_ARGUMENT]
)

@pool_run_commands = []
pool_opts.each do |opt, arg|
  case opt
  when '--help'
    puts <<-EOF

Usage: pool_utils.rb -c /path/to/cgminer.conf -f /path/to/host_file [option]

--add-pool, --add:
    Usage: pool_utils.rb -f hosts --add-pool 'stratum+tcp://stratum.slushpool.com:3333 username password'

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

--pools, -p
    Show configured pools

--remove-pool, --rm:
    Usage: pool_utils.rb -f hosts --remove-pool '6'

--switch-pool:
    Switch pool N to the highest priority (the pool is also enabled)
    Usage: pool_utils.rb -f hosts --switch-pool '0'

      EOF
  when '--add-pool'
    @add_pool_args = arg.split
    #url, usr, pass
    @pool_run_commands << ADD_POOL
  when '--conf'
    @conf_file_arg = arg.to_s
  when '--disable-pool'
    @pool_run_commands << DISABLE_POOL
  when '--enable-pool'
    @pool_run_commands << ENABLE_POOL
  when '--host-file'
    @host_file_arg = arg
  when '--pools'
    @pool_run_commands << POOLS
  when '--remove-pool'
    @remove_pool_arg = arg
    @pool_run_commands << REMOVE_POOL
  when '--switchpool'
    @switch_pool_arg = arg.to_s
    @pool_run_commands << SWITCH_POOL
  end
end

def conf_file_handle
  begin
    host_file = File.open(@conf_file_arg)
  rescue => e
    puts e
  end
end

def backup_cgminer_conf
  `cp -y "#{@conf_file_arg}" "#{@conf_file_arg}.bak"`
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

def send_query(command, message=nil, json=nil, *parameters)
  @pool_host_list.each do |addr|
    begin
      host = CGMiner::API::Client.new(addr.to_s, 4028)
      returned_data = Timeout::timeout(TIMEOUT) { host.send(command, *parameters) }
      json_response = JSON.parse(returned_data.body.to_json)
      if message
        print addr
        print message
      end
      if json
        puts json_response
      end
    rescue => e
        puts e
    end
  end
end

### API Commands
def add_pool
  p = @add_pool_args
  # p[0] == URL
  # p[1] == USR
  # P[2] == PASS
  send_query(ADD_POOL, message=@add_msg, json=nil, p[0], p[1], p[2])
end

def disable_pool
  []
end

def enable_pool
  []
end

def pools
  send_query(POOLS, message=nil, json=true)
end

def removepool
  send_query(REMOVE_POOL, message=@remove_msg, json=nil, @remove_pool_arg)
end

def switch_pool
  send_query(SWITCH_POOL, message=@switch_msg, json=nil, @switch_pool_arg)
end

def main
  pool_host_list_constructor
  @pool_run_commands.each do |cmd|
    case cmd
    when ADD_POOL
      add_pool
    when DISABLE_POOL
      disable_pool
    when ENABLE_POOL
      enable_pool
    when POOLS
      pools
    when REMOVE_POOL
      removepool
    when SWITCH_POOL
      switchpool
    end
  end
end

if __FILE__ == $0
  main
end
