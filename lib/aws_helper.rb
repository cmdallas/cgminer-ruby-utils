#!/user/bin/env ruby

require 'aws-sdk-cloudwatch'
require 'aws-sdk-sns'

def cloudwatch_client_constructor
  credentials = Aws::SharedCredentials.new(profile_name: 'default')
  Aws::EC2::Client.new(credentials: credentials)
  @cloudwatch = Aws::CloudWatch::Client.new(region: 'us-west-2')
end

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
