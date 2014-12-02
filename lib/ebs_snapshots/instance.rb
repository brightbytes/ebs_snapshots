module EbsSnapshots
  module Instance

    def instance_ids_from_ami(image_id)
      resp = ec2_client.describe_instances(
        filters: [
          { name: 'image-id', values: [image_id] }
        ],
      )
      instance_ids = []
      resp[:reservations].each { |r|
        r[:instances].each { |i|
          next unless i[:state][:name] == 'running'
          instance_ids << i[:instance_id]
        }
      }
      instance_ids
    end

    def instance_ids_from_tag(instance_name)
      resp = ec2_client.describe_instances(
        filters: [
          { name: 'tag-value', values: [instance_name] }
        ],
      )
      instance_ids = []
      resp[:reservations].each { |r|
        r[:instances].each { |i|
          next unless i[:state][:name] == 'running'
          instance_ids << i[:instance_id]
        }
      }
      instance_ids
    end

    def list_volume_ids_from_instance_ids(instance_ids)
      resp = ec2_client.describe_volumes(
        filters: [
          { name: 'attachment.instance-id', values: instance_ids },
        ],
      )
      volume_ids = []
      resp[:volumes].each { |i|
        next if config['exclude_devices'].include?(i[:attachments][0].device)
        volume_ids << i[:volume_id]
      }
      volume_ids
    end

  end
end
