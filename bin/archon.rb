require 'aws-sdk-cloudwatch'
require 'aws-sdk-ec2'
require 'cgminer/api'
require 'colorize'
require 'ipaddress'
require 'sane_timeout'

require_relative 'assets'

###############################################################################
@host_list = []

def host_list_constructor
  # Build the host list from a file
  # HACK: hard coded host file location for now...
  host_file_location = 'C:\Users\Chris\Documents\GitHub\cgminer-ruby-utils\etc\hosts.txt'
  begin
    File.open(host_file_location, "r") do |host|
      host.each_line do |line|
        # Remove any possible new lines from ingested hosts file
        line.delete!("\n")
        @host_list << line
      end
    end
  rescue => e
    puts ' Problem creating the hosts file'.upcase.red
    puts e
  end
end

###############################################################################
def init_cloudwatch
  # Pull credentials stored in ~/.aws/credentials
  credentials = Aws::SharedCredentials.new(profile_name: 'default')
  Aws::EC2::Client.new(credentials: credentials)

  # Instantiate CloudWatch client
  @cloudwatch = Aws::CloudWatch::Client.new(region: 'us-west-2')
end

# TODO: Since I dont have a miner to test this on I am using the getwork metric for testing
def put_getwork(namespace, name_metric, dimension_name, dimension_value, datapoint_value)
  # Dump metrics directly into CloudWatch
  @cloudwatch.put_metric_data({
    namespace: namespace,
    metric_data: [
      {
        metric_name: name_metric, # Getworks for testing
        dimensions: [
          {
            name: dimension_name, # 'IP'
            value: dimension_value, # The actual IP address
          },
        ],
        timestamp: Time.now,
        value: datapoint_value, # Value of the emitted_metric
        unit: "Count",
        storage_resolution: 1,
      },
    ],
  })
end

###############################################################################
def query_cgminers(command)
  # Query the host list constructed by the host_constructor
  command = command.to_sym

  @host_list.each do |addr|
    begin
      host = Timeout::timeout(10) { CGMiner::API::Client.new(addr.to_s, 4028) }
      returned_data = host.send(command)
      json_response = JSON.parse(returned_data.body.to_json)
      emitted_metric = json_response[0]["Getworks"]
      put_getwork('namespace3', 'Getworks', 'IP', addr, emitted_metric)
      # add logic to append logfile
      puts addr + ' ' + emitted_metric.to_s + ' SUCCESS ' + \
                Time.now.strftime('%m %d %Y %H:%M:%S').to_s
    rescue => e
      # add logic to append logfile
      puts addr + ' - FAILURE ' + e.to_s + ' ' + \
                Time.now.strftime('%m %d %Y %H:%M:%S').to_s
    end
  end
end

###############################################################################
def main
  # TODO: move first 2 begin/rescue blocks into their own functions?
  begin
    puts ('#' * 75).red; puts "\n"; archon_text; puts "\n"
    puts ' Negotiating credentials with AWS...'.yellow
    init_cloudwatch
    puts " Credentials found!".upcase.green
  rescue => e
    puts ' [ERROR] Problem with credentials'.red
    raise e
  end

  begin
    puts "\n Building the host list...".yellow
    #dynamic_host_constructor('10.0.0.74', '10.0.0.76')
    host_list_constructor
    puts " The host list has been constructed with the following hosts:\n".green
    puts ' ' + @host_list.to_s + "\n\n"
    puts (' #' * 19).green
    puts (' #' * 4).green + ' BEGINNING MONITORING' + (' #' * 4).green + "\n\n"
  rescue => e
    puts ' [ERROR] Could not create host list'.red
    raise e
  end

  while true
    query_cgminers('summary')
    # query_cgminers('devs')
    sleep 5
    redo
  end
end

if __FILE__ == $0
  main
end
