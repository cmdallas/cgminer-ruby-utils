#!/usr/bin/env rub

require_relative 'log_helper'

@hardware_anomalies = []
@hashrate_mh15m_anomalies = []
@timeout_anomalies = []
@fatal_anomalies = []

def alarm_dispatcher
  @all_anomalies.each do |anomaly, value|
    if !value.empty?
      case anomaly
      when :hardware_anomalies
        puts @hardware_anomalies
        sns_send(ERROR_MSG_HW, @hardware_anomalies)
      when :hashrate_mh15m_anomalies
        puts @hashrate_mh15m_anomalies
        sns_send(ERROR_MSG_HASHRATE, @hashrate_mh15m_anomalies)
      when :timeout_anomalies
        puts @timeout_anomalies
        sns_send(ERROR_MSG_TIMEOUT, @timeout_anomalies)
      when :fatal_anomalies
        puts @fatal_anomalies
        sns_send(ERROR_MSG_FATAL, @fatal_anomalies)
      end
    end
  end
end

def anomaly_collector
  @all_anomalies = {
    hardware_anomalies: @hardware_anomalies,
    hashrate_mh15m_anomalies: @hashrate_mh15m_anomalies,
    timeout_anomalies: @timeout_anomalies,
    fatal_anomalies: @fatal_anomalies
  }
end

def fatal_listener(addr, trace)
  @fatal_anomalies << "#{addr} #{Time.now.strftime('%m-%d %H:%M')}"
  log_file_handle.write("#{addr} FATAL #{trace} #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n")
end

def hardware_listener(addr, json_response)
  hw_errors = json_response[0]["Hardware Errors"]
  if hw_errors < 1
    log_file_handle.write("#{addr} OK #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n")
  else
    log_file_handle.write("#{addr} HWERROR #{hw_errors} #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n")
    @hardware_anomalies << "#{addr} HWERROR #{hw_errors}"
  end
end

def hashrate_listener_mh15m(addr, json_response)
  uptime = json_response[0]["Elapsed"]
  mhs_15m = json_response[0]["MHS 15m"]
  # allow 3 minutes before making determinations
  if uptime < 180
    log_file_handle.write("#{addr} warming up. Uptime: #{uptime}\n")
  elsif uptime.to_i > 180 && mhs_15m.to_i > 11000
    log_file_handle.write("#{addr} OK mhs15m: #{mhs_15m} #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n")
  elsif uptime.to_i > 180 && mhs_15m.to_i < 11000
    puts "#{addr} LOWHASH mhs_15m: #{mhs_15m} #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n"
    @hashrate_mh15m_anomalies << "#{addr}: #{mhs_15m} | #{uptime}"
    log_file_handle.write("#{addr} LOWHASH mhs_15m: #{mhs_15m} #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n")
  else
    puts mhs_15m
  end
end

def timeout_listener(addr)
  @timeout_anomalies << "#{addr} #{Time.now.strftime('%m-%d %H:%M')}"
  log_file_handle.write("#{addr} TIMEOUT #{Time.now.strftime('%m %d %Y %H:%M:%S')}\n")
end
