#!/usr/bin/env ruby
require 'yaml'
require 'logger'
require Dir.pwd + '/lib/ebs_snapshots/version.rb'
require Dir.pwd + '/lib/ebs_snapshots/snapshot.rb'
require Dir.pwd + '/lib/ebs_snapshots/instance.rb'

CONFIG = YAML::load_file((File.join(Dir.pwd, 'config/config.yml')))
INSTANCE_NAMES = 'instance_names'
INSTANCE_IDS = 'instance_ids'
IMAGE_IDS = 'image_ids'
DEVICE_NAME = 'device_name'

module EbsSnapshots
  include EbsSnapshots::Snapshot
  def create_snapshots
    $LOG.info("Starting create EbsSnapshots::Snapshot....")
    region = CONFIG['region'] || ENV['AWS_REGION']

    if CONFIG[INSTANCE_NAMES] != nil
      $LOG.debug("==> about to run create_snapshot_from_instance_name #{CONFIG[INSTANCE_NAMES]} #{region} ")
      instance_names = CONFIG[INSTANCE_NAMES].to_s.split(',')
      EbsSnapshots::Snapshot::create_snapshot_from_instance_name(region, instance_names, CONFIG['namespace'])
    end

    if CONFIG[INSTANCE_IDS] != nil
      $LOG.debug("==> about to run create_snapshot_from_instances #{CONFIG[INSTANCE_IDS]} #{region} ")
      instance_ids = CONFIG[INSTANCE_IDS].to_s.split(',')
      EbsSnapshots::Snapshot.create_snapshot_from_instances(region, instance_ids, CONFIG['namespace'])
    end

    if CONFIG[IMAGE_IDS] != nil
      $LOG.debug("==> about to run create_snapshot_from_images #{CONFIG[IMAGE_IDS]} #{region} ")
      image_ids = CONFIG[IMAGE_IDS].to_s.split(',')
      EbsSnapshots::Snapshot.create_snapshot_from_images(region, image_ids, CONFIG['namespace'])
    end
    $LOG.info("Finished create EbsSnapshots::Snapshot....")
  end

  def prune_snapshots(config_path = nil)

    if config_path
      config = YAML::load_file(config_path)
      $LOG = Logger.new(config['log_file_path'], 'monthly')
      set_log_level(config)
    else
      config = CONFIG
    end

    $LOG.info("Starting prune snapshots....")
    region = config['region'] || ENV['AWS_REGION']
    age_in_days = config['retention']['daily']

    if age_in_days == nil
      periodic_interval = config['retention']['periodic']['interval']
      periodic_span = config['retention']['periodic']['span']

      # Calculate age_in_days by multiplying interval and span
      if periodic_interval != nil && periodic_span != nil
        age_in_days = periodic_interval * periodic_span
      end
    end

    if config[INSTANCE_NAMES] != nil
      $LOG.debug("==> about to run prune_snapshot_by_instance_name #{config[INSTANCE_NAMES]} #{region} ")
      instance_names = config[INSTANCE_NAMES].to_s.split(',')
      EbsSnapshots::Snapshot.prune_snapshot_by_instance_name(region, instance_names, age_in_days)
    end

    if config[INSTANCE_IDS] != nil
      $LOG.debug("==> about to run prune_snapshot_by_instance_ids #{config[INSTANCE_IDS]} #{region} ")
      instance_ids = config[INSTANCE_IDS].to_s.split(',')
      EbsSnapshots::Snapshot.prune_snapshot_by_instance_ids(region, instance_ids, age_in_days)
    end

    if config[IMAGE_IDS] != nil
      $LOG.debug("==> about to run prune_snapshot_by_image_ids #{config[IMAGE_IDS]} #{region} ")
      image_ids = config[IMAGE_IDS].to_s.split(',')
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

  if CONFIG[DEVICE_NAME] != nil
    ROOT_DEVICE = CONFIG[DEVICE_NAME]
  else
    # default value of root device
    ROOT_DEVICE = '/dev/sda1'
  end

  private

  # set_log_level : to set custom log level for rake task and cleanup library method.
  def set_log_level(config)
    if config['log_level']
      case config['log_level']
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
      when
        $LOG.level = Logger::INFO
      end
    else
      $LOG.level = Logger::DEBUG
    end
  end

end
