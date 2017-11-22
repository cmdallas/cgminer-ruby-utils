#!/usr/bin/env ruby

require_relative '../lib/aws_helper'

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
