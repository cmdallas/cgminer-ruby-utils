#!/usr/bin/env ruby

require 'cgminer/api'
require 'colorize'
require 'getoptlong'
require 'pry'
require 'sane_timeout'

ARGV << '--help' if ARGV.empty?

pool_opts = GetoptLong.new(
  [ '--add-pool', '--add', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--disable-pool', '--disable', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--enable-pool', '--enable', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--host-file', '-f', GetoptLong::REQUIRED_ARGUMENT],
  [ '--remove-pool', '--remove', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--switch-pool', '--switch', GetoptLong::OPTIONAL_ARGUMENT]
)

pool_opts.each do |opt, arg|
  case opt
  when '--help'
    puts <<-EOF

Usage: pool_utils.rb -f /path/to/host_file [option]

--add-pool, --add:
    (NOT YET IMPLEMENTED)

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

--switch-pool, --switch:
    (NOT YET IMPLEMENTED)

      EOF
  when '--add-pool'
  when '--disable-pool'
  when '--enable-pool'
  when '--help'
  when '--host-file'
  when '--remove-pool'
  when '--switch-pool'
  end
end
