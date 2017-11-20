#!/usr/bin/env rake

require 'fileutils'

namespace :build do |all_tasks|
  dir = "#{File.expand_path('/')}var/log/cgminer-ruby-utils/"
  desc "Create: #{dir}"
  task :log_dir do
    FileUtils.mkdir_p(dir) unless Dir.exists?(dir); puts
  end

  desc "Do everything"
  task :all do
    all_tasks.tasks.each do |task|
      Rake::Task[task].invoke
    end
  end
end
