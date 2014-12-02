require 'yaml'
require 'logger'
require_relative 'ebs_snapshots/base'
require_relative 'ebs_snapshots/version'

module EbsSnapshots
  def load_config(path)
    YAML::load_file(path)
  end
  module_function :load_config
end
