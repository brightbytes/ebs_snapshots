# EbsSnapshots

## Installation
Add this line to your application's Gemfile:

    gem 'ebs_snapshots', git: "git@github.com:brightbytes/ebs_snapshots.git"

## Setup
Dump the config file as a template for customization

    bundle exec rake ebs_snapshots:dump_config

or just make a copy [the default](https://github.com/brightbytes/ebs_snapshots/blob/master/config/config.yml).

Edit that file especially to add **instance_names**, **instance_ids**, and
**image_ids**. Each of them is optional but at least one needs to be
populated to trigger any snapshots.

## Usage

### Rake
Run that config:

    bundle exec rake ebs_snapshots:run[path/to/customized/config.yml]

This task should be scheduled to run daily.

### RabbitMQ
In /bin/rabbitmq_client.rb is a RabbitMQ consumer client which triggers snapshot using messages.

The client subscribes to messages named `ebs.snapshots`. The message body should be a Ruby Hash with any customizations of the config.yml. For example `"{instance_ids: 'i-b90bcdb3'}"`

### Custom Apps

    require 'ebs_snapshots'
    ebs_snapshot = EbsSnapshots::Base.new
    config = EbsSnapshots.load_config('path/to/customized/config.yml')
    ebs_snapshot.run(config)

### Testing
`bundle exec rspec` or `bundle exec guard`
