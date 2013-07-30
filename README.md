resque-stress
=============

Stress testing of resque workers

Usage
=====

The above usage is from the examples/rails_demo app.

1. Define a test harness using the resque-stress DSL.

```ruby
harness :rails_demo do
  target_rate 10

  queue :reports do
    job :sales_report_job do
      weight 41
      runtime_min 1
      runtime_max 2
      error_rate 0.1
    end

    job :inventory_report_job do
      weight 39
      runtime_min 0.5
      runtime_max 1.0
      error_rate 0.2
    end
  end

  queue :import_export do
    job :import_job do
      weight 9
      runtime_min 3
      runtime_max 4
      error_rate 0.3
    end
    job :export_job do
      weight 11
      runtime_min 3
      runtime_max 4
      error_rate 0.3
    end
  end
end
```

2. Configure your app to make use of the DSL generated workers.

```ruby
require 'resque'

Resque.redis = 'localhost:6379:15'
Resque.redis.flushdb

require 'resque-stress'

load File.join(Rails.root, 'lib', 'jobs.rb')

path = File.join(Rails.root, 'config', 'stressque.dsl')
harness = Resque::Stress::DSL.eval_file(path)
harness.freeze_classes!
```

3. Run Resque in your app to pick up any jobs.

```
QUEUES=* VVERBOSE=1 be rake resque:work
```

4. Run the test harness.

```be stressque -c examples/demo.dsl -r localhost:6379:15```

5. Examine the results.

DSL
===
The examples/demo.dsl file has comments describing the dsl in details.

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
      weight 5

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
      weight 1
      runtime_min 5
      runtime_max 10
      error_rate 0.2
    end
  end

  # another queue
  queue :reports do
    # another job within the queue.
    job :eeo do
      weight 1
      error_rate 0.05
    end
  end
end
```
