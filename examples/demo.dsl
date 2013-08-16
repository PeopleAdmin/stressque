# the top-level harness block defines a test
# harness.
harness :my_load_scenario do
  # The event publisher to use for resque clues
  # to push resque events to some external data
  # store for analysis.
  event_publisher do
    Resque::Plugins::Clues::StandardOutPublisher.new
  end

  # target_rate defines the target rate of jobs
  # enqueued per second.
  target_rate 10

  # queue blocks define a queue within the stress
  # test
  queue :email do

    # job blocks define a job type to be created
    # that will be enqueued to the parent queue.
    # The name specified here will be camelcased
    # (fast_email will become FastEmail)
    job :fast_email do

      # The volume of the job within the overall
      # pool of jobs.  The likelihood a job is
      # to be enqueued is its volume / sum of all
      # job volume.  Defaults to 1.
      volume 5

      # The minimum amount of time to perform the
      # job.  Defaults to 1.
      runtime_min 5

      # The maximum amount of time to perform the
      # job.  Defaults to 2.  The runtime is a
      # random between runtime_min..runtime_max
      runtime_max 10

      # The error_rate to maintain within the job.
      # Approximately this percentage of enqueues
      # will result in a failure of the job.  The
      # default is 0
      error_rate 0.1
    end

    # another job within the same queue
    job :slow_email do
      volume 1
      runtime_min 5
      runtime_max 10
      error_rate 0.2
    end
  end

  # another queue
  queue :reports do
    # another job within the queue.
    job :eeo do
      volume 1
      error_rate 0.05
    end
  end
end
