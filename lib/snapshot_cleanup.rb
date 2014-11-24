require 'yaml'
require Dir.pwd + '/lib/ebs_snapshots.rb'
include EbsSnapshots

# ebs_snapshot_cleanup : Library method that runs all of the appropriate snapshot/cleanup methods.
def ebs_snapshot_cleanup(config_path)
  if config_path
    if File.exist?(config_path) && (YAML::load_file(config_path) rescue false)
      EbsSnapshots.prune_snapshots(config_path)
    else
      puts "Please specify the valid yml file path."
    end
  else
	EbsSnapshots.prune_snapshots
  end
end

ebs_snapshot_cleanup(ARGV[0])
