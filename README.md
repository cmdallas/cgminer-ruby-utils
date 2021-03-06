# cgminer-ruby-utils

[![N|Solid](https://tinyurl.com/yabgovoj)](https://en.bitcoin.it/wiki/Main_Page)

**Ruby utilities to monitor cryptocurrency mining devices via the cgminer api and dispatch alerts using AWS SNS.**

⚠️⚠️ Caution ⚠️⚠️ Development was never finished (and was very naive) on this project. Alarm thresholds are hard coded and non configurable in its current state (like seriously, in `alarm_helper.rb`). 💔

# How To:

**Example Topology:**

[![N|Solid](https://s3-us-west-2.amazonaws.com/cgminer-ruby-utils/example_topology.png)]()

1.  Run the following shell script to prepare your device to use cgminer-ruby-utils. This script is configured for yum based systems:
    ```
    wget https://raw.githubusercontent.com/cmdallas/mining-scripts/master/bootstrap/bootstrap_ruby_utils_yum.sh
    bootstrap=$(basename $_)
    chmod +x $bootstrap && ./$bootstrap
    ```
2.  Create a hosts file that is delimited by new lines. This can be done manually or with the 'setup_hostlist.rb' script:

    **Examples using setup_hostlist.rb**

    ```
    # create a host list using CIDR notation.
    setup_hostlist.rb -f ~/cgminer-ruby-utils/hosts -c '10.0.0.1/24'

    # create a host list using a first-to-last range
    setup_hostlist.rb -f ~/cgminer-ruby-utils/hosts -r
    ```

3.  Populate the aws.conf file with your SNS Topic ARN, profile, and region. Make sure AWS credentials are configured on your system.

4.  Use the 'fleet_warden.rb' script to query all of the hosts in the host file:

    **Examples using fleet_warden.rb**

    ```
    # check to see if 15 minute average hashrate is above 11TH/s
    fleet_warden.rb -f ~/cgminer-ruby-utils/hosts --hash15m
    ```

5.  Configure cron to automatically fire the script every N minutes.
