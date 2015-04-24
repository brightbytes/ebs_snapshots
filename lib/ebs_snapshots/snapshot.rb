module EbsSnapshots

  module Snapshot
    EPOCH = Time.parse('1970-01-01')

    def capture_snapshots
      volume_ids.each { |volume_id| create_snapshot(volume_id) }
    end

    def create_snapshot(volume_id)
      ec2_client.create_snapshot(
        volume_id: volume_id,
        description: "#{config['namespace']}-#{volume_id}-#{run_time.strftime("%Y-%m-%d.%H%M%S")}"
      )
      logger.info("create_snapshot(#{volume_id})") # the ec2_client response is useless for reporting
    end

    def prune_snapshots
      snapshots_to_delete.each { |snapshot_id|
        delete_snapshot(snapshot_id)
      }
    end

    def delete_snapshot(snapshot_id)
      ec2_client.delete_snapshot( snapshot_id: snapshot_id )
      logger.info("delete_snapshot(#{snapshot_id})")
    end

    def age_in_days(since)
      (run_time - since).to_i / (24 * 60 * 60)
    end

    def is_periodic?(age)
      return true if config['intervals'].zero?
      (age_in_days(EPOCH) - age) % config['intervals'] == 0
    end

    def is_within_periodic?(age)
      age <= (config['interval_days'] * config['intervals'])
    end

    def snapshots_to_delete
      resp = ec2_client.describe_snapshots(
        filters: [
          { name: 'volume-id', values: volume_ids },
        ],
      )
      snapshot_ids = []
      resp[:snapshots].each { |i|
        age = age_in_days(Time.at(i[:start_time]))
        logger.debug("age #{age}")
        next if age < config['retain_for_days'] # there will be retain_for_days + 1 snapshots
        next if is_periodic?(age) and is_within_periodic?(age) # there will be retain_for_days + 1 + intervals snapshots
        snapshot_ids << i[:snapshot_id]
      }
      logger.info("snapshots_to_delete found #{snapshot_ids.inspect}")
      snapshot_ids
    end

  end
end
