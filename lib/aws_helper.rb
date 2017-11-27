#!/user/bin/env ruby

require 'aws-sdk-cloudwatch'
require 'aws-sdk-ec2'
require 'aws-sdk-sns'

### CloudWatch
def cloudwatch_client_constructor
  credentials = Aws::SharedCredentials.new(profile_name: 'default')
  Aws::EC2::Client.new(
    credentials: credentials,
    region: 'us-west-2'
  )
  @cloudwatch = Aws::CloudWatch::Client.new(region: 'us-west-2')
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
    region: 'us-west-2'
  )
end

def sns_send(error_msg, hosts)
  begin
    @sns.publish({
      topic_arn: "arn:aws:sns:us-west-2:114600190083:Alert",
      message: "#{error_msg} #{hosts}"
    })
  rescue Aws::Errors::MissingCredentialsError
    log_file_handle.write("SNS SNS-AUTH-FAIL #{e} #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n")
  rescue => e
    log_file_handle.write("SNS SNS-FATAL #{e} #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n")
  end
end
