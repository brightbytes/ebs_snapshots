require 'fileutils'
require 'ebs_snapshots'

namespace :ebs_snapshots do

  desc "Writes the config/config.yml to the current working directory"
  task :dump_config do
    path = 'config/config.yml'
    pwd = File.join(Dir.pwd)
    FileUtils.cp((File.join(Dir.pwd, path)), pwd)
    puts "Wrote config to #{File.join(pwd, path)}"
  end

  desc "Task to runs all of the appropriate snapshot/cleanup methods."
  task :run, [:config_path] do |t, args|
    if File.exist?(args.config_path)
      config = EbsSnapshots::load_config(args.config_path)
      EbsSnapshots::Base.new.run(config)
    else
      puts "Please specify the valid yml file path."
    end
  end
end
