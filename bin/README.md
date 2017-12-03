#### Blacklister
* blacklister.rb
  * Script to interactively blacklist (ie remove) a host from a hosts file. Use for hosts being taken out of service to silence false alerts from being dispatched.
  ```
  Usage: ./blacklister.rb -f hosts --ip '10.0.0.74 10.0.0.75'
  ```

#### Fleet Warden
* fleet_warden.rb
  * Fleet Warden is designed to query the cgminer api and call alarm listeners stored in lib/alarm_helper. Fleet Warden relies up a newline delimited host file containing only IP addresses.
  ```
  Usage: ./fleet_warden.rb -f hosts --hash15m
  ```

#### Monitor Monitoring Nodes
* monitor_monitoring_nodes.rb
  * Scripts to monitor the monitoring nodes. Information such as cpu, disk, & ram are emitted to CloudWatch.

#### Pool Utils
* pool_utils.rb
  * Pool Utils contains utilities such as adding, switching pools for all hosts within a specified, newline delimited host file.
  ```
  Usage: ./pool_utils.rb -f hosts [option]
  ```

#### Setup Hostlist
* setup_hostlist.rb
  * Setup Hostlist is designed to interactively create a host file using cidr notation, ranges, etc.
  ```
  Usage: ./setup_hostlist.rb -f hosts [-c 10.0.0.1/24]
  ```
