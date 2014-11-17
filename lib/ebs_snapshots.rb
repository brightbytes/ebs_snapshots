#!/usr/bin/env ruby
require 'yaml'
require 'logger'
require 'ebs_snapshots/version.rb'
require 'ebs_snapshots/snapshot.rb'

CONFIG = YAML::load_file((File.join(Dir.pwd, 'config/config.yml')))

module EbsSnapshots
  include EbsSnapshots::Snapshot
  def create_snapshots
    $LOG.info("Starting create EbsSnapshots::Snapshot....")
    region = CONFIG['region'] != nil ? CONFIG['region'] : ENV['AWS_REGION']

    if CONFIG['instance_names'] != nil
      $LOG.debug("==> about to run create_snapshot_from_instance_name #{CONFIG['instance_names']} #{region} ")
      instance_names = CONFIG['instance_names'].to_s.split(',')
      EbsSnapshots::Snapshot::create_snapshot_from_instance_name(region, instance_names, CONFIG['namespace'])
    end

    if CONFIG['instance_ids'] != nil
      $LOG.debug("==> about to run create_snapshot_from_instances #{CONFIG['instance_ids']} #{region} ")
      instance_ids = CONFIG['instance_ids'].to_s.split(',')
      EbsSnapshots::Snapshot.create_snapshot_from_instances(region, instance_ids, CONFIG['namespace'])
    end

    if CONFIG['image_ids'] != nil
      $LOG.debug("==> about to run create_snapshot_from_images #{CONFIG['image_ids']} #{region} ")
      image_ids = CONFIG['image_ids'].to_s.split(',')
      EbsSnapshots::Snapshot.create_snapshot_from_images(region, image_ids, CONFIG['namespace'])
    end
    $LOG.info("Finished create EbsSnapshots::Snapshot....")
  end

  def prune_snapshots
   $LOG.info("Starting prune snapshots....")
    region = CONFIG['region'] != nil ? CONFIG['region'] : ENV['AWS_REGION']
    age_in_days = CONFIG['retention']['daily']

    if age_in_days == nil
      periodic_interval = CONFIG['retention']['periodic']['interval']
      periodic_span = CONFIG['retention']['periodic']['span']

      # Calculate age_in_days by multiplying interval and span
      if periodic_interval != nil && periodic_span != nil
        age_in_days = periodic_interval * periodic_span
      end
    end

    if CONFIG['instance_names'] != nil
      $LOG.debug("==> about to run prune_snapshot_by_instance_name #{CONFIG['instance_names']} #{region} ")
      instance_names = CONFIG['instance_names'].to_s.split(',')
      EbsSnapshots::Snapshot.prune_snapshot_by_instance_name(region, instance_names, age_in_days)
    end

    if CONFIG['instance_ids'] != nil
      $LOG.debug("==> about to run prune_snapshot_by_instance_ids #{CONFIG['instance_ids']} #{region} ")
      instance_ids = CONFIG['instance_ids'].to_s.split(',')
      EbsSnapshots::Snapshot.prune_snapshot_by_instance_ids(region, instance_ids, age_in_days)
    end

    if CONFIG['image_ids'] != nil
      $LOG.debug("==> about to run prune_snapshot_by_image_ids #{CONFIG['image_ids']} #{region} ")
      image_ids = CONFIG['image_ids'].to_s.split(',')
      EbsSnapshots::Snapshot.prune_snapshot_by_image_ids(region, image_ids, age_in_days)
    end
    $LOG.info("Finished prune snapshots....")
  end


  $LOG = Logger.new(CONFIG['log_file_path'], 'monthly')

  if CONFIG['log_level'] != nil
    case CONFIG['log_level']
    when 'debug'
      $LOG.level = Logger::DEBUG
    when 'error'
      $LOG.level = Logger::Error
    when 'warn'
      $LOG.level = Logger::WARN
    when 'fatal'
      $LOG.level = Logger::FATAL
    when 'unknown'
      $LOG.level = Logger::UNKOWN
    else
      $LOG.level = Logger::INFO
    end
  else
    $LOG.level = Logger::WARN
  end

  if CONFIG['device_name'] != nil
    ROOT_DEVICE = CONFIG['device_name']
  else
    # default value of root device
    ROOT_DEVICE = '/dev/sda1'
  end

end
