#!/usr/bin/env ruby

require_relative '../lib/aws_helper'

def cpu_check
# total cpu used as a percentage
  cpu_used = `top -n 1 -b | awk '/^%Cpu/{print $2}'`
  cpu_used = cpu_used.to_f
  put_cloudwatch_data('Monitor Servers', 'CpuUsed', 'Host IP', ip_fetcher, cpu_used)
end

def disk_check
# disk used as a percentage
  disk_used = `df -h | awk '$NF=="/"{printf "%s", $5}'`
  disk_used = (disk_used.gsub('%', '')).to_i
  put_cloudwatch_data('Monitor Servers', 'DiskUsed', 'Host IP', ip_fetcher, disk_used)
end

def memory_check
# memory used as a percentage
  memory_used = `free -m | awk 'NR==2{printf "%.2f", $3*100/$2}'`
  memory_used = memory_used.to_f
  put_cloudwatch_data('Monitor Servers', 'MemoryUsed', 'Host IP', ip_fetcher, memory_used)
end

def ip_fetcher
# fetch server ip
  # server_ip = `/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'` # debian
  server_ip = `hostname -i | awk '{print $3}'` # centos
  server_ip = (server_ip.gsub("\n", '')).to_s
end

def main
  cloudwatch_conf_reader
  cloudwatch_client_constructor
  disk_check
  memory_check
  cpu_check
end

if __FILE__ == $0
  main
end
