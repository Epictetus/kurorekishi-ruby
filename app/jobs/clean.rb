
class Clean
  @queue = :cleaner

  def self.perform
    Bucket.find_in_batches(:batch_size => 100) do |buckets|
      buckets.each do |job|
        if job.expired? then job.destroy; return end
      end
    end
  end
end
