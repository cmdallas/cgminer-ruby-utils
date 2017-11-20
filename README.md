# cgminer-ruby-utils

[![N|Solid](https://tinyurl.com/yabgovoj)](https://en.bitcoin.it/wiki/Main_Page)

Ruby utilities to monitor cryptocurrency mining devices via the cgminer api.

# How to:
1. Run the following shell script to prepare your device to use cgminer-ruby-utils. This script is configured for debian based systems:
    ```
    wget https://raw.githubusercontent.com/cmdallas/cgminer-ruby-utils/master/bootstrap.sh
    bootstrap=$(basename $_)
    chmod +x $bootstrap && sudo ./$bootstrap
    ```
2. Create a hosts file that is delimited by new lines. This can be done manually or with the 'setup_hostlist.rb' script.

    **Examples using setup_hostlist.rb**
    ```
    # create a host list using CIDR notation.
    ruby ~./cgminer-ruby-utils/bin/setup_hostlist.rb --f ~/cgminer-ruby-utils/hosts -c '10.0.0.1/24'

    # create a host list using a first-to-last range
    ruby ~./cgminer-ruby-utils/bin/setup_hostlist.rb --f ~/cgminer-ruby-utils/hosts -r '10.0.0.1,10.0.0.10'
    ```
3. Use the 'adhoc_runer.rb' script to query all of the hosts in the host file

    **Examples using adhoc_runner.rb**
    ```
    # check to see if 15 minute average hashrate is above 11000TH/s
    ruby ~./cgminer-ruby-utils/bin/adhoc_runner.rb -f ~/cgminer-ruby-utils/hosts --hash15m
    ```
4. Configure cron to automatically fire the script every N minutes

**Warning:**
- AWS SNS topic is currently hardcoded in 'adhoc_runner.rb' hosts file.
