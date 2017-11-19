#!/usr/bin/env ruby

require 'fileutils'

LOG_PATH = File.expand_path('/') + 'var/log/cgminer-ruby-utils/'

def log_filepath_exists
  dirname = File.dirname(LOG_PATH)
  unless File.directory?(LOG_PATH)
    FileUtils.mkdir_p(LOG_PATH)
  end
end

def main
  log_filepath_exists
end
