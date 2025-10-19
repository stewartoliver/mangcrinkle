# Good Job configuration for testing
RSpec.configure do |config|
  # Use Good Job adapter for job tests
  config.before(:each, type: :job) do
    ActiveJob::Base.queue_adapter = :good_job
  end

  # Helper methods for testing jobs
  config.include ActiveJob::TestHelper, type: :job
end
