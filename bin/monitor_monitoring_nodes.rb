#!/usr/bin/env ruby

require_relative '../lib/aws_helper'

def disk_check
  disk_used = `df -h | awk '$NF=="/"{printf "%s", $5}'`
  disk_used = (disk_used.gsub('%', '')).to_i
  put_cloudwatch_data('MonitorServers', 'DiskUsed', 'Monitoring Host Metrics', ip_fetcher, disk_used)
end

def memory_check
# memory used as a percentage
  memory_used = `free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }'`
  memory_used = memory_used.to_i
  put_cloudwatch_data('MonitorServers', 'MemoryUsed', 'Monitoring Host Metrics', ip_fetcher, disk_used)
end

def ip_fetcher
  server_ip = `/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`
  server_ip = (server_ip.gsub("\n", '')).to_s
end

def main
  cloudwatch_client_constructor
  disk_check
  memory_check
end

if __FILE__ == $0
  main
end
