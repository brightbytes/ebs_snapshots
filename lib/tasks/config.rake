require 'yaml'
require 'fileutils'
require 'ebs_snapshots'
include EbsSnapshots

namespace :ebs_snapshots do

  desc "Task to writes the config/config.yml to the pwd"
  task :copy do
    if File.exist?(File.join(Dir.pwd, 'config/config.yml'))
      FileUtils.cp((File.join(Dir.pwd, 'config/config.yml')), File.join(Dir.pwd))
    else
      puts "File doesn't exist on following path : config/config.yml"
    end
  end

  desc "Task to runs all of the appropriate snapshot/cleanup methods."
  task :cleanup, [:path] do |t, args|
    if args.path
      if File.exist?(args.path) && (YAML::load_file(args.path) rescue false)
        EbsSnapshots.prune_snapshots(args.path)
      else
        puts "Please specify the valid yml file path."
      end
    else
      EbsSnapshots.prune_snapshots
    end
  end

  desc "Merge config file with specified file."
  task :merge_config, [:path] do |t, args|
    if args.path
      if File.exist?(args.path)
        #copy original config file to current directory.
        FileUtils.cp((File.join(Dir.pwd, 'config/config.yml.sample')), File.join(Dir.pwd))

        config_param = YAML::load_file((File.join(Dir.pwd, 'config/config.yml.sample')))
        tmp_param = YAML::load_file(args.path) rescue {}

        # if original config file is empty.
        config_param = config_param ? config_param : {}
        #if second file is empty
        tmp_param = tmp_param ? tmp_param : {}
        result = {}
        result = merge_hash(config_param, tmp_param)

        #Generate new yaml file by merging tow files.
        File.open((File.join(Dir.pwd, 'config/config.yml')), 'w'){|f|
          f.write(result.to_yaml.gsub("---\n", ''))
        }
      else
        puts "Please specify the correct path."
      end
    else
      puts "Please specify the the path as argument."
    end
  end

  #merge_hash : will merge two hashes.
  def merge_hash(config_param, tmp_param)
    config_param.merge(tmp_param){|key, first, second|
      if first.class.eql?(Hash) && second.class.eql?(Hash)
        merge_hash(first, second)
      elsif second.class.eql?(Hash)
        if first.class.eql?(Hash)
          merge_hash(second, first)
        else
          second
        end
      else
        tmp_param[key] ?  tmp_param[key] : config_param[key]
      end
    }
  end

end
