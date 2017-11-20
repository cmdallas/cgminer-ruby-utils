#!/usr/bin/env bash
set -x

if [[ $(id -u) -ne 0 ]]
  then echo "Please run as root"
  exit 1
fi

echo "Bootstrapping cgminer-ruby-utils"
apt-get update
apt-get install -y ruby gem
gem install rake bundler
(cd && git clone 'https://github.com/cmdallas/cgminer-ruby-utils.git')
app_dir="~/cgminer-ruby-utils"
rake -f $app_dir/Rakefile build:all
bundle install --system --gemfile=$app_dir/Gemfile
echo "Finished"
exit 0
