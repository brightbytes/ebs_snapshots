#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'ebs_snapshots'

QUEUE = 'ebs.snapshots'

connection = Bunny.new(:automatically_recover => false)
connection.start
channel = connection.create_channel
snapshot_queue = channel.queue(QUEUE)
ebs_snapshots = EbsSnapshots::Base.new

begin
  puts "Waiting for Snapshot request..."
  snapshot_queue.subscribe(:block => true) do |delivery_info, properties, message_body|
    # message body is a stringified ruby hash of any elements of ebs_snapshots/config/config.yml
    config = eval(message_body)
    ebs_snapshots.run(config)
  end

rescue Interrupt => _
  connection.close
  exit(0)
end
