require 'aws-sdk-cloudwatch'
require 'aws-sdk-ec2'
require 'cgminer/api'
require 'ipaddress'

###############################################################################
@address_range = '' # Test host for now. Add cidr for a range
@addr_list = []

# Build a custom range of IP addresses without using a netmask
def dynamic_host_constructor(first_address, last_address)
  first = IPAddress first_address
  last = IPAddress last_address
  @addr_list = first.to(last)
end

# Use @address_range to construct a list
def static_host_constructor
  ip = IPAddress @address_range
  ip.each do |addr|
    @addr_list << addr.address
  end
end

# Empty the hostlist
def flush_hostlist
  @addr_list = []
end

###############################################################################
# Pull credentials stored in ~/.aws/credentials and instantiate CloudWatch client
def init_cloudwatch
  credentials = Aws::SharedCredentials.new(profile_name: 'default')
  Aws::EC2::Client.new(credentials: credentials)

  @cloudwatch = Aws::CloudWatch::Client.new(region: 'us-west-2')
end

# TODO: Since I dont have a miner to test this on I am using the getwork metric for testing
def put_getwork(namespace, name_metric, dimension_name, dimension_value, datapoint_value)
  # Dump metrics into CloudWatch
  @cloudwatch.put_metric_data({
    namespace: namespace,
    metric_data: [ # required
      {
        metric_name: name_metric, # Getwprks
        dimensions: [
          {
            name: dimension_name, # IP:
            value: dimension_value, # 172.16.0.3
          },
        ],
        timestamp: Time.now,
        value: datapoint_value, # func name value
        unit: "Count",
        storage_resolution: 1,
      },
    ],
  })
end

###############################################################################
# Query the host list constructed by the host_constructor
def query_cgminers(command)
  command = command.to_sym

  @addr_list.each do |addr|
    begin
      host = CGMiner::API::Client.new(addr.to_s, 4028)
      returned_data = host.send(command)
      json_response = JSON.parse(returned_data.body.to_json)
      emitted_metric = json_response[0]["Getworks"]
      put_getwork('namespace3', 'Getworks', 'IP', addr, emitted_metric)
      # add logic to append logfile
      puts addr + ' ' + emitted_metric.to_s + ' SUCCESS ' + \
                        Time.now.strftime('%m %d %Y %H:%M:%S').to_s
    rescue => e
      # add logic to append logfile
      puts addr + ' - FAILURE ' + e.to_s + ' ' + Time.now.strftime('%m %d %Y %H:%M:%S').to_s
    end
  end
end

###############################################################################
def main
  begin
    puts 'Negotiating credentials with AWS'
    init_cloudwatch
  rescue => e
    puts 'Problem with credentials'
    raise e
  end

  begin
    puts 'Building host list'
    dynamic_host_constructor('10.0.0.74', '10.0.0.76')
    puts 'The host list has been constructed with the following hosts:'
    puts @addr_list.to_s + "\n"
  rescue => e
    puts '[ERROR] Could not create host list'
    raise e
  end

  while true
    query_cgminers('summary')
    # query_cgminers('devs')
    # Ideally sleep will be 15min (900)
    sleep 5
    redo
  end
end

if __FILE__ == $0
  main
end
