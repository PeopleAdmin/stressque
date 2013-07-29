resque-stress
=============

Stress testing of resque workers

Usage
=====

Define a test harness using the resque-stress DSL.

```ruby
# the top-level harness block defines a test
# harness.
harness :my_load_scenario do
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

      # The weight of the job within the overall
      # pool of jobs.  The likelihood a job is
      # to be enqueued is its weight / sum of all
      # job weights.  Defaults to 1.
      weight: 5

      # The range of time it should take to perform
      # the job.  A random value will be chosen
      # within this range, and the job will "hard
      # sleep" for that time.  A hard sleep is one
      # that actually pegs the CPU for the duration
      # to simulate workload.  Default range is
      # 1..1
      runtime_range: 1..2

      # The error_rate to maintain within the job.
      # Approximately this percentage of enqueues
      # will result in a failure of the job.  The
      # default is 0
      error_rate: .1
    end

    # another job within the same queue
    job :slow_email do
      weight: 1
      runtime_min: 5
      runtime_max: 10
      error_rate: .2
    end
  end

  # another queue
  queue :reports do
    # another job within the queue.
    job :eeo do
      weight: 1
      error_rate: .05
    end
  end
end
```
