#!/usr/bin/env ruby

require 'fileutils'

LOG_PATH = File.expand_path('/') + 'var/log/cgminer-ruby-utils/'

def log_filepath_exists
  dirname = File.dirname(LOG_PATH)
  unless File.directory?(LOG_PATH)
    FileUtils.mkdir_p(LOG_PATH)
  end
end

def log_file_handle
  log_file_path = "#{LOG_PATH}logs"
  begin
    log = File.open(log_file_path, 'a+')
    log.sync = true
    log
  rescue => e
    puts e.backtrace
    puts 'Problem with log file'
  end
end

def close_log_file_handle
  log_file_handle.close
end

def main
  log_filepath_exists
end
