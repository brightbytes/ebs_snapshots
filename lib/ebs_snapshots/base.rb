require 'yaml'
require 'logger'
require 'aws-sdk'
require_relative '../ebs_snapshots'
require_relative 'snapshot'
require_relative 'instance'

module EbsSnapshots
  class Base
    attr_reader :config, :ec2_client, :logger, :region, :run_time

    include EbsSnapshots::Snapshot
    include EbsSnapshots::Instance

    BASE_CONFIG = File.absolute_path(File.join(__FILE__, '../../../config/config.yml'))
    IMAGE_IDS = 'image_ids' # these constants map to config keys
    INSTANCE_IDS = 'instance_ids'
    INSTANCE_NAMES = 'instance_names'

    def run(config)
      set_config(config)
      @run_time = Time.now.utc
      logger.info("EbsSnapshots.run start #{@run_time}")
      prune_snapshots
      capture_snapshots
      logger.info("EbsSnapshots.run complete #{Time.now.utc}")
    end

    def volume_ids
      return @volume_ids if @volume_ids
      instance_ids = config[INSTANCE_IDS]
      config[IMAGE_IDS].each do |image_id|
        instance_ids += instance_ids_from_ami(image_id)
      end
      config[INSTANCE_NAMES].each do |instance_name|
        instance_ids += instance_ids_from_tag(instance_name)
      end
      instance_ids.uniq!
      @volume_ids = list_volume_ids_from_instance_ids(instance_ids)
      logger.info("volume_ids: #{@volume_ids.inspect}")
      @volume_ids
    end

    def set_config(config)
      raise RuntimeError, "set_config argument must be a ruby hash" unless config.is_a?(Hash)
      @config = EbsSnapshots.load_config(BASE_CONFIG)
      @config.merge!(config)
      set_logger
      @config['retain_for_days'] = @config['retain_for_days'].to_i
      @config['interval_days'] = @config['interval_days'].to_i
      @config['intervals'] = @config['intervals'].to_i
      @region = config['region'] || ENV['AWS_REGION']
      @ec2_client = Aws::EC2::Client.new(region: region)
    end

    def set_logger
      level = case config['log_level']
      when 'error'
        Logger::ERROR
      when 'fatal'
        Logger::FATAL
      when 'info'
        Logger::INFO
      when 'warn'
        Logger::WARN
      when 'debug'
        Logger::DEBUG
      else
        Logger::INFO
      end
      @logger = Logger.new(config['log_file_path'])
      @logger.level = level
    end

  end
end
