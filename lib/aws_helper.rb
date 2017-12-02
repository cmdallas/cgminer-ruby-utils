#!/user/bin/env ruby

require 'aws-sdk-cloudwatch'
require 'aws-sdk-ec2'
require 'aws-sdk-sns'
require 'json'

### CloudWatch
def cloudwatch_client_constructor
  credentials = Aws::SharedCredentials.new(profile_name: @cloudwatch_profile)
  Aws::EC2::Client.new(
    credentials: credentials,
    region: @cloudwatch_region
  )
  @cloudwatch = Aws::CloudWatch::Client.new(region: @cloudwatch_region)
end

def put_cloudwatch_data(namespace, name_metric, dimension_name, dimension_value, datapoint_value)
# make PutMetricData api call to cloudwatch using custom metrics
  @cloudwatch.put_metric_data({
    namespace: namespace,
    metric_data: [
      {
        metric_name: name_metric,
        dimensions: [
          {
            name: dimension_name,
            value: dimension_value,
          },
        ],
        timestamp: Time.now,
        value: datapoint_value,
        unit: "Count",
        storage_resolution: 1,
      },
    ],
  })
end

### SNS
def sns_client_constructor
  @sns = Aws::SNS::Client.new(
    region: @sns_region
  )
end

def sns_send(error_msg, hosts)
  begin
    @sns.publish({
      topic_arn: @sns_topic,
      message: "#{error_msg} #{hosts}"
    })
  rescue Aws::Errors::MissingCredentialsError
    log_file_handle.write("SNS SNS-AUTH-FAIL #{e} #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n")
  rescue => e
    log_file_handle.write("SNS SNS-FATAL #{e} #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n")
  end
end

def cloudwatch_conf_reader
  conf_file = File.read('../aws.conf')
  data = JSON.parse(conf_file)
  @cloudwatch_profile = data['cloudwatch_config']['profile']
  @cloudwatch_region = data['cloudwatch_config']['region']
end

def sns_conf_reader
  conf_file = File.read('../aws.conf')
  data = JSON.parse(conf_file)
  @sns_profile = data['sns_config']['profile']
  @sns_region = data['sns_config']['region']
  @sns_topic = data['sns_config']['sns_topic_arn']
end
