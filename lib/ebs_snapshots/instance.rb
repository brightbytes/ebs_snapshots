require Dir.pwd + '/lib/ebs_snapshots.rb'

module EbsSnapshots
  module Instance

    # List instances launched using the tag.
    def list_instances_from_tag(region, instance_name)
      ec2 = Aws::EC2::Client.new(region: region)
      resp = ec2.describe_instances(
        filters: [
          {
            name: 'tag-value',
            values: [instance_name]
          }
        ],
      )
      instance_ids = []
      resp[:reservations].each { |r|
        r[:instances].each { |i|
          next unless i[:state][:name] == 'running'
          instance_ids.push(i[:instance_id])
          $LOG.debug("Instance Id :#{i[:instance_id]}\n")
        }
      }
      instance_ids
    end

    # List volumes attached to the instance.
    def list_volumes_from_instance(region, instance_id)
      $LOG.debug("Listing Volumes for Instance : #{instance_id}\n")
      ec2 = Aws::EC2::Client.new(region: region)
      resp = ec2.describe_volumes(
        filters: [
          {
            name: 'attachment.instance-id',
            values: [instance_id],
          },
        ],
      )

      volume_ids = []
      resp[:volumes].each { |i|
        # Skip root volumes attached to /dev/sda1
        next if i[:attachments][0].device == ROOT_DEVICE
        volume_ids.compact!
        volume_ids.push(i[:volume_id])
        $LOG.debug("Volume Id to process snapshot : #{i[:volume_id]} Device : #{i[:attachments][0].device}\n")
      }
      $LOG.debug("List of volumes to process snapshot : #{volume_ids}\n")
      volume_ids
    end

    # List instances launched using the ami.
    def list_instances_from_ami(region, image_id)
      ec2 = Aws::EC2::Client.new(region: region)
      resp = ec2.describe_instances(
        filters: [
          {
            name: 'image-id',
            values: [image_id]
          }
        ],
      )
      instance_ids = []
      resp[:reservations].each { |r|
        r[:instances].each { |i|
          next unless i[:state][:name] == 'running'
          instance_ids.push(i[:instance_id])
          $LOG.debug("Instance Id :#{i[:instance_id]}\n")
        }
      }
      instance_ids
    end

  end
end
