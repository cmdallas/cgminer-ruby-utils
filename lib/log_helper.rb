#!/usr/bin/env ruby

require 'fileutils'
require 'logger'

LOG_PATH = File.expand_path('/') + 'var/log/cgminer-ruby-utils/'

def log_filepath_exists
  dirname = File.dirname(LOG_PATH)
  unless File.directory?(LOG_PATH)
    FileUtils.mkdir_p(LOG_PATH)
  end
end

@logger = Logger.new("#{LOG_PATH}logs", 'hourly') # hourly for testing

def main
  log_filepath_exists
end
