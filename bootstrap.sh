#!/usr/bin/env bash
set -x

echo "Bootstrapping cgminer-ruby-utils"
apt-get update
apt-get install -y ruby gem
gem install rake bundler
(cd && git clone 'https://github.com/cmdallas/cgminer-ruby-utils.git')
app_dir=$_
rake -f $app_dir/Rakefile build:all
bundle install --gemfile=$app_dir/Gemfile
echo "Success!"

exit 0
