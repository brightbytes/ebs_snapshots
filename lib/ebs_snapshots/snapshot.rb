require 'aws-sdk-core'
require 'ebs_snapshots/instance.rb'
require 'ebs_snapshots'


module EbsSnapshots

  module Snapshot
    include EbsSnapshots::Instance
    # Create snapshots from instance name
    def create_snapshot_from_instance_name(region, instance_names, namespace)
      instance_names.each { |instance_name|
        $LOG.debug("==> Creating snapshot from instance name #{instance_name}")
        # List all instances created using the tag name.
        instance_ids = EbsSnapshots::Instance.list_instances_from_tag(region, instance_name)
        create_snapshot_from_instances(region, instance_ids, namespace)
      }
    end

    # Create snapshots from instances
    def create_snapshot_from_instances(region, instance_ids, namespace)
      instance_ids.each { |instance|
        $LOG.debug("==> Creating snapshot from Instance #{instance_ids}")
        # List all volumes attached to the instance.
        volume_ids = EbsSnapshots::Instance.list_volumes_from_instance(region, instance)
        capture_snapshots(region, volume_ids)
      }
    end

    # Create snapshots from images
    def create_snapshot_from_images(region, image_ids, namespace)
      image_ids.each { |image|
        $LOG.debug("==> Creating snapshot from image #{image}")
        # List all instances created using the tag name.
        instance_ids = EbsSnapshots::Instance.list_instances_from_ami(region, image)
        create_snapshot_from_instances(region, instance_ids, namespace)
      }
    end

    # Delete snapshots by instance name
    def prune_snapshot_by_instance_name(region, instance_names, age_in_days)
      instance_names.each { |instance_name|
        $LOG.debug("==> Deleting snapshot using instance name #{instance_name}")
        # List all instances created using the tag name.
        instance_ids = EbsSnapshots::Instance.list_instances_from_tag(region, instance_name)
        prune_snapshot_by_instance_ids(region, instance_ids, age_in_days)
      }
    end

    # delete snapshots from instances
    def prune_snapshot_by_instance_ids(region, instance_ids, age_in_days)
      instance_ids.each { |instance|
        $LOG.debug("==> Deleting snapshot using instance id #{instance}")
        # List all volumes attached to the instance.
        volume_ids = EbsSnapshots::Instance.list_volumes_from_instance(region, instance)
        delete_snapshots(region, volume_ids, age_in_days)
      }
    end

    # Delete snapshots from images
    def prune_snapshot_by_image_ids(region, image_ids, age_in_days)
      image_ids.each { |image|
        $LOG.debug("==> Deleting snapshot using image id #{image}")
        # List all instances created using the tag name.
        instance_ids = EbsSnapshots::Instance.list_instances_from_ami(region, image)
        prune_snapshot_by_instance_ids(region, instance_ids, age_in_days)
      }
    end

    # delete snapshots.
    def delete_snapshots(region, volume_ids, age_in_days)
      volume_ids.each { |volume|
        snapshot_ids = list_snapshots_to_delete(region, volume, age_in_days)

        snapshot_ids.each { |snapshot_id|
          name = "#{volume}"
          delete_snapshot(region, snapshot_id)
        }
      }
    end

    # Capture snapshots.
    def capture_snapshots(region, volume_ids)
      volume_ids.each { |volume|
        name = "#{volume}"
        create_snapshot(region, volume, name)
      }
    end

    # Create snapshot of given volume id.
    def create_snapshot(region, volume_id, description)
      ec2 = Aws::EC2::Client.new(region: region)
      resp = ec2.create_snapshot(
        volume_id: volume_id,
        description: "#{description}-#{Time.now.utc.strftime("%Y-%m-%d.%H%M%S")}",
      )
      $LOG.info("Created snapshot #{resp[:snapshot_id]} of volume #{volume_id}")
    end

    # Delete snapshot by id.
    def delete_snapshot(region, snapshot_id)
      ec2 = Aws::EC2::Client.new(region: region)
      resp = ec2.delete_snapshot(
        snapshot_id: snapshot_id,
      )
      $LOG.info("Deleted snapshot #{snapshot_id}")
    end

    # List snapshots to delete from specified volume id and retention period.
    def list_snapshots_to_delete(region, volumeId, retention_age_in_days)
      ec2 = Aws::EC2::Client.new(region: region)
      resp = ec2.describe_snapshots(
        filters: [
          {
            name: 'volume-id',
            values: [volumeId],
          },
        ],
      )
      snapshot_ids = []
      resp[:snapshots].each { |i|
        current_time = Time.now
        snapshot_start_time = Time.at(i[:start_time])
        current_age_in_days = (current_time - snapshot_start_time).to_i / (24 * 60 * 60)
        $LOG.debug("current snapshot age in days :#{current_age_in_days} and snapshot retention age in days #{retention_age_in_days.to_i} \n")
        # skip snapshot if retention age days is non zero and current age days is less thank retention age days
        next if retention_age_in_days.to_i != 0 && current_age_in_days <= retention_age_in_days.to_i
        snapshot_ids.compact!
        snapshot_ids.push(i[:snapshot_id])
        $LOG.debug("snapshot Id to delete : #{i[:snapshot_id]}\n")
      }
      snapshot_ids
    end

  end
end
