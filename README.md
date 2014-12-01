ebs_snapshots
=============

A ruby gem to automate ebs snapshots

# Installation
Add this line to your application's Gemfile:

    gem 'ebs_snapshots', git: "git@github.com:brightbytes/ebs_snapshots.git"

# Configure using rake
This rake tasks that writes the config/config.yml to the pwd.

    rake ebs_snapshots:copy

This rake task that runs all of the appropriate snapshot/cleanup methods and accepts an optional argument that is the path to a customized config file.

    rake ebs_snapshots:cleanup[<config file path>]

# Configure using library method
This library method that runs all of the appropriate snapshot/cleanup methods and accepts an optional argument that is the path to a customized config file.

    ruby lib/snapshot_cleanup.rb <config file path>

# Setup volume filter
Update config/config.yml with the configuration required to find out the volumes for snapshot.

# Using IAM instance role
Your instance should be IAM role enabled to resolved the credentials using Amazon instance metadata API.

## Usage
Create or Delete ebs volume snapshots. Within /bin you will find several clients written for processing snapshot.
Please refer examples/*.sample for sender request structure.

Rabbitmq Client
    - Rabbitmq consumer client which triggers snapshot using messages.

        - Message Queue : "ebs.snapshots"
        - Message Body
            - "create" : creates snapshot using configs from config/config.yml.
            - "delete" : deletes snapshot using configs from config/config.yml.

Ruby Client
    - Creates and deletes snapshot using configs from config/config.yml.
